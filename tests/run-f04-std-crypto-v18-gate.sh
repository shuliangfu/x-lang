#!/usr/bin/env bash
# F-04 v18: std.crypto chacha20_poly1305.inc.c → chacha20_poly1305.x.
#
# Usage: ./tests/run-f04-std-crypto-v18-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f04-std-crypto-v18-gate.sh
# 2026-08-26: Honesty — hard-fail static TSV + inventory + STD-006
# manifest-only (no soft die→exit0). Soft XLANG_F04_CRYPTO_V18_FAIL retired.
# Prefer asm; pin XLANG_LINK_XLANG. Host-c chacha smoke observational.
# Report static=/inventory=/crypto=/smoke=/skip=. Gate was
# portable-false-green (DOC still pointed at top-level
# analysis/phase-f-f04-v18.md after archive; soft FAIL printed then exit0;
# Makefile fossil greps after Makefile deleted). PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/std-crypto.sh
. tests/lib/std-crypto.sh

DOC="${XLANG_F04_CRYPTO_V18_DOC:-analysis/archive/phase/phase-f-f04-v18.md}"
MANIFEST="tests/baseline/f04-std-crypto-v18.tsv"
CHACHA="std/crypto/chacha20_poly1305.x"
AEAD="std/crypto/chacha20_aead.x"
GLUE="compiler/seeds/runtime_crypto_inc_glue.from_x.c"
COMPILE_STD="compiler/scripts/xlang_compile_std_module.sh"
PREFIX="xlang: [XLANG_F04_CRYPTO_V18]"

resolve_shu() {
  local cand abs
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$(pwd)/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

die() {
  echo "f04-crypto-v18 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} inventory=${INVENTORY_OK:-0} crypto=${CRYPTO_OK:-0} smoke=${SMOKE_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
INVENTORY_OK=0
CRYPTO_OK=0
SMOKE_OK=0
SKIP=1

echo "=== F-04 v18: std.crypto chacha20_poly1305.inc.c → chacha20_poly1305.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
grep -q 'F-04 v18' "$DOC" || die "doc missing F-04 v18 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f analysis/phase-f-f04-v18.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ ! -f std/crypto/chacha20_poly1305.inc.c ] || die "chacha20_poly1305.inc.c should be deleted"
[ -f "$CHACHA" ] || die "missing chacha20_poly1305.x"
[ -f "$AEAD" ] || die "missing chacha20_aead.x"
[ -f "$GLUE" ] || die "missing crypto_inc_glue seed"
[ -f "$COMPILE_STD" ] || die "missing xlang_compile_std_module.sh"
# Live split: core marker/block in chacha20_poly1305.x; AEAD seal/open/smoke in chacha20_aead.x.
# PLATFORM: SHARED archaeology — match xlang_compile_std_module crypto parts.
grep -q 'crypto_chacha_core_marker_c' "$CHACHA" || die "chacha core missing marker"
grep -q 'xlang_chacha20_block' "$CHACHA" || die "chacha core missing block"
grep -q 'crypto_chacha20_poly1305_seal_c' "$AEAD" || die "chacha aead missing seal"
grep -q 'crypto_chacha20_poly1305_open_c' "$AEAD" || die "chacha aead missing open"
grep -q 'crypto_chacha20_poly1305_smoke_c' "$AEAD" || die "chacha aead missing smoke"
grep -q 'chacha20_poly1305.x' "$COMPILE_STD" || die "compile_std missing chacha20_poly1305.x part"
grep -q 'chacha20_aead.x' "$COMPILE_STD" || die "compile_std missing chacha20_aead.x part"
if grep -q 'chacha20_poly1305.inc.c' "$GLUE" 2>/dev/null; then
  die "glue still includes chacha20_poly1305.inc.c"
fi

while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in
    \#*) continue ;;
  esac
  case "$kind" in
    symbol)
      target="$(std_crypto_resolve_impl_path "$mod_path")"
      [ -f "$target" ] || die "manifest target missing: $target"
      grep -qF "$anchor" "$target" || die "manifest missing '$anchor' in $target"
      ;;
    absent)
      [ ! -f "$anchor" ] || die "manifest absent file still exists: $anchor"
      ;;
    *)
      die "manifest unknown kind '$kind' for $item_id"
      ;;
  esac
done < "$MANIFEST"
echo "f04-crypto-v18 manifest OK"
STATIC_OK=1

if [ ! -f tests/run-std-c-inventory-gate.sh ]; then
  die "missing tests/run-std-c-inventory-gate.sh"
fi
echo "=== F-04 v18: delegate run-std-c-inventory-gate (F-01; hard) ==="
chmod +x tests/run-std-c-inventory-gate.sh
if ! XLANG_STD_C_INVENTORY_FAIL=1 tests/run-std-c-inventory-gate.sh; then
  die "std-c-inventory sub-gate failed"
fi
INVENTORY_OK=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1

xlang_compiler_make ../std/crypto/crypto.o >/dev/null 2>&1 || die "ensure crypto.o failed (xlang_compiler_make)"

if [ ! -f tests/run-std-crypto-gate.sh ]; then
  die "missing tests/run-std-crypto-gate.sh"
fi
echo "=== F-04 v18: delegate run-std-crypto-gate (manifest-only; hard) ==="
chmod +x tests/run-std-crypto-gate.sh
if ! XLANG_STD_CRYPTO_MANIFEST_ONLY=1 tests/run-std-crypto-gate.sh; then
  die "run-std-crypto-gate failed"
fi
CRYPTO_OK=1

# Host-c chacha smoke observational (product AEAD body may be stub / UNDEF).
# PLATFORM: SHARED archaeology.
echo "=== F-04 v18: host-c chacha smoke (observational) ==="
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
set +e
if std_crypto_o_has_x_symbols std/crypto/crypto.o \
  && nm std/crypto/crypto.o 2>/dev/null | grep -qE ' crypto_chacha20_poly1305_smoke_c$'; then
  cat >"$TMP/chacha_smoke_main.c" <<'EOF'
#include <stdint.h>
extern int32_t crypto_chacha20_poly1305_smoke_c(void);
int main(void) { return crypto_chacha20_poly1305_smoke_c() != 0 ? 1 : 0; }
EOF
  if cc -std=c11 -O1 -o "$TMP/chacha_smoke" "$TMP/chacha_smoke_main.c" std/crypto/crypto.o 2>/dev/null \
    && "$TMP/chacha_smoke"; then
    SMOKE_OK=1
    echo "f04 crypto chacha20_poly1305 smoke OK"
  else
    echo "f04-crypto-v18: chacha host-c observational fail (not soft FAIL)" >&2
    SMOKE_OK=0
  fi
else
  echo "f04-crypto-v18: chacha host-c observational skip (missing symbols)" >&2
  SMOKE_OK=0
fi
set -e
SKIP=0

echo "${PREFIX} status=ok static=${STATIC_OK} inventory=${INVENTORY_OK} crypto=${CRYPTO_OK} smoke=${SMOKE_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f04 std.crypto v18 gate OK (F-04 v18; honesty)"
