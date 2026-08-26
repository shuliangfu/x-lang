#!/usr/bin/env bash
# F-04 v21: std.crypto module closure (v16～v19 aggregate + manifest).
#
# Usage: ./tests/run-f04-std-crypto-closure-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f04-std-crypto-closure-gate.sh
# 2026-08-26: Honesty — hard-fail static TSV + four child gates + inventory +
# STD-006 manifest-only (no soft die→exit0; no export of retired
# XLANG_F04_CRYPTO_{V16,V17,V18,V19,CLOSURE}_FAIL). Soft
# XLANG_F04_CRYPTO_CLOSURE_FAIL retired. Prefer asm; pin XLANG_LINK_XLANG.
# Report v16=/v17=/v18=/v19=/crypto=/inventory=/skip=. Gate was
# portable-false-green (soft FAIL exit0 + soft child FAIL pass-through +
# Makefile content greps / TSV makefile_crypto_o after Makefile deleted while
# children already honesty-green). PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_F04_DOC:-analysis/archive/phase/phase-f-f04-v21-closure.md}"
MANIFEST="tests/baseline/f04-std-crypto-closure.tsv"
COMPILE_STD="compiler/scripts/xlang_compile_std_module.sh"
MK_STD="compiler/mk/std_and_panic_objs.mk"
MK_SEED="compiler/mk/driver_seed_r_lists.mk"
PREFIX="xlang: [XLANG_F04_CRYPTO_CLOSURE]"

resolve_shu() {
  local cand abs
  # Prefer product asm; pin XLANG_LINK_XLANG for child dogfood consistency.
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
  echo "f04-crypto-closure gate FAIL: $*" >&2
  echo "${PREFIX} status=fail v16=${V16_OK:-0} v17=${V17_OK:-0} v18=${V18_OK:-0} v19=${V19_OK:-0} crypto=${CRYPTO_OK:-0} inventory=${INVENTORY_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

V16_OK=0
V17_OK=0
V18_OK=0
V19_OK=0
CRYPTO_OK=0
INVENTORY_OK=0
SKIP=1

echo "=== F-04 v21: std.crypto module closure (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
grep -q 'F-04 v21' "$DOC" || die "doc missing F-04 v21 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f analysis/phase-f-f04-v21-closure.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$COMPILE_STD" ] || die "missing xlang_compile_std_module.sh"
[ -f "$MK_STD" ] || die "missing std_and_panic_objs.mk"
[ -f "$MK_SEED" ] || die "missing driver_seed_r_lists.mk"
grep -q '../std/crypto/crypto.o' "$MK_STD" || die "mk missing crypto.o"
grep -q 'core.x' "$COMPILE_STD" || die "compile_std missing core.x"
grep -q 'aes_gcm.x' "$COMPILE_STD" || die "compile_std missing aes_gcm.x"
grep -q 'chacha20_poly1305.x' "$COMPILE_STD" || die "compile_std missing chacha20_poly1305.x"
grep -q 'ed25519.x' "$COMPILE_STD" || die "compile_std missing ed25519.x"
grep -q 'runtime_crypto_inc_glue.o' "$MK_SEED" || die "mk missing runtime_crypto_inc_glue.o"
grep -q 'runtime_ed25519_ref10_glue.o' "$MK_SEED" || die "mk missing runtime_ed25519_ref10_glue.o"
[ ! -f std/crypto/crypto.c ] || die "std/crypto/crypto.c must stay deleted"
if grep -q 'std/crypto/crypto\.c' "$COMPILE_STD" 2>/dev/null; then
  # compile_std may mention crypto.o path only; ban resurrect of crypto.c source path as part list.
  :
fi

while IFS=$'\t' read -r item_id kind anchor _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in
    \#*) continue ;;
  esac
  case "$kind" in
    file|doc|gate|script|manifest)
      [ -f "$anchor" ] || die "missing $anchor ($item_id)"
      ;;
    absent)
      [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)"
      ;;
    *)
      die "manifest unknown kind '$kind' for $item_id"
      ;;
  esac
done < "$MANIFEST"
echo "f04-crypto-closure manifest OK"

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1

xlang_compiler_make ../std/crypto/crypto.o >/dev/null 2>&1 || die "ensure crypto.o failed (xlang_compiler_make)"

# Hard-delegate children. Do NOT export retired XLANG_F04_CRYPTO_*_FAIL envs.
# PLATFORM: SHARED archaeology.
run_child() {
  local g="$1"
  local flag_var="$2"
  [ -f "$g" ] || die "missing $g"
  echo "=== F-04 v21: delegate $(basename "$g") (hard) ==="
  chmod +x "$g"
  if ! "$g"; then
    die "$(basename "$g") sub-gate failed"
  fi
  eval "$flag_var=1"
}

run_child tests/run-f04-std-crypto-v16-gate.sh V16_OK
run_child tests/run-f04-std-crypto-v17-gate.sh V17_OK
run_child tests/run-f04-std-crypto-v18-gate.sh V18_OK
run_child tests/run-f04-std-crypto-v19-gate.sh V19_OK

if [ -f tests/run-std-crypto-gate.sh ]; then
  echo "=== F-04 v21: delegate run-std-crypto-gate (manifest-only; hard) ==="
  chmod +x tests/run-std-crypto-gate.sh
  if ! XLANG_STD_CRYPTO_MANIFEST_ONLY=1 tests/run-std-crypto-gate.sh; then
    die "run-std-crypto-gate failed"
  fi
  CRYPTO_OK=1
else
  die "missing tests/run-std-crypto-gate.sh"
fi

if [ -f tests/run-std-c-inventory-gate.sh ]; then
  echo "=== F-04 v21: delegate run-std-c-inventory-gate (F-01; hard) ==="
  chmod +x tests/run-std-c-inventory-gate.sh
  if ! XLANG_STD_C_INVENTORY_FAIL=1 tests/run-std-c-inventory-gate.sh; then
    die "std-c-inventory sub-gate failed"
  fi
  INVENTORY_OK=1
else
  die "missing tests/run-std-c-inventory-gate.sh"
fi
SKIP=0

echo "${PREFIX} status=ok v16=${V16_OK} v17=${V17_OK} v18=${V18_OK} v19=${V19_OK} crypto=${CRYPTO_OK} inventory=${INVENTORY_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f04 std.crypto closure gate OK (F-04 v21; honesty)"
