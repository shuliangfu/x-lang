#!/usr/bin/env bash
# ZC-5 门禁：fs_pipe_splice smoke +（Linux）16MiB proxy bench + strace splice 验证。
# 用法：
#   ./tests/run-zc5-gate.sh
#   SHU=./compiler/shu_asm ./tests/run-zc5-gate.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/perf-syscall-batch.sh
. "$(dirname "$0")/lib/perf-syscall-batch.sh"

SHU_BIN="${SHU:-}"
case "$SHU_BIN" in
  /*) SHU_ABS="$SHU_BIN" ;;
  "") SHU_ABS="" ;;
  *) SHU_ABS="$(pwd)/$SHU_BIN" ;;
esac

zc5_native_exe() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

if [ -z "$SHU_ABS" ] || ! zc5_native_exe "$SHU_ABS"; then
  SHU_ABS=""
  for cand in ./compiler/shu-c ./compiler/shu ./compiler/shu_asm; do
    case "$cand" in /*) abs="$cand" ;; *) abs="$(pwd)/$cand" ;; esac
    if zc5_native_exe "$abs"; then
      SHU_ABS="$abs"
      break
    fi
  done
fi

CHECK_SHU="$SHU_ABS"
if [ -z "$CHECK_SHU" ] && [ -x ./compiler/shu-c ]; then
  CHECK_SHU=./compiler/shu-c
fi

OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"
SMOKE_OUT="$OUT_DIR/shu_zc5_splice_smoke"
BENCH_OUT="$OUT_DIR/shu_zc5_splice_bench"
rm -f "$SMOKE_OUT" "$BENCH_OUT"

echo "=== ZC-5: fs_pipe_splice smoke + bench ==="

if [ -z "$CHECK_SHU" ]; then
  if make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c 2>/dev/null; then
    [ -x ./compiler/shu-c ] && CHECK_SHU=./compiler/shu-c
  fi
fi

if [ -z "$CHECK_SHU" ]; then
  echo "zc5 gate SKIP (no working shu-c/shu)"
  exit 0
fi

# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
ensure_std_c_o ../std/fs/fs.o
ensure_std_c_o ../std/net/net.o

SMOKE_SRC="tests/fs/splice_smoke.su"
BENCH_SRC="tests/bench/zero_copy_splice.su"

if ! "$CHECK_SHU" check -L . "$SMOKE_SRC" >/dev/null 2>&1; then
  echo "zc5 FAIL: typeck $SMOKE_SRC" >&2
  "$CHECK_SHU" check -L . "$SMOKE_SRC" 2>&1 || true
  exit 1
fi
if ! "$CHECK_SHU" check -L . "$BENCH_SRC" >/dev/null 2>&1; then
  echo "zc5 FAIL: typeck $BENCH_SRC" >&2
  "$CHECK_SHU" check -L . "$BENCH_SRC" 2>&1 || true
  exit 1
fi
echo "zc5: splice typeck OK"

RUN_SHU="$CHECK_SHU"
# -o 链接 fs/net 须 shu-c/shu；shu_asm 缺 fs_read_c 等 C 互操作符号。
LINK_SHU=""
for cand in ./compiler/shu-c ./compiler/shu; do
  case "$cand" in /*) abs="$cand" ;; *) abs="$(pwd)/$cand" ;; esac
  if zc5_native_exe "$abs"; then
    LINK_SHU="$abs"
    break
  fi
done
if [ -n "$LINK_SHU" ]; then
  RUN_SHU="$LINK_SHU"
elif [ -n "$SHU_ABS" ] && zc5_native_exe "$SHU_ABS"; then
  RUN_SHU="$SHU_ABS"
fi

if ! SHU="$RUN_SHU" "$RUN_SHU" -L . "$SMOKE_SRC" -o "$SMOKE_OUT" 2>/tmp/shu_zc5_smoke_build.log; then
  echo "zc5 FAIL: compile $SMOKE_SRC" >&2
  tail -8 /tmp/shu_zc5_smoke_build.log 2>/dev/null || true
  exit 1
fi

if [ -x "$SMOKE_OUT" ]; then
  RC=0
  "$SMOKE_OUT" >/dev/null 2>&1 || RC=$?
  if [ "$RC" -ne 0 ]; then
    echo "zc5 FAIL: splice_smoke expected exit 0, got $RC" >&2
    exit 1
  fi
  echo "zc5: splice_smoke exit=0 OK"
else
  echo "zc5: splice_smoke compile OK, run SKIP (no native exe)"
fi

# Linux：16MiB bench + strace splice（复用 sendfile sink）
if [ "$(uname -s)" != "Linux" ] || ! zc5_native_exe "$RUN_SHU"; then
  echo "zc5: bench/strace SKIP (Linux + native shu required)"
  echo "zc5 gate OK"
  exit 0
fi

BENCH_MB="${SHU_IO_BENCH_MB:-16}"
BENCH_FILE="tests/bench/.io_mmap_bench_tmp"
if [ ! -f "$BENCH_FILE" ]; then
  dd if=/dev/zero of="$BENCH_FILE" bs=1M count="$BENCH_MB" status=none 2>/dev/null || \
    dd if=/dev/zero of="$BENCH_FILE" bs=1048576 count="$BENCH_MB" 2>/dev/null
fi

SINK_BIN="/tmp/shu_zc5_splice_sink"
SINK_PORT=38460
cc -O2 tests/bench/zero_copy_sendfile_sink.c -o "$SINK_BIN" 2>/dev/null || {
  echo "zc5: bench SKIP (compile sink failed)"
  echo "zc5 gate OK"
  exit 0
}

"$SINK_BIN" "$SINK_PORT" >/dev/null 2>&1 &
SINK_PID=$!
sleep 0.3

if ! SHU="$RUN_SHU" "$RUN_SHU" -L . "$BENCH_SRC" -o "$BENCH_OUT" 2>/tmp/shu_zc5_bench_build.log; then
  kill "$SINK_PID" 2>/dev/null || true
  wait "$SINK_PID" 2>/dev/null || true
  echo "zc5 FAIL: compile $BENCH_SRC" >&2
  exit 1
fi

if [ ! -x "$BENCH_OUT" ]; then
  kill "$SINK_PID" 2>/dev/null || true
  wait "$SINK_PID" 2>/dev/null || true
  echo "zc5: bench compile OK, run SKIP"
  echo "zc5 gate OK"
  exit 0
fi

BENCH_BYTES=$((BENCH_MB * 1048576))
EXPECT_RC=$((BENCH_BYTES & 255))
RC=0
"$BENCH_OUT" "$SINK_PORT" >/dev/null 2>&1 || RC=$?
kill "$SINK_PID" 2>/dev/null || true
wait "$SINK_PID" 2>/dev/null || true

if [ "$RC" != "$EXPECT_RC" ]; then
  echo "zc5 FAIL: zero_copy_splice expected exit $EXPECT_RC, got $RC" >&2
  exit 1
fi
echo "zc5: zero_copy_splice 16MiB exit=$RC OK"

# strace 实锤 splice：GHA 原生 Linux 须绿；Docker Desktop ptrace 常失效（仅见 +++ exited +++）。
zc5_strace_captures_syscalls() {
  local probe_out rc=1
  command -v strace >/dev/null 2>&1 || return 1
  probe_out="$(mktemp /tmp/shu_zc5_strace_probe.XXXXXX)"
  strace -o "$probe_out" /bin/ls / >/dev/null 2>&1 || true
  if grep -qE '^openat\(' "$probe_out" 2>/dev/null; then
    rc=0
  fi
  rm -f "$probe_out"
  return "$rc"
}

if command -v strace >/dev/null 2>&1; then
  if ! zc5_strace_captures_syscalls; then
    if [ "${SHU_ZC5_REQUIRE_STRACE:-0}" = "1" ]; then
      echo "zc5 FAIL: strace probe failed (SHU_ZC5_REQUIRE_STRACE=1; need native Linux ptrace)" >&2
      exit 1
    fi
    echo "zc5: strace splice SKIP (strace cannot capture syscalls on this runner; e.g. Mac Docker Desktop ptrace)"
  else
    "$SINK_BIN" "$SINK_PORT" >/dev/null 2>&1 &
    SINK_PID=$!
    sleep 0.3
    strace_out="$(mktemp /tmp/shu_zc5_strace.XXXXXX)"
    RC=0
    strace -e trace=splice,read,write -o "$strace_out" "$BENCH_OUT" "$SINK_PORT" >/dev/null 2>&1 || RC=$?
    kill "$SINK_PID" 2>/dev/null || true
    wait "$SINK_PID" 2>/dev/null || true
    if [ "$RC" = "$EXPECT_RC" ]; then
      if grep -q 'splice(' "$strace_out" 2>/dev/null; then
        echo "zc5: strace splice syscall OK"
        perf_sb_count_from_strace_log "$strace_out"
        sb_total=$(perf_sb_io_total "$perf_sb_read" "$perf_sb_write" "$perf_sb_readv" \
          "$perf_sb_writev" "$perf_sb_splice" "$perf_sb_sendfile")
        sb_ok=$(perf_sb_within_caps zero_copy_splice "$perf_sb_read" "$perf_sb_write" \
          "$perf_sb_readv" "$perf_sb_writev" "$perf_sb_splice" "$perf_sb_sendfile")
        perf_sb_report_emit zero_copy_splice "$perf_sb_read" "$perf_sb_write" "$perf_sb_readv" \
          "$perf_sb_writev" "$perf_sb_splice" "$perf_sb_sendfile" "$sb_total" \
          "zero_copy_readwrite" "-" "$sb_ok"
      else
        echo "zc5 FAIL: strace missing splice()" >&2
        rm -f "$strace_out"
        exit 1
      fi
    fi
    rm -f "$strace_out"
  fi
fi

echo "zc5 gate OK"
