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
# 仍走 Makefile 冷启动；本脚本服务日常 relink / xlang_asm 产品路径。

set -e
# Resolve compiler/ from this file's path — not $0 alone.
# When this file is `source`d (bash), $0 is the parent shell argv0 and
# dirname("$0")/.. can land on the *repo* root; Ubuntu then misses
# compiler/scripts/bootstrap_nostdlib_shared.sh (mac had an untracked
# repo scripts/ symlink that masked the bug).
# PLATFORM: SHARED — BASH_SOURCE when available; $0 for sh exec/eval.
# shellcheck disable=SC2128,SC3054
if [ -n "${BASH_SOURCE:-}" ]; then
  # bash: BASH_SOURCE[0] is this file even under `source`
  _G05_SELF="${BASH_SOURCE[0]}"
else
  _G05_SELF="$0"
fi
_G05_ROOT="$(CDPATH= cd -- "$(dirname "$_G05_SELF")/.." && pwd)"
cd "$_G05_ROOT"

UNAME_S="$(uname -s 2>/dev/null || echo Unknown)"
UNAME_M="$(uname -m 2>/dev/null || echo unknown)"

# Why: Windows MSYS2/MinGW ships gcc only (no cc alias). Honor caller-provided
#      $CC (Windows build envs export CC=gcc), then fall back to cc for POSIX.
#      Mirrors g05_ensure_relink_prereqs.sh L30 precedence. Without this the
#      hot-path cc -c in g05_ensure fails with "cc: command not found" on
#      Windows even when CC=gcc is exported.
G05_CC="${G05_CC:-${CC:-cc}}"
G05_OUT="${G05_OUT:-xlang}"
G05_XLANG_C="${G05_XLANG_C:-xlang-c}"
G05_BOOTSTRAP="${G05_BOOTSTRAP:-bootstrap_xlangc}"

# base cflags（与 Makefile CFLAGS 默认一致）
_BASE_CFLAGS="-Wall -Wextra -I. -Iinclude -Isrc"
_DRIVER_SEED_LINK_FLAGS="-DXLANG_USE_X_DRIVER -DXLANG_USE_X_PIPELINE -DXLANG_USE_X_TYPECK -DXLANG_USE_X_CODEGEN"

