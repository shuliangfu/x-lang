#!/usr/bin/env bash
# g05_relink_xlang.sh — G-05：最终链接 xlang 的唯一 shell 实现
#
# 由 g05_prepare_and_relink.sh 在依赖齐备后调用（G05_* 来自 g05_relink_env.sh）。
# 目的：最终链接 + 同步 xlang-c/bootstrap_xlangc 仅在本脚本（G-05 100% 产品路径）。
#
# wave773 · 11.1.4 pure-ld (G.7 有则补全 pure_ld_shared.sh):
#   When freestanding-eligible (Darwin / Linux x86_64 crt0), pure-ld first.
# wave774 · 11.1.4 endgame slice: NO silent CC fallback after pure-ld fail.
#   · freestanding-eligible + not FORCE_CC → pure-ld required (hard fail on miss)
#   · FORCE_CC=1 or host ineligible → named $CC $CFLAGS -o residual only
#   Object list authority remains g05_relink_env (no second .o inventory).
#
# 环境变量（g05_relink_env.sh 注入）：
#   G05_CC          编译器（默认 cc）— residual path
#   G05_CFLAGS      完整 cflags + link flags（含 -e _start 等）— residual path
#   G05_OUT         输出二进制名（默认 xlang）
#   G05_OBJS        全部 .o 参数（空格分隔）
#   G05_XLANG_C      xlang-c 同步名（默认 xlang-c）
#   G05_BOOTSTRAP   bootstrap_xlangc 同步名（默认 bootstrap_xlangc）
#   G05_SYNC_ASM=1  同时 cp 到 xlang_asm（可选；prepare 亦可在外层做）
#
# Env overrides:
#   XLANG_G05_FORCE_CC=1 / XLANG_SEED_LINK_FORCE_CC=1 — skip pure-ld; CC residual only
#
# 用法（compiler/ 目录）：
#   eval "$(sh scripts/g05_relink_env.sh)" && sh scripts/g05_relink_xlang.sh
#
# PLATFORM: SHARED — pure-ld required when freestanding; Windows stays CC residual.
# PLATFORM: LINUX — nostdlib product drops -lc (static freestanding); libc cold uses -lc.
# PLATFORM: MACOS — pure_ld_shared syslibroot + -lSystem.
# Wave: 773 pure-ld prefer · 774 drop silent CC fallback.

set -e
cd "$(dirname "$0")/.."

# knife256/10.2: install GOOD lex peel (fill→next_into + hard peek +20/+24)
# Demote peel's source_data/length so nopark (real lexer globals) wins.
if [ -s /tmp/p9a_lex_bridge_peel_GOOD.o ]; then
  mkdir -p build_asm/selfhost_pabi
  cp -f /tmp/p9a_lex_bridge_peel_GOOD.o build_asm/selfhost_pabi/p9a_lex_bridge_peel.o
  echo "g05_relink_xlang: installed GOOD p9a_lex_bridge_peel.o" >&2
  _oc="${LLVM_OBJCOPY:-/opt/homebrew/opt/llvm/bin/llvm-objcopy}"
  _peel=build_asm/selfhost_pabi/p9a_lex_bridge_peel.o
  if [ -x "$_oc" ] && [ -s "$_peel" ]; then
    for _s in _parser_asm_lex_source_data_c _parser_asm_lex_source_length_c; do
      if nm -gU "$_peel" 2>/dev/null | awk '{print $3}' | grep -qxF "$_s"; then
        "$_oc" --redefine-sym="${_s}=${_s}__peel_dup" "$_peel" 2>/dev/null \
          && echo "g05_relink_xlang: demoted peel $_s (nopark wins)" >&2 || true
      fi
    done
  fi
fi

# w1484: refuse to link when ensure / relink_env logged a g05 pure-asm crash
# (a retry or cc fallback may have hidden it). PLATFORM: SHARED.
# knife256/10.2: overlay-missing = Cap prior kept, not a product crash.
if [ -s build_asm/g05_xasm_crash.log ]; then
  _crash_hard=$(grep -v 'overlay-missing' build_asm/g05_xasm_crash.log || true)
  if [ -n "$_crash_hard" ]; then
    echo "g05_relink_xlang: g05 pure-asm compiler crashed (build_asm/g05_xasm_crash.log):" >&2
    printf '%s\n' "$_crash_hard" | sed 's/^/  /' >&2
    if [ "${XLANG_G05_XASM_ALLOW_CRASH:-0}" != "1" ]; then
      echo "  fix the product and rm the log, or XLANG_G05_XASM_ALLOW_CRASH=1 to only warn" >&2
      exit 1
    fi
  fi
fi

CC="${G05_CC:-cc}"
CFLAGS="${G05_CFLAGS:-}"

# Stage 12.2.1: XLANG_FORBID_HOST_CC gate (no-op when flag unset; zero impact
# on normal builds). When XLANG_FORBID_HOST_CC=1, replaces $CC with a wrapper
# that logs and blocks all host-CC invocations — builds the zero-CC problem map.
# PLATFORM: SHARED.
. "$(dirname "$0")/forbid_host_cc.sh"

OUT="${G05_OUT:-xlang}"
OBJS="${G05_OBJS:-}"
# w2055: "sym=object" pairs whose strong sidecar must beat a weakened pabi
# copy. Darwin pure-ld writes a link map and the check below reads it.
WINNERS="${G05_LINK_WINNERS:-}"
XLANG_C="${G05_XLANG_C:-xlang-c}"
BOOTSTRAP="${G05_BOOTSTRAP:-bootstrap_xlangc}"

if [ -z "$OBJS" ]; then
  echo "g05_relink_xlang: G05_OBJS empty (eval g05_relink_env.sh first)" >&2
  exit 1
fi

# G.7: pure-ld helpers — single authority (shared with cold seed link).
# shellcheck disable=SC1091
. scripts/pure_ld_shared.sh

