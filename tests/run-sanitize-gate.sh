#!/usr/bin/env bash
# M-6 门禁：`-fsanitize=address` 强制 INDEX 边界插桩（release 默认无额外检查）。
#
# 用法：
#   ./tests/run-sanitize-gate.sh
#   SHU=./compiler/shu-c ./tests/run-sanitize-gate.sh
set -e
cd "$(dirname "$0")/.."

SHU_BIN="${SHU:-}"
if [ -z "$SHU_BIN" ]; then
  if [ -x ./compiler/shu-c ]; then
    SHU_BIN=./compiler/shu-c
  elif [ -x ./compiler/shu ]; then
    SHU_BIN=./compiler/shu
  else
    make -C compiler -q 2>/dev/null || make -C compiler
    SHU_BIN=./compiler/shu-c
  fi
fi

SRC="tests/sanitize/bounds_literal_ok.su"
OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"
NORM_OUT="$OUT_DIR/shu_sanitize_norm.c"
SAN_OUT="$OUT_DIR/shu_sanitize_asan.c"
rm -f "$NORM_OUT" "$SAN_OUT"

echo "=== M-6: sanitize=address bounds instrumentation ==="

if ! "$SHU_BIN" check "$SRC" >/dev/null 2>&1; then
  echo "sanitize gate FAIL: typeck $SRC" >&2
  exit 1
fi

"$SHU_BIN" -E "$SRC" >"$NORM_OUT" 2>/dev/null
"$SHU_BIN" -fsanitize=address -E "$SRC" >"$SAN_OUT" 2>/dev/null

bounds_guard_re='>= [0-9]+ \? \(shulang_panic_'

if grep -qE "$bounds_guard_re" "$NORM_OUT" 2>/dev/null; then
  echo "sanitize gate FAIL: default -E should skip bounds for proven literal index" >&2
  exit 1
fi
echo "sanitize: default emit no extra bounds OK"

if ! grep -qE "$bounds_guard_re" "$SAN_OUT" 2>/dev/null; then
  echo "sanitize gate FAIL: -fsanitize=address -E missing INDEX bounds guard" >&2
  exit 1
fi
echo "sanitize: -fsanitize=address emit bounds OK"

# OOB 仍 panic（与 run-ub.sh 一致）
UB_OUT="$OUT_DIR/shu_sanitize_oob"
rm -f "$UB_OUT"
if ! "$SHU_BIN" -fsanitize=address tests/ub/bounds_array.su -o "$UB_OUT" 2>/dev/null; then
  echo "sanitize gate FAIL: compile bounds_array.su" >&2
  exit 1
fi
RC=0
"$UB_OUT" 2>/dev/null || RC=$?
if [ "$RC" -eq 134 ] || [ "$RC" -ne 0 ]; then
  echo "sanitize: bounds_array OOB panic OK (rc=$RC)"
else
  echo "sanitize gate FAIL: bounds_array expected panic, rc=$RC" >&2
  exit 1
fi

echo "sanitize gate OK"
