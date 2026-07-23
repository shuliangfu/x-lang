# 文件职责：bootstrap run-all 下选择用于 -o 链接/运行的编译器。
# seed（XLANG）负责 .x typeck/check；可执行与跨模块符号由 xlang-c 承担（若存在）。
# 用法：在 run-*.sh 中 `. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"` 后使用 $RUN_XLANG。

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "${BASH_SOURCE[0]:-$0}")/ci-host.sh"

# 默认与 XLANG 相同；run-all 会 export XLANG_LINK_XLANG=./compiler/xlang-c。
# bootstrap（XLANG_RUN_ALL_BOOTSTRAP_XLANG=1）：-o 链接默认 xlang-c；seed xlang 仍由各脚本 $XLANG build 做 check/typeck。
# 非 x86_64 bootstrap：-o 链接优先 xlang-c（seed asm 跨 arch 不可用）。
# MSYS2：seed -o / -backend c 全链路挂起（见 run-async.sh）；x86_64 亦须 xlang-c。
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*)
    if [ -x ./compiler/xlang-c ] && [ -z "${XLANG_LINK_XLANG:-}" ]; then
      XLANG_LINK_XLANG=./compiler/xlang-c
    fi
    ;;
esac
case "$(uname -m 2>/dev/null)" in
  x86_64|amd64) ;;
  *)
    if [ -x ./compiler/xlang-c ] && [ -z "${XLANG_LINK_XLANG:-}" ]; then
      XLANG_LINK_XLANG=./compiler/xlang-c
    fi
    ;;
esac
RUN_XLANG="${XLANG_LINK_XLANG:-${XLANG:-./compiler/xlang}}"
if [ -n "${XLANG_RUN_ALL_BOOTSTRAP_XLANG:-}" ] && [ -z "${XLANG_LINK_XLANG:-}" ] && [ -x ./compiler/xlang-c ] && ci_native_shu ./compiler/xlang-c; then
  RUN_XLANG=./compiler/xlang-c
fi
# xlang/xlang_asm：slice .length 等 -o codegen 不完整；refresh xlang_asm 在非 x86_64 上 asm 产出 EM:62。
# 未显式 XLANG_LINK_XLANG 时，-o 可执行链接一律 xlang-c（ZC-3 / Docker / run-all 一致）。
if [ -x ./compiler/xlang-c ] && [ -z "${XLANG_LINK_XLANG:-}" ] && ci_native_shu ./compiler/xlang-c; then
  case "$(basename "${XLANG:-}")" in
    xlang|xlang_asm) RUN_XLANG=./compiler/xlang-c ;;
  esac
fi
# bootstrap arm64：xlang_asm -o 负例 typeck 易 OOM；与 run-check 一致走 xlang-c。
TYPECK_XLANG="${XLANG:-./compiler/xlang}"
if [ -n "${XLANG_RUN_ALL_BOOTSTRAP_XLANG:-}" ] && [ -x ./compiler/xlang-c ] && ci_native_shu ./compiler/xlang-c; then
  case "$(uname -m 2>/dev/null)" in
    x86_64|amd64) ;;
    *) TYPECK_XLANG=./compiler/xlang-c ;;
  esac
fi
# xlang-c（XLANG_LEGACY_C_FRONTEND=1 构建，无 XLANG_USE_X_PIPELINE）不支持 -backend 参数
# （runtime.c:1219 报 "build error[BLD001]: -backend asm not available"）。
# 只有 xlang_asm/xlang_asm_stage1 等真正链了 asm 后端 .o 的构建才支持 -backend asm。
# 故 xlang-c 走默认 C 后端 -o（fork gcc 链）；struct/inline SIGSEGV 由各 gate 的 fallback 处理。
XLANG_LINK_BACKEND_ARGS=""
case "$(basename "${RUN_XLANG}")" in
  xlang_asm|xlang_asm2|xlang_asm_stage1) XLANG_LINK_BACKEND_ARGS="-backend asm" ;;
esac
# Darwin：产品 asm -o 在 arm64 上 CG002 empty text；-o 链接改走 -backend c。
# Ubuntu/Linux 金标仍默认 -backend asm。显式 XLANG_LINK_BACKEND_ARGS 优先。
case "$(uname -s 2>/dev/null)-$(uname -m 2>/dev/null)" in
  Darwin-arm64|Darwin-aarch64)
    if [ -z "${XLANG_FORCE_LINK_BACKEND:-}" ]; then
      XLANG_LINK_BACKEND_ARGS="-backend c"
    fi
    ;;
esac
if [ -n "${XLANG_FORCE_LINK_BACKEND:-}" ]; then
  XLANG_LINK_BACKEND_ARGS="-backend ${XLANG_FORCE_LINK_BACKEND}"
fi
# W3 / B-strict：stage2 xlang_asm(2) 可用于 asm -o；未显式 XLANG_LINK_XLANG 时优先于 xlang-c（seed -o 易 SIGSEGV）。
# refresh-xlang-asm-gate 后 xlang_asm 常新于 xlang_asm2（未跑 stage2）；勿用陈旧 gen2。
if [ -z "${XLANG_LINK_XLANG:-}" ]; then
  if [ -x ./compiler/xlang_asm2 ] && ci_native_shu ./compiler/xlang_asm2; then
    RUN_XLANG=./compiler/xlang_asm2
    if [ -x ./compiler/xlang_asm ] && ci_native_shu ./compiler/xlang_asm \
       && [ ./compiler/xlang_asm -nt ./compiler/xlang_asm2 ]; then
      RUN_XLANG=./compiler/xlang_asm
    fi
  elif [ -x ./compiler/xlang_asm ] && ci_native_shu ./compiler/xlang_asm; then
    RUN_XLANG=./compiler/xlang_asm
  fi
fi
# 多数 run-*.sh 直接调用 $RUN_XLANG build 而未透传 XLANG_LINK_BACKEND_ARGS。
# Darwin 下注入 wrapper，保证 -backend c 落到产品 -o。
if [ -n "${XLANG_LINK_BACKEND_ARGS:-}" ] && [ -z "${XLANG_NO_BACKEND_WRAP:-}" ]; then
  _be_wrap="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/xlang-backend-wrap.sh"
  if [ -x "$_be_wrap" ] || [ -f "$_be_wrap" ]; then
    chmod +x "$_be_wrap" 2>/dev/null || true
    export XLANG_BACKEND_WRAP_REAL="${RUN_XLANG}"
    export XLANG_BACKEND_WRAP_ARGS="${XLANG_LINK_BACKEND_ARGS}"
    RUN_XLANG="$_be_wrap"
  fi
fi
export TYPECK_XLANG RUN_XLANG XLANG_LINK_BACKEND_ARGS

# bootstrap-min：-o 经 xlang-min-link 包装（旧 link_abi 无 /usr/local/bin/gcc 时 gcc 回退）。
if [ -n "${XLANG_BOOTSTRAP_MIN:-}" ] && [ -z "${XLANG_BOOTSTRAP_MIN_NO_WRAP:-}" ]; then
  _min_wrap="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/xlang-min-link.sh"
  if [ -x "$_min_wrap" ]; then
    _min_real="${XLANG_MIN_LINK_REAL:-${XLANG_LINK_XLANG:-./compiler/xlang_asm}}"
    export XLANG_MIN_LINK_REAL="$_min_real"
    chmod +x "$_min_wrap" 2>/dev/null || true
    RUN_XLANG="$_min_wrap"
  fi
fi
