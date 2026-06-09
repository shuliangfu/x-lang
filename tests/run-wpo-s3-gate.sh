#!/usr/bin/env bash
# WPO-S3 门禁：小 struct stack promote + struct 跨 await asm CPS（exit 10 / SHU_ASYNC_YIELD exit 0）
# 用法：./tests/run-wpo-s3-gate.sh
# 同模块 smoke：shu_asm 已内联 make_pair/sum_pair（disasm 基线）。
# 跨模块 stack_promote_cross：typeck 始终跑；asm 链默认开启（需可 exec 的 Linux shu_asm）。
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/wpo-s3-disasm.sh
. tests/lib/wpo-s3-disasm.sh

CHECK_SHU="${SHU:-}"
# shu_asm 仅在本机可 exec 时跑 disasm（Mac 上常为 Docker 产物的 Linux ELF）
SHU_ASM_BIN=""
SHU_ASM_NATIVE=0
if [ -x ./compiler/shu_asm ]; then
  SHU_ASM_BIN=./compiler/shu_asm
elif [ -x ./compiler/shu_asm.experimental ] && [ "$(uname -s)" = "Linux" ]; then
  SHU_ASM_BIN=./compiler/shu_asm.experimental
fi
if [ -n "$SHU_ASM_BIN" ]; then
  if [ "$(uname -s)" = "Linux" ]; then
    SHU_ASM_NATIVE=1
  elif [ "$(uname -s)" != "Darwin" ] && file "$SHU_ASM_BIN" 2>/dev/null | grep -q "Mach-O"; then
    SHU_ASM_NATIVE=1
  fi
fi

if [ -z "$CHECK_SHU" ]; then
  # shu-c 无 --help；可执行即优先（Mac 勿误选 Linux ELF shu_asm）
  if [ -x ./compiler/shu-c ]; then
    CHECK_SHU=./compiler/shu-c
  elif [ -n "$SHU_ASM_BIN" ] && [ "$SHU_ASM_NATIVE" = "1" ]; then
    CHECK_SHU="$SHU_ASM_BIN"
  else
    make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c
    CHECK_SHU=./compiler/shu-c
  fi
fi

SU="tests/wpo/stack_promote_smoke.su"
OUT="/tmp/shu_wpo_stack_promote_smoke"

echo "=== WPO-S3: stack_promote_smoke check ($CHECK_SHU) ==="
"$CHECK_SHU" check "$SU" >/dev/null

echo "=== WPO-S3: stack_promote_cross typeck (import struct helpers) ==="
"$CHECK_SHU" check tests/wpo/stack_promote_cross.su >/dev/null
echo "=== WPO-S3: stack_promote_cross_ret typeck (field sum, no sum_pair) ==="
"$CHECK_SHU" check tests/wpo/stack_promote_cross_ret.su >/dev/null
echo "=== WPO-S3: stack_promote_escape typeck (&p escape) ==="
"$CHECK_SHU" check tests/wpo/stack_promote_escape.su >/dev/null
echo "=== WPO-S3: stack_promote_escape_cross typeck (import &p escape) ==="
"$CHECK_SHU" check tests/wpo/stack_promote_escape_cross.su >/dev/null
echo "=== WPO-S3: stack_promote_escape_global typeck (expect struct stack escape) ==="
neg_global=$("$CHECK_SHU" check tests/wpo/stack_promote_escape_global.su 2>&1) && {
  echo "wpo-s3 escape_global FAIL: expected typeck reject" >&2
  exit 1
}
echo "$neg_global" | grep -q "struct stack escape" || {
  echo "wpo-s3 escape_global FAIL: expected struct stack escape diagnostic" >&2
  echo "$neg_global" >&2
  exit 1
}
echo "wpo-s3 escape_global reject OK"
echo "=== WPO-S3: stack_promote_await typeck (struct 跨 await 占位) ==="
"$CHECK_SHU" check tests/wpo/stack_promote_await.su >/dev/null
echo "=== WPO-S3: stack_promote_await_yield typeck (struct 跨 await + 双 poll) ==="
"$CHECK_SHU" check tests/wpo/stack_promote_await_yield.su >/dev/null
echo "wpo-s3 cross/cross_ret/escape/await/await_yield typeck OK"

if wpo_host_asm_run_na; then
  echo "wpo-s3 asm smoke N/A on $(uname -s)-$(uname -m) (refresh shu_asm asm stub; x86_64 covers)"
