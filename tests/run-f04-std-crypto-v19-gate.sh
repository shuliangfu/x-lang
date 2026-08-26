#!/usr/bin/env bash
# F-04 v19: std.crypto ed25519.inc.c → ed25519.x + ref10 glue.
#
# Usage: ./tests/run-f04-std-crypto-v19-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f04-std-crypto-v19-gate.sh
# 2026-08-26: Honesty — hard-fail static TSV + inventory + STD-006
# manifest-only (no soft die→exit0). Soft XLANG_F04_CRYPTO_V19_FAIL retired.
# Prefer asm; pin XLANG_LINK_XLANG. Do NOT delegate run-std-crypto-ed25519-gate
# (still hard-runs `xlang-c check`; check gate paused 2026-08-05). Host-c
# ed25519 smoke observational. Report static=/inventory=/crypto=/smoke=/skip=.
# Gate was portable-false-green (DOC still pointed at top-level
# analysis/phase-f-f04-v19.md after archive; soft FAIL printed then exit0;
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

DOC="${XLANG_F04_CRYPTO_V19_DOC:-analysis/archive/phase/phase-f-f04-v19.md}"
MANIFEST="tests/baseline/f04-std-crypto-v19.tsv"
ED25519="std/crypto/ed25519.x"
GLUE="compiler/seeds/runtime_ed25519_ref10_glue.from_x.c"
INC_GLUE="compiler/seeds/runtime_crypto_inc_glue.from_x.c"
COMPILE_STD="compiler/scripts/xlang_compile_std_module.sh"
MK_SEED="compiler/mk/driver_seed_r_lists.mk"
PREFIX="xlang: [XLANG_F04_CRYPTO_V19]"

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
  echo "f04-crypto-v19 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} inventory=${INVENTORY_OK:-0} crypto=${CRYPTO_OK:-0} smoke=${SMOKE_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
INVENTORY_OK=0
CRYPTO_OK=0
SMOKE_OK=0
SKIP=1

echo "=== F-04 v19: std.crypto ed25519.inc.c → ed25519.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
grep -q 'F-04 v19' "$DOC" || die "doc missing F-04 v19 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f analysis/phase-f-f04-v19.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ ! -f std/crypto/ed25519.inc.c ] || die "ed25519.inc.c should be deleted"
[ -f "$ED25519" ] || die "missing ed25519.x"
[ -f "$GLUE" ] || die "missing ed25519_ref10_glue seed"
[ -f "$INC_GLUE" ] || die "missing crypto_inc_glue seed"
[ -f "$COMPILE_STD" ] || die "missing xlang_compile_std_module.sh"
[ -f "$MK_SEED" ] || die "missing driver_seed_r_lists.mk"
grep -q 'crypto_ed25519_sign_c' "$ED25519" || die "ed25519.x missing sign"
grep -q 'crypto_ed25519_smoke_c' "$ED25519" || die "ed25519.x missing smoke"
grep -q 'crypto/ed25519/fe.inc' "$GLUE" || die "ref10 glue missing fe.inc include"
grep -q 'ed25519.x' "$COMPILE_STD" || die "compile_std missing ed25519.x part"
grep -q 'runtime_ed25519_ref10_glue.o' "$MK_SEED" || die "mk missing runtime_ed25519_ref10_glue.o"
grep -q 'runtime_crypto_inc_glue.o' "$MK_SEED" || die "mk missing runtime_crypto_inc_glue.o"
if grep -q 'ed25519.inc.c' "$INC_GLUE" 2>/dev/null; then
  die "crypto_inc_glue still includes ed25519.inc.c"
fi
[ ! -f std/crypto/crypto_inc_glue.c ] || die "std crypto_inc_glue.c should be deleted (F-ZC)"
[ ! -f std/crypto/ed25519_ref10_glue.c ] || die "std ed25519_ref10_glue.c should be deleted (F-ZC)"

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
    file)
      [ -f "$anchor" ] || die "manifest missing file $anchor"
      ;;
    *)
      die "manifest unknown kind '$kind' for $item_id"
      ;;
  esac
done < "$MANIFEST"
echo "f04-crypto-v19 manifest OK"
STATIC_OK=1

if [ ! -f tests/run-std-c-inventory-gate.sh ]; then
  die "missing tests/run-std-c-inventory-gate.sh"
fi
echo "=== F-04 v19: delegate run-std-c-inventory-gate (F-01; hard) ==="
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

xlang_compiler_make ../std/crypto/crypto.o runtime_ed25519_ref10_glue.o runtime_crypto_inc_glue.o >/dev/null 2>&1 \
  || die "ensure crypto.o + glue failed (xlang_compiler_make)"

# Product path = STD-006 manifest-only (ed25519 child still hard-runs check;
# check gate paused — do not open that knife here).
# PLATFORM: SHARED archaeology.
if [ ! -f tests/run-std-crypto-gate.sh ]; then
  die "missing tests/run-std-crypto-gate.sh"
fi
echo "=== F-04 v19: delegate run-std-crypto-gate (manifest-only; hard) ==="
chmod +x tests/run-std-crypto-gate.sh
if ! XLANG_STD_CRYPTO_MANIFEST_ONLY=1 tests/run-std-crypto-gate.sh; then
  die "run-std-crypto-gate failed"
fi
CRYPTO_OK=1

# Host-c ed25519 smoke observational.
# PLATFORM: SHARED archaeology.
echo "=== F-04 v19: host-c ed25519 smoke (observational) ==="
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
set +e
if std_crypto_o_has_x_symbols std/crypto/crypto.o \
  && nm std/crypto/crypto.o 2>/dev/null | grep -qE ' crypto_ed25519_smoke_c$'; then
  cat >"$TMP/ed25519_smoke_main.c" <<'EOF'
#include <stdint.h>
extern int32_t crypto_ed25519_smoke_c(void);
int main(void) { return crypto_ed25519_smoke_c() != 0 ? 1 : 0; }
EOF
  if cc -std=c11 -O1 -o "$TMP/ed25519_smoke" "$TMP/ed25519_smoke_main.c" $(std_crypto_c_link_objs) 2>/dev/null \
    && "$TMP/ed25519_smoke"; then
    SMOKE_OK=1
    echo "f04 crypto ed25519 smoke OK"
  else
    echo "f04-crypto-v19: ed25519 host-c observational fail (not soft FAIL)" >&2
    SMOKE_OK=0
  fi
else
  echo "f04-crypto-v19: ed25519 host-c observational skip (missing symbols)" >&2
  SMOKE_OK=0
fi
set -e
SKIP=0

echo "${PREFIX} status=ok static=${STATIC_OK} inventory=${INVENTORY_OK} crypto=${CRYPTO_OK} smoke=${SMOKE_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f04 std.crypto v19 gate OK (F-04 v19; honesty)"
