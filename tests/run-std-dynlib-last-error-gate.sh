#!/usr/bin/env bash
# STD-096：std.dynlib last_error 文本诊断门禁
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

MOD_SU="std/dynlib/mod.su"
DYNLIB_C="std/dynlib/dynlib.c"
MANIFEST="tests/baseline/std-dynlib-last-error.tsv"
SMOKE_SU="tests/dynlib/last_error.su"
SMOKE_C="tests/dynlib/last_error_smoke.c"
PREFIX="shu: [SHU_STD096_DYNLIB_ERR]"

stdlib_cm_native_shu() {
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

echo "=== STD-096: dynlib last_error manifest ==="
for f in "$MOD_SU" "$DYNLIB_C" "$MANIFEST" "$SMOKE_SU" "$SMOKE_C"; do
  if [ ! -f "$f" ]; then
    echo "dynlib-last-error gate FAIL: missing $f" >&2
    exit 1
  fi
done
if ! grep -qE "function last_error\\(" "$MOD_SU" 2>/dev/null; then
  echo "dynlib-last-error gate FAIL: missing api last_error" >&2
  exit 1
fi
if ! grep -qF "dynlib_last_error_copy_c" "$DYNLIB_C" 2>/dev/null; then
  echo "dynlib-last-error gate FAIL: missing C copy symbol" >&2
  exit 1
fi
echo "dynlib-last-error manifest OK"

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/dynlib/dynlib.o

C_OK=0
echo "=== STD-096: C smoke ==="
c_exe="/tmp/shu_std096_dynlib_err_$$"
if cc -Wall -Wextra -o "$c_exe" "$SMOKE_C" std/dynlib/dynlib.o 2>/dev/null; then
  set +e
  "$c_exe" >/dev/null 2>&1
  c_ec=$?
  set -e
  rm -f "$c_exe"
  if [ "$c_ec" -ne 0 ]; then
    echo "dynlib-last-error gate FAIL: C smoke exit=$c_ec" >&2
    exit 1
  fi
  C_OK=1
else
  echo "dynlib-last-error gate FAIL: compile $SMOKE_C" >&2
  exit 1
fi

SU_OK=0
SKIP=0
SHU_BIN=""
if SHU_BIN="$(stdlib_cm_native_shu ./compiler/shu-c && echo ./compiler/shu-c || true)"; then
  :
elif SHU_BIN="$(stdlib_cm_native_shu ./compiler/shu && echo ./compiler/shu || true)"; then
  :
fi
if [ -n "$SHU_BIN" ]; then
  echo "=== STD-096: .su typeck (SHU=$SHU_BIN) ==="
  if ! "$SHU_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "dynlib-last-error gate FAIL: typeck $SMOKE_SU" >&2
    "$SHU_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    exit 1
  fi
  SU_OK=1
else
  echo "dynlib-last-error gate SKIP .su (no native shu)" >&2
  SKIP=1
fi

echo "${PREFIX} status=ok c=${C_OK} su=${SU_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "std-dynlib-last-error gate OK"
