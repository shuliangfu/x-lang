#!/usr/bin/env bash
# STD-091：std.io ↔ std.context read_ctx/write_ctx 联动门禁
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

MOD_X="std/io/mod.x"
SMOKE="tests/io/context_read_write.x"
PREFIX="xlang: [XLANG_STD091_IO_CTX]"

stdlib_cm_native_xlang() {
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

echo "=== STD-091: io-context manifest ==="
for f in "$MOD_X" "$SMOKE"; do
  if [ ! -f "$f" ]; then
    echo "io-context gate FAIL: missing $f" >&2
    exit 1
  fi
done
for sym in timeout_from_ctx read_ctx write_ctx IO_CTX_MS_CANCELLED IO_CTX_MS_EXPIRED; do
  case "$sym" in
    IO_CTX_MS_*)
      if ! grep -qF "const ${sym}:" "$MOD_X" 2>/dev/null; then
        echo "io-context gate FAIL: missing const $sym" >&2
        exit 1
      fi
      ;;
    *)
      if ! grep -qE "function ${sym}\\(" "$MOD_X" 2>/dev/null; then
        echo "io-context gate FAIL: missing api $sym" >&2
        exit 1
      fi
      ;;
  esac
done
echo "io-context manifest OK"

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
# shellcheck source=lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh" 
ensure_std_c_o ../std/context/context.o
ensure_std_c_o ../std/time/time.o
ensure_std_c_o ../std/atomic/atomic.o
ensure_runtime_atomic_glue_o
ensure_runtime_time_os_o

XLANG_BIN=""
if XLANG_BIN="$(stdlib_cm_native_xlang ./compiler/xlang-c && echo ./compiler/xlang-c || true)"; then
  :
elif XLANG_BIN="$(stdlib_cm_native_xlang ./compiler/xlang && echo ./compiler/xlang || true)"; then
  :
fi

X_OK=0
SKIP=0
if [ -n "$XLANG_BIN" ]; then
  echo "=== STD-091: smoke (XLANG=$XLANG_BIN) ==="
  if ! "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    echo "io-context gate FAIL: typeck $SMOKE" >&2
    exit 1
  fi
  exe="/tmp/xlang_std091_io_ctx_$$"
  if ! "$XLANG_BIN" -L . "$SMOKE" -o "$exe" compiler/runtime_atomic_glue.o compiler/runtime_time_os.o >/dev/null 2>&1; then
    echo "io-context gate FAIL: compile $SMOKE" >&2
    exit 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "io-context gate FAIL: run exit=$ec" >&2
    exit 1
  fi
  X_OK=1
else
  echo "io-context gate SKIP .x (no native xlang)" >&2
  SKIP=1
fi

echo "${PREFIX} status=ok x=${X_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "std-io-context gate OK"