# knife256/10.2: g05_ensure re-runs darwin_phase1_hollow_fill AFTER g05_relink_env
# w211 weaken. Egg/mega refresh can restore strong T on pabi → Darwin ld dup vs
# register_tl_const.o. Re-weaken on the live pabi just before pure-ld.
# note743y.6.20: same for modlet_float_imm / modlet_strpool overlays — tip-cold
# Cap tip rebuilds src/runtime_pipeline_abi.o with strong T of
# pipe_modlet_scalar_init_common_imm and pipe_modlet_bake_string_lit_elem_to_data
# while overlays also export them → ld duplicate (primary L4 FAIL).
# PLATFORM: MACOS · no FORCE_CC.
if [ "$(uname -s 2>/dev/null)" = "Darwin" ] \
  && [ -s src/runtime_pipeline_abi.o ]; then
  _g05_oc=""
  if [ -x /opt/homebrew/opt/llvm/bin/llvm-objcopy ]; then
    _g05_oc=/opt/homebrew/opt/llvm/bin/llvm-objcopy
  elif [ -x /usr/local/opt/llvm/bin/llvm-objcopy ]; then
    _g05_oc=/usr/local/opt/llvm/bin/llvm-objcopy
  elif command -v llvm-objcopy >/dev/null 2>&1; then
    _g05_oc=$(command -v llvm-objcopy)
  fi
  if [ -n "$_g05_oc" ]; then
    if printf '%s' " $OBJS " | grep -Eq '(^|[[:space:]/])register_tl_const\.o([[:space:]]|$)' \
      && nm -gU src/runtime_pipeline_abi.o 2>/dev/null \
           | grep -q ' T _pipeline_asm_register_module_top_level_lets_c$'; then
      "$_g05_oc" --weaken-symbol=_pipeline_asm_register_module_top_level_lets_c \
        src/runtime_pipeline_abi.o 2>/dev/null \
        && echo "g05_relink_xlang: pre-ld weaken pabi register_tl (overlay wins)" >&2 \
        || true
    fi
    # note743y.6.20: weaken mega copies so Cap tip overlays first-win.
    if printf '%s' " $OBJS " | grep -Eq '(^|[[:space:]/])modlet_float_imm\.o([[:space:]]|$)' \
      && nm -gU src/runtime_pipeline_abi.o 2>/dev/null \
           | grep -q ' T _pipe_modlet_scalar_init_common_imm$'; then
      "$_g05_oc" --weaken-symbol=_pipe_modlet_scalar_init_common_imm \
        src/runtime_pipeline_abi.o 2>/dev/null \
        && echo "g05_relink_xlang: pre-ld weaken pabi scalar_init_common_imm (float_imm wins)" >&2 \
        || true
    fi
    if printf '%s' " $OBJS " | grep -Eq '(^|[[:space:]/])modlet_strpool\.o([[:space:]]|$)' \
      && nm -gU src/runtime_pipeline_abi.o 2>/dev/null \
           | grep -q ' T _pipe_modlet_bake_string_lit_elem_to_data$'; then
      "$_g05_oc" --weaken-symbol=_pipe_modlet_bake_string_lit_elem_to_data \
        src/runtime_pipeline_abi.o 2>/dev/null \
        && echo "g05_relink_xlang: pre-ld weaken pabi bake_string_lit (strpool wins)" >&2 \
        || true
    fi
    # note743y.6.23: Cap tip G05 lists struct_lit_field.o + pabi_weak; both
    # define glue_struct_lit_field_store_sz as T. Windows weakens pabi_weak
    # in g05_relink_env; Darwin Cap tip must demote pabi_weak pre-ld (Apple
    # ld rejects duplicate strong). Same for w211 vs const_lit_fold.
    # PLATFORM: MACOS Cap tip / tip-cold.
    if printf '%s' " $OBJS " | grep -Eq '(^|[[:space:]/])struct_lit_field\.o([[:space:]]|$)' \
      && [ -s build_asm/selfhost_pabi/pabi_weak.o ] \
      && nm build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null \
           | grep -q ' T _glue_struct_lit_field_store_sz$'; then
      "$_g05_oc" --redefine-sym=_glue_struct_lit_field_store_sz=_glue_struct_lit_field_store_sz__demoted \
        build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null \
        && echo "g05_relink_xlang: note743y.6.23 pre-ld demote pabi_weak struct_lit_field_store_sz" >&2 \
        || true
    fi
    if printf '%s' " $OBJS " | grep -Eq '(^|[[:space:]/])const_lit_fold\.o([[:space:]]|$)' \
      && [ -s build_asm/selfhost_pabi/pabi_weak.o ] \
      && nm build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null \
           | grep -q ' T _w211_fold_const_expr_i32$'; then
      "$_g05_oc" --redefine-sym=_w211_fold_const_expr_i32=_w211_fold_const_expr_i32__demoted \
        build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null \
        && echo "g05_relink_xlang: note743y.6.23 pre-ld demote pabi_weak w211_fold" >&2 \
        || true
    fi
    # note743y.6.23: tip-cold opt/si Abort — mega egg
    # pipeline_asm_emit_var_field_access_elf_c (frame 0x2a0) stack-chk fails
    # on core/option. Cap tip / field_cap_residual_load (frame 0xd00) is the
    # known-good body. Darwin llvm-objcopy --weaken often leaves T; demote
    # mega (and pabi_weak if T) via redefine-sym so field_cap is sole strong.
    # PLATFORM: MACOS tip cold.
    if printf '%s' " $OBJS " | grep -Eq '(^|[[:space:]/])field_cap_residual_load\.o([[:space:]]|$)' \
      && nm -gU src/runtime_pipeline_abi.o 2>/dev/null \
           | grep -q ' T _pipeline_asm_emit_var_field_access_elf_c$'; then
      "$_g05_oc" --redefine-sym=_pipeline_asm_emit_var_field_access_elf_c=_pipeline_asm_emit_var_field_access_elf_c__demoted \
        src/runtime_pipeline_abi.o 2>/dev/null \
        && echo "g05_relink_xlang: note743y.6.23 pre-ld demote pabi var_field_access (field_cap wins)" >&2 \
        || true
    fi
    if printf '%s' " $OBJS " | grep -Eq '(^|[[:space:]/])field_cap_residual_load\.o([[:space:]]|$)' \
      && [ -s build_asm/selfhost_pabi/pabi_weak.o ] \
      && nm build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null \
           | grep -q ' T _pipeline_asm_emit_var_field_access_elf_c$'; then
      "$_g05_oc" --redefine-sym=_pipeline_asm_emit_var_field_access_elf_c=_pipeline_asm_emit_var_field_access_elf_c__demoted \
        build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null \
        && echo "g05_relink_xlang: note743y.6.23 pre-ld demote pabi_weak var_field_access (field_cap wins)" >&2 \
        || true
    fi
    # note743y.6.23: peel helpers_thin first-wins transparent_value over pabi_weak.
    # PLATFORM: MACOS Cap tip.
    if printf '%s' " $OBJS " | grep -Eq '(^|[[:space:]/])binop_block_peel_helpers_thin\.o([[:space:]]|$)' \
      && [ -s build_asm/selfhost_pabi/pabi_weak.o ] \
      && nm build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null \
           | grep -q ' T _glue_expr_block_transparent_value_ref_at$'; then
      "$_g05_oc" --redefine-sym=_glue_expr_block_transparent_value_ref_at=_glue_expr_block_transparent_value_ref_at__pabi_weak_dup \
        build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null \
        && echo "g05_relink_xlang: note743y.6.23 pre-ld demote pabi_weak transparent_value (helpers wins)" >&2 \
        || true
    fi
    # 10.22: slice_length_to_rbx thin first-wins TYPE_SLICE dual-GP length.
    if printf '%s' " $OBJS " | grep -Eq '(^|[[:space:]/])slice_length_to_rbx_a64\.o([[:space:]]|$)' \
      && [ -s build_asm/selfhost_pabi/pabi_weak.o ] \
      && nm build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null \
           | grep -q ' T _glue_emit_slice_length_to_rbx_elf_c$'; then
      "$_g05_oc" --redefine-sym=_glue_emit_slice_length_to_rbx_elf_c=_glue_emit_slice_length_to_rbx_elf_c__demoted \
        build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null \
        && echo "g05_relink_xlang: 10.22 pre-ld demote pabi_weak slice_length (thin wins)" >&2 \
        || true
    fi
    # 10.22: STRUCT_LIT.field→[]T — slice_modlet calls _prev; demote egg T/W.
    if printf '%s' " $OBJS " | grep -Eq '(^|[[:space:]/])slice_modlet(_a64)?\.o([[:space:]]|$)'; then
      for _sm_pw in build_asm/selfhost_pabi/pabi_weak.o \
                    build_asm/selfhost_pabi/pabi_alias.skip_egg.o \
                    build_asm/selfhost_pabi/pabi.o \
                    build_asm/selfhost_pabi/cap_tip_pabi_sym_fill.o \
                    src/runtime_pipeline_abi.o; do
        [ -s "$_sm_pw" ] || continue
        if nm "$_sm_pw" 2>/dev/null | grep -Eq ' [TW] _glue_emit_slice_from_array_let_init_elf_c$'; then
          "$_g05_oc" --redefine-sym=_glue_emit_slice_from_array_let_init_elf_c=_glue_emit_slice_from_array_let_init_elf_c_prev \
            "$_sm_pw" 2>/dev/null \
            && echo "g05_relink_xlang: 10.22 pre-ld demote $_sm_pw slice_modlet→_prev" >&2 \
            || true
        fi
      done
      unset _sm_pw
      # Cap tip G05_OBJS often omits runtime_pipeline_abi.o — demote then leaves
      # no _prev in the link. Stub returns -1 (same as prior Cap tip CG002).
      # Drop any prior stub first so demoted egg W/_prev is never doubled.
      _sm_objs_new=""
      for _sm_o in $OBJS; do
        case "$_sm_o" in
          *glue_slice_from_array_let_init_prev_stub*.o) continue ;;
        esac
        _sm_objs_new="${_sm_objs_new:+$_sm_objs_new }$_sm_o"
      done
      OBJS="$_sm_objs_new"
      unset _sm_objs_new
      _sm_has_prev=0
      for _sm_o in $OBJS; do
        [ -s "$_sm_o" ] || continue
        if nm "$_sm_o" 2>/dev/null | grep -Eq ' [TW] _glue_emit_slice_from_array_let_init_elf_c_prev$'; then
          _sm_has_prev=1
          break
        fi
      done
      if [ "$_sm_has_prev" != "1" ]; then
        _sm_stub=build_asm/selfhost_pabi/glue_slice_from_array_let_init_prev_stub_a64.o
        mkdir -p build_asm/selfhost_pabi
        clang -c -o "$_sm_stub" src/asm/glue_slice_from_array_let_init_prev_stub_a64.s \
          || { echo "g05_relink_xlang: ERROR 10.22 _prev stub assemble failed" >&2; exit 1; }
        OBJS="$_sm_stub $OBJS"
        echo "g05_relink_xlang: 10.22 prepended Cap tip _prev stub (-1)" >&2
      else
        echo "g05_relink_xlang: 10.22 _prev present (egg demote); skip stub" >&2
      fi
      unset _sm_has_prev _sm_stub _sm_o
    fi

    # 10.22: take_field_slice — weaken egg reverse_infer so soft T first-wins.
    # Do NOT redefine-sym (rewrites call sites inside typeck_x to the dead name).
    if printf "%s" " $OBJS " | grep -Eq "(^|[[:space:]/])typeck_field_reverse_infer_soft\.o([[:space:]]|$)"; then
      for _ri_pw in build_asm/selfhost_pabi/typeck_x.cap_repr_weak.o \
                    build_asm/selfhost_pabi/typeck_x.cap_repr_weak.binop_cmp_peel.o \
                    typeck_x.o \
                    build_asm/selfhost_pabi/typeck_x_binop_cmp_peel.o; do
        [ -s "$_ri_pw" ] || continue
        if nm "$_ri_pw" 2>/dev/null | grep -Eq " T _typeck_field_reverse_infer_base_type$"; then
          "$_g05_oc" --weaken-symbol=_typeck_field_reverse_infer_base_type \
            "$_ri_pw" 2>/dev/null \
            && echo "g05_relink_xlang: 10.22 weaken $_ri_pw reverse_infer (soft wins)" >&2 \
            || true
        fi
      done
      unset _ri_pw
    fi
    if printf "%s" " $OBJS " | grep -Eq "(^|[[:space:]/])call_arg_struct_lit_field\.o([[:space:]]|$)"; then
      # Extract egg body as _prev (redefine on a COPY). Weaken egg definition so
      # call sites still name glue_emit_one_call_arg_elf_c and bind to thin T.
      _ca_prev=build_asm/selfhost_pabi/call_arg_emit_one_prev_a64.o
      _ca_src_o=""
      for _ca_pw in src/asm/backend_call_dispatch.o \
                    build_asm/selfhost_pabi/pabi_weak.o \
                    build_asm/selfhost_pabi/cap_tip_pabi_sym_fill.o \
                    src/runtime_pipeline_abi.o; do
        [ -s "$_ca_pw" ] || continue
        if nm "$_ca_pw" 2>/dev/null | grep -Eq " [TW] _glue_emit_one_call_arg_elf_c$"; then
          _ca_src_o="$_ca_pw"
          break
        fi
      done
      if [ -n "$_ca_src_o" ]; then
        _ca_exp="/tmp/g05_call_arg_prev_$$.exp"
        printf "%s\n" "_glue_emit_one_call_arg_elf_c" > "$_ca_exp"
        if ld -r -o "$_ca_prev" -exported_symbols_list "$_ca_exp" "$_ca_src_o" 2>/dev/null; then
          "$_g05_oc" --redefine-sym=_glue_emit_one_call_arg_elf_c=_glue_emit_one_call_arg_elf_c_prev \
            "$_ca_prev" 2>/dev/null \
            && echo "g05_relink_xlang: 10.22 call_arg _prev ld-r extract from $_ca_src_o" >&2 \
            || rm -f "$_ca_prev"
        else
          rm -f "$_ca_prev"
        fi
        rm -f "$_ca_exp"
        for _ca_pw in src/asm/backend_call_dispatch.o \
                      build_asm/selfhost_pabi/pabi_weak.o \
                      build_asm/selfhost_pabi/cap_tip_pabi_sym_fill.o \
                      src/runtime_pipeline_abi.o; do
          [ -s "$_ca_pw" ] || continue
          if nm "$_ca_pw" 2>/dev/null | grep -Eq " T _glue_emit_one_call_arg_elf_c$"; then
            "$_g05_oc" --weaken-symbol=_glue_emit_one_call_arg_elf_c "$_ca_pw" 2>/dev/null \
              && echo "g05_relink_xlang: 10.22 weaken $_ca_pw call_arg (thin wins)" >&2 \
              || true
          fi
        done
        if [ -s "$_ca_prev" ] && nm "$_ca_prev" 2>/dev/null | grep -Eq " [TW] _glue_emit_one_call_arg_elf_c_prev$"; then
          OBJS="$_ca_prev $OBJS"
          echo "g05_relink_xlang: 10.22 prepended call_arg _prev extract" >&2
        fi
      fi
      unset _ca_prev _ca_src_o _ca_pw
    fi

    # 10.22: when ast_to_elf_thin is in OBJS, demote archive_leaf face only
    # (keep mega_body on leaf). Thin skips reset_data when data_len>0 (cims).
    # PLATFORM: MACOS Cap tip.
    if printf "%s" " $OBJS " | grep -Eq "(^|[[:space:]/])ast_to_elf_thin_a64\.o([[:space:]]|$)" \
      && [ -s build_asm/selfhost_pabi/archive_leaf_extract.o ]; then
      if nm -gU build_asm/selfhost_pabi/archive_leaf_extract.o 2>/dev/null \
           | grep -q " T _pipeline_backend_asm_codegen_ast_to_elf_c$"; then
        "$_g05_oc" --redefine-sym=_pipeline_backend_asm_codegen_ast_to_elf_c=_pipeline_backend_asm_codegen_ast_to_elf_c__demoted \
          build_asm/selfhost_pabi/archive_leaf_extract.o 2>/dev/null \
          && echo "g05_relink_xlang: 10.22 demote archive_leaf ast_to_elf_c (thin wins)" >&2 \
          || true
      fi
    fi

    # note743y.6.23: Cap tip archive_leaf owns backend_asm_codegen (+mega_body).
    # ensure may rebuild mega after env demote → pure-ld duplicate mega_body.
    # pre-ld demote both T on runtime_pipeline_abi.o. PLATFORM: MACOS tip cold.
    if printf '%s' " $OBJS " | grep -Eq '(^|[[:space:]/])archive_leaf_extract\.o([[:space:]]|$)'; then
      _al_demote=""
      if nm -gU src/runtime_pipeline_abi.o 2>/dev/null \
           | grep -q ' T _pipeline_backend_asm_codegen_ast_to_elf_c\$'; then
        _al_demote="$_al_demote --redefine-sym=_pipeline_backend_asm_codegen_ast_to_elf_c=_pipeline_backend_asm_codegen_ast_to_elf_c__demoted"
      fi
      if nm -gU src/runtime_pipeline_abi.o 2>/dev/null \
           | grep -q ' T _pipeline_backend_asm_codegen_ast_to_elf_mega_body_c\$'; then
        _al_demote="$_al_demote --redefine-sym=_pipeline_backend_asm_codegen_ast_to_elf_mega_body_c=_pipeline_backend_asm_codegen_ast_to_elf_mega_body_c__demoted"
      fi
      if [ -n "$_al_demote" ]; then
        # shellcheck disable=SC2086
        "$_g05_oc" $_al_demote src/runtime_pipeline_abi.o 2>/dev/null \
          && echo "g05_relink_xlang: note743y.6.23 pre-ld demote mega backend_asm_codegen (+mega_body; archive_leaf wins)" >&2 \
          || true
      fi
      unset _al_demote
    fi
    # note743y.6.23: tip fat seed_mega on asm_backend_partial never calls
    # pipeline_; demote when Cap tip front tramp is in OBJS so pure-ld first-wins.
    # PLATFORM: MACOS tip cold.
    if printf '%s' " $OBJS " | grep -Eq '(^|[[:space:]/])backend_codegen_to_elf_tramp_a64\.o([[:space:]]|$)' \
      && [ -s build_asm/seed_host/asm_backend_partial.o ]; then
      _sm_demote=""
      for _sm_sy in _backend_asm_codegen_ast_to_elf_seed_mega _backend_asm_codegen_ast_to_elf; do
        if nm -gU build_asm/seed_host/asm_backend_partial.o 2>/dev/null \
             | grep -q " T ${_sm_sy}\$"; then
          _sm_demote="$_sm_demote --redefine-sym=${_sm_sy}=${_sm_sy}__demoted"
        fi
      done
      if [ -n "$_sm_demote" ]; then
        # shellcheck disable=SC2086
        "$_g05_oc" $_sm_demote build_asm/seed_host/asm_backend_partial.o 2>/dev/null \
          && echo "g05_relink_xlang: note743y.6.23 pre-ld demote fat seed_mega (tramp wins)" >&2 \
          || true
      fi
      unset _sm_demote _sm_sy
    fi
  fi
  unset _g05_oc
