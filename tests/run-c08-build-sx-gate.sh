#!/usr/bin/env bash
# C-08 v1：根 build.sx 构建策略 + build_tool / build_runtime 登记。
#
# 用法：./tests/run-c08-build-sx-gate.sh
set -e
cd "$(dirname "$0")/.."

echo "=== C-08: build.sx policy ==="
for f in build.sx analysis/phase-c-c08-v1.md; do
  [ -f "$f" ] || { echo "c08 build-sx FAIL: missing $f" >&2; exit 1; }
done
grep -q 'build_use_asm_only' build.sx || { echo "c08 build-sx FAIL: build.sx missing build_use_asm_only" >&2; exit 1; }
grep -q 'build_tool' build.sx || { echo "c08 build-sx FAIL: build.sx missing build_tool ref" >&2; exit 1; }
[ -f compiler/src/build_runtime.c ] || { echo "c08 build-sx FAIL: missing build_runtime.c" >&2; exit 1; }
grep -q 'build-tool' compiler/Makefile || { echo "c08 build-sx FAIL: Makefile missing build-tool target" >&2; exit 1; }
echo "c08 build-sx gate OK"
