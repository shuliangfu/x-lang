#!/usr/bin/env bash
# STD-126：std.crypto Ed25519 门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-crypto-ed25519-v1.md"
MANIFEST="tests/baseline/std-crypto-ed25519-manifest.tsv"
MOD_SU="std/crypto/mod.sx"
CRYPTO_C="std/crypto/crypto.c"
LIB="tests/lib/std-crypto-ed25519.sh"
SMOKE_SU="tests/std-crypto/ed25519_roundtrip.sx"
. "$LIB"
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$CRYPTO_C" "$SMOKE_SU"; do
  [ -f "$f" ] || { echo "std-crypto-ed25519 gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF STD-126 "$DOC" || { echo "std-crypto-ed25519 gate FAIL: doc" >&2; exit 1; }
sym_miss="$(std_crypto_ed25519_symbols_ok "$MOD_SU" "$CRYPTO_C" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/crypto/crypto.o
CRYPTO_O="$(cd compiler && pwd)/../std/crypto/crypto.o"
C_OK=0
std_crypto_ed25519_run_c_smoke "$CRYPTO_O" && C_OK=1 || exit 1
SU_OK=0
SKIP=0
if [ -x ./compiler/shux-c ]; then
  ./compiler/shux-c check -L . "$SMOKE_SU" >/dev/null
  std_crypto_ed25519_run_smoke ./compiler/shux-c "$SMOKE_SU" && SU_OK=1 || exit 1
else
  SKIP=1
fi
std_crypto_ed25519_emit_report ok "$C_OK" "$SU_OK" "$SKIP"
echo "std-crypto-ed25519 gate OK"
