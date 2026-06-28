#!/usr/bin/env bash
# F-04 v21：std.crypto 模块闭合门禁（v16～v19 聚合 + manifest）。
#
# 用法：./tests/run-f04-std-crypto-closure-gate.sh
# 环境：SHUX_F04_CRYPTO_CLOSURE_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F04_CRYPTO_CLOSURE_FAIL:-0}
DOC="analysis/phase-f-f04-v21-closure.md"
MANIFEST="tests/baseline/f04-std-crypto-closure.tsv"

die() {
  echo "f04-crypto-closure gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-04 v21: std.crypto module closure ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v21' "$DOC" || die "doc missing F-04 v21 marker"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"

while IFS=$'\t' read -r item_id kind anchor _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|script|manifest)
      [ -f "$anchor" ] || die "missing $anchor ($item_id)"
      ;;
    absent)
      [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)"
      ;;
  esac
done < "$MANIFEST"

grep -q 'core.sx' compiler/Makefile || die "Makefile missing core.sx"
grep -q 'ed25519.sx' compiler/Makefile || die "Makefile missing ed25519.sx"
if grep -q 'std/crypto/crypto\.c' compiler/Makefile 2>/dev/null; then
  die "Makefile still references std/crypto/crypto.c"
fi
if grep -q 'aes_gcm\.inc\.c' compiler/Makefile 2>/dev/null; then
  die "Makefile still references aes_gcm.inc.c"
fi

make -C compiler ../std/crypto/crypto.o >/dev/null 2>&1 || die "make crypto.o failed"

for sub in run-f04-std-crypto-v16-gate.sh run-f04-std-crypto-v17-gate.sh \
  run-f04-std-crypto-v18-gate.sh run-f04-std-crypto-v19-gate.sh; do
  if [ -f "tests/$sub" ]; then
    echo "=== F-04 v21: delegate $sub ==="
    chmod +x "tests/$sub"
    case "$sub" in
      *v16*) env_var=SHUX_F04_CRYPTO_V16_FAIL ;;
      *v17*) env_var=SHUX_F04_CRYPTO_V17_FAIL ;;
      *v18*) env_var=SHUX_F04_CRYPTO_V18_FAIL ;;
      *v19*) env_var=SHUX_F04_CRYPTO_V19_FAIL ;;
      *) env_var=SHUX_F04_CRYPTO_CLOSURE_FAIL ;;
    esac
    if ! env "$env_var=$FAIL" "tests/$sub"; then
      die "$sub failed"
    fi
  fi
done

if [ -f tests/run-std-crypto-gate.sh ]; then
  echo "=== F-04 v21: delegate run-std-crypto-gate (manifest) ==="
  chmod +x tests/run-std-crypto-gate.sh
  if ! SHUX_STD_CRYPTO_MANIFEST_ONLY=1 tests/run-std-crypto-gate.sh; then
    die "run-std-crypto-gate failed"
  fi
fi

echo "f04 std.crypto closure gate OK (F-04 v21)"
