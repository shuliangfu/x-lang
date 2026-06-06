#!/usr/bin/env bash
# WPO-S3 跨模块 asm 二分：隔离 import 路径 fault（需 Linux shu_asm）
# 用法：SHU=./compiler/shu_asm ./tests/run-wpo-s3-cross-bisect.sh
# 含 import 的 .su 须在 shu_asm -backend asm -o 下产出非空 .o（修复前 typeck_entry SIGSEGV）。
set -e
cd "$(dirname "$0")/.."

SHU_BIN="${SHU:-./compiler/shu_asm}"
if [ ! -x "$SHU_BIN" ]; then
  echo "wpo-s3 cross bisect SKIP (need $SHU_BIN)"
  exit 0
fi

# 编译 .o；fault 时失败
wpo_s3_try_asm_o() {
  local label="$1"
  local su="$2"
  local out="/tmp/shu_wpo_s3_${label}.o"
  rm -f "$out"
  set +e
  "$SHU_BIN" -backend asm -o "$out" "$su" 2>/tmp/shu_wpo_s3_${label}.log
  local brc=$?
  set -e
  if [ "$brc" -ne 0 ] || [ ! -f "$out" ]; then
    echo "wpo-s3 cross bisect FAIL: $label .o compile (rc=$brc)" >&2
    tail -5 "/tmp/shu_wpo_s3_${label}.log" 2>/dev/null || true
    return 1
  fi
  echo "wpo-s3 cross bisect OK: $label .o"
}

echo "=== WPO-S3 cross-module asm bisect ($SHU_BIN) ==="
wpo_s3_try_asm_o smoke tests/wpo/stack_promote_smoke.su
wpo_s3_try_asm_o dead_user tests/wpo/dead_user.su
wpo_s3_try_asm_o cross_i32 tests/wpo/stack_promote_cross_i32.su
wpo_s3_try_asm_o cross_ret tests/wpo/stack_promote_cross_ret.su
wpo_s3_try_asm_o escape_cross tests/wpo/stack_promote_escape_cross.su
wpo_s3_try_asm_o cross_full tests/wpo/stack_promote_cross.su
echo "wpo-s3 cross bisect OK (import asm .o compile)"
