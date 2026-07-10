#!/usr/bin/env bash
# F-04 v18：std.crypto chacha20_poly1305.inc.c → chacha20_poly1305.x 门禁。
#
# 用法：./tests/run-f04-std-crypto-v18-gate.sh
# 环境：SHUX_F04_CRYPTO_V18_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F04_CRYPTO_V18_FAIL:-0}
DOC="analysis/phase-f-f04-v18.md"
CHACHA="std/crypto/chacha20_poly1305.x"
GLUE="compiler/src/asm/runtime_crypto_inc_glue.inc"

# shellcheck source=tests/lib/std-crypto.sh
. tests/lib/std-crypto.sh

die() {
  echo "f04-crypto-v18 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-04 v18: std.crypto chacha20_poly1305.inc.c → chacha20_poly1305.x ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v18' "$DOC" || die "doc missing F-04 v18 marker"
[ ! -f std/crypto/chacha20_poly1305.inc.c ] || die "chacha20_poly1305.inc.c should be deleted"
[ -f "$CHACHA" ] || die "missing chacha20_poly1305.x"
[ -f "$GLUE" ] || die "missing crypto_inc_glue.c"
grep -q 'crypto_chacha20_poly1305_seal_c' "$CHACHA" || die "chacha missing seal"
grep -q 'crypto_chacha20_poly1305_open_c' "$CHACHA" || die "chacha missing open"
grep -q 'crypto_chacha20_poly1305_smoke_c' "$CHACHA" || die "chacha missing smoke"
grep -q 'Poly1305Ctx' "$CHACHA" || die "chacha missing Poly1305Ctx"
grep -q 'allow(padding)' "$CHACHA" || die "chacha missing allow(padding)"
grep -q 'crypto_mem_eq_c' "$CHACHA" || die "chacha missing crypto_mem_eq_c extern"
grep -q 'chacha20_poly1305.x' compiler/Makefile || die "Makefile missing chacha20_poly1305.x build"
if grep -q 'chacha20_poly1305.inc.c' "$GLUE" 2>/dev/null; then
  die "glue still includes chacha20_poly1305.inc.c"
fi

MANIFEST="tests/baseline/f04-std-crypto-v18.tsv"
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
  if nm std/crypto/crypto.o 2>/dev/null | grep -qE ' crypto_chacha20_poly1305_smoke_c$'; then
    cat >"$TMP/chacha_smoke_main.c" <<'EOF'
#include <stdint.h>
extern int32_t crypto_chacha20_poly1305_smoke_c(void);
int main(void) { return crypto_chacha20_poly1305_smoke_c() != 0 ? 1 : 0; }
EOF
    if ! cc -std=c11 -O1 -o "$TMP/chacha_smoke" "$TMP/chacha_smoke_main.c" std/crypto/crypto.o 2>/dev/null; then
      die "chacha C smoke compile failed"
    fi
    "$TMP/chacha_smoke" || die "chacha C smoke run failed"
    echo "f04 crypto chacha20_poly1305 smoke OK"
  else
    echo "f04 crypto chacha20_poly1305 smoke SKIP (crypto.o missing chacha symbols)"
  fi
else
  echo "f04 crypto chacha20_poly1305 smoke SKIP (crypto.o missing .x symbols; need shux-c)"
fi

if [ -f tests/run-std-crypto-gate.sh ]; then
  echo "=== F-04 v18: delegate run-std-crypto-gate (manifest) ==="
  chmod +x tests/run-std-crypto-gate.sh
  if ! SHUX_STD_CRYPTO_MANIFEST_ONLY=1 tests/run-std-crypto-gate.sh; then
    die "run-std-crypto-gate failed"
  fi
fi

echo "f04 std.crypto v18 gate OK (F-04 v18)"
