#!/usr/bin/env bash
# STD-126：std.crypto Ed25519 门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-crypto-ed25519-v1.md"
MANIFEST="tests/baseline/std-crypto-ed25519-manifest.tsv"
MOD_X="std/crypto/mod.x"
ED25519_X="std/crypto/ed25519.x"
REF10_GLUE="compiler/src/asm/runtime_ed25519_ref10_glue.inc"
CRYPTO_GLUE="compiler/src/asm/runtime_crypto_inc_glue.c"
LIB="tests/lib/std-crypto-ed25519.sh"
SMOKE_X="tests/std-crypto/ed25519_roundtrip.x"
. "$LIB"
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$ED25519_X" "$REF10_GLUE" "$CRYPTO_GLUE" "$SMOKE_X"; do
  [ -f "$f" ] || { echo "std-crypto-ed25519 gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF STD-126 "$DOC" || { echo "std-crypto-ed25519 gate FAIL: doc" >&2; exit 1; }
sym_miss="$(std_crypto_ed25519_symbols_ok "$MOD_X" "$ED25519_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/crypto/crypto.o
ensure_runtime_ed25519_ref10_glue_o
ensure_runtime_crypto_inc_glue_o
CRYPTO_O="$(cd compiler && pwd)/../std/crypto/crypto.o"
C_OK=0
SKIP=0
set +e
std_crypto_ed25519_run_c_smoke "$CRYPTO_O"
c_ec=$?
set -e
if [ "$c_ec" -eq 0 ]; then
  C_OK=1
elif [ "$c_ec" -eq 2 ]; then
  SKIP=1
else
  exit 1
fi
X_OK=0
if [ -x ./compiler/shux-c ]; then
  ./compiler/shux-c check -L . "$SMOKE_X" >/dev/null
  std_crypto_ed25519_run_smoke ./compiler/shux-c "$SMOKE_X" && X_OK=1 || exit 1
else
  SKIP=1
fi
std_crypto_ed25519_emit_report ok "$C_OK" "$X_OK" "$SKIP"
echo "std-crypto-ed25519 gate OK"
