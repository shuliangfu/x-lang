#!/usr/bin/env bash
# 文件职责：验证 f32/f64 类型与浮点字面量；含边界与负向测试。
# 依赖：compiler/shux，tests/float/*.x

set -e
cd "$(dirname "$0")/.."
if [ -z "${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler
fi
SHUX=${SHUX:-./compiler/shux}
if [ -n "${SHUX_RUN_ALL_BOOTSTRAP_SHUX:-}" ] && [ -x ./compiler/shux_asm2 ]; then
  SHUX=./compiler/shux_asm2
elif [ -n "${SHUX_RUN_ALL_BOOTSTRAP_SHUX:-}" ] && [ -x ./compiler/shux_asm ]; then
  SHUX=./compiler/shux_asm
fi

# 正例：基础 f32/f64、0.0、整字面量 0
$SHUX tests/float/f32_f64.x -o /tmp/shux_float 2>&1
exitcode=0; /tmp/shux_float >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected 0 (f32_f64), got $exitcode"; exit 1; }

# 正例：科学计数法、.5
$SHUX tests/float/scientific_and_dot.x -o /tmp/shux_float2 2>&1
exitcode=0; /tmp/shux_float2 >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected 0 (scientific_and_dot), got $exitcode"; exit 1; }

# 正例：边界 0.0、const 1e2、.25
$SHUX tests/float/boundary.x -o /tmp/shux_float_boundary 2>&1
exitcode=0; /tmp/shux_float_boundary >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected 0 (boundary), got $exitcode"; exit 1; }

# 负例：f32 初值为 none 应 typeck 失败（typeck.x 允许 let x: f32 = 1 整型隐式转换）
if $SHUX check tests/float/init_invalid.x 2>&1 | grep -qE "typeck|pipeline failed|cannot|mismatch|invalid"; then
  : # 预期报错，通过
else
  echo "expected typeck error for f32 = none"
  exit 1
fi

# 回归：f32 = 1 整型字面量在 typeck.x 可绿（旧负例 init_non_zero_int.x 已弃用）
$SHUX check tests/float/init_non_zero_int.x >/dev/null 2>&1 || {
  echo "expected typeck OK for f32 = 1 (int coercion)"
  exit 1
}

echo "float test OK"
