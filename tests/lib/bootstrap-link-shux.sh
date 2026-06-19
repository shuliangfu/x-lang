# 文件职责：bootstrap run-all 下选择用于 -o 链接/运行的编译器。
# seed（SHUX）负责 .sx typeck/check；可执行与跨模块符号由 shux-c 承担（若存在）。
# 用法：在 run-*.sh 中 `. "$(dirname "$0")/lib/bootstrap-link-shux.sh"` 后使用 $RUN_SHUX。

# 默认与 SHUX 相同；run-all 会 export SHUX_LINK_SHUX=./compiler/shux-c。
# bootstrap（SHUX_RUN_ALL_BOOTSTRAP_SHUX=1）：-o 链接默认 shux-c；seed shux 仍由各脚本 $SHUX 做 check/typeck。
# 非 x86_64 bootstrap：-o 链接优先 shux-c（seed asm 跨 arch 不可用）。
# MSYS2：seed -o / -backend c 全链路挂起（见 run-async.sh）；x86_64 亦须 shux-c。
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*)
    if [ -x ./compiler/shux-c ] && [ -z "${SHUX_LINK_SHUX:-}" ]; then
      SHUX_LINK_SHUX=./compiler/shux-c
    fi
    ;;
esac
case "$(uname -m 2>/dev/null)" in
  x86_64|amd64) ;;
  *)
    if [ -x ./compiler/shux-c ] && [ -z "${SHUX_LINK_SHUX:-}" ]; then
      SHUX_LINK_SHUX=./compiler/shux-c
    fi
    ;;
esac
RUN_SHUX="${SHUX_LINK_SHUX:-${SHUX:-./compiler/shux}}"
if [ -n "${SHUX_RUN_ALL_BOOTSTRAP_SHUX:-}" ] && [ -z "${SHUX_LINK_SHUX:-}" ] && [ -x ./compiler/shux-c ]; then
  RUN_SHUX=./compiler/shux-c
fi
# shux/shux_asm：slice .length 等 -o codegen 不完整；refresh shux_asm 在非 x86_64 上 asm 产出 EM:62。
# 未显式 SHUX_LINK_SHUX 时，-o 可执行链接一律 shux-c（ZC-3 / Docker / run-all 一致）。
if [ -x ./compiler/shux-c ] && [ -z "${SHUX_LINK_SHUX:-}" ]; then
  case "$(basename "${SHUX:-}")" in
    shux|shux_asm) RUN_SHUX=./compiler/shux-c ;;
  esac
fi
