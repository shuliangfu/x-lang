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

# Why: Windows MSYS2/MinGW ships gcc only (no cc alias). Honor caller-provided
#      $CC (Windows build envs export CC=gcc), then fall back to cc for POSIX.
#      Mirrors g05_ensure_relink_prereqs.sh L30 precedence. Without this the
#      hot-path cc -c in g05_ensure fails with "cc: command not found" on
#      Windows even when CC=gcc is exported.
G05_CC="${G05_CC:-${CC:-cc}}"
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
  # asm_experimental_symbol_bridge：Darwin weak 桩 platform_macho_write_macho_o_to_buf
  # （seed bridge weak_import 静态链必需；见 seeds/asm_experimental_symbol_bridge.from_x.c）
  _PIPELINE_LINK_O="build_asm/bootstrap_seed_pipeline_filtered.o"
  _USER_ASM_LINK="build_asm/seed_host/asm_backend_partial.o build_asm/seed_host/asm_full_link_stubs.o build_asm/bootstrap_seed_user_asm_seed_bridge_filtered.o build_asm/bootstrap_seed_asm_backend_compat_stubs_filtered.o build_asm/bootstrap_seed_backend_x86_64_enc_c_filtered.o build_asm/asm_experimental_symbol_bridge.o src/asm/backend_enc_dispatch.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o parser_asm_thin_glue.o src/asm/parser_asm_parse_expr_link.o"
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
  # PLATFORM: WINDOWS | MSYS | MINGW — mirror of Makefile SHUX_IS_WIN_HOST branch
  # (makefile L1988-1999). crt0_mingw.o entry, PE --stack 256MiB reserve
  # (MSYS default main thread stack ~2MiB overflows deep parse_into/typeck_x_ast
  # recursion), --allow-multiple-definition (PE has no weak function symbols;
  # SHUX_WEAK expands empty, stubs are strong — see include/shux_weak.h).
  # Topology mirrors Linux else-branch (pipeline_x.o + raw USER_ASM_SEED_OBJS;
  # Darwin-only filtered objs do not apply on PE). Single authority is the
  # Makefile; this shell branch is the G-05 product-path mirror (G.7).
  MINGW*|MSYS*|CYGWIN*)
  _ASM_GLUE_DUP_LDFLAGS="-Wl,--allow-multiple-definition"
  case "$UNAME_M" in
  x86_64|amd64)
  _MAIN_LINK_O="src/asm/crt0_mingw.o"
  _MAIN_LINK_FLAGS="-Wl,--stack,268435456"
  ;;
  *)
  _MAIN_LINK_O="src/main_driver.o"
  _MAIN_LINK_FLAGS=""
  ;;
  esac
  _PIPELINE_LINK_O="pipeline_x.o"
  _USER_ASM_LINK="build_asm/seed_host/asm_backend_partial.o build_asm/seed_host/asm_full_link_stubs.o src/asm/user_asm_seed_bridge.o src/asm/asm_backend_compat_stubs.o src/asm/backend_enc_dispatch.o src/asm/backend_x86_64_enc_c.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o parser_asm_thin_glue.o src/asm/parser_asm_parse_expr_link.o"
  ;;
  *)
  echo "g05_relink_env: unsupported host $UNAME_S/$UNAME_M (use Makefile cold path)" >&2
  exit 1
  ;;
esac

# DRIVER_SEED layout: mirror Makefile LEGACY vs no_c default.
# PLATFORM: SHARED — Makefile is the single authority (makefile L1843-1900).
# g05_relink_env is the shell mirror (G.7). On Linux/macOS the default no_c
# layout works (X pipeline self-contained). On Windows MSYS/MinGW the
# documented build env sets SHUX_LEGACY_C_FRONTEND=1 (see
# analysis/Windows平台限制与测试指南.md §3.2): shux-c.exe must use the C
# frontend runtime (runtime_driver.o + lexer.o + ast_seed.o +
# cfg_eval_bootstrap_stub.o + async_*), NOT the no_c runtime
# (runtime_driver_no_c.o + cfg_eval.o). The no_c runtime on Windows fails
# the X pipeline with XP001/XP003 (pipeline returned -1) because
# runtime_driver_no_c.o's driver dispatch does not match the Windows seed
# binary layout (the pinned bootstrap_shuxc was captured under LEGACY mode).
# Without this guard g05 relink-shux on Windows produced a shux.exe that
# links cleanly but cannot run even `function main(): i32 { return 42; }`.
# Honor SHUX_LEGACY_C_FRONTEND (=1 LEGACY; otherwise no_c default) and
# SHUX_NO_C_SEED_LINK (=1 forces no_c even under LEGACY — experimental).
if [ "${SHUX_NO_C_SEED_LINK:-0}" != "1" ] && [ "${SHUX_LEGACY_C_FRONTEND:-0}" = "1" ]; then
  # LEGACY mode: matches Makefile SHUX_LEGACY_C_FRONTEND=1 branch.
  # runtime_driver.o (not no_c), C lexer.o + ast_seed.o, cfg_eval_bootstrap_stub,
  # async liveness/cps_codegen. DRIVER_SEED_C_FRONTEND_LEGACY is empty (C
  # frontend deleted, G-02a) so DRIVER_SEED_FRONTEND_EXTRA is empty.
  _DRIVER_SEED_RUNTIME_O="src/runtime_driver.o"
  _LEXER_LINK_O="src/lexer/lexer.o"
  _AST_LINK_O="src/ast/ast_seed.o"
  # NOTE: runtime_driver_strict_glue_stubs.o is NOT here — it goes in _GLUE_SUFFIX
  # (link END) per Makefile L1936. See _GLUE_SUFFIX below for why.
  _DRIVER_SEED_SUPPORT="src/async/async_liveness.o src/async/async_cps_codegen.o src/lexer/cfg_eval_bootstrap_stub.o src/typeck/typeck_f64_bits.o"
