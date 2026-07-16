#!/usr/bin/env bash
# shux check（deno check 语义）：合法静默通过；非法打印 path:line:col - error: 并 exit 1。
set -e
cd "$(dirname "$0")/.."
SHUX=${SHUX:-./compiler/shux}
# run-all 默认 C 流水线：仅 RUN_ALL_USE_C 显式要求时改绑 shux-c。
# 旧逻辑在 SHUX_RUN_ALL_BOOTSTRAP_SHUX 下把 shux/shux_asm 改成 pin shux-c：
# 冷 L2 后 shux-c 常为 seed 拷贝，对 fmt 产物 CHK001，而产品 shux_asm check 已静默绿。
if [ -n "${RUN_ALL_USE_C:-}" ] && [ -x ./compiler/shux-c ]; then
  SHUX=./compiler/shux-c
fi
export SHUX
./tests/run-comment-prefix.sh
chmod +x tests/run-fmt-wrap.sh 2>/dev/null || true
./tests/run-fmt-wrap.sh
if [ -z "${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler bootstrap-driver-seed
fi
ROOT=$(pwd)
case "$SHUX" in
  /*) SHUX_EXE="$SHUX" ;;
  *) SHUX_EXE="$ROOT/$SHUX" ;;
esac

# 无参：在子目录内递归 check（与 fmt 一致，不应要求显式路径）
(
  cd tests/return-value
  chk_cwd=$("$SHUX_EXE" check main.x 2>&1)
  if [ -n "$chk_cwd" ]; then
    echo "expected silent check on main.x, got: $chk_cwd"
    exit 1
  fi
)
echo "check OK: cwd (no path arg)"

# 合法：成功时无输出（deno check）
chk_out=$($SHUX check tests/return-value/main.x 2>&1)
if [ -n "$chk_out" ]; then
  echo "expected silent check success, got: $chk_out"
  exit 1
fi
echo "check OK: return-value (silent)"

# 合法：含 import
chk_out2=$($SHUX check -L . tests/stdlib-import/main.x 2>&1)
if [ -n "$chk_out2" ]; then
  echo "expected silent check success with import, got: $chk_out2"
  exit 1
fi
echo "check OK: import (silent)"

# 非法：typeck 应失败并带诊断行
neg_out=$($SHUX check tests/typeck/return_operand_type_mismatch.x 2>&1) && {
  echo "expected check to fail on type mismatch"
  exit 1
}
echo "$neg_out" | grep -qE " - error: |typeck error:|check failed|error\[[A-Z][0-9]+\]:" || {
  echo "expected type error diagnostic, got: $neg_out"
  exit 1
}
echo "check reject type error OK"

chmod +x tests/run-types-gate.sh 2>/dev/null || true
if [ -n "${SHUX_BOOTSTRAP_MIN:-}" ]; then
  echo "check: skip run-types-gate link (bootstrap-min; gold/W3 覆盖)"
else
  _types_gate_shux="${SHUX_LINK_SHUX:-./compiler/shux-c}"
  [ -x "$_types_gate_shux" ] || _types_gate_shux="$SHUX"
  SHUX="$_types_gate_shux" ./tests/run-types-gate.sh
fi

echo "check test OK"
