#!/usr/bin/env bash
# 侧车 grow 池 / 动态上限边界：超过旧硬顶（16 形参、96 stmt、256 函数、32 #if 深度等）。
# 由 run-all.sh 调用；C 与 SU 路径均应通过。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHU=${SHU:-./compiler/shu}
TMPDIR=${TMPDIR:-/tmp}
GEN_DIR="$TMPDIR/shu_pool_limits_gen"
mkdir -p "$GEN_DIR"

run_expect_exit() {
  local src="$1" expect="$2" label="$3"
  $SHU "$src" -o "$GEN_DIR/out_${label}" 2>&1
  local ec=0
  "$GEN_DIR/out_${label}" >/dev/null 2>&1 || ec=$?
  if [ "$ec" -ne "$expect" ]; then
    echo "pool-limits $label: expected exit $expect, got $ec"
    exit 1
  fi
}

# 静态用例：20 形参、20 struct 字段、6 层嵌套 loop
run_expect_exit tests/pool-limits/many_params.su 19 many_params
run_expect_exit tests/pool-limits/many_fields.su 19 many_fields
run_expect_exit tests/pool-limits/nested_loops.su 6 nested_loops
run_expect_exit tests/pool-limits/nested_loops_8.su 8 nested_loops_8
run_expect_exit tests/pool-limits/many_call_args.su 64 many_call_args
run_expect_exit tests/pool-limits/many_import_select.su 9 many_import_select

# 30 局部变量（旧 AsmFuncCtx locals[24] 硬顶）
gen_many_locals() {
  echo "// generated: many_locals"
  echo "function main(): i32 {"
  local i=0
  while [ "$i" -lt 30 ]; do
    echo "  let v${i}: i32 = ${i};"
    i=$((i + 1))
  done
  echo "  return v29;"
  echo "}"
}
gen_many_locals > "$GEN_DIR/many_locals.su"
run_expect_exit "$GEN_DIR/many_locals.su" 29 many_locals

# 100 条 block stmt（旧 stmt_order 96 硬顶）
gen_many_block_stmts() {
  echo "// generated: many_block_stmts"
  echo "function main(): i32 {"
  local i=0
  while [ "$i" -lt 100 ]; do
    echo "  let s${i}: i32 = ${i};"
    i=$((i + 1))
  done
  echo "  return s99;"
  echo "}"
}
gen_many_block_stmts > "$GEN_DIR/many_block_stmts.su"
run_expect_exit "$GEN_DIR/many_block_stmts.su" 99 many_block_stmts

# 260 个顶层函数（旧 module func 256 硬顶）
# fn259 固定返回 42：进程 exit code 仅 0–255，若 return 259 会被截成 3 造成误报。
gen_many_funcs() {
  echo "// generated: many_funcs (260); fn259 returns 42 (exit code is u8)"
  local i=258
  while [ "$i" -ge 0 ]; do
    echo "function fn${i}(): i32 { return ${i}; }"
    i=$((i - 1))
  done
  echo "function fn259(): i32 { return 42; }"
  echo "function main(): i32 { return fn259(); }"
}
gen_many_funcs > "$GEN_DIR/many_funcs.su"
run_expect_exit "$GEN_DIR/many_funcs.su" 42 many_funcs

# #if 嵌套 40 层（旧 preprocess stack[32] 硬顶）
DEPTH=40
gen_deep_if() {
  echo "// generated: deep_if_nest depth=$DEPTH"
  local i=1
  while [ "$i" -le "$DEPTH" ]; do
    echo "#if L${i}"
    i=$((i + 1))
  done
  echo "function main(): i32 { return 40; }"
  i=$DEPTH
  while [ "$i" -ge 1 ]; do
    echo "#endif"
    i=$((i - 1))
  done
}
gen_deep_if > "$GEN_DIR/deep_if_nest.su"
DEFS=""
i=1
while [ "$i" -le "$DEPTH" ]; do
  DEFS="$DEFS -DL${i}"
  i=$((i + 1))
done
# shellcheck disable=SC2086
$SHU $DEFS "$GEN_DIR/deep_if_nest.su" -o "$GEN_DIR/out_deep_if" 2>&1
ec=0
"$GEN_DIR/out_deep_if" >/dev/null 2>&1 || ec=$?
if [ "$ec" -ne 40 ]; then
  echo "pool-limits deep_if_nest: expected exit 40, got $ec"
  exit 1
fi

echo "pool-limits test OK"
