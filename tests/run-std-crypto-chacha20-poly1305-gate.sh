#!/usr/bin/env bash
# STD-113：std.crypto ChaCha20-Poly1305 门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-crypto-chacha20-poly1305-v1.md"
MANIFEST="tests/baseline/std-crypto-chacha20-poly1305.tsv"
MOD_SX="std/crypto/mod.sx"
CRYPTO_GLUE="compiler/src/asm/runtime_crypto_inc_glue.c"
LIB="tests/lib/std-crypto-chacha20-poly1305.sh"
SMOKE_SX="tests/std-crypto/chacha20_poly1305_roundtrip.sx"
. "$LIB"
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SX" "$CRYPTO_GLUE" "$SMOKE_SX"; do
  [ -f "$f" ] || { echo "std-crypto-chacha gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF STD-113 "$DOC" || { echo "std-crypto-chacha gate FAIL: doc" >&2; exit 1; }
sym_miss="$(std_crypto_chacha_symbols_ok "$MOD_SX" "$CRYPTO_GLUE" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/crypto/crypto.o
CRYPTO_O="$(cd compiler && pwd)/../std/crypto/crypto.o"
C_OK=0
SKIP=0
if std_crypto_o_has_sx_symbols "$CRYPTO_O"; then
  std_crypto_chacha_run_c_smoke "$CRYPTO_O" && C_OK=1 || exit 1
else
  echo "std-crypto-chacha SKIP c smoke (crypto.o missing .sx symbols; need shux-c)" >&2
  SKIP=1
fi
SX_OK=0
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  SHUX_BIN=./compiler/shux-c
  [ -x "$SHUX_BIN" ] || SHUX_BIN=./compiler/shux
  "$SHUX_BIN" check -L . "$SMOKE_SX" >/dev/null
  std_crypto_chacha_run_smoke "$SHUX_BIN" "$SMOKE_SX" && SX_OK=1 || exit 1
else
  SKIP=1
fi
std_crypto_chacha_emit_report ok "$C_OK" "$SX_OK" "$SKIP"
echo "std-crypto-chacha20-poly1305 gate OK"