case "$UNAME_S" in
  Darwin)
  # PLATFORM: MACOS — `-multiply_defined` is obsolete on Apple ld (g05 pure-ld
  # warned every relink; experimental_bootstrap already cleared this). G.7
  # single authority owns duplicates; do not pass the dead flag via G05_CFLAGS.
  _ASM_GLUE_DUP_LDFLAGS=""
  case "$UNAME_M" in
  arm64|aarch64)
  # PLATFORM: MACOS arm64 — runtime_asm_io_stubs.o (XLANG_WEAK io twin) provides
  # xlang_sys_write/read/writev for src/runtime_driver_no_c.o: rt_entry.x is
  # SHARED and since Cap 9.1.8 declares `export extern xlang_sys_write` (raw
  # write leaf). The freestanding_io strong twin is Linux-x86_64-only asm, so
  # without this slot the Darwin g05 pure-ld fails U _xlang_sys_write from
  # _rt_entry_strlen. G.7: same face as the Linux MAIN_LINK_O freestanding_io
  # slot; the weak twin loses to any strong twin when both are linked.
  _MAIN_LINK_O="src/asm/crt0_arm64.o runtime_asm_io_stubs.o"
  _MAIN_LINK_FLAGS="-e _start -nostartfiles"
  ;;
  x86_64|amd64)
  # PLATFORM: MACOS x86_64 — same xlang_sys_* provider slot as arm64 above
  # (rt_entry.x SHARED Cap 9.1.8 leaf; freestanding_io is Linux-only).
  _MAIN_LINK_O="src/asm/crt0_darwin_x86_64.o runtime_asm_io_stubs.o"
  _MAIN_LINK_FLAGS="-e _start -nostartfiles"
  ;;
  *)
  _MAIN_LINK_O="src/main_driver.o"
  _MAIN_LINK_FLAGS=""
  ;;
  esac
  # wave309 G.7 8.3 floor: product pipeline_x / filtered mega retired (0 residual
  # product T after Cap/domain leave; only gen weak io_register stub — duplicated).
  # Darwin historically linked bootstrap_seed_pipeline_filtered.o; empty keep after
  # leave made filter --require-keep fail. Live faces = runtime_pipeline_abi pure/seed.
  # asm_experimental_symbol_bridge：Darwin weak 桩 platform_macho_write_macho_o_to_buf
  # （seed bridge weak_import 静态链必需；见 seeds/asm_experimental_symbol_bridge.from_x.c）
  # PLATFORM: MACOS product pure-ld — no pipeline mega .o.
  _PIPELINE_LINK_O=""
  # PLATFORM: MACOS — backend_arm64_enc_c.o strong arch_arm64_enc_* override weak -1 stubs (CG002).
  _USER_ASM_LINK="build_asm/seed_host/asm_backend_partial.o build_asm/seed_host/asm_full_link_stubs.o build_asm/bootstrap_seed_user_asm_seed_bridge_filtered.o build_asm/bootstrap_seed_asm_backend_compat_stubs_filtered.o build_asm/bootstrap_seed_backend_x86_64_enc_c_filtered.o src/asm/backend_arm64_enc_c.o build_asm/asm_experimental_symbol_bridge.o src/asm/backend_enc_dispatch.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o parser_asm_thin_glue.o src/asm/parser_asm_parse_expr_link.o"
  ;;
  Linux)
  _ASM_GLUE_DUP_LDFLAGS="-Wl,--allow-multiple-definition"
  case "$UNAME_M" in
  x86_64|amd64)
  # PLATFORM: LINUX x86_64 — mirror mk/driver_seed_link_picks.mk MAIN_LINK_O.
  # freestanding_io provides xlang_sys_* for pure-ld (driver_x std.sys UNDEFs);
  # -lc alone cannot resolve them. G.7: same face as catalog MAIN_LINK.
  _MAIN_LINK_O="src/asm/crt0_x86_64.o src/asm/freestanding_io_x86_64.o"
  _MAIN_LINK_FLAGS="-no-pie -e _start -nostartfiles"
  ;;
  *)
  _MAIN_LINK_O="src/main_driver.o"
  _MAIN_LINK_FLAGS=""
  ;;
  esac
  # wave309 G.7 8.3 floor: product pipeline_x.o retired (empty mega; pure/seed owns faces).
  # Linux historically linked pipeline_x.o; now empty. PLATFORM: LINUX product pure-ld.
  _PIPELINE_LINK_O=""
  _USER_ASM_LINK="build_asm/seed_host/asm_backend_partial.o build_asm/seed_host/asm_full_link_stubs.o src/asm/user_asm_seed_bridge.o src/asm/asm_backend_compat_stubs.o src/asm/backend_enc_dispatch.o src/asm/backend_x86_64_enc_c.o src/asm/backend_arm64_enc_c.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o parser_asm_thin_glue.o src/asm/parser_asm_parse_expr_link.o"
  ;;
  # PLATFORM: WINDOWS | MSYS | MINGW — mirror of Makefile XLANG_IS_WIN_HOST branch
  # (makefile L1988-1999). crt0_mingw.o entry, PE --stack 256MiB reserve
  # (MSYS default main thread stack ~2MiB overflows deep parse_into/typeck_x_ast
  # recursion), --allow-multiple-definition (PE has no weak function symbols;
  # XLANG_WEAK expands empty, stubs are strong — see include/xlang_weak.h).
  # wave309: topology mirrors Linux (empty pipeline mega + raw USER_ASM_SEED_OBJS).
  # Darwin-only filtered objs do not apply on PE). Single authority is the
  # Makefile; this shell branch is the G-05 product-path mirror (G.7).
  Windows_NT*|MINGW*|MSYS*|CYGWIN*)
  _ASM_GLUE_DUP_LDFLAGS="-Wl,--allow-multiple-definition"
  case "$UNAME_M" in
  x86_64|amd64)
  # PLATFORM: WINDOWS — same xlang_sys_* provider slot as Darwin: rt_entry.x is
  # SHARED and since Cap 9.1.8 references xlang_sys_write (freestanding_io
  # strong twin is Linux-x86_64-only). PE XLANG_WEAK expands empty (strong def)
  # and --allow-multiple-definition is first-wins, so a real strong twin linked
  # ahead would still win. Needs MSYS2 gate confirmation (not covered by
  # macOS/Ubuntu L2).
  _MAIN_LINK_O="src/asm/crt0_mingw.o runtime_asm_io_stubs.o"
  _MAIN_LINK_FLAGS="-Wl,--stack,268435456"
  ;;
  *)
  _MAIN_LINK_O="src/main_driver.o"
  _MAIN_LINK_FLAGS=""
  ;;
  esac
  # wave309: empty pipeline mega on Windows product path too.
  _PIPELINE_LINK_O=""
  # PLATFORM: WINDOWS | MSYS | MINGW — PE XLANG_WEAK is empty (strong stubs) and
  # --allow-multiple-definition is FIRST-wins (see include/xlang_weak.h + _GLUE_SUFFIX).
  # Real arch_*_enc_* bodies (backend_x86_64_enc_c.o) MUST precede asm_full_link_stubs.o
  # and asm_backend_compat_stubs.o; otherwise stub arch_x86_64_enc_enc_label (mov $-1;ret)
  # wins → mega_body_c enc_label fail → CG002 code_len=0 on every user -backend asm.
  # Linux ELF keeps stubs-first (weak override). Darwin uses filtered objs + weak.
  _USER_ASM_LINK="build_asm/seed_host/asm_backend_partial.o src/asm/backend_x86_64_enc_c.o src/asm/backend_arm64_enc_c.o src/asm/user_asm_seed_bridge.o src/asm/backend_enc_dispatch.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o src/asm/asm_backend_compat_stubs.o build_asm/seed_host/asm_full_link_stubs.o parser_asm_thin_glue.o src/asm/parser_asm_parse_expr_link.o"
  ;;
  *)
  echo "g05_relink_env: unsupported host $UNAME_S/$UNAME_M (use ./xbuild bootstrap-driver-seed cold path)" >&2
  exit 1
  ;;
esac
# PLATFORM: LINUX | WINDOWS — arch_x86_64_enc_enc_cltd still emits cltd
# (99) in the linked encoder object. idiv %rbx is 64-bit (48 f7 fb), so
# the live sign-extend has to be cqo (48 99). This one-symbol object is
# linked first. Linux: ahead of backend_x86_64_enc_c.o. Windows: ahead of
# backend_enc_dispatch.o (PE first strong definition wins). Darwin is
# arm64 and must not link this COFF/ELF object. Rebuilding the whole x86
# encoder TU changes its other symbols. Absent file keeps the previous
# sign-extend.
case "$UNAME_S" in
  Linux|MINGW*|MSYS*|CYGWIN*|Windows_NT*)
    if [ -s build_asm/selfhost_pabi/cltd_cqo.o ]; then
      _USER_ASM_LINK="build_asm/selfhost_pabi/cltd_cqo.o $_USER_ASM_LINK"
    fi
    # PLATFORM: LINUX | WINDOWS — bare sub rsp,imm32 > 1 page skips the
    # Windows guard page (SEGV on deep AS/compare folds). This object
    # replaces arch_x86_64_enc_enc_prologue with a probed allocator.
    # PE first-wins: must precede backend_enc_dispatch.o /
    # backend_x86_64_enc_c.o. Absent file keeps the unprobed prologue.
    if [ -s build_asm/selfhost_pabi/prologue_chkstk.o ]; then
      _USER_ASM_LINK="build_asm/selfhost_pabi/prologue_chkstk.o $_USER_ASM_LINK"
    fi
    ;;
esac

