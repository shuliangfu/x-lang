#!/usr/bin/env bash
# Cap tip leftover: true-cold wipe rebuilds runtime_test_fn_invoke.o from cold
# seed only — 9.1 removed cold public wrappers, so test.o UNDEFs
# test_call_i32_void_c. Rebuild thin.x + FROM_X rest. Prefer asm; no FORCE_CC
# / new host-cc .c. PLATFORM: MACOS|DARWIN Cap tip.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/.."

out=runtime_test_fn_invoke.o
x_src=src/asm/runtime_test_fn_invoke.x
seed=seeds/runtime_test_fn_invoke.from_x.c
need_rebuild=0
if [ ! -s "$out" ]; then
  need_rebuild=1
elif ! nm -gU "$out" 2>/dev/null | grep -q 'T _test_call_i32_void_c$'; then
  need_rebuild=1
fi
if [ "$need_rebuild" = "0" ]; then
  echo "cap_tip_ensure_stdtest: $out already has public test_call_i32_void_c" >&2
  exit 0
fi

[ -f "$x_src" ] || { echo "cap_tip_ensure_stdtest: missing $x_src" >&2; exit 1; }
[ -f "$seed" ] || { echo "cap_tip_ensure_stdtest: missing $seed" >&2; exit 1; }

_xl=""
if [ -x ./xlang.product_legacy_bak ]; then
  _xl=./xlang.product_legacy_bak
elif [ -n "${XLANG:-}" ] && [ -x "${XLANG}" ]; then
  _xl="$XLANG"
elif [ -x ./xlang ]; then
  _xl=./xlang
fi
[ -n "$_xl" ] || { echo "cap_tip_ensure_stdtest: no XLANG for thin tip-compile" >&2; exit 1; }

thin_o="$(mktemp "${TMPDIR:-/tmp}/cap_tip_stdtest_thin.XXXXXX.o")"
rest_o="$(mktemp "${TMPDIR:-/tmp}/cap_tip_stdtest_rest.XXXXXX.o")"
cleanup() { rm -f "$thin_o" "$rest_o"; }
trap cleanup EXIT

if ! XLANG_PREFER_ASM_O=1 "$_xl" -backend asm -c "$x_src" -o "$thin_o" 2>/dev/null \
  || ! nm -gU "$thin_o" 2>/dev/null | grep -q 'T _test_call_i32_void_c$'; then
  echo "cap_tip_ensure_stdtest: thin tip-compile failed ($_xl)" >&2
  exit 1
fi

# shellcheck disable=SC2086
if ! cc -c -I. -Iinclude -Isrc -Isrc/asm -DXLANG_RUNTIME_TEST_FN_INVOKE_FROM_X \
     -o "$rest_o" "$seed" 2>/dev/null \
  || ! nm -gU "$rest_o" 2>/dev/null | grep -q 'T _test_call_i32_void_impl_c$'; then
  echo "cap_tip_ensure_stdtest: rest FROM_X compile failed" >&2
  exit 1
fi

if ! ld -r -o "$out" "$thin_o" "$rest_o" 2>/dev/null; then
  echo "cap_tip_ensure_stdtest: ld -r merge failed" >&2
  exit 1
fi
nm -gU "$out" 2>/dev/null | grep -q 'T _test_call_i32_void_c$' \
  && nm -gU "$out" 2>/dev/null | grep -q 'T _test_call_i32_void_impl_c$' \
  || { echo "cap_tip_ensure_stdtest: merged $out missing public/impl" >&2; exit 1; }
echo "cap_tip_ensure_stdtest: OK thin+rest $out" >&2
