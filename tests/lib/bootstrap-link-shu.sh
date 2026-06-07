# 文件职责：bootstrap run-all 下选择用于 -o 链接/运行的编译器。
# seed（SHU）负责 .su typeck/check；可执行与跨模块符号由 shu-c 承担（若存在）。
# 用法：在 run-*.sh 中 `. "$(dirname "$0")/lib/bootstrap-link-shu.sh"` 后使用 $RUN_SHU。

# 默认与 SHU 相同；run-all 会 export SHULANG_LINK_SHU=./compiler/shu-c。
RUN_SHU="${SHULANG_LINK_SHU:-${SHU:-./compiler/shu}}"
# 非 x86_64 bootstrap：-o 链接优先 shu-c（seed asm 跨 arch 不可用）。
case "$(uname -m 2>/dev/null)" in
  x86_64|amd64) ;;
  *)
    if [ -x ./compiler/shu-c ] && [ -z "${SHULANG_LINK_SHU:-}" ]; then
      SHULANG_LINK_SHU=./compiler/shu-c
    fi
    ;;
esac