# DRIVER_SEED layout: mirror Makefile LEGACY vs no_c default.
# PLATFORM: SHARED — Makefile is the single authority (makefile L1843-1900).
# g05_relink_env is the shell mirror (G.7). On Linux/macOS the default no_c
# layout works (X pipeline self-contained). On Windows MSYS/MinGW the
# documented build env sets XLANG_LEGACY_C_FRONTEND=1 (see
# analysis/Windows平台限制与测试指南.md §3.2): xlang-c.exe must use the C
# frontend runtime (runtime_driver.o + lexer.o + ast_seed.o +
# cfg_eval_bootstrap_stub.o + async_*), NOT the no_c runtime
# (runtime_driver_no_c.o + cfg_eval.o). The no_c runtime on Windows fails
# the X pipeline with XP001/XP003 (pipeline returned -1) because
# runtime_driver_no_c.o's driver dispatch does not match the Windows seed
# binary layout (the pinned bootstrap_xlangc was captured under LEGACY mode).
# Without this guard g05 relink-xlang on Windows produced a xlang.exe that
# links cleanly but cannot run even `function main(): i32 { return 42; }`.
# Class S / leftover-safe (2026-09-22): Windows PE product path must use LEGACY
# runtime_driver.o (Win64 argc/argv). Unset XLANG_LEGACY_C_FRONTEND used to fall
# through to no_c → SysV driver_run_compiler_full → --help SEGV in driver_argv_at,
# so FIELD override never landed in a runnable live. Default LEGACY=1 on Win hosts
# when unset; XLANG_NO_C_SEED_LINK=1 still forces no_c; explicit =0 still allowed.
case "$(uname -s 2>/dev/null || echo Unknown)" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT*)
    if [ -z "${XLANG_LEGACY_C_FRONTEND+x}" ]; then
      XLANG_LEGACY_C_FRONTEND=1
    fi
    ;;
esac
# Honor XLANG_LEGACY_C_FRONTEND (=1 LEGACY; otherwise no_c default) and
# XLANG_NO_C_SEED_LINK (=1 forces no_c even under LEGACY — experimental).
if [ "${XLANG_NO_C_SEED_LINK:-0}" != "1" ] && [ "${XLANG_LEGACY_C_FRONTEND:-0}" = "1" ]; then
  # LEGACY mode: matches Makefile XLANG_LEGACY_C_FRONTEND=1 branch.
  # runtime_driver.o (not no_c), C lexer.o + ast_seed.o, cfg_eval_bootstrap_stub,
  # async liveness/cps_codegen. DRIVER_SEED_C_FRONTEND_LEGACY is empty (C
  # frontend deleted, G-02a) so DRIVER_SEED_FRONTEND_EXTRA is empty.
  _DRIVER_SEED_RUNTIME_O="src/runtime_driver.o"
  _LEXER_LINK_O="src/lexer/lexer.o"
  _AST_LINK_O="src/ast/ast_seed.o"
  # NOTE: runtime_driver_strict_glue_stubs.o is NOT here — it goes in _GLUE_SUFFIX
  # (link END) per Makefile L1936. See _GLUE_SUFFIX below for why.
  # async_asm_pool: unbundled from pipeline_glue (2026-07-21); asm CPS layout.
  _DRIVER_SEED_SUPPORT="src/async/async_liveness.o src/async/async_cps_codegen.o src/async/async_asm_pool.o src/lexer/cfg_eval_bootstrap_stub.o src/typeck/typeck_f64_bits.o"
else
  # no_c default (G-02a): X pipeline self-contained, no C lexer/ast.
  _DRIVER_SEED_RUNTIME_O="src/runtime_driver_no_c.o"
  _LEXER_LINK_O=""
  _AST_LINK_O=""
  # NOTE: runtime_driver_strict_glue_stubs.o is NOT here — it goes in _GLUE_SUFFIX
  # (link END) per Makefile L1936. See _GLUE_SUFFIX below for why.
  # async_asm_pool: unbundled from pipeline_glue; required in no_c product link too.
  _DRIVER_SEED_SUPPORT="src/async/async_asm_pool.o src/lexer/cfg_eval.o src/typeck/typeck_f64_bits.o"
fi
_X_FRONTEND="parser_x.o lexer_x.o typeck_x.o codegen_x.o x_frontend_link_alias.o"
_DRIVER_SUBCMD="driver_fmt_x.o driver_check_x.o driver_test_x.o driver_compile_x.o driver_build_x.o driver_run_x.o driver_emit_x.o"
# _GLUE_SUFFIX: stubs only at link END.
# wave304 G.7 8.3.6: pipeline_glue_strict_minimal seed shell retired (0 residual T
# after wave303 overload leave → typeck_x). Product no longer host-cc or links
# that empty shell. Historical: strict_minimal + stubs was DRIVER_SEED_GLUE_SUFFIX.
# Why runtime_driver_strict_glue_stubs.o at link END (not in _DRIVER_SEED_SUPPORT
# middle): stubs .o has symbols WITH real impls in runtime_pipeline_abi / pure
# (historical: pipeline_x.o). wave309 retired product pipeline_x mega.
# On Windows PE --allow-multiple-definition FIRST-wins; stubs AFTER real impls.
# On ELF/Darwin XLANG_WEAK=weak so real impl wins regardless of order.
# PLATFORM: SHARED freestanding 8.3.6 shell retire + wave309 pipeline mega retire.
_GLUE_SUFFIX="src/runtime_driver_strict_glue_stubs.o"

