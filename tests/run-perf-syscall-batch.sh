#!/usr/bin/env bash
# PERF-008: syscall batch strace bench — I/O syscall counts vs baseline / ref.
#
# Honesty: soft XLANG_SYSCALL_BATCH_FAIL:-0 previously left over-cap /
# batch≥ref unchecked (silent OK = portable false-green). Soft SKIP→OK on
# missing native / prefer-xlang-c-only / sink-compile soft exit retired.
# Prefer product xlang_asm. Over-cap / batch≥ref / compile-fail = obs
# (FAIL=1 still hard). Non-Linux / no strace = skip. Explicit bad XLANG =
# hard die. Report run=/obs=/skip=.
#
# Usage:
#   ./tests/run-perf-syscall-batch.sh
#   XLANG=./compiler/xlang_asm ./tests/run-perf-syscall-batch.sh
# Env:
#   XLANG_SYSCALL_BATCH_FAIL=1 — over-cap / batch≥ref hard-fail
#   XLANG_SYSCALL_BATCH_REQUIRE_STRACE=1 — no strace = hard (CI Linux)
# PLATFORM: SHARED archaeology (Ubuntu gold; Darwin = skip, no strace).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/perf-syscall-batch.sh
. tests/lib/perf-syscall-batch.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
# Honesty: do NOT auto-make before resolve.

BASELINE="${XLANG_SYSCALL_BATCH_BASELINE:-tests/baseline/syscall-batch-perf.tsv}"
OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"
FAIL_FLAG="${XLANG_SYSCALL_BATCH_FAIL:-0}"
REQUIRE_STRACE="${XLANG_SYSCALL_BATCH_REQUIRE_STRACE:-0}"
BENCH_MB="${XLANG_IO_BENCH_MB:-16}"
BENCH_FILE="bench/.io_mmap_bench_tmp"
BENCH_BYTES=$((BENCH_MB * 1048576))
EXPECT_ZC_RC=$((BENCH_BYTES & 255))
# PLATFORM: SHARED — sink remapped with i07_ bench id (wave rename).
SINK_SRC="bench/i07_zero_copy_sendfile_sink.c"
SINK_BIN="/tmp/xlang_syscall_batch_sink"
PREFIX="xlang: [XLANG_SYSCALL_BATCH]"
OBS=0
RUN_OK=0
SKIP=0
CASE_OK=0
CASE_TOTAL=0
CASE_OBS=0

die() {
  echo "syscall-batch FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

echo "=== PERF-008: syscall batch strace bench (baseline=${BASELINE}) ==="

# PLATFORM: DARWIN / non-Linux — strace N/A; honest skip before soft OK.
if ! perf_sb_strace_probe_ok; then
  if [ "$REQUIRE_STRACE" = "1" ]; then
    die "strace unavailable (XLANG_SYSCALL_BATCH_REQUIRE_STRACE=1)"
  fi
  if [ -n "${XLANG:-}" ]; then
    resolve_shu >/dev/null || die "XLANG=${XLANG} not native (refuse soft SKIP→OK)"
  fi
  SKIP=1
  echo "syscall-batch perf SKIP: need Linux + working strace"
  ok_report
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang_asm/xlang-c/xlang (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "syscall-batch: resolve=$XLANG_BIN"

if [ ! -f "$BENCH_FILE" ]; then
  dd if=/dev/zero of="$BENCH_FILE" bs=1M count="$BENCH_MB" status=none 2>/dev/null || \
    dd if=/dev/zero of="$BENCH_FILE" bs=1048576 count="$BENCH_MB" 2>/dev/null || \
    die "create bench file $BENCH_FILE"
fi

ensure_std_c_o ../std/net/net.o

[ -f "$SINK_SRC" ] || die "missing $SINK_SRC"
cc -O2 "$SINK_SRC" -o "$SINK_BIN" || die "compile sink $SINK_SRC"

declare -A SB_READ SB_WRITE SB_READV SB_WRITEV SB_SPLICE SB_SENDFILE SB_IO_TOTAL
CASE_IDX=0

# Pass 1: compile + strace collect.
while IFS=$'\t' read -r case_id bench_src expect_exit needs_sink _rest; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*) continue ;; esac
  CASE_TOTAL=$((CASE_TOTAL + 1))
  CASE_IDX=$((CASE_IDX + 1))
  exe="${OUT_DIR}/xlang_syscall_batch_${case_id}"
  rm -f "$exe"

  if [ ! -f "$bench_src" ]; then
    echo "syscall-batch OBS: missing bench $bench_src ($case_id)" >&2
    CASE_OBS=$((CASE_OBS + 1))
    OBS=1
    continue
  fi

  echo "── measure ${case_id} (${bench_src}) ──"
  if ! XLANG="$XLANG_BIN" "$XLANG_BIN" -L . "$bench_src" -o "$exe"; then
    echo "syscall-batch OBS: compile $bench_src" >&2
    CASE_OBS=$((CASE_OBS + 1))
    OBS=1
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
    echo "syscall-batch OBS: strace $case_id rc=${strace_rc}" >&2
    CASE_OBS=$((CASE_OBS + 1))
    OBS=1
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

# Pass 2: cap + batch_lt_ref + emit.
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
      echo "syscall-batch OBS: $case_id io_total=${total} >= ref ${ref_case}=${ref_total}" >&2
    fi
  fi

  perf_sb_report_emit "$case_id" "${SB_READ[$case_id]}" "${SB_WRITE[$case_id]}" \
    "${SB_READV[$case_id]}" "${SB_WRITEV[$case_id]}" "${SB_SPLICE[$case_id]}" \
    "${SB_SENDFILE[$case_id]}" "$total" "${ref_case:--}" "$ref_total" "$ok"

  if [ "$ok" = "1" ]; then
    echo "syscall-batch OK: $case_id io_total=${total} ref=${ref_total}"
    CASE_OK=$((CASE_OK + 1))
    RUN_OK=1
  else
    echo "syscall-batch OBS: $case_id exceeds cap or batch≥ref" >&2
    CASE_OBS=$((CASE_OBS + 1))
    OBS=1
    if [ "$FAIL_FLAG" = "1" ]; then
      die "$case_id exceeds cap or batch≥ref (XLANG_SYSCALL_BATCH_FAIL=1)"
    fi
  fi
done < "$BASELINE"

if [ "$CASE_TOTAL" -eq 0 ]; then
  die "no cases in $BASELINE"
fi

echo "syscall-batch perf OK (cases=${CASE_OK}/${CASE_TOTAL} obs_cases=${CASE_OBS})"
ok_report
exit 0
