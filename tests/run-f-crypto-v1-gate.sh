#!/usr/bin/env bash
# F-crypto v1：std.crypto 纳入 F 聚合 batch（F-04 v16～v21 已闭合）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_CRYPTO_V1_FAIL:-0}
DOC="analysis/phase-f-crypto-v1.md"
MANIFEST="tests/baseline/f-crypto-v1-closure.tsv"
die() { echo "f-crypto-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-crypto v1: F-04 closure → F batch ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-crypto v1' "$DOC" || die "doc marker"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/crypto/crypto.o >/dev/null 2>&1 || die "make crypto.o failed"
else
  echo "f-crypto-v1 SKIP crypto.o build (no shux-c)" >&2
fi
chmod +x tests/run-f04-std-crypto-closure-gate.sh
SHUX_F04_CRYPTO_CLOSURE_FAIL="$FAIL" tests/run-f04-std-crypto-closure-gate.sh || die "f04 closure failed"
for sub in run-std-crypto-aes-gcm-gate.sh run-std-crypto-chacha20-poly1305-gate.sh \
  run-std-crypto-ed25519-gate.sh run-std-crypto-sha512-hmac-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-crypto-v1 gate OK"
