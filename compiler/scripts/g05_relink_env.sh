#!/bin/sh
# g05_relink_env.sh — G-05 100%：relink 链接清单与 flags（纯 shell，不依赖 make）
#
# 用法（compiler/ 目录）：
# eval "$(sh scripts/g05_relink_env.sh)"
# . scripts/g05_relink_env.sh # 若由 prepare source（需 set -a 慎用）
#
# 输出：可 eval 的 G05_* 赋值（与历史 make g05-export-relink 同形）
#
# 覆盖面：默认 no_c seed 布局（G-02a）。LEGACY_C_FRONTEND / NO_C_SEED_LINK 实验链
# 仍走 Makefile 冷启动；本脚本服务日常 relink / shux_asm 产品路径。

set -e
# 允许从任意 cwd 调用：解析到 compiler/
_G05_ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$_G05_ROOT"

UNAME_S="$(uname -s 2>/dev/null || echo Unknown)"
UNAME_M="$(uname -m 2>/dev/null || echo unknown)"

G05_CC="${G05_CC:-cc}"
G05_OUT="${G05_OUT:-shux}"
G05_SHUX_C="${G05_SHUX_C:-shux-c}"
G05_BOOTSTRAP="${G05_BOOTSTRAP:-bootstrap_shuxc}"

# base cflags（与 Makefile CFLAGS 默认一致）
_BASE_CFLAGS="-Wall -Wextra -I. -Iinclude -Isrc"
_DRIVER_SEED_LINK_FLAGS="-DSHUX_USE_X_DRIVER -DSHUX_USE_X_PIPELINE -DSHUX_USE_X_TYPECK -DSHUX_USE_X_CODEGEN"

case "$UNAME_S" in
  Darwin)
  _ASM_GLUE_DUP_LDFLAGS="-Wl,-multiply_defined,suppress"
  case "$UNAME_M" in
  arm64|aarch64)
  _MAIN_LINK_O="src/asm/crt0_arm64.o"
  _MAIN_LINK_FLAGS="-e _start -nostartfiles"
  ;;
  x86_64|amd64)
  _MAIN_LINK_O="src/asm/crt0_darwin_x86_64.o"
  _MAIN_LINK_FLAGS="-e _start -nostartfiles"
  ;;
  *)
  _MAIN_LINK_O="src/main_driver.o"
  _MAIN_LINK_FLAGS=""
  ;;
  esac
  # Darwin：filtered pipeline + filtered user_asm seed 拓扑
  _PIPELINE_LINK_O="build_asm/bootstrap_seed_pipeline_filtered.o"
  _USER_ASM_LINK="build_asm/seed_host/asm_backend_partial.o build_asm/seed_host/asm_full_link_stubs.o build_asm/bootstrap_seed_user_asm_seed_bridge_filtered.o build_asm/bootstrap_seed_asm_backend_compat_stubs_filtered.o build_asm/bootstrap_seed_backend_x86_64_enc_c_filtered.o src/asm/backend_enc_dispatch.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o parser_asm_thin_glue.o src/asm/parser_asm_parse_expr_link.o"
  ;;
  Linux)
  _ASM_GLUE_DUP_LDFLAGS="-Wl,--allow-multiple-definition"
  case "$UNAME_M" in
  x86_64|amd64)
  _MAIN_LINK_O="src/asm/crt0_x86_64.o"
  _MAIN_LINK_FLAGS="-no-pie -e _start -nostartfiles"
  ;;
  *)
  _MAIN_LINK_O="src/main_driver.o"
  _MAIN_LINK_FLAGS=""
  ;;
  esac
  # Linux：pipeline_x.o + 全量 USER_ASM_LINK
  _PIPELINE_LINK_O="pipeline_x.o"
  _USER_ASM_LINK="build_asm/seed_host/asm_backend_partial.o build_asm/seed_host/asm_full_link_stubs.o src/asm/user_asm_seed_bridge.o src/asm/asm_backend_compat_stubs.o src/asm/backend_enc_dispatch.o src/asm/backend_x86_64_enc_c.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o parser_asm_thin_glue.o src/asm/parser_asm_parse_expr_link.o"
  ;;
  *)
  echo "g05_relink_env: unsupported host $UNAME_S/$UNAME_M (use Makefile cold path)" >&2
  exit 1
  ;;
esac

# 默认 no_c DRIVER_SEED 支撑（与 Makefile else 分支一致）
# G-02e: typeck_c_module_stubs + heap_user 并入 runtime_driver_strict_glue_stubs
_DRIVER_SEED_SUPPORT="src/runtime_driver_strict_glue_stubs.o src/lexer/cfg_eval.o src/typeck/typeck_f64_bits.o"
_X_FRONTEND="parser_x.o lexer_x.o typeck_x.o codegen_x.o x_frontend_link_alias.o"
_DRIVER_SUBCMD="driver_fmt_x.o driver_check_x.o driver_test_x.o driver_compile_x.o driver_build_x.o driver_run_x.o driver_emit_x.o"
_GLUE_SUFFIX="build_asm/pipeline_glue_strict_minimal.o"

# DRIVER_SEED_OBJS 展开（MAIN + runtime ABI + no_c runtime + x frontend + support + shims）
_DRIVER_SEED_OBJS="$_MAIN_LINK_O src/runtime_io_abi.o src/runtime_link_abi.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/diag.o src/runtime_pipeline_abi.o src/runtime_driver_no_c.o src/driver/fmt_check_cmd_driver.o src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o $_X_FRONTEND $_DRIVER_SEED_SUPPORT src/x_seed_bridge.o src/seed_link_compat.o"

# 最终链接 obj 序（与 make g05-export-relink 一致）
G05_OBJS="$_DRIVER_SEED_OBJS driver_x.o $_PIPELINE_LINK_O lsp_x.o lsp_diag_x.o lsp_io_x.o preprocess_x.o $_DRIVER_SUBCMD src/lsp/lsp_diag.o src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o lsp_io_std_heap_x.o $_USER_ASM_LINK $_GLUE_SUFFIX"

G05_CFLAGS="$_BASE_CFLAGS $_DRIVER_SEED_LINK_FLAGS $_ASM_GLUE_DUP_LDFLAGS $_MAIN_LINK_FLAGS"

# 供 ensure 使用的热路径（force 重编的 .c → .o）
G05_HOT_C_OBJS="src/runtime_link_abi.o src/runtime_driver_no_c.o build_asm/pipeline_glue_strict_minimal.o"

# shell 安全单引号转义
_sq() {
  printf "%s" "$1" | sed "s/'/'\\\\''/g"
}

echo "G05_CC='$(_sq "$G05_CC")'"
echo "G05_CFLAGS='$(_sq "$G05_CFLAGS")'"
echo "G05_OUT='$(_sq "$G05_OUT")'"
echo "G05_SHUX_C='$(_sq "$G05_SHUX_C")'"
echo "G05_BOOTSTRAP='$(_sq "$G05_BOOTSTRAP")'"
echo "G05_OBJS='$(_sq "$G05_OBJS")'"
echo "G05_HOT_C_OBJS='$(_sq "$G05_HOT_C_OBJS")'"
echo "G05_UNAME_S='$(_sq "$UNAME_S")'"
echo "G05_UNAME_M='$(_sq "$UNAME_M")'"
