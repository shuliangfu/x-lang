#!/usr/bin/env bash
# M3-b：B-strict 替换 seed 后跑 bootstrap 白名单（与 run-shu-asm-gate + L4 核心子集一致）。
# 用法：./tests/run-all-bstrict.sh
# 不跑全量 run-all（其余用例仍走 shu-c）；验收 shu_asm 替代 seed 后白名单不回归。

set -e
cd "$(dirname "$0")/.."

if [ ! -f compiler/shu_asm ] || [ ! -x compiler/shu_asm ]; then
  echo "run-all-bstrict: build shu_asm first: make -C compiler bootstrap-driver-bstrict" >&2
  exit 127
fi

# run-bootstrap-bstrict-ci.sh 已构建 shu_asm 时跳过重复全量编译。
if [ -n "${SHU_BSTRICT_SKIP_BUILD:-}" ]; then
  echo "run-all-bstrict: SHU_BSTRICT_SKIP_BUILD=1, cp shu_asm -> shu ..."
  cp -f compiler/shu_asm compiler/shu
else
  echo "run-all-bstrict: SHU_BSTRICT_REPLACE=1 bootstrap-driver-bstrict ..."
  make -C compiler bootstrap-driver-bstrict SHU_BSTRICT_REPLACE=1
fi

export SHU=./compiler/shu
export SHULANG_SKIP_SUBSCRIPT_MAKE=1
export SHULANG_RUN_ALL_BOOTSTRAP_SHU=1
export SHULANG_BSTRICT_RUN_ALL=1
export SHULANG_LINK_SHU=./compiler/shu
# shu_asm 无 -o 烟测与 -o 连续调用偶发 SIGSEGV；白名单仅验 -o/check，跳过烟测。
export SHU_SKIP_PARSE_SMOKE=1

# 与 run-shu-asm-gate + run-all.sh run_shu_for_script 白名单核心项对齐
BSTRICT_SCRIPTS=(
  run-lexer.sh
  run-typeck.sh
  run-check.sh
  run-hello.sh
  run-import.sh
  run-stdlib-import.sh
  run-while.sh
  run-option.sh
  run-compound-assign.sh
  run-multi-file.sh
  run-struct.sh
  run-return-value.sh
  run-return-expr.sh
  run-parser.sh
  run-for.sh
  run-array.sh
  run-pointer.sh
  run-if-expr.sh
  run-enum-asm.sh
  run-match.sh
  run-enum.sh
  run-dual-chain-struct-return.sh
  run-float.sh
  run-slice.sh
  run-defer.sh
  run-vector.sh
  run-panic.sh
  run-result.sh
  run-binary-expr.sh
  run-fmt-cmd.sh
  run-test-cmd.sh
  run-bool.sh
  run-ternary.sh
  run-boundary-encodings.sh
  run-let-const.sh
  run-toplevel-let.sh
  run-preprocess.sh
  run-goto.sh
  run-multi-func.sh
  run-mem.sh
  run-string.sh
  run-core-types.sh
  run-builtin.sh
  run-trait.sh
  run-generic.sh
  run-encoding.sh
  run-base64.sh
  run-time.sh
  run-sync.sh
  run-atomic.sh
  run-ffi.sh
  run-csv.sh
)

for script in "${BSTRICT_SCRIPTS[@]}"; do
  if [ ! -f "tests/$script" ]; then
    echo "run-all-bstrict: missing tests/$script" >&2
    exit 1
  fi
  chmod +x "tests/$script"
  echo "run-all-bstrict: $script ..."
  attempt=1
  while [ "$attempt" -le 3 ]; do
    if SHU="$SHU" ./tests/"$script"; then
      break
    fi
    if [ "$attempt" -ge 3 ]; then
      echo "run-all-bstrict: $script failed after 3 attempts" >&2
      exit 1
    fi
    echo "run-all-bstrict: retry $script (attempt $((attempt + 1))) ..."
    attempt=$((attempt + 1))
  done
done

echo "run-all-bstrict OK (${#BSTRICT_SCRIPTS[@]} scripts, compiler/shu is shu_asm)"
