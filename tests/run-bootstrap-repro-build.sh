#!/usr/bin/env bash
# BOOT-003 辅助：仅构建 bootstrap-driver-bstrict（供 run-bootstrap-repro.sh 调用）
#
# 用法：./tests/run-bootstrap-repro-build.sh
set -e
cd "$(dirname "$0")/.."

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || ulimit -s 16384 2>/dev/null || true

if [ ! -f compiler/shu ] || [ ! -x compiler/shu ]; then
  echo "bootstrap-repro-build: seed shu missing; run: make -C compiler OPT=1 all" >&2
  exit 127
fi

# 与 run-bootstrap-bstrict-ci.sh 一致：保留 seed 作 asm-73 回退。
if [ -x compiler/shu-su ]; then
  cp -f compiler/shu-su compiler/shu_asm73_seed
elif [ -x compiler/shu ]; then
  cp -f compiler/shu compiler/shu_asm73_seed
fi
export ASM73_FALLBACK_SHU=./compiler/shu_asm73_seed

if [ -n "${CI:-}" ] && [ "$(uname -s 2>/dev/null)" = "Linux" ]; then
  export SHU_ASM_CI_SKIP_FAST=1
  export SHU_ASM_SKIP_STRICT_SMOKE=1
fi

echo "bootstrap-repro-build: make bootstrap-driver-bstrict ..."
make -C compiler bootstrap-driver-bstrict 2>&1 | tee /tmp/bootstrap_repro_build.log

if ! grep -qE 'Target-B-strict|B-strict OK|LINK_MODE=asm_only_strict' /tmp/bootstrap_repro_build.log; then
  echo "bootstrap-repro-build FAIL: expected B-strict markers in log" >&2
  exit 1
fi
if [ ! -x compiler/shu_asm ]; then
  echo "bootstrap-repro-build FAIL: compiler/shu_asm not built" >&2
  exit 1
fi
echo "bootstrap-repro-build OK"
