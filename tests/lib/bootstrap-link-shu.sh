# 文件职责：bootstrap run-all 下选择用于 -o 链接/运行的编译器。
# seed（SHU）负责 .su typeck/check；可执行与跨模块符号由 shu-c 承担（若存在）。
# 用法：在 run-*.sh 中 `. "$(dirname "$0")/lib/bootstrap-link-shu.sh"` 后使用 $RUN_SHU。

# 默认与 SHU 相同；run-all 会 export SHULANG_LINK_SHU=./compiler/shu-c。
# bootstrap（SHULANG_RUN_ALL_BOOTSTRAP_SHU=1）：-o 链接默认 shu-c；seed shu 仍由各脚本 $SHU 做 check/typeck。
# 非 x86_64 bootstrap：-o 链接优先 shu-c（seed asm 跨 arch 不可用）。
# MSYS2：seed -o / -backend c 全链路挂起（见 run-async.sh）；x86_64 亦须 shu-c。
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*)
    if [ -x ./compiler/shu-c ] && [ -z "${SHULANG_LINK_SHU:-}" ]; then
      SHULANG_LINK_SHU=./compiler/shu-c
    fi
    ;;
esac
case "$(uname -m 2>/dev/null)" in
  x86_64|amd64) ;;
  *)
    if [ -x ./compiler/shu-c ] && [ -z "${SHULANG_LINK_SHU:-}" ]; then
      SHULANG_LINK_SHU=./compiler/shu-c
    fi
    ;;
esac
RUN_SHU="${SHULANG_LINK_SHU:-${SHU:-./compiler/shu}}"
if [ -n "${SHULANG_RUN_ALL_BOOTSTRAP_SHU:-}" ] && [ -z "${SHULANG_LINK_SHU:-}" ] && [ -x ./compiler/shu-c ]; then
  RUN_SHU=./compiler/shu-c
fi
# shu/shu_asm：slice .length 等 -o codegen 不完整；refresh shu_asm 在非 x86_64 上 asm 产出 EM:62。
# 未显式 SHULANG_LINK_SHU 时，-o 可执行链接一律 shu-c（ZC-3 / Docker / run-all 一致）。
if [ -x ./compiler/shu-c ] && [ -z "${SHULANG_LINK_SHU:-}" ]; then
  case "$(basename "${SHU:-}")" in
    shu|shu_asm) RUN_SHU=./compiler/shu-c ;;
  esac
fi