fi
# 10.22: Linux tip peel — slice_modlet calls _prev; demote egg W on alias.
# PLATFORM: LINUX tip peel. No FORCE_CC.
if [ "$(uname -s 2>/dev/null)" = "Linux" ]; then
  _g05_oc=""
  if command -v llvm-objcopy >/dev/null 2>&1; then
    _g05_oc=$(command -v llvm-objcopy)
  elif command -v objcopy >/dev/null 2>&1; then
    _g05_oc=$(command -v objcopy)
  fi
  if [ -n "$_g05_oc" ] \
    && printf '%s' " $OBJS " | grep -Eq '(^|[[:space:]/])slice_modlet(_a64)?\.o([[:space:]]|$)'; then
    for _sm_pw in build_asm/selfhost_pabi/pabi_alias.skip_egg.o \
                  build_asm/selfhost_pabi/pabi_weak.o \
                  build_asm/selfhost_pabi/pabi.o \
                  src/runtime_pipeline_abi.o; do
      [ -s "$_sm_pw" ] || continue
      if nm "$_sm_pw" 2>/dev/null | grep -Eq ' [TW] glue_emit_slice_from_array_let_init_elf_c$'; then
        "$_g05_oc" --redefine-sym=glue_emit_slice_from_array_let_init_elf_c=glue_emit_slice_from_array_let_init_elf_c_prev \
          "$_sm_pw" 2>/dev/null \
          && echo "g05_relink_xlang: 10.22 Linux demote $_sm_pw slice_modlet→_prev" >&2 \
          || true
      fi
    done
    unset _sm_pw
  fi
  # If egg demote missed / not in OBJS, still need _prev for slice_modlet.
  if printf '%s' " $OBJS " | grep -Eq '(^|[[:space:]/])slice_modlet(_a64)?\.o([[:space:]]|$)'; then
    _sm_objs_new=""
    for _sm_o in $OBJS; do
      case "$_sm_o" in
        *glue_slice_from_array_let_init_prev_stub*.o) continue ;;
      esac
      _sm_objs_new="${_sm_objs_new:+$_sm_objs_new }$_sm_o"
    done
    OBJS="$_sm_objs_new"
    unset _sm_objs_new
    _sm_has_prev=0
    for _sm_o in $OBJS; do
      [ -s "$_sm_o" ] || continue
      if nm "$_sm_o" 2>/dev/null | grep -Eq ' [TW] glue_emit_slice_from_array_let_init_elf_c_prev$'; then
        _sm_has_prev=1
        break
      fi
    done
    if [ "$_sm_has_prev" != "1" ]; then
      _sm_stub=build_asm/selfhost_pabi/glue_slice_from_array_let_init_prev_stub_x64.o
      mkdir -p build_asm/selfhost_pabi
      clang -c -o "$_sm_stub" src/asm/glue_slice_from_array_let_init_prev_stub_x64.s \
        || { echo "g05_relink_xlang: ERROR 10.22 Linux _prev stub assemble failed" >&2; exit 1; }
      OBJS="$_sm_stub $OBJS"
      echo "g05_relink_xlang: 10.22 prepended Linux _prev stub (-1)" >&2
    else
      echo "g05_relink_xlang: 10.22 Linux _prev present (egg demote); skip stub" >&2
    fi
    unset _sm_has_prev _sm_stub _sm_o
  fi
  # 10.22: take_field_slice — reverse_infer soft + call_arg thin (Linux ELF names).
  # --gc-sections drops tip-emitted call_arg soft unless -u forces the T.
  if [ -n "$_g05_oc" ] \
    && printf "%s" " $OBJS " | grep -Eq "(^|[[:space:]/])typeck_field_reverse_infer_soft\.o([[:space:]]|$)"; then
    for _ri_pw in build_asm/selfhost_pabi/typeck_x_ufcs_soft_retarget.o \
                  build_asm/selfhost_pabi/typeck_x_binop_cmp_peel.o \
                  typeck_x.o \
                  /tmp/typeck_peel_tfs.o; do
      [ -s "$_ri_pw" ] || continue
      if nm "$_ri_pw" 2>/dev/null | grep -Eq " [TW] typeck_field_reverse_infer_base_type$"; then
        "$_g05_oc" --weaken-symbol=typeck_field_reverse_infer_base_type "$_ri_pw" 2>/dev/null \
          && echo "g05_relink_xlang: 10.22 Linux weaken $_ri_pw reverse_infer (soft wins)" >&2 \
          || true
      fi
    done
    # Also scan OBJS for any other strong reverse_infer (tip peel blobs)
    for _ri_o in $OBJS; do
      case "$(basename "$_ri_o")" in
        typeck_field_reverse_infer_soft.o) continue ;;
      esac
      [ -s "$_ri_o" ] || continue
      if nm "$_ri_o" 2>/dev/null | grep -Eq " T typeck_field_reverse_infer_base_type$"; then
        "$_g05_oc" --weaken-symbol=typeck_field_reverse_infer_base_type "$_ri_o" 2>/dev/null \
          && echo "g05_relink_xlang: 10.22 Linux weaken $_ri_o reverse_infer T→W" >&2 \
          || true
      fi
    done
    unset _ri_pw _ri_o
    export XLANG_G05_LINUX_FORCE_U_REVERSE_INFER=1
  fi
  if [ -n "$_g05_oc" ] \
    && printf "%s" " $OBJS " | grep -Eq "(^|[[:space:]/])call_arg_struct_lit_field\.o([[:space:]]|$)"; then
    _ca_prev=build_asm/selfhost_pabi/backend_call_dispatch_ca_prev.o
    _ca_src_o=""
    for _ca_pw in src/asm/backend_call_dispatch.o \
                  build_asm/selfhost_pabi/pabi_weak.o \
                  src/runtime_pipeline_abi.o; do
      [ -s "$_ca_pw" ] || continue
      if nm "$_ca_pw" 2>/dev/null | grep -Eq " [TW] glue_emit_one_call_arg_elf_c$"; then
        _ca_src_o="$_ca_pw"
        break
      fi
    done
    if [ -n "$_ca_src_o" ]; then
      cp -f "$_ca_src_o" "$_ca_prev"
      "$_g05_oc" --redefine-sym=glue_emit_one_call_arg_elf_c=glue_emit_one_call_arg_elf_c_prev \
        "$_ca_prev" 2>/dev/null \
        && echo "g05_relink_xlang: 10.22 Linux call_arg _prev from $_ca_src_o" >&2 \
        || rm -f "$_ca_prev"
      # Local call_args sites follow redefine to _prev; retarget them to soft U name.
      if [ -s "$_ca_prev" ] && [ -f scripts/g05_elf_retarget_soft_syms.py ]; then
        _ca_rt=build_asm/selfhost_pabi/backend_call_dispatch_ca_retarget.o
        if python3 scripts/g05_elf_retarget_soft_syms.py "$_ca_prev" "$_ca_rt" \
            glue_emit_one_call_arg_elf_c_prev=glue_emit_one_call_arg_elf_c \
            2>/tmp/g05_call_arg_retarget.log; then
          cp -f "$_ca_rt" "$_ca_prev"
          echo "g05_relink_xlang: 10.22 Linux call_arg ELF retarget → soft" >&2
        else
          echo "g05_relink_xlang: WARN call_arg .o retarget failed (product patch later)" >&2
        fi
        unset _ca_rt
      fi
      _ca_objs_new=""
      for _ca_o in $OBJS; do
        case "$(basename "$_ca_o")" in
          backend_call_dispatch.o) _ca_objs_new="${_ca_objs_new:+$_ca_objs_new }$_ca_prev" ;;
          backend_call_dispatch_ca_prev.o) continue ;;
          *) _ca_objs_new="${_ca_objs_new:+$_ca_objs_new }$_ca_o" ;;
        esac
      done
      OBJS="$_ca_objs_new"
      unset _ca_objs_new _ca_o
      if [ -s "$_ca_prev" ] && nm "$_ca_prev" 2>/dev/null | grep -Eq " [TW] glue_emit_one_call_arg_elf_c_prev$"; then
        case " $OBJS " in
          *" $_ca_prev "*) ;;
          *) OBJS="$_ca_prev $OBJS" ;;
        esac
      fi
      export XLANG_G05_LINUX_FORCE_U_CALL_ARG=1
    fi
    unset _ca_prev _ca_src_o _ca_pw
  fi
  # 10.22: durable_ptr thin vs pabi_alias hollow W
  if [ -n "$_g05_oc" ] \
    && printf "%s" " $OBJS " | grep -Eq "(^|[[:space:]/])array_lit_durable_thin\.o([[:space:]]|$)"; then
    for _du_pw in build_asm/selfhost_pabi/pabi_alias.skip_egg.o \
                  build_asm/selfhost_pabi/pabi_alias.elf64k.o \
                  build_asm/selfhost_pabi/pabi_alias.o; do
      [ -s "$_du_pw" ] || continue
      if nm "$_du_pw" 2>/dev/null | grep -Eq " [TW] glue_asm_emit_array_lit_durable_ptr_rax_elf_c$"; then
        "$_g05_oc" --weaken-symbol=glue_asm_emit_array_lit_durable_ptr_rax_elf_c "$_du_pw" 2>/dev/null \
          && echo "g05_relink_xlang: 10.22 Linux weaken $_du_pw durable_ptr (thin wins)" >&2 \
          || true
      fi
    done
    unset _du_pw
    export XLANG_G05_LINUX_FORCE_U_DURABLE=1
  fi
  unset _g05_oc
