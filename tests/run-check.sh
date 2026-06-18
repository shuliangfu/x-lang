#!/usr/bin/env bash
# shu check（deno check 语义）：合法静默通过；非法打印 path:line:col - error: 并 exit 1。
set -e
cd "$(dirname "$0")/.."
./tests/run-comment-prefix.sh
chmod +x tests/run-fmt-wrap.sh 2>/dev/null || true
./tests/run-fmt-wrap.sh
if [ -z "${SHULANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler bootstrap-driver-seed
fi
SHU=${SHU:-./compiler/shu}
ROOT=$(pwd)
case "$SHU" in
  /*) SHU_EXE="$SHU" ;;
  *) SHU_EXE="$ROOT/$SHU" ;;
esac

# 无参：在子目录内递归 check（与 fmt 一致，不应要求显式路径）
(
  cd tests/return-value
  chk_cwd=$("$SHU_EXE" check main.su 2>&1)
  if [ -n "$chk_cwd" ]; then
    echo "expected silent check on main.su, got: $chk_cwd"
    exit 1
  fi
)
echo "check OK: cwd (no path arg)"

# 合法：成功时无输出（deno check）
chk_out=$($SHU check tests/return-value/main.su 2>&1)
if [ -n "$chk_out" ]; then
  echo "expected silent check success, got: $chk_out"
  exit 1
fi
echo "check OK: return-value (silent)"

# 合法：含 import
chk_out2=$($SHU check -L . tests/stdlib-import/main.su 2>&1)
if [ -n "$chk_out2" ]; then
  echo "expected silent check success with import, got: $chk_out2"
  exit 1
fi
echo "check OK: import (silent)"

# 非法：typeck 应失败并带诊断行
neg_out=$($SHU check tests/typeck/return_operand_type_mismatch.su 2>&1) && {
  echo "expected check to fail on type mismatch"
  exit 1
}
echo "$neg_out" | grep -qE " - error: |typeck error:|check failed" || {
  echo "expected type error diagnostic, got: $neg_out"
  exit 1
}
echo "check reject type error OK"

chmod +x tests/run-types-gate.sh 2>/dev/null || true
./tests/run-types-gate.sh

echo "check test OK"
