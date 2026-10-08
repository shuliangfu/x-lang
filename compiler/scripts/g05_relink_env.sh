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
# PLATFORM: LINUX | WINDOWS — idiv %rbx is 64-bit (48 f7 fb), so the
# live sign-extend has to be cqo (48 99), not cltd (99). This one-symbol
# object is linked first. Linux: ahead of backend_x86_64_enc_c.o.
# Windows: ahead of backend_x86_64_enc_c.o and backend_enc_dispatch.o
# (PE first strong definition wins; Linux --allow-multiple-definition
# is the same first-wins). Both of those objects also define
# arch_x86_64_enc_enc_cltd. Darwin is arm64 and must not link this
# object. Do not rebuild either encoder TU: their other symbols stay.
# Linux and Windows rebuild src/asm/backend_x86_64_enc_cltd_cqo_thin.x
# after _g05_pure_overlay is defined, and exit 1 if that object is
# missing. An absent file is prepended only after that rebuild.
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
# w2060: cqo unit. The on-disk cltd_cqo.o is a leftover (frame 0x868)
# that still appends 0x48 then 0x99. backend_enc_dispatch.o and
# backend_x86_64_enc_c.o each have their own strong T of
# arch_x86_64_enc_enc_cltd, so this object has to be linked first.
# Rebuild the tip thin every Linux and Windows relink. That thin
# appends the same two bytes and does not divide. A missing object
# exits 1. The path was prepended above when a leftover existed; if
# it was absent, prepend it once here. Darwin does not link this object.
# PLATFORM: LINUX | WINDOWS | MSYS | MINGW.
case "$UNAME_S" in
  Linux|MINGW*|MSYS*|CYGWIN*|Windows_NT*)
    _g05_pure_overlay src/asm/backend_x86_64_enc_cltd_cqo_thin.x \
      build_asm/selfhost_pabi/cltd_cqo.o \
      arch_x86_64_enc_enc_cltd
    if [ ! -s build_asm/selfhost_pabi/cltd_cqo.o ]; then
      echo "g05_relink_env: ERROR cltd_cqo .x did not build" >&2
      exit 1
    fi
    case "$_USER_ASM_LINK" in
      *build_asm/selfhost_pabi/cltd_cqo.o*)
        ;;
      *)
        _USER_ASM_LINK="build_asm/selfhost_pabi/cltd_cqo.o $_USER_ASM_LINK"
        ;;
    esac
    ;;
esac
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
# w1544/w2056: CALL-returned slice deep-copy, one rule with no size cap:
# data on the callee's (now popped) stack is copied in full into a malloc
# block; data anywhere else is aliased. Strong T first-wins egg weak
# (Darwin) / --allow-multiple-definition (Linux) / weakened pabi_weak T
# (Windows). Ahead of _PABI_SELFHOST. PLATFORM: SHARED.
_g05_pure_overlay src/runtime_pipeline_abi_reent_nocap_thin.x \
  build_asm/selfhost_pabi/reent_nocap.o glue_slice_let_reent_deep_copy_after_dual_gp_elf_c
_PABI_REENT_NOCAP="$_G05_PO_OUT"
# w1584: egg glue_sum_block_slice_reent_dc_bytes_c adds the <=1024 slice
# payload into its total slot, then the esz>8 false branch jumps to the
# epilogue with eax=0. compute_frame_size therefore reserves nothing, and
# the use_frame=1 deep copy (reent_nocap) is placed below rsp. The current
# product compiles the existing w157 thin so that false branch falls
# through and the epilogue returns the total slot. Link that strong T
# ahead of the egg. Localize the unprefixed walker and the spill twins in
# this object: they must not replace the egg w157_walk_block_rec_x or
# glue_asm_sum_block_call_spill_bytes. Not an ld -r egg reinject (wave406
# HARD BAN). Algorithm stays the thin body. PLATFORM: SHARED.
_PABI_REENT_SUM=""
if [ "${XLANG_REENT_SUM_OVERLAY:-1}" = "1" ]; then
  _g05_pure_overlay src/runtime_pipeline_abi_w157_sum_thin.x \
    build_asm/selfhost_pabi/reent_sum.o glue_sum_block_slice_reent_dc_bytes_c
  _PABI_REENT_SUM="$_G05_PO_OUT"
  if [ -n "$_PABI_REENT_SUM" ] && [ -s "$_PABI_REENT_SUM" ]; then
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
    if [ -z "$_oc" ]; then
      echo "g05_relink_env: ERROR reent sum overlay has no objcopy" >&2
      printf '%s overlay-missing g05_relink_env: %s (no objcopy)\n' \
        "$(date +%H:%M:%S)" "$_PABI_REENT_SUM" \
        >>build_asm/g05_xasm_crash.log 2>/dev/null || true
      _PABI_REENT_SUM=""
    else
      for _hsym in w157_walk_block_rec_x \
          pipeline_w157_sum_expr_call_spill_bytes \
          pipeline_glue_asm_sum_block_call_spill_bytes \
          glue_asm_sum_block_call_spill_bytes; do
        if nm "$_PABI_REENT_SUM" 2>/dev/null | grep -qE " T ${_hsym}\$"; then
          "$_oc" --localize-symbol="${_hsym}" "$_PABI_REENT_SUM" || { echo "g05_relink_env: ERROR objcopy failed at line 406" >&2; exit 1; }
        fi
        if nm "$_PABI_REENT_SUM" 2>/dev/null | grep -qE " T _${_hsym}\$"; then
          "$_oc" --localize-symbol="_${_hsym}" "$_PABI_REENT_SUM" || { echo "g05_relink_env: ERROR objcopy failed at line 409" >&2; exit 1; }
        fi
      done
      if ! nm "$_PABI_REENT_SUM" 2>/dev/null \
        | grep -qE " T _*glue_sum_block_slice_reent_dc_bytes_c\$"; then
        echo "g05_relink_env: ERROR reent sum overlay lost T glue_sum_block_slice_reent_dc_bytes_c" >&2
        printf '%s overlay-missing g05_relink_env: %s (T lost after localize)\n' \
          "$(date +%H:%M:%S)" "$_PABI_REENT_SUM" \
          >>build_asm/g05_xasm_crash.log 2>/dev/null || true
        _PABI_REENT_SUM=""
      elif nm "$_PABI_REENT_SUM" 2>/dev/null \
        | grep -qE " T _*w157_walk_block_rec_x\$"; then
        echo "g05_relink_env: ERROR reent sum walker still global" >&2
        printf '%s overlay-missing g05_relink_env: %s (walker still global)\n' \
          "$(date +%H:%M:%S)" "$_PABI_REENT_SUM" \
          >>build_asm/g05_xasm_crash.log 2>/dev/null || true
        _PABI_REENT_SUM=""
      fi
    fi
  fi
fi
# w1544: Cap residual field load/store width (w1007/w1008), now rebuilt
# from .x by the current product on every relink instead of a stale
# prebuilt object. Enum-typed struct fields are 4 bytes (Token.kind store
# used to write 8 and zero Token.line). Consumed below by the per-OS
# _PABI_SELFHOST blocks. PLATFORM: SHARED.
_g05_pure_overlay src/runtime_pipeline_abi_field_cap_residual_load_thin.x \
  build_asm/selfhost_pabi/field_cap_residual_load.o pipeline_expr_field_access_load_byte_sz
# w1486 / w2060: Windows block-entry VAR-slot cache clear lives in
# backend_emit_block_body_sync_elf in the let-order thin below. That
# function clears only when link_abi_host_is_windows() is set, then binds
# and emits. The host-cc overlay that only cleared and forwarded is not a
# build input. Egg T is weakened when the let-order object exists.
# PLATFORM: WINDOWS | MSYS | MINGW for the clear; Darwin/Linux do not clear.
# w2060: Windows let-order / emit_let_init compile from the same .x Darwin
# and Linux already overlay. The host-gcc .c twins stayed for two old PE
# symptoms: store_eax returned -1 after a null compare that did not reload
# elf_ctx, and the egg body_sync forwarder left the VAR-slot cache stale.
# The installed Windows compiler reloads elf_ctx (probe_store_eax_null),
# and backend_emit_block_body_sync_elf clears the cache when
# link_abi_host_is_windows() is set. A missing object exits 1. No host-cc
# of the .c twins or of the cache-clear overlay.
# PLATFORM: WINDOWS | MSYS | MINGW only — Darwin/Linux use the block below.
case "$UNAME_S" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT*)
    _g05_pure_overlay src/runtime_pipeline_abi_block_body_sync_let_order_thin.x \
      build_asm/selfhost_pabi/body_sync_let_order.o pipeline_asm_emit_block_body_sync_elf
    if [ ! -s build_asm/selfhost_pabi/body_sync_let_order.o ]; then
      echo "g05_relink_env: ERROR Windows body_sync let-order .x did not build" >&2
      exit 1
    fi
    _g05_pure_overlay src/runtime_pipeline_abi_glue_block_body_emit_let_init_thin.x \
      build_asm/selfhost_pabi/emit_let_init.o glue_block_body_emit_let_init
    if [ ! -s build_asm/selfhost_pabi/emit_let_init.o ]; then
      echo "g05_relink_env: ERROR Windows emit_let_init .x did not build" >&2
      exit 1
    fi
    ;;
esac
# w1487 / w2060: Windows tail-jmp comes from the same tip thin Darwin and
# Linux already inject. That thin has the w1483 single-statement gate, so a
# body that is not one forwarder stays on the normal prologue path. The
# host-cc overlay that always returned 0 is not a build input. Missing
# object exits 1. Egg w499 is still weakened below so this T first-wins.
# PLATFORM: WINDOWS | MSYS | MINGW only.
_PABI_TAIL_JMP_OFF=""
case "$UNAME_S" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT*)
    _g05_pure_overlay src/runtime_pipeline_abi_asm_codegen_mega_emit_tail_jmp_thin.x \
      build_asm/selfhost_pabi/tail_jmp_off.o w499_mega_try_tail_jmp
    if [ ! -s build_asm/selfhost_pabi/tail_jmp_off.o ]; then
      echo "g05_relink_env: ERROR Windows tail-jmp .x did not build" >&2
      exit 1
    fi
    _PABI_TAIL_JMP_OFF="build_asm/selfhost_pabi/tail_jmp_off.o"
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
# R_X86_64_PLT32, so this overlay is the linked body. The thin keeps no
# names, drops those three prefixes, emits parser_expr_wrap_in_return
# (w1577: a ret0 stub aborted fmt), emits parser_alloc_float_lit
# (w1579: a ret0 stub dropped a plain f64 literal), emits
# parser_alloc_true_bool_lit (w1580: a ret0 stub dropped main from a
# loop), emits wrap_block_ref_as_expr (w1581: a ret0 stub dropped main
# from a bare block), emits try_skip_allow_padding_struct (w1582: the
# stub path was a 24-byte argument-less call to the glue), and emits
# try_skip_allow_padding_struct_buf (w1583: safe_helper already returns
# 1, so the list compare never ran and the probe body stays 348 bytes).
# A failed compile is logged and blocks the link. PLATFORM: SHARED.
_PABI_PARSER_FORCE_STUB=""
if [ "${XLANG_PARSER_FORCE_STUB_OVERLAY:-1}" = "1" ]; then
  _g05_pure_overlay src/runtime_pipeline_abi_parser_force_stub_thin.x \
    build_asm/selfhost_pabi/parser_force_stub.o asm_parser_emit_heavy_force_stub
  _PABI_PARSER_FORCE_STUB="$_G05_PO_OUT"
fi
# w1565: parser EMIT_HEAVY thin-delegate predicate. The egg
# asm_parser_func_is_thin_delegate returns 1 for a 116-row name table.
# skip_heavy calls it with R_X86_64_PLT32, so this overlay is the linked
# body. The thin returns 0. A throwaway link changed only
# parser_token_is_label_start (24-byte glue call → real body); the 87
# eight-byte glue jumps stayed byte-identical because parser.x already
# tails to those glues. A failed compile is logged and blocks the link.
# PLATFORM: SHARED.
_PABI_PARSER_THIN_DELEGATE=""
if [ "${XLANG_PARSER_THIN_DELEGATE_OVERLAY:-1}" = "1" ]; then
  _g05_pure_overlay src/runtime_pipeline_abi_parser_thin_delegate_thin.x \
    build_asm/selfhost_pabi/parser_thin_delegate.o asm_parser_func_is_thin_delegate
  _PABI_PARSER_THIN_DELEGATE="$_G05_PO_OUT"
fi
# w1572: ELF undef workspace. The egg pipe_elf_undef_cap is weak and
# returns 256. Its name/len BSS is local and 256 rows, and only the three
# weak accessors reference it. The .x authorities already return 2048 and
# size the rows at 2048. This overlay is those four strong symbols plus
# the 2048-row storage. A missing T blocks the link (crash log). Do not
# rebuild the pabi egg. PLATFORM: SHARED.
_PABI_ELF_UNDEF_CAP=""
if [ "${XLANG_ELF_UNDEF_CAP_OVERLAY:-1}" = "1" ]; then
  # Same product compile as _g05_pure_overlay, plus a 240s cap. The 2048-row
  # BSS is larger than the other thins. A hang must not pin the relink.
  # PLATFORM: SHARED.
  _cap_x=src/runtime_pipeline_abi_elf_undef_cap_thin.x
  _cap_o=build_asm/selfhost_pabi/elf_undef_cap.o
  _G05_PO_OUT=""
  if [ -f "$_cap_x" ] && [ -x ./xlang_asm ]; then
    mkdir -p build_asm/selfhost_pabi
    rm -f "$_cap_o" "$_cap_o.tmp.o"
    # macOS has no timeout(1); perl alarm gives the same 240s cap there
    # (SIGALRM exit >= 128 is logged as a crash below).
    if command -v timeout >/dev/null 2>&1; then
      _cap_to="timeout 240"
    else
      _cap_to="perl -e alarm(240);exec(@ARGV)"
    fi
    _cap_try=1
    while [ "$_cap_try" -le 3 ]; do
      _cap_rc=0
      $_cap_to ./xlang_asm -backend asm -c "$_cap_x" -o "$_cap_o.tmp.o" \
        >/dev/null 2>&1 || _cap_rc=$?
      if [ "$_cap_rc" -eq 0 ] && [ -s "$_cap_o.tmp.o" ]; then
        mv -f "$_cap_o.tmp.o" "$_cap_o"
        break
      fi
      if [ "$_cap_rc" -eq 124 ] || [ "$_cap_rc" -ge 128 ]; then
        printf '%s rc=%s g05_relink_env: ./xlang_asm -backend asm -c %s\n' \
          "$(date +%H:%M:%S)" "$_cap_rc" "$_cap_x" \
          >>build_asm/g05_xasm_crash.log 2>/dev/null || true
      fi
      rm -f "$_cap_o.tmp.o"
      _cap_try=$((_cap_try + 1))
    done
    if [ -s "$_cap_o" ]; then
      _cap_ok=1
      for _csym in pipe_elf_undef_cap pipe_elf_ws_undef_name_row \
          pipe_elf_ws_undef_len_at pipe_elf_ws_undef_len_set; do
        if ! nm "$_cap_o" 2>/dev/null | grep -q "T _*${_csym}\$"; then
          _cap_ok=0
        fi
      done
      if [ "$_cap_ok" = "1" ]; then
        _G05_PO_OUT="$_cap_o"
      else
        echo "g05_relink_env: ERROR elf undef cap overlay missing a T" >&2
        printf '%s overlay-missing g05_relink_env: %s (accessor T)\n' \
          "$(date +%H:%M:%S)" "$_cap_x" \
          >>build_asm/g05_xasm_crash.log 2>/dev/null || true
        rm -f "$_cap_o"
      fi
    else
      echo "g05_relink_env: ERROR pure overlay $_cap_x did not build (T pipe_elf_undef_cap)" >&2
      printf '%s overlay-missing g05_relink_env: %s (no T pipe_elf_undef_cap)\n' \
        "$(date +%H:%M:%S)" "$_cap_x" \
        >>build_asm/g05_xasm_crash.log 2>/dev/null || true
    fi
  elif [ ! -x ./xlang_asm ]; then
    echo "g05_relink_env: WARNING pure overlay $_cap_x not built (no ./xlang_asm)" >&2
  fi
  _PABI_ELF_UNDEF_CAP="$_G05_PO_OUT"
fi
# w1576: qualified TYPE_NAMED size. The egg glue_type_size_simple is weak
# and exact-matches layout names, so token.Token misses and returns 4.
# LexerResult is then 32 and allow(padding) drops ident_len. The mega
# suffix rule is the authority; this overlay is that strong body. Small
# (one u8[256], no huge BSS), so the ordinary overlay compile is enough.
# A missing T blocks the link. Do not rebuild the pabi egg.
# PLATFORM: SHARED.
_PABI_NAMED_SIZE=""
if [ "${XLANG_NAMED_SIZE_OVERLAY:-1}" = "1" ]; then
  _g05_pure_overlay src/runtime_pipeline_abi_named_size_thin.x \
    build_asm/selfhost_pabi/named_size.o glue_type_size_simple
  _PABI_NAMED_SIZE="$_G05_PO_OUT"
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
# Linux and Windows link asm_expr_helpers_thin.x for the 9..16 field pair.
# Darwin keeps this full thin. All three already emit wide imm64.
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
# so the per-level mask reaches the product. Windows compiles the same .x
# in the MINGW block above. PLATFORM: MACOS|DARWIN + LINUX.
case "$UNAME_S" in
  Darwin|Linux)
    if [ "${XLANG_BODY_SYNC_LET_ORDER_OVERLAY:-1}" = "1" ]; then
      _g05_pure_overlay src/runtime_pipeline_abi_block_body_sync_let_order_thin.x \
        build_asm/selfhost_pabi/body_sync_let_order.o pipeline_asm_emit_block_body_sync_elf
    fi
    # w2060: empty ARRAY_LIT [] on fixed T[N] must zero-fill (C ={}). Egg
    # glue_block_body_emit_let_init early-returned with no stores. Tip stack
    # reuse then skipped parse_one_function_impl name consume (XT001).
    # Strong thin first-wins. PLATFORM: MACOS|DARWIN + LINUX.
    if [ "${XLANG_EMIT_LET_INIT_EMPTY_FIXED_OVERLAY:-1}" = "1" ]; then
      _g05_pure_overlay src/runtime_pipeline_abi_glue_block_body_emit_let_init_thin.x \
        build_asm/selfhost_pabi/emit_let_init.o glue_block_body_emit_let_init
    fi
    ;;
