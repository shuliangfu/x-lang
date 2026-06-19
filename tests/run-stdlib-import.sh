#!/usr/bin/env bash
# 测试自举前标准库扩展（5.5）：多个 core/std 模块可 import 并有最小可用实现。
# 依赖：compiler/shux 或 shux-c、tests/stdlib-import/main.sx、core/*.sx、std/*.sx（-L .）。
# P5 / ubuntu-gates：typeck 烟测与 -o 链接优先 shux-c（bootstrap shux 对 dep typeck/-o 易失败）。

set -e
cd "$(dirname "$0")/.."

# 可执行链接优先 shux-c；无 shux-c 时回退 SHU / shux。
stdlib_import_pick_link_shu() {
  if [ -x ./compiler/shux-c ]; then
    echo "./compiler/shux-c"
    return 0
  fi
  if [ -n "${SHUX:-}" ] && [ -x "$SHUX" ]; then
    echo "$SHUX"
    return 0
  fi
  if [ -x ./compiler/shux ]; then
    echo "./compiler/shux"
    return 0
  fi
  echo "./compiler/shux-c"
}

if [ -n "$SHUX" ]; then
  :
elif [ -x ./compiler/shux-c ]; then
  SHUX=./compiler/shux-c
elif [ -x ./compiler/shux ]; then
  SHUX=./compiler/shux
else
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
  SHUX=./compiler/shux-c
fi

# typeck / 烟测：跨平台以 shux-c 为准（bootstrap shux 对 core.option 等 dep 可能误报）
CHECK_SHUX="$SHUX"
if [ -x ./compiler/shux-c ]; then
  CHECK_SHUX=./compiler/shux-c
fi
LINK_SHUX="$(stdlib_import_pick_link_shu)"

make -C compiler -q ../std/process/process.o 2>/dev/null || make -C compiler ../std/process/process.o
# run-all 入口已 make 时跳过（SHUX_SKIP_SUBSCRIPT_MAKE=1）。
if [ -z "${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  if [ -n "${SHUX_RUN_ALL_BOOTSTRAP_SHUX:-}" ]; then
    make -C compiler bootstrap-driver-seed -q 2>/dev/null || make -C compiler bootstrap-driver-seed
  else
    make -C compiler -q 2>/dev/null || make -C compiler
  fi
fi
# bootstrap seed：typeck 走 .sx pipeline（check）；多模块可执行链接仍用 shux-c（seed -o 常 cc failed）。
if [ -n "${SHUX_RUN_ALL_BOOTSTRAP_SHUX:-}" ]; then
  # deno check 语义：成功时静默（exit 0、无输出）；与 tests/run-check.sh 一致。
  chk_out=$($SHUX check -L . tests/stdlib-import/main.sx 2>&1) || chk_rc=$?
  chk_rc=${chk_rc:-0}
  if [ "$chk_rc" -ne 0 ]; then
    echo "stdlib-import: check failed on bootstrap shux (exit $chk_rc)" >&2
    echo "$chk_out"
    exit 1
  fi
  if [ -n "$chk_out" ] && echo "$chk_out" | grep -qE " - error: |typeck error:|check failed|parse error"; then
    echo "stdlib-import: unexpected check diagnostics on bootstrap shux" >&2
    echo "$chk_out"
    exit 1
  fi
  LINK_SHUX="$(stdlib_import_pick_link_shu)"
else
  out=$($CHECK_SHUX -L . tests/stdlib-import/main.sx 2>&1)
  echo "$out" | grep -q "parse OK" || { echo "expected parse OK"; echo "$out"; exit 1; }
  echo "$out" | grep -q "typeck OK" || { echo "expected typeck OK"; echo "$out"; exit 1; }
fi
if [ "$LINK_SHUX" != "$CHECK_SHUX" ] && [ -n "$LINK_SHUX" ]; then
  echo "stdlib-import: link via $(basename "$LINK_SHUX") (check via $(basename "$CHECK_SHUX"))"
fi
if ! $LINK_SHUX -L . tests/stdlib-import/main.sx -o /tmp/shux_stdlib_import >/dev/null 2>&1; then
  echo "stdlib-import: compile failed (link via ${LINK_SHUX##*/})" >&2
  exit 1
fi
/tmp/shux_stdlib_import
echo "stdlib-import test OK"