fi
# nostdlib policy for Linux product (same as g05_relink_env).
# shellcheck disable=SC1091
. scripts/bootstrap_nostdlib_shared.sh

n_objs=$(printf '%s\n' "$OBJS" | wc -w | tr -d ' ')

# w2060: snapshot this stage's compiler before the link replaces it. The two
# host-cc leaf vehicles below (std/fs/fs.o, std/string/string.o) are rebuilt
# by the compiler that runs this stage (g1 <- v1, g2 <- g1, g3 <- g2), the
# same compiler that built every other object of the stage. Same preference
# as pure_asm_x_to_o: ./xlang, then ./xlang_asm. PLATFORM: LINUX|DARWIN.
# Windows: keep the .exe name so the copy stays runnable. PLATFORM: SHARED.
_G05_STAGE_X=""
_G05_STAGE_X_FROM=""
_G05_STAGE_DIR=""
# Windows has no writable /tmp; TEMP is set by the build env. PLATFORM: SHARED.
_G05_TMPROOT="${TMPDIR:-${TEMP:-/tmp}}"
for _sx_cand in xlang xlang.exe xlang_asm xlang_asm.exe; do
  if [ -f "$_sx_cand" ] && [ -x "$_sx_cand" ] && [ -s "$_sx_cand" ]; then
    _G05_STAGE_DIR="$(mktemp -d "$_G05_TMPROOT/g05_stage_x.XXXXXX" 2>/dev/null || echo "$_G05_TMPROOT/g05_stage_x.$$")"
    mkdir -p "$_G05_STAGE_DIR"
    _G05_STAGE_X="$_G05_STAGE_DIR/$_sx_cand"
    if cp -p "$_sx_cand" "$_G05_STAGE_X" && chmod +x "$_G05_STAGE_X"; then
      _G05_STAGE_X_FROM="$PWD/$_sx_cand"
    else
      rm -rf "$_G05_STAGE_DIR"
      _G05_STAGE_X=""
      _G05_STAGE_DIR=""
    fi
    break
  fi