else
  # no_c default (G-02a): X pipeline self-contained, no C lexer/ast.
  _DRIVER_SEED_RUNTIME_O="src/runtime_driver_no_c.o"
  _LEXER_LINK_O=""
  _AST_LINK_O=""
  # NOTE: runtime_driver_strict_glue_stubs.o is NOT here — it goes in _GLUE_SUFFIX
  # (link END) per Makefile L1936. See _GLUE_SUFFIX below for why.
  _DRIVER_SEED_SUPPORT="src/lexer/cfg_eval.o src/typeck/typeck_f64_bits.o"
fi
_X_FRONTEND="parser_x.o lexer_x.o typeck_x.o codegen_x.o x_frontend_link_alias.o"
_DRIVER_SUBCMD="driver_fmt_x.o driver_check_x.o driver_test_x.o driver_compile_x.o driver_build_x.o driver_run_x.o driver_emit_x.o"
# _GLUE_SUFFIX mirrors the Makefile target-specific DRIVER_SEED_GLUE_SUFFIX
# (makefile L2499/L2504, applies to bootstrap-driver-seed & shux-c LEGACY):
#   build_asm/pipeline_glue_strict_minimal.o src/runtime_driver_strict_glue_stubs.o
# Why runtime_driver_strict_glue_stubs.o at link END (not in _DRIVER_SEED_SUPPORT
# middle): stubs .o has symbols WITH real impls in pipeline_x.o (e.g.
# driver_get_module_num_funcs, parser_parse_into_init, pipeline_run_x_pipeline).
# On Windows PE --allow-multiple-definition FIRST-wins; linking stubs BEFORE
# pipeline_x.o makes the stub shadow the real impl → shux -c silently reports
# num_funcs=0 / pipeline returned -1 (XP001/XP003). On ELF/Darwin SHUX_WEAK=weak
# so real impl wins regardless of order. Moving stubs to link END (after
# pipeline_glue_strict_minimal.o, after all real impls) guarantees real impls
# win on PE. Mirrors Makefile L1863-1875 fix (2026-07-19 stubs move). G.7.
_GLUE_SUFFIX="build_asm/pipeline_glue_strict_minimal.o src/runtime_driver_strict_glue_stubs.o"

# Cap residual：与 Makefile RT_SEED_SLICE_OBJS / build_shux_asm asm_bootstrap_support_extra_link 同源。
# runtime_driver_abi 始终 extern 这些符号；no_c runtime 在 SHUX_RT_*_FROM_X 下不内嵌 BSS 定义。
# PLATFORM: SHARED — nm on runtime_driver_no_c.o shows U for driver_arena_buf /
# write_io_net_abi_inline / driver_x_emit_c_* / runtime_report_* after true L4 wipe.
# Always link RT seed slices (same list as Makefile). Omitting them (922487e5) made
# L2/L3 look green only when an old binary residual remained; L4 g05 link UNDEF.
# Do NOT empty this when no_c is U; if no_c ever merges strong defs, fix no_c merge
# first — do not leave slices empty as a "dup-symbol" workaround.
# 含 rt_parse_diag：runtime_report_parse_recovery_diagnostics（冷启动 no_c 为 U）
_RT_SEED_SLICE_OBJS="src/runtime/rt_arena_buf.o src/runtime/rt_emit_state.o src/runtime/rt_preamble.o src/runtime/rt_stack.o src/runtime/rt_parse_diag.o"
# DRIVER_SEED_OBJS 展开（MAIN + runtime ABI + no_c + process argv + rt slices + x frontend + support + shims）
# PLATFORM: SHARED — runtime_process_argv.o provides process_shux_argc/argv_get
# (Makefile DRIVER_SEED_OBJS). Without it g05 link fails U process_shux_* from
# runtime_link_abi.o process_args_*_c.
_DRIVER_SEED_OBJS="$_MAIN_LINK_O src/runtime_io_abi.o src/runtime_link_abi.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/diag.o src/runtime_pipeline_abi.o $_DRIVER_SEED_RUNTIME_O $_RT_SEED_SLICE_OBJS runtime_process_argv.o src/driver/fmt_check_cmd_driver.o src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o $_LEXER_LINK_O $_AST_LINK_O $_X_FRONTEND $_DRIVER_SEED_SUPPORT src/x_seed_bridge.o src/seed_link_compat.o"

