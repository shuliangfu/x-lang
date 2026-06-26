#!/usr/bin/env bash
# 文件职责：验证 codegen 使用 main 体字面量作为程序退出码；编译 fn main() -> i32 { 42 } 并检查退出码为 42。
# 与其它文件的关系：由 compiler/Makefile 的 test 目标调用；依赖 compiler/shux、tests/return-value/main.sx。

set -e
cd "$(dirname "$0")/.."
if [ -z "${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler
fi
SHUX=${SHUX:-./compiler/shux}
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
LINK_SHUX="$RUN_SHUX"
OUT=/tmp/shux_return_value
# 避免上一次 shux-c 留下的 Mach-O 与本次 C 输出长度交错导致 file/cc 误判；同时清掉二次链接产物。
rm -f "$OUT" "${OUT}.bin"
# 编译：shux-c 走 C 前端会在 -o 处直接产出可执行文件；bootstrap-driver-seed 的 shux / stage2 对无 import 单文件走 .sx pipeline，仅把生成的 C 写入 -o，须再经 cc 链接。
$LINK_SHUX tests/return-value/main.sx -o "$OUT" 2>&1
BIN="$OUT"
ft=$(file -b "$OUT" 2>/dev/null || true)
# 无 file(1) 时勿把已链接 ELF 当 C 源；读魔数 0x7F 'E' 'L' 'F'。
is_elf=0
if [ -f "$OUT" ]; then
  magic=$(dd if="$OUT" bs=1 count=4 2>/dev/null | od -An -tx1 | tr -d ' \n')
  [ "$magic" = "7f454c46" ] && is_elf=1
fi
case "$ft" in
  *Mach-O*|*ELF*|*PE32*)
    ;;
  *)
    if [ "$is_elf" -eq 1 ]; then
      :
    else
    # 无 .c 后缀时须 -x c，否则 clang 会把输入当链接目标而非 C 源（报 ld: unknown file type）。
    cc -x c -std=c11 -Wall -Wextra -o "${OUT}.bin" "$OUT" 2>/dev/null \
      || gcc -x c -std=c11 -Wall -Wextra -o "${OUT}.bin" "$OUT" 2>/dev/null \
      || clang -x c -std=c11 -Wall -Wextra -o "${OUT}.bin" "$OUT"
    BIN="${OUT}.bin"
    fi
    ;;
esac
# 运行生成的可执行文件并捕获退出码（set -e 下非零会退出，故用 || 保存到变量）
exitcode=0
"$BIN" >/dev/null 2>&1 || exitcode=$?
if [ "$exitcode" -ne 42 ]; then
    echo "expected exit code 42, got $exitcode"
    exit 1
fi
echo "return value test OK"