done

g05_force_cc() {
  [ "${XLANG_G05_FORCE_CC:-0}" = "1" ] || [ "${XLANG_SEED_LINK_FORCE_CC:-0}" = "1" ]
}

# Named CC residual only (FORCE_CC escape or pure-ld ineligible host).
# wave774: not used as silent fallback after pure-ld failure.
run_g05_cc_residual() {
  # shellcheck disable=SC2086
  echo "g05_relink_xlang: $CC ... -o $OUT  ($n_objs objs; CC residual)"
  # w2055: Windows links through this path; with WINNERS set it writes a
  # GNU ld map and runs the same winner check. PLATFORM: WINDOWS.
  _cmap=""
  case "$(uname -s 2>/dev/null)" in
    MINGW*|MSYS*|CYGWIN*|Windows_NT*)
      if [ -n "$WINNERS" ]; then
        _cmap="build_asm/$(basename "$OUT").ldmap"
        rm -f "$_cmap"
      fi
      ;;
  esac
  # shellcheck disable=SC2086
  $CC $CFLAGS ${_cmap:+-Wl,-Map=$_cmap} -o "$OUT" $OBJS
  echo "g05_relink_xlang: OK CC residual $OUT" >&2
  if [ -n "$_cmap" ]; then
    g05_check_link_winners "$_cmap" || exit 1
  fi
}

