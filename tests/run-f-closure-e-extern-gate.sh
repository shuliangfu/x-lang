#!/usr/bin/env bash
# F 闭合：std 模块 -E-extern + cc -c 批量门禁
#
# 遍历所有 std/**/mod.x，用 shux-c -E-extern 生成瘦 C，再用 cc -c 编译。
# 分类：OK / FAIL_SHUXC（shux-c 生成失败）/ FAIL_CC（cc 编译失败）
# 用法：./tests/run-f-closure-e-extern-gate.sh
# 环境：SHUX_F_CLOSURE_FAIL=1 失败时硬退出
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/compiler"

FAIL=${SHUX_F_CLOSURE_FAIL:-0}
SHUX="${SHUX:-./shux-c}"
[ -x "$SHUX" ] || SHUX="./shux"
[ -x "$SHUX" ] || { echo "f-closure-e-extern-gate: SKIP (no shux-c/shux)"; exit 0; }

# 只看 error，抑制 warning（-E-extern 生成的 C 有大量 extern 前向声明 warning）
CFLAGS="-I.. -I. -Iinclude -Isrc -Wno-unused-variable -Wno-unused-parameter -Wno-unused-function -Wno-parentheses -Wno-sign-compare -Wno-ignored-qualifiers -Wno-unused-but-set-variable -Wno-type-limits -Wno-visibility -Wno-incompatible-pointer-types -Wno-incompatible-pointer-types-discards-qualifiers"
if cc -v 2>&1 | grep -q clang; then
  CFLAGS="$CFLAGS -Wno-logical-op-parentheses -Wno-bitwise-op-parentheses"
fi

OK=0; FAIL_SHUXC=0; FAIL_CC=0
OK_LIST=""; SHUXC_LIST=""; CC_LIST=""

# 收集所有 std/**/mod.x（跳过 compress 子模块的独立 mod.x，只测顶层 + compress/mod.x）
mods=$(find ../std -name "mod.x" -type f | LC_ALL=C sort)

for m in $mods; do
  mod_name=$(echo "$m" | sed 's|../std/||; s|/mod.x||')
  gen="/tmp/shux_f_closure_$$.${mod_name//\//_}.c"
  obj="/tmp/shux_f_closure_$$.${mod_name//\//_}.o"
  rm -f "$gen" "$obj" 2>/dev/null || true

  # shux-c -E-extern 生成 C
  if ! "$SHUX" -E-extern -L .. "$m" >"$gen" 2>/tmp/shux_f_closure_$$.shuxc.log; then
    FAIL_SHUXC=$((FAIL_SHUXC+1))
    SHUXC_LIST="$SHUXC_LIST $mod_name"
    rm -f "$gen" 2>/dev/null || true
    continue
  fi

  # cc -c 编译
  if ! cc $CFLAGS -c "$gen" -o "$obj" 2>/tmp/shux_f_closure_$$.cc.log; then
    FAIL_CC=$((FAIL_CC+1))
    CC_LIST="$CC_LIST $mod_name"
    # 记录首个 error 便于诊断
    err=$(grep -m1 'error:' /tmp/shux_f_closure_$$.cc.log 2>/dev/null | head -1 || true)
    [ -n "$err" ] && CC_LIST="$CC_LIST($err)" || CC_LIST="$CC_LIST(no_error_line)"
    rm -f "$gen" "$obj" 2>/dev/null || true
    continue
  fi

  OK=$((OK+1))
  OK_LIST="$OK_LIST $mod_name"
  rm -f "$gen" "$obj" 2>/dev/null || true
done

rm -f /tmp/shux_f_closure_$$.*.log 2>/dev/null || true

echo "=== F closure -E-extern gate ==="
echo "OK=$OK FAIL_CC=$FAIL_CC FAIL_SHUXC=$FAIL_SHUXC"
echo "--- OK ---"
echo "$OK_LIST" | tr ' ' '\n' | grep -v '^$' | LC_ALL=C sort | tr '\n' ' '
echo ""
echo "--- FAIL_CC ($FAIL_CC) ---"
echo "$CC_LIST" | tr ' ' '\n' | grep -v '^$' | LC_ALL=C sort
echo "--- FAIL_SHUXC ($FAIL_SHUXC) ---"
echo "$SHUXC_LIST" | tr ' ' '\n' | grep -v '^$' | LC_ALL=C sort

if [ "$FAIL_CC" -gt 0 ] || [ "$FAIL_SHUXC" -gt 0 ]; then
  echo "f-closure-e-extern-gate: FAIL (OK=$OK FAIL_CC=$FAIL_CC FAIL_SHUXC=$FAIL_SHUXC)" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
echo "f-closure-e-extern-gate: OK (all $OK modules pass -E-extern + cc -c)"
exit 0
