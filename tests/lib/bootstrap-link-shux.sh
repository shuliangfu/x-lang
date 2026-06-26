# 文件职责：bootstrap run-all 下选择用于 -o 链接/运行的编译器。
# seed（SHUX）负责 .sx typeck/check；可执行与跨模块符号由 shux-c 承担（若存在）。
# 用法：在 run-*.sh 中 `. "$(dirname "$0")/lib/bootstrap-link-shux.sh"` 后使用 $RUN_SHUX。

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "${BASH_SOURCE[0]}")/ci-host.sh"

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
if [ -n "${SHUX_RUN_ALL_BOOTSTRAP_SHUX:-}" ] && [ -z "${SHUX_LINK_SHUX:-}" ] && [ -x ./compiler/shux-c ] && ci_native_shu ./compiler/shux-c; then
  RUN_SHUX=./compiler/shux-c
fi
# shux/shux_asm：slice .length 等 -o codegen 不完整；refresh shux_asm 在非 x86_64 上 asm 产出 EM:62。
# 未显式 SHUX_LINK_SHUX 时，-o 可执行链接一律 shux-c（ZC-3 / Docker / run-all 一致）。
if [ -x ./compiler/shux-c ] && [ -z "${SHUX_LINK_SHUX:-}" ] && ci_native_shu ./compiler/shux-c; then
  case "$(basename "${SHUX:-}")" in
    shux|shux_asm) RUN_SHUX=./compiler/shux-c ;;
  esac
fi
# bootstrap arm64：shux_asm -o 负例 typeck 易 OOM；与 run-check 一致走 shux-c。
TYPECK_SHUX="${SHUX:-./compiler/shux}"
if [ -n "${SHUX_RUN_ALL_BOOTSTRAP_SHUX:-}" ] && [ -x ./compiler/shux-c ] && ci_native_shu ./compiler/shux-c; then
  case "$(uname -m 2>/dev/null)" in
    x86_64|amd64) ;;
    *) TYPECK_SHUX=./compiler/shux-c ;;
  esac
fi
# shux-c 默认 C 后端 -o 在 struct/inline 等用例易 SIGSEGV；与 shux_compile_std_sx.sh 一致走 asm。
SHUX_LINK_BACKEND_ARGS=""
case "$(basename "${RUN_SHUX}")" in
  shux-c) SHUX_LINK_BACKEND_ARGS="-backend asm" ;;
esac
# W3 / B-strict：stage2 shux_asm(2) 可用于 asm -o；未显式 SHUX_LINK_SHUX 时优先于 shux-c（seed -o 易 SIGSEGV）。
# refresh-shux-asm-gate 后 shux_asm 常新于 shux_asm2（未跑 stage2）；勿用陈旧 gen2。
if [ -z "${SHUX_LINK_SHUX:-}" ]; then
  if [ -x ./compiler/shux_asm2 ] && ci_native_shu ./compiler/shux_asm2; then
    RUN_SHUX=./compiler/shux_asm2
    if [ -x ./compiler/shux_asm ] && ci_native_shu ./compiler/shux_asm \
       && [ ./compiler/shux_asm -nt ./compiler/shux_asm2 ]; then
      RUN_SHUX=./compiler/shux_asm
    fi
  elif [ -x ./compiler/shux_asm ] && ci_native_shu ./compiler/shux_asm; then
    RUN_SHUX=./compiler/shux_asm
  fi
fi
export TYPECK_SHUX RUN_SHUX SHUX_LINK_BACKEND_ARGS

# bootstrap-min：-o 经 shux-min-link 包装（旧 link_abi 无 /usr/local/bin/gcc 时 gcc 回退）。
if [ -n "${SHUX_BOOTSTRAP_MIN:-}" ] && [ -z "${SHUX_BOOTSTRAP_MIN_NO_WRAP:-}" ]; then
  _min_wrap="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/shux-min-link.sh"
  if [ -x "$_min_wrap" ]; then
    _min_real="${SHUX_MIN_LINK_REAL:-${SHUX_LINK_SHUX:-./compiler/shux_asm}}"
    export SHUX_MIN_LINK_REAL="$_min_real"
    chmod +x "$_min_wrap" 2>/dev/null || true
    RUN_SHUX="$_min_wrap"
  fi
fi
