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

# Darwin diag.o references xlang_panic_. Other hosts leave this empty.
_PANIC_LINK_O=""

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
  # （seed bridge weak_import 静态链必需）。w1520：两对象均由纯 asm 编
  # src/asm/asm_experimental_symbol_bridge.x ＋ _entry.x（定义 entry 的 TU 走入口模式只出
  # entry，故拆开；Mac ld -r 会丢段首弱属性，故不合并，链两个 .o）。
  # PLATFORM: MACOS product pure-ld — no pipeline mega .o.
  _PIPELINE_LINK_O=""
  # PLATFORM: MACOS — backend_arm64_enc_c.o strong arch_arm64_enc_* override weak -1 stubs (CG002).
  _USER_ASM_LINK="build_asm/seed_host/asm_backend_partial.o build_asm/seed_host/asm_full_link_stubs.o build_asm/bootstrap_seed_user_asm_seed_bridge_filtered.o build_asm/bootstrap_seed_asm_backend_compat_stubs_filtered.o build_asm/bootstrap_seed_backend_x86_64_enc_c_filtered.o src/asm/backend_arm64_enc_c.o build_asm/asm_experimental_symbol_bridge.o build_asm/asm_experimental_symbol_bridge_entry.o src/asm/backend_enc_dispatch.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o parser_asm_thin_glue.o src/asm/parser_asm_parse_expr_link.o"
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
    # replaces arch_x86_64_enc_enc_prologue (+ epilogue). w1046 always
    # saves rbx (tip i32 cmp parks temps there; w1043 lean smashed callers).
    # PE first-wins: must precede backend_enc_dispatch.o /
    # backend_x86_64_enc_c.o. Rebuild from .c when present.
    if [ -f src/asm/backend_x86_64_enc_prologue_chkstk.c ]; then
      mkdir -p build_asm/selfhost_pabi
      # shellcheck disable=SC2086
      if $G05_CC $_BASE_CFLAGS -I. -Iinclude -Isrc -c -o \
          build_asm/selfhost_pabi/prologue_chkstk.o \
          src/asm/backend_x86_64_enc_prologue_chkstk.c 2>/dev/null; then
        :
      fi
    fi
    if [ -s build_asm/selfhost_pabi/prologue_chkstk.o ]; then
      _USER_ASM_LINK="build_asm/selfhost_pabi/prologue_chkstk.o $_USER_ASM_LINK"
    fi
    ;;
esac

# DRIVER_SEED layout: mirror Makefile LEGACY vs no_c default.
# PLATFORM: SHARED — Makefile is the single authority (makefile L1843-1900).
# g05_relink_env is the shell mirror (G.7). On Linux/macOS the default no_c
# layout works (X pipeline self-contained). Historical (before w1498): on
# Windows MSYS/MinGW the documented build env sets XLANG_LEGACY_C_FRONTEND=1 (see
# analysis/Windows平台限制与测试指南.md §3.2): xlang-c.exe must use the C
# frontend runtime (runtime_driver.o + lexer.o + ast_seed.o +
# cfg_eval_bootstrap_stub.o + async_*), NOT the no_c runtime
# (runtime_driver_no_c.o + cfg_eval.o). The no_c runtime on Windows fails
# the X pipeline with XP001/XP003 (pipeline returned -1) because
# runtime_driver_no_c.o's driver dispatch does not match the Windows seed
# binary layout (the pinned bootstrap_xlangc was captured under LEGACY mode).
# Without this guard g05 relink-xlang on Windows produced a xlang.exe that
# links cleanly but cannot run even `function main(): i32 { return 42; }`.
# w1498 (10.19): Windows no longer defaults to LEGACY. src/runtime_driver.o has
# had no builder since wave321 (runtime monofile retired); on Windows it was a
# stale leftover that still carried old copies of the rt slices
# (emit_state/parse_diag/preamble/stack/arena_buf) and, being linked before
# _RT_SEED_SLICE_OBJS under --allow-multiple-definition (first wins), shadowed
# the new slices. The no_c runtime is rebuilt by ensure (try-rt-prefer) from
# the .x on every host; its two Windows gaps (rt_diag_get_errno, setenv) are now
# Windows bodies in rt_diag_errno.x and rt_compile.x. Windows uses the same
# no_c layout as Linux/macOS. Explicit XLANG_LEGACY_C_FRONTEND=1 keeps the C
# lexer/ast archaeology objects but still takes the no_c runtime (below).
# Honor XLANG_LEGACY_C_FRONTEND (=1 LEGACY; otherwise no_c default) and
# XLANG_NO_C_SEED_LINK (=1 forces no_c even under LEGACY — experimental).
if [ "${XLANG_NO_C_SEED_LINK:-0}" != "1" ] && [ "${XLANG_LEGACY_C_FRONTEND:-0}" = "1" ]; then
  # LEGACY mode: matches Makefile XLANG_LEGACY_C_FRONTEND=1 branch.
  # (historically runtime_driver.o), C lexer.o + ast_seed.o, cfg_eval_bootstrap_stub,
  # async liveness/cps_codegen. DRIVER_SEED_C_FRONTEND_LEGACY is empty (C
  # frontend deleted, G-02a) so DRIVER_SEED_FRONTEND_EXTRA is empty.
  # w1498: the runtime is the ensure-built no_c object even under LEGACY;
  # src/runtime_driver.o has no builder and must never reach a product link.
  _DRIVER_SEED_RUNTIME_O="src/runtime_driver_no_c.o"
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
# w1500 (终局待办 10.23): compile one pure .x pabi overlay with the current
# product (no host cc). 3 tries; a crash (rc 124 / >=128) is logged to
# build_asm/g05_xasm_crash.log, and a product that cannot produce the object
# (or whose object lacks the T) is logged there too, so g05_relink_xlang.sh
# refuses to link instead of silently falling back to the egg bodies (the
# 10.17 / 10.18 regressions). Result path in _G05_PO_OUT ("" = not built).
# Usage: _g05_pure_overlay SRC.x OUT.o T_SYMBOL
# PLATFORM: SHARED.
_g05_pure_overlay() {
  _po_x=$1
  _po_o=$2
  _po_sym=$3
  _G05_PO_OUT=""
  [ -f "$_po_x" ] || return 0
  mkdir -p build_asm/selfhost_pabi
  rm -f "$_po_o" "$_po_o.tmp.o"
  if [ ! -x ./xlang_asm ]; then
    echo "g05_relink_env: WARNING pure overlay $_po_x not built (no ./xlang_asm)" >&2
    return 0
  fi
  for _po_try in 1 2 3; do
    _po_rc=0
    ./xlang_asm -backend asm -c "$_po_x" -o "$_po_o.tmp.o" >/dev/null 2>&1 || _po_rc=$?
    if [ "$_po_rc" -eq 124 ] || [ "$_po_rc" -ge 128 ]; then
      printf '%s rc=%s g05_relink_env: ./xlang_asm -backend asm -c %s\n' \
        "$(date +%H:%M:%S)" "$_po_rc" "$_po_x" >>build_asm/g05_xasm_crash.log 2>/dev/null || true
    fi
    if [ "$_po_rc" -eq 0 ] \
      && nm "$_po_o.tmp.o" 2>/dev/null | grep -q "T _*${_po_sym}\$"; then
      mv -f "$_po_o.tmp.o" "$_po_o"
      break
    fi
    rm -f "$_po_o.tmp.o"
  done
  if [ -s "$_po_o" ]; then
    _G05_PO_OUT="$_po_o"
  else
    printf '%s overlay-missing g05_relink_env: %s (no T %s)\n' \
      "$(date +%H:%M:%S)" "$_po_x" "$_po_sym" >>build_asm/g05_xasm_crash.log 2>/dev/null || true
    echo "g05_relink_env: ERROR pure overlay $_po_x did not build (T $_po_sym)" >&2
  fi
}
# w1041/w1497: call_spill budget ((n+1)*8, x86 exact per-arg GP units, widest
# GP for the Windows outgoing area). w1500: pure .x (was host-cc seed).
# Strong T first-wins; HARD BAN tip reinject of w157 thin (Darwin BRANCH26).
# Must precede _PABI_SELFHOST: Linux spill.o also defines this T and would
# otherwise first-win the egg *32 body (w1041 map). PLATFORM: SHARED.
_g05_pure_overlay src/runtime_pipeline_abi_call_spill_thin.x \
  build_asm/selfhost_pabi/call_spill.o glue_asm_sum_block_call_spill_bytes
_PABI_CALL_SPILL="$_G05_PO_OUT"
# w1032..w1497: compute_frame_size (leaf scratch floor skip, arm64 x2, w1490
# expression-nested locals, Windows outgoing area). w1500: pure .x (was
# host-cc seed). Strong T first-wins egg weak (Darwin/Ubuntu) or weakened
# pabi_weak T (Windows). Also ahead of _PABI_SELFHOST. PLATFORM: SHARED.
_g05_pure_overlay src/runtime_pipeline_abi_frame_size_thin.x \
  build_asm/selfhost_pabi/compute_frame_size.o pipeline_asm_compute_frame_size_c
_PABI_FRAME_SIZE="$_G05_PO_OUT"
# w1544: CALL-returned slice deep-copy no longer truncates past its cap
# (egg copied only the first 1024 bytes; a longer slice is now passed
# through unchanged, like the host-C twin). Strong T first-wins egg weak
# (Darwin) / --allow-multiple-definition (Linux) / weakened pabi_weak T
# (Windows). Ahead of _PABI_SELFHOST. PLATFORM: SHARED.
_g05_pure_overlay src/runtime_pipeline_abi_reent_nocap_thin.x \
  build_asm/selfhost_pabi/reent_nocap.o glue_slice_let_reent_deep_copy_after_dual_gp_elf_c