# 最终链接 obj 序（与 make g05-export-relink 一致）
# ast_gen2.o: in LEGACY mode, append at link END (mirrors Makefile shux-c LEGACY L2501
# which ends with ast_gen2.o). ast_gen2.o provides ast_arena_* / ast_block_*
# used by the C frontend runtime (runtime_driver.o). In no_c default the X
# pipeline uses ast_ast_* (not ast_arena_*), so ast_gen2.o is not needed.
if [ "${SHUX_NO_C_SEED_LINK:-0}" != "1" ] && [ "${SHUX_LEGACY_C_FRONTEND:-0}" = "1" ]; then
  _AST_GEN2="ast_gen2.o"
else
  _AST_GEN2=""
fi
G05_OBJS="$_DRIVER_SEED_OBJS driver_x.o $_PIPELINE_LINK_O lsp_x.o lsp_diag_x.o lsp_io_x.o preprocess_x.o $_DRIVER_SUBCMD src/lsp/lsp_diag.o src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o lsp_io_std_heap_x.o $_USER_ASM_LINK $_GLUE_SUFFIX $_AST_GEN2"

G05_CFLAGS="$_BASE_CFLAGS $_DRIVER_SEED_LINK_FLAGS $_ASM_GLUE_DUP_LDFLAGS $_MAIN_LINK_FLAGS"

# NL-07 L10 / G-03: product default g05 chain aligns with build_shux_asm crt0 v5.
# PLATFORM: LINUX — when bootstrap_wants_nostdlib, drop host-implicit -lc (cc driver)
# by using -nostdlib -static + freestanding_io + bootstrap_nostdlib_stubs + weak atoi.
# G.7: policy from scripts/bootstrap_nostdlib_shared.sh (same as build_shux_asm).
# Ensure does not run here (eval purity); g05_ensure_relink_prereqs builds the objs.
# shellcheck disable=SC1091
. "$_G05_ROOT/scripts/bootstrap_nostdlib_shared.sh"
if bootstrap_wants_nostdlib; then
  case "$UNAME_S/$UNAME_M" in
  Linux/x86_64|Linux/amd64)
  _G05_NOSTDLIB_FLAGS="$(bootstrap_nostdlib_link_flags)"
  # Obj paths only (no ensure). atoi_stub always listed; ensure builds it.
  # runtime_panic T atoi skip is applied in ensure when CRT0_ATOI_LINK empty —
  # g05 bag has no runtime_panic.o, so atoi_stub.o is always required.
  _G05_NOSTDLIB_OBJS="src/asm/freestanding_io_x86_64.o src/asm/bootstrap_nostdlib_stubs.o atoi_stub.o"
  G05_CFLAGS="$G05_CFLAGS $_G05_NOSTDLIB_FLAGS"
  G05_OBJS="$G05_OBJS $_G05_NOSTDLIB_OBJS"
  ;;
  esac
fi

# 供 ensure 使用的热路径（force 重编的 .c → .o）
# Hot-path C rebuild targets. In no_c mode runtime_driver_no_c.o is hot;
# in LEGACY mode runtime_driver.o is hot (matches Makefile DRIVER_SEED_RUNTIME_REBUILD).
if [ "${SHUX_NO_C_SEED_LINK:-0}" != "1" ] && [ "${SHUX_LEGACY_C_FRONTEND:-0}" = "1" ]; then
  G05_HOT_C_OBJS="src/runtime_link_abi.o src/runtime_driver.o build_asm/pipeline_glue_strict_minimal.o"
else
  G05_HOT_C_OBJS="src/runtime_link_abi.o src/runtime_driver_no_c.o build_asm/pipeline_glue_strict_minimal.o"
fi

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
