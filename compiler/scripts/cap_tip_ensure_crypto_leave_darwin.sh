#!/usr/bin/env bash
# Cap tip leftover: true-cold wipe rebuilds runtime_ed25519_ref10_glue.o via
# cold seed only — 9.1 removed cold public wrappers, so crypto.o UNDEFs
# ed25519_ref10_{create_keypair,sign,verify}. Rebuild thin.x + FROM_X rest.
# Prefer asm; no FORCE_CC / new host-cc .c. PLATFORM: MACOS|DARWIN Cap tip.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/.."

out=runtime_ed25519_ref10_glue.o
x_src=src/asm/runtime_ed25519_ref10_glue.x
seed=seeds/runtime_ed25519_ref10_glue.from_x.c
need_rebuild=0
if [ ! -s "$out" ]; then
  need_rebuild=1
elif ! nm -gU "$out" 2>/dev/null | grep -q 'T _ed25519_ref10_create_keypair$'; then
  need_rebuild=1
elif ! nm -gU "$out" 2>/dev/null | grep -q 'T _ed25519_ref10_sign$'; then
  need_rebuild=1
elif ! nm -gU "$out" 2>/dev/null | grep -q 'T _ed25519_ref10_verify$'; then
  need_rebuild=1
fi
if [ "$need_rebuild" = "0" ]; then
  echo "cap_tip_ensure_crypto: $out already has public ref10 wrappers" >&2
  exit 0
fi

[ -f "$x_src" ] || { echo "cap_tip_ensure_crypto: missing $x_src" >&2; exit 1; }
[ -f "$seed" ] || { echo "cap_tip_ensure_crypto: missing $seed" >&2; exit 1; }

_xl=""
if [ -x ./xlang.product_legacy_bak ]; then
  _xl=./xlang.product_legacy_bak
elif [ -n "${XLANG:-}" ] && [ -x "${XLANG}" ]; then
  _xl="$XLANG"
elif [ -x ./xlang ]; then
  _xl=./xlang
fi
[ -n "$_xl" ] || { echo "cap_tip_ensure_crypto: no XLANG for thin tip-compile" >&2; exit 1; }

thin_o="$(mktemp "${TMPDIR:-/tmp}/cap_tip_ed25519_thin.XXXXXX.o")"
rest_o="$(mktemp "${TMPDIR:-/tmp}/cap_tip_ed25519_rest.XXXXXX.o")"
cleanup() { rm -f "$thin_o" "$rest_o"; }
trap cleanup EXIT

if ! XLANG_PREFER_ASM_O=1 "$_xl" -backend asm -c "$x_src" -o "$thin_o" 2>/dev/null \
  || ! nm -gU "$thin_o" 2>/dev/null | grep -q 'T _ed25519_ref10_create_keypair$'; then
  echo "cap_tip_ensure_crypto: thin tip-compile failed ($_xl)" >&2
  exit 1
fi

# shellcheck disable=SC2086
if ! cc -c -I. -Iinclude -Isrc -Isrc/asm -DXLANG_RUNTIME_ED25519_REF10_GLUE_FROM_X \
     -o "$rest_o" "$seed" 2>/dev/null \
  || ! nm -gU "$rest_o" 2>/dev/null | grep -q 'T _ed25519_ref10_create_keypair_impl_c$'; then
  echo "cap_tip_ensure_crypto: rest FROM_X compile failed" >&2
  exit 1
fi

if ! ld -r -o "$out" "$thin_o" "$rest_o" 2>/dev/null; then
  echo "cap_tip_ensure_crypto: ld -r merge failed" >&2
  exit 1
fi
nm -gU "$out" 2>/dev/null | grep -q 'T _ed25519_ref10_create_keypair$' \
  && nm -gU "$out" 2>/dev/null | grep -q 'T _ed25519_ref10_sign$' \
  && nm -gU "$out" 2>/dev/null | grep -q 'T _ed25519_ref10_verify$' \
  || { echo "cap_tip_ensure_crypto: merged $out missing public wrappers" >&2; exit 1; }
echo "cap_tip_ensure_crypto: OK thin+rest $out" >&2