_PABI_REENT_NOCAP="$_G05_PO_OUT"
# w1544: Cap residual field load/store width (w1007/w1008), now rebuilt
# from .x by the current product on every relink instead of a stale
# prebuilt object. Enum-typed struct fields are 4 bytes (Token.kind store
# used to write 8 and zero Token.line). Consumed below by the per-OS
# _PABI_SELFHOST blocks. PLATFORM: SHARED.
_g05_pure_overlay src/runtime_pipeline_abi_field_cap_residual_load_thin.x \
  build_asm/selfhost_pabi/field_cap_residual_load.o pipeline_expr_field_access_load_byte_sz
# w1486: Windows block-entry VAR-slot cache clear (egg body_sync forwarder
# never clears; mega reuses one ctx so next function hits stale %rbx).
# Strong T first-wins weakened pabi_weak egg T; post-link jmp W→T.
# PLATFORM: WINDOWS | MSYS | MINGW only — Darwin/Linux tip .x already clear.
_PABI_BB_CACHE=""
# w1488: Windows let-order / emit_let_init host-gcc twins (w1009/w1010) were
# only ever built by hand; a cold build_asm lost them and the egg block_inits
# hoisted CALL let inits above earlier stmts (let y=id(x) before side(&x)).
# Rebuild from the in-repo .c twins every relink. The let-order twin's
# backend_emit_block_body_sync_elf also clears the VAR-slot cache, so the
# w1486 cache-clear overlay is skipped when it builds.
# PLATFORM: WINDOWS | MSYS | MINGW only — Darwin/Linux keep tip .x objects.
_PABI_WIN_LET_ORDER=""
case "$UNAME_S" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT*)
    mkdir -p build_asm/selfhost_pabi
    rm -f build_asm/selfhost_pabi/body_sync_let_order.o build_asm/selfhost_pabi/emit_let_init.o
    if [ "${XLANG_WIN_LET_ORDER_TWIN:-1}" = "1" ] \
        && [ -f src/runtime_pipeline_abi_block_body_sync_let_order_thin.c ]; then
      # shellcheck disable=SC2086
      if $G05_CC $_BASE_CFLAGS -I. -Iinclude -Isrc -Iseeds -c -o \
          build_asm/selfhost_pabi/body_sync_let_order.o \
          src/runtime_pipeline_abi_block_body_sync_let_order_thin.c 2>/dev/null; then
        _PABI_WIN_LET_ORDER=1
      else
        rm -f build_asm/selfhost_pabi/body_sync_let_order.o
      fi
    fi
    if [ "${XLANG_WIN_EMIT_LET_INIT_TWIN:-1}" = "1" ] \
        && [ -f src/runtime_pipeline_abi_glue_block_body_emit_let_init_thin.c ]; then
      # shellcheck disable=SC2086
      $G05_CC $_BASE_CFLAGS -I. -Iinclude -Isrc -Iseeds -c -o \
          build_asm/selfhost_pabi/emit_let_init.o \
          src/runtime_pipeline_abi_glue_block_body_emit_let_init_thin.c 2>/dev/null \
        || rm -f build_asm/selfhost_pabi/emit_let_init.o
    fi
    ;;
esac
case "$UNAME_S" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT*)
    if [ -z "$_PABI_WIN_LET_ORDER" ] \
        && [ -f seeds/runtime_pipeline_abi_win_block_body_cache_clear_overlay.c ]; then
      mkdir -p build_asm/selfhost_pabi
      # shellcheck disable=SC2086
      if $G05_CC $_BASE_CFLAGS -I. -Iinclude -Isrc -Iseeds -c -o \
          build_asm/selfhost_pabi/block_body_cache_clear.o \
          seeds/runtime_pipeline_abi_win_block_body_cache_clear_overlay.c 2>/dev/null; then
        _PABI_BB_CACHE="build_asm/selfhost_pabi/block_body_cache_clear.o"
      fi
    fi
    ;;
esac
# w1487: Windows egg tail-jmp peer (pre-w1483, no single-stmt gate) turns
# whole functions into `jmp callee` (pthin_expr_primary ident/paren/array/
# lbrace → jmp suffix_loop). Strong T returns 0; weakened pabi_weak egg T;
# post-link jmp W→T. PLATFORM: WINDOWS | MSYS | MINGW only.
_PABI_TAIL_JMP_OFF=""
case "$UNAME_S" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT*)
    if [ -f seeds/runtime_pipeline_abi_win_tail_jmp_off_overlay.c ]; then
      mkdir -p build_asm/selfhost_pabi
      # shellcheck disable=SC2086
      if $G05_CC $_BASE_CFLAGS -I. -Iinclude -Isrc -Iseeds -c -o \
          build_asm/selfhost_pabi/tail_jmp_off.o \
          seeds/runtime_pipeline_abi_win_tail_jmp_off_overlay.c 2>/dev/null; then
        _PABI_TAIL_JMP_OFF="build_asm/selfhost_pabi/tail_jmp_off.o"
      fi
    fi
    ;;
esac
# w1497: Windows param-home canonicalize overlay. Egg mega_body calls the
# same-TU leftover-PE param_home that homes i32 formals without cltq, so a
# C caller's stack `movl` leaves garbage upper bits. Strong T first-wins;
# weakened pabi_weak egg T; post-link jmp W/t→T.
# PLATFORM: WINDOWS | MSYS | MINGW only.
_PABI_WIN_PARAM_HOME=""
case "$UNAME_S" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT*)
    # w1500: pure .x (was host-cc seed).
    _g05_pure_overlay src/runtime_pipeline_abi_win_param_home_thin.x \
      build_asm/selfhost_pabi/win_param_home.o pipeline_asm_emit_param_home_elf_c
    _PABI_WIN_PARAM_HOME="$_G05_PO_OUT"
    ;;
esac
# w1499: 64-bit MUL / MOD / divisor zero check (终局待办 10.20). The pabi
# bodies emit 32-bit mul/rem/test, so i64/usize products and remainders lost
# their high half and diag_snap_load_ptr (usize MUL) crashed every located
# diagnostic. Pure thin .x compiled by the current product every relink (no
# host cc) and linked first: Darwin pabi copies are weak, Linux first-wins,
# Windows weakens pabi_weak below and win_patch_body_sync_jmp folds W/t→T.
# A failed compile is logged and blocks the link (w1500 _g05_pure_overlay).
# PLATFORM: SHARED.
_PABI_BINOP_WIDE=""
if [ "${XLANG_BINOP_WIDE_OVERLAY:-1}" = "1" ]; then
  _g05_pure_overlay src/runtime_pipeline_abi_binop_wide_thin.x \
    build_asm/selfhost_pabi/binop_wide.o pipeline_asm_emit_binop_mod_elf_c
  _PABI_BINOP_WIDE="$_G05_PO_OUT"
fi
# w1558: parser bootstrap mega allow list. Egg
# asm_parser_bootstrap_mega_emit_allowed is the short list (parse_into* and
# collect_imports_buf). mega_entry calls it with R_X86_64_PLT32, so this
# overlay is the linked body. Adds parse, parse_one_function_impl,
# parse_expr_into, parse_block_into, parse_body_lets_into when
# XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT is set. MINIMAL stays two names.
# A failed compile is logged and blocks the link. PLATFORM: SHARED.
_PABI_PARSER_MEGA_ALLOW=""
if [ "${XLANG_PARSER_MEGA_ALLOW_OVERLAY:-1}" = "1" ]; then
  _g05_pure_overlay src/runtime_pipeline_abi_parser_mega_allow_thin.x \
    build_asm/selfhost_pabi/parser_mega_allow.o asm_parser_bootstrap_mega_emit_allowed
  _PABI_PARSER_MEGA_ALLOW="$_G05_PO_OUT"
fi
# w1564: parser EMIT_HEAVY force-stub list. The egg
# asm_parser_emit_heavy_force_stub also stubs every onefunc_ /
# copy_onefunc_ / set_onefunc_ name. skip_heavy calls it with
# R_X86_64_PLT32, so this overlay is the linked body. The thin keeps the
# six recorded segfault / elf_ec=-1 names and drops those three prefixes.
# A failed compile is logged and blocks the link. PLATFORM: SHARED.
_PABI_PARSER_FORCE_STUB=""
if [ "${XLANG_PARSER_FORCE_STUB_OVERLAY:-1}" = "1" ]; then
  _g05_pure_overlay src/runtime_pipeline_abi_parser_force_stub_thin.x \
    build_asm/selfhost_pabi/parser_force_stub.o asm_parser_emit_heavy_force_stub
  _PABI_PARSER_FORCE_STUB="$_G05_PO_OUT"
fi
# w1501: module-let STRING_LIT pool head chunk 127 (终局待办 10.24). pabi's
# pipe_modlet_bake_string_lit_elem_to_data copied the head chunk with a 255
# cap while the parser splits literals every 127 bytes, so bytes 127..254 of a
# long module string became NUL. Same pure-overlay rules as binop_wide.
# PLATFORM: SHARED.
_PABI_MODLET_STRPOOL=""
if [ "${XLANG_MODLET_STRPOOL_OVERLAY:-1}" = "1" ]; then
  _g05_pure_overlay src/runtime_pipeline_abi_modlet_strpool_thin.x \
    build_asm/selfhost_pabi/modlet_strpool.o pipe_modlet_bake_string_lit_elem_to_data
  _PABI_MODLET_STRPOOL="$_G05_PO_OUT"