# Cap residual：与 Makefile RT_SEED_SLICE_OBJS / build_xlang_asm asm_bootstrap_support_extra_link 同源。
# runtime_driver_abi 始终 extern 这些符号；no_c runtime 在 XLANG_RT_*_FROM_X 下不内嵌 BSS 定义。
# PLATFORM: SHARED — nm on runtime_driver_no_c.o shows U for driver_arena_buf /
# write_io_net_abi_inline / driver_x_emit_c_* / runtime_report_* after true L4 wipe.
# Always link RT seed slices (same list as Makefile). Omitting them (922487e5) made
# L2/L3 look green only when an old binary residual remained; L4 g05 link UNDEF.
# Do NOT empty this when no_c is U; if no_c ever merges strong defs, fix no_c merge
# first — do not leave slices empty as a "dup-symbol" workaround.
# 含 rt_parse_diag：runtime_report_parse_recovery_diagnostics（冷启动 no_c 为 U）
_RT_SEED_SLICE_OBJS="src/runtime/rt_arena_buf.o src/runtime/rt_emit_state.o src/runtime/rt_preamble.o src/runtime/rt_stack.o src/runtime/rt_parse_diag.o"
# DRIVER_SEED_OBJS 展开（MAIN + runtime ABI + no_c + process argv + rt slices + x frontend + support + shims）
# PLATFORM: SHARED — runtime_process_argv.o provides process_xlang_argc/argv_get
# (Makefile DRIVER_SEED_OBJS). Without it g05 link fails U process_xlang_* from
# runtime_link_abi.o process_args_*_c.
# wave742: leftover WAVE274 cap sidecar first-wins over leftover 2048 weak
# (Darwin strong vs weak; LINUX --allow-multiple-definition). Do not ld -r
# merge into pabi (Darwin libtool n_sect). HARD BAN PREFER asm_wpo_thin
# (w744: n_sect closed; live thin WPO is CG002 code_len=0). Do not prepend
# src/runtime_pipeline_abi_asm_wpo_thin.o.
# PLATFORM: SHARED leftover gcc sidecar · LINUX gold · MACOS co-path.
# wave745: PREFER asm_wpo_thin first-wins leftover WPO (4096 cap in the
# thin). leftover-gcc cap sidecar is fallback only when the thin .o is
# absent. Do not prepend both (two WPO BSS homes). Do not ld -r into pabi.
# PLATFORM: SHARED PREFER_ASM sidecar · LINUX gold · MACOS co-path.
_PABI_WPO_CAP=""
_PABI_WPO_THIN=""
if [ -s src/runtime_pipeline_abi_asm_wpo_thin.o ]; then
  _PABI_WPO_THIN="src/runtime_pipeline_abi_asm_wpo_thin.o"
elif [ -s src/runtime_pipeline_abi_asm_wpo_cap.o ]; then
  _PABI_WPO_CAP="src/runtime_pipeline_abi_asm_wpo_cap.o"
fi
# wave743: leftover gcc append_reloc_typed sidecar (PAGE21 owner bind).
# Strong T first-wins leftover gcc weak T that COMMON lea calls. Do not
# ld -r into pabi. PLATFORM: SHARED leftover gcc sidecar · MACOS writer.
_PABI_RELOC_TYPED=""
if [ -s src/runtime_pipeline_abi_reloc_typed.o ]; then
  _PABI_RELOC_TYPED="src/runtime_pipeline_abi_reloc_typed.o"
fi
# wave744: leftover gcc F7 data_len sidecar (dual BSS). Strong T first-wins
# leftover gcc weak emit/append/poke so compact macho_write sees bake.
# Do not ld -r into pabi. PLATFORM: SHARED leftover gcc sidecar · MACOS writer.
_PABI_DATA_LEN=""
if [ -s src/runtime_pipeline_abi_data_len.o ]; then
  _PABI_DATA_LEN="src/runtime_pipeline_abi_data_len.o"
fi
# wave745: leftover gcc const_lit is_const + load_operand file-level let
# fallback. Strong T first-wins leftover gcc weak. Do not ld -r into pabi.
# PLATFORM: SHARED leftover gcc sidecar · LINUX gold · MACOS co-path.
_PABI_CONST_LIT=""
if [ -s src/runtime_pipeline_abi_const_lit.o ]; then
  _PABI_CONST_LIT="src/runtime_pipeline_abi_const_lit.o"
fi
# wave767 Class R: Win PE assign overrides FIRST (allow-multiple first-wins).
# var + field + index + deref scalar. Built by g05_ensure when seeds present.
# PLATFORM: WINDOWS | MSYS | MINGW only — Darwin/Linux ignore.
_WIN_ASSIGN_OVERRIDES=""
case "$UNAME_S" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT*)
    for _wov in src/win_assign_var_override.o src/win_assign_field_override.o src/win_assign_index_override.o src/win_assign_deref_override.o src/win_struct_let_init_override.o src/win_copy_large_struct_override.o src/win_simd_splat_override.o src/win_vector_type_let_init_override.o src/win_simd_select_shuffle_fma_override.o src/win_asm_parser_override.o src/win_m8_tail_override.o src/win_wpo_collect_walk_override.o src/win_wpo_pgo_emit_override.o src/win_index_elem_byte_sz_override.o; do
      if [ -s "$_wov" ]; then
        _WIN_ASSIGN_OVERRIDES="$_WIN_ASSIGN_OVERRIDES $_wov"
      fi
    done
    # w1013: bake tip packs module i8; INDEX tip esz=1 (win_index). assign /
    # emit / force_esz true_i8 tips parked on WINDOWS (jmp/CG002). PLATFORM: WINDOWS.
    ;;
