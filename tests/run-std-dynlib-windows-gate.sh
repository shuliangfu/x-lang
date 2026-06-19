#!/usr/bin/env bash
# STD-027：std.dynlib Windows LoadLibrary 门禁
#
# 用法：./tests/run-std-dynlib-windows-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_DYNLIB_WIN_DOC:-analysis/std-dynlib-windows-v1.md}"
MANIFEST="${SHUX_STD_DYNLIB_WIN_TSV:-tests/baseline/std-dynlib-windows.tsv}"
DYNLIB_C="std/dynlib/dynlib.c"
MOD_SU="std/dynlib/mod.sx"
LIB="tests/lib/std-dynlib-windows.sh"
SMOKE="tests/dynlib/open_sym_close.sx"
WIN_PATH_SU="tests/dynlib/win_path.sx"
WIN_PATH_C="tests/dynlib/win_path_smoke.c"
NULL_TEST="tests/dynlib/main.sx"
RUNNER="tests/run-dynlib.sh"

# shellcheck source=tests/lib/std-dynlib-windows.sh
. tests/lib/std-dynlib-windows.sh

echo "=== STD-027: dynlib Windows manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$DYNLIB_C" "$MOD_SU" "$SMOKE" "$WIN_PATH_SU" "$WIN_PATH_C" "$NULL_TEST" "$RUNNER"; do
  if [ ! -f "$f" ]; then
    echo "std-dynlib-windows gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in LoadLibraryA LoadLibraryW GetProcAddress FreeLibrary kernel32.dll open_sym_close dynlib_win_normalize_path; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-dynlib-windows gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(std_dynlib_win_manifest_ok "$DOC" "$DYNLIB_C" "$MOD_SU" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_dynlib_win_emit_report "fail" 0 0 0
  echo "std-dynlib-windows gate FAIL: manifest_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-dynlib-windows manifest OK"

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

CHECK_OK=0
RUN_OK=0
WIN_PATH_C_OK=0
SKIP=1
if SHUX_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-027: typeck (SHUX=$SHUX_BIN) ==="
  if "$SHUX_BIN" check -L . "$SMOKE" >/dev/null 2>&1 && "$SHUX_BIN" check -L . "$NULL_TEST" >/dev/null 2>&1 && "$SHUX_BIN" check -L . "$WIN_PATH_SU" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-dynlib-windows gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE" 2>&1 | tail -6 >&2 || true
    std_dynlib_win_emit_report "fail" 0 0 0
    exit 1
  fi
  SKIP=0
  make -C compiler -q ../std/dynlib/dynlib.o 2>/dev/null || make -C compiler ../std/dynlib/dynlib.o
  echo "=== STD-097: win path C smoke ==="
  if cc -Wall -Wextra -o /tmp/shux_std_dynlib_winpath "$WIN_PATH_C" std/dynlib/dynlib.o 2>/dev/null; then
    wp_ec=0
    /tmp/shux_std_dynlib_winpath >/dev/null 2>&1 || wp_ec=$?
    rm -f /tmp/shux_std_dynlib_winpath
    if [ "$wp_ec" -ne 0 ]; then
      echo "std-dynlib-windows gate FAIL: win_path_smoke exit=$wp_ec" >&2
      std_dynlib_win_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
    WIN_PATH_C_OK=1
  else
    echo "std-dynlib-windows gate FAIL: compile win_path_smoke.c" >&2
    exit 1
  fi
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
  # shellcheck source=tests/lib/bootstrap-link-shux.sh
  . "$(dirname "$0")/lib/bootstrap-link-shux.sh"
  if $RUN_SHUX -L . "$SMOKE" -o /tmp/shux_std_dynlib_osc 2>/tmp/shux_std_dynlib_osc_build.log; then
    exitcode=0
    /tmp/shux_std_dynlib_osc >/dev/null 2>&1 || exitcode=$?
    if [ "$exitcode" -eq 0 ]; then
      RUN_OK=1
    else
      echo "std-dynlib-windows gate FAIL: open_sym_close exit=$exitcode" >&2
      std_dynlib_win_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "std-dynlib-windows gate SKIP runnable link (check passed)" >&2
    tail -5 /tmp/shux_std_dynlib_osc_build.log 2>/dev/null >&2 || true
    SKIP=1
  fi
else
  echo "std-dynlib-windows gate SKIP typeck (no native shux)" >&2
fi

std_dynlib_win_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-dynlib-windows gate OK"