esac
# wave767 Class R: Win PE assign overrides (allow-multiple first-wins).
# field stays. var and deref scalar are the egg T. Built by g05_ensure
# when seeds present.
# w2060: index is not in this list while the true-pack stack is on.
# assign_index_true_i8.o is an earlier strong T of
# glue_emit_assign_index_elf_c. See the filter after _WIN_TRUE_PACK.
# w2060: do not link src/win_struct_let_init_override.o. The egg T
# pipeline_asm_emit_struct_let_init_elf_c is the windows_link_stubs body,
# and that body matches the override (129 bytes; call rel32 ignored).
# Same-TU calls already use the egg copy. A second T only feeds the
# redirect when two defs exist.
# w2060: do not link src/win_copy_large_struct_override.o. The egg T
# glue_copy_large_struct_from_rax_ptr_elf_c is the windows_link_stubs body,
# and that body matches the override (1029 bytes; call rel32 ignored).
# The store-pair thin only has an undefined reference, so external
# callers resolve to this one egg T.
# w2060: do not link src/win_assign_deref_override.o. The egg T
# glue_emit_assign_deref_elf_c is the windows_link_stubs body, and that
# body matches the override (359 bytes; call rel32 ignored). The override
# object defines only that one T. Do not switch assign_deref_thin.x on.
# w2060: do not link src/win_vector_type_let_init_override.o. The egg T
# glue_emit_vector_type_let_init_elf_c is the windows_link_stubs body,
# and that body matches the override (605 bytes; call rel32 ignored).
# The override object defines only that one T.
# w2060: do not link src/win_m8_tail_override.o. The egg defines the four
# asm_*_m8_tail_thin_delegate_c_name symbols from windows_link_stubs.c.
# Each matches the override once call rel32 and trailing nops are
# ignored (357, 373, 373, and 507 bytes). The backend and pipeline
# static tables match (1440 and 96 bytes; pointer relocs ignored).
# The driver and typeck tables are empty. The override defines only
# those four T symbols. Do not switch a thin on for them.
# w2060: do not link src/win_asm_parser_override.o. The egg defines
# asm_parser_emit_heavy_safe_helper, asm_parser_func_is_thin_delegate,
# and asm_parser_m8_tail_thin_delegate_c_name from windows_link_stubs.c.
# Each matches the override once call rel32 and trailing nops are
# ignored (9776, 168, and 357 bytes). The 116-row table matches
# (3712 bytes; pointer relocs ignored; 232 strings). The override
# defines only those three T symbols. The parser thin-delegate overlay
# stays linked ahead and still returns 0. Do not switch another thin on.
# w2060: do not link src/win_wpo_collect_walk_override.o. The egg T
# asm_wpo_collect_walk in src/runtime_pipeline_abi.o is 22 bytes: push
# rbp, save the four register args, pop, ret. The override is that same
# sequence plus trailing nops, and it defines only that one T. Same-TU
# calls already use the egg copy. Do not switch asm_wpo_thin.x on.
# w2060: do not link src/win_simd_splat_override.o. The egg T
# pipeline_asm_simd_try_inline_splat_call_elf_c is the
# windows_link_stubs body. It matches the override: 1236 bytes, 256
# insns, and the same 20 call relocs. The static name check sits 0xdc
# bytes ahead in both objects. The override's only global T is that
# function. Same-TU stub calls already enter the egg copy. Do not
# switch a thin on.
# w2060: do not link src/win_simd_select_shuffle_fma_override.o. The
# egg defines pipeline_asm_simd_try_inline_shuffle_call_elf_c,
# pipeline_asm_simd_try_inline_select_call_elf_c, and
# pipeline_asm_simd_try_inline_fma3_call_elf_c from
# windows_link_stubs.c. In the linked image each matches the override:
# shuffle 1370 bytes / 284 insns, select 1918 bytes / 389 insns, fma
# 1245 bytes / 261 insns. Call targets are the same symbols. The string
# LEAs load the same literals (shuffle 5, select 5, fma 1). The
# override's only global T symbols are those three. The egg select call
# to splat is already bound inside the TU. Same-TU vector-let-init
# calls already enter the egg copies. Do not switch a thin on.
# PLATFORM: WINDOWS | MSYS | MINGW only — Darwin/Linux ignore.
_WIN_ASSIGN_OVERRIDES=""
case "$UNAME_S" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT*)
    # w1020: when true-pack tip stack is ON (default; XLANG_WIN_BAKE_TIP=0
    # forces Cap residual), skip src/win_index Cap residual twin.
    # Tip INDEX objects are the three .x overlays. PLATFORM: WINDOWS.
    _skip_src_win_index=0
    if [ "${XLANG_WIN_BAKE_TIP:-}" != "0" ] \
      && [ -s build_asm/selfhost_pabi/index_elem_true_i8.o ]; then
      _skip_src_win_index=1
    fi
    for _wov in src/win_assign_field_override.o src/win_assign_index_override.o src/win_wpo_pgo_emit_override.o src/win_index_elem_byte_sz_override.o; do
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
# w2055: sym=object pairs the relink must prove won (Darwin ld map check).
_G05_LINK_WINNERS=""
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
    objcopy --weaken-symbol=pipeline_asm_emit_return_elf_impl "$_PABI_LINK_O" || { echo "g05_relink_env: ERROR objcopy failed at line 889" >&2; exit 1; }
  fi
fi
# w1558: egg allow-list is already weak. If a rebuild leaves it strong,
# weaken so the overlay first-wins. PLATFORM: LINUX.
if [ "$UNAME_S" = "Linux" ] && [ -n "$_PABI_PARSER_MEGA_ALLOW" ] && [ -s "$_PABI_LINK_O" ] \
  && command -v objcopy >/dev/null 2>&1; then
  if nm "$_PABI_LINK_O" 2>/dev/null | grep -qE " T asm_parser_bootstrap_mega_emit_allowed$"; then
    objcopy --weaken-symbol=asm_parser_bootstrap_mega_emit_allowed "$_PABI_LINK_O" || { echo "g05_relink_env: ERROR objcopy failed at line 897" >&2; exit 1; }
  fi
fi
# w1564: egg force-stub is already weak. If a rebuild leaves it strong,
# weaken so the overlay first-wins. PLATFORM: LINUX.
if [ "$UNAME_S" = "Linux" ] && [ -n "$_PABI_PARSER_FORCE_STUB" ] && [ -s "$_PABI_LINK_O" ] \
  && command -v objcopy >/dev/null 2>&1; then
  if nm "$_PABI_LINK_O" 2>/dev/null | grep -qE " T asm_parser_emit_heavy_force_stub$"; then
    objcopy --weaken-symbol=asm_parser_emit_heavy_force_stub "$_PABI_LINK_O" || { echo "g05_relink_env: ERROR objcopy failed at line 905" >&2; exit 1; }
  fi
fi
# w1565: egg thin-delegate predicate is already weak. If a rebuild leaves
# it strong, weaken so the overlay first-wins. PLATFORM: LINUX.
if [ "$UNAME_S" = "Linux" ] && [ -n "$_PABI_PARSER_THIN_DELEGATE" ] && [ -s "$_PABI_LINK_O" ] \
  && command -v objcopy >/dev/null 2>&1; then
  if nm "$_PABI_LINK_O" 2>/dev/null | grep -qE " T asm_parser_func_is_thin_delegate$"; then
    objcopy --weaken-symbol=asm_parser_func_is_thin_delegate "$_PABI_LINK_O" || { echo "g05_relink_env: ERROR objcopy failed at line 913" >&2; exit 1; }
  fi
fi
# w1572: egg undef cap and the three workspace accessors are already weak.
# If a refresh leaves any of them strong, weaken so the overlay first-wins.
# PLATFORM: LINUX.
if [ "$UNAME_S" = "Linux" ] && [ -n "$_PABI_ELF_UNDEF_CAP" ] && [ -s "$_PABI_LINK_O" ] \
  && command -v objcopy >/dev/null 2>&1; then
  for _csym in pipe_elf_undef_cap pipe_elf_ws_undef_name_row \
      pipe_elf_ws_undef_len_at pipe_elf_ws_undef_len_set; do
    if nm "$_PABI_LINK_O" 2>/dev/null | grep -qE " T ${_csym}$"; then
      objcopy --weaken-symbol="$_csym" "$_PABI_LINK_O" || { echo "g05_relink_env: ERROR objcopy failed at line 924" >&2; exit 1; }
    fi
  done
fi
# w1576: egg glue_type_size_simple is already weak. If a refresh leaves
# it strong, weaken so the named-size overlay first-wins.
# PLATFORM: LINUX.
if [ "$UNAME_S" = "Linux" ] && [ -n "$_PABI_NAMED_SIZE" ] && [ -s "$_PABI_LINK_O" ] \
  && command -v objcopy >/dev/null 2>&1; then
  if nm "$_PABI_LINK_O" 2>/dev/null | grep -qE " T glue_type_size_simple$"; then
    objcopy --weaken-symbol=glue_type_size_simple "$_PABI_LINK_O" || { echo "g05_relink_env: ERROR objcopy failed at line 934" >&2; exit 1; }
  fi