esac
# w943: self-hosted pabi bodies ahead of src/runtime_pipeline_abi.o.
# Linux first-wins (--allow-multiple-definition) keeps these strong
# definitions. The stale frames stay in that .o; do not PREFER into it
# and do not gcc -E them onto a page. Built by
# scripts/linux_selfhost_pabi_sidecars.sh. Absent directory → old list.
# PLATFORM: LINUX — ELF sidecars. Darwin and Windows leave this empty.
_PABI_SELFHOST=""
if [ "$UNAME_S" = "Linux" ] && [ -f build_asm/selfhost_pabi/READY ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/slot.o build_asm/selfhost_pabi/esz.o build_asm/selfhost_pabi/loc.o build_asm/selfhost_pabi/lea.o build_asm/selfhost_pabi/rec.o build_asm/selfhost_pabi/two.o build_asm/selfhost_pabi/one.o build_asm/selfhost_pabi/as.o build_asm/selfhost_pabi/sizeof.o"
  for _sh in build_asm/selfhost_pabi/slot.o build_asm/selfhost_pabi/esz.o build_asm/selfhost_pabi/loc.o build_asm/selfhost_pabi/lea.o build_asm/selfhost_pabi/rec.o build_asm/selfhost_pabi/two.o build_asm/selfhost_pabi/one.o build_asm/selfhost_pabi/as.o build_asm/selfhost_pabi/sizeof.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_cast_orch_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_f2i32_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_f2i64_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_f2i_orch_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_i2f32_i32_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_i2f32_i64_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_i2f32_i64mov_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_i2f32_k15_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_i2f32_orch_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_i2f32_sf64_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_i2f32_u64_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_i2f64_f32_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_i2f64_i32_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_i2f64_i64_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_i2f64_i64mov_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_i2f64_orch_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_i2f64_u64_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_lea_thin.o; do
    if [ ! -s "$_sh" ]; then
      echo "g05_relink_env: missing $_sh; self-host sidecars dropped" >&2
      _PABI_SELFHOST=""
      break
    fi
  done
  if [ -n "$_PABI_SELFHOST" ]; then
    # Peer arms are not in runtime_pipeline_abi.o. They must be on the
    # list or pipeline_asm_emit_as_elf_impl cannot resolve them.
    _PABI_SELFHOST="$_PABI_SELFHOST build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_cast_orch_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_f2i32_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_f2i64_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_f2i_orch_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_i2f32_i32_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_i2f32_i64_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_i2f32_i64mov_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_i2f32_k15_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_i2f32_orch_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_i2f32_sf64_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_i2f32_u64_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_i2f64_f32_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_i2f64_i32_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_i2f64_i64_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_i2f64_i64mov_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_i2f64_orch_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_i2f64_u64_thin.o build_asm/selfhost_pabi/runtime_pipeline_abi_fnptr_as_lea_thin.o"
  fi
fi
# w944: module-level INDEX base. Missing trio keeps the w943 list and the
# original runtime_pipeline_abi.o (assign/spill bytes stay in that file).
# PLATFORM: LINUX
_PABI_LINK_O="src/runtime_pipeline_abi.o"
if [ -n "$_PABI_SELFHOST" ] \
  && [ -s build_asm/selfhost_pabi/base.o ] \
  && [ -s build_asm/selfhost_pabi/spill.o ] \
  && [ -s build_asm/selfhost_pabi/pabi_alias.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/base.o build_asm/selfhost_pabi/spill.o $_PABI_SELFHOST"
  _PABI_LINK_O="build_asm/selfhost_pabi/pabi_alias.o"
fi
# w945: compiler-emitted pipeline_asm_emit_assign_elf_c. The gcc body
# returns 0 after the pointer peel and never emits scalar `*p = v`.
# A missing file keeps the w944 list. Do not PREFER this into the .o.
# PLATFORM: LINUX
if [ -n "$_PABI_SELFHOST" ] && [ -s build_asm/selfhost_pabi/assign.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/assign.o $_PABI_SELFHOST"
fi
# w946: compiler-emitted modlet family. Module `let g: [2]S = [S { v: 1 },
# S { v: 2 }]` used to abort in the scalar baker. The whole family shares
# one table, so the object stays intact. A missing file keeps the w945
# list. Do not PREFER this into the .o.
# PLATFORM: LINUX
if [ -n "$_PABI_SELFHOST" ] && [ -s build_asm/selfhost_pabi/modlet.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/modlet.o $_PABI_SELFHOST"
fi
# w1007: Cap residual struct field load_sz → 4. First-wins over pabi.
# PLATFORM: LINUX
if [ -n "$_PABI_SELFHOST" ] && [ -s build_asm/selfhost_pabi/field_cap_residual_load.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/field_cap_residual_load.o $_PABI_SELFHOST"
fi
# w1009: let-after-assign stmt_order (pass1 deferred lets). First-wins.
# PLATFORM: LINUX
if [ -n "$_PABI_SELFHOST" ] && [ -s build_asm/selfhost_pabi/body_sync_let_order.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/body_sync_let_order.o $_PABI_SELFHOST"
fi
# w1012: true-pack ARRAY i8 INDEX esz=1 + sext8 emit_index. First-wins.
# bake_elems + bake_struct are the Darwin/Win baker twins; on Linux they
# first-win the bake face when modlet.o cannot rebuild (T001). They
# cross-call; both must link. Prefer ahead of other pabi sidecars.
# PLATFORM: LINUX
if [ -n "$_PABI_SELFHOST" ] && [ -s build_asm/selfhost_pabi/bake_struct.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/bake_struct.o $_PABI_SELFHOST"
fi
if [ -n "$_PABI_SELFHOST" ] && [ -s build_asm/selfhost_pabi/bake_elems.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/bake_elems.o $_PABI_SELFHOST"
fi
if [ -n "$_PABI_SELFHOST" ] && [ -s build_asm/selfhost_pabi/index_elem_true_i8.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/index_elem_true_i8.o $_PABI_SELFHOST"
fi
if [ -n "$_PABI_SELFHOST" ] && [ -s build_asm/selfhost_pabi/emit_index_true_i8.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/emit_index_true_i8.o $_PABI_SELFHOST"
fi
if [ -n "$_PABI_SELFHOST" ] && [ -s build_asm/selfhost_pabi/assign_index_true_i8.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/assign_index_true_i8.o $_PABI_SELFHOST"
fi
if [ -n "$_PABI_SELFHOST" ] && [ -s build_asm/selfhost_pabi/force_esz_true_i8.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/force_esz_true_i8.o $_PABI_SELFHOST"
fi
# w959: module INDEX store. Darwin pabi calls the cold lea, which misses
# the live table and faults. The forwarder is the cold name and calls the
# live function. Darwin ld has no multidef, so the cold symbol in a copy
# of pabi is weakened; the original runtime_pipeline_abi.o stays untouched.
# Windows GNU ld is first-wins, so the forwarder alone is enough.
# PLATFORM: MACOS|DARWIN — needs both objects. A missing file keeps pabi.
if [ "$UNAME_S" = "Darwin" ] \
  && [ -s build_asm/selfhost_pabi/lea_cold_fwd.o ] \
  && [ -s build_asm/selfhost_pabi/pabi_weak.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/lea_cold_fwd.o $_PABI_SELFHOST"
  # Folder. Strong beats the weak gcc body in pabi_weak.o.
  # Return 3 writes a real high half through out_hi.
  # Return 4 stores one f32 bit pattern in the low word.
  # An f32 ADD, SUB, MUL, or DIV is that same word. 1.0f + 2.0f is
  # 00004040. Return 5 stores both f64 halves. 1.0 is
  # 000000000000f03f. Missing file keeps the weak body (u8/bool stay unfolded).
  # PLATFORM: MACOS|DARWIN — do not add this object on Linux.
  if [ -s build_asm/selfhost_pabi/elem_const.o ]; then
    _PABI_SELFHOST="build_asm/selfhost_pabi/elem_const.o $_PABI_SELFHOST"
  fi
  # w971/w972/w974: 8-byte elems. Return 1 sign-fills. Return 2 writes
  # a zero high half for [2^31, 2^32). Return 3 stores out_hi.
  # Return 4 is an f32 word and does not sign-fill.
  # Return 5 stores both f64 halves and does not sign-fill.
  # 1.0 is 000000000000f03f. 0.1 keeps its real high word.
  # A missing file keeps the weak baker.
  # PLATFORM: MACOS|DARWIN — do not add this object on Linux or Windows.
  if [ -s build_asm/selfhost_pabi/bake_elems.o ]; then
    _PABI_SELFHOST="build_asm/selfhost_pabi/bake_elems.o $_PABI_SELFHOST"
  fi
  # STRUCT_LIT elements. The array baker calls this object. A missing
  # file leaves struct elements unfolded. Do not link it on Linux:
  # Ubuntu's modlet.o already bakes struct fields.
  # PLATFORM: MACOS|DARWIN.
  if [ -s build_asm/selfhost_pabi/bake_struct.o ]; then
    _PABI_SELFHOST="build_asm/selfhost_pabi/bake_struct.o $_PABI_SELFHOST"
  fi
  # w1007: Cap residual struct field load_sz → 4 (LDRSW / esz-4 cells).
  # Strong beats pabi_weak glue + load_byte_sz. PLATFORM: MACOS|DARWIN.
  if [ -s build_asm/selfhost_pabi/field_cap_residual_load.o ]; then
    _PABI_SELFHOST="build_asm/selfhost_pabi/field_cap_residual_load.o $_PABI_SELFHOST"
  fi
  # w1009: let-after-assign body_sync. Leftover body_sync is strong T in
  # pabi_weak — weaken so strong thin first-wins for same-TU callers too.
  # Prefer --weaken-symbol (works with Homebrew llvm-objcopy); redefine only
  # if still strong (redefine keeps same-TU bl on the dead body — wrong).
  # PLATFORM: MACOS|DARWIN.
  if [ -s build_asm/selfhost_pabi/body_sync_let_order.o ]; then
    _oc=""
    if command -v llvm-objcopy >/dev/null 2>&1; then
      _oc=llvm-objcopy
    elif [ -x /opt/homebrew/opt/llvm/bin/llvm-objcopy ]; then
      _oc=/opt/homebrew/opt/llvm/bin/llvm-objcopy
    elif [ -x /usr/local/opt/llvm/bin/llvm-objcopy ]; then
      _oc=/usr/local/opt/llvm/bin/llvm-objcopy
    elif command -v objcopy >/dev/null 2>&1; then
      _oc=objcopy
    fi
    if [ -n "$_oc" ] && [ -s build_asm/selfhost_pabi/pabi_weak.o ]; then
      for _bsym in _pipeline_asm_emit_block_body_sync_elf _backend_emit_block_body_sync_elf; do
        if nm -m build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null | grep -F "$_bsym" | grep -qv weak; then
          "$_oc" --weaken-symbol="$_bsym" build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
      done
    fi
    _PABI_SELFHOST="build_asm/selfhost_pabi/body_sync_let_order.o $_PABI_SELFHOST"
  fi
  # w1012: true-pack ARRAY i8 (INDEX esz=1 + sext8 load). Strong tip over
  # weak pabi emit_index; weaken leftover strong index_elem_byte_sz_c.
  # PLATFORM: MACOS|DARWIN.
  if [ -s build_asm/selfhost_pabi/index_elem_true_i8.o ]; then
    _oc=""
    if command -v llvm-objcopy >/dev/null 2>&1; then
      _oc=llvm-objcopy
    elif [ -x /opt/homebrew/opt/llvm/bin/llvm-objcopy ]; then
      _oc=/opt/homebrew/opt/llvm/bin/llvm-objcopy
    elif [ -x /usr/local/opt/llvm/bin/llvm-objcopy ]; then
      _oc=/usr/local/opt/llvm/bin/llvm-objcopy
    elif command -v objcopy >/dev/null 2>&1; then
      _oc=objcopy
    fi
    if [ -n "$_oc" ] && [ -s build_asm/selfhost_pabi/pabi_weak.o ]; then
      for _isym in _pipeline_asm_index_elem_byte_sz_c _glue_index_elem_byte_sz_from_type_ref_c \
        _pipeline_asm_index_elem_byte_sz _pipeline_asm_emit_index_elf_c \
        _glue_emit_index_load_arms_elf_c; do
        if nm -m build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null | grep -F "$_isym" | grep -qv weak; then
          "$_oc" --weaken-symbol="$_isym" build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
      done
    fi
    _PABI_SELFHOST="build_asm/selfhost_pabi/index_elem_true_i8.o $_PABI_SELFHOST"
  fi
  if [ -s build_asm/selfhost_pabi/emit_index_true_i8.o ]; then
    _PABI_SELFHOST="build_asm/selfhost_pabi/emit_index_true_i8.o $_PABI_SELFHOST"
  fi
  if [ -s build_asm/selfhost_pabi/assign_index_true_i8.o ]; then
    _oc=""
    if command -v llvm-objcopy >/dev/null 2>&1; then
      _oc=llvm-objcopy
    elif [ -x /opt/homebrew/opt/llvm/bin/llvm-objcopy ]; then
      _oc=/opt/homebrew/opt/llvm/bin/llvm-objcopy
    elif [ -x /usr/local/opt/llvm/bin/llvm-objcopy ]; then
      _oc=/usr/local/opt/llvm/bin/llvm-objcopy
    elif command -v objcopy >/dev/null 2>&1; then
      _oc=objcopy
    fi
    if [ -n "$_oc" ] && [ -s build_asm/selfhost_pabi/pabi_weak.o ]; then
      for _asym in _glue_emit_assign_index_elf_c; do
        if nm -m build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null | grep -F "$_asym" | grep -qv weak; then
          "$_oc" --weaken-symbol="$_asym" build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
      done
    fi
    _PABI_SELFHOST="build_asm/selfhost_pabi/assign_index_true_i8.o $_PABI_SELFHOST"
  fi
  if [ -s build_asm/selfhost_pabi/force_esz_true_i8.o ]; then
    _oc=""
    if command -v llvm-objcopy >/dev/null 2>&1; then
      _oc=llvm-objcopy
    elif [ -x /opt/homebrew/opt/llvm/bin/llvm-objcopy ]; then
      _oc=/opt/homebrew/opt/llvm/bin/llvm-objcopy
    elif [ -x /usr/local/opt/llvm/bin/llvm-objcopy ]; then
      _oc=/usr/local/opt/llvm/bin/llvm-objcopy
    elif command -v objcopy >/dev/null 2>&1; then
      _oc=objcopy
    fi
    if [ -n "$_oc" ] && [ -s build_asm/selfhost_pabi/pabi_weak.o ]; then
      for _fsym in _glue_array_lit_force_esz_from_elem_type_c; do
        if nm -m build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null | grep -F "$_fsym" | grep -qv weak; then
          "$_oc" --weaken-symbol="$_fsym" build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
      done
    fi
    _PABI_SELFHOST="build_asm/selfhost_pabi/force_esz_true_i8.o $_PABI_SELFHOST"
  fi
  _PABI_LINK_O="build_asm/selfhost_pabi/pabi_weak.o"
fi
# PLATFORM: WINDOWS | MSYS | MINGW — first strong cold lea wins.
# elem_const.o is the folder. The egg no longer defines it.
# Return 3 stores the high half the egg baker reads from out_hi.
# Return 4 is the f32 word, including an f32 ADD, SUB, MUL, or DIV.
# The egg baker does not sign-fill it. 1.0f + 2.0f is 00004040.
# Return 5 is both f64 halves. The egg baker copies out_hi and does
# not sign-fill a negative low word. 1.0 is 000000000000f03f.
case "$UNAME_S" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT*)
    if [ -s build_asm/selfhost_pabi/elem_const.o ]; then
      _PABI_SELFHOST="build_asm/selfhost_pabi/elem_const.o $_PABI_SELFHOST"
    fi
    if [ -s build_asm/selfhost_pabi/lea_cold_fwd.o ]; then
      _PABI_SELFHOST="build_asm/selfhost_pabi/lea_cold_fwd.o $_PABI_SELFHOST"
    fi
    # STRUCT_LIT elements. The egg baker calls this object.
    # bake_elems.o first-wins true-pack named i8 ARRAY (w1012/w1013).
    # Egg same-TU local e8 stays on leftover — weaken pabi_weak + post-link
    # jmp (win_patch_body_sync_jmp). PLATFORM: WINDOWS.
    if [ -s build_asm/selfhost_pabi/bake_elems.o ]; then
      _PABI_SELFHOST="build_asm/selfhost_pabi/bake_elems.o $_PABI_SELFHOST"
    fi
    if [ -s build_asm/selfhost_pabi/bake_struct.o ]; then
      _PABI_SELFHOST="build_asm/selfhost_pabi/bake_struct.o $_PABI_SELFHOST"
    fi
    # w1007 Cap residual field load_sz. PLATFORM: WINDOWS.
    if [ -s build_asm/selfhost_pabi/field_cap_residual_load.o ]; then
      _PABI_SELFHOST="build_asm/selfhost_pabi/field_cap_residual_load.o $_PABI_SELFHOST"
    fi
    # w1009/w1010/w1013: body_sync + emit_let_init + bake_elems. PLATFORM: WINDOWS.
    # Host-gcc / tip first-wins. mega same-TU REL32 or local e8 keeps leftover —
    # weaken a COPY (pabi_weak.o), never mutate egg runtime_pipeline_abi.o;
    # post-link win_patch_body_sync_jmp redirects leftover W→T.
    # Also create pabi_weak when assign/emit true_i8 tips need weaken.
    if [ -s build_asm/selfhost_pabi/body_sync_let_order.o ] \
      || [ -s build_asm/selfhost_pabi/emit_let_init.o ] \
      || [ -s build_asm/selfhost_pabi/bake_elems.o ]; then
      _oc=""
      if command -v llvm-objcopy >/dev/null 2>&1; then
        _oc=llvm-objcopy
      elif command -v objcopy >/dev/null 2>&1; then
        _oc=objcopy
      fi
      if [ -n "$_oc" ] && [ -s src/runtime_pipeline_abi.o ]; then
        mkdir -p build_asm/selfhost_pabi
        cp -f src/runtime_pipeline_abi.o build_asm/selfhost_pabi/pabi_weak.o
        for _bsym in pipeline_asm_emit_block_body_sync_elf backend_emit_block_body_sync_elf; do
          if [ -s build_asm/selfhost_pabi/body_sync_let_order.o ]; then
            "$_oc" --weaken-symbol="$_bsym" build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
          fi
        done
        if [ -s build_asm/selfhost_pabi/emit_let_init.o ]; then
          "$_oc" --weaken-symbol=glue_block_body_emit_let_init \
            build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
        # w1013: true-pack bake tip. Weaken egg bake_array. PLATFORM: WINDOWS.
        if [ -s build_asm/selfhost_pabi/bake_elems.o ]; then
          "$_oc" --weaken-symbol=pipe_modlet_bake_array_lit_elems_to_data \
            build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
        _PABI_LINK_O="build_asm/selfhost_pabi/pabi_weak.o"
      fi
    fi
    if [ -s build_asm/selfhost_pabi/emit_let_init.o ]; then
      _PABI_SELFHOST="build_asm/selfhost_pabi/emit_let_init.o $_PABI_SELFHOST"
    fi
    if [ -s build_asm/selfhost_pabi/body_sync_let_order.o ]; then
      _PABI_SELFHOST="build_asm/selfhost_pabi/body_sync_let_order.o $_PABI_SELFHOST"
    fi
    # w1007 Cap residual named_builtin size→4 overlay (when typeck_x.o
    # still has 1/2). First-wins. PLATFORM: WINDOWS.
    if [ -s build_asm/selfhost_pabi/named_builtin_cap.o ]; then
      _PABI_SELFHOST="build_asm/selfhost_pabi/named_builtin_cap.o $_PABI_SELFHOST"
    fi
    ;;
esac
_DRIVER_SEED_OBJS="$_PABI_SELFHOST $_WIN_ASSIGN_OVERRIDES $_PABI_WPO_THIN $_PABI_WPO_CAP $_PABI_RELOC_TYPED $_PABI_DATA_LEN $_PABI_CONST_LIT $_MAIN_LINK_O src/runtime_io_abi.o src/runtime_link_abi.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/diag.o $_PABI_LINK_O $_DRIVER_SEED_RUNTIME_O $_RT_SEED_SLICE_OBJS runtime_process_argv.o src/driver/fmt_check_cmd_driver.o src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o $_LEXER_LINK_O $_AST_LINK_O $_X_FRONTEND $_DRIVER_SEED_SUPPORT src/x_seed_bridge.o src/seed_link_compat.o src/token_typekind_tag_tables.o"

# 最终链接 obj 序（与 make g05-export-relink 一致）
# ast_gen2.o: in LEGACY mode, append at link END (mirrors Makefile xlang-c LEGACY L2501
# which ends with ast_gen2.o). ast_gen2.o provides ast_arena_* / ast_block_*
# used by the C frontend runtime (runtime_driver.o). In no_c default the X
# pipeline uses ast_ast_* (not ast_arena_*), so ast_gen2.o is not needed.
if [ "${XLANG_NO_C_SEED_LINK:-0}" != "1" ] && [ "${XLANG_LEGACY_C_FRONTEND:-0}" = "1" ]; then
  _AST_GEN2="ast_gen2.o"
else
  _AST_GEN2=""
fi
G05_OBJS="$_DRIVER_SEED_OBJS driver_x.o $_PIPELINE_LINK_O lsp_x.o lsp_diag_x.o lsp_io_x.o preprocess_x.o $_DRIVER_SUBCMD src/lsp/lsp_diag.o src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o lsp_io_std_heap_x.o $_USER_ASM_LINK $_GLUE_SUFFIX $_AST_GEN2"

G05_CFLAGS="$_BASE_CFLAGS $_DRIVER_SEED_LINK_FLAGS $_ASM_GLUE_DUP_LDFLAGS $_MAIN_LINK_FLAGS"

# NL-07 L10 / G-03: product default g05 chain aligns with build_xlang_asm crt0 v5.
# PLATFORM: LINUX — when bootstrap_wants_nostdlib, drop host-implicit -lc (cc driver)
# by using -nostdlib -static + freestanding_io + bootstrap_nostdlib_stubs + weak atoi.
# G.7: policy from scripts/bootstrap_nostdlib_shared.sh (same as build_xlang_asm).
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
  # freestanding_io is already on MAIN_LINK_O (Linux x86_64 pure-ld face) —
  # G.7: do not re-list it here (duplicate strong xlang_sys_*).
  _G05_NOSTDLIB_OBJS="src/asm/bootstrap_nostdlib_stubs.o atoi_stub.o"
  G05_CFLAGS="$G05_CFLAGS $_G05_NOSTDLIB_FLAGS"
  G05_OBJS="$G05_OBJS $_G05_NOSTDLIB_OBJS"
  ;;
  esac
fi

# 供 ensure 使用的热路径（force 重编的 .c → .o）
# Hot-path C rebuild targets. In no_c mode runtime_driver_no_c.o is hot;
# in LEGACY mode runtime_driver.o is hot (matches Makefile DRIVER_SEED_RUNTIME_REBUILD).
# wave304: strict_minimal shell retired — no longer a hot C rebuild target.
if [ "${XLANG_NO_C_SEED_LINK:-0}" != "1" ] && [ "${XLANG_LEGACY_C_FRONTEND:-0}" = "1" ]; then
  G05_HOT_C_OBJS="src/runtime_link_abi.o src/runtime_driver.o"
else
  G05_HOT_C_OBJS="src/runtime_link_abi.o src/runtime_driver_no_c.o"
fi

# shell 安全单引号转义
_sq() {
  printf "%s" "$1" | sed "s/'/'\\\\''/g"
}

# PLATFORM: SHARED — surface platform link faces for archaeology / Stage2 X dogfood
# (verify-selfhost-stage2). Same values already folded into G05_CFLAGS / G05_OBJS;
# export named keys so consumers do not re-hardcode Darwin crt0 / multiply_defined.
# G.7 有则补全 — do not invent a second platform table in Stage2.
echo "G05_CC='$(_sq "$G05_CC")'"
echo "G05_CFLAGS='$(_sq "$G05_CFLAGS")'"
echo "G05_OUT='$(_sq "$G05_OUT")'"
echo "G05_XLANG_C='$(_sq "$G05_XLANG_C")'"
echo "G05_BOOTSTRAP='$(_sq "$G05_BOOTSTRAP")'"
echo "G05_OBJS='$(_sq "$G05_OBJS")'"
echo "G05_HOT_C_OBJS='$(_sq "$G05_HOT_C_OBJS")'"
echo "G05_MAIN_LINK_O='$(_sq "$_MAIN_LINK_O")'"
echo "G05_MAIN_LINK_FLAGS='$(_sq "$_MAIN_LINK_FLAGS")'"
echo "G05_ASM_GLUE_DUP_LDFLAGS='$(_sq "$_ASM_GLUE_DUP_LDFLAGS")'"
echo "G05_USER_ASM_LINK='$(_sq "$_USER_ASM_LINK")'"
echo "G05_UNAME_S='$(_sq "$UNAME_S")'"
echo "G05_UNAME_M='$(_sq "$UNAME_M")'"