# w2055: read the link map (Darwin ld64 -map or GNU ld -Map) and prove each
# "sym=object" pair in WINNERS resolved to that object. A miss means the
# weakened pabi copy won.
g05_check_link_winners() {
  python3 - "$1" $WINNERS <<'PYEOF'
import os, re, sys
mp = sys.argv[1]
objs, syms, sec = {}, {}, None
for line in open(mp, encoding="utf-8", errors="replace"):
    if line.startswith("# Object files:"):
        sec = "o"; continue
    if line.startswith("# Sections:"):
        sec = None; continue
    if line.startswith("# Symbols:"):
        sec = "s"; continue
    if sec == "o":
        m = re.match(r"\[\s*(\d+)\]\s+(.*)$", line.rstrip("\n"))
        if m:
            objs[m.group(1)] = m.group(2)
    elif sec == "s":
        m = re.match(r"0x[0-9A-Fa-f]+\s+0x[0-9A-Fa-f]+\s+\[\s*(\d+)\]\s+(\S+)$", line.rstrip("\n"))
        if m:
            syms.setdefault(m.group(2), []).append(m.group(1))
if not objs:
    # GNU ld -Map: an input-section line names the object; the symbol lines
    # under it (address + name) are the definitions that won.
    syms, cur, pend = {}, None, False
    for line in open(mp, encoding="utf-8", errors="replace"):
        t = line.rstrip("\n")
        m = re.match(r"^ (\.\S+)?\s+0x[0-9a-fA-F]+\s+0x[0-9a-fA-F]+\s+(\S+\.o)\s*$", t)
        if m and (m.group(1) or pend):
            cur = m.group(2); pend = False; continue
        if re.match(r"^ \.\S+\s*$", t):
            pend = True; continue
        pend = False
        m = re.match(r"^\s+0x[0-9a-fA-F]+\s+([A-Za-z_][\w.$]*)\s*$", t)
        if m and cur:
            k = "g%d" % len(objs)
            objs[k] = cur
            syms.setdefault(m.group(1), []).append(k)
bad = 0
for pair in sys.argv[2:]:
    sym, _, want = pair.partition("=")
    got = [objs.get(i, "?") for i in syms.get(sym, [])]
    # knife 254: ALE linked last may also list the same name (local /
    # no_dead_strip). Tip first-wins when want is among providers.
    want_r = os.path.realpath(want)
    ok = any(os.path.realpath(g) == want_r for g in got)
    print("g05_relink_xlang: winner %s -> %s %s" % (sym, ",".join(got) or "missing", "OK" if ok else "FAIL (want %s)" % want), file=sys.stderr)
    bad += not ok
sys.exit(1 if bad else 0)
PYEOF
}

# note743y.5: egg frame undercount → patch sub $imm,%rsp before pure-ld.
# PLATFORM: LINUX only (objdump x86_64 ELF). Darwin Cap uses tip chkstk.
if [ "$(uname -s)" = "Linux" ] && [ -f scripts/linux_patch_elf_frame_min.py ]; then
  python3 scripts/linux_patch_elf_frame_min.py || true
fi

# pure-ld required when freestanding-eligible and not forced to CC residual.
run_g05_pure_ld_required() {
  entry=""
  tail=""
  extra=""

  # Product freestanding entry (matches MAIN_LINK_FLAGS / cold SEED_LINK_ENTRY).
  entry="$(pure_ld_default_entry)"
  if bootstrap_wants_nostdlib; then
    # PLATFORM: LINUX — map cc -nostdlib -static -Wl,--gc-sections → pure ld flags.
    # No -lc; freestanding_io + nostdlib stubs already in G05_OBJS.
    extra="-static --gc-sections"
    if [ "${XLANG_G05_LINUX_FORCE_U_CALL_ARG:-0}" = "1" ]; then
      extra="$extra -u glue_emit_one_call_arg_elf_c"
      echo "g05_relink_xlang: 10.22 Linux -u glue_emit_one_call_arg_elf_c (keep call_arg soft)" >&2
    fi
    if [ "${XLANG_G05_LINUX_FORCE_U_REVERSE_INFER:-0}" = "1" ]; then
      extra="$extra -u typeck_field_reverse_infer_base_type"
      echo "g05_relink_xlang: 10.22 Linux -u typeck_field_reverse_infer_base_type (keep reverse_infer soft)" >&2
    fi
    if [ "${XLANG_G05_LINUX_FORCE_U_DURABLE:-0}" = "1" ]; then
      extra="$extra -u glue_asm_emit_array_lit_durable_ptr_rax_elf_c"
      echo "g05_relink_xlang: 10.22 Linux -u durable_ptr (keep thin)" >&2
    fi
    tail=""
  else
    # Darwin / Linux-with-libc freestanding (nostartfiles-style).
    tail="$(pure_ld_default_libc_tail)"
  fi
  _map=""
  if [ -n "$WINNERS" ]; then
    _map="build_asm/$(basename "$OUT").ldmap"
    rm -f "$_map"
    case "$(uname -s 2>/dev/null)" in
      Darwin) extra="$extra -map $_map" ;;
      Linux) extra="$extra -Map=$_map" ;;
      *) _map="" ;;
    esac
  fi
  echo "g05_relink_xlang: pure-ld → $OUT  ($n_objs objs)" >&2
  if pure_ld_try_link "$OUT" "$OBJS" "$entry" "$tail" "$extra" ""; then
    echo "g05_relink_xlang: OK pure-ld $OUT" >&2
    if [ -n "$_map" ]; then
      g05_check_link_winners "$_map" || exit 1
    fi
    # 10.22: if call_args still PC-calls _prev (in-object redefine), retarget product.
    if [ "${XLANG_G05_LINUX_FORCE_U_CALL_ARG:-0}" = "1" ] && [ -x "$OUT" ] \
      && [ -f scripts/g05_elf_retarget_call_arg_prev_product.py ]; then
      python3 scripts/g05_elf_retarget_call_arg_prev_product.py "$OUT" \
        || echo "g05_relink_xlang: WARN call_arg product retarget failed" >&2
    fi
    return 0
  fi
  echo "g05_relink_xlang: FAIL pure-ld for $OUT (no silent CC fallback; set XLANG_G05_FORCE_CC=1 for escape)" >&2
  exit 1
}

# Decision tree (wave774):
#   FORCE_CC=1              → named CC residual only
#   !freestanding_ok        → named CC residual only (ineligible host)
#   else                    → pure-ld required (hard fail on miss)
if g05_force_cc; then
  echo "g05_relink_xlang: pure-ld skipped (FORCE_CC) → CC residual only" >&2
  run_g05_cc_residual
elif ! pure_ld_freestanding_ok; then
  echo "g05_relink_xlang: pure-ld ineligible (host not freestanding) → CC residual only" >&2
  run_g05_cc_residual
else
  run_g05_pure_ld_required
fi

# note743y.6.1: tip-cold egg one.o undercounts frames; tip emits chkstk.
# Full tip sidecars refresh broke the second pure-ld (skip_egg UNDEFs).
# Only tip-rebuild one.o (for_call_args); keep first-link product on fail.
# PLATFORM: LINUX. Egg ELF frame patch remains for the first link.
if [ "$(uname -s)" = "Linux" ] && [ "${XLANG_G05_TIP_SIDECAR_REFRESH:-1}" = "1" ]; then
  _y6_tip=""
  if [ -x "$OUT" ]; then
    _y6_tip="$OUT"
  elif [ -x "./$OUT" ]; then
    _y6_tip="./$OUT"
  elif [ -x ./xlang_asm ]; then
    _y6_tip=./xlang_asm
  fi
  if [ -n "$_y6_tip" ] && [ -f src/runtime_pipeline_abi_for_call_args_thin.x ]; then
    echo "g05_relink_xlang: note743y.6.1 tip-refresh one.o via $_y6_tip" >&2
    cp -f "$_y6_tip" "${OUT}.pre_y6"
    _y6_work="$(mktemp -d "${TMPDIR:-/tmp}/g05_y6_one.XXXXXX")"
    if timeout 300 "$_y6_tip" -c -backend asm \
        -o "$_y6_work/one.o" src/runtime_pipeline_abi_for_call_args_thin.x >/dev/null 2>&1 \
      && [ -s "$_y6_work/one.o" ]; then
      mkdir -p build_asm/selfhost_pabi
      cp -f "$_y6_work/one.o" build_asm/selfhost_pabi/one.o
      # weaken extras; keep for_call_args strong (same as sidecars)
      while read -r _ys; do
        [ -n "$_ys" ] || continue
        [ "$_ys" = "pipeline_asm_emit_expr_elf_for_call_args" ] && continue
        objcopy --weaken-symbol="$_ys" build_asm/selfhost_pabi/one.o 2>/dev/null || true
      done < <(nm "$_y6_work/one.o" | awk '$2=="T"{print $3}')
      echo "g05_relink_xlang: note743y.6.1 tip one.o OK; second pure-ld" >&2
      # Subshell: run_g05_pure_ld_required uses exit 1 on fail.
      if ( run_g05_pure_ld_required ); then
        rm -f "${OUT}.pre_y6"
      else
        echo "g05_relink_xlang: WARN tip one.o second pure-ld failed; restore first-link product" >&2
        mv -f "${OUT}.pre_y6" "$OUT"
        chmod +x "$OUT" 2>/dev/null || true
      fi
    else
      echo "g05_relink_xlang: WARN tip one.o rebuild failed; keeping first-link product" >&2
      rm -f "${OUT}.pre_y6"
    fi
    rm -rf "$_y6_work"
  fi
