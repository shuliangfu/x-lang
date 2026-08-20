#!/usr/bin/env bash
# Stage 4 Hello World: compile examples/hello.x and require stdout "Hello World".
# Product path: pure-asm `$XLANG -o` (default; no silent host-cc).
# Host-cc `-backend c` only when XLANG_ALLOW_HOST_CC=1 or XLANG_FORCE_LINK_BACKEND=c
# (matches void-main / option / defer-gate). PLATFORM: SHARED pure-asm product gate.
# run-all USE_C path may still bind xlang-c when RUN_ALL_USE_C=1.

set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
XLANG=${XLANG:-./compiler/xlang}

# Probe whether the binary accepts -x (pipeline); pure C frontend xlang-c rejects it.
xlang_cli_supports_x() {
  local o
  o=$("$1" -x 2>&1) || true
  case "$o" in
    *"unknown option"*) return 1 ;;
    *) return 0 ;;
  esac
}

# Unique outs so parallel JOBS>1 cannot clobber /tmp/xlang_hello.
HELLO_OUT="${TMPDIR:-/tmp}/xlang_hello.$$"
HELLO_BUILD_LOG="${TMPDIR:-/tmp}/xlang_hello_build.$$.log"
trap 'rm -f "$HELLO_OUT" "$HELLO_BUILD_LOG"' EXIT

HELLO_COMPILE_XLANG="$XLANG"
HELLO_BACKEND=""
# Optional experimental host-cc only when explicitly allowed.
if [ -n "${XLANG_FORCE_LINK_BACKEND:-}" ]; then
  HELLO_BACKEND="-backend ${XLANG_FORCE_LINK_BACKEND}"
elif [ "${XLANG_ALLOW_HOST_CC:-}" = "1" ]; then
  HELLO_BACKEND="-backend c"
fi
# MSYS2: seed -o can hang; prefer xlang-c like bootstrap-link-xlang / run-async.
if [ -n "${MSYSTEM:-}" ] || case "$(uname -s 2>/dev/null)" in MINGW*|MSYS*) true ;; *) false ;; esac; then
  if [ -x ./compiler/xlang-c ]; then
    HELLO_COMPILE_XLANG=./compiler/xlang-c
    HELLO_BACKEND=""
  fi
elif [ -n "${XLANG_LINK_XLANG:-}" ] && [ -x "${XLANG_LINK_XLANG}" ]; then
  # Product cold chain: keep product xlang/xlang_asm (bstrict exports XLANG_LINK_XLANG).
  # Do NOT inject -backend c here — silent host-cc is banned (host-cc-requires-allow).
  case "$(basename "${XLANG:-}")" in
    xlang|xlang_asm|xlang_asm2|xlang_asm_stage1)
      HELLO_COMPILE_XLANG="$XLANG"
      # HELLO_BACKEND already set only for ALLOW / FORCE above.
      ;;
    *)
      HELLO_COMPILE_XLANG="${XLANG_LINK_XLANG}"
      ;;
  esac
fi
case "${XLANG##*/}" in
  xlang_stage1|xlang_stage2)
    _hello_xlang_dir=$(dirname "$XLANG")
    if [ -x "$_hello_xlang_dir/xlang-c" ]; then HELLO_COMPILE_XLANG="$_hello_xlang_dir/xlang-c"; fi
    ;;
esac
# Non-x86_64: prefer xlang-c for runnable host objs; do not force -backend c without ALLOW.
case "$(uname -m 2>/dev/null)" in
  x86_64|amd64) ;;
  *)
    if [ -x ./compiler/xlang-c ]; then
      HELLO_COMPILE_XLANG=./compiler/xlang-c
      HELLO_BACKEND=""
    fi
    ;;
esac
if [ -n "${RUN_ALL_USE_C:-}" ]; then
  # run-all C pipeline; skip make when parent already built (XLANG_SKIP_SUBSCRIPT_MAKE=1).
  if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
    xlang_compiler_make -q all 2>/dev/null || xlang_compiler_make all
  fi
  if [ -x ./compiler/xlang-c ]; then
    HELLO_COMPILE_XLANG=./compiler/xlang-c
    HELLO_BACKEND=""
  fi
  $HELLO_COMPILE_XLANG $HELLO_BACKEND examples/hello.x -o "$HELLO_OUT"
else
  if [[ "$HELLO_COMPILE_XLANG" == *xlang-c* ]] || ! xlang_cli_supports_x "$HELLO_COMPILE_XLANG"; then
    $HELLO_COMPILE_XLANG $HELLO_BACKEND -L . examples/hello.x -o "$HELLO_OUT"
  else
    # -o full driver path; drain non-TTY stdout (seed hang on Codespace gold L5).
    # pipefail so compile failure is not swallowed by tee|cat.
    set -o pipefail
    if ! $HELLO_COMPILE_XLANG $HELLO_BACKEND -L . examples/hello.x -o "$HELLO_OUT" 2>&1 | tee "$HELLO_BUILD_LOG" | cat >/dev/null; then
      echo "hello compile failed (see $HELLO_BUILD_LOG)" >&2
      exit 1
    fi
    set +o pipefail
  fi
fi
if [ ! -x "$HELLO_OUT" ]; then
  echo "hello compile failed (no executable $HELLO_OUT)" >&2
  exit 1
fi
set +e
out=$("$HELLO_OUT")
rc=$?
set -e
echo "$out" | grep -q "Hello World" || { echo "expected 'Hello World' in output, got: $out"; exit 1; }
# void main → process exit 0 (Zig-like; examples/hello.x contract)
if [ "$rc" -ne 0 ]; then
  echo "expected hello exit 0, got $rc" >&2
  exit 1
fi
echo "Hello World test OK"
