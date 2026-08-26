#!/usr/bin/env bash
# F-04 v17: std.crypto aes_gcm.inc.c → aes_gcm.x.
#
# Usage: ./tests/run-f04-std-crypto-v17-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f04-std-crypto-v17-gate.sh
# 2026-08-26: Honesty — hard-fail static TSV + inventory + STD-006
# manifest-only (no soft die→exit0). Soft XLANG_F04_CRYPTO_V17_FAIL retired.
# Prefer asm; pin XLANG_LINK_XLANG. Host-c aes_gcm smoke observational
# (aes-gcm nist2 product residual stays out of this archaeology knife).
# Report static=/inventory=/crypto=/smoke=/skip=. Gate was
# portable-false-green (DOC still pointed at top-level
# analysis/phase-f-f04-v17.md after archive; soft FAIL printed then exit0;
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

DOC="${XLANG_F04_CRYPTO_V17_DOC:-analysis/archive/phase/phase-f-f04-v17.md}"
MANIFEST="tests/baseline/f04-std-crypto-v17.tsv"
AES_GCM="std/crypto/aes_gcm.x"
GLUE="compiler/seeds/runtime_crypto_inc_glue.from_x.c"
COMPILE_STD="compiler/scripts/xlang_compile_std_module.sh"
PREFIX="xlang: [XLANG_F04_CRYPTO_V17]"

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
  echo "f04-crypto-v17 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} inventory=${INVENTORY_OK:-0} crypto=${CRYPTO_OK:-0} smoke=${SMOKE_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
INVENTORY_OK=0
CRYPTO_OK=0
SMOKE_OK=0
SKIP=1

echo "=== F-04 v17: std.crypto aes_gcm.inc.c → aes_gcm.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
grep -q 'F-04 v17' "$DOC" || die "doc missing F-04 v17 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f analysis/phase-f-f04-v17.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ ! -f std/crypto/aes_gcm.inc.c ] || die "aes_gcm.inc.c should be deleted"
[ -f "$AES_GCM" ] || die "missing aes_gcm.x"
[ -f "$GLUE" ] || die "missing crypto_inc_glue seed"
[ -f "$COMPILE_STD" ] || die "missing xlang_compile_std_module.sh"
grep -q 'crypto_aes_gcm_seal_c' "$AES_GCM" || die "aes_gcm missing seal"
grep -q 'crypto_aes_gcm_open_c' "$AES_GCM" || die "aes_gcm missing open"
grep -q 'crypto_aes_gcm_marker_c' "$AES_GCM" || die "aes_gcm missing marker"
grep -q 'aes_gcm.x' "$COMPILE_STD" || die "compile_std missing aes_gcm.x part"
if grep -q 'aes_gcm.inc.c' "$GLUE" 2>/dev/null; then
  die "glue still includes aes_gcm.inc.c"
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
echo "f04-crypto-v17 manifest OK"
STATIC_OK=1

if [ ! -f tests/run-std-c-inventory-gate.sh ]; then
  die "missing tests/run-std-c-inventory-gate.sh"
fi
echo "=== F-04 v17: delegate run-std-c-inventory-gate (F-01; hard) ==="
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
echo "=== F-04 v17: delegate run-std-crypto-gate (manifest-only; hard) ==="
chmod +x tests/run-std-crypto-gate.sh
if ! XLANG_STD_CRYPTO_MANIFEST_ONLY=1 tests/run-std-crypto-gate.sh; then
  die "run-std-crypto-gate failed"
fi
CRYPTO_OK=1

# Host-c aes_gcm smoke observational (nist2 product residual not this knife).
# PLATFORM: SHARED archaeology.
echo "=== F-04 v17: host-c aes_gcm smoke (observational) ==="
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
set +e
if std_crypto_o_has_x_symbols std/crypto/crypto.o \
  && nm std/crypto/crypto.o 2>/dev/null | grep -qE ' crypto_aes_gcm_seal_c$'; then
  cat >"$TMP/aes_gcm_smoke_main.c" <<'EOF'
#include <stdint.h>
#include <string.h>
extern int32_t crypto_aes_gcm_seal_c(const uint8_t *key, int32_t key_len, const uint8_t *iv,
  int32_t iv_len, const uint8_t *aad, int32_t aad_len, const uint8_t *pt, int32_t pt_len,
  uint8_t *ct, uint8_t *tag);
extern int32_t crypto_aes_gcm_open_c(const uint8_t *key, int32_t key_len, const uint8_t *iv,
  int32_t iv_len, const uint8_t *aad, int32_t aad_len, const uint8_t *ct, int32_t ct_len,
  const uint8_t *tag, uint8_t *pt);
int main(void) {
  uint8_t key[16] = {0};
  uint8_t iv[12] = {0};
  uint8_t pt[16] = {0};
  uint8_t ct[16];
  uint8_t tag[16];
  uint8_t out[16];
  if (crypto_aes_gcm_seal_c(key, 16, iv, 12, 0, 0, pt, 16, ct, tag) != 0) return 1;
  if (crypto_aes_gcm_open_c(key, 16, iv, 12, 0, 0, ct, 16, tag, out) != 0) return 2;
  return memcmp(pt, out, 16) == 0 ? 0 : 3;
}
EOF
  if cc -std=c11 -O1 -o "$TMP/aes_gcm_smoke" "$TMP/aes_gcm_smoke_main.c" std/crypto/crypto.o 2>/dev/null \
    && "$TMP/aes_gcm_smoke"; then
    SMOKE_OK=1
    echo "f04 crypto aes_gcm smoke OK"
  else
    echo "f04-crypto-v17: aes_gcm host-c observational fail (not soft FAIL)" >&2
    SMOKE_OK=0
  fi
else
  echo "f04-crypto-v17: aes_gcm host-c observational skip (missing symbols)" >&2
  SMOKE_OK=0
fi
set -e
SKIP=0

echo "${PREFIX} status=ok static=${STATIC_OK} inventory=${INVENTORY_OK} crypto=${CRYPTO_OK} smoke=${SMOKE_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f04 std.crypto v17 gate OK (F-04 v17; honesty)"
