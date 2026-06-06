#!/usr/bin/env bash
# 测试自举前标准库扩展（5.5）：多个 core/std 模块可 import 并有最小可用实现。
# 依赖：compiler/shu 或 shu-c、tests/stdlib-import/main.su、core/*.su、std/*.su（-L .）。
# P5 / ubuntu-gates：typeck 烟测与 -o 链接优先 shu-c（bootstrap shu 对 dep typeck/-o 易失败）。

set -e
cd "$(dirname "$0")/.."

# 可执行链接优先 shu-c；无 shu-c 时回退 SHU / shu。
stdlib_import_pick_link_shu() {
  if [ -x ./compiler/shu-c ]; then
    echo "./compiler/shu-c"
    return 0
  fi
  if [ -n "${SHU:-}" ] && [ -x "$SHU" ]; then
    echo "$SHU"
    return 0
  fi
  if [ -x ./compiler/shu ]; then
    echo "./compiler/shu"
    return 0
  fi
  echo "./compiler/shu-c"
}

if [ -n "$SHU" ]; then
  :
elif [ -x ./compiler/shu-c ]; then
  SHU=./compiler/shu-c
elif [ -x ./compiler/shu ]; then
  SHU=./compiler/shu
else
  make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c
  SHU=./compiler/shu-c
fi

# typeck / 烟测：跨平台以 shu-c 为准（bootstrap shu 对 core.option 等 dep 可能误报）
CHECK_SHU="$SHU"
if [ -x ./compiler/shu-c ]; then
  CHECK_SHU=./compiler/shu-c
fi
LINK_SHU="$(stdlib_import_pick_link_shu)"

make -C compiler -q ../std/process/process.o 2>/dev/null || make -C compiler ../std/process/process.o
# run-all 入口已 make 时跳过（SHULANG_SKIP_SUBSCRIPT_MAKE=1）。
if [ -z "${SHULANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  if [ -n "${SHULANG_RUN_ALL_BOOTSTRAP_SHU:-}" ]; then
    make -C compiler bootstrap-driver-seed -q 2>/dev/null || make -C compiler bootstrap-driver-seed
  else
    make -C compiler -q 2>/dev/null || make -C compiler
  fi
fi
# bootstrap seed：typeck 走 .su pipeline（check）；多模块可执行链接仍用 shu-c（seed -o 常 cc failed）。
if [ -n "${SHULANG_RUN_ALL_BOOTSTRAP_SHU:-}" ]; then
  # deno check 语义：成功时静默（exit 0、无输出）；与 tests/run-check.sh 一致。
  chk_out=$($SHU check -L . tests/stdlib-import/main.su 2>&1) || chk_rc=$?
  chk_rc=${chk_rc:-0}
  if [ "$chk_rc" -ne 0 ]; then
    echo "stdlib-import: check failed on bootstrap shu (exit $chk_rc)" >&2
    echo "$chk_out"
    exit 1
  fi
  if [ -n "$chk_out" ] && echo "$chk_out" | grep -qE " - error: |typeck error:|check failed|parse error"; then
    echo "stdlib-import: unexpected check diagnostics on bootstrap shu" >&2
    echo "$chk_out"
    exit 1
  fi
  LINK_SHU="$(stdlib_import_pick_link_shu)"
else
  out=$($CHECK_SHU -L . tests/stdlib-import/main.su 2>&1)
  echo "$out" | grep -q "parse OK" || { echo "expected parse OK"; echo "$out"; exit 1; }
  echo "$out" | grep -q "typeck OK" || { echo "expected typeck OK"; echo "$out"; exit 1; }
fi
if [ "$LINK_SHU" != "$CHECK_SHU" ] && [ -n "$LINK_SHU" ]; then
  echo "stdlib-import: link via $(basename "$LINK_SHU") (check via $(basename "$CHECK_SHU"))"
fi
if ! $LINK_SHU -L . tests/stdlib-import/main.su -o /tmp/shu_stdlib_import >/dev/null 2>&1; then
  echo "stdlib-import: compile failed (link via ${LINK_SHU##*/})" >&2
  exit 1
fi
/tmp/shu_stdlib_import
echo "stdlib-import test OK"
