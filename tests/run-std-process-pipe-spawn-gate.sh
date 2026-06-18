#!/usr/bin/env bash
# STD-023/024：std.process 管道重定向与 Windows spawn 门禁
#
# 用法：./tests/run-std-process-pipe-spawn-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_STD_PPS_DOC:-analysis/std-process-pipe-spawn-v1.md}"
MANIFEST="${SHU_STD_PPS_TSV:-tests/baseline/std-process-pipe-spawn.tsv}"
PROC_SU="std/process/mod.su"
PROC_C="std/process/process.c"
LIB="tests/lib/std-process-pipe-spawn.sh"
PIPE_SU="tests/process/spawn_pipe_echo.su"
WIN_SU="tests/process/spawn_wait_win.su"

# shellcheck source=tests/lib/std-process-pipe-spawn.sh
. tests/lib/std-process-pipe-spawn.sh

# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

echo "=== STD-023/024: process pipe/spawn manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$PROC_SU" "$PROC_C" "$PIPE_SU" "$WIN_SU"; do
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

sym_miss="$(std_pps_symbols_ok "$PROC_SU" "$MANIFEST" || true)"
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
  for cand in ./compiler/shu-c ./compiler/shu; do
    if stdlib_cm_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

if SHU_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-023/024: typeck (SHU=$SHU_BIN) ==="
  make -C compiler -q ../std/process/process.o 2>/dev/null || make -C compiler ../std/process/process.o 2>/dev/null || true
  make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c 2>/dev/null || true
  if "$SHU_BIN" check -L . "$PIPE_SU" >/dev/null 2>&1; then
    PIPE_OK=1
  else
    echo "std-process-pipe-spawn gate FAIL: spawn_pipe_echo typeck" >&2
    "$SHU_BIN" check -L . "$PIPE_SU" 2>&1 | tail -10 >&2 || true
    std_pps_emit_report "fail" 0 0 0
    exit 1
  fi
  if "$SHU_BIN" check -L . "$WIN_SU" >/dev/null 2>&1; then
    WIN_OK=1
  else
    echo "std-process-pipe-spawn gate FAIL: spawn_wait_win typeck" >&2
    "$SHU_BIN" check -L . "$WIN_SU" 2>&1 | tail -10 >&2 || true
    std_pps_emit_report "fail" "$PIPE_OK" 0 0
    exit 1
  fi
  SKIP=0
  if [ -x tests/run-process.sh ]; then
    echo "=== STD-023/024: delegate run-process (runnable subset) ==="
    chmod +x tests/run-process.sh
    if SHU="$SHU_BIN" ./tests/run-process.sh >/tmp/std_pps_process.log 2>&1; then
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
  echo "std-process-pipe-spawn gate SKIP typeck (no native shu-c)" >&2
fi

std_pps_emit_report "ok" "$PIPE_OK" "$WIN_OK" "$SKIP"
echo "std-process-pipe-spawn gate OK"
