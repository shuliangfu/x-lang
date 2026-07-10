#!/usr/bin/env bash
# F-04 v19：std.crypto ed25519.inc.c → ed25519.x 门禁。
#
# 用法：./tests/run-f04-std-crypto-v19-gate.sh
# 环境：SHUX_F04_CRYPTO_V19_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F04_CRYPTO_V19_FAIL:-0}
DOC="analysis/phase-f-f04-v19.md"
ED25519="std/crypto/ed25519.x"
GLUE="compiler/seeds/runtime_ed25519_ref10_glue.from_x.c"
INC_GLUE="compiler/seeds/runtime_crypto_inc_glue.from_x.c"

# shellcheck source=tests/lib/std-crypto.sh
. tests/lib/std-crypto.sh

die() {
  echo "f04-crypto-v19 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-04 v19: std.crypto ed25519.inc.c → ed25519.x ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v19' "$DOC" || die "doc missing F-04 v19 marker"
[ ! -f std/crypto/ed25519.inc.c ] || die "ed25519.inc.c should be deleted"
[ -f "$ED25519" ] || die "missing ed25519.x"
[ -f "$GLUE" ] || die "missing ed25519_ref10_glue.c"
grep -q 'crypto_ed25519_sign_c' "$ED25519" || die "ed25519.x missing sign"
grep -q 'crypto_ed25519_smoke_c' "$ED25519" || die "ed25519.x missing smoke"
grep -q 'crypto/ed25519/fe.inc' "$GLUE" || die "ref10 glue missing fe.inc include"
grep -q 'ed25519.x' compiler/Makefile || die "Makefile missing ed25519.x build"
grep -q 'runtime_ed25519_ref10_glue' compiler/Makefile || die "Makefile missing runtime_ed25519_ref10_glue"
grep -q 'runtime_crypto_inc_glue' compiler/Makefile || die "Makefile missing runtime_crypto_inc_glue"
if grep -q 'ed25519.inc.c' "$INC_GLUE" 2>/dev/null; then
  die "crypto_inc_glue still includes ed25519.inc.c"
fi
[ ! -f std/crypto/crypto_inc_glue.c ] || die "std crypto_inc_glue.c should be deleted (F-ZC)"
[ ! -f std/crypto/ed25519_ref10_glue.c ] || die "std ed25519_ref10_glue.c should be deleted (F-ZC)"

MANIFEST="tests/baseline/f04-std-crypto-v19.tsv"
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
      file)
        [ -f "$anchor" ] || die "manifest missing file $anchor"
        ;;
    esac
  done < "$MANIFEST"
fi

make -C compiler ../std/crypto/crypto.o runtime_ed25519_ref10_glue.o runtime_crypto_inc_glue.o >/dev/null 2>&1 || die "make crypto.o failed"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
if std_crypto_o_has_x_symbols std/crypto/crypto.o; then
  if nm std/crypto/crypto.o 2>/dev/null | grep -qE ' crypto_ed25519_smoke_c$'; then
    cat >"$TMP/ed25519_smoke_main.c" <<'EOF'
#include <stdint.h>
extern int32_t crypto_ed25519_smoke_c(void);
int main(void) { return crypto_ed25519_smoke_c() != 0 ? 1 : 0; }
EOF
    if ! cc -std=c11 -O1 -o "$TMP/ed25519_smoke" "$TMP/ed25519_smoke_main.c" $(std_crypto_c_link_objs) 2>/dev/null; then
      die "ed25519 C smoke compile failed"
    fi
    "$TMP/ed25519_smoke" || die "ed25519 C smoke run failed"
    echo "f04 crypto ed25519 smoke OK"
  else
    echo "f04 crypto ed25519 smoke SKIP (crypto.o missing ed25519 .x symbols)"
  fi
else
  echo "f04 crypto ed25519 smoke SKIP (crypto.o missing .x symbols; need shux-c)"
fi

if [ -f tests/run-std-crypto-ed25519-gate.sh ]; then
  echo "=== F-04 v19: delegate ed25519 gate ==="
  chmod +x tests/run-std-crypto-ed25519-gate.sh
  if ! tests/run-std-crypto-ed25519-gate.sh; then
    die "run-std-crypto-ed25519-gate failed"
  fi
fi

echo "f04 std.crypto v19 gate OK (F-04 v19)"
