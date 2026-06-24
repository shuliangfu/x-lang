#!/usr/bin/env bash
# F-04 v17：std.crypto aes_gcm.inc.c → aes_gcm.sx 门禁。
#
# 用法：./tests/run-f04-std-crypto-v17-gate.sh
# 环境：SHUX_F04_CRYPTO_V17_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F04_CRYPTO_V17_FAIL:-0}
DOC="analysis/phase-f-f04-v17.md"
AES_GCM="std/crypto/aes_gcm.sx"
GLUE="compiler/src/asm/runtime_crypto_inc_glue.c"

# shellcheck source=tests/lib/std-crypto.sh
. tests/lib/std-crypto.sh

die() {
  echo "f04-crypto-v17 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-04 v17: std.crypto aes_gcm.inc.c → aes_gcm.sx ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v17' "$DOC" || die "doc missing F-04 v17 marker"
[ ! -f std/crypto/aes_gcm.inc.c ] || die "aes_gcm.inc.c should be deleted"
[ -f "$AES_GCM" ] || die "missing aes_gcm.sx"
[ -f "$GLUE" ] || die "missing crypto_inc_glue.c"
grep -q 'crypto_aes_gcm_seal_c' "$AES_GCM" || die "aes_gcm missing seal"
grep -q 'crypto_aes_gcm_open_c' "$AES_GCM" || die "aes_gcm missing open"
grep -q 'CRYPTO_AES_SBOX' "$AES_GCM" || die "aes_gcm missing sbox"
grep -q 'aes_gcm.sx' compiler/Makefile || die "Makefile missing aes_gcm.sx build"
if grep -q 'aes_gcm.inc.c' "$GLUE" 2>/dev/null; then
  die "glue still includes aes_gcm.inc.c"
fi

MANIFEST="tests/baseline/f04-std-crypto-v17.tsv"
if [ -f "$MANIFEST" ]; then
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*) continue ;; esac
    case "$kind" in
      symbol)
        target="$(std_crypto_resolve_impl_path "$mod_path")"
        grep -qF "$anchor" "$target" || die "manifest missing '$anchor' in $target"
        ;;
      absent)
        [ ! -f "$anchor" ] || die "manifest absent file still exists: $anchor"
        ;;
    esac
  done < "$MANIFEST"
fi

make -C compiler ../std/crypto/crypto.o >/dev/null 2>&1 || die "make crypto.o failed"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
if std_crypto_o_has_sx_symbols std/crypto/crypto.o; then
  if nm std/crypto/crypto.o 2>/dev/null | grep -qE ' crypto_aes_gcm_seal_c$'; then
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
    if ! cc -std=c11 -O1 -o "$TMP/aes_gcm_smoke" "$TMP/aes_gcm_smoke_main.c" std/crypto/crypto.o 2>/dev/null; then
      die "aes_gcm C smoke compile failed"
    fi
    "$TMP/aes_gcm_smoke" || die "aes_gcm C smoke run failed"
    echo "f04 crypto aes_gcm smoke OK"
  else
    echo "f04 crypto aes_gcm smoke SKIP (crypto.o missing aes_gcm symbols)"
  fi
else
  echo "f04 crypto aes_gcm smoke SKIP (crypto.o missing .sx symbols; need shux-c)"
fi

if [ -f tests/run-std-crypto-gate.sh ]; then
  echo "=== F-04 v17: delegate run-std-crypto-gate (manifest) ==="
  chmod +x tests/run-std-crypto-gate.sh
  if ! SHUX_STD_CRYPTO_MANIFEST_ONLY=1 tests/run-std-crypto-gate.sh; then
    die "run-std-crypto-gate failed"
  fi
fi

echo "f04 std.crypto v17 gate OK (F-04 v17)"
