#!/usr/bin/env bash
# Cap tip leftover: true-cold wipe rebuilds runtime_backtrace_platform.o from
# cold seed only — 9.1 removed cold public wrappers, so backtrace.o UNDEFs
# backtrace_symbolicate_c (and peers). Rebuild thin.x + FROM_X rest. Prefer
# asm; no FORCE_CC / new host-cc .c. PLATFORM: MACOS|DARWIN Cap tip.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/.."

out=runtime_backtrace_platform.o
x_src=src/asm/runtime_backtrace_platform.x
seed=seeds/runtime_backtrace_platform.from_x.c
need_rebuild=0
if [ ! -s "$out" ]; then
  need_rebuild=1
elif ! nm -gU "$out" 2>/dev/null | grep -q 'T _backtrace_symbolicate_c$'; then
  need_rebuild=1
elif ! nm -gU "$out" 2>/dev/null | grep -q 'T _backtrace_capture_c$'; then
  need_rebuild=1
fi
if [ "$need_rebuild" = "0" ]; then
  echo "cap_tip_ensure_backtrace: $out already has public backtrace_*_c wrappers" >&2
  exit 0
fi

[ -f "$x_src" ] || { echo "cap_tip_ensure_backtrace: missing $x_src" >&2; exit 1; }
[ -f "$seed" ] || { echo "cap_tip_ensure_backtrace: missing $seed" >&2; exit 1; }

_xl=""
if [ -x ./xlang.product_legacy_bak ]; then
  _xl=./xlang.product_legacy_bak
elif [ -n "${XLANG:-}" ] && [ -x "${XLANG}" ]; then
  _xl="$XLANG"
elif [ -x ./xlang ]; then
  _xl=./xlang
fi
[ -n "$_xl" ] || { echo "cap_tip_ensure_backtrace: no XLANG for thin tip-compile" >&2; exit 1; }

thin_o="$(mktemp "${TMPDIR:-/tmp}/cap_tip_bt_thin.XXXXXX.o")"
rest_o="$(mktemp "${TMPDIR:-/tmp}/cap_tip_bt_rest.XXXXXX.o")"
cleanup() { rm -f "$thin_o" "$rest_o"; }
trap cleanup EXIT

if ! XLANG_PREFER_ASM_O=1 "$_xl" -backend asm -c "$x_src" -o "$thin_o" 2>/dev/null \
  || ! nm -gU "$thin_o" 2>/dev/null | grep -q 'T _backtrace_symbolicate_c$'; then
  echo "cap_tip_ensure_backtrace: thin tip-compile failed ($_xl)" >&2
  exit 1
fi

# shellcheck disable=SC2086
if ! cc -c -I. -Iinclude -Isrc -Isrc/asm -DXLANG_RUNTIME_BACKTRACE_PLATFORM_FROM_X \
     -o "$rest_o" "$seed" 2>/dev/null \
  || ! nm -gU "$rest_o" 2>/dev/null | grep -q 'T _backtrace_symbolicate_impl$'; then
  echo "cap_tip_ensure_backtrace: rest FROM_X compile failed" >&2
  exit 1
fi

if ! ld -r -o "$out" "$thin_o" "$rest_o" 2>/dev/null; then
  echo "cap_tip_ensure_backtrace: ld -r merge failed" >&2
  exit 1
fi
nm -gU "$out" 2>/dev/null | grep -q 'T _backtrace_symbolicate_c$' \
  && nm -gU "$out" 2>/dev/null | grep -q 'T _backtrace_capture_c$' \
  && nm -gU "$out" 2>/dev/null | grep -q 'T _backtrace_symbolicate_impl$' \
  || { echo "cap_tip_ensure_backtrace: merged $out missing public/impl" >&2; exit 1; }
echo "cap_tip_ensure_backtrace: OK thin+rest $out" >&2