fi
# w1510: STRUCT_LIT fields matched to the layout by name (终局待办 10.29).
# pabi's pipeline_expr_struct_lit_field_offset_at / _field_type_ref_at took
# the literal field index as the layout index, so a literal written in a
# different field order (`S { a: 7, t: "x", b: 9 }`) stored every value at the
# wrong offset (local/module garbage, module *u8 SEGV, module struct arrays
# CG002). The pure .x also carries glue_struct_lit_field_store_sz (bool pad
# uses the next layout offset). Same pure-overlay rules as binop_wide.
# PLATFORM: SHARED.
_PABI_STRUCT_LIT_FIELD=""
if [ "${XLANG_STRUCT_LIT_FIELD_OVERLAY:-1}" = "1" ]; then
  _g05_pure_overlay src/runtime_pipeline_abi_struct_lit_field_thin.x \
    build_asm/selfhost_pabi/struct_lit_field.o pipeline_expr_struct_lit_field_offset_at
  _PABI_STRUCT_LIT_FIELD="$_G05_PO_OUT"
fi
# w1511: module-let f32 FLOAT_LIT gets a modlet cell (终局待办 10.40).
# pabi's pipe_modlet_scalar_init_common_imm only took BOOL/int/null-ptr, so
# `let g: f32 = 1.5` was hoisted into main and every other function used its
# own stack slot (cross-function reads/writes lost). The pure .x adds the
# IEEE single pattern; prepare and the hoist gate share this symbol. Same
# pure-overlay rules as struct_lit_field.
# PLATFORM: SHARED.
_PABI_MODLET_FLOAT_IMM=""
if [ "${XLANG_MODLET_FLOAT_IMM_OVERLAY:-1}" = "1" ]; then
  _g05_pure_overlay src/runtime_pipeline_abi_modlet_float_imm_thin.x \
    build_asm/selfhost_pabi/modlet_float_imm.o pipe_modlet_scalar_init_common_imm
  _PABI_MODLET_FLOAT_IMM="$_G05_PO_OUT"
fi
# w1502: VAR assign gate + leaves (终局待办 10.25). Darwin pabi is a libtool
# archive, so ensure's w620 inject of the assign_var leaves never ran there,
# and Windows linked a host-cc var override (removed w1506); both live gates handled
# plain ASSIGN only, so `a += 3` and every compound op failed with CG002.
# Compile the gate overlay plus the unchanged leaves (try_let, finish, typed
# stores, rhs_to_rax and its arms; load_lr lives in the gate file, mod stays
# binop_wide) with the current
# product every relink. Darwin weakens the pabi_weak gate below; Windows
# weakens pabi_weak and folds W/t to T post-link.
# Linux keeps the injected pabi leaves. PLATFORM: MACOS|DARWIN + WINDOWS.
# w1507 (终局待办 10.34): the gate also skips the finish demote for f32 targets
# whose value is already f32 bits (compound ops, plain FLOAT_LIT assign).
_PABI_ASSIGN_VAR=""
case "$UNAME_S" in
  Darwin|MINGW*|MSYS*|CYGWIN*|Windows_NT*)
    if [ "${XLANG_ASSIGN_VAR_OVERLAY:-1}" = "1" ]; then
      _g05_pure_overlay src/runtime_pipeline_abi_assign_var_compound_thin.x \
        build_asm/selfhost_pabi/assign_var_compound.o glue_emit_assign_var_elf_c
      if [ -n "$_G05_PO_OUT" ]; then
        _PABI_ASSIGN_VAR="$_G05_PO_OUT"
        for _avl in \
          "assign_var_try_let|glue_emit_assign_var_try_let_elf_c" \
          "assign_var_finish|glue_emit_assign_var_finish_elf_c" \
          "assign_var_store|glue_emit_assign_var_store_elf_c" \
          "assign_var_store_pair|glue_emit_assign_var_store_pair_elf_c" \
          "assign_var_store_f32|glue_emit_assign_var_store_f32_elf_c" \
          "assign_var_store_slice|glue_emit_assign_var_store_slice_elf_c" \
          "assign_rhsrax_to_rax|glue_emit_assign_rhs_to_rax_elf_c" \
          "assign_rhsrax_arms_simple|glue_emit_assign_rhs_add_elf_c" \
          "assign_rhsrax_arms_div|glue_emit_assign_rhs_div_elf_c" \
          "assign_rhsrax_arms_div_float|glue_emit_assign_rhs_div_float_elf_c" \
          "assign_rhsrax_arms_shl|glue_emit_assign_rhs_shl_elf_c" \
          "assign_rhsrax_arms_shr|glue_emit_assign_rhs_shr_elf_c"; do
          _g05_pure_overlay "src/runtime_pipeline_abi_${_avl%%|*}_thin.x" \
            "build_asm/selfhost_pabi/av_${_avl%%|*}.o" "${_avl##*|}"
          _PABI_ASSIGN_VAR="$_PABI_ASSIGN_VAR $_G05_PO_OUT"
        done
      fi
    fi
    ;;
esac
# w1504 (终局待办 10.30): Darwin links the leftover gcc emit_expr_elf_rec /
# emit_expr_elf_c from pabi_weak, whose emit_expr_elf_fast reads INT_LIT
# values through an implicit-int int64_val_at (sxtw w0, bit-31 range check),
# so literals above 32 bits were emitted as imm32. The rec's own source
# (runtime_pipeline_abi_asm_expr_thin.x, no new file) now emits wide INT_LIT
# as imm64 before the fast path; compile it with the current product every
# relink and weaken the leftover rec/emit_expr_elf_c below.
# Linux keeps its w739 rec, Windows its egg rec (both emit imm64 already).
# PLATFORM: MACOS|DARWIN.
_PABI_ASM_EXPR=""
case "$UNAME_S" in
  Darwin)
    if [ "${XLANG_ASM_EXPR_REC_OVERLAY:-1}" = "1" ]; then
      _g05_pure_overlay src/runtime_pipeline_abi_asm_expr_thin.x \
        build_asm/selfhost_pabi/asm_expr_rec.o pipeline_asm_emit_expr_elf_rec
      _PABI_ASM_EXPR="$_G05_PO_OUT"
    fi
    ;;
esac
# w1521 (终局待办 10.57): Darwin's live EXPR_RETURN impl (pabi_weak strong T)
# never copied a > 16-byte result into the caller's x8 buffer. The pure
# overlay copies into the parked sret dest and returns it in x0; pabi_weak
# _pipeline_asm_emit_return_elf_impl is weakened below. Linux x86_64: same
# overlay (lea local + copy into [rbp-home]); pabi.o keeps a strong T there,
# so the Linux copy weakens it in pabi_weak.o. Windows (w1521): egg T weakened
# in pabi_weak + win_patch jmp. PLATFORM: MACOS|DARWIN|LINUX|WINDOWS.
_PABI_RETURN_SRET=""
case "$UNAME_S" in
  Darwin|Linux|MINGW*|MSYS*|CYGWIN*|Windows_NT*)
    if [ "${XLANG_RETURN_SRET_OVERLAY:-1}" = "1" ]; then
      _g05_pure_overlay src/runtime_pipeline_abi_return_sret_thin.x \
        build_asm/selfhost_pabi/return_sret.o pipeline_asm_emit_return_elf_impl
      _PABI_RETURN_SRET="$_G05_PO_OUT"
    fi
    ;;
esac
# w1521 (终局待办 10.57): INDEX base `v.p[i]` with a *T struct field peeled
# the pointer twice (pabi glue_emit_index_eff_addr_base_elf_c FIELD branch
# plus trailing arm). Pure overlay skips the second peel for PTR fields;
# pabi_weak _glue_emit_index_eff_addr_base_elf_c weakened below (Darwin,
# Windows egg copy); Linux pabi already carries it weak. PLATFORM: SHARED.
_PABI_INDEX_BASE_FIELD=""
if [ "${XLANG_INDEX_BASE_FIELD_OVERLAY:-1}" = "1" ]; then
  _g05_pure_overlay src/runtime_pipeline_abi_index_base_field_thin.x \
    build_asm/selfhost_pabi/index_base_field.o glue_emit_index_eff_addr_base_elf_c
  _PABI_INDEX_BASE_FIELD="$_G05_PO_OUT"
fi
# w1507 (终局待办 10.34): Linux VAR assign goes through the assign.o sidecar
# (runtime_pipeline_abi_assign_thin.x, stale-marks pabi.o), not the VAR gate,
# and calls the pabi demote after rhs_to_rax. That demote called FLOAT_LIT f64
# and ran cvtsd2ss over f32 bits (`x = 2.25`, `x += 2.25`). A pure .x demote
# (pabi copy is weak on Linux) skips FLOAT_LIT sources; compile it with the
# current product every relink and link it first. PLATFORM: LINUX.
_PABI_F32_DEMOTE=""
case "$UNAME_S" in
  Linux)
    if [ "${XLANG_F32_DEMOTE_OVERLAY:-1}" = "1" ]; then
      _g05_pure_overlay src/runtime_pipeline_abi_f32_demote_thin.x \
        build_asm/selfhost_pabi/f32_demote.o glue_maybe_demote_f64_to_f32_eax_elf_c
      _PABI_F32_DEMOTE="$_G05_PO_OUT"
    fi
    ;;