fi

# w1010: PE mega same-TU leftover body_sync / emit_let_init → jmp to host-gcc twin.
# PLATFORM: WINDOWS only (script no-ops on Mach-O/ELF).
# MinGW -o xlang often materializes as xlang.exe; resolve before cp/patch.
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT*)
    if [ -f "${OUT}.exe" ]; then
      OUT="${OUT}.exe"
    fi
    if [ -f scripts/win_patch_body_sync_jmp.py ] && [ -f "$OUT" ]; then
      python3 scripts/win_patch_body_sync_jmp.py "$OUT" || { echo "g05_relink_xlang: win_patch_body_sync_jmp failed" >&2; exit 1; }
    fi
    ;;
esac

# knife253 / 9.1: Darwin ale leftovers define local (t) twins of global (T)
# symbols; same-TU calls bind the short local and break struct-lit / option L2.
# Trampoline every t->T pair in the freshly linked product, then ad-hoc codesign
# (TEXT was rewritten). PLATFORM: DARWIN only.
case "$(uname -s 2>/dev/null)" in
  Darwin)
    if [ "${XLANG_SKIP_DARWIN_TRAMP:-0}" != "1" ] && [ -f scripts/darwin_tramp_local_shadows_to_global.py ]; then
      python3 scripts/darwin_tramp_local_shadows_to_global.py "$OUT"         || { echo "g05_relink_xlang: darwin_tramp_local_shadows_to_global failed" >&2; exit 1; }
      codesign --sign - --force --timestamp=none "$OUT" 2>/dev/null         || codesign -f -s - "$OUT"         || { echo "g05_relink_xlang: codesign after trampoline failed" >&2; exit 1; }
      echo "g05_relink_xlang: Darwin local-shadow trampolines + codesign OK" >&2
    fi
    ;;
esac

# w1499: copy onto a fresh inode. macOS keeps the code signature of an
# executable it already ran cached per vnode, so cp over the old file can make
# the next exec die with SIGKILL ("load code signature error 2").
# PLATFORM: MACOS needs it; SHARED harmless.
_g05_cp_fresh() {
  [ "$1" = "$2" ] && return 0
  rm -f "$2"
  cp -f "$1" "$2"
}
_g05_cp_fresh "$OUT" "$XLANG_C"
_g05_cp_fresh "$OUT" "$BOOTSTRAP"
echo "g05_relink_xlang OK ($OUT → $XLANG_C + $BOOTSTRAP)"

# Always sync product asm name after g05. On Windows MinGW, L2 defaults to
# ./compiler/xlang_asm (no .exe) while -o xlang materializes as xlang.exe —
# a stale bare xlang_asm silently fails hello/si while xlang_asm.exe is green.
# PLATFORM: WINDOWS sync both names; SHARED sync bare xlang_asm.
_g05_cp_fresh "$OUT" xlang_asm
echo "g05_relink_xlang: synced xlang_asm"
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT*)
    _g05_cp_fresh "$OUT" xlang_asm.exe
    echo "g05_relink_xlang: synced xlang_asm.exe"
    # MinGW -o writes xlang.exe. The copies above publish xlang_asm,
    # xlang_asm.exe, the unsuffixed xlang-c, and bootstrap_xlangc.
    # They do not publish the literal bare xlang, which ./xlang and the
    # stage identity check both open, nor xlang-c.exe, which the nine
    # driver leaves exec (pick_xlang). Leaving either name on the previous
    # image makes the next generation compare or compile with the old
    # compiler. CPython isfile does not add the Git bash .exe suffix.
    # _g05_cp_fresh removes only the literal destination; a bare name does
    # not delete the .exe sibling. PLATFORM: WINDOWS.
    if python3 -c 'import os,sys; raise SystemExit(0 if os.path.isfile(sys.argv[1]) else 1)' xlang; then
      _g05_cp_fresh "$OUT" xlang
      echo "g05_relink_xlang: synced xlang"
    fi
    _g05_cp_fresh "$OUT" xlang-c.exe
    echo "g05_relink_xlang: synced xlang-c.exe"
    ;;
esac

# w1545 (Windows FORCE refresh of every leaf, failures kept with a WARN) is
# folded into the shared block below (w2060): one freshness rule and a hard
# fail on every host. PLATFORM: SHARED.

