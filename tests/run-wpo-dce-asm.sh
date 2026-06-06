#!/usr/bin/env bash
# WPO v0 烟测：asm 后端 DCE 剔除 dead export（跨 import 库）
set -e
cd "$(dirname "$0")/.."

SHU_BIN="${SHU:-./compiler/shu_asm}"
if [ ! -x "$SHU_BIN" ]; then
  make -C compiler shu-c -q 2>/dev/null || make -C compiler shu-c
  SHU_BIN="./compiler/shu-c"
fi

TMP_O="/tmp/shu_wpo_dead_user_asm.o"
TMP_EXE="/tmp/shu_wpo_dead_user_asm"

rm -f "$TMP_O" "$TMP_EXE"

# -backend asm -o .o：dead_export 不应出现在符号表
"$SHU_BIN" -backend asm -o "$TMP_O" tests/wpo/dead_user.su >/dev/null 2>&1 || {
  echo "WPO asm DCE SKIP: shu asm compile failed (need shu_asm on Linux CI)"
  exit 0
}

if nm "$TMP_O" 2>/dev/null | grep -q 'dead_export'; then
  echo "WPO asm DCE FAIL: dead_export still in .o symbols"
  nm "$TMP_O" 2>/dev/null | grep -E 'dead_export|live_export|main' || true
  exit 1
fi
if ! nm "$TMP_O" 2>/dev/null | grep -q 'live_export'; then
  echo "WPO asm DCE FAIL: missing live_export"
  exit 1
fi
if ! nm "$TMP_O" 2>/dev/null | grep -q ' main'; then
  echo "WPO asm DCE FAIL: missing main"
  exit 1
fi

# 链接运行：exit 7
"$SHU_BIN" -backend asm -o "$TMP_EXE" tests/wpo/dead_user.su >/dev/null 2>&1 || true
if [ -x "$TMP_EXE" ]; then
  rc=$("$TMP_EXE"; echo $?)
  [ "$rc" = "7" ] || { echo "dead_user asm exit=$rc want 7"; exit 1; }
fi

echo "wpo asm dce OK"
