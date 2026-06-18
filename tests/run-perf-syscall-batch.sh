#!/usr/bin/env bash
# PERF-008：syscall 批处理 bench — strace 统计 I/O syscall 并与 baseline / ref 比较
#
# 用法：
#   ./tests/run-perf-syscall-batch.sh
#   SHU=./compiler/shu-c ./tests/run-perf-syscall-batch.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/perf-syscall-batch.sh
. tests/lib/perf-syscall-batch.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh

BASELINE="${SHU_SYSCALL_BATCH_BASELINE:-tests/baseline/syscall-batch-perf.tsv}"
OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"
FAIL_FLAG="${SHU_SYSCALL_BATCH_FAIL:-0}"
REQUIRE_STRACE="${SHU_SYSCALL_BATCH_REQUIRE_STRACE:-0}"
BENCH_MB="${SHU_IO_BENCH_MB:-16}"
BENCH_FILE="tests/bench/.io_mmap_bench_tmp"
BENCH_BYTES=$((BENCH_MB * 1048576))
EXPECT_ZC_RC=$((BENCH_BYTES & 255))
SINK_BIN="/tmp/shu_syscall_batch_sink"

SHU_BIN="${SHU:-}"
if [ -z "$SHU_BIN" ]; then
  for cand in ./compiler/shu-c ./compiler/shu ./compiler/shu_asm; do
    case "$cand" in /*) abs="$cand" ;; *) abs="$(pwd)/$cand" ;; esac
    if dod_native_exe "$abs"; then
      SHU_BIN="$abs"
      break
    fi
  done
  SHU_BIN="${SHU_BIN:-./compiler/shu-c}"
else
  case "$SHU_BIN" in /*) ;; *) SHU_BIN="$(pwd)/$SHU_BIN" ;; esac
fi

LINK_SHU="$SHU_BIN"
for cand in ./compiler/shu-c ./compiler/shu; do
  case "$cand" in /*) abs="$cand" ;; *) abs="$(pwd)/$cand" ;; esac
  if dod_native_exe "$abs"; then
    LINK_SHU="$abs"
    break
  fi
done

echo "=== PERF-008: syscall batch strace bench (baseline=${BASELINE}) ==="

if ! dod_native_exe "$LINK_SHU"; then
  echo "syscall-batch perf SKIP: ${LINK_SHU} not native"
  exit 0
fi

if ! perf_sb_strace_probe_ok; then
  if [ "$REQUIRE_STRACE" = "1" ]; then
    echo "syscall-batch perf FAIL: strace unavailable (SHU_SYSCALL_BATCH_REQUIRE_STRACE=1)" >&2
    exit 1
  fi
  echo "syscall-batch perf SKIP: need Linux + working strace"
  exit 0
fi

if [ ! -f "$BENCH_FILE" ]; then
  dd if=/dev/zero of="$BENCH_FILE" bs=1M count="$BENCH_MB" status=none 2>/dev/null || \
    dd if=/dev/zero of="$BENCH_FILE" bs=1048576 count="$BENCH_MB" 2>/dev/null
fi

ensure_std_c_o ../std/fs/fs.o
ensure_std_c_o ../std/net/net.o

cc -O2 tests/bench/zero_copy_sendfile_sink.c -o "$SINK_BIN" 2>/dev/null || {
  echo "syscall-batch perf SKIP: compile sink failed"
  exit 0
}

declare -A SB_READ SB_WRITE SB_READV SB_WRITEV SB_SPLICE SB_SENDFILE SB_IO_TOTAL
HARD_FAIL=0
CASE_OK=0
CASE_TOTAL=0
CASE_IDX=0

# 第一遍：编译 + strace 收集各 case 计数。
while IFS=$'\t' read -r case_id bench_src expect_exit needs_sink _rest; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*) continue ;; esac
  CASE_TOTAL=$((CASE_TOTAL + 1))
  CASE_IDX=$((CASE_IDX + 1))
  exe="${OUT_DIR}/shu_syscall_batch_${case_id}"
  rm -f "$exe"

  echo "── measure ${case_id} ──"
  if ! SHU="$LINK_SHU" "$LINK_SHU" -L . "$bench_src" -o "$exe"; then
    echo "syscall-batch FAIL: compile $bench_src" >&2
    HARD_FAIL=1
    continue
  fi

  exp_rc="$expect_exit"
  sink_pid=""
  port=""
  if [ "$needs_sink" = "1" ]; then
    exp_rc="$EXPECT_ZC_RC"
    port=$((38470 + CASE_IDX))
    "$SINK_BIN" "$port" >/dev/null 2>&1 &
    sink_pid=$!
    sleep 0.3
    strace_rc=0
    perf_sb_strace_io_counts "$exe" "$exp_rc" "$port" || strace_rc=$?
  else
    strace_rc=0
    perf_sb_strace_io_counts "$exe" "$exp_rc" || strace_rc=$?
  fi
  if [ -n "$sink_pid" ]; then
    kill "$sink_pid" 2>/dev/null || true
    wait "$sink_pid" 2>/dev/null || true
  fi
  if [ "$strace_rc" -ne 0 ]; then
    echo "syscall-batch FAIL: strace $case_id rc=${strace_rc}" >&2
    HARD_FAIL=1
    continue
  fi

  SB_READ[$case_id]="$perf_sb_read"
  SB_WRITE[$case_id]="$perf_sb_write"
  SB_READV[$case_id]="$perf_sb_readv"
  SB_WRITEV[$case_id]="$perf_sb_writev"
  SB_SPLICE[$case_id]="$perf_sb_splice"
  SB_SENDFILE[$case_id]="$perf_sb_sendfile"
  SB_IO_TOTAL[$case_id]=$(perf_sb_io_total "$perf_sb_read" "$perf_sb_write" "$perf_sb_readv" \
    "$perf_sb_writev" "$perf_sb_splice" "$perf_sb_sendfile")
done < "$BASELINE"

# 第二遍：cap + batch_lt_ref 校验并 emit。
while IFS=$'\t' read -r case_id _bench_src _expect_exit _needs_sink _cr _cw _crv _cwv _csp _csf _minsp _minsf ref_case _notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*) continue ;; esac
  [ -n "${SB_IO_TOTAL[$case_id]:-}" ] || continue

  ok=$(perf_sb_within_caps "$case_id" "${SB_READ[$case_id]}" "${SB_WRITE[$case_id]}" \
    "${SB_READV[$case_id]}" "${SB_WRITEV[$case_id]}" "${SB_SPLICE[$case_id]}" \
    "${SB_SENDFILE[$case_id]}" "$BASELINE")

  ref_total="-"
  total="${SB_IO_TOTAL[$case_id]}"
  if [ -n "$ref_case" ] && [ "$ref_case" != "-" ] && [ -n "${SB_IO_TOTAL[$ref_case]:-}" ]; then
    ref_total="${SB_IO_TOTAL[$ref_case]}"
    if [ "$total" -ge "$ref_total" ]; then
      ok=0
      echo "syscall-batch FAIL: $case_id io_total=${total} >= ref ${ref_case}=${ref_total}" >&2
    fi
  fi

  perf_sb_report_emit "$case_id" "${SB_READ[$case_id]}" "${SB_WRITE[$case_id]}" \
    "${SB_READV[$case_id]}" "${SB_WRITEV[$case_id]}" "${SB_SPLICE[$case_id]}" \
    "${SB_SENDFILE[$case_id]}" "$total" "${ref_case:--}" "$ref_total" "$ok"

  if [ "$ok" = "1" ]; then
    echo "syscall-batch OK: $case_id io_total=${total} ref=${ref_total}"
    CASE_OK=$((CASE_OK + 1))
  elif [ "$FAIL_FLAG" = "1" ]; then
    HARD_FAIL=1
  fi
done < "$BASELINE"

if [ "$CASE_TOTAL" -eq 0 ]; then
  echo "syscall-batch FAIL: no cases in $BASELINE" >&2
  exit 1
fi

if [ "$HARD_FAIL" -ne 0 ]; then
  echo "syscall-batch perf FAIL" >&2
  exit 1
fi

echo "syscall-batch perf OK (cases=${CASE_OK}/${CASE_TOTAL})"
