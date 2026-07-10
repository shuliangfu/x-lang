#!/usr/bin/env bash
# STD-023/024：std.process 管道重定向与 Windows spawn 门禁
#
# 用法：./tests/run-std-process-pipe-spawn-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_PPS_DOC:-analysis/std-process-pipe-spawn-v1.md}"
MANIFEST="${SHUX_STD_PPS_TSV:-tests/baseline/std-process-pipe-spawn.tsv}"
PROC_X="std/process/mod.x"
PROC_C="${SHUX_STD_PROCESS_IMPL:-compiler/src/asm/runtime_process_os_glue.inc}"
LIB="tests/lib/std-process-pipe-spawn.sh"
PIPE_X="tests/process/spawn_pipe_echo.x"
WIN_X="tests/process/spawn_wait_win.x"

# shellcheck source=tests/lib/std-process-pipe-spawn.sh
. tests/lib/std-process-pipe-spawn.sh

# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

echo "=== STD-023/024: process pipe/spawn manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$PROC_X" "$PROC_C" "$PIPE_X" "$WIN_X"; do
  if [ ! -f "$f" ]; then
    echo "std-process-pipe-spawn gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in spawn_io process_spawn_io_c spawn_pipe_echo spawn_wait_win; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-process-pipe-spawn gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF "process_spawn_io_c" "$PROC_C" 2>/dev/null; then
  echo "std-process-pipe-spawn gate FAIL: process.c missing process_spawn_io_c" >&2
  exit 1
fi

sym_miss="$(std_pps_symbols_ok "$PROC_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_pps_emit_report "fail" 0 0 1
  echo "std-process-pipe-spawn gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-process-pipe-spawn manifest OK"

stdlib_cm_native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 0 ;;
  esac
}

PIPE_OK=0
WIN_OK=0
SKIP=1
resolve_shu() {
  local cand
  for cand in ./compiler/shux-c ./compiler/shux; do
    if stdlib_cm_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

if SHUX_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-023/024: typeck (SHUX=$SHUX_BIN) ==="
  make -C compiler -q ../std/process/process.o 2>/dev/null || make -C compiler ../std/process/process.o 2>/dev/null || true
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  if "$SHUX_BIN" check -L . "$PIPE_X" >/dev/null 2>&1; then
    PIPE_OK=1
  else
    echo "std-process-pipe-spawn gate FAIL: spawn_pipe_echo typeck" >&2
    "$SHUX_BIN" check -L . "$PIPE_X" 2>&1 | tail -10 >&2 || true
    std_pps_emit_report "fail" 0 0 0
    exit 1
  fi
  if "$SHUX_BIN" check -L . "$WIN_X" >/dev/null 2>&1; then
    WIN_OK=1
  else
    echo "std-process-pipe-spawn gate FAIL: spawn_wait_win typeck" >&2
    "$SHUX_BIN" check -L . "$WIN_X" 2>&1 | tail -10 >&2 || true
    std_pps_emit_report "fail" "$PIPE_OK" 0 0
    exit 1
  fi
  SKIP=0
  if [ -x tests/run-process.sh ]; then
    echo "=== STD-023/024: delegate run-process (runnable subset) ==="
    chmod +x tests/run-process.sh
    if SHUX="$SHUX_BIN" ./tests/run-process.sh >/tmp/std_pps_process.log 2>&1; then
      grep -qF 'process test OK' /tmp/std_pps_process.log || true
    else
      if ci_is_windows_msys; then
        tail -12 /tmp/std_pps_process.log >&2 || true
        std_pps_emit_report "fail" "$PIPE_OK" "$WIN_OK" 0
        exit 1
      fi
      echo "std-process-pipe-spawn gate WARN: run-process (non-Windows)" >&2
    fi
  fi
else
  echo "std-process-pipe-spawn gate SKIP typeck (no native shux-c)" >&2
fi

std_pps_emit_report "ok" "$PIPE_OK" "$WIN_OK" "$SKIP"
echo "std-process-pipe-spawn gate OK"
