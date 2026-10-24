#!/usr/bin/env bash
# Cap tip leftover: true-cold wipe rebuilds runtime_dynlib_os.o from cold seed
# only — 9.1 removed cold public wrappers, so dynlib.o UNDEFs
# dynlib_os_{copy_last_error,open,sym,win_path_smoke}_c. Prefer
# darwin_text.x + darwin.x (pure-asm); fallback thin.x + FROM_X rest.
# No FORCE_CC / new host-cc .c. PLATFORM: SHARED — nm _?; cold-seed fallback for Linux tip-cold.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/.."

out=runtime_dynlib_os.o
x_thin=src/asm/runtime_dynlib_os.x
x_darwin=src/asm/runtime_dynlib_os_darwin.x
x_text=src/asm/runtime_dynlib_os_darwin_text.x
seed=seeds/runtime_dynlib_os.from_x.c
need_rebuild=0
if [ ! -s "$out" ]; then
  need_rebuild=1
else
  for s in dynlib_os_copy_last_error_c dynlib_os_open_c dynlib_os_sym_c dynlib_os_win_path_smoke_c; do
    if ! nm -gU "$out" 2>/dev/null | grep -qE "T _?${s}\$"; then
      need_rebuild=1
      break
    fi
  done
fi
if [ "$need_rebuild" = "0" ]; then
  echo "cap_tip_ensure_dynlib: $out already has public dynlib_os_*_c wrappers" >&2
  exit 0
fi

[ -f "$x_darwin" ] || { echo "cap_tip_ensure_dynlib: missing $x_darwin" >&2; exit 1; }
[ -f "$x_text" ] || { echo "cap_tip_ensure_dynlib: missing $x_text" >&2; exit 1; }

_xl=""
if [ -x ./xlang.product_legacy_bak ]; then
  _xl=./xlang.product_legacy_bak
elif [ -n "${XLANG:-}" ] && [ -x "${XLANG}" ]; then
  _xl="$XLANG"
elif [ -x ./xlang ]; then
  _xl=./xlang
fi
[ -n "$_xl" ] || { echo "cap_tip_ensure_dynlib: no XLANG for tip-compile" >&2; exit 1; }

text_o="$(mktemp "${TMPDIR:-/tmp}/cap_tip_dynlib_text.XXXXXX.o")"
darwin_o="$(mktemp "${TMPDIR:-/tmp}/cap_tip_dynlib_darwin.XXXXXX.o")"
thin_o="$(mktemp "${TMPDIR:-/tmp}/cap_tip_dynlib_thin.XXXXXX.o")"
rest_o="$(mktemp "${TMPDIR:-/tmp}/cap_tip_dynlib_rest.XXXXXX.o")"
cleanup() { rm -f "$text_o" "$darwin_o" "$thin_o" "$rest_o"; }
trap cleanup EXIT

merged=0
if XLANG_PREFER_ASM_O=1 "$_xl" -backend asm -c "$x_text" -o "$text_o" 2>/dev/null \
  && XLANG_PREFER_ASM_O=1 "$_xl" -backend asm -c "$x_darwin" -o "$darwin_o" 2>/dev/null \
  && [ -s "$text_o" ] && [ -s "$darwin_o" ] \
  && ld -r -o "$out" "$text_o" "$darwin_o" 2>/dev/null; then
  merged=1
  echo "cap_tip_ensure_dynlib: OK darwin_text+darwin $out" >&2
elif [ -f "$x_thin" ] && [ -f "$seed" ] \
  && XLANG_PREFER_ASM_O=1 "$_xl" -backend asm -c "$x_thin" -o "$thin_o" 2>/dev/null \
  && nm -gU "$thin_o" 2>/dev/null | grep -qE 'T _?dynlib_os_open_c$' \
  && cc -c -I. -Iinclude -Isrc -Isrc/asm -DXLANG_RUNTIME_DYNLIB_OS_FROM_X \
       -o "$rest_o" "$seed" 2>/dev/null \
  && [ -s "$rest_o" ] \
  && ld -r -o "$out" "$thin_o" "$rest_o" 2>/dev/null; then
  merged=1
  echo "cap_tip_ensure_dynlib: OK thin+FROM_X rest $out" >&2
fi
if [ "$merged" != "1" ] && [ -f "$seed" ]; then
  # Linux tip-cold: Darwin .x path often misses; cold seed restores public *_c (记253).
  if cc -c -I. -Iinclude -Isrc -Isrc/asm -o "$rest_o" "$seed" 2>/dev/null     && cp -f "$rest_o" "$out"; then
    merged=1
    echo "cap_tip_ensure_dynlib: OK cold-seed $out" >&2
  fi
fi
[ "$merged" = "1" ] || { echo "cap_tip_ensure_dynlib: merge failed" >&2; exit 1; }

for s in dynlib_os_copy_last_error_c dynlib_os_open_c dynlib_os_sym_c dynlib_os_win_path_smoke_c; do
  nm -gU "$out" 2>/dev/null | grep -qE "T _?${s}\$" \
    || { echo "cap_tip_ensure_dynlib: merged $out missing $s" >&2; exit 1; }
done