elif [ "$SHU_ASM_NATIVE" = "1" ]; then
  "$SHU_ASM_BIN" "$SU" -o "$OUT" 2>/dev/null
  EX=0
  "$OUT" >/dev/null 2>&1 || EX=$?
  if [ "$EX" -ne 7 ]; then
    echo "wpo-s3 smoke FAIL: expected exit 7 got $EX" >&2
    exit 1
  fi
  MAIN_ASM=$(wpo_main_asm "$OUT" || true)
  if [ -z "$MAIN_ASM" ]; then
    echo "wpo-s3 asm FAIL: cannot disassemble main ($OUT); need otool or objdump" >&2
    exit 1
  fi
  # 同模块当前基线：main 内联 helper，不应 call make_pair/sum_pair（见 tests/baseline/wpo-s3-disasm.tsv）
  if ! wpo_s3_main_no_helper_calls "$OUT"; then
    echo "wpo-s3 asm FAIL: intra-module baseline expects no call make_pair/sum_pair in main" >&2
    printf '%s\n' "$MAIN_ASM" | grep -E 'make_pair|sum_pair|bl|call' || true
    exit 1
  fi
  echo "wpo-s3 asm baseline OK (main inlined, exit 7)"

  # 跨模块 asm：co-emit dep + 链接 exe；main 应 call 导入的 make_pair/sum_pair（stack promotion 前基线）
  CROSS_OUT="/tmp/shu_wpo_stack_promote_cross"
  "$SHU_ASM_BIN" -backend asm tests/wpo/stack_promote_cross.su -o "$CROSS_OUT" 2>/tmp/shu_wpo_s3_cross_build.log
  if [ ! -x "$CROSS_OUT" ]; then
    echo "wpo-s3 cross asm FAIL: link/exe missing (see /tmp/shu_wpo_s3_cross_build.log)" >&2
    tail -8 /tmp/shu_wpo_s3_cross_build.log 2>/dev/null || true
    exit 1
  fi
  if ! wpo_s3_main_no_helper_calls "$CROSS_OUT"; then
    echo "wpo-s3 cross asm FAIL: stack promotion expects no call make_pair/sum_pair in main" >&2
    wpo_main_asm "$CROSS_OUT" | grep -E 'make_pair|sum_pair|call|bl' || true
    exit 1
  fi
  EX=0
  "$CROSS_OUT" >/dev/null 2>&1 || EX=$?
  if [ "$EX" -ne 7 ]; then
    echo "wpo-s3 cross asm FAIL: expected exit 7 got $EX" >&2
    exit 1
  fi
  echo "wpo-s3 cross asm OK (import helpers inlined in main, exit 7)"

  # 跨模块 field-sum（无 sum_pair call）：make_pair 内联 + main 直读 p.a/p.b
  CROSS_RET_OUT="/tmp/shu_wpo_stack_promote_cross_ret"
  "$SHU_ASM_BIN" -backend asm tests/wpo/stack_promote_cross_ret.su -o "$CROSS_RET_OUT" 2>/tmp/shu_wpo_s3_cross_ret_build.log
  if [ ! -x "$CROSS_RET_OUT" ]; then
    echo "wpo-s3 cross_ret asm FAIL: link/exe missing (see /tmp/shu_wpo_s3_cross_ret_build.log)" >&2
    tail -8 /tmp/shu_wpo_s3_cross_ret_build.log 2>/dev/null || true
    exit 1
  fi
  if ! wpo_s3_main_no_helper_calls "$CROSS_RET_OUT"; then
    echo "wpo-s3 cross_ret asm FAIL: expects no call make_pair/sum_pair in main" >&2
    wpo_main_asm "$CROSS_RET_OUT" | grep -E 'make_pair|sum_pair|call|bl' || true
    exit 1
  fi
  EX=0
  "$CROSS_RET_OUT" >/dev/null 2>&1 || EX=$?
  if [ "$EX" -ne 7 ]; then
    echo "wpo-s3 cross_ret asm FAIL: expected exit 7 got $EX" >&2
    exit 1
  fi
  echo "wpo-s3 cross_ret asm OK (make_pair inlined, field sum exit 7)"

  # 同模块 &p 逃逸：make_pair 须直写栈槽，sum_via_ptr 可读有效指针
  ESC_OUT="/tmp/shu_wpo_stack_promote_escape"
  "$SHU_ASM_BIN" tests/wpo/stack_promote_escape.su -o "$ESC_OUT" 2>/tmp/shu_wpo_s3_escape_build.log
  if [ ! -x "$ESC_OUT" ]; then
    echo "wpo-s3 escape asm FAIL: link/exe missing (see /tmp/shu_wpo_s3_escape_build.log)" >&2
    tail -8 /tmp/shu_wpo_s3_escape_build.log 2>/dev/null || true
    exit 1
  fi
  if ! wpo_main_no_calls_pat "$ESC_OUT" 'make_pair'; then
    echo "wpo-s3 escape asm FAIL: make_pair must be inlined into stack slot when &p escapes" >&2
    wpo_main_asm "$ESC_OUT" | grep -E 'make_pair|call|bl' || true
    exit 1
  fi
  EX=0
  "$ESC_OUT" >/dev/null 2>&1 || EX=$?
  if [ "$EX" -ne 7 ]; then
    echo "wpo-s3 escape asm FAIL: expected exit 7 got $EX" >&2
    exit 1
  fi
  echo "wpo-s3 escape asm OK (addr-of local struct, exit 7)"

  # 跨模块 &p → import read_pair_ptr：make_pair 内联 + 指针实参 call helper
  ESC_CROSS_OUT="/tmp/shu_wpo_stack_promote_escape_cross"
  "$SHU_ASM_BIN" -backend asm tests/wpo/stack_promote_escape_cross.su -o "$ESC_CROSS_OUT" 2>/tmp/shu_wpo_s3_escape_cross_build.log
  if [ ! -x "$ESC_CROSS_OUT" ]; then
    echo "wpo-s3 escape_cross asm FAIL: link/exe missing (see /tmp/shu_wpo_s3_escape_cross_build.log)" >&2
    tail -8 /tmp/shu_wpo_s3_escape_cross_build.log 2>/dev/null || true
    exit 1
  fi
  if ! wpo_main_no_calls_pat "$ESC_CROSS_OUT" 'make_pair'; then
    echo "wpo-s3 escape_cross asm FAIL: make_pair must be inlined when &p escapes to import call" >&2
    wpo_main_asm "$ESC_CROSS_OUT" | grep -E 'make_pair|call|bl' || true
    exit 1
  fi
  EX=0
  "$ESC_CROSS_OUT" >/dev/null 2>&1 || EX=$?
  if [ "$EX" -ne 7 ]; then
    echo "wpo-s3 escape_cross asm FAIL: expected exit 7 got $EX" >&2
    exit 1
  fi
  echo "wpo-s3 escape_cross asm OK (import read_pair_ptr(&p), exit 7)"

  # struct 跨 await：asm sync stub / C CPS 帧保留 Pair（exit 10 = 3+4+3）
  AWAIT_OUT="/tmp/shu_wpo_stack_promote_await"
  "$SHU_ASM_BIN" tests/wpo/stack_promote_await.su -o "$AWAIT_OUT" 2>/tmp/shu_wpo_s3_await_build.log
  if [ ! -x "$AWAIT_OUT" ]; then
    echo "wpo-s3 await asm FAIL: link/exe missing (see /tmp/shu_wpo_s3_await_build.log)" >&2
    tail -8 /tmp/shu_wpo_s3_await_build.log 2>/dev/null || true
    exit 1
  fi
  EX=0
  "$AWAIT_OUT" >/dev/null 2>&1 || EX=$?
  if [ "$EX" -ne 10 ]; then
    echo "wpo-s3 await asm FAIL: expected exit 10 got $EX" >&2
    exit 1
  fi
  echo "wpo-s3 await asm OK (struct across await exit 10)"

  # struct 跨 await + SHU_ASYNC_YIELD 双 poll：帧须保留 Pair，resume 后 exit 0
  make -C compiler ../std/async/scheduler.o -q 2>/dev/null || make -C compiler ../std/async/scheduler.o
  AWAIT_YIELD_OUT="/tmp/shu_wpo_stack_promote_await_yield"
  SHU_ASYNC_YIELD=1 "$SHU_ASM_BIN" -L . tests/wpo/stack_promote_await_yield.su -o "$AWAIT_YIELD_OUT" 2>/tmp/shu_wpo_s3_await_yield_build.log
  if [ ! -x "$AWAIT_YIELD_OUT" ]; then
    echo "wpo-s3 await_yield asm FAIL: link/exe missing (see /tmp/shu_wpo_s3_await_yield_build.log)" >&2
    tail -8 /tmp/shu_wpo_s3_await_yield_build.log 2>/dev/null || true
    exit 1
  fi
  EX=0
  SHU_ASYNC_YIELD=1 "$AWAIT_YIELD_OUT" >/dev/null 2>&1 || EX=$?
  if [ "$EX" -ne 0 ]; then
    echo "wpo-s3 await_yield asm FAIL: expected exit 0 got $EX (SHU_ASYNC_YIELD=1 double poll)" >&2
    exit 1
  fi
  echo "wpo-s3 await_yield asm OK (struct frame preserved across suspend, exit 0)"
else
  if [ "$(uname -s)" = "Darwin" ]; then
    echo "wpo-s3 asm smoke N/A on Darwin (user exe ld/run; Linux x86_64 covers)"
  else
    echo "wpo-s3 asm smoke SKIP (no shu_asm; use docker ubuntu-wpo-s2)"
  fi
fi

echo "wpo-s3 gate OK"
