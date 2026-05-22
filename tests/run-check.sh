#!/usr/bin/env bash
# shu check：仅 parse+typeck，不链接；合法通过、非法拒绝。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler bootstrap-driver-seed
SHU=${SHU:-./compiler/shu}

# 负例须走 .su pipeline typeck（shu-su）；C 前端 shu-c 对 return 操作数类型仍较宽松。
NEG_SHU="$SHU"
if [ -x ./compiler/shu-su ]; then
  NEG_SHU=./compiler/shu-su
elif [ "${SHU##*/}" = "shu-c" ]; then
  make -C compiler bootstrap-driver-seed -q 2>/dev/null || make -C compiler bootstrap-driver-seed
  [ -x ./compiler/shu-su ] && NEG_SHU=./compiler/shu-su
fi

# 合法：return-value 主程序
$SHU check tests/return-value/main.su 2>&1 | grep -q "check OK"
echo "check OK: return-value"

# 合法：含 import（多模块 core/std）
$SHU check -L . tests/stdlib-import/main.su 2>&1 | grep -q "check OK"
echo "check OK: import"

# 非法：typeck 应失败（优先 shu-su/.su pipeline）
if $NEG_SHU check tests/typeck/return_operand_type_mismatch.su 2>&1; then
  echo "expected check to fail on type mismatch"
  exit 1
fi
echo "check reject type error OK"

echo "check test OK"
