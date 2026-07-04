#!/usr/bin/env bash
# shux check（deno check 语义）：合法静默通过；非法打印 path:line:col - error: 并 exit 1。
set -e
cd "$(dirname "$0")/.."
SHUX=${SHUX:-./compiler/shux}
# run-all 默认 C 流水线：fmt/check 用 shux-c（seed 对部分 fmt 产物 check 仍不完整）。
if [ -n "${RUN_ALL_USE_C:-}" ] && [ -x ./compiler/shux-c ]; then
  SHUX=./compiler/shux-c
elif [ -n "${SHUX_RUN_ALL_BOOTSTRAP_SHUX:-}" ] && [ -x ./compiler/shux-c ]; then
  # bootstrap run-all-bstrict：shux_asm 的 check 会打印 parse OK/typeck OK；与 -o 一致走 shux-c 静默 check。
  case "$(basename "${SHUX:-./compiler/shux}")" in
    shux|shux_asm) SHUX=./compiler/shux-c ;;
    *)
      case "$(uname -m 2>/dev/null)" in
        x86_64|amd64) ;;
        *) SHUX=./compiler/shux-c ;;
      esac
      ;;
  esac
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
echo "$neg_out" | grep -qE " - error: |typeck error:|check failed" || {
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