fi
# w1584: egg slice-reent sum is a strong T that returns 0 after adding the
# payload. Weaken the pabi link object (build_asm only; never the src egg)
# so the overlay first-wins. spill.o already carries a weak copy.
# PLATFORM: LINUX.
if [ "$UNAME_S" = "Linux" ] && [ -n "$_PABI_REENT_SUM" ] && [ -s "$_PABI_LINK_O" ] \
  && command -v objcopy >/dev/null 2>&1; then
  case "$_PABI_LINK_O" in
    build_asm/*)
      if nm "$_PABI_LINK_O" 2>/dev/null \
        | grep -qE " T glue_sum_block_slice_reent_dc_bytes_c$"; then
        objcopy --weaken-symbol=glue_sum_block_slice_reent_dc_bytes_c \
          "$_PABI_LINK_O" 2>/dev/null || true
      fi
      ;;
  esac
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
# w2060: empty [] fixed T[N] zero-fill emit_let_init. First-wins.
# PLATFORM: LINUX
if [ -n "$_PABI_SELFHOST" ] && [ -s build_asm/selfhost_pabi/emit_let_init.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/emit_let_init.o $_PABI_SELFHOST"
fi
# w2060: Linux deref sidecar. The on-disk object is an Oct 1 leftover and
# nothing rebuilt it, so a missing file used to keep the egg body. The egg
# symbol pipeline_asm_emit_deref_elf_c is already weak. The tip thin's four
# helpers are emitted as pipeline_deref_* and are not defined in the egg,
# so this does not weaken anything. Rebuild that thin every Linux relink
# while the self-host pabi set is linked. A missing object exits 1. Windows
# and Darwin leave _PABI_SELFHOST empty here and do not build this object.
# Do not rebuild the pabi egg.
# PLATFORM: LINUX
case "$UNAME_S" in
  Linux)
    if [ -n "$_PABI_SELFHOST" ]; then
      _g05_pure_overlay src/runtime_pipeline_abi_deref_narrow_thin.x \
        build_asm/selfhost_pabi/runtime_pipeline_abi_deref_narrow_thin.o \
        pipeline_asm_emit_deref_elf_c
      if [ ! -s build_asm/selfhost_pabi/runtime_pipeline_abi_deref_narrow_thin.o ]; then
        echo "g05_relink_env: ERROR Linux deref_narrow .x did not build" >&2
        exit 1
      fi
    fi
    ;;
esac
# w1590: deref load uses the pointer pointee width. First-wins over the egg.
# The rebuild above exits 1 when this set is linked and the object is missing.
# PLATFORM: LINUX
if [ -n "$_PABI_SELFHOST" ] && [ -s build_asm/selfhost_pabi/runtime_pipeline_abi_deref_narrow_thin.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/runtime_pipeline_abi_deref_narrow_thin.o $_PABI_SELFHOST"
fi
# w1594: i32 - i64 skips the cltq after subq. Recompile the w1591 object
# from this source on Linux. A missing T is logged and the link is refused.
# PLATFORM: LINUX
case "$UNAME_S" in
  Linux)
    if [ "${XLANG_WIDEN_MIXED_OVERLAY:-1}" = "1" ]; then
      _g05_pure_overlay src/runtime_pipeline_abi_widen_mixed_thin.x \
        build_asm/selfhost_pabi/runtime_pipeline_abi_widen_mixed_thin.o \
        glue_emit_binop_sub_rbx_minus_rax_elf_c
    fi
    ;;
esac
# w1591: i32+i64 add width and f32-expression promote. w1594 sub lives in
# the same object. First-wins over the egg. A missing object keeps the
# previous list. PLATFORM: LINUX
if [ -n "$_PABI_SELFHOST" ] && [ -s build_asm/selfhost_pabi/runtime_pipeline_abi_widen_mixed_thin.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/runtime_pipeline_abi_widen_mixed_thin.o $_PABI_SELFHOST"
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
# w2055: collect-deps import scan ahead of the pabi copy (old C body calls
# the struct-returning lexer_init). linux_selfhost_pabi_refresh_tip.sh
# rebuilds cimp.o on every ensure. PLATFORM: LINUX.
if [ -n "$_PABI_SELFHOST" ] && [ -s build_asm/selfhost_pabi/cimp.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/cimp.o $_PABI_SELFHOST"
fi
# w2055: enum namespace tag ahead of the pabi copies (32-byte buffer that
# pipeline_expr_var_name_into zeros 256 bytes into).
# linux_selfhost_pabi_refresh_tip.sh rebuilds enum_ns_tag.o on every ensure.
# The pabi copies of the cimp and enum
# names are weakened in the pabi link object; a failed weaken stops the
# relink, and each name goes into _G05_LINK_WINNERS for the post-link map
# check. PLATFORM: LINUX.
if [ -n "$_PABI_SELFHOST" ] && [ -s build_asm/selfhost_pabi/enum_ns_tag.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/enum_ns_tag.o $_PABI_SELFHOST"
fi
# w2060: wide STRUCT_LIT / FIELD / VAR store. The Linux egg's
# glue_store_retval_pair_to_rbp_elf_c is W and compares only 48, 49,
# and 47. linux_selfhost_pabi_refresh_tip.sh rebuilds
# store_retval_pair.o on every ensure, with no PREFER. Link it ahead
# of the egg. A strong T in the link object is weakened. The measured
# egg is already W, so that weaken waits until a later egg is T.
# A missing object stops the relink. Darwin is not switched.
# PLATFORM: LINUX.
if [ -n "$_PABI_SELFHOST" ] && [ -s build_asm/selfhost_pabi/store_retval_pair.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/store_retval_pair.o $_PABI_SELFHOST"
fi
# w2060: named-field aggregate load outside a call. The Linux egg's
# glue_field_call_arg_try_load_agg_from_rax_elf_c is W and returns 0
# when pipeline_asm_emit_call_arg_active_c is 0, so a let or assign
# never takes the 9 to 16 byte pair or the wider-than-16 address path.
# linux_selfhost_pabi_refresh_tip.sh rebuilds field_agg_load.o on every
# ensure, with no PREFER. Link it ahead of the egg. A strong T in the
# link object is weakened. The measured egg is already W. A missing
# object stops the relink. Darwin's pabi_weak already matches the tip
# gates, and Windows is not switched. PLATFORM: LINUX.
if [ -n "$_PABI_SELFHOST" ] && [ -s build_asm/selfhost_pabi/field_agg_load.o ]; then
  _PABI_SELFHOST="build_asm/selfhost_pabi/field_agg_load.o $_PABI_SELFHOST"
fi
if [ "$UNAME_S" = "Linux" ] && [ -n "$_PABI_SELFHOST" ]; then
  for _lw in "xlang_module_collect_imports_from_buf=build_asm/selfhost_pabi/cimp.o" \
      "pipeline_expr_enum_namespace_field_tag=build_asm/selfhost_pabi/enum_ns_tag.o" \
      "pipeline_asm_cmp_enum_rhs_tag_c=build_asm/selfhost_pabi/enum_ns_tag.o" \
      "glue_store_retval_pair_to_rbp_elf_c=build_asm/selfhost_pabi/store_retval_pair.o" \
      "glue_field_call_arg_try_load_agg_from_rax_elf_c=build_asm/selfhost_pabi/field_agg_load.o"; do
    _lw_s="${_lw%%=*}"; _lw_o="${_lw#*=}"
    if [ ! -s "$_lw_o" ]; then
      echo "g05_relink_env: missing $_lw_o for $_lw_s (Linux)" >&2
      exit 1
    fi
    if nm "$_PABI_LINK_O" 2>/dev/null | grep -qE " T ${_lw_s}$"; then
      if ! objcopy --weaken-symbol="$_lw_s" "$_PABI_LINK_O"; then
        echo "g05_relink_env: weaken $_lw_s in $_PABI_LINK_O failed (Linux)" >&2
        exit 1
      fi
    fi
    _G05_LINK_WINNERS="$_G05_LINK_WINNERS $_lw_s=$_lw_o"
  done
fi
# w2060: INDEX assign-address cache guard. The egg
# glue_index_assign_addr_cache_hit is a strong T (frame sub $0x68)
# that still answers from the wave156 cache. Eight R_X86_64_PLT32
# sites in that object name it. ensure's
# pipeline_abi_inject_w156_guard_thin returns without compiling once
# that T exists, so the always-miss thin never replaced the egg.
# Darwin rebuilds w156_guard_a64.o and Windows rebuilds
# w156_guard_win.o on every relink. This is the Linux twin: PREFER=1,
# one strong T, no xlang_panic_. Link it ahead of the pabi copy.
# A missing object exits 1. Weaken a strong T only on the build_asm
# link object. The later elf64k and skip_heavy copies start from that
# object, so the weaken is kept. Never edit src/runtime_pipeline_abi.o.
# PLATFORM: LINUX.
case "$UNAME_S" in
  Linux)
    if [ -n "$_PABI_SELFHOST" ]; then
      _lw156_x=src/runtime_pipeline_abi_w156_guard_thin.x
      _lw156_o=build_asm/selfhost_pabi/w156_guard.o
      _lw156_s=glue_index_assign_addr_cache_hit
      if [ ! -f "$_lw156_x" ]; then
        echo "g05_relink_env: $_lw156_x missing (Linux w156 guard)" >&2
        exit 1
      fi
      if [ ! -x ./xlang_asm ]; then
        echo "g05_relink_env: ./xlang_asm missing (Linux w156 guard)" >&2
        exit 1
      fi
      mkdir -p build_asm/selfhost_pabi
      rm -f "$_lw156_o" "$_lw156_o.tmp.o"
      if command -v timeout >/dev/null 2>&1; then
        _lw156_to="timeout 240"
      else
        _lw156_to=""
      fi
      if ! env XLANG_PREFER_ASM_O=1 $_lw156_to ./xlang_asm -backend asm -c \
          "$_lw156_x" -o "$_lw156_o.tmp.o" >/dev/null 2>&1; then
        rm -f "$_lw156_o.tmp.o"
        echo "g05_relink_env: $_lw156_x failed (Linux w156 guard)" >&2
        exit 1
      fi
      if ! nm "$_lw156_o.tmp.o" 2>/dev/null | grep -q " T ${_lw156_s}\$"; then
        rm -f "$_lw156_o.tmp.o"
        echo "g05_relink_env: $_lw156_x lacks strong $_lw156_s (Linux w156 guard)" >&2
        exit 1
      fi
      if nm "$_lw156_o.tmp.o" 2>/dev/null | grep -q 'xlang_panic_'; then
        rm -f "$_lw156_o.tmp.o"
        echo "g05_relink_env: $_lw156_x references xlang_panic_ (Linux w156 guard)" >&2
        exit 1
      fi
      if ! command -v objcopy >/dev/null 2>&1; then
        rm -f "$_lw156_o.tmp.o"
        echo "g05_relink_env: no objcopy for $_lw156_x (Linux w156 guard)" >&2
        exit 1
      fi
      for _lw156_g in $(nm "$_lw156_o.tmp.o" 2>/dev/null | awk '$2=="T"{print $3}'); do
        [ "$_lw156_g" = "$_lw156_s" ] && continue
        if ! objcopy --weaken-symbol="$_lw156_g" "$_lw156_o.tmp.o"; then
          rm -f "$_lw156_o.tmp.o"
          echo "g05_relink_env: weaken $_lw156_g in $_lw156_x failed (Linux w156 guard)" >&2
          exit 1
        fi
      done
      if ! nm "$_lw156_o.tmp.o" 2>/dev/null | grep -q " T ${_lw156_s}\$"; then
        rm -f "$_lw156_o.tmp.o"
        echo "g05_relink_env: $_lw156_x lost strong $_lw156_s (Linux w156 guard)" >&2
        exit 1
      fi
      mv -f "$_lw156_o.tmp.o" "$_lw156_o"
      _PABI_SELFHOST="$_lw156_o $_PABI_SELFHOST"
      case "$_PABI_LINK_O" in
        build_asm/*)
          if nm "$_PABI_LINK_O" 2>/dev/null | grep -qE " T ${_lw156_s}$"; then
            if ! objcopy --weaken-symbol="$_lw156_s" "$_PABI_LINK_O"; then
              echo "g05_relink_env: weaken $_lw156_s in $_PABI_LINK_O failed (Linux w156 guard)" >&2
              exit 1
            fi
          fi
          ;;
      esac
      _G05_LINK_WINNERS="$_G05_LINK_WINNERS $_lw156_s=$_lw156_o"
    fi
    ;;
esac
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
# live function. Darwin ld has no multidef. pabi_weak.o already holds a
# weak external of this name, and that symbol is not the __text atom at
# offset 0, so the strong sidecar wins. The egg runtime_pipeline_abi.o
# stays untouched. Windows GNU ld is first-wins, so the forwarder alone
# is enough there.
# w2060: the on-disk lea_cold_fwd.o is a leftover (frame 0x890). Rebuild
# the tip thin every Darwin relink. That thin only calls the live
# resolver and does not divide. A missing object exits 1. No new weaken.
# Linux does not link this object. Windows rebuilds it in its own block.
# The if below still needs pabi_weak.o; without that copy the egg stays.
# PLATFORM: MACOS|DARWIN.
if [ "$UNAME_S" = "Darwin" ]; then
  _g05_pure_overlay src/runtime_pipeline_abi_modlet_lea_cold_fwd_thin.x \
    build_asm/selfhost_pabi/lea_cold_fwd.o \
    pipe_modlet_lea_named_binding_addr_to_rax_cold
  if [ ! -s build_asm/selfhost_pabi/lea_cold_fwd.o ]; then
    echo "g05_relink_env: ERROR Darwin lea_cold_fwd .x did not build" >&2
    exit 1
  fi
fi
# w2060: STRUCT_LIT baker. The on-disk bake_struct.o is a leftover
# (frame 0xe50). Rebuild the tip thin every Darwin relink. That thin
# does not divide. pabi_weak.o does not define
# pipe_modlet_bake_struct_lit_to_data, so this strong sidecar is the
# only copy on the Darwin pabi_weak link. No new weaken. The egg keeps
# its own strong T and is not the link object once pabi_weak.o is
# selected. A missing object exits 1. Linux does not rebuild this thin.
# Windows rebuilds it in its own block. The if below still prepends
# the object only when pabi_weak.o exists.
# PLATFORM: MACOS|DARWIN.
if [ "$UNAME_S" = "Darwin" ]; then
  _g05_pure_overlay src/runtime_pipeline_abi_modlet_bake_struct_thin.x \
    build_asm/selfhost_pabi/bake_struct.o \
    pipe_modlet_bake_struct_lit_to_data
  if [ ! -s build_asm/selfhost_pabi/bake_struct.o ]; then
    echo "g05_relink_env: ERROR Darwin bake_struct .x did not build" >&2
    exit 1
  fi
fi
# w2060: mixed-width integer ADD and SUB, plus the f32 promote.
# Linux already rebuilds this thin. Darwin pabi_weak.o keeps weak
# copies of the four exports, and none of them is the __text atom.
# Rebuild the tip thin every Darwin relink with the same pure overlay
# Linux uses (no PREFER). The thin does not divide. Helper names
# pipeline_w1591_*, pipeline_w1594_*, and pipeline_w1597_* are absent
# from pabi_weak.o. w1598_add_stored_in_u32 stays undefined here and is
# defined by the existing binop_wide overlay. A missing object exits 1.
# No new weaken. Windows rebuilds this thin in its own case. The if
# below still prepends the object only when pabi_weak.o exists.
# PLATFORM: MACOS|DARWIN.
if [ "$UNAME_S" = "Darwin" ]; then
  _g05_pure_overlay src/runtime_pipeline_abi_widen_mixed_thin.x \
    build_asm/selfhost_pabi/runtime_pipeline_abi_widen_mixed_thin.o \
    glue_emit_binop_sub_rbx_minus_rax_elf_c
  if [ ! -s build_asm/selfhost_pabi/runtime_pipeline_abi_widen_mixed_thin.o ]; then
    echo "g05_relink_env: ERROR Darwin widen_mixed .x did not build" >&2
    exit 1
  fi
fi
# w2060: wide STRUCT_LIT / FIELD / VAR store. pabi_weak's
# _glue_store_retval_pair_to_rbp_elf_c is weak and is not the __text
# atom. Its sz>16 gate copies kinds 45, 47, 48, and 49. A kind below
# 45, including FIELD 44 and VAR 3, branches into
# glue_load_var_as_value_to_rax_rdx_elf_c. The tip thin copies 48, 49,
# 47, 45, 44, and 3. Rebuild that thin every Darwin relink with no
# PREFER. A missing object, an xlang_panic_ reference, or a missing
# copy/kind undef stops the relink. Linux and Windows already link this
# file. Do not use g05_darwin_pabi_thin_sidecar: that helper sets
# XLANG_PREFER_ASM_O. The if below still prepends the object only when
# pabi_weak.o exists. PLATFORM: MACOS|DARWIN.
if [ "$UNAME_S" = "Darwin" ]; then
  unset XLANG_PREFER_ASM_O
  _g05_pure_overlay src/runtime_pipeline_abi_store_retval_pair_thin.x \
    build_asm/selfhost_pabi/store_retval_pair_a64.o \
    glue_store_retval_pair_to_rbp_elf_c
  _dstore_o=build_asm/selfhost_pabi/store_retval_pair_a64.o
  if [ ! -s "$_dstore_o" ]; then
    echo "g05_relink_env: ERROR Darwin store_retval_pair .x did not build" >&2
    exit 1
  fi
  if nm "$_dstore_o" 2>/dev/null | awk '{s=$NF; sub(/^_/,"",s); if (s=="xlang_panic_") e=1} END{exit e?0:1}'; then
    echo "g05_relink_env: ERROR Darwin store_retval_pair references xlang_panic_" >&2
    exit 1
  fi
  for _dstore_need in glue_copy_large_struct_from_rax_ptr_elf_c pipeline_expr_kind_ord_at; do
    if ! nm -u "$_dstore_o" 2>/dev/null | awk -v n="$_dstore_need" '{s=$NF; sub(/^_/,"",s); if (s==n) f=1} END{exit f?0:1}'; then
      echo "g05_relink_env: ERROR Darwin store_retval_pair lacks undef $_dstore_need" >&2
      exit 1
    fi
  done
fi
# w2060: module-level INDEX base. Darwin's
# glue_try_index_var_or_field_base_to_rbx_elf_c is eight bytes: mov w0,
# #-2; ret. It is not the __text atom. Callers enter the stubdead
# branch, and that branch's reloc names this symbol. Linux already
# links the tip thin as base.o and aliases the egg body as
# glue_try_index_var_or_field_base_to_rbx_elf_rest. Rebuild the same
# thin every Darwin relink with no PREFER. Require the strong export,
# an undefined _rest, and an undefined modlet load. Reject
# xlang_panic_. A missing object exits 1. The egg file is not edited.
# Windows keeps its egg entry. PLATFORM: MACOS|DARWIN.
if [ "$UNAME_S" = "Darwin" ]; then
  unset XLANG_PREFER_ASM_O
  _g05_pure_overlay src/runtime_pipeline_abi_index_base_rbx_thin.x \
    build_asm/selfhost_pabi/index_base_rbx_a64.o \
    glue_try_index_var_or_field_base_to_rbx_elf_c
  _idx_o=build_asm/selfhost_pabi/index_base_rbx_a64.o
  if [ ! -s "$_idx_o" ]; then
    echo "g05_relink_env: ERROR Darwin index base .x did not build" >&2
    exit 1
  fi
  if ! nm "$_idx_o" 2>/dev/null | grep -q ' T _glue_try_index_var_or_field_base_to_rbx_elf_c$'; then
    echo "g05_relink_env: ERROR Darwin index base lacks strong export" >&2
    exit 1
  fi
  for _idx_need in glue_try_index_var_or_field_base_to_rbx_elf_rest pipeline_asm_modlet_load_to_rax_elf_c backend_enc_mov_rax_to_rbx_arch; do
    if ! nm -u "$_idx_o" 2>/dev/null | awk -v n="$_idx_need" '{s=$NF; sub(/^_/,"",s); if (s==n) f=1} END{exit f?0:1}'; then
      echo "g05_relink_env: ERROR Darwin index base lacks undef $_idx_need" >&2
      exit 1
    fi
  done
  if nm "$_idx_o" 2>/dev/null | awk '{s=$NF; sub(/^_/,"",s); if (s=="xlang_panic_") e=1} END{exit e?0:1}'; then
    echo "g05_relink_env: ERROR Darwin index base references xlang_panic_" >&2
    exit 1
  fi
fi
# w2060: call-arg packer. Darwin pabi_weak keeps a strong
# _pipeline_asm_emit_expr_elf_for_call_args at a non-zero offset. That
# symbol is not the __text atom (_pabi_weak_text_base). The measured
# egg body is 1708 bytes; the tip thin is the wave216 packer, including
# fixed-array FIELD arguments decaying to the element address. Two BR26
# sites in _glue_enc_local_slot_ptr_or_addr_elf_c and the two stubdead
# branches name this symbol. Rebuild the thin on every Darwin relink.
# XLANG_PREFER_ASM_O=1 makes the body's (n + 7) / 8 alignment a real
# divide: the linked product skips its divisor panic emit when that
# variable is 1. Reject an xlang_panic_ reference. Weaken every other
# strong T so first-wins cannot pick up a second global. Do not inject
# this object into runtime_pipeline_abi.o, and do not call
# g05_darwin_pabi_thin_sidecar. Linux keeps its mtime one.o rebuild.
# Windows rebuilds this thin in its own case. The link block below
# weakens the egg copy and prepends this object when pabi_weak.o exists.
# PLATFORM: MACOS|DARWIN.
if [ "$UNAME_S" = "Darwin" ]; then
  _dfca_x=src/runtime_pipeline_abi_for_call_args_thin.x
  _dfca_o=build_asm/selfhost_pabi/for_call_args_a64.o
  _dfca_s=_pipeline_asm_emit_expr_elf_for_call_args
  if [ ! -f "$_dfca_x" ] || [ ! -x ./xlang_asm ]; then
    echo "g05_relink_env: $_dfca_x or ./xlang_asm missing (Darwin call-arg packer)" >&2
    exit 1
  fi
  mkdir -p build_asm/selfhost_pabi
  rm -f "$_dfca_o" "$_dfca_o.tmp.o"
  if ! XLANG_PREFER_ASM_O=1 ./xlang_asm -backend asm -c "$_dfca_x" -o "$_dfca_o.tmp.o" >/dev/null 2>&1; then
    rm -f "$_dfca_o.tmp.o"
    echo "g05_relink_env: $_dfca_x failed (Darwin call-arg packer)" >&2
    exit 1
  fi
  _dfca_oc=""
  if command -v llvm-objcopy >/dev/null 2>&1; then
    _dfca_oc=llvm-objcopy
  elif [ -x /opt/homebrew/opt/llvm/bin/llvm-objcopy ]; then
    _dfca_oc=/opt/homebrew/opt/llvm/bin/llvm-objcopy
  elif [ -x /usr/local/opt/llvm/bin/llvm-objcopy ]; then
    _dfca_oc=/usr/local/opt/llvm/bin/llvm-objcopy
  elif command -v objcopy >/dev/null 2>&1; then
    _dfca_oc=objcopy
  fi
  for _dfca_g in $(nm "$_dfca_o.tmp.o" 2>/dev/null | awk '$2=="T"{print $3}'); do
    [ "$_dfca_g" = "$_dfca_s" ] && continue
    if [ -z "$_dfca_oc" ] || ! "$_dfca_oc" --weaken-symbol="$_dfca_g" "$_dfca_o.tmp.o"; then
      rm -f "$_dfca_o.tmp.o"
      echo "g05_relink_env: weaken $_dfca_g in $_dfca_x failed (Darwin call-arg packer)" >&2
      exit 1
    fi
  done
  if ! nm "$_dfca_o.tmp.o" 2>/dev/null | grep -q " T ${_dfca_s}\$"; then
    rm -f "$_dfca_o.tmp.o"
    echo "g05_relink_env: $_dfca_x lacks strong $_dfca_s (Darwin call-arg packer)" >&2
    exit 1
  fi
  if nm "$_dfca_o.tmp.o" 2>/dev/null | awk '{s=$NF; sub(/^_/,"",s); if (s=="xlang_panic_") e=1} END{exit e?0:1}'; then
    rm -f "$_dfca_o.tmp.o"
    echo "g05_relink_env: ERROR Darwin call-arg packer references xlang_panic_" >&2
    exit 1
  fi
  mv -f "$_dfca_o.tmp.o" "$_dfca_o"
fi
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
  # STRUCT_LIT elements. The array baker calls this object. The
  # Darwin rebuild above already exited 1 when the tip thin did not
  # produce it. Ubuntu's modlet.o bakes struct fields, so Linux does
  # not rebuild this thin.
  # PLATFORM: MACOS|DARWIN.
  if [ -s build_asm/selfhost_pabi/bake_struct.o ]; then
    _PABI_SELFHOST="build_asm/selfhost_pabi/bake_struct.o $_PABI_SELFHOST"
  fi
  # w2060: mixed-width ADD/SUB and f32 promote. The four exports are
  # already weak in pabi_weak.o. The Darwin rebuild above exits 1 when
  # the tip thin did not produce this object. Linux rebuilds the same
  # path in its own block. Windows rebuilds this thin in its own case.
  # PLATFORM: MACOS|DARWIN.
  if [ -s build_asm/selfhost_pabi/runtime_pipeline_abi_widen_mixed_thin.o ]; then
    _PABI_SELFHOST="build_asm/selfhost_pabi/runtime_pipeline_abi_widen_mixed_thin.o $_PABI_SELFHOST"
  fi
  # w2060: wide store pair. The rebuild above already exited 1 when the
  # tip thin did not produce this object. Weaken a strong pabi_weak
  # copy. The measured copy is already weak and is not the __text atom,
  # so that weaken waits. The private
  # _pipeline_w2060_store_pair_cell_i32 is this object's text atom and
  # is absent from pabi_weak; leave it strong. PLATFORM: MACOS|DARWIN.
  if [ -s build_asm/selfhost_pabi/store_retval_pair_a64.o ]; then
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
    if nm -m build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null \
        | grep 'external.* _glue_store_retval_pair_to_rbp_elf_c$' | grep -qv weak; then
      if [ -z "$_oc" ] || ! "$_oc" --weaken-symbol=_glue_store_retval_pair_to_rbp_elf_c \
          build_asm/selfhost_pabi/pabi_weak.o; then
        echo "g05_relink_env: weaken pabi_weak _glue_store_retval_pair_to_rbp_elf_c failed (Darwin store pair)" >&2
        exit 1
      fi
    fi
    _G05_LINK_WINNERS="$_G05_LINK_WINNERS _glue_store_retval_pair_to_rbp_elf_c=build_asm/selfhost_pabi/store_retval_pair_a64.o"
    _PABI_SELFHOST="build_asm/selfhost_pabi/store_retval_pair_a64.o $_PABI_SELFHOST"
  fi
  # w2060: module-level INDEX base. The rebuild above already exited 1
  # when the tip thin did not produce this object. The measured egg
  # entry is eight bytes (mov w0, #-2; ret). Mach-O llvm-objcopy cannot
  # --add-symbol, so assemble that measured entry under the _rest name
  # the thin calls for locals, fields, and every non-module base. Stop
  # if the egg span is not 8 or the two instructions differ. Weaken the
  # egg name so this thin first-wins. The stubdead reloc names that
  # symbol and follows the strong definition. The egg file is not
  # edited. PLATFORM: MACOS|DARWIN.
  if [ -s build_asm/selfhost_pabi/index_base_rbx_a64.o ]; then
    _idx_o=build_asm/selfhost_pabi/index_base_rbx_a64.o
    _idx_pw=build_asm/selfhost_pabi/pabi_weak.o
    _idx_rest_s=build_asm/selfhost_pabi/index_base_rbx_rest_a64.s
    _idx_rest_o=build_asm/selfhost_pabi/index_base_rbx_rest_a64.o
    if ! python3 - "$_idx_pw" <<'PY'
import subprocess, sys
path = sys.argv[1]
sym = "_glue_try_index_var_or_field_base_to_rbx_elf_c"
nm = subprocess.check_output(["nm", path], text=True, errors="replace")
addrs = []
hit = None
for line in nm.splitlines():
    parts = line.split()
    if len(parts) < 3:
        continue
    try:
        addr = int(parts[0], 16)
    except ValueError:
        continue
    addrs.append(addr)
    if parts[-1] == sym:
        hit = addr
if hit is None:
    sys.stderr.write("g05_relink_env: Darwin index base symbol missing\n")
    sys.exit(1)
nxt = next(a for a in sorted(set(addrs)) if a > hit)
if nxt - hit != 8:
    sys.stderr.write("g05_relink_env: Darwin index base span is not 8\n")
    sys.exit(1)
dump = subprocess.check_output(
    ["objdump", "-d", "--start-address=0x%x" % hit, "--stop-address=0x%x" % nxt, path],
    text=True, errors="replace")
if "12800020" not in dump or "d65f03c0" not in dump:
    sys.stderr.write("g05_relink_env: Darwin index base entry is not mov w0, #-2; ret\n")
    sys.exit(1)
PY
    then
      echo "g05_relink_env: Darwin index base egg entry check failed" >&2
      exit 1
    fi
    cat > "$_idx_rest_s" <<'EOF'
.globl _glue_try_index_var_or_field_base_to_rbx_elf_rest
.p2align 2
_glue_try_index_var_or_field_base_to_rbx_elf_rest:
    mov w0, #-2
    ret
EOF
    if ! as -arch arm64 -o "$_idx_rest_o" "$_idx_rest_s"; then
      echo "g05_relink_env: Darwin index base _rest assemble failed" >&2
      exit 1
    fi
    if ! nm "$_idx_rest_o" 2>/dev/null | grep -q '_glue_try_index_var_or_field_base_to_rbx_elf_rest$'; then
      echo "g05_relink_env: Darwin index base _rest symbol missing" >&2
      exit 1
    fi
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
    if nm -m "$_idx_pw" 2>/dev/null \
        | grep 'external.* _glue_try_index_var_or_field_base_to_rbx_elf_c$' | grep -qv weak; then
      if [ -z "$_oc" ] || ! "$_oc" --weaken-symbol=_glue_try_index_var_or_field_base_to_rbx_elf_c \
          "$_idx_pw"; then
        echo "g05_relink_env: weaken pabi_weak _glue_try_index_var_or_field_base_to_rbx_elf_c failed (Darwin index base)" >&2
        exit 1
      fi
    fi
    _G05_LINK_WINNERS="$_G05_LINK_WINNERS _glue_try_index_var_or_field_base_to_rbx_elf_c=$_idx_o"
    _PABI_SELFHOST="$_idx_o $_idx_rest_o $_PABI_SELFHOST"
  fi
  # w2060: call-arg packer. The rebuild above already exited 1 when the
  # tip thin did not produce this object. The egg symbol is strong and
  # is not the __text atom, so weaken that copy and link the thin first.
  # Mach-O BR26 sites follow the strong definition. The egg file is not
  # edited. PLATFORM: MACOS|DARWIN.
  if [ -s build_asm/selfhost_pabi/for_call_args_a64.o ]; then
    _dfca_o=build_asm/selfhost_pabi/for_call_args_a64.o
    _dfca_s=_pipeline_asm_emit_expr_elf_for_call_args
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
    if nm -m build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null \
        | grep "external.* ${_dfca_s}\$" | grep -qv weak; then
      if [ -z "$_oc" ] || ! "$_oc" --weaken-symbol="${_dfca_s}" \
          build_asm/selfhost_pabi/pabi_weak.o; then
        echo "g05_relink_env: weaken pabi_weak ${_dfca_s} failed (Darwin call-arg packer)" >&2
        exit 1
      fi
    fi
    _G05_LINK_WINNERS="$_G05_LINK_WINNERS ${_dfca_s}=${_dfca_o}"
    _PABI_SELFHOST="${_dfca_o} $_PABI_SELFHOST"
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
  # Rebuilt on every relink (w2060; was: missing or older than the thin .x).
  # PLATFORM: MACOS|DARWIN.
  _pps_x=src/runtime_pipeline_abi_param_ptr_slot_thin.x
  _pps_o=build_asm/selfhost_pabi/param_ptr_slot_a64.o
  if [ -f "$_pps_x" ] && [ -x ./xlang_asm ]; then
    # w2060: always rebuild with the current product (see cimp below).
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
          "$_oc" --weaken-symbol="$_psym" build_asm/selfhost_pabi/pabi_weak.o || { echo "g05_relink_env: ERROR objcopy failed at line 1218" >&2; exit 1; }
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
            "$_oc" --weaken-symbol="$_psym" "$_pw.tmp.o" || { echo "g05_relink_env: ERROR objcopy failed at line 1237" >&2; exit 1; }
          done
          mv -f "$_pw.tmp.o" "$_pw"
        fi
        rm -f "$_pw.tmp.o"
      fi
    fi
    _PABI_SELFHOST="$_pps_o $_PABI_SELFHOST"
  fi
  # w2055 (Darwin twin of the Linux cimp.o): collect-deps import scan.
  # pabi_weak keeps an old C xlang_module_collect_imports_from_buf that calls
  # the struct-returning lexer_init(); since e5ba88d9d lexer_init(out: *Lexer)
  # writes through x0, so the scan sees num_imports 1 with an empty path
  # (IMP001 ./.x). Compile the thin with the current product, weaken the pabi
  # copy, and let the thin win. A failed compile stops the relink.
  # PLATFORM: MACOS|DARWIN.
  _cimp_x=src/runtime_pipeline_abi_collect_imports_thin.x
  _cimp_o=build_asm/selfhost_pabi/cimp_a64.o
  if [ "$UNAME_S" = "Darwin" ] && [ -f "$_cimp_x" ] && [ -x ./xlang_asm ] \
    && [ -s build_asm/selfhost_pabi/pabi_weak.o ]; then
    # w2060: always rebuild (as on Windows). An mtime test kept objects
    # compiled by an earlier product whenever ./xlang_asm was restored with
    # an older mtime (cp -p), so a broken product's sidecars reached the link.
      rm -f "$_cimp_o"
      if XLANG_PREFER_ASM_O=1 ./xlang_asm -backend asm -c "$_cimp_x" -o "$_cimp_o.tmp.o" >/dev/null 2>&1 \
        && nm -m "$_cimp_o.tmp.o" 2>/dev/null | grep -v weak \
          | grep -q 'external _xlang_module_collect_imports_from_buf$' \
        && ! nm -u "$_cimp_o.tmp.o" 2>/dev/null | grep -qx '_lexer_init'; then
        mv -f "$_cimp_o.tmp.o" "$_cimp_o"
      else
        rm -f "$_cimp_o.tmp.o"
        echo "g05_relink_env: $_cimp_x failed (Darwin cimp)" >&2
        exit 1
      fi
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
        | grep 'external.* _xlang_module_collect_imports_from_buf$' | grep -qv weak; then
      if ! "$_oc" --weaken-symbol=_xlang_module_collect_imports_from_buf \
          build_asm/selfhost_pabi/pabi_weak.o; then
        echo "g05_relink_env: weaken pabi_weak collect_imports copy failed" >&2
        exit 1
      fi
    fi
    _PABI_SELFHOST="$_cimp_o $_PABI_SELFHOST"
    _G05_LINK_WINNERS="$_G05_LINK_WINNERS _xlang_module_collect_imports_from_buf=$_cimp_o"
  fi
  # w2055: enum namespace FIELD_ACCESS tag and compare RHS enum tag. pabi_weak
  # keeps pre-w1653 C bodies of pipeline_expr_enum_namespace_field_tag and
  # pipeline_asm_cmp_enum_rhs_tag_c with a 32-byte base_buf;
  # pipeline_expr_var_name_into zeros 256 bytes, and the stack guard aborts
  # the compiler on parser.x. Same pattern as cimp: compile the thin with
  # the current product, weaken the pabi copies, link the thin first. A
  # failed compile or weaken stops the relink. PLATFORM: MACOS|DARWIN.
  # g05_darwin_pabi_thin_sidecar THIN_X OUT_O "SYM..." TAG: compile THIN_X
  # with the current product (pure asm), require a strong def of every SYM,
  # weaken the stale pabi_weak copies, link OUT_O first and record each SYM
  # in _G05_LINK_WINNERS for the post-link map check. Any failure stops the
  # relink. PLATFORM: MACOS|DARWIN.
  g05_darwin_pabi_thin_sidecar() {
    _ts_x="$1"; _ts_o="$2"; _ts_syms="$3"; _ts_tag="$4"
    [ "$UNAME_S" = "Darwin" ] && [ -f "$_ts_x" ] && [ -x ./xlang_asm ] \
      && [ -s build_asm/selfhost_pabi/pabi_weak.o ] || return 0
    # w2060: always rebuild with the current product (see cimp above).
      rm -f "$_ts_o"
      if ! XLANG_PREFER_ASM_O=1 ./xlang_asm -backend asm -c "$_ts_x" -o "$_ts_o.tmp.o" >/dev/null 2>&1; then
        rm -f "$_ts_o.tmp.o"
        echo "g05_relink_env: $_ts_x failed (Darwin $_ts_tag)" >&2
        exit 1
      fi
      for _ts_s in $_ts_syms; do
        if ! nm -m "$_ts_o.tmp.o" 2>/dev/null | grep -v weak | grep -q "external $_ts_s\$"; then
          rm -f "$_ts_o.tmp.o"
          echo "g05_relink_env: $_ts_x lacks strong $_ts_s (Darwin $_ts_tag)" >&2
          exit 1
        fi
      done
      mv -f "$_ts_o.tmp.o" "$_ts_o"
    for _ts_s in $_ts_syms; do
      if nm -m build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null \
          | grep "external.* $_ts_s\$" | grep -qv weak; then
        if [ -z "$_oc" ] || ! "$_oc" --weaken-symbol="$_ts_s" build_asm/selfhost_pabi/pabi_weak.o; then
          echo "g05_relink_env: weaken pabi_weak $_ts_s copy failed (Darwin $_ts_tag)" >&2
          exit 1
        fi
      fi
      _G05_LINK_WINNERS="$_G05_LINK_WINNERS $_ts_s=$_ts_o"
    done
    _PABI_SELFHOST="$_ts_o $_PABI_SELFHOST"
  }
  g05_darwin_pabi_thin_sidecar src/runtime_pipeline_abi_enum_ns_tag_thin.x \
    build_asm/selfhost_pabi/enum_ns_tag_a64.o \
    "_pipeline_expr_enum_namespace_field_tag _pipeline_asm_cmp_enum_rhs_tag_c" \
    "enum ns tag"
  # w2060: dep prerun parse-skip-typeck (std.io.driver / std.net deps). The
  # Class BR compaction left 8-byte ret0 copies of both names in pabi_weak:
  # the dep slot was never parsed, so importer typeck saw an empty module
  # and failed `driver.f()` with T001 (std/fs/mod.x submit_read_batch).
  # Ubuntu and Windows pabi keep the real bodies of both (checked w2060);
  # only the Darwin Mach-O compaction stubbed them, so only Darwin overlays.
  # PLATFORM: MACOS|DARWIN.
  g05_darwin_pabi_thin_sidecar src/runtime_pipeline_abi_dep_prerun_skip_typeck_thin.x \
    build_asm/selfhost_pabi/dep_prerun_skip_typeck_a64.o \
    "_xlang_pipeline_dep_prerun_parse_skip_typeck _xlang_pipeline_dep_prerun_parse_skip_typeck_impl" \
    "dep prerun skip typeck"
  # w2055: Mach-O writer. pabi_weak keeps the pre-w1814 C writer whose
  # unique-undef cap is 256 with 1024-byte index tables; parser.x has more
  # than 256 unique undefined relocs, so the writer returns -1 (CG002,
  # out_len=0). The thin owns its 2048-slot tables; the cap is the next
  # sidecar.
  g05_darwin_pabi_thin_sidecar src/runtime_pipeline_abi_macho_write_thin.x \
    build_asm/selfhost_pabi/macho_write_a64.o \
    "_pipeline_macho_write_o_to_buf_c _platform_macho_write_macho_o_to_buf" \
    "macho writer"
  # w2055: Mach-O unique-undef cap. pabi_weak keeps a copy of
  # pipe_elf_macho_undef_cap that returns 256; the writer above calls the
  # cap and sizes its tables to 2048. The cap has one definition, in its
  # own thin. PLATFORM: MACOS|DARWIN.
  g05_darwin_pabi_thin_sidecar src/runtime_pipeline_abi_macho_undef_cap_thin.x \
    build_asm/selfhost_pabi/macho_undef_cap_a64.o \
    "_pipe_elf_macho_undef_cap" \
    "macho undef cap"
  # w2055: assignment through a pointer. pabi_weak keeps the pre-wave324
  # pipeline_asm_emit_assign_elf_c: for `*p = s` with a struct s it loads s
  # into x0/x1 and stores only 8 bytes, so the rest of the struct is lost.
  # lexer.x hands Token back through an out pointer (e5ba88d9d), so every
  # lexer built by that body is broken. The thin has the wave324 DEREF path;
  # Linux already injects it into pabi. PLATFORM: MACOS|DARWIN.
  g05_darwin_pabi_thin_sidecar src/runtime_pipeline_abi_assign_thin.x \
    build_asm/selfhost_pabi/assign_a64.o \
    "_pipeline_asm_emit_assign_elf_c" \
    "assign"
  # w2055: INDEX assign-address cache. The assign thin above asks
  # glue_index_assign_addr_cache_hit before an INDEX store; the pabi_weak
  # copy still answers from the wave156 cache, which nothing clears at an
  # if/else join, so the else arm stores through a stale x1 (call_spill
  # thin, EXC_BAD_ACCESS). The guard thin always misses. Linux rebuilds
  # w156_guard.o in the Linux self-host block. PLATFORM: MACOS|DARWIN.
  g05_darwin_pabi_thin_sidecar src/runtime_pipeline_abi_w156_guard_thin.x \
    build_asm/selfhost_pabi/w156_guard_a64.o \
    "_glue_index_assign_addr_cache_hit" \
    "w156 guard"
  # w2060 A1: struct let-init winner only. The assign thin hands
  # `*p = <struct expr>` to glue_emit_struct_type_let_init_elf_c with the
  # destination in a register (-3); the pabi_weak copy returns -2 for a
  # struct literal/call/field/index/deref rhs and the caller stores only
  # 8 bytes. Thin defines let_init only; fields/lit/struct_let_init stay
  # as extern → pabi leftover (bodies archived for w2061 if sret remains).
  # PLATFORM: MACOS|DARWIN.
  g05_darwin_pabi_thin_sidecar src/runtime_pipeline_abi_struct_let_init_thin.x \
    build_asm/selfhost_pabi/struct_let_init_a64.o \
    "_glue_emit_struct_type_let_init_elf_c" \
    "struct let init"
  # w2060: AAPCS64 >16B param home. Leftover copies from the stack (SysV
  # MEMORY); tip callers pass a GP pointer. Thin homes byref. PLATFORM: MACOS|DARWIN.
  g05_darwin_pabi_thin_sidecar src/runtime_pipeline_abi_arm64_param_home_thin.x \
    build_asm/selfhost_pabi/arm64_param_home_a64.o \
    "_pipeline_asm_emit_param_home_elf_c" \
    "arm64 param home"
  # w2060: struct-lit field CALL/wide copy. Leftover win_emit truncates to 8B.
  # Pure-asm thin via tip product (g05_darwin_pabi_thin_sidecar). PLATFORM: MACOS|DARWIN.
  g05_darwin_pabi_thin_sidecar src/runtime_pipeline_abi_struct_lit_fields_thin.x \
    build_asm/selfhost_pabi/struct_lit_fields_a64.o \
    "_win_emit_struct_lit_fields_into_parked_rbx" \
    "struct lit fields" 
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
          "$_oc" --weaken-symbol="$_bsym" build_asm/selfhost_pabi/pabi_weak.o || { echo "g05_relink_env: ERROR objcopy failed at line 1416" >&2; exit 1; }
        fi
      done
    fi
    _PABI_SELFHOST="build_asm/selfhost_pabi/body_sync_let_order.o $_PABI_SELFHOST"
  fi
  # w2060: empty [] fixed T[N] zero-fill. Strong thin; weaken egg copy.
  # PLATFORM: MACOS|DARWIN.
  if [ -s build_asm/selfhost_pabi/emit_let_init.o ]; then
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
          | grep -F "_glue_block_body_emit_let_init" | grep -qv weak; then
        "$_oc" --weaken-symbol=_glue_block_body_emit_let_init \
          build_asm/selfhost_pabi/pabi_weak.o || {
          echo "g05_relink_env: ERROR weaken emit_let_init failed" >&2
          exit 1
        }
      fi
    fi
    _G05_LINK_WINNERS="$_G05_LINK_WINNERS _glue_block_body_emit_let_init=build_asm/selfhost_pabi/emit_let_init.o"
    _PABI_SELFHOST="build_asm/selfhost_pabi/emit_let_init.o $_PABI_SELFHOST"
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
          "$_oc" --weaken-symbol="$_isym" build_asm/selfhost_pabi/pabi_weak.o || { echo "g05_relink_env: ERROR objcopy failed at line 1441" >&2; exit 1; }
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
          "$_oc" --weaken-symbol="$_asym" build_asm/selfhost_pabi/pabi_weak.o || { echo "g05_relink_env: ERROR objcopy failed at line 1473" >&2; exit 1; }
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
        "$_oc" --weaken-symbol=_glue_emit_assign_field_elf_c build_asm/selfhost_pabi/pabi_weak.o || { echo "g05_relink_env: ERROR objcopy failed at line 1503" >&2; exit 1; }
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
          "$_oc" --weaken-symbol="$_fsym" build_asm/selfhost_pabi/pabi_weak.o || { echo "g05_relink_env: ERROR objcopy failed at line 1524" >&2; exit 1; }
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
  # w1572: egg undef cap is a strong T on some Darwin copies. Apple ld
  # has no multidef, so weaken the pabi_weak copy. The original egg stays.
  # PLATFORM: MACOS|DARWIN.
  if [ -n "$_PABI_ELF_UNDEF_CAP" ] && [ -s build_asm/selfhost_pabi/pabi_weak.o ]; then
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
      for _csym in pipe_elf_undef_cap pipe_elf_ws_undef_name_row \
          pipe_elf_ws_undef_len_at pipe_elf_ws_undef_len_set; do
        if nm -m build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null \
          | grep -E " _${_csym}$" | grep -v undefined | grep -qv weak; then
          "$_oc" --weaken-symbol="_${_csym}" \
            build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
      done
    fi
  fi
  # w1576: Apple ld has no multidef. Weaken a strong glue_type_size_simple
  # on the pabi_weak copy so the named-size overlay wins. The egg file stays.
  # PLATFORM: MACOS|DARWIN.
  if [ -n "$_PABI_NAMED_SIZE" ] && [ -s build_asm/selfhost_pabi/pabi_weak.o ]; then
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
      if nm -m build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null \
        | grep -E " _glue_type_size_simple$" | grep -v undefined | grep -qv weak; then
        "$_oc" --weaken-symbol=_glue_type_size_simple \
          build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
      fi
    fi
  fi
  # w1584: Apple ld has no multidef. Weaken a strong slice-reent sum on
  # the pabi_weak copy so the overlay wins. The egg file stays.
  # PLATFORM: MACOS|DARWIN.
  if [ -n "$_PABI_REENT_SUM" ] && [ -s build_asm/selfhost_pabi/pabi_weak.o ]; then
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
      if nm -m build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null \
        | grep -E " _glue_sum_block_slice_reent_dc_bytes_c$" \
        | grep -v undefined | grep -qv weak; then
        "$_oc" --weaken-symbol=_glue_sum_block_slice_reent_dc_bytes_c \
          build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
      fi
    fi
  fi
  _PABI_LINK_O="build_asm/selfhost_pabi/pabi_weak.o"
fi
# PLATFORM: WINDOWS | MSYS | MINGW.
# elem_const.o is the folder. The egg global is U, and a local _cold
# remains. The tip thin divides integers, so it is not a g05 input.
# The cold lea is rebuilt below.
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
    # w2060: cold lea forwarder. The egg's only copy is the local
    # pipe_modlet_lea_named_binding_addr_to_rax_cold, and that body calls
    # pipeline_asm_modlet_find_cold. One same-TU call lands on that entry.
    # There is no global of this name to weaken. Rebuild the tip thin
    # every relink (one strong T that calls the live resolver). A missing
    # object exits 1. win_patch_body_sync_jmp folds the local t onto this
    # T. Linux does not link this object. Darwin rebuilds the same thin
    # before its pabi_weak link. PLATFORM: WINDOWS | MSYS | MINGW.
    _g05_pure_overlay src/runtime_pipeline_abi_modlet_lea_cold_fwd_thin.x \
      build_asm/selfhost_pabi/lea_cold_fwd.o \
      pipe_modlet_lea_named_binding_addr_to_rax_cold
    if [ ! -s build_asm/selfhost_pabi/lea_cold_fwd.o ]; then
      echo "g05_relink_env: ERROR Windows lea_cold_fwd .x did not build" >&2
      exit 1
    fi
    _PABI_SELFHOST="build_asm/selfhost_pabi/lea_cold_fwd.o $_PABI_SELFHOST"
    # w2060: STRUCT_LIT baker. The egg has U
    # pipe_modlet_bake_struct_lit_to_data and a local _cold copy, so the
    # strong T has to come from this object. The on-disk bake_struct.o was
    # a leftover. Rebuild it from the tip thin every relink. One strong T.
    # A missing object exits 1. Linux does not rebuild this thin. Darwin
    # rebuilds the same thin before its pabi_weak link.
    # PLATFORM: WINDOWS | MSYS | MINGW.
    _g05_pure_overlay src/runtime_pipeline_abi_modlet_bake_struct_thin.x \
      build_asm/selfhost_pabi/bake_struct.o pipe_modlet_bake_struct_lit_to_data
    if [ ! -s build_asm/selfhost_pabi/bake_struct.o ]; then
      echo "g05_relink_env: ERROR Windows bake_struct .x did not build" >&2
      exit 1
    fi
    # STRUCT_LIT elements. The egg baker calls this object.
    # w1020: one function in bake_elems_thin.x is smash frame 0xb40.
    # w2060: one strong T from src/pabi_bake_elems_one.x. File-local
    # helpers stay in that object. They are not a second link winner.
    # Do not PREFER the thin. Do not gcc seeds/win_bake_elems_override.c
    # here. Linux still compiles that C. Darwin still builds the thin.
    # A missing object exits 1. Default ON; set XLANG_WIN_BAKE_TIP=0
    # for Cap residual. INDEX tip is three .x objects, not -D gcc.
    # PLATFORM: WINDOWS.
    _WIN_TRUE_PACK=0
    if [ "${XLANG_WIN_BAKE_TIP:-}" != "0" ]; then
      mkdir -p build_asm/selfhost_pabi
      # w2060: one strong T from src/pabi_bake_elems_one.x.
      # The egg keeps a different body. The thin stays off.
      # Linux still compiles the C seed. A missing object exits 1.
      # PLATFORM: WINDOWS | MSYS | MINGW.
      _g05_pure_overlay src/pabi_bake_elems_one.x \
        build_asm/selfhost_pabi/bake_elems.o \
        pipe_modlet_bake_array_lit_elems_to_data
      if [ ! -s build_asm/selfhost_pabi/bake_elems.o ]; then
        echo "g05_relink_env: ERROR Windows bake_elems .x did not build" >&2
        exit 1
      fi
      # w2060: three strong T, three objects. Same-.o dual T smashes i32.
      # pipeline_asm_index_elem_byte_sz_c calls
      # glue_index_elem_byte_sz_from_type_ref_c as an extern. The short
      # wrapper is a third object. True-pack widths (named i8=1, i16=2,
      # u16=2) live in the .x. The egg glue body has no those parks.
      # Do not fold into runtime_pipeline_abi.x. Do not gcc
      # -DXLANG_WIN_TRUE_PACK seeds/win_index_elem_byte_sz_override.c
      # here. Linux sidecar still gcc's that C. The non-D Cap residual
      # object stays out of this link. A missing object exits 1.
      # PLATFORM: WINDOWS | MSYS | MINGW.
      _g05_pure_overlay src/pabi_index_elem_from_type_one.x \
        build_asm/selfhost_pabi/index_elem_from_type.o \
        glue_index_elem_byte_sz_from_type_ref_c
      if [ ! -s build_asm/selfhost_pabi/index_elem_from_type.o ]; then
        echo "g05_relink_env: ERROR Windows index_elem from_type .x did not build" >&2
        exit 1
      fi
      _g05_pure_overlay src/pabi_index_elem_byte_sz_one.x \
        build_asm/selfhost_pabi/index_elem_true_i8.o \
        pipeline_asm_index_elem_byte_sz_c
      if [ ! -s build_asm/selfhost_pabi/index_elem_true_i8.o ]; then
        echo "g05_relink_env: ERROR Windows index_elem .x did not build" >&2
        exit 1
      fi
      _g05_pure_overlay src/pabi_index_elem_wrap_one.x \
        build_asm/selfhost_pabi/index_elem_wrap.o \
        pipeline_asm_index_elem_byte_sz
      if [ ! -s build_asm/selfhost_pabi/index_elem_wrap.o ]; then
        echo "g05_relink_env: ERROR Windows index_elem wrap .x did not build" >&2
        exit 1
      fi
      # w2060: one strong T from src/pabi_force_esz_one.x.
      # fnptr_array_esz_thin.x stays off (HARD BAN PREFER, same-.o dual T).
      # Do not gcc -DXLANG_WIN_FORCE_ESZ_ONLY. A missing object exits 1.
      # PLATFORM: WINDOWS | MSYS | MINGW.
      _g05_pure_overlay src/pabi_force_esz_one.x \
        build_asm/selfhost_pabi/force_esz_true_i8.o \
        glue_array_lit_force_esz_from_elem_type_c
      if [ ! -s build_asm/selfhost_pabi/force_esz_true_i8.o ]; then
        echo "g05_relink_env: ERROR Windows force_esz .x did not build" >&2
        exit 1
      fi
      # w2060: one strong T from src/pabi_elem_byte_sz_one.x.
      # fnptr_array_esz_thin.x stays off (HARD BAN PREFER, same-.o dual T).
      # Do not gcc -DXLANG_WIN_ELEM_BYTE_SZ_ONLY. Do not put this symbol
      # in force_esz_true_i8.o. A missing object exits 1.
      # PLATFORM: WINDOWS | MSYS | MINGW.
      _g05_pure_overlay src/pabi_elem_byte_sz_one.x \
        build_asm/selfhost_pabi/array_lit_esz_true_i8.o \
        pipeline_asm_array_lit_elem_byte_sz_c
      if [ ! -s build_asm/selfhost_pabi/array_lit_esz_true_i8.o ]; then
        echo "g05_relink_env: ERROR Windows elem_byte_sz .x did not build" >&2
        exit 1
      fi
      # w2060: two strong T, two objects. Same-.o dual T smashes i32.
      # emit_index_thin.x stays off (HARD BAN PREFER).
      # Do not gcc seeds/emit_index_true_i8_override.c here.
      # A missing object exits 1.
      # PLATFORM: WINDOWS | MSYS | MINGW.
      _g05_pure_overlay src/pabi_emit_index_arms_one.x \
        build_asm/selfhost_pabi/emit_index_arms_true_i8.o \
        glue_emit_index_load_arms_elf_c
      if [ ! -s build_asm/selfhost_pabi/emit_index_arms_true_i8.o ]; then
        echo "g05_relink_env: ERROR Windows emit_index arms .x did not build" >&2
        exit 1
      fi
      _g05_pure_overlay src/pabi_emit_index_elf_one.x \
        build_asm/selfhost_pabi/emit_index_elf_true_i8.o \
        pipeline_asm_emit_index_elf_c
      if [ ! -s build_asm/selfhost_pabi/emit_index_elf_true_i8.o ]; then
        echo "g05_relink_env: ERROR Windows emit_index elf .x did not build" >&2
        exit 1
      fi
      # w2060: one strong T from src/pabi_assign_index_one.x.
      # File-local helpers stay in that one object. They are not a second
      # link winner. assign_index_thin.x stays off (HARD BAN PREFER).
      # Do not gcc seeds/assign_index_true_i8_override.c here.
      # Linux and Darwin still compile that C. A missing object exits 1.
      # PLATFORM: WINDOWS | MSYS | MINGW.
      _g05_pure_overlay src/pabi_assign_index_one.x \
        build_asm/selfhost_pabi/assign_index_true_i8.o \
        glue_emit_assign_index_elf_c
      if [ ! -s build_asm/selfhost_pabi/assign_index_true_i8.o ]; then
        echo "g05_relink_env: ERROR Windows assign_index .x did not build" >&2
        exit 1
      fi
      # w2060: one strong T from src/pabi_fixed_array_total_bytes_one.x.
      # runtime_pipeline_abi.x keeps a different body (named types always
      # go through glue_type_size_simple). Do not gcc
      # seeds/fixed_array_total_bytes_true_pack_override.c here.
      # Linux and Darwin still compile that C. A missing object exits 1.
      # PLATFORM: WINDOWS | MSYS | MINGW.
      _g05_pure_overlay src/pabi_fixed_array_total_bytes_one.x \
        build_asm/selfhost_pabi/fixed_array_total_bytes_true_pack.o \
        glue_fixed_array_total_bytes_c
      if [ ! -s build_asm/selfhost_pabi/fixed_array_total_bytes_true_pack.o ]; then
        echo "g05_relink_env: ERROR Windows fixed_array .x did not build" >&2
        exit 1
      fi
      # w1023: nested ARRAY_LIT → array_lit_flat.
      # w2060: short name from src/pabi_vector_let_init_nested_one.x.
      # The mangled name and stubdead each forward from their own object.
      # Same-.o dual T smashes i32. File-local helpers stay with the
      # short name. Do not gcc seeds/vector_let_init_nested_override.c
      # here. Linux and Darwin still compile that C. A missing object
      # exits 1. PLATFORM: WINDOWS | MSYS | MINGW.
      _g05_pure_overlay src/pabi_vector_let_init_nested_one.x \
        build_asm/selfhost_pabi/vector_let_init_nested.o \
        pipeline_asm_emit_vector_let_init_elf_c
      if [ ! -s build_asm/selfhost_pabi/vector_let_init_nested.o ]; then
        echo "g05_relink_env: ERROR Windows vector_let .x did not build" >&2
        exit 1
      fi
      _g05_pure_overlay src/pabi_vector_let_init_mangled_one.x \
        build_asm/selfhost_pabi/vector_let_init_mangled.o \
        pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32
      if [ ! -s build_asm/selfhost_pabi/vector_let_init_mangled.o ]; then
        echo "g05_relink_env: ERROR Windows vector_let mangled .x did not build" >&2
        exit 1
      fi
      _g05_pure_overlay src/pabi_vector_let_init_stubdead_one.x \
        build_asm/selfhost_pabi/vector_let_init_stubdead.o \
        pipeline_asm_emit_vector_let_init_elf_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_i32_reti32_pabi_stubdead
      if [ ! -s build_asm/selfhost_pabi/vector_let_init_stubdead.o ]; then
        echo "g05_relink_env: ERROR Windows vector_let stubdead .x did not build" >&2
        exit 1
      fi
      # w1024: module VAR → local fixed-array.
      # w2060: one strong T from src/pabi_fixed_array_let_init_module_var_one.x.
      # File-local helpers stay in that object. They are not a second
      # link winner. The egg keeps the dest-in-rbx ARRAY_LIT body.
      # Do not gcc seeds/fixed_array_let_init_module_var_override.c here.
      # Linux and Darwin still compile that C. A missing object exits 1.
      # PLATFORM: WINDOWS | MSYS | MINGW.
      _g05_pure_overlay src/pabi_fixed_array_let_init_module_var_one.x \
        build_asm/selfhost_pabi/fixed_array_let_init_module_var.o \
        glue_emit_fixed_array_type_let_init_elf_c
      if [ ! -s build_asm/selfhost_pabi/fixed_array_let_init_module_var.o ]; then
        echo "g05_relink_env: ERROR Windows module_var .x did not build" >&2
        exit 1
      fi
    fi
    if [ "${XLANG_WIN_BAKE_TIP:-}" != "0" ] \
      && [ -s build_asm/selfhost_pabi/bake_elems.o ] \
      && [ -s build_asm/selfhost_pabi/bake_struct.o ] \
      && [ -s build_asm/selfhost_pabi/index_elem_true_i8.o ] \
      && [ -s build_asm/selfhost_pabi/emit_index_arms_true_i8.o ] \
      && [ -s build_asm/selfhost_pabi/emit_index_elf_true_i8.o ] \
      && [ -s build_asm/selfhost_pabi/assign_index_true_i8.o ] \
      && [ -s build_asm/selfhost_pabi/force_esz_true_i8.o ] \
      && [ -s build_asm/selfhost_pabi/array_lit_esz_true_i8.o ]; then
      _WIN_TRUE_PACK=1
    fi
    # w2060: glue_emit_assign_index_elf_c. The first strong T on the PE
    # link is assign_index_true_i8.o, built from pabi_assign_index_one.x.
    # Linux and Darwin still gcc the C seed into the same filename.
    # It is inside _PABI_SELFHOST, ahead of
    # _WIN_ASSIGN_OVERRIDES. PE --allow-multiple-definition is first-wins,
    # so src/win_assign_index_override.o is a later T and does not run.
    # Installed Windows objects: T in assign_index_true_i8.o, T in the
    # override, T in the egg, W in pabi_weak.o. No earlier selfhost
    # object defines it. XLANG_WIN_BAKE_TIP=0 leaves the stack off, so
    # the override stays and still beats the egg. Do not switch
    # assign_index_thin.x on. PLATFORM: WINDOWS.
    # w2060: pipeline_asm_index_elem_byte_sz_c and its two siblings.
    # Each strong T is its own object, built from a .x above.
    # index_elem_true_i8.o is the _c body. from_type is the peeler.
    # wrap is the short forward. Same-.o dual T smashes i32.
    # The non-D src/win_index_elem_byte_sz_override.o is the Cap residual.
    # Drop it once this stack is on. XLANG_WIN_BAKE_TIP=0 leaves the
    # residual linked, and it still beats the egg.
    # PLATFORM: WINDOWS.
    if [ "$_WIN_TRUE_PACK" = "1" ]; then
      _win_asg_kept=""
      for _wov in $_WIN_ASSIGN_OVERRIDES; do
        if [ "$_wov" = "src/win_assign_index_override.o" ] \
          || [ "$_wov" = "src/win_index_elem_byte_sz_override.o" ]; then
          continue
        fi
        _win_asg_kept="${_win_asg_kept}${_win_asg_kept:+ }$_wov"
      done
      _WIN_ASSIGN_OVERRIDES="$_win_asg_kept"
    fi
    if [ "$_WIN_TRUE_PACK" = "1" ]; then
      _PABI_SELFHOST="build_asm/selfhost_pabi/bake_struct.o $_PABI_SELFHOST"
      _PABI_SELFHOST="build_asm/selfhost_pabi/bake_elems.o $_PABI_SELFHOST"
      _PABI_SELFHOST="build_asm/selfhost_pabi/index_elem_true_i8.o $_PABI_SELFHOST"
      if [ -s build_asm/selfhost_pabi/index_elem_from_type.o ]; then
        _PABI_SELFHOST="build_asm/selfhost_pabi/index_elem_from_type.o $_PABI_SELFHOST"
      fi
      if [ -s build_asm/selfhost_pabi/index_elem_wrap.o ]; then
        _PABI_SELFHOST="build_asm/selfhost_pabi/index_elem_wrap.o $_PABI_SELFHOST"
      fi
      _PABI_SELFHOST="build_asm/selfhost_pabi/emit_index_arms_true_i8.o $_PABI_SELFHOST"
      _PABI_SELFHOST="build_asm/selfhost_pabi/emit_index_elf_true_i8.o $_PABI_SELFHOST"
      _PABI_SELFHOST="build_asm/selfhost_pabi/assign_index_true_i8.o $_PABI_SELFHOST"
      _PABI_SELFHOST="build_asm/selfhost_pabi/force_esz_true_i8.o $_PABI_SELFHOST"
      _PABI_SELFHOST="build_asm/selfhost_pabi/array_lit_esz_true_i8.o $_PABI_SELFHOST"
      if [ -s build_asm/selfhost_pabi/fixed_array_total_bytes_true_pack.o ]; then
        _PABI_SELFHOST="build_asm/selfhost_pabi/fixed_array_total_bytes_true_pack.o $_PABI_SELFHOST"
      fi
      if [ -s build_asm/selfhost_pabi/vector_let_init_nested.o ]; then
        _PABI_SELFHOST="build_asm/selfhost_pabi/vector_let_init_nested.o $_PABI_SELFHOST"
      fi
      if [ -s build_asm/selfhost_pabi/vector_let_init_mangled.o ]; then
        _PABI_SELFHOST="build_asm/selfhost_pabi/vector_let_init_mangled.o $_PABI_SELFHOST"
      fi
      if [ -s build_asm/selfhost_pabi/vector_let_init_stubdead.o ]; then
        _PABI_SELFHOST="build_asm/selfhost_pabi/vector_let_init_stubdead.o $_PABI_SELFHOST"
      fi
      if [ -s build_asm/selfhost_pabi/fixed_array_let_init_module_var.o ]; then
        _PABI_SELFHOST="build_asm/selfhost_pabi/fixed_array_let_init_module_var.o $_PABI_SELFHOST"
      fi
    elif [ -s build_asm/selfhost_pabi/bake_struct.o ]; then
      _PABI_SELFHOST="build_asm/selfhost_pabi/bake_struct.o $_PABI_SELFHOST"
    fi
    # w2055 (Windows twin of the Darwin/Linux enum sidecar): pabi_weak keeps
    # the old C bodies of pipeline_expr_enum_namespace_field_tag (32-byte
    # base_buf; pipeline_expr_var_name_into zeros 256 bytes, which reaches the
    # saved rbp, return address and home slots) and pipeline_asm_cmp_enum_rhs_tag_c.
    # Compile the thin with the current product (pure asm), require both
    # strong T, weaken the pabi_weak copies below, link the thin first, and
    # record both names for the post-link map check. win_patch_body_sync_jmp
    # folds the same-TU egg callers W→T. Any failure stops the relink.
    # PLATFORM: WINDOWS.
    _PABI_WIN_ENUM_NS=""
    _wen_x=src/runtime_pipeline_abi_enum_ns_tag_thin.x
    _wen_o=build_asm/selfhost_pabi/enum_ns_tag_win.o
    if [ -f "$_wen_x" ]; then
      mkdir -p build_asm/selfhost_pabi
      rm -f "$_wen_o" "$_wen_o.tmp.o"
      if ! XLANG_PREFER_ASM_O=1 ./xlang_asm -backend asm -c "$_wen_x" -o "$_wen_o.tmp.o" >/dev/null 2>&1; then
        rm -f "$_wen_o.tmp.o"
        echo "g05_relink_env: $_wen_x failed (Windows enum ns tag)" >&2
        exit 1
      fi
      for _wen_s in pipeline_expr_enum_namespace_field_tag pipeline_asm_cmp_enum_rhs_tag_c; do
        if ! nm "$_wen_o.tmp.o" 2>/dev/null | tr -d '\r' | grep -q " T ${_wen_s}\$"; then
          rm -f "$_wen_o.tmp.o"
          echo "g05_relink_env: $_wen_x lacks strong $_wen_s (Windows enum ns tag)" >&2
          exit 1
        fi
      done
      mv -f "$_wen_o.tmp.o" "$_wen_o"
      _PABI_WIN_ENUM_NS="$_wen_o"
      _PABI_SELFHOST="$_wen_o $_PABI_SELFHOST"
    fi
    # w2060: collect-deps import scan (Windows twin of Darwin cimp_a64.o and
    # linux_selfhost_pabi_refresh_tip.sh step 4). pabi_weak keeps a strong T
    # xlang_module_collect_imports_from_buf whose body calls lexer_init.
    # The tip thin builds a Lexer and calls parser_collect_imports_buf. It
    # does not divide. Compile it every relink, require that one strong T,
    # reject a lexer_init reference, weaken the pabi_weak copy below, and
    # link the thin first. win_patch_body_sync_jmp folds the weakened entry
    # onto this T. A missing object or a failed weaken exits 1. The egg
    # file is not edited. Linux and Darwin already rebuild this thin.
    # PLATFORM: WINDOWS | MSYS | MINGW.
    _PABI_WIN_CIMP=""
    _wci_x=src/runtime_pipeline_abi_collect_imports_thin.x
    _wci_o=build_asm/selfhost_pabi/cimp_win.o
    _wci_s=xlang_module_collect_imports_from_buf
    if [ ! -f "$_wci_x" ]; then
      echo "g05_relink_env: $_wci_x missing (Windows collect-imports)" >&2
      exit 1
    fi
    mkdir -p build_asm/selfhost_pabi
    rm -f "$_wci_o" "$_wci_o.tmp.o"
    if ! XLANG_PREFER_ASM_O=1 ./xlang_asm -backend asm -c "$_wci_x" -o "$_wci_o.tmp.o" >/dev/null 2>&1; then
      rm -f "$_wci_o.tmp.o"
      echo "g05_relink_env: $_wci_x failed (Windows collect-imports)" >&2
      exit 1
    fi
    if ! nm "$_wci_o.tmp.o" 2>/dev/null | tr -d '\r' | grep -q " T ${_wci_s}\$"; then
      rm -f "$_wci_o.tmp.o"
      echo "g05_relink_env: $_wci_x lacks strong $_wci_s (Windows collect-imports)" >&2
      exit 1
    fi
    if nm "$_wci_o.tmp.o" 2>/dev/null | tr -d '\r' | grep -q 'lexer_init$'; then
      rm -f "$_wci_o.tmp.o"
      echo "g05_relink_env: $_wci_x still references lexer_init (Windows collect-imports)" >&2
      exit 1
    fi
    mv -f "$_wci_o.tmp.o" "$_wci_o"
    _PABI_WIN_CIMP="$_wci_o"
    _PABI_SELFHOST="$_wci_o $_PABI_SELFHOST"
    # w2060: mixed-width ADD/SUB and f32 promote. Linux and Darwin already
    # rebuild this thin with _g05_pure_overlay (no PREFER). The egg defines
    # each arithmetic export twice. demote-all-dual below keeps the cap-band
    # external and turns the earlier body into a static symbol; same-TU
    # calls still enter that static body. glue_float_promote_src_ty_ref_c
    # is one external. Compile the tip thin every relink, require the four
    # export T symbols, and reject xlang_panic_. Helper T names
    # pipeline_w1591_*, pipeline_w1594_*, and pipeline_w1597_* are absent
    # from the egg, so they stay strong. w1598_add_stored_in_u32 stays
    # undefined here and is defined by the binop_wide overlay. Weaken the
    # four egg externals after demote. win_patch_body_sync_jmp folds the
    # weakened external, and folds the static twin of the three arithmetic
    # names. A missing object exits 1. The egg file is not edited.
    # PLATFORM: WINDOWS | MSYS | MINGW.
    _PABI_WIN_WIDEN=""
    _wwm_x=src/runtime_pipeline_abi_widen_mixed_thin.x
    _wwm_o=build_asm/selfhost_pabi/runtime_pipeline_abi_widen_mixed_thin.o
    _g05_pure_overlay "$_wwm_x" "$_wwm_o" glue_emit_binop_sub_rbx_minus_rax_elf_c
    if [ ! -s "$_wwm_o" ]; then
      echo "g05_relink_env: ERROR Windows widen_mixed .x did not build" >&2
      exit 1
    fi
    for _wwm_s in glue_emit_binop_add_rax_rbx_elf_c \
      glue_emit_binop_sub_rbx_minus_rax_elf_c \
      glue_emit_binop_sub_rax_minus_rbx_elf_c \
      glue_float_promote_src_ty_ref_c; do
      if ! nm "$_wwm_o" 2>/dev/null | tr -d '\r' | grep -q " T ${_wwm_s}\$"; then
        echo "g05_relink_env: $_wwm_x lacks strong $_wwm_s (Windows widen_mixed)" >&2
        exit 1
      fi
    done
    if nm "$_wwm_o" 2>/dev/null | tr -d '\r' | grep -q 'xlang_panic_'; then
      echo "g05_relink_env: $_wwm_x references xlang_panic_ (Windows widen_mixed)" >&2
      exit 1
    fi
    _PABI_WIN_WIDEN="$_wwm_o"
    _PABI_SELFHOST="$_wwm_o $_PABI_SELFHOST"
    # w2060: 9..16 named-field pair load. Linux rebuilds rec.o from this
    # helpers thin. Darwin links the full asm_expr thin (HARD BAN here:
    # frame smash). The Windows egg defines pipeline_asm_emit_expr_elf_rec
    # twice. demote-all-dual below keeps the cap-band external, which calls
    # fast and does not call pipeline_asm_deref_struct16_rax_ptr_elf_c, and
    # leaves the earlier body static. That static range has no such call
    # either. Compile this thin every relink with no PREFER. Require the
    # one strong rec and an undefined reference to the pair helper. Reject
    # xlang_panic_. Another strong T that the egg already defines is
    # weakened in this object so it cannot first-win that egg body.
    # Private helpers stay strong. Link this object first. The egg external
    # is weakened after demote. win_patch_body_sync_jmp folds that W and
    # the static twin onto this T. A missing object exits 1. The egg file
    # is not edited. PLATFORM: WINDOWS | MSYS | MINGW.
    _PABI_WIN_REC=""
    _wrec_x=src/runtime_pipeline_abi_asm_expr_helpers_thin.x
    _wrec_o=build_asm/selfhost_pabi/asm_expr_helpers_win.o
    _wrec_s=pipeline_asm_emit_expr_elf_rec
    _wrec_need=pipeline_asm_deref_struct16_rax_ptr_elf_c
    if [ ! -f "$_wrec_x" ]; then
      echo "g05_relink_env: $_wrec_x missing (Windows expr rec)" >&2
      exit 1
    fi
    _g05_pure_overlay "$_wrec_x" "$_wrec_o" "$_wrec_s"
    if [ ! -s "$_wrec_o" ]; then
      echo "g05_relink_env: ERROR Windows expr rec .x did not build" >&2
      exit 1
    fi
    if ! nm "$_wrec_o" 2>/dev/null | tr -d '\r' | grep -q " T ${_wrec_s}\$"; then
      echo "g05_relink_env: $_wrec_x lacks strong $_wrec_s (Windows expr rec)" >&2
      exit 1
    fi
    if ! nm -u "$_wrec_o" 2>/dev/null | tr -d '\r' | grep -q "${_wrec_need}\$"; then
      echo "g05_relink_env: $_wrec_x does not call $_wrec_need (Windows expr rec)" >&2
      exit 1
    fi
    if nm -u "$_wrec_o" 2>/dev/null | tr -d '\r' | grep -q 'xlang_panic_$'; then
      echo "g05_relink_env: $_wrec_x references xlang_panic_ (Windows expr rec)" >&2
      exit 1
    fi
    _wrec_egg=src/runtime_pipeline_abi.o
    if [ ! -s "$_wrec_egg" ]; then
      _wrec_egg=build_asm/selfhost_pabi/pabi_weak.o
    fi
    _wrec_list=build_asm/selfhost_pabi/asm_expr_helpers_win.tlist
    nm "$_wrec_o" 2>/dev/null | tr -d '\r' | awk '$2=="T"{print $3}' > "$_wrec_list"
    while read -r _wrec_extra; do
      [ -n "$_wrec_extra" ] || continue
      [ "$_wrec_extra" = "$_wrec_s" ] && continue
      if [ -s "$_wrec_egg" ] && nm "$_wrec_egg" 2>/dev/null | tr -d '\r' \
          | awk -v s="$_wrec_extra" '$NF==s && $1 ~ /^[0-9a-fA-F]+$/ {f=1} END{exit !f}'; then
        _wrec_oc=""
        if command -v llvm-objcopy >/dev/null 2>&1; then
          _wrec_oc=llvm-objcopy
        elif command -v objcopy >/dev/null 2>&1; then
          _wrec_oc=objcopy
        fi
        if [ -z "$_wrec_oc" ] || ! "$_wrec_oc" --weaken-symbol="$_wrec_extra" "$_wrec_o"; then
          echo "g05_relink_env: weaken $_wrec_extra in $_wrec_o failed (Windows expr rec)" >&2
          rm -f "$_wrec_list"
          exit 1
        fi
      fi
    done < "$_wrec_list"
    rm -f "$_wrec_list"
    if ! nm "$_wrec_o" 2>/dev/null | tr -d '\r' | grep -q " T ${_wrec_s}\$"; then
      echo "g05_relink_env: $_wrec_o lost strong $_wrec_s (Windows expr rec)" >&2
      exit 1
    fi
    _PABI_WIN_REC="$_wrec_o"
    _PABI_SELFHOST="$_wrec_o $_PABI_SELFHOST"
    # w2060: store a wide retval into the let slot. The Windows egg defines
    # glue_store_retval_pair_to_rbp_elf_c twice. demote-all-dual below keeps
    # the cap-band external, which copies a value wider than 16 bytes only
    # for CALL, METHOD, and INDEX, and leaves the earlier body static.
    # The tip function also copies STRUCT_LIT, FIELD, and VAR. Compile this
    # thin every relink with no PREFER. Require the one strong export and
    # undefined references to the copy helper and the kind loader, so a
    # dropped kind test that deletes the copy fails the relink. Reject
    # xlang_panic_. Another strong T that the egg already defines is
    # weakened in this object. The private cell loader stays strong. Link
    # this object first. The egg external is weakened after demote.
    # win_patch_body_sync_jmp folds that W and the static twin onto this T.
    # A missing object exits 1. The egg file is not edited. Linux and Darwin
    # are not switched here. PLATFORM: WINDOWS | MSYS | MINGW.
    _PABI_WIN_STORE=""
    _wsp_x=src/runtime_pipeline_abi_store_retval_pair_thin.x
    _wsp_o=build_asm/selfhost_pabi/store_retval_pair_win.o
    _wsp_s=glue_store_retval_pair_to_rbp_elf_c
    _wsp_copy=glue_copy_large_struct_from_rax_ptr_elf_c
    _wsp_kind=pipeline_expr_kind_ord_at
    if [ ! -f "$_wsp_x" ]; then
      echo "g05_relink_env: $_wsp_x missing (Windows store pair)" >&2
      exit 1
    fi
    _g05_pure_overlay "$_wsp_x" "$_wsp_o" "$_wsp_s"
    if [ ! -s "$_wsp_o" ]; then
      echo "g05_relink_env: ERROR Windows store pair .x did not build" >&2
      exit 1
    fi
    if ! nm "$_wsp_o" 2>/dev/null | tr -d '\r' | grep -q " T ${_wsp_s}\$"; then
      echo "g05_relink_env: $_wsp_x lacks strong $_wsp_s (Windows store pair)" >&2
      exit 1
    fi
    if ! nm -u "$_wsp_o" 2>/dev/null | tr -d '\r' | grep -q "${_wsp_copy}\$"; then
      echo "g05_relink_env: $_wsp_x does not call $_wsp_copy (Windows store pair)" >&2
      exit 1
    fi
    if ! nm -u "$_wsp_o" 2>/dev/null | tr -d '\r' | grep -q "${_wsp_kind}\$"; then
      echo "g05_relink_env: $_wsp_x does not call $_wsp_kind (Windows store pair)" >&2
      exit 1
    fi
    if nm "$_wsp_o" 2>/dev/null | tr -d '\r' | grep -q 'xlang_panic_'; then
      echo "g05_relink_env: $_wsp_x references xlang_panic_ (Windows store pair)" >&2
      exit 1
    fi
    _wsp_egg=src/runtime_pipeline_abi.o
    if [ ! -s "$_wsp_egg" ]; then
      _wsp_egg=build_asm/selfhost_pabi/pabi_weak.o
    fi
    _wsp_list=build_asm/selfhost_pabi/store_retval_pair_win.tlist
    nm "$_wsp_o" 2>/dev/null | tr -d '\r' | awk '$2=="T"{print $3}' > "$_wsp_list"
    while read -r _wsp_extra; do
      [ -n "$_wsp_extra" ] || continue
      [ "$_wsp_extra" = "$_wsp_s" ] && continue
      if [ -s "$_wsp_egg" ] && nm "$_wsp_egg" 2>/dev/null | tr -d '\r' \
          | awk -v s="$_wsp_extra" '$NF==s && $1 ~ /^[0-9a-fA-F]+$/ {f=1} END{exit !f}'; then
        _wsp_oc=""
        if command -v llvm-objcopy >/dev/null 2>&1; then
          _wsp_oc=llvm-objcopy
        elif command -v objcopy >/dev/null 2>&1; then
          _wsp_oc=objcopy
        fi
        if [ -z "$_wsp_oc" ] || ! "$_wsp_oc" --weaken-symbol="$_wsp_extra" "$_wsp_o"; then
          echo "g05_relink_env: weaken $_wsp_extra in $_wsp_o failed (Windows store pair)" >&2
          rm -f "$_wsp_list"
          exit 1
        fi
      fi
    done < "$_wsp_list"
    rm -f "$_wsp_list"
    if ! nm "$_wsp_o" 2>/dev/null | tr -d '\r' | grep -q " T ${_wsp_s}\$"; then
      echo "g05_relink_env: $_wsp_o lost strong $_wsp_s (Windows store pair)" >&2
      exit 1
    fi
    _PABI_WIN_STORE="$_wsp_o"
    _PABI_SELFHOST="$_wsp_o $_PABI_SELFHOST"
    # w2060: named-field aggregate load outside a call. The Windows egg
    # defines glue_field_call_arg_try_load_agg_from_rax_elf_c once, as T.
    # That body returns 0 when pipeline_asm_emit_call_arg_active_c is 0,
    # before it sizes the field, so a let or assign never takes the 9 to
    # 16 byte pair or the wider-than-16 address path. Three same-TU calls
    # enter that entry. There is no static twin. Compile the existing thin
    # every relink with no PREFER. Require the one strong export and
    # undefined references to the 9 to 16 byte deref and the qword load.
    # Reject xlang_panic_. Another strong T that the egg already defines
    # is weakened in this object. The filename-prefixed cell loaders are
    # not egg symbols and stay strong. Link this object first. The egg
    # external is weakened below. win_patch_body_sync_jmp folds that W
    # onto this T. The name is not added to the static-t list. A missing
    # object exits 1. The egg file is not edited. Darwin already matches
    # the tip, and Linux already links this thin. PLATFORM: WINDOWS | MSYS | MINGW.
    _PABI_WIN_FAG=""
    _wfag_x=src/runtime_pipeline_abi_field_agg_load_thin.x
    _wfag_o=build_asm/selfhost_pabi/field_agg_load_win.o
    _wfag_s=glue_field_call_arg_try_load_agg_from_rax_elf_c
    _wfag_deref=pipeline_asm_deref_struct16_rax_ptr_elf_c
    _wfag_load=backend_enc_load_64_from_rax_arch
    if [ ! -f "$_wfag_x" ]; then
      echo "g05_relink_env: $_wfag_x missing (Windows field aggregate load)" >&2
      exit 1
    fi
    _g05_pure_overlay "$_wfag_x" "$_wfag_o" "$_wfag_s"
    if [ ! -s "$_wfag_o" ]; then
      echo "g05_relink_env: ERROR Windows field aggregate load .x did not build" >&2
      exit 1
    fi
    if ! nm "$_wfag_o" 2>/dev/null | tr -d '\r' | grep -q " T ${_wfag_s}\$"; then
      echo "g05_relink_env: $_wfag_x lacks strong $_wfag_s (Windows field aggregate load)" >&2
      exit 1
    fi
    if ! nm -u "$_wfag_o" 2>/dev/null | tr -d '\r' | grep -q "${_wfag_deref}\$"; then
      echo "g05_relink_env: $_wfag_x does not call $_wfag_deref (Windows field aggregate load)" >&2
      exit 1
    fi
    if ! nm -u "$_wfag_o" 2>/dev/null | tr -d '\r' | grep -q "${_wfag_load}\$"; then
      echo "g05_relink_env: $_wfag_x does not call $_wfag_load (Windows field aggregate load)" >&2
      exit 1
    fi
    if nm "$_wfag_o" 2>/dev/null | tr -d '\r' | grep -q 'xlang_panic_'; then
      echo "g05_relink_env: $_wfag_x references xlang_panic_ (Windows field aggregate load)" >&2
      exit 1
    fi
    _wfag_egg=src/runtime_pipeline_abi.o
    if [ ! -s "$_wfag_egg" ]; then
      _wfag_egg=build_asm/selfhost_pabi/pabi_weak.o
    fi
    _wfag_list=build_asm/selfhost_pabi/field_agg_load_win.tlist
    nm "$_wfag_o" 2>/dev/null | tr -d '\r' | awk '$2=="T"{print $3}' > "$_wfag_list"
    while read -r _wfag_extra; do
      [ -n "$_wfag_extra" ] || continue
      [ "$_wfag_extra" = "$_wfag_s" ] && continue
      if [ -s "$_wfag_egg" ] && nm "$_wfag_egg" 2>/dev/null | tr -d '\r' \
          | awk -v s="$_wfag_extra" '$NF==s && $1 ~ /^[0-9a-fA-F]+$/ {f=1} END{exit !f}'; then
        _wfag_oc=""
        if command -v llvm-objcopy >/dev/null 2>&1; then
          _wfag_oc=llvm-objcopy
        elif command -v objcopy >/dev/null 2>&1; then
          _wfag_oc=objcopy
        fi
        if [ -z "$_wfag_oc" ] || ! "$_wfag_oc" --weaken-symbol="$_wfag_extra" "$_wfag_o"; then
          echo "g05_relink_env: weaken $_wfag_extra in $_wfag_o failed (Windows field aggregate load)" >&2
          rm -f "$_wfag_list"
          exit 1
        fi
      fi
    done < "$_wfag_list"
    rm -f "$_wfag_list"
    if ! nm "$_wfag_o" 2>/dev/null | tr -d '\r' | grep -q " T ${_wfag_s}\$"; then
      echo "g05_relink_env: $_wfag_o lost strong $_wfag_s (Windows field aggregate load)" >&2
      exit 1
    fi
    _PABI_WIN_FAG="$_wfag_o"
    _PABI_SELFHOST="$_wfag_o $_PABI_SELFHOST"
    # w2060: module-array INDEX base. The Windows egg defines
    # glue_try_index_var_or_field_base_to_rbx_elf_c once, as T. That body
    # is 27 bytes: it homes rcx, rdx, r8, and r9, returns -2, and pops rbp.
    # Eighteen same-TU REL32 calls name that entry. There is no static
    # twin. Compile the existing thin every relink with no PREFER. Require
    # the one strong export and undefined references to _rest, the kind
    # loader, the stack-offset helper, the modlet load, and mov rax to rbx.
    # Reject xlang_panic_. Another strong T that the egg already defines
    # is weakened in this object. The egg entry must stay those 27 bytes;
    # a different entry stops the relink. Assemble that entry as
    # glue_try_index_var_or_field_base_to_rbx_elf_rest. The post-link fold
    # overwrites the egg bytes, so _rest is this separate object and is
    # not weakened. Link the thin ahead of _rest and ahead of pabi_weak.
    # The egg external is weakened below. win_patch_body_sync_jmp folds
    # that W onto this T. The name is not added to the static-t list. A
    # missing object exits 1. The egg file is not edited. Linux already
    # links this thin as base.o. Darwin already assembles its own eight-byte
    # _rest. PLATFORM: WINDOWS | MSYS | MINGW.
    _PABI_WIN_IDX=""
    _widx_x=src/runtime_pipeline_abi_index_base_rbx_thin.x
    _widx_o=build_asm/selfhost_pabi/index_base_rbx_win.o
    _widx_s=glue_try_index_var_or_field_base_to_rbx_elf_c
    _widx_rest_s=build_asm/selfhost_pabi/index_base_rbx_rest_win.s
    _widx_rest_o=build_asm/selfhost_pabi/index_base_rbx_rest_win.o
    _widx_rest_sym=glue_try_index_var_or_field_base_to_rbx_elf_rest
    if [ ! -f "$_widx_x" ]; then
      echo "g05_relink_env: $_widx_x missing (Windows index base)" >&2
      exit 1
    fi
    _g05_pure_overlay "$_widx_x" "$_widx_o" "$_widx_s"
    if [ ! -s "$_widx_o" ]; then
      echo "g05_relink_env: ERROR Windows index base .x did not build" >&2
      exit 1
    fi
    if ! nm "$_widx_o" 2>/dev/null | tr -d '\r' | grep -q " T ${_widx_s}\$"; then
      echo "g05_relink_env: $_widx_x lacks strong $_widx_s (Windows index base)" >&2
      exit 1
    fi
    for _widx_need in glue_try_index_var_or_field_base_to_rbx_elf_rest \
        pipeline_expr_kind_ord_at glue_var_expr_stack_off_elf_c \
        pipeline_asm_modlet_load_to_rax_elf_c backend_enc_mov_rax_to_rbx_arch; do
      if ! nm -u "$_widx_o" 2>/dev/null | tr -d '\r' | grep -q "${_widx_need}\$"; then
        echo "g05_relink_env: $_widx_x does not call $_widx_need (Windows index base)" >&2
        exit 1
      fi
    done
    if nm "$_widx_o" 2>/dev/null | tr -d '\r' | grep -q 'xlang_panic_'; then
      echo "g05_relink_env: $_widx_x references xlang_panic_ (Windows index base)" >&2
      exit 1
    fi
    _widx_egg=src/runtime_pipeline_abi.o
    if [ ! -s "$_widx_egg" ]; then
      echo "g05_relink_env: $_widx_egg missing (Windows index base)" >&2
      exit 1
    fi
    if ! python3 - "$_widx_egg" "$_widx_s" span <<'PY'
import re, subprocess, sys
path, name, mode = sys.argv[1], sys.argv[2], sys.argv[3]
want = bytes.fromhex("554889e548894d1048895518448945204c894d28b8feffffff5dc3")
nm = subprocess.check_output(["nm", path], text=True, errors="replace")
rows = []
for line in nm.splitlines():
    parts = line.replace("\r", "").split()
    if len(parts) < 3:
        continue
    try:
        addr = int(parts[0], 16)
    except ValueError:
        continue
    rows.append((addr, parts[1], parts[-1]))
hits = [addr for addr, kind, sym in rows if sym == name and kind in "Tt"]
if len(hits) != 1:
    sys.stderr.write("g05_relink_env: Windows index base symbol count %d\n" % len(hits))
    sys.exit(1)
hit = hits[0]
if mode == "span":
    later = [addr for addr, kind, sym in rows if addr > hit]
    if not later:
        sys.stderr.write("g05_relink_env: Windows index base has no next symbol\n")
        sys.exit(1)
    stop = min(later)
    if stop - hit != 27:
        sys.stderr.write("g05_relink_env: Windows index base span is %d\n" % (stop - hit))
        sys.exit(1)
else:
    stop = hit + 27
dump = subprocess.check_output(
    ["objdump", "-d", "--start-address=0x%x" % hit, "--stop-address=0x%x" % stop, path],
    text=True, errors="replace")
got = bytearray()
for line in dump.splitlines():
    m = re.match(r"\s*[0-9a-f]+:\s+((?:[0-9a-f]{2}[ \t]+)+)", line)
    if not m:
        continue
    for b in m.group(1).split():
        got.append(int(b, 16))
if bytes(got) != want:
    sys.stderr.write("g05_relink_env: Windows index base entry bytes changed\n")
    sys.exit(1)
PY
    then
      echo "g05_relink_env: Windows index base egg entry check failed" >&2
      exit 1
    fi
    cat > "$_widx_rest_s" <<'EOF'
.globl glue_try_index_var_or_field_base_to_rbx_elf_rest
.def glue_try_index_var_or_field_base_to_rbx_elf_rest
.scl 2
.type 32
.endef
glue_try_index_var_or_field_base_to_rbx_elf_rest:
    push %rbp
    mov %rsp, %rbp
    mov %rcx, 0x10(%rbp)
    mov %rdx, 0x18(%rbp)
    mov %r8d, 0x20(%rbp)
    mov %r9, 0x28(%rbp)
    mov $0xfffffffe, %eax
    pop %rbp
    ret
EOF
    if ! as -o "$_widx_rest_o" "$_widx_rest_s"; then
      echo "g05_relink_env: Windows index base _rest assemble failed" >&2
      exit 1
    fi
    if ! nm "$_widx_rest_o" 2>/dev/null | tr -d '\r' | grep -q " T ${_widx_rest_sym}\$"; then
      echo "g05_relink_env: Windows index base _rest symbol missing" >&2
      exit 1
    fi
    if ! python3 - "$_widx_rest_o" "$_widx_rest_sym" prefix <<'PY'
import re, subprocess, sys
path, name, mode = sys.argv[1], sys.argv[2], sys.argv[3]
want = bytes.fromhex("554889e548894d1048895518448945204c894d28b8feffffff5dc3")
nm = subprocess.check_output(["nm", path], text=True, errors="replace")
rows = []
for line in nm.splitlines():
    parts = line.replace("\r", "").split()
    if len(parts) < 3:
        continue
    try:
        addr = int(parts[0], 16)
    except ValueError:
        continue
    rows.append((addr, parts[1], parts[-1]))
hits = [addr for addr, kind, sym in rows if sym == name and kind in "Tt"]
if len(hits) != 1:
    sys.stderr.write("g05_relink_env: Windows index base symbol count %d\n" % len(hits))
    sys.exit(1)
hit = hits[0]
if mode == "span":
    later = [addr for addr, kind, sym in rows if addr > hit]
    if not later:
        sys.stderr.write("g05_relink_env: Windows index base has no next symbol\n")
        sys.exit(1)
    stop = min(later)
    if stop - hit != 27:
        sys.stderr.write("g05_relink_env: Windows index base span is %d\n" % (stop - hit))
        sys.exit(1)
else:
    stop = hit + 27
dump = subprocess.check_output(
    ["objdump", "-d", "--start-address=0x%x" % hit, "--stop-address=0x%x" % stop, path],
    text=True, errors="replace")
got = bytearray()
for line in dump.splitlines():
    m = re.match(r"\s*[0-9a-f]+:\s+((?:[0-9a-f]{2}[ \t]+)+)", line)
    if not m:
        continue
    for b in m.group(1).split():
        got.append(int(b, 16))
if bytes(got) != want:
    sys.stderr.write("g05_relink_env: Windows index base entry bytes changed\n")
    sys.exit(1)
PY
    then
      echo "g05_relink_env: Windows index base _rest bytes mismatch" >&2
      exit 1
    fi
    _widx_list=build_asm/selfhost_pabi/index_base_rbx_win.tlist
    nm "$_widx_o" 2>/dev/null | tr -d '\r' | awk '$2=="T"{print $3}' > "$_widx_list"
    while read -r _widx_extra; do
      [ -n "$_widx_extra" ] || continue
      [ "$_widx_extra" = "$_widx_s" ] && continue
      if [ -s "$_widx_egg" ] && nm "$_widx_egg" 2>/dev/null | tr -d '\r' \
          | awk -v s="$_widx_extra" '$NF==s && $1 ~ /^[0-9a-fA-F]+$/ {f=1} END{exit !f}'; then
        _widx_oc=""
        if command -v llvm-objcopy >/dev/null 2>&1; then
          _widx_oc=llvm-objcopy
        elif command -v objcopy >/dev/null 2>&1; then
          _widx_oc=objcopy
        fi
        if [ -z "$_widx_oc" ] || ! "$_widx_oc" --weaken-symbol="$_widx_extra" "$_widx_o"; then
          echo "g05_relink_env: weaken $_widx_extra in $_widx_o failed (Windows index base)" >&2
          rm -f "$_widx_list"
          exit 1
        fi
      fi
    done < "$_widx_list"
    rm -f "$_widx_list"
    if ! nm "$_widx_o" 2>/dev/null | tr -d '\r' | grep -q " T ${_widx_s}\$"; then
      echo "g05_relink_env: $_widx_o lost strong $_widx_s (Windows index base)" >&2
      exit 1
    fi
    _PABI_WIN_IDX="$_widx_o"
    _PABI_SELFHOST="$_widx_o $_widx_rest_o $_PABI_SELFHOST"
    # w2060: param-pointer slot. Darwin already rebuilds this thin.
    # Linux injects it through pipeline_abi_inject_param_ptr_slot_thin.
    # The Windows egg defines glue_local_var_slot_needs_ptr_load_elf_c
    # once, below the demote cap, so demote leaves that external. Four
    # same-TU REL32 calls name it, from
    # glue_emit_slice_length_to_rbx_elf_c,
    # glue_enc_local_slot_ptr_or_addr_rbx_elf_c,
    # glue_load_var_as_value_to_rax_rdx_elf_c, and
    # pipeline_asm_emit_var_field_access_elf_c. None of those owners is
    # folded. w189_param_at_is_type_ptr is one external and has no reloc.
    # w189_stack_off_is_emit_param_ptr_slot is one in-cap external plus
    # one static below the cap; neither has a reloc. Compile the existing
    # thin every relink with no PREFER. Require the three strong T
    # symbols and reject xlang_panic_. Link the thin ahead of pabi.
    # Weaken the three egg externals below. The static w189_stack_off
    # copy stays static and out of the static-t list.
    # win_patch_body_sync_jmp folds only
    # glue_local_var_slot_needs_ptr_load_elf_c. A missing object exits 1.
    # The egg file is not edited. PLATFORM: WINDOWS | MSYS | MINGW.
    _PABI_WIN_PPS=""
    _wpps_x=src/runtime_pipeline_abi_param_ptr_slot_thin.x
    _wpps_o=build_asm/selfhost_pabi/param_ptr_slot_win.o
    if [ ! -f "$_wpps_x" ]; then
      echo "g05_relink_env: $_wpps_x missing (Windows param ptr slot)" >&2
      exit 1
    fi
    _g05_pure_overlay "$_wpps_x" "$_wpps_o" glue_local_var_slot_needs_ptr_load_elf_c
    if [ ! -s "$_wpps_o" ]; then
      echo "g05_relink_env: ERROR Windows param ptr slot .x did not build" >&2
      exit 1
    fi
    for _wpps_s in glue_local_var_slot_needs_ptr_load_elf_c \
        w189_param_at_is_type_ptr \
        w189_stack_off_is_emit_param_ptr_slot; do
      if ! nm "$_wpps_o" 2>/dev/null | tr -d '\r' | grep -q " T ${_wpps_s}\$"; then
        echo "g05_relink_env: $_wpps_x lacks strong $_wpps_s (Windows param ptr slot)" >&2
        exit 1
      fi
    done
    if nm "$_wpps_o" 2>/dev/null | tr -d '\r' | grep -q 'xlang_panic_'; then
      echo "g05_relink_env: $_wpps_x references xlang_panic_ (Windows param ptr slot)" >&2
      exit 1
    fi
    _PABI_WIN_PPS="$_wpps_o"
    _PABI_SELFHOST="$_wpps_o $_PABI_SELFHOST"
    # w2055: assignment through a pointer (Windows twin of the Darwin assign
    # sidecar). pabi_weak keeps the pre-wave324 pipeline_asm_emit_assign_elf_c,
    # whose deref path (win_assign_deref_override) stores rax only, so
    # `*p = s` writes the first 8 bytes of a struct and drops the rest.
    # lexer.x hands Token back through an out pointer (e5ba88d9d). Compile the
    # thin with the current product (pure asm), require a strong T, weaken the
    # pabi_weak copy below, link the thin first, record it for the post-link
    # map check; win_patch_body_sync_jmp folds same-TU egg callers W→T.
    # Any failure stops the relink. PLATFORM: WINDOWS.
    _PABI_WIN_ASSIGN=""
    _was_x=src/runtime_pipeline_abi_assign_thin.x
    _was_o=build_asm/selfhost_pabi/assign_win.o
    if [ -f "$_was_x" ]; then
      mkdir -p build_asm/selfhost_pabi
      rm -f "$_was_o" "$_was_o.tmp.o"
      if ! XLANG_PREFER_ASM_O=1 ./xlang_asm -backend asm -c "$_was_x" -o "$_was_o.tmp.o" >/dev/null 2>&1; then
        rm -f "$_was_o.tmp.o"
        echo "g05_relink_env: $_was_x failed (Windows assign)" >&2
        exit 1
      fi
      if ! nm "$_was_o.tmp.o" 2>/dev/null | tr -d '\r' | grep -q " T pipeline_asm_emit_assign_elf_c\$"; then
        rm -f "$_was_o.tmp.o"
        echo "g05_relink_env: $_was_x lacks strong pipeline_asm_emit_assign_elf_c (Windows assign)" >&2
        exit 1
      fi
      mv -f "$_was_o.tmp.o" "$_was_o"
      _PABI_WIN_ASSIGN="$_was_o"
      _PABI_SELFHOST="$_was_o $_PABI_SELFHOST"
    fi
    # w2055: INDEX assign-address cache (Windows twin of the Darwin w156
    # guard sidecar). The assign thin asks glue_index_assign_addr_cache_hit
    # before an INDEX store; the pabi_weak copy still answers from the
    # wave156 cache, which nothing clears at an if/else join, so an else
    # arm can store through a stale address. The guard thin always misses.
    # Linux rebuilds w156_guard.o in the Linux self-host block.
    # Compile it with the current product (pure asm), require a strong T,
    # weaken the pabi_weak copy below, record it for the map check. Any
    # failure stops the relink. PLATFORM: WINDOWS.
    _PABI_WIN_W156=""
    _wgd_x=src/runtime_pipeline_abi_w156_guard_thin.x
    _wgd_o=build_asm/selfhost_pabi/w156_guard_win.o
    if [ -f "$_wgd_x" ]; then
      mkdir -p build_asm/selfhost_pabi
      rm -f "$_wgd_o" "$_wgd_o.tmp.o"
      if ! XLANG_PREFER_ASM_O=1 ./xlang_asm -backend asm -c "$_wgd_x" -o "$_wgd_o.tmp.o" >/dev/null 2>&1; then
        rm -f "$_wgd_o.tmp.o"
        echo "g05_relink_env: $_wgd_x failed (Windows w156 guard)" >&2
        exit 1
      fi
      if ! nm "$_wgd_o.tmp.o" 2>/dev/null | tr -d '\r' | grep -q " T glue_index_assign_addr_cache_hit\$"; then
        rm -f "$_wgd_o.tmp.o"
        echo "g05_relink_env: $_wgd_x lacks strong glue_index_assign_addr_cache_hit (Windows w156 guard)" >&2
        exit 1
      fi
      mv -f "$_wgd_o.tmp.o" "$_wgd_o"
      _PABI_WIN_W156="$_wgd_o"
      _PABI_SELFHOST="$_wgd_o $_PABI_SELFHOST"
    fi
    # w2060 A1: Windows twin of the Darwin struct let-init sidecar.
    # Thin file carries only glue_emit_struct_type_let_init_elf_c (let_init
    # winner). fields/lit/struct_let_init stay as extern → pabi leftover.
    # Do not weaken anything inside the thin. Weaken only the pabi_weak egg
    # copy of let_init below; objcopy failure exits 1. Map-check the winner.
    # PLATFORM: WINDOWS.
    _PABI_WIN_SLI=""
    _wsl_x=src/runtime_pipeline_abi_struct_let_init_thin.x
    _wsl_o=build_asm/selfhost_pabi/struct_let_init_win.o
    if [ -f "$_wsl_x" ]; then
      mkdir -p build_asm/selfhost_pabi
      rm -f "$_wsl_o" "$_wsl_o.tmp.o"
      if ! XLANG_PREFER_ASM_O=1 ./xlang_asm -backend asm -c "$_wsl_x" -o "$_wsl_o.tmp.o" >/dev/null 2>&1; then
        rm -f "$_wsl_o.tmp.o"
        echo "g05_relink_env: $_wsl_x failed (Windows struct let init)" >&2
        exit 1
      fi
      for _wsl_s in glue_emit_struct_type_let_init_elf_c; do
        if ! nm "$_wsl_o.tmp.o" 2>/dev/null | tr -d '\r' | grep -q " T ${_wsl_s}\$"; then
          rm -f "$_wsl_o.tmp.o"
          echo "g05_relink_env: $_wsl_x lacks strong $_wsl_s (Windows struct let init)" >&2
          exit 1
        fi
      done
      # A1: thin must not define/weaken the other three family symbols.
      for _wsl_bad in pipeline_asm_emit_struct_let_init_elf_c pipeline_asm_emit_struct_lit_fields_elf_c pipeline_asm_emit_struct_lit_elf_c; do
        if nm "$_wsl_o.tmp.o" 2>/dev/null | tr -d '\r' | grep -q " T ${_wsl_bad}\$"; then
          rm -f "$_wsl_o.tmp.o"
          echo "g05_relink_env: $_wsl_x must not define $_wsl_bad (Windows A1 let_init-only)" >&2
          exit 1
        fi
      done
      mv -f "$_wsl_o.tmp.o" "$_wsl_o"
      _PABI_WIN_SLI="$_wsl_o"
      _PABI_SELFHOST="$_wsl_o $_PABI_SELFHOST"
    fi
    # w2060: call-arg packer (Windows twin of linux_selfhost_pabi_refresh_tip.sh
    # step 6). pabi_weak keeps the 10-05 pipeline_asm_emit_expr_elf_for_call_args,
    # so the tip fix for fixed-array FIELD arguments (decay to the element
    # address for pointer formals) never reached the Windows product. Compile
    # the thin with this stage's product (pure asm), require a strong T,
    # weaken every other global of the thin (first-wins must not pick up
    # anything else), weaken the pabi_weak copy below, link the thin first,
    # and record it for the post-link map check; win_patch_body_sync_jmp
    # folds same-TU egg callers W->T. Any failure stops the relink.
    # PLATFORM: WINDOWS.
    _PABI_WIN_FCA=""
    _wfc_x=src/runtime_pipeline_abi_for_call_args_thin.x
    _wfc_o=build_asm/selfhost_pabi/for_call_args_win.o
    _wfc_s=pipeline_asm_emit_expr_elf_for_call_args
    if [ ! -f "$_wfc_x" ]; then
      echo "g05_relink_env: $_wfc_x missing (Windows call-arg packer)" >&2
      exit 1
    fi
    mkdir -p build_asm/selfhost_pabi
    rm -f "$_wfc_o" "$_wfc_o.tmp.o"
    if ! XLANG_PREFER_ASM_O=1 ./xlang_asm -backend asm -c "$_wfc_x" -o "$_wfc_o.tmp.o" >/dev/null 2>&1; then
      rm -f "$_wfc_o.tmp.o"
      echo "g05_relink_env: $_wfc_x failed (Windows call-arg packer)" >&2
      exit 1
    fi
    _wfc_oc=""
    if command -v llvm-objcopy >/dev/null 2>&1; then
      _wfc_oc=llvm-objcopy
    elif command -v objcopy >/dev/null 2>&1; then
      _wfc_oc=objcopy
    fi
    if [ -z "$_wfc_oc" ]; then
      rm -f "$_wfc_o.tmp.o"
      echo "g05_relink_env: no objcopy for $_wfc_x (Windows call-arg packer)" >&2
      exit 1
    fi
    for _wfc_g in $(nm "$_wfc_o.tmp.o" 2>/dev/null | tr -d '\r' | awk '$2=="T"{print $3}'); do
      [ "$_wfc_g" = "$_wfc_s" ] && continue
      if ! "$_wfc_oc" --weaken-symbol="$_wfc_g" "$_wfc_o.tmp.o"; then
        rm -f "$_wfc_o.tmp.o"
        echo "g05_relink_env: weaken $_wfc_g in $_wfc_x failed (Windows call-arg packer)" >&2
        exit 1
      fi
    done
    if ! nm "$_wfc_o.tmp.o" 2>/dev/null | tr -d '\r' | grep -q " T ${_wfc_s}\$"; then
      rm -f "$_wfc_o.tmp.o"
      echo "g05_relink_env: $_wfc_x lacks strong $_wfc_s (Windows call-arg packer)" >&2
      exit 1
    fi
    mv -f "$_wfc_o.tmp.o" "$_wfc_o"
    _PABI_WIN_FCA="$_wfc_o"
    _PABI_SELFHOST="$_wfc_o $_PABI_SELFHOST"
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
      || [ -n "$_PABI_TAIL_JMP_OFF" ] \
      || [ -n "$_PABI_BINOP_WIDE" ] \
      || [ -n "$_PABI_MODLET_STRPOOL" ] \
      || [ -n "$_PABI_STRUCT_LIT_FIELD" ] \
      || [ -n "$_PABI_MODLET_FLOAT_IMM" ] \
      || [ -n "$_PABI_INDEX_BASE_FIELD" ] \
      || [ -n "$_PABI_ASSIGN_VAR" ] \
      || [ -n "$_PABI_WIN_ENUM_NS" ] \
      || [ -n "$_PABI_WIN_ASSIGN" ] \
      || [ -n "$_PABI_WIN_W156" ] \
      || [ -n "$_PABI_WIN_SLI" ] \
      || [ -n "$_PABI_WIN_FCA" ] \
      || [ -n "$_PABI_WIN_CIMP" ] \
      || [ -n "$_PABI_WIN_WIDEN" ] \
      || [ -n "$_PABI_WIN_REC" ] \
      || [ -n "$_PABI_WIN_STORE" ] \
      || [ -n "$_PABI_WIN_IDX" ] \
      || [ -n "$_PABI_WIN_PPS" ] \
      || [ -s build_asm/selfhost_pabi/field_cap_residual_load.o ]; then
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
            "$_oc" --weaken-symbol="$_bsym" build_asm/selfhost_pabi/pabi_weak.o || { echo "g05_relink_env: ERROR objcopy failed at line 2082" >&2; exit 1; }
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
        # w1565: weaken egg thin-delegate predicate so the overlay first-wins.
        # The one same-TU caller is asm_skip_heavy_module_func_body (REL32).
        # win_patch names folds that W onto the overlay. PLATFORM: WINDOWS.
        if [ -n "$_PABI_PARSER_THIN_DELEGATE" ]; then
          "$_oc" --weaken-symbol=asm_parser_func_is_thin_delegate \
            build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
        # w1572: weaken egg undef cap and workspace accessors.
        # PLATFORM: WINDOWS.
        if [ -n "$_PABI_ELF_UNDEF_CAP" ]; then
          for _csym in pipe_elf_undef_cap pipe_elf_ws_undef_name_row \
              pipe_elf_ws_undef_len_at pipe_elf_ws_undef_len_set; do
            "$_oc" --weaken-symbol="$_csym" \
              build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
          done
        fi
        # w1576: weaken egg glue_type_size_simple so the overlay first-wins.
        # PLATFORM: WINDOWS.
        if [ -n "$_PABI_NAMED_SIZE" ]; then
          "$_oc" --weaken-symbol=glue_type_size_simple \
            build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
        fi
        # w2055: weaken the egg enum ns tag / cmp rhs tag copies so the thin
        # first-wins; a failed weaken stops the relink. PLATFORM: WINDOWS.
        if [ -n "$_PABI_WIN_ENUM_NS" ]; then
          for _wen_s in pipeline_expr_enum_namespace_field_tag pipeline_asm_cmp_enum_rhs_tag_c; do
            if ! "$_oc" --weaken-symbol="$_wen_s" build_asm/selfhost_pabi/pabi_weak.o; then
              echo "g05_relink_env: weaken pabi_weak $_wen_s failed (Windows)" >&2
              exit 1
            fi
            _G05_LINK_WINNERS="$_G05_LINK_WINNERS $_wen_s=$_PABI_WIN_ENUM_NS"
          done
        fi
        # w2055: weaken the egg assign copy so the thin first-wins; a failed
        # weaken stops the relink. PLATFORM: WINDOWS.
        if [ -n "$_PABI_WIN_ASSIGN" ]; then
          if ! "$_oc" --weaken-symbol=pipeline_asm_emit_assign_elf_c build_asm/selfhost_pabi/pabi_weak.o; then
            echo "g05_relink_env: weaken pabi_weak pipeline_asm_emit_assign_elf_c failed (Windows)" >&2
            exit 1
          fi
          _G05_LINK_WINNERS="$_G05_LINK_WINNERS pipeline_asm_emit_assign_elf_c=$_PABI_WIN_ASSIGN"
        fi
        # w2055: weaken the egg INDEX assign-address cache hit so the guard
        # thin first-wins; a failed weaken stops the relink. PLATFORM: WINDOWS.
        if [ -n "$_PABI_WIN_W156" ]; then
          if ! "$_oc" --weaken-symbol=glue_index_assign_addr_cache_hit build_asm/selfhost_pabi/pabi_weak.o; then
            echo "g05_relink_env: weaken pabi_weak glue_index_assign_addr_cache_hit failed (Windows)" >&2
            exit 1
          fi
          _G05_LINK_WINNERS="$_G05_LINK_WINNERS glue_index_assign_addr_cache_hit=$_PABI_WIN_W156"
        fi
        # w2060: weaken the egg struct let-init family so the thin first-wins;
        # a failed weaken stops the relink. PLATFORM: WINDOWS.
        if [ -n "$_PABI_WIN_SLI" ]; then
          for _wsl_s in glue_emit_struct_type_let_init_elf_c; do
            if ! "$_oc" --weaken-symbol="$_wsl_s" build_asm/selfhost_pabi/pabi_weak.o; then
              echo "g05_relink_env: weaken pabi_weak $_wsl_s failed (Windows)" >&2
              exit 1
            fi
            _G05_LINK_WINNERS="$_G05_LINK_WINNERS $_wsl_s=$_PABI_WIN_SLI"
          done
        fi
        # w2060: weaken the egg call-arg packer so the thin first-wins; a
        # failed weaken stops the relink. PLATFORM: WINDOWS.
        if [ -n "$_PABI_WIN_FCA" ]; then
          if ! "$_oc" --weaken-symbol=pipeline_asm_emit_expr_elf_for_call_args build_asm/selfhost_pabi/pabi_weak.o; then
            echo "g05_relink_env: weaken pabi_weak pipeline_asm_emit_expr_elf_for_call_args failed (Windows)" >&2
            exit 1
          fi
          _G05_LINK_WINNERS="$_G05_LINK_WINNERS pipeline_asm_emit_expr_elf_for_call_args=$_PABI_WIN_FCA"
        fi
        # w2060: weaken the egg collect-imports copy so the thin first-wins.
        # The old body calls lexer_init. A failed weaken stops the relink.
        # PLATFORM: WINDOWS.
        if [ -n "$_PABI_WIN_CIMP" ]; then
          if ! "$_oc" --weaken-symbol=xlang_module_collect_imports_from_buf build_asm/selfhost_pabi/pabi_weak.o; then
            echo "g05_relink_env: weaken pabi_weak xlang_module_collect_imports_from_buf failed (Windows)" >&2
            exit 1
          fi
          _G05_LINK_WINNERS="$_G05_LINK_WINNERS xlang_module_collect_imports_from_buf=$_PABI_WIN_CIMP"
        fi
        # w2060: weaken the egg mixed-width add/sub and f32 promote copies
        # so the thin first-wins. demote-all-dual has already made the
        # earlier arithmetic twin static and left the cap-band external.
        # glue_float_promote_src_ty_ref_c has one definition. A failed
        # weaken stops the relink. The egg file is not edited.
        # PLATFORM: WINDOWS.
        if [ -n "$_PABI_WIN_WIDEN" ]; then
          for _wwm_s in glue_emit_binop_add_rax_rbx_elf_c \
            glue_emit_binop_sub_rbx_minus_rax_elf_c \
            glue_emit_binop_sub_rax_minus_rbx_elf_c \
            glue_float_promote_src_ty_ref_c; do
            if ! "$_oc" --weaken-symbol="$_wwm_s" build_asm/selfhost_pabi/pabi_weak.o; then
              echo "g05_relink_env: weaken pabi_weak $_wwm_s failed (Windows widen_mixed)" >&2
              exit 1
            fi
            _G05_LINK_WINNERS="$_G05_LINK_WINNERS $_wwm_s=$_PABI_WIN_WIDEN"
          done
        fi
        # w2060: weaken the egg expr rec so the helpers thin first-wins.
        # demote-all-dual has already made the earlier twin static and left
        # the cap-band external. That external calls fast and does not call
        # the 9..16 pair helper. A failed weaken stops the relink. The egg
        # file is not edited. PLATFORM: WINDOWS.
        if [ -n "$_PABI_WIN_REC" ]; then
          if ! "$_oc" --weaken-symbol=pipeline_asm_emit_expr_elf_rec \
              build_asm/selfhost_pabi/pabi_weak.o; then
            echo "g05_relink_env: weaken pabi_weak pipeline_asm_emit_expr_elf_rec failed (Windows expr rec)" >&2
            exit 1
          fi
          _G05_LINK_WINNERS="$_G05_LINK_WINNERS pipeline_asm_emit_expr_elf_rec=$_PABI_WIN_REC"
        fi
        # w2060: weaken the egg store-retval copy so this thin first-wins.
        # demote-all-dual has already made the earlier twin static and left
        # the cap-band external. That external copies a value wider than
        # 16 bytes only for CALL, METHOD, and INDEX. A failed weaken stops
        # the relink. The egg file is not edited. PLATFORM: WINDOWS.
        if [ -n "$_PABI_WIN_STORE" ]; then
          if ! "$_oc" --weaken-symbol=glue_store_retval_pair_to_rbp_elf_c \
              build_asm/selfhost_pabi/pabi_weak.o; then
            echo "g05_relink_env: weaken pabi_weak glue_store_retval_pair_to_rbp_elf_c failed (Windows store pair)" >&2
            exit 1
          fi
          _G05_LINK_WINNERS="$_G05_LINK_WINNERS glue_store_retval_pair_to_rbp_elf_c=$_PABI_WIN_STORE"
        fi
        # w2060: weaken the egg field-aggregate load so this thin first-wins.
        # The measured copy is one T. It returns 0 before sizing when no
        # call argument is active. A failed weaken stops the relink. The
        # egg file is not edited. PLATFORM: WINDOWS.
        if [ -n "$_PABI_WIN_FAG" ]; then
          if ! "$_oc" --weaken-symbol=glue_field_call_arg_try_load_agg_from_rax_elf_c \
              build_asm/selfhost_pabi/pabi_weak.o; then
            echo "g05_relink_env: weaken pabi_weak glue_field_call_arg_try_load_agg_from_rax_elf_c failed (Windows field aggregate load)" >&2
            exit 1
          fi
          _G05_LINK_WINNERS="$_G05_LINK_WINNERS glue_field_call_arg_try_load_agg_from_rax_elf_c=$_PABI_WIN_FAG"
        fi
        # w2060: weaken the egg index-base entry so this thin first-wins.
        # The measured copy is one T. It homes the four register arguments
        # and returns -2. Eighteen same-TU REL32 calls name it. A failed
        # weaken stops the relink. The egg file is not edited. _rest is a
        # separate object and is not weakened. PLATFORM: WINDOWS.
        if [ -n "$_PABI_WIN_IDX" ]; then
          if ! "$_oc" --weaken-symbol=glue_try_index_var_or_field_base_to_rbx_elf_c \
              build_asm/selfhost_pabi/pabi_weak.o; then
            echo "g05_relink_env: weaken pabi_weak glue_try_index_var_or_field_base_to_rbx_elf_c failed (Windows index base)" >&2
            exit 1
          fi
          _G05_LINK_WINNERS="$_G05_LINK_WINNERS glue_try_index_var_or_field_base_to_rbx_elf_c=$_PABI_WIN_IDX"
        fi
        # w2060: weaken the egg field-access load width so the field_cap
        # thin first-wins. One external T sits in the demote cap, so demote
        # leaves it external. Six same-TU REL32 calls still enter it. There
        # is no static twin. A failed weaken stops the relink. The egg file
        # is not edited. PLATFORM: WINDOWS.
        if [ -s build_asm/selfhost_pabi/field_cap_residual_load.o ]; then
          if ! "$_oc" --weaken-symbol=pipeline_expr_field_access_load_byte_sz \
              build_asm/selfhost_pabi/pabi_weak.o; then
            echo "g05_relink_env: weaken pabi_weak pipeline_expr_field_access_load_byte_sz failed (Windows field load width)" >&2
            exit 1
          fi
        fi
        # w2060: weaken the egg param-pointer slot externals so this thin
        # first-wins. glue_local_var_slot_needs_ptr_load_elf_c is one
        # external below the demote cap. Four same-TU REL32 calls name it.
        # The two w189 helpers are externals with no reloc. The static
        # w189_stack_off twin is left static. A failed weaken stops the
        # relink. The egg file is not edited. PLATFORM: WINDOWS.
        if [ -n "$_PABI_WIN_PPS" ]; then
          for _wpps_s in glue_local_var_slot_needs_ptr_load_elf_c \
              w189_param_at_is_type_ptr \
              w189_stack_off_is_emit_param_ptr_slot; do
            if ! nm build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null | tr -d '\r' \
                | grep -q " T ${_wpps_s}\$"; then
              echo "g05_relink_env: pabi_weak lacks $_wpps_s (Windows param ptr slot)" >&2
              exit 1
            fi
            if ! "$_oc" --weaken-symbol="$_wpps_s" \
                build_asm/selfhost_pabi/pabi_weak.o; then
              echo "g05_relink_env: weaken pabi_weak $_wpps_s failed (Windows param ptr slot)" >&2
              exit 1
            fi
            _G05_LINK_WINNERS="$_G05_LINK_WINNERS $_wpps_s=$_PABI_WIN_PPS"
          done
        fi
        # w1584: weaken egg slice-reent sum so the overlay first-wins.
        # PLATFORM: WINDOWS.
        if [ -n "$_PABI_REENT_SUM" ]; then
          "$_oc" --weaken-symbol=glue_sum_block_slice_reent_dc_bytes_c \
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
# w1607: strong 65536 label/patch layout. The thin's getters are
# file-private and the thin is not linked, so the weak copies still
# return the 16384 offsets. sizeof on this host is already the 64k
# end. The egg also inlines e_machine/reloc_type at the 16384
# offsets (add $17432600 / $17432604, six stores each, two mega
# copies). Getter-only link reads a zero slot and ld reports EM: 0.
# Patch those adds on a copy. Do not rebuild the egg and do not
# edit the original .o. Linux only: Darwin and Windows sizeof is
# not that end. Does not change pipe_elf_table_cap.
# PLATFORM: LINUX
_PABI_ELF_LAYOUT_64K=""
case "$UNAME_S" in
  Linux)
    if [ "${XLANG_ELF_LAYOUT_64K_OVERLAY:-1}" = "1" ]; then
      _g05_pure_overlay src/runtime_pipeline_abi_elf_layout_64k_thin.x \
        build_asm/selfhost_pabi/elf_layout_64k.o \
        pipe_elf_off_num_labels
      _PABI_ELF_LAYOUT_64K="$_G05_PO_OUT"
      if [ "$_PABI_LINK_O" = "build_asm/selfhost_pabi/pabi_alias.o" ]; then
        _pabi_elf64=build_asm/selfhost_pabi/pabi_alias.elf64k.o
        # stdout of this script is eval'd by g05; keep tool chatter on stderr.
        if ! python3 scripts/patch_pabi_elf_emachine_64k.py \
            "$_PABI_LINK_O" "$_pabi_elf64" >&2; then
          echo "g05_relink_env: elf 64k egg patch failed" >&2
          exit 1
        fi
        _PABI_LINK_O="$_pabi_elf64"
      fi
    fi
    ;;
esac
# w1624: the egg skip_heavy body does not call asm_env_force_full_bodies.
# Twelve PLT32 sites inside that object call the symbol. Alias the bytes
# and undefine the link name in a copy, then link the thin prefix ahead
# of that copy. FORCE unset calls the egg body. Do not edit pabi_alias.o
# or the 64k copy in place, and do not rebuild the egg. Darwin and
# Windows keep their w1549 image. PLATFORM: LINUX.
_PABI_SKIP_HEAVY=""
case "$UNAME_S" in
  Linux)
    if [ "${XLANG_SKIP_HEAVY_FORCE_OVERLAY:-1}" = "1" ]; then
      case "$_PABI_LINK_O" in
        build_asm/selfhost_pabi/pabi_alias.o|build_asm/selfhost_pabi/pabi_alias.elf64k.o)
          _g05_pure_overlay src/runtime_pipeline_abi_skip_heavy_force_thin.x \
            build_asm/selfhost_pabi/skip_heavy_force.o \
            asm_skip_heavy_module_func_body
          if [ -n "$_G05_PO_OUT" ]; then
            if ! nm "$_G05_PO_OUT" 2>/dev/null | grep -q ' T asm_env_force_full_bodies$'; then
              echo "g05_relink_env: skip_heavy thin missing asm_env_force_full_bodies" >&2
              exit 1
            fi
            _skip_dst=build_asm/selfhost_pabi/pabi_alias.skip_egg.o
            if ! python3 scripts/g05_pabi_skip_heavy_egg_alias.py \
                "$_PABI_LINK_O" "$_skip_dst"; then
              echo "g05_relink_env: skip_heavy egg alias failed" >&2
              exit 1
            fi
            _PABI_LINK_O="$_skip_dst"
            _PABI_SKIP_HEAVY="$_G05_PO_OUT"
          fi
          ;;
      esac
    fi
    ;;
esac
# w1609: cap residual product faces (host-call temps, slice-let reent,
# pipeline scratch buffers, bounded-loop helpers) are defined only in
# seeds/codegen_cap_residual.from_x.c, which assemble pastes into
# codegen_gen.c. A pure-asm codegen_x.o leaves them undefined. Link the
# same seed as its own object after codegen_x.o. With a host-cc
# codegen_x.o the symbols are duplicated and the earlier copy wins.
# Linux and Darwin (w2060: Darwin's codegen_x.o is pure asm since 7.2, so
# its g1 link had these names undefined). Windows still links the w1549
# image, whose codegen_x.o already contains the paste. Does not rebuild the
# pabi egg and does not set XLANG_CODEGEN_FROM_X.
# PLATFORM: LINUX|MACOS
_CODEGEN_CAP_RESIDUAL=""
case "$UNAME_S" in
  Linux|Darwin)
    if [ "${XLANG_CODEGEN_CAP_RESIDUAL:-1}" = "1" ]; then
      mkdir -p build_asm/selfhost_pabi
      _cap_o=build_asm/selfhost_pabi/codegen_cap_residual.o
      if ! $G05_CC $_BASE_CFLAGS \
          -DXLANG_USE_X_DRIVER -DXLANG_USE_X_PIPELINE \
          -DXLANG_USE_X_TYPECK -DXLANG_USE_X_CODEGEN \
          -c -o "$_cap_o" seeds/codegen_cap_residual_tu.c; then
        echo "g05_relink_env: codegen cap residual compile failed" >&2
        exit 1
      fi
      _CODEGEN_CAP_RESIDUAL="$_cap_o"
    fi
    ;;
esac
# w1612: BSS slot accessors and typeck_set_allow_legacy_extern_calls are
# defined in seeds/typeck_cap_residual.from_x.c (slot prefix) and
# seeds/typeck_allow_legacy.from_x.c. A pure-asm typeck_x.o leaves them
# undefined. Link the same seeds as one object immediately after
# typeck_x.o. With a host-cc typeck_x.o the symbols are duplicated and
# the earlier copy wins. Linux and Darwin (w2060: Darwin's typeck_x.o is
# pure asm since 7.2 and its g1 link missed typeck_get_allow_legacy_extern_calls).
# Windows still links the w1549 image, whose typeck_x.o already contains
# the paste. Does not rebuild the pabi egg and does not set XLANG_TYPECK_FROM_X.
# PLATFORM: LINUX|MACOS
# w2055: when the CTFE object below is linked it already defines the slot
# prefix (seeds/typeck_ctfe_tu.c includes the whole residual). Then this
# object is compiled with TYPECK_ALLOW_LEGACY_ONLY and carries only the
# allow-legacy helpers, so no name is defined twice. Darwin ld64 rejects
# duplicate definitions; Linux only tolerated them via
# --allow-multiple-definition. Same number of cc compiles either way.
_TYPECK_CTFE_WANT=0
case "$UNAME_S" in
  Linux|Darwin)
    if [ "${XLANG_TYPECK_CTFE:-1}" = "1" ] && \
        sh scripts/g05_ensure_relink_prereqs.sh --typeck-x-pure-asm-kept >/dev/null; then
      _TYPECK_CTFE_WANT=1
    fi
    ;;
esac
_TYPECK_CAP_RESIDUAL=""
case "$UNAME_S" in
  Linux|Darwin)
    if [ "${XLANG_TYPECK_CAP_RESIDUAL:-1}" = "1" ]; then
      mkdir -p build_asm/selfhost_pabi
      _tcap_o=build_asm/selfhost_pabi/typeck_cap_residual.o
      _tcap_def=""
      if [ "$_TYPECK_CTFE_WANT" = "1" ]; then
        _tcap_def="-DTYPECK_ALLOW_LEGACY_ONLY=1"
      fi
      if ! $G05_CC $_BASE_CFLAGS \
          -DXLANG_USE_X_DRIVER -DXLANG_USE_X_PIPELINE \
          -DXLANG_USE_X_TYPECK -DXLANG_USE_X_CODEGEN $_tcap_def \
          -c -o "$_tcap_o" seeds/typeck_cap_residual_tu.c; then
        echo "g05_relink_env: typeck cap residual compile failed" >&2
        exit 1
      fi
      _TYPECK_CAP_RESIDUAL="$_tcap_o"
    fi
    ;;
esac
# w1622: the seven CTFE faces live in the same residual seed, below the
# SLOTS_ONLY cut. The slot object above does not define them. Host-cc
# typeck_x.o does, because assemble pastes the seed into typeck_gen.c.
# A pure-asm typeck_x.o does not. Compile seeds/typeck_ctfe_tu.c only when
# compiler/typeck_x.pure_asm matches typeck_x.o, and place that object
# after the allow-legacy object (the slot prefix comes only from here).
# No stamp: do not compile it and do not put it on the link. The early
# ensure flag exits before the crash-log wipe. Its stdout is discarded
# so this script's eval output stays assignment-only. Does not set
# XLANG_TYPECK_FROM_X and does not edit the residual seed (a seed edit
# would make the next ensure splice and host-cc typeck_gen.c).
# PLATFORM: LINUX|MACOS — w2060: Darwin has the pure-asm typeck stamp since
# 7.2 and its g1 link missed the typeck_fold_* faces. Windows has no stamp.
_TYPECK_CTFE=""
case "$UNAME_S" in
  Linux|Darwin)
    if [ "$_TYPECK_CTFE_WANT" = "1" ]; then
      mkdir -p build_asm/selfhost_pabi
      _tctfe_h=build_asm/selfhost_pabi/typeck_expr_layout.h
      _tctfe_o=build_asm/selfhost_pabi/typeck_ctfe.o
      if ! python3 scripts/assemble_typeck_gen_from_x.py \
          --write-expr-layout typeck_gen.c --layout-out "$_tctfe_h"; then
        echo "g05_relink_env: typeck expr layout slice failed" >&2
        exit 1
      fi
      if ! $G05_CC $_BASE_CFLAGS \
          -DXLANG_USE_X_DRIVER -DXLANG_USE_X_PIPELINE \
          -DXLANG_USE_X_TYPECK -DXLANG_USE_X_CODEGEN \
          -Ibuild_asm/selfhost_pabi \
          -c -o "$_tctfe_o" seeds/typeck_ctfe_tu.c; then
        echo "g05_relink_env: typeck CTFE compile failed" >&2
        exit 1
      fi
      _TYPECK_CTFE="$_tctfe_o"
    fi
    ;;
esac
_X_FRONTEND="parser_x.o lexer_x.o typeck_x.o ${_TYPECK_CAP_RESIDUAL} ${_TYPECK_CTFE} codegen_x.o x_frontend_link_alias.o"
_DRIVER_SEED_OBJS="$_PABI_ELF_LAYOUT_64K $_PABI_INDEX_BASE_FIELD $_PABI_RETURN_SRET $_PABI_MODLET_FLOAT_IMM $_PABI_STRUCT_LIT_FIELD $_PABI_F32_DEMOTE $_PABI_ASM_EXPR $_PABI_ASSIGN_VAR $_PABI_MODLET_STRPOOL $_PABI_BINOP_WIDE $_PABI_PARSER_MEGA_ALLOW $_PABI_PARSER_FORCE_STUB $_PABI_PARSER_THIN_DELEGATE $_PABI_ELF_UNDEF_CAP $_PABI_NAMED_SIZE $_PABI_WIN_PARAM_HOME $_PABI_TAIL_JMP_OFF $_PABI_CALL_SPILL $_PABI_FRAME_SIZE $_PABI_REENT_NOCAP $_PABI_REENT_SUM $_PABI_SELFHOST $_WIN_ASSIGN_OVERRIDES $_PABI_WPO_THIN $_PABI_WPO_CAP $_PABI_RELOC_TYPED $_PABI_DATA_LEN $_PABI_CONST_LIT $_MAIN_LINK_O src/runtime_io_abi.o src/runtime_link_abi.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/diag.o $_PANIC_LINK_O $_PABI_SKIP_HEAVY $_PABI_LINK_O $_DRIVER_SEED_RUNTIME_O $_RT_SEED_SLICE_OBJS runtime_process_argv.o src/driver/fmt_check_cmd_driver.o src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o $_LEXER_LINK_O $_AST_LINK_O $_X_FRONTEND $_CODEGEN_CAP_RESIDUAL $_DRIVER_SEED_SUPPORT src/x_seed_bridge.o $_SEED_LINK_COMPAT src/token_typekind_tag_tables.o"

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
echo "G05_LINK_WINNERS='$(_sq "${_G05_LINK_WINNERS# }")'"
