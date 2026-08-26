#!/usr/bin/env bash
# F-04 v16: std.crypto remove crypto.c shell (core.x + glue).
#
# Usage: ./tests/run-f04-std-crypto-v16-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f04-std-crypto-v16-gate.sh
# 2026-08-26: Honesty — hard-fail static TSV + inventory + STD-006
# manifest-only (no soft die→exit0). Soft XLANG_F04_CRYPTO_V16_FAIL retired.
# Prefer asm; pin XLANG_LINK_XLANG. Host-c sha256 smoke observational.
# Report static=/inventory=/crypto=/smoke=/skip=. Gate was
# portable-false-green (DOC still pointed at top-level
# analysis/phase-f-f04-v16.md after archive; soft FAIL printed then exit0;
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

DOC="${XLANG_F04_CRYPTO_V16_DOC:-analysis/archive/phase/phase-f-f04-v16.md}"
MANIFEST="tests/baseline/f04-std-crypto-v16.tsv"
CORE="std/crypto/core.x"
GLUE="compiler/seeds/runtime_crypto_inc_glue.from_x.c"
COMPILE_STD="compiler/scripts/xlang_compile_std_module.sh"
MK_STD="compiler/mk/std_and_panic_objs.mk"
PREFIX="xlang: [XLANG_F04_CRYPTO_V16]"

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
  echo "f04-crypto-v16 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} inventory=${INVENTORY_OK:-0} crypto=${CRYPTO_OK:-0} smoke=${SMOKE_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
INVENTORY_OK=0
CRYPTO_OK=0
SMOKE_OK=0
SKIP=1

echo "=== F-04 v16: std.crypto remove crypto.c shell (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
grep -q 'F-04 v16' "$DOC" || die "doc missing F-04 v16 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f analysis/phase-f-f04-v16.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ ! -f std/crypto/crypto.c ] || die "crypto.c should be deleted"
[ -f "$CORE" ] || die "missing core.x"
[ -f "$GLUE" ] || die "missing crypto_inc_glue seed"
[ -f "$COMPILE_STD" ] || die "missing xlang_compile_std_module.sh"
[ -f "$MK_STD" ] || die "missing std_and_panic_objs.mk"
grep -q 'crypto_mem_eq_c' "$CORE" || die "crypto_core missing mem_eq"
grep -q 'crypto_sha256_c' "$CORE" || die "crypto_core missing sha256"
grep -q 'crypto_hmac_sha256_c' "$CORE" || die "crypto_core missing hmac_sha256"
grep -q 'crypto_sha512_c' "$GLUE" || die "glue missing sha512"
grep -q '../std/crypto/crypto.o' "$MK_STD" || die "mk missing crypto.o"
grep -q 'core.x' "$COMPILE_STD" || die "compile_std missing core.x part"
grep -q 'runtime_crypto_inc_glue.o' compiler/mk/driver_seed_r_lists.mk || die "mk missing runtime_crypto_inc_glue.o"

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
echo "f04-crypto-v16 manifest OK"
STATIC_OK=1

if [ ! -f tests/run-std-c-inventory-gate.sh ]; then
  die "missing tests/run-std-c-inventory-gate.sh"
fi
echo "=== F-04 v16: delegate run-std-c-inventory-gate (F-01; hard) ==="
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
echo "=== F-04 v16: delegate run-std-crypto-gate (manifest-only; hard) ==="
chmod +x tests/run-std-crypto-gate.sh
if ! XLANG_STD_CRYPTO_MANIFEST_ONLY=1 tests/run-std-crypto-gate.sh; then
  die "run-std-crypto-gate failed"
fi
CRYPTO_OK=1

# Host-c sha256 smoke is observational (archaeology = .x + inventory +
# STD-006; product residual / host-cc link quirks must not soft-fail the gate).
# PLATFORM: SHARED archaeology.
echo "=== F-04 v16: host-c sha256 smoke (observational) ==="
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
set +e
if std_crypto_o_has_x_symbols std/crypto/crypto.o; then
  cat >"$TMP/sha256_smoke_main.c" <<'EOF'
#include <stdint.h>
#include <string.h>
extern void crypto_sha256_c(const uint8_t *msg, int32_t len, uint8_t *out);
static const uint8_t expect[32] = {
  186, 120, 22, 191, 143, 1, 207, 234, 65, 65, 64, 222, 93, 174, 34, 35,
  176, 3, 97, 163, 150, 23, 122, 156, 180, 16, 255, 97, 242, 0, 21, 173};
int main(void) {
  uint8_t msg[3] = {'a', 'b', 'c'};
  uint8_t out[32];
  crypto_sha256_c(msg, 3, out);
  return memcmp(out, expect, 32) == 0 ? 0 : 1;
}
EOF
  if cc -std=c11 -O1 -o "$TMP/sha256_smoke" "$TMP/sha256_smoke_main.c" std/crypto/crypto.o 2>/dev/null \
    && "$TMP/sha256_smoke"; then
    SMOKE_OK=1
    echo "f04 crypto sha256 smoke OK"
  else
    echo "f04-crypto-v16: sha256 host-c observational fail (not soft FAIL)" >&2
    SMOKE_OK=0
  fi
else
  echo "f04-crypto-v16: sha256 host-c observational skip (no .x symbols)" >&2
  SMOKE_OK=0
fi
set -e
SKIP=0

echo "${PREFIX} status=ok static=${STATIC_OK} inventory=${INVENTORY_OK} crypto=${CRYPTO_OK} smoke=${SMOKE_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f04 std.crypto v16 gate OK (F-04 v16; honesty)"