esac
# w1505 (终局待办 10.36): the body_sync let-order thin kept one defer mask for
# every nesting level, so an inner if/while/region body overwrote the outer
# block's mask and an outer pass1-deferred `let` (`let m2 = msg;` after an if
# holding its own let) was emitted by neither pass. The object used to be a
# leftover (Sep 25); compile its source with the current product every relink
# so the per-level mask reaches the product. Windows builds the host-gcc twin
# of the same file above. PLATFORM: MACOS|DARWIN + LINUX.
case "$UNAME_S" in
  Darwin|Linux)
    if [ "${XLANG_BODY_SYNC_LET_ORDER_OVERLAY:-1}" = "1" ]; then
      _g05_pure_overlay src/runtime_pipeline_abi_block_body_sync_let_order_thin.x \
        build_asm/selfhost_pabi/body_sync_let_order.o pipeline_asm_emit_block_body_sync_elf
    fi
    ;;
esac
# wave767 Class R: Win PE assign overrides FIRST (allow-multiple first-wins).
# var + field + index + deref scalar. Built by g05_ensure when seeds present.
# PLATFORM: WINDOWS | MSYS | MINGW only — Darwin/Linux ignore.
_WIN_ASSIGN_OVERRIDES=""
case "$UNAME_S" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT*)
    # w1020: when true-pack tip stack is ON (default; XLANG_WIN_BAKE_TIP=0
    # forces Cap residual), skip src/win_index Cap residual twin.
    # Tip INDEX .o built with -DXLANG_WIN_TRUE_PACK. PLATFORM: WINDOWS.
    _skip_src_win_index=0
    if [ "${XLANG_WIN_BAKE_TIP:-}" != "0" ] \
      && [ -s build_asm/selfhost_pabi/index_elem_true_i8.o ]; then
      _skip_src_win_index=1
    fi
    for _wov in src/win_assign_field_override.o src/win_assign_index_override.o src/win_assign_deref_override.o src/win_struct_let_init_override.o src/win_copy_large_struct_override.o src/win_simd_splat_override.o src/win_vector_type_let_init_override.o src/win_simd_select_shuffle_fma_override.o src/win_asm_parser_override.o src/win_m8_tail_override.o src/win_wpo_collect_walk_override.o src/win_wpo_pgo_emit_override.o src/win_index_elem_byte_sz_override.o; do
      if [ "$_skip_src_win_index" = "1" ] \
        && [ "$_wov" = "src/win_index_elem_byte_sz_override.o" ]; then
        continue
      fi
      # w1506 (10.35): the var override .c is gone; the pure .x gate owns VAR assign.
      if [ -s "$_wov" ]; then
        _WIN_ASSIGN_OVERRIDES="$_WIN_ASSIGN_OVERRIDES $_wov"
      fi
    done
    # w1018: true-pack tip stack opt-in (XLANG_WIN_BAKE_TIP=1). PLATFORM: WINDOWS.
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
# w1521 (终局待办 10.57): Linux keeps a strong EXPR_RETURN impl in the pabi
# link object; weaken it (idempotent) so return_sret.o first-wins.
# PLATFORM: LINUX.
if [ "$UNAME_S" = "Linux" ] && [ -n "$_PABI_RETURN_SRET" ] && [ -s "$_PABI_LINK_O" ] \
  && command -v objcopy >/dev/null 2>&1; then
  if nm "$_PABI_LINK_O" 2>/dev/null | grep -qE " T pipeline_asm_emit_return_elf_impl$"; then
    objcopy --weaken-symbol=pipeline_asm_emit_return_elf_impl "$_PABI_LINK_O" 2>/dev/null || true
  fi
fi
# w1558: egg allow-list is already weak. If a rebuild leaves it strong,
# weaken so the overlay first-wins. PLATFORM: LINUX.
if [ "$UNAME_S" = "Linux" ] && [ -n "$_PABI_PARSER_MEGA_ALLOW" ] && [ -s "$_PABI_LINK_O" ] \
  && command -v objcopy >/dev/null 2>&1; then
  if nm "$_PABI_LINK_O" 2>/dev/null | grep -qE " T asm_parser_bootstrap_mega_emit_allowed$"; then
    objcopy --weaken-symbol=asm_parser_bootstrap_mega_emit_allowed "$_PABI_LINK_O" 2>/dev/null || true
  fi
fi
# w1564: egg force-stub is already weak. If a rebuild leaves it strong,
# weaken so the overlay first-wins. PLATFORM: LINUX.
if [ "$UNAME_S" = "Linux" ] && [ -n "$_PABI_PARSER_FORCE_STUB" ] && [ -s "$_PABI_LINK_O" ] \
  && command -v objcopy >/dev/null 2>&1; then
  if nm "$_PABI_LINK_O" 2>/dev/null | grep -qE " T asm_parser_emit_heavy_force_stub$"; then
    objcopy --weaken-symbol=asm_parser_emit_heavy_force_stub "$_PABI_LINK_O" 2>/dev/null || true
  fi
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
# w1021: module STRUCT_LIT-in-ARRAY CG002 when bake_struct was parked
# (.o.off) and bake_elems orphan-gated. Restore bake_struct; rebuild
# bake_elems from SHARED host-gcc seed (same as Win). PLATFORM: LINUX.
if [ -n "$_PABI_SELFHOST" ]; then
  if [ ! -s build_asm/selfhost_pabi/bake_struct.o ] \
    && [ -s build_asm/selfhost_pabi/bake_struct.o.off ]; then
    cp -f build_asm/selfhost_pabi/bake_struct.o.off \
      build_asm/selfhost_pabi/bake_struct.o
  fi
  if [ -s build_asm/selfhost_pabi/bake_struct.o ] \
    && [ -f seeds/win_bake_elems_override.c ]; then
    gcc -c -O2 -o build_asm/selfhost_pabi/bake_elems.o \
      seeds/win_bake_elems_override.c || true
  fi
