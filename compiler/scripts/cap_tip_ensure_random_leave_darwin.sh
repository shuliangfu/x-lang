#!/usr/bin/env bash
# Cap tip leftover: true-cold wipe rebuilds runtime_random_fill.o from cold
# seed only — 9.1 removed cold public wrappers, so random.o UNDEFs
# random_fill_bytes_c (ld text often cites _std_random_fill_bytes in
# random.o). Darwin product body is thin runtime_random_fill.x (pure-asm;
# no host-cc seed). Prefer asm; no FORCE_CC / new host-cc .c.
# PLATFORM: SHARED — nm accepts optional Mach-O underscore (Linux ELF).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/.."

out=runtime_random_fill.o
x_src=src/asm/runtime_random_fill.x
seed=seeds/runtime_random_fill.from_x.c
need_rebuild=0
if [ ! -s "$out" ]; then
  need_rebuild=1
elif ! nm -gU "$out" 2>/dev/null | grep -qE 'T _?random_fill_bytes_c$'; then
  need_rebuild=1
fi
if [ "$need_rebuild" = "0" ]; then
  echo "cap_tip_ensure_random: $out already has public random_fill_bytes_c" >&2
  exit 0
fi

[ -f "$x_src" ] || { echo "cap_tip_ensure_random: missing $x_src" >&2; exit 1; }

_xl=""
if [ -x ./xlang.product_legacy_bak ]; then
  _xl=./xlang.product_legacy_bak
elif [ -n "${XLANG:-}" ] && [ -x "${XLANG}" ]; then
  _xl="$XLANG"
elif [ -x ./xlang ]; then
  _xl=./xlang
fi
[ -n "$_xl" ] || { echo "cap_tip_ensure_random: no XLANG for thin tip-compile" >&2; exit 1; }

thin_o="$(mktemp "${TMPDIR:-/tmp}/cap_tip_random_thin.XXXXXX.o")"
cleanup() { rm -f "$thin_o"; }
trap cleanup EXIT

if XLANG_PREFER_ASM_O=1 "$_xl" -backend asm -c "$x_src" -o "$thin_o" 2>/dev/null \
  && nm -gU "$thin_o" 2>/dev/null | grep -qE 'T _?random_fill_bytes_c$'; then
  cp -f "$thin_o" "$out"
  echo "cap_tip_ensure_random: OK thin $out" >&2
elif [ -f "$seed" ] && cc -c -I. -Iinclude -Isrc -Isrc/asm -o "$thin_o" "$seed" 2>/dev/null \
  && nm -gU "$thin_o" 2>/dev/null | grep -qE 'T _?random_fill_bytes_c$'; then
  cp -f "$thin_o" "$out"
  echo "cap_tip_ensure_random: OK cold-seed $out" >&2
else
  echo "cap_tip_ensure_random: thin tip-compile and cold-seed failed ($_xl)" >&2
  exit 1
fi
nm -gU "$out" 2>/dev/null | grep -qE 'T _?random_fill_bytes_c$' \
  || { echo "cap_tip_ensure_random: $out missing random_fill_bytes_c" >&2; exit 1; }
