#!/usr/bin/env bash
# STD-113：std.crypto ChaCha20-Poly1305 门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-crypto-chacha20-poly1305-v1.md"
MANIFEST="tests/baseline/std-crypto-chacha20-poly1305.tsv"
MOD_SU="std/crypto/mod.su"
CRYPTO_C="std/crypto/crypto.c"
LIB="tests/lib/std-crypto-chacha20-poly1305.sh"
SMOKE_SU="tests/std-crypto/chacha20_poly1305_roundtrip.su"
. "$LIB"
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$CRYPTO_C" "$SMOKE_SU"; do
  [ -f "$f" ] || { echo "std-crypto-chacha gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF STD-113 "$DOC" || { echo "std-crypto-chacha gate FAIL: doc" >&2; exit 1; }
sym_miss="$(std_crypto_chacha_symbols_ok "$MOD_SU" "$CRYPTO_C" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/crypto/crypto.o
CRYPTO_O="$(cd compiler && pwd)/../std/crypto/crypto.o"
C_OK=0
std_crypto_chacha_run_c_smoke "$CRYPTO_O" && C_OK=1 || exit 1
SU_OK=0
SKIP=0
if [ -x ./compiler/shu-c ]; then
  ./compiler/shu-c check -L . "$SMOKE_SU" >/dev/null
  std_crypto_chacha_run_smoke ./compiler/shu-c "$SMOKE_SU" && SU_OK=1 || exit 1
else
  SKIP=1
fi
std_crypto_chacha_emit_report ok "$C_OK" "$SU_OK" "$SKIP"
echo "std-crypto-chacha20-poly1305 gate OK"