# w2055: Linux leaves were only ever built when missing. A source change in a
# leaf module (80fd8b8ee: core/option out-pointer returns) left the old object
# in place and user programs linked the stale ABI (L2 opt exit 134). Rebuild
# only leaves the std module script reports stale (ensure without FORCE), with
# the product's asm backend so no host C compiler runs. Keep the old leaf when
# the rebuild fails.
# w2055: Darwin too. Its leaves were never refreshed either (core/option
# kept the by-value ABI, L2 opt hit expect_i32's panic), and its default
# leaf backend is C plus the host compiler, so refresh here with asm.
# w2060: Windows takes the same block (was the w1545 FORCE loop that kept a
# failed leaf with only a WARN). PLATFORM: LINUX|DARWIN|WINDOWS.
case "$(uname -s 2>/dev/null)" in
  Linux|Darwin|MINGW*|MSYS*|CYGWIN*|Windows_NT*)
    case "$OUT" in /*|?:*) _refresh_x="$OUT" ;; *) _refresh_x="./$OUT" ;; esac
    _kept_stale=""
    # The refresh must not fall back to the module script's C path: a cc
    # that always fails sits first on PATH, so an asm failure keeps the old
    # leaf instead of adding a host compiler run.
    _nocc_dir=$(mktemp -d "$_G05_TMPROOT/g05_nocc.XXXXXX" 2>/dev/null || echo "$_G05_TMPROOT/g05_nocc.$$")
    mkdir -p "$_nocc_dir"
    for _ccn in cc gcc clang; do
      printf '#!/bin/sh\necho "g05_relink_xlang: host $0 blocked during leaf refresh" >&2\nexit 1\n' > "$_nocc_dir/$_ccn"
      chmod +x "$_nocc_dir/$_ccn"
    done
    # w2060 (manager ruling A): std/fs/fs.o and std/string/string.o have no
    # asm vehicle; their dedicated scripts (xlang_compile_std_fs_formal.sh,
    # xlang_compile_std_string_o.sh) compile the product's emitted C with the
    # host cc lines they already carry. Host cc is allowed for those two
    # scripts only, through a logging wrapper; every other leaf keeps the
    # always-failing cc above. Freshness is one rule on every host: a leaf is
    # STALE when the shared script's own source check says so, or when this
    # stage's compiler is newer than the leaf (so g1, g2 and g3 each rebuild
    # it with their own compiler). A missing leaf is skipped (refresh only,
    # same as every other leaf). A failed rebuild restores the old leaf and
    # stops the relink: no ALLOW escape. PLATFORM: LINUX|DARWIN.
    _ccv_x="${_G05_STAGE_X:-$_refresh_x}"
    _ccv_from="${_G05_STAGE_X_FROM:-$_refresh_x}"
    if command -v sha256sum >/dev/null 2>&1; then
      _ccv_sha=$(sha256sum "$_ccv_x" | cut -c1-16)
    else
      _ccv_sha=$(shasum -a 256 "$_ccv_x" | cut -c1-16)
    fi
    _ccv_id="$_ccv_sha@$(stat -c %Y "$_ccv_x" 2>/dev/null || stat -f %m "$_ccv_x" 2>/dev/null || echo 0)"
    _ccv_hostcc=$(cd .. && git ls-files 'compiler/*.c' 2>/dev/null | wc -l | tr -d ' ')
    _ccv_dir=$(mktemp -d "$_G05_TMPROOT/g05_ccv.XXXXXX" 2>/dev/null || echo "$_G05_TMPROOT/g05_ccv.$$")
    mkdir -p "$_ccv_dir"
    for _ccn in cc gcc clang; do
      _ccv_real=$(command -v "$_ccn" 2>/dev/null || true)
      if [ -n "$_ccv_real" ]; then
        # Log to a file: the vehicles send cc stderr to their own temp files.
        printf '#!/bin/sh\necho "cc-vehicle exec %s $*" >> "%s/calls"\nexec "%s" "$@"\n' \
          "$_ccn" "$_ccv_dir" "$_ccv_real" > "$_ccv_dir/$_ccn"
      else
        printf '#!/bin/sh\necho "g05_relink_xlang: cc-vehicle %s not installed" >&2\nexit 1\n' \
          "$_ccn" > "$_ccv_dir/$_ccn"
      fi
      chmod +x "$_ccv_dir/$_ccn"
    done
    for _leaf in ../core/*/*.o ../std/*/*.o ../std/*/*/*.o; do
      [ -s "$_leaf" ] || continue
      case "$_leaf" in
        ../std/fs/fs.o|../std/string/string.o)
          # w2060: the link above runs before this refresh, so the leaf is
          # newer than the product that was just linked; with mtime alone the
          # next stage saw its compiler as older and skipped (g1 rebuilt, g2
          # skipped, g3 rebuilt). Record which compiler built the leaf
          # (sha@mtime of this stage's compiler) and rebuild when the record
          # is missing or names another compiler. PLATFORM: SHARED.
          _ccv_stamp="build_asm/g05_leaf_stamp/$(echo "$_leaf" | sed 's#^\.\./##; s#/#_#g').id"
          _ccv_prev=$(cat "$_ccv_stamp" 2>/dev/null || echo none)
          _ccv_force=0
          [ "$_ccv_x" -nt "$_leaf" ] && _ccv_force=1
          [ "$_ccv_prev" = "$_ccv_id" ] || _ccv_force=1
          echo "g05_relink_xlang: cc-vehicle $_leaf compiler=$_ccv_from sha=$_ccv_sha force=$_ccv_force id=$_ccv_id prev=$_ccv_prev host-cc=$_ccv_hostcc"
          cp -fp "$_leaf" "$_leaf.w2055bak"
          _before=$(stat -c %Y "$_leaf" 2>/dev/null || stat -f %m "$_leaf" 2>/dev/null || echo 0)
          _erc=0
          : > "$_ccv_dir/calls"
          PATH="$_ccv_dir:$PATH" FORCE="$_ccv_force" XLANG_FORCE_LINK_BACKEND=asm XLANG="$_ccv_x" \
            bash scripts/xlang_compile_std_module.sh ensure "$_leaf" >"$_ccv_dir/log" 2>&1 || _erc=$?
          sed -e 's/^/  /' "$_ccv_dir/log" | cut -c1-240
          sed -e 's/^/  g05_relink_xlang: /' "$_ccv_dir/calls" | cut -c1-240
          echo "g05_relink_xlang: cc-vehicle $_leaf cc-calls=$(wc -l < "$_ccv_dir/calls" | tr -d ' ') rc=$_erc"
          if [ "$_erc" = 0 ] && [ -s "$_leaf" ]; then
            _after=$(stat -c %Y "$_leaf" 2>/dev/null || stat -f %m "$_leaf" 2>/dev/null || echo 0)
            if [ "$_after" != "$_before" ] || ! cmp -s "$_leaf" "$_leaf.w2055bak"; then
              rm -f "$_leaf.w2055bak"
              mkdir -p build_asm/g05_leaf_stamp && echo "$_ccv_id" > "$_ccv_stamp"
              echo "g05_relink_xlang: refreshed stale $_leaf (cc-vehicle, $_ccv_from)"
              continue
            fi
            if [ "$_ccv_force" != 1 ]; then
              rm -f "$_leaf.w2055bak"
              continue
            fi
            # FORCE=1 must rebuild; an untouched leaf is a skipped rebuild.
            _erc=nochange
          fi
          mv -f "$_leaf.w2055bak" "$_leaf"
          echo "g05_relink_xlang: FAIL cc-vehicle rebuild of $_leaf rc=$_erc (old leaf restored)" >&2
          rm -rf "$_ccv_dir" "$_nocc_dir"
          if [ -n "$_G05_STAGE_DIR" ]; then rm -rf "$_G05_STAGE_DIR"; fi
          exit 1
          ;;
      esac
      _before=$(stat -c %Y "$_leaf" 2>/dev/null || stat -f %m "$_leaf" 2>/dev/null || echo 0)
      cp -fp "$_leaf" "$_leaf.w2055bak"
      _erc=0
      PATH="$_nocc_dir:$PATH" XLANG_FORCE_LINK_BACKEND=asm XLANG="$_refresh_x" bash scripts/xlang_compile_std_module.sh ensure "$_leaf" >/dev/null 2>&1 || _erc=$?
      if [ "$_erc" = 3 ]; then
        # Not a catalog leaf (exit 3): the product never ensures it; leave it.
        mv -f "$_leaf.w2055bak" "$_leaf"
        continue
      fi
      if [ "$_erc" = 0 ] && [ -s "$_leaf" ]; then
        rm -f "$_leaf.w2055bak"
        _after=$(stat -c %Y "$_leaf" 2>/dev/null || stat -f %m "$_leaf" 2>/dev/null || echo 0)
        if [ "$_after" != "$_before" ]; then
          echo "g05_relink_xlang: refreshed stale $_leaf"
        fi
      else
        mv -f "$_leaf.w2055bak" "$_leaf"
        _kept_stale="$_kept_stale $_leaf"
        echo "g05_relink_xlang: !!!!! STALE LEAF KEPT: $_leaf (asm rebuild failed; programs linking it get the OLD object) !!!!!" >&2
      fi
    done
    rm -rf "$_nocc_dir" "$_ccv_dir"
    if [ -n "$_kept_stale" ]; then
      echo "g05_relink_xlang: !!!!! STALE LEAVES KEPT ($(echo $_kept_stale | wc -w)):$_kept_stale !!!!!" >&2
      # w2060: formal gate — any STALE LEAF KEPT is a hard fail (old leaf must not ship).
      # Escape only with XLANG_G05_ALLOW_STALE_LEAF=1 for local diagnosis.
      if [ "${XLANG_G05_ALLOW_STALE_LEAF:-0}" != "1" ]; then
        echo "g05_relink_xlang: FAIL on STALE LEAF KEPT (set XLANG_G05_ALLOW_STALE_LEAF=1 to warn-only)" >&2
        exit 1
      fi
    fi
    ;;
esac
if [ -n "$_G05_STAGE_DIR" ]; then rm -rf "$_G05_STAGE_DIR"; fi
exit 0
