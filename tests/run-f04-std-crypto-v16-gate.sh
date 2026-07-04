#!/usr/bin/env bash
# F-04 v16：std.crypto crypto.c shell 去 C 门禁。
#
# 用法：./tests/run-f04-std-crypto-v16-gate.sh
# 环境：SHUX_F04_CRYPTO_V16_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F04_CRYPTO_V16_FAIL:-0}
DOC="analysis/phase-f-f04-v16.md"
CORE="std/crypto/core.x"
GLUE="compiler/src/asm/runtime_crypto_inc_glue.c"

# shellcheck source=tests/lib/std-crypto.sh
. tests/lib/std-crypto.sh

die() {
  echo "f04-crypto-v16 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-04 v16: std.crypto remove crypto.c shell ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v16' "$DOC" || die "doc missing F-04 v16 marker"
[ ! -f std/crypto/crypto.c ] || die "crypto.c should be deleted"
[ -f "$CORE" ] || die "missing core.x"
[ -f "$GLUE" ] || die "missing crypto_inc_glue.c"
grep -q 'crypto_mem_eq_c' "$CORE" || die "crypto_core missing mem_eq"
grep -q 'crypto_sha256_c' "$CORE" || die "crypto_core missing sha256"
grep -q 'crypto_hmac_sha256_c' "$CORE" || die "crypto_core missing hmac_sha256"
grep -q 'crypto_sha512_c' "$GLUE" || die "glue missing sha512"
grep -q 'core.x' compiler/Makefile || die "Makefile missing core.x build"
if grep -q 'std/crypto/crypto\.c' compiler/Makefile 2>/dev/null; then
  die "Makefile still references crypto.c"
fi

MANIFEST="tests/baseline/f04-std-crypto-v16.tsv"
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
  if ! cc -std=c11 -O1 -o "$TMP/sha256_smoke" "$TMP/sha256_smoke_main.c" std/crypto/crypto.o 2>/dev/null; then
    die "sha256 C smoke compile failed"
  fi
  "$TMP/sha256_smoke" || die "sha256 C smoke run failed"
  echo "f04 crypto sha256 smoke OK"
else
  echo "f04 crypto sha256 smoke SKIP (crypto.o missing .x symbols; need shux-c)"
fi

if [ -f tests/run-std-crypto-gate.sh ]; then
  echo "=== F-04 v16: delegate run-std-crypto-gate (manifest) ==="
  chmod +x tests/run-std-crypto-gate.sh
  if ! SHUX_STD_CRYPTO_MANIFEST_ONLY=1 tests/run-std-crypto-gate.sh; then
    die "run-std-crypto-gate failed"
  fi
fi

echo "f04 std.crypto v16 gate OK (F-04 v16)"