fi
# w1017: elem_const tip first-wins folder when modlet.o is stale (T001 on
# full modlet_thin). PLATFORM: LINUX.
if [ -n "$_PABI_SELFHOST" ] && [ -s build_asm/selfhost_pabi/elem_const.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/elem_const.o $_PABI_SELFHOST"
fi
if [ -n "$_PABI_SELFHOST" ] && [ -s build_asm/selfhost_pabi/bake_struct.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/bake_struct.o $_PABI_SELFHOST"
fi
# bake_elems U-calls bake_struct. Orphan tip (no bake_struct.o and no
# modlet.o) → pure-ld UNDEF. Skip alone; weak egg bake_array remains.
# PLATFORM: LINUX
if [ -n "$_PABI_SELFHOST" ] && [ -s build_asm/selfhost_pabi/bake_elems.o ] \
  && { [ -s build_asm/selfhost_pabi/bake_struct.o ] \
    || [ -s build_asm/selfhost_pabi/modlet.o ]; }; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/bake_elems.o $_PABI_SELFHOST"
fi
if [ -n "$_PABI_SELFHOST" ] && [ -s build_asm/selfhost_pabi/index_elem_true_i8.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/index_elem_true_i8.o $_PABI_SELFHOST"
fi
if [ -n "$_PABI_SELFHOST" ] && [ -s build_asm/selfhost_pabi/emit_index_true_i8.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/emit_index_true_i8.o $_PABI_SELFHOST"
fi
# w1508 (10.33): rebuild the index-assign seed every relink (no leftover .o).
if [ -n "$_PABI_SELFHOST" ] && [ -f seeds/assign_index_true_i8_override.c ]; then
  if ! gcc -c -O2 -o build_asm/selfhost_pabi/assign_index_true_i8.o \
      seeds/assign_index_true_i8_override.c; then
    echo "g05_relink_env: assign_index_true_i8 cc failed" >&2
    rm -f build_asm/selfhost_pabi/assign_index_true_i8.o
  fi
fi
if [ -n "$_PABI_SELFHOST" ] && [ -s build_asm/selfhost_pabi/assign_index_true_i8.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/assign_index_true_i8.o $_PABI_SELFHOST"
fi
if [ -n "$_PABI_SELFHOST" ] && [ -s build_asm/selfhost_pabi/force_esz_true_i8.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/force_esz_true_i8.o $_PABI_SELFHOST"
fi
# w1022: true-pack [N]i8 row stride for nested INDEX/bake. PLATFORM: LINUX.
if [ -n "$_PABI_SELFHOST" ] && [ -f seeds/fixed_array_total_bytes_true_pack_override.c ]; then
  mkdir -p build_asm/selfhost_pabi
  gcc -c -O2 -o build_asm/selfhost_pabi/fixed_array_total_bytes_true_pack.o \
    seeds/fixed_array_total_bytes_true_pack_override.c || true
fi
if [ -n "$_PABI_SELFHOST" ] \
  && [ -s build_asm/selfhost_pabi/fixed_array_total_bytes_true_pack.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/fixed_array_total_bytes_true_pack.o $_PABI_SELFHOST"
fi
# w1483: arr_struct_lit peers (tip pabi U). Built by
# linux_selfhost_pabi_sidecars.sh. PLATFORM: LINUX.
if [ -n "$_PABI_SELFHOST" ]; then
  for _asl in call_bulk call_elems copy_bulk copy_elems call_one_elem; do
    if [ -s "build_asm/selfhost_pabi/asl_$_asl.o" ]; then
      _PABI_SELFHOST="$_PABI_SELFHOST build_asm/selfhost_pabi/asl_$_asl.o"
    fi
  done
fi
# w1023: nested ARRAY_LIT local let-init → array_lit_flat. PLATFORM: LINUX.
if [ -n "$_PABI_SELFHOST" ] && [ -f seeds/vector_let_init_nested_override.c ]; then
  mkdir -p build_asm/selfhost_pabi
  gcc -c -O2 -o build_asm/selfhost_pabi/vector_let_init_nested.o \
    seeds/vector_let_init_nested_override.c || true
fi
if [ -n "$_PABI_SELFHOST" ] \
  && [ -s build_asm/selfhost_pabi/vector_let_init_nested.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/vector_let_init_nested.o $_PABI_SELFHOST"
fi
# w1024: module VAR → local fixed-array let-init. PLATFORM: LINUX.
if [ -n "$_PABI_SELFHOST" ] && [ -f seeds/fixed_array_let_init_module_var_override.c ]; then
  mkdir -p build_asm/selfhost_pabi
  gcc -c -O2 -o build_asm/selfhost_pabi/fixed_array_let_init_module_var.o \
    seeds/fixed_array_let_init_module_var_override.c || true
fi
if [ -n "$_PABI_SELFHOST" ] \
  && [ -s build_asm/selfhost_pabi/fixed_array_let_init_module_var.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/fixed_array_let_init_module_var.o $_PABI_SELFHOST"
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
  # w1484: arm64 call_spill ×2 root fix (compute_frame_size overlay). The
  # Darwin pabi_weak w189 param_ptr_slot bodies were emitted by a product
  # whose frame budget was 8 B/temp while the arm64 emitter uses 16 B slots:
  # temps overwrite the caller's saved x29/x30 → ~1/3 `-backend asm -c`
  # SIGSEGV in glue_load_var_as_value_to_rax_rdx_elf_c. pabi.o is a libtool
  # archive here (inject skip) and FORCE pabi is banned, so re-emit the thin
  # with the current product and let it first-win over weakened pabi_weak.
  # Rebuilt when missing or older than the thin .x / frame overlay (w1500: frame_size_thin.x).
  # PLATFORM: MACOS|DARWIN.
  _pps_x=src/runtime_pipeline_abi_param_ptr_slot_thin.x
  _pps_o=build_asm/selfhost_pabi/param_ptr_slot_a64.o
  if [ -f "$_pps_x" ] && [ -x ./xlang_asm ]; then
    if [ ! -s "$_pps_o" ] || [ "$_pps_x" -nt "$_pps_o" ] \
      || [ src/runtime_pipeline_abi_frame_size_thin.x -nt "$_pps_o" ]; then
      rm -f "$_pps_o"
      for _pps_try in 1 2 3 4 5 6 7 8; do
        _pps_rc=0
        ./xlang_asm -backend asm -c "$_pps_x" -o "$_pps_o.tmp.o" >/dev/null 2>&1 || _pps_rc=$?
        # w1484 crash detector: same log as ensure's g05_xasm; relink fails on it.
        if [ "$_pps_rc" -eq 124 ] || [ "$_pps_rc" -ge 128 ]; then
          printf '%s rc=%s g05_relink_env: ./xlang_asm -backend asm -c %s\n' \
            "$(date +%H:%M:%S)" "$_pps_rc" "$_pps_x" >>build_asm/g05_xasm_crash.log 2>/dev/null || true
        fi
        if [ "$_pps_rc" -eq 0 ] \
          && nm -m "$_pps_o.tmp.o" 2>/dev/null | grep -q 'external _w189_param_at_is_type_ptr$'; then
          mv -f "$_pps_o.tmp.o" "$_pps_o"
          break
        fi
        rm -f "$_pps_o.tmp.o"
      done
    fi
  fi
  if [ -s "$_pps_o" ]; then
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
      for _psym in _w189_param_at_is_type_ptr _w189_stack_off_is_emit_param_ptr_slot \
        _glue_local_var_slot_needs_ptr_load_elf_c; do
        if nm -m build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null | grep -F "$_psym" | grep -qv weak; then
          "$_oc" --weaken-symbol="$_psym" build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
      done
      # Apple ld treats the first symbol of a non-subsections __text (the
      # section atom name) as strong even when N_WEAK_DEF is set, so a weak
      # w189 at offset 0 still collides with the thin. Prefix a brk stub via
      # ld -r so w189 becomes an alias, then weaken again. Idempotent.
      _pw=build_asm/selfhost_pabi/pabi_weak.o
      if nm -nm "$_pw" 2>/dev/null \
        | awk '$1=="0000000000000000" && /__TEXT,__text/ {print $NF; exit}' \
        | grep -qx '_w189_param_at_is_type_ptr'; then
        printf '.text\n.globl _pabi_weak_text_base\n.p2align 2\n_pabi_weak_text_base:\n  brk #0x1484\n' \
          > build_asm/selfhost_pabi/pabi_weak_base.s
        if as -arch arm64 -o build_asm/selfhost_pabi/pabi_weak_base.o \
            build_asm/selfhost_pabi/pabi_weak_base.s 2>/dev/null \
          && ld -r -keep_private_externs -o "$_pw.tmp.o" \
            build_asm/selfhost_pabi/pabi_weak_base.o "$_pw" 2>/dev/null; then
          for _psym in _w189_param_at_is_type_ptr _w189_stack_off_is_emit_param_ptr_slot \
            _glue_local_var_slot_needs_ptr_load_elf_c; do
            "$_oc" --weaken-symbol="$_psym" "$_pw.tmp.o" 2>/dev/null || true
          done
          mv -f "$_pw.tmp.o" "$_pw"
        fi
        rm -f "$_pw.tmp.o"
      fi
    fi
    _PABI_SELFHOST="$_pps_o $_PABI_SELFHOST"
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
  # w1508 (10.33): the Darwin .o was a leftover from before w1072; rebuild it
  # from the seed every relink so compound index ops reach the live body.
  if [ -f seeds/assign_index_true_i8_override.c ]; then
    if ! cc -c -O2 -o build_asm/selfhost_pabi/assign_index_true_i8.o \
        seeds/assign_index_true_i8_override.c; then
      echo "g05_relink_env: assign_index_true_i8 cc failed" >&2
      rm -f build_asm/selfhost_pabi/assign_index_true_i8.o
    fi
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
  # w1509 (10.32): the pabi field-assign body only took plain `=` (kind 28),
  # so `p.x += 4` failed with CG002. Build the shared field-assign seed (same
  # body plus compound ops) every relink and weaken the pabi copy.
  rm -f build_asm/selfhost_pabi/assign_field_seed.o
  if [ -f seeds/win_assign_field_override.c ]; then
    if ! cc -c -O2 -o build_asm/selfhost_pabi/assign_field_seed.o \
        seeds/win_assign_field_override.c; then
      echo "g05_relink_env: assign_field_seed cc failed" >&2
      rm -f build_asm/selfhost_pabi/assign_field_seed.o
    fi
  fi
  if [ -s build_asm/selfhost_pabi/assign_field_seed.o ]; then
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
      if nm -m build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null | grep -F "_glue_emit_assign_field_elf_c" | grep -qv weak; then
        "$_oc" --weaken-symbol=_glue_emit_assign_field_elf_c build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
      fi
    fi
    _PABI_SELFHOST="build_asm/selfhost_pabi/assign_field_seed.o $_PABI_SELFHOST"
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
      # w1014: also weaken array_lit_elem_byte_sz (force_esz=0 local path).
      for _fsym in _glue_array_lit_force_esz_from_elem_type_c \
                   _pipeline_asm_array_lit_elem_byte_sz_c; do
        if nm -m build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null | grep -F "$_fsym" | grep -qv weak; then
          "$_oc" --weaken-symbol="$_fsym" build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
      done
    fi
    _PABI_SELFHOST="build_asm/selfhost_pabi/force_esz_true_i8.o $_PABI_SELFHOST"
  fi
  # w1022: true-pack [N]i8 row stride (named i8→1). Nested local INDEX.
  # PLATFORM: MACOS|DARWIN.
  if [ -f seeds/fixed_array_total_bytes_true_pack_override.c ]; then
    gcc -c -O2 -o build_asm/selfhost_pabi/fixed_array_total_bytes_true_pack.o \
      seeds/fixed_array_total_bytes_true_pack_override.c 2>/dev/null || true
  fi
  if [ -s build_asm/selfhost_pabi/fixed_array_total_bytes_true_pack.o ]; then
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
      if nm -m build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null \
        | grep -F "_glue_fixed_array_total_bytes_c" | grep -qv weak; then
        "$_oc" --weaken-symbol=_glue_fixed_array_total_bytes_c \
          build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
      fi
    fi
    _PABI_SELFHOST="build_asm/selfhost_pabi/fixed_array_total_bytes_true_pack.o $_PABI_SELFHOST"
  fi
  # w1023: nested ARRAY_LIT → array_lit_flat (Darwin store calls mangled Cap
  # residual that used to -1). Weaken pabi mangled; tip first-wins.
  # PLATFORM: MACOS|DARWIN.
  if [ -f seeds/vector_let_init_nested_override.c ]; then
    gcc -c -O2 -o build_asm/selfhost_pabi/vector_let_init_nested.o \
      seeds/vector_let_init_nested_override.c 2>/dev/null || true
  fi
  if [ -s build_asm/selfhost_pabi/vector_let_init_nested.o ]; then
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
      for _vsym in \
        _pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32 \
        _pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32_pabi_stubdead \
        _pipeline_asm_emit_vector_let_init_elf_c; do
        if nm -m build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null \
          | grep -F "$_vsym" | grep -qv weak; then
          "$_oc" --weaken-symbol="$_vsym" \
            build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
      done
    fi
    _PABI_SELFHOST="build_asm/selfhost_pabi/vector_let_init_nested.o $_PABI_SELFHOST"
  fi
  # w1024: module VAR → local fixed-array (store -2 → COMMON lea+copy).
  # PLATFORM: MACOS|DARWIN.
  if [ -f seeds/fixed_array_let_init_module_var_override.c ]; then
    gcc -c -O2 -o build_asm/selfhost_pabi/fixed_array_let_init_module_var.o \
      seeds/fixed_array_let_init_module_var_override.c 2>/dev/null || true
  fi
  if [ -s build_asm/selfhost_pabi/fixed_array_let_init_module_var.o ]; then
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
      if nm -m build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null \
        | grep -F "_glue_emit_fixed_array_type_let_init_elf_c" | grep -qv weak; then
        "$_oc" --weaken-symbol=_glue_emit_fixed_array_type_let_init_elf_c \
          build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
      fi
    fi
    _PABI_SELFHOST="build_asm/selfhost_pabi/fixed_array_let_init_module_var.o $_PABI_SELFHOST"
  fi
  # w1502: leftover gcc VAR assign gate (plain ASSIGN only) is strong T in
  # pabi_weak. Weaken it so the pure .x gate wins for same-TU callers too.
  # PLATFORM: MACOS|DARWIN.
  if [ -n "$_PABI_ASSIGN_VAR" ] && [ -s build_asm/selfhost_pabi/pabi_weak.o ]; then
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
    if [ -n "$_oc" ] && nm -m build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null \
      | grep -E " _glue_emit_assign_var_elf_c$" | grep -v undefined | grep -qv weak; then
      "$_oc" --weaken-symbol=_glue_emit_assign_var_elf_c \
        build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
    fi
  fi
  # w1504: leftover gcc emit_expr_elf_rec / emit_expr_elf_c (and the shared
  # w495 cell helper) are strong T in pabi_weak. Weaken them so the asm_expr
  # rec wins for same-TU callers too. PLATFORM: MACOS|DARWIN.
  if [ -n "$_PABI_ASM_EXPR" ] && [ -s build_asm/selfhost_pabi/pabi_weak.o ]; then
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
    if [ -n "$_oc" ]; then
      for _aesym in _pipeline_asm_emit_expr_elf_rec _pipeline_asm_emit_expr_elf_c _w495_cell_i32; do
        if nm -m build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null \
          | grep -E " ${_aesym}\$" | grep -v undefined | grep -qv weak; then
          "$_oc" --weaken-symbol="$_aesym" \
            build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
      done
    fi
  fi
  # w1521: weaken leftover EXPR_RETURN impl so return_sret.o wins.
  # PLATFORM: MACOS|DARWIN.
  if [ -n "$_PABI_RETURN_SRET" ] && [ -s build_asm/selfhost_pabi/pabi_weak.o ]; then
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
    if [ -n "$_oc" ] && nm -m build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null \
      | grep -E " _pipeline_asm_emit_return_elf_impl$" | grep -v undefined | grep -qv weak; then
      "$_oc" --weaken-symbol=_pipeline_asm_emit_return_elf_impl \
        build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
    fi
  fi
  # w1521: weaken leftover INDEX base eff-addr so index_base_field.o wins.
  if [ -n "$_PABI_INDEX_BASE_FIELD" ] && [ -s build_asm/selfhost_pabi/pabi_weak.o ]; then
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
    if [ -n "$_oc" ] && nm -m build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null \
      | grep -E " _glue_emit_index_eff_addr_base_elf_c$" | grep -v undefined | grep -qv weak; then
      "$_oc" --weaken-symbol=_glue_emit_index_eff_addr_base_elf_c \
        build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
    fi
  fi
  # w1546: binop_wide's glue_try_emit_mixed_f32_f64_arith_elf_c converts an
  # integer operand of an f64 add/sub/mul/div. The egg body is already weak
  # in the current pabi_weak; weaken again if a rebuild leaves it strong.
  # Apple ld has no multidef. PLATFORM: MACOS|DARWIN.
  if [ -n "$_PABI_BINOP_WIDE" ] && [ -s build_asm/selfhost_pabi/pabi_weak.o ]; then
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
    if [ -n "$_oc" ] && nm -m build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null \
      | grep -F "_glue_try_emit_mixed_f32_f64_arith_elf_c" | grep -qv weak; then
      "$_oc" --weaken-symbol=_glue_try_emit_mixed_f32_f64_arith_elf_c \
        build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
    fi
  fi
  # PLATFORM: MACOS|DARWIN — host_is_arm64_c is mov w0,#1; ret. Leftover
  # PAGE21/PAGEOFF12 still name the old BSS load and sit on that mov/ret.
  # ld rejects them. Drop only those mismatched relocs.
  # Do not rebuild pabi_weak.o. Diagnostics go to stderr (stdout is eval'd).
  if [ -s build_asm/selfhost_pabi/pabi_weak.o ]; then
    python3 scripts/pabi_drop_stale_pageoff12.py \
      build_asm/selfhost_pabi/pabi_weak.o >&2 || true
    # w1485: leftover gcc pabi calls pipeline_asm_emit_module_ref_c with no
    # prototype (implicit int) and sign-extends w0, cutting the Module* high
    # word. Any .x that reads a file-level let/const in a body then faults in
    # asm_module_top_level_const_lit_i32 and g05 falls back to host cc.
    # Rewrite that sxtw to mov. Idempotent. PLATFORM: MACOS|DARWIN.
    python3 scripts/pabi_ptr_ret_sxtw_fix.py \
      build_asm/selfhost_pabi/pabi_weak.o >&2 || true
  fi
  # diag.o eight pure pieces reference xlang_panic_. This object is the
  # Darwin pure-asm body. Do not re-emit it: the current compiler faults
  # on runtime_panic_arm64.x. getenv is already strong in
  # runtime_link_abi.o; Apple ld has no multidef, so weaken the copies.
  # PLATFORM: MACOS|DARWIN.
  if [ -s runtime_panic.o ]; then
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
    if [ -n "$_oc" ] && nm -m runtime_panic.o 2>/dev/null \
      | grep -F "_link_abi_getenv" | grep -qv weak; then
      "$_oc" --weaken-symbol=_link_abi_getenv \
        --weaken-symbol=_link_abi_getenv_impl \
        runtime_panic.o 2>/dev/null || true
    fi
    _PANIC_LINK_O="runtime_panic.o"
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
    # w1020: PE tip from bake_elems_thin.x is non-deterministic CG002;
    # host-gcc seeds/win_bake_elems_override.c through the same weaken+jmp
    # is stable. Default ON (auto-build tip .o from seeds); set
    # XLANG_WIN_BAKE_TIP=0 for Cap residual. INDEX tip uses
    # -DXLANG_WIN_TRUE_PACK. force_esz / elem_byte_sz split into two .o.
    # PLATFORM: WINDOWS.
    _WIN_TRUE_PACK=0
    if [ "${XLANG_WIN_BAKE_TIP:-}" != "0" ]; then
      mkdir -p build_asm/selfhost_pabi
      if [ -f seeds/win_bake_elems_override.c ]; then
        gcc -c -O2 -o build_asm/selfhost_pabi/bake_elems.o \
          seeds/win_bake_elems_override.c || true
      fi
      if [ -f seeds/win_index_elem_byte_sz_override.c ]; then
        gcc -c -O2 -DXLANG_WIN_TRUE_PACK \
          -o build_asm/selfhost_pabi/index_elem_true_i8.o \
          seeds/win_index_elem_byte_sz_override.c || true
      fi
      if [ -f seeds/force_esz_true_i8_override.c ]; then
        # Split force_esz / elem_byte_sz into two .o (w1020 PE). PLATFORM: WINDOWS.
        gcc -c -O2 -DXLANG_WIN_FORCE_ESZ_ONLY \
          -o build_asm/selfhost_pabi/force_esz_true_i8.o \
          seeds/force_esz_true_i8_override.c || true
        gcc -c -O2 -DXLANG_WIN_ELEM_BYTE_SZ_ONLY \
          -o build_asm/selfhost_pabi/array_lit_esz_true_i8.o \
          seeds/force_esz_true_i8_override.c || true
      fi
      if [ -f seeds/emit_index_true_i8_override.c ]; then
        gcc -c -O2 -o build_asm/selfhost_pabi/emit_index_true_i8.o \
          seeds/emit_index_true_i8_override.c || true
      fi
      if [ -f seeds/assign_index_true_i8_override.c ]; then
        gcc -c -O2 -o build_asm/selfhost_pabi/assign_index_true_i8.o \
          seeds/assign_index_true_i8_override.c || true
      fi
      if [ -f seeds/fixed_array_total_bytes_true_pack_override.c ]; then
        gcc -c -O2 -o build_asm/selfhost_pabi/fixed_array_total_bytes_true_pack.o \
          seeds/fixed_array_total_bytes_true_pack_override.c || true
      fi
      # w1023: nested ARRAY_LIT → array_lit_flat. PLATFORM: WINDOWS.
      if [ -f seeds/vector_let_init_nested_override.c ]; then
        gcc -c -O2 -o build_asm/selfhost_pabi/vector_let_init_nested.o \
          seeds/vector_let_init_nested_override.c || true
      fi
      # w1024: module VAR → local fixed-array. PLATFORM: WINDOWS.
      if [ -f seeds/fixed_array_let_init_module_var_override.c ]; then
        gcc -c -O2 -o build_asm/selfhost_pabi/fixed_array_let_init_module_var.o \
          seeds/fixed_array_let_init_module_var_override.c || true
      fi
    fi
    if [ "${XLANG_WIN_BAKE_TIP:-}" != "0" ] \
      && [ -s build_asm/selfhost_pabi/bake_elems.o ] \
      && [ -s build_asm/selfhost_pabi/bake_struct.o ] \
      && [ -s build_asm/selfhost_pabi/index_elem_true_i8.o ] \
      && [ -s build_asm/selfhost_pabi/emit_index_true_i8.o ] \
      && [ -s build_asm/selfhost_pabi/assign_index_true_i8.o ] \
      && [ -s build_asm/selfhost_pabi/force_esz_true_i8.o ] \
      && [ -s build_asm/selfhost_pabi/array_lit_esz_true_i8.o ]; then
      _WIN_TRUE_PACK=1
    fi
    if [ "$_WIN_TRUE_PACK" = "1" ]; then
      _PABI_SELFHOST="build_asm/selfhost_pabi/bake_struct.o $_PABI_SELFHOST"
      _PABI_SELFHOST="build_asm/selfhost_pabi/bake_elems.o $_PABI_SELFHOST"
      _PABI_SELFHOST="build_asm/selfhost_pabi/index_elem_true_i8.o $_PABI_SELFHOST"
      _PABI_SELFHOST="build_asm/selfhost_pabi/emit_index_true_i8.o $_PABI_SELFHOST"
      _PABI_SELFHOST="build_asm/selfhost_pabi/assign_index_true_i8.o $_PABI_SELFHOST"
      _PABI_SELFHOST="build_asm/selfhost_pabi/force_esz_true_i8.o $_PABI_SELFHOST"
      _PABI_SELFHOST="build_asm/selfhost_pabi/array_lit_esz_true_i8.o $_PABI_SELFHOST"
      if [ -s build_asm/selfhost_pabi/fixed_array_total_bytes_true_pack.o ]; then
        _PABI_SELFHOST="build_asm/selfhost_pabi/fixed_array_total_bytes_true_pack.o $_PABI_SELFHOST"
      fi
      if [ -s build_asm/selfhost_pabi/vector_let_init_nested.o ]; then
        _PABI_SELFHOST="build_asm/selfhost_pabi/vector_let_init_nested.o $_PABI_SELFHOST"
      fi
      if [ -s build_asm/selfhost_pabi/fixed_array_let_init_module_var.o ]; then
        _PABI_SELFHOST="build_asm/selfhost_pabi/fixed_array_let_init_module_var.o $_PABI_SELFHOST"
      fi
    elif [ -s build_asm/selfhost_pabi/bake_struct.o ]; then
      _PABI_SELFHOST="build_asm/selfhost_pabi/bake_struct.o $_PABI_SELFHOST"
    fi
    # w1007 Cap residual field load_sz. PLATFORM: WINDOWS.
    if [ -s build_asm/selfhost_pabi/field_cap_residual_load.o ]; then
      _PABI_SELFHOST="build_asm/selfhost_pabi/field_cap_residual_load.o $_PABI_SELFHOST"
    fi
    # w1009/w1010/w1013/w1018: body_sync + emit_let_init + optional true-pack.
    # Host-gcc / tip first-wins. mega same-TU REL32 or local e8 keeps leftover —
    # weaken a COPY (pabi_weak.o), never mutate egg runtime_pipeline_abi.o;
    # post-link win_patch_body_sync_jmp redirects leftover W→T (earliest VA).
    # PLATFORM: WINDOWS.
    if [ -s build_asm/selfhost_pabi/body_sync_let_order.o ] \
      || [ -s build_asm/selfhost_pabi/emit_let_init.o ] \
      || [ "$_WIN_TRUE_PACK" = "1" ] \
      || [ -n "$_PABI_BB_CACHE" ] \
      || [ -n "$_PABI_TAIL_JMP_OFF" ] \
      || [ -n "$_PABI_BINOP_WIDE" ] \
      || [ -n "$_PABI_MODLET_STRPOOL" ] \
      || [ -n "$_PABI_STRUCT_LIT_FIELD" ] \
      || [ -n "$_PABI_MODLET_FLOAT_IMM" ] \
      || [ -n "$_PABI_INDEX_BASE_FIELD" ] \
      || [ -n "$_PABI_ASSIGN_VAR" ]; then
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
        # w1018: true-pack tip stack weaken leftovers. PLATFORM: WINDOWS.
        if [ "$_WIN_TRUE_PACK" = "1" ]; then
          for _wsym in pipe_modlet_bake_array_lit_elems_to_data \
            pipeline_asm_index_elem_byte_sz_c glue_index_elem_byte_sz_from_type_ref_c \
            pipeline_asm_index_elem_byte_sz \
            pipeline_asm_emit_index_elf_c glue_emit_index_load_arms_elf_c \
            glue_emit_assign_index_elf_c \
            glue_array_lit_force_esz_from_elem_type_c \
            pipeline_asm_array_lit_elem_byte_sz_c \
            glue_fixed_array_total_bytes_c \
            pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32 \
            pipeline_asm_emit_vector_let_init_elf_c \
            glue_emit_fixed_array_type_let_init_elf_c; do
            "$_oc" --weaken-symbol="$_wsym" \
              build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
          done
        fi
        # w1037: egg dual/triple EXTERNAL T (Cap leftover + historic stub +
        # tip inject). One-pass Cap-band demote replaces per-sym lists
        # (w1031–w1036). Same-TU REL32 to demoted STATIC still binds; PE
        # exports one T per name. PLATFORM: WINDOWS.
        if [ -f scripts/win_coff_keep_earliest_sym.py ]; then
          python3 scripts/win_coff_keep_earliest_sym.py --demote-all-dual \
            build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
        # w1493: the demote leaves STATIC modlet copies whose callers (store,
        # index, &let paths) fill a different module-let table than the
        # EXTERNAL find/load read, so those accesses fail with CG002
        # elf_ec=-1. Point those relocations at the EXTERNAL faces. The two
        # prefixes cover every other duplicated modlet helper (for example
        # pipe_modlet_lea_named_binding_addr_to_rax on `return &g[0]`, which
        # failed while only the eight names above were moved).
        # PLATFORM: WINDOWS.
        if [ -f scripts/elf_retarget_local_dup_relocs.py ]; then
          python3 scripts/elf_retarget_local_dup_relocs.py \
            build_asm/selfhost_pabi/pabi_weak.o \
            pipeline_asm_modlet_prepare_and_emit_elf_c \
            pipeline_asm_modlet_seed_nonzero_inits_elf_c \
            pipeline_asm_modlet_store_from_rax_elf_c \
            pipeline_asm_modlet_load_to_rax_elf_c \
            pipeline_asm_modlet_find pipe_modlet_get_n \
            pipeline_asm_modlet_name_is_shared pipeline_asm_modlet_reset \
            'pipe_modlet_*' 'pipeline_asm_modlet_*' \
            >/dev/null 2>&1 || true
        fi
        # w1034: when wave743 sidecar is linked, weaken egg typed so PE
        # first-wins PAGE21 owner-bind (matches Ubuntu single T). PLATFORM: WINDOWS.
        if [ -n "$_PABI_RELOC_TYPED" ]; then
          "$_oc" --weaken-symbol=pipeline_elf_ctx_append_reloc_typed \
            build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
        # w1544: weaken egg reent deep-copy so the no-cap overlay first-wins.
        # PLATFORM: WINDOWS.
        if [ -n "$_PABI_REENT_NOCAP" ]; then
          "$_oc" --weaken-symbol=glue_slice_let_reent_deep_copy_after_dual_gp_elf_c \
            build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
        # w1032: weaken egg compute_frame_size so overlay first-wins.
        # PLATFORM: WINDOWS.
        if [ -n "$_PABI_FRAME_SIZE" ]; then
          "$_oc" --weaken-symbol=pipeline_asm_compute_frame_size_c \
            build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
        # w1486: weaken egg body_sync forwarder so cache-clear overlay
        # first-wins. PLATFORM: WINDOWS.
        if [ -n "$_PABI_BB_CACHE" ]; then
          "$_oc" --weaken-symbol=backend_emit_block_body_sync_elf \
            build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
        # w1487: weaken egg tail-jmp peer so the off overlay first-wins.
        # PLATFORM: WINDOWS.
        if [ -n "$_PABI_TAIL_JMP_OFF" ]; then
          "$_oc" --weaken-symbol=w499_mega_try_tail_jmp \
            build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
        # w1497: weaken egg param_home so the canonicalize overlay first-wins.
        # PLATFORM: WINDOWS.
        if [ -n "$_PABI_WIN_PARAM_HOME" ]; then
          "$_oc" --weaken-symbol=pipeline_asm_emit_param_home_elf_c \
            build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
          # w1521: egg fill_param_slots gave >16B formals an 8-byte slot.
          "$_oc" --weaken-symbol=pipeline_asm_fill_param_slots \
            build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
        # w1521: weaken egg EXPR_RETURN impl (>16B sret copy overlay).
        # PLATFORM: WINDOWS.
        if [ -n "$_PABI_RETURN_SRET" ]; then
          "$_oc" --weaken-symbol=pipeline_asm_emit_return_elf_impl \
            build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
        # w1499: weaken egg 32-bit mul/mod/zero-check so the binop_wide
        # overlay first-wins. PLATFORM: WINDOWS.
        if [ -n "$_PABI_BINOP_WIDE" ]; then
          for _bwsym in glue_emit_binop_mul_rax_rbx_elf_c \
            pipeline_asm_emit_binop_mod_elf_c \
            pipeline_asm_emit_divisor_zero_check_rbx_elf_c \
            glue_emit_assign_rhs_mod_elf_c \
            glue_try_emit_mixed_f32_f64_arith_elf_c; do
            "$_oc" --weaken-symbol="$_bwsym" \
              build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
          done
        fi
        # w1558: weaken egg parser mega allow list so the overlay first-wins.
        # PLATFORM: WINDOWS.
        if [ -n "$_PABI_PARSER_MEGA_ALLOW" ]; then
          "$_oc" --weaken-symbol=asm_parser_bootstrap_mega_emit_allowed \
            build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
        # w1564: weaken egg force-stub so the overlay first-wins.
        # PLATFORM: WINDOWS.
        if [ -n "$_PABI_PARSER_FORCE_STUB" ]; then
          "$_oc" --weaken-symbol=asm_parser_emit_heavy_force_stub \
            build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
        # w1501: weaken egg module-let string pool baker (127 head chunk).
        # PLATFORM: WINDOWS.
        if [ -n "$_PABI_MODLET_STRPOOL" ]; then
          "$_oc" --weaken-symbol=pipe_modlet_bake_string_lit_elem_to_data \
            build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
        # w1510: weaken egg STRUCT_LIT field offset/type/store_sz (by-name).
        # PLATFORM: WINDOWS.
        if [ -n "$_PABI_STRUCT_LIT_FIELD" ]; then
          for _slsym in pipeline_expr_struct_lit_field_offset_at \
              pipeline_expr_struct_lit_field_type_ref_at glue_struct_lit_field_store_sz; do
            "$_oc" --weaken-symbol="$_slsym" \
              build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
          done
        fi
        # w1521: weaken egg INDEX base eff-addr (single *T field peel).
        # PLATFORM: WINDOWS.
        if [ -n "$_PABI_INDEX_BASE_FIELD" ]; then
          "$_oc" --weaken-symbol=glue_emit_index_eff_addr_base_elf_c \
            build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
        # w1511: weaken egg module-let scalar COMMON gate (f32 imm).
        # PLATFORM: WINDOWS.
        if [ -n "$_PABI_MODLET_FLOAT_IMM" ]; then
          "$_oc" --weaken-symbol=pipe_modlet_scalar_init_common_imm \
            build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
        # w1502: weaken egg VAR assign gate (pure .x gate first-wins).
        # PLATFORM: WINDOWS.
        if [ -n "$_PABI_ASSIGN_VAR" ]; then
          "$_oc" --weaken-symbol=glue_emit_assign_var_elf_c \
            build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
        # w1041: weaken egg call_spill so overlay first-wins.
        # PLATFORM: WINDOWS.
        if [ -n "$_PABI_CALL_SPILL" ]; then
          "$_oc" --weaken-symbol=glue_asm_sum_block_call_spill_bytes \
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
    # w1038: PE has no true weak (XLANG_WEAK empty). seed_link_compat
    # arch_*_enc_enc_label stubs and asm_full_link_stubs arch_*_emit_call
    # become strong T and first-wins over enc_dispatch / text authority.
    # Weaken copies so real T is unique. PLATFORM: WINDOWS.
    _oc=""
    if command -v llvm-objcopy >/dev/null 2>&1; then
      _oc=llvm-objcopy
    elif command -v objcopy >/dev/null 2>&1; then
      _oc=objcopy
    fi
    if [ -n "$_oc" ]; then
      mkdir -p build_asm/selfhost_pabi
      if [ -s src/seed_link_compat.o ]; then
        cp -f src/seed_link_compat.o build_asm/selfhost_pabi/seed_link_compat_weak.o
        for _wsym in arch_arm64_enc_enc_label arch_riscv64_enc_enc_label; do
          "$_oc" --weaken-symbol="$_wsym" \
            build_asm/selfhost_pabi/seed_link_compat_weak.o 2>/dev/null || true
        done
        _SEED_LINK_COMPAT="build_asm/selfhost_pabi/seed_link_compat_weak.o"
      fi
      if [ -s build_asm/seed_host/asm_full_link_stubs.o ]; then
        cp -f build_asm/seed_host/asm_full_link_stubs.o \
          build_asm/selfhost_pabi/asm_full_link_stubs_weak.o
        for _wsym in arch_x86_64_emit_call arch_arm64_emit_call \
          arch_riscv64_emit_call arch_arm64_enc_enc_label \
          arch_riscv64_enc_enc_label; do
          "$_oc" --weaken-symbol="$_wsym" \
            build_asm/selfhost_pabi/asm_full_link_stubs_weak.o 2>/dev/null || true
        done
        # shellcheck disable=SC2001
        _USER_ASM_LINK="$(printf '%s' "$_USER_ASM_LINK" | sed \
          's|build_asm/seed_host/asm_full_link_stubs\.o|build_asm/selfhost_pabi/asm_full_link_stubs_weak.o|g')"
      fi
    fi
    # w1053: PE first-wins. backend_x86_64_enc_c.o is linked ahead of
    # backend_enc_dispatch.o, so its add/sub/store and x86_enc_jcc_rel32
    # hide the dispatch bodies. enc_c jcc records the patch slot before
    # the 6-byte branch is written (option illegal instruction, stdlib-import
    # SEGV). enc_c store splits the byte template from disp32. objcopy -N
    # cannot drop x86_enc_jcc_rel32: four relocs still name it. Undefine
    # those four defs on a COPY; relocs stay and bind dispatch. Do not
    # rebuild either encoder object. Do not edit the original .o.
    # PLATFORM: WINDOWS.
    if [ -s src/asm/backend_x86_64_enc_c.o ]; then
      mkdir -p build_asm/selfhost_pabi
      _enc_copy=build_asm/selfhost_pabi/enc_c_dispatch_wins.o
      cp -f src/asm/backend_x86_64_enc_c.o "$_enc_copy"
      if ! python3 scripts/win_coff_keep_earliest_sym.py --undefine "$_enc_copy" \
          x86_enc_jcc_rel32 \
          arch_x86_64_enc_enc_store_rax_to_rbx_offset \
          arch_x86_64_enc_enc_add_rax_rbx \
          arch_x86_64_enc_enc_sub_rax_rbx; then
        echo "g05_relink_env: enc dispatch-wins undefine failed" >&2
        exit 1
      fi
      # Bash replace, not sed: MSYS rewrites a sed script that contains a
      # drive-letter path and the pattern stops matching.
      _USER_ASM_LINK="${_USER_ASM_LINK//src\/asm\/backend_x86_64_enc_c.o/$_enc_copy}"
      case "$_USER_ASM_LINK" in
        *src/asm/backend_x86_64_enc_c.o*)
          echo "g05_relink_env: enc_c path still in the Windows link" >&2
          exit 1
          ;;
      esac
    fi
    ;;
esac
# Default seed_link_compat path (POSIX keeps src/; Win may override above).
: "${_SEED_LINK_COMPAT:=src/seed_link_compat.o}"
_DRIVER_SEED_OBJS="$_PABI_INDEX_BASE_FIELD $_PABI_RETURN_SRET $_PABI_MODLET_FLOAT_IMM $_PABI_STRUCT_LIT_FIELD $_PABI_F32_DEMOTE $_PABI_ASM_EXPR $_PABI_ASSIGN_VAR $_PABI_MODLET_STRPOOL $_PABI_BINOP_WIDE $_PABI_PARSER_MEGA_ALLOW $_PABI_PARSER_FORCE_STUB $_PABI_WIN_PARAM_HOME $_PABI_TAIL_JMP_OFF $_PABI_BB_CACHE $_PABI_CALL_SPILL $_PABI_FRAME_SIZE $_PABI_REENT_NOCAP $_PABI_SELFHOST $_WIN_ASSIGN_OVERRIDES $_PABI_WPO_THIN $_PABI_WPO_CAP $_PABI_RELOC_TYPED $_PABI_DATA_LEN $_PABI_CONST_LIT $_MAIN_LINK_O src/runtime_io_abi.o src/runtime_link_abi.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/diag.o $_PANIC_LINK_O $_PABI_LINK_O $_DRIVER_SEED_RUNTIME_O $_RT_SEED_SLICE_OBJS runtime_process_argv.o src/driver/fmt_check_cmd_driver.o src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o $_LEXER_LINK_O $_AST_LINK_O $_X_FRONTEND $_DRIVER_SEED_SUPPORT src/x_seed_bridge.o $_SEED_LINK_COMPAT src/token_typekind_tag_tables.o"

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
# w1498: LEGACY also links and heats runtime_driver_no_c.o (runtime_driver.o retired).
# wave304: strict_minimal shell retired — no longer a hot C rebuild target.
if [ "${XLANG_NO_C_SEED_LINK:-0}" != "1" ] && [ "${XLANG_LEGACY_C_FRONTEND:-0}" = "1" ]; then
  G05_HOT_C_OBJS="src/runtime_link_abi.o src/runtime_driver_no_c.o"
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
