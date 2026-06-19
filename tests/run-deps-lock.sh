#!/usr/bin/env bash
# TOOL-008：依赖锁 replay 烟测（verify 金样 + 二次 verify 一致）。
#
# 用法：./tests/run-deps-lock.sh
set -e
cd "$(dirname "$0")/.."

PKG=tests/fixtures/pkgmgr/shux.pkg.tsv
LOCK=tests/fixtures/pkgmgr/shux.pkg.lock.tsv

chmod +x scripts/shux-deps-lock.sh scripts/shux-deps-verify.sh scripts/shux-deps-resolve.sh

./scripts/shux-deps-verify.sh "$PKG" "$LOCK"
./scripts/shux-deps-verify.sh "$PKG" "$LOCK" | tee /tmp/shux_deps_verify_1.log
grep -q 'reproducible=OK' /tmp/shux_deps_verify_1.log

TMP_LOCK="/tmp/shux_pkg_regen_$$.lock.tsv"
./scripts/shux-deps-lock.sh "$PKG" "$TMP_LOCK"
./scripts/shux-deps-verify.sh "$PKG" "$TMP_LOCK"
# 金样锁与再生锁的 locked 行 sha 须一致
if ! diff -u <(grep '^locked' "$LOCK" | sort) <(grep '^locked' "$TMP_LOCK" | sort); then
  echo "run-deps-lock FAIL: regen lock differs from golden" >&2
  rm -f "$TMP_LOCK"
  exit 1
fi
rm -f "$TMP_LOCK"

echo "deps-lock OK"
