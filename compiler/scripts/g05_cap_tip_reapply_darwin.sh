#!/usr/bin/env bash
# g05_cap_tip_reapply_darwin.sh — after cold g05 (LEGACY-sized product), re-link Cap tip.
# Does NOT restore a prior Cap tip binary as tip (banned). Relinks this-wave from
# Cap tip env + recipe objects (cache softs/dual_gp/macho/dep_prerun bak).
# PLATFORM: MACOS Cap tip sidecar. Run from compiler/.
set -euo pipefail
cd "$(dirname "$0")/.."
# Soft prepends may run before g05_env sources G05_OBJS (set -u).
G05_OBJS="${G05_OBJS:-}"

CACHE="${XLANG_CAP_TIP_L4_CACHE:-}"
if [ -z "$CACHE" ]; then
  for c in /tmp/cap_tip_l4_safe_406200eef "$HOME/.cache/xlang_cap_tip_l4" .cap_tip_l4_cache; do
    if [ -d "$c" ] && [ -f "$c/g05_env_cap_tip_darwin.sh" ]; then
      CACHE="$c"
      break
    fi
  done
fi
[ -n "$CACHE" ] && [ -d "$CACHE" ] || {
  echo "g05_cap_tip_reapply: need Cap tip L4 cache (XLANG_CAP_TIP_L4_CACHE)" >&2
  exit 1
}

OC="${LLVM_OBJCOPY:-}"
if [ -z "$OC" ]; then
  for c in /opt/homebrew/opt/llvm/bin/llvm-objcopy /usr/local/opt/llvm/bin/llvm-objcopy; do
    [ -x "$c" ] && OC=$c && break
  done
fi
[ -n "$OC" ] || { echo "need llvm-objcopy" >&2; exit 1; }

echo "g05_cap_tip_reapply: cache=$CACHE"

# Cap tip this-wave: ASM_DEBUG note path SEGVs on diag loc (ctx); keep off for reapply/L2.
unset XLANG_ASM_DEBUG || true

# Recipe objects Cap tip needs (cold g05 may not match Cap tip identity)
mkdir -p build_asm/selfhost_pabi
if [ -f "$CACHE/dual_gp_new.o" ]; then
  cp -f "$CACHE/dual_gp_new.o" build_asm/selfhost_pabi/dual_gp_byte_size_a64.o
fi
# knife256/10.2: ARRAY→*u8 call-arg decay (print ABI x0=ptr,x1=len)
if [ -f "$CACHE/arg_byte_size_a64.o" ]; then
  cp -f "$CACHE/arg_byte_size_a64.o" build_asm/selfhost_pabi/arg_byte_size_a64.o
fi
if [ -f "$CACHE/mw.o" ]; then
  cp -f "$CACHE/mw.o" build_asm/selfhost_pabi/macho_write_a64.o
fi
# dep_prerun: prefer bak_pre_demote (survives *.o wipe); else cache
for base in dep_prerun_skip_typeck_a64 dep_prerun_parse_only_a64; do
  if [ -f "build_asm/selfhost_pabi/${base}.o.bak_pre_demote" ]; then
    cp -f "build_asm/selfhost_pabi/${base}.o.bak_pre_demote" "build_asm/selfhost_pabi/${base}.o"
  elif [ -f "$CACHE/${base}.o.bak_pre_demote" ]; then
    cp -f "$CACHE/${base}.o.bak_pre_demote" "build_asm/selfhost_pabi/${base}.o"
  fi
done

# knife256/10.2: named_size_thin is Cap tip size_simple authority (S24→24).
# Do NOT demote it to namedsizedead — that left only weak short pabi size_simple
# and ret_fixed_s24 COMMON sizes collapsed to n_arr*1 (exit 10/138).
# Tip-compile from .x; demote pabi_weak size_simple so named_size first-wins.
# PLATFORM: MACOS Cap tip.
if [ -f src/runtime_pipeline_abi_named_size_thin.x ]; then
  # set -u: XLANG may be unset until softs block; prefer LEGACY bak then ./xlang
  _ns_xl="${XLANG:-}"
  [ -x ./xlang ] && _ns_xl="./xlang"
  [ -x ./xlang.product_legacy_bak ] && _ns_xl="./xlang.product_legacy_bak"
  if XLANG_PREFER_ASM_O=1 "$_ns_xl" -backend asm -c \
      src/runtime_pipeline_abi_named_size_thin.x \
      -o build_asm/selfhost_pabi/named_size.o 2>/dev/null \
    && nm -gU build_asm/selfhost_pabi/named_size.o 2>/dev/null \
         | grep -q 'T _glue_type_size_simple$'; then
    echo "g05_cap_tip_reapply: tip-compiled named_size.o (size_simple authority)" >&2
  else
    echo "g05_cap_tip_reapply: WARN named_size tip-compile failed" >&2
  fi
fi
if [ -n "${OC:-}" ] && [ -s build_asm/selfhost_pabi/pabi_weak.o ] \
  && [ -s build_asm/selfhost_pabi/named_size.o ] \
  && nm -gU build_asm/selfhost_pabi/named_size.o 2>/dev/null \
       | grep -q 'T _glue_type_size_simple$'; then
  [ -s build_asm/selfhost_pabi/pabi_weak.o.bak_cap ] \
    || cp -f build_asm/selfhost_pabi/pabi_weak.o build_asm/selfhost_pabi/pabi_weak.o.bak_cap
  # Prefer bak then demote size_simple so named_size wins.
  cp -f build_asm/selfhost_pabi/pabi_weak.o.bak_cap build_asm/selfhost_pabi/pabi_weak.o
  if nm -gU build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null \
       | grep -q 'T _glue_type_size_simple$\|weak.*_glue_type_size_simple'; then
    "$OC" --redefine-sym=_glue_type_size_simple=_glue_type_size_simple__demoted \
      build_asm/selfhost_pabi/pabi_weak.o \
      && echo "g05_cap_tip_reapply: demoted pabi size_simple (named_size wins)" >&2 || true
  fi
fi


# knife256/10.2: pabi_weak typeck_x_type_size_from_layout_glue is a hollow
# (epilogue with no store to w0 → returns 1). Cap tip named_size then reports
# S24 size 1 → ret_fixed_s24 COMMON n_arr*1. Tip-compile typeck_orch_thin
# (260B Cap tip body, matches idle) and demote pabi/m8 stubs.
# PLATFORM: MACOS Cap tip.
if [ ! -s build_asm/selfhost_pabi/typeck_orch_layout_glue_a64.o ] \
  && [ -f src/runtime_pipeline_abi_typeck_orch_thin.x ]; then
  # set -u: XLANG may be unset until softs block; prefer LEGACY bak then ./xlang
  _orch_xl="${XLANG:-}"
  [ -x ./xlang ] && _orch_xl="./xlang"
  [ -x ./xlang.product_legacy_bak ] && _orch_xl="./xlang.product_legacy_bak"
  if XLANG_PREFER_ASM_O=1 "$_orch_xl" -backend asm -c \
      src/runtime_pipeline_abi_typeck_orch_thin.x \
      -o build_asm/selfhost_pabi/typeck_orch_layout_glue_a64.o.tmp 2>/dev/null \
    && nm -gU build_asm/selfhost_pabi/typeck_orch_layout_glue_a64.o.tmp 2>/dev/null \
         | grep -q 'T _typeck_x_type_size_from_layout_glue$'; then
    # Keep only layout glues (avoid dual typeck_x_ast_* with Cap tip typeck).
    echo '_typeck_x_type_size_from_layout_glue
_typeck_x_type_align_from_layout_glue' > /tmp/cap_tip_orch_layout.exp
    if ld -r -o build_asm/selfhost_pabi/typeck_orch_layout_glue_a64.o \
         -exported_symbols_list /tmp/cap_tip_orch_layout.exp \
         build_asm/selfhost_pabi/typeck_orch_layout_glue_a64.o.tmp 2>/dev/null \
      && [ -s build_asm/selfhost_pabi/typeck_orch_layout_glue_a64.o ]; then
      echo "g05_cap_tip_reapply: tip-compiled typeck_orch layout_glue" >&2
    else
      cp -f build_asm/selfhost_pabi/typeck_orch_layout_glue_a64.o.tmp \
        build_asm/selfhost_pabi/typeck_orch_layout_glue_a64.o
      echo "g05_cap_tip_reapply: tip-compiled typeck_orch (full; layout_glue)" >&2
    fi
  fi
  rm -f build_asm/selfhost_pabi/typeck_orch_layout_glue_a64.o.tmp /tmp/cap_tip_orch_layout.exp
fi
if [ -s build_asm/selfhost_pabi/typeck_orch_layout_glue_a64.o ]; then
  case " ${G05_OBJS:-} " in
    *" build_asm/selfhost_pabi/typeck_orch_layout_glue_a64.o "*) ;;
    *) G05_OBJS="build_asm/selfhost_pabi/typeck_orch_layout_glue_a64.o ${G05_OBJS:-}"; export G05_OBJS
       echo "g05_cap_tip_reapply: prepended typeck_orch_layout_glue_a64.o" >&2 ;;
  esac
  if [ -n "${OC:-}" ] && [ -s build_asm/selfhost_pabi/pabi_weak.o ]; then
    [ -s build_asm/selfhost_pabi/pabi_weak.o.bak_cap ] \
      || cp -f build_asm/selfhost_pabi/pabi_weak.o build_asm/selfhost_pabi/pabi_weak.o.bak_cap
    "$OC" \
      --redefine-sym=_typeck_x_type_size_from_layout_glue=_typeck_x_type_size_from_layout_glue__demoted \
      --redefine-sym=_typeck_x_type_align_from_layout_glue=_typeck_x_type_align_from_layout_glue__demoted \
      build_asm/selfhost_pabi/pabi_weak.o \
      && echo "g05_cap_tip_reapply: demoted pabi layout_glue hollows" >&2 || true
  fi
  if [ -n "${OC:-}" ] && [ -s build_asm/selfhost_pabi/m8_reloc_stubs_g05.o ]; then
    "$OC" --weaken-symbol=_typeck_x_type_size_from_layout_glue \
      --weaken-symbol=_typeck_x_type_align_from_layout_glue \
      build_asm/selfhost_pabi/m8_reloc_stubs_g05.o 2>/dev/null \
      && echo "g05_cap_tip_reapply: weakened m8 layout_glue stubs" >&2 || true
  fi
fi

# Softs: rebuild with LEGACY bak if present (stable assembler), else this-wave xlang
if [ -x xlang.product_legacy_bak ]; then
  export XLANG="$PWD/xlang.product_legacy_bak"
elif [ -x xlang ]; then
  export XLANG="$PWD/xlang"
else
  echo "g05_cap_tip_reapply: no XLANG to assemble softs" >&2
  exit 1
fi
bash scripts/g05_cap_tip_typeck_soft_prep.sh

# Cap tip env + relink (OUT=xlang.cap_g05_l2)
set -a
# shellcheck disable=SC1091
. scripts/g05_env_cap_tip_darwin.sh
# knife256/10.2: nopark lex_source_data first-wins (sticky park poisons dep names).
# PLATFORM: MACOS — weaken nop9b's copies. Do NOT --redefine-sym them to
# __park_dead: objcopy rewrites this object's own relocations, so
# parser_asm_parse_one_extern_skip_into_c keeps calling the park body and
# copies an extern's name out of the caller's sticky source (probe_ext_i32
# landed as bytes from the importing file). A weak def lets the strong
# nopark .o win for every call site, including nop9b's.
if [ ! -s build_asm/selfhost_pabi/lex_source_data_nopark_a64.o ]; then
  _lsn=src/asm/lex_source_data_nopark_a64.s
  [ -f "$_lsn" ] || _lsn=build_asm/selfhost_pabi/lex_source_data_nopark.s
  [ -f "$_lsn" ] && as -o build_asm/selfhost_pabi/lex_source_data_nopark_a64.o "$_lsn"
fi
if [ -s build_asm/selfhost_pabi/lex_source_data_nopark_a64.o ]; then
  if [ -n "${OC:-}" ] && [ -s build_asm/selfhost_pabi/parser_asm_thin_glue.nop9b.o ]; then
    _nop9b=build_asm/selfhost_pabi/parser_asm_thin_glue.nop9b.o
    # A previous redefine left the public names as __park_dead. Put them
    # back so relocations name the nopark symbols, then weaken.
    "$OC" --redefine-sym=_parser_asm_lex_source_data_c__park_dead=_parser_asm_lex_source_data_c \
      --redefine-sym=_parser_asm_lex_source_length_c__park_dead=_parser_asm_lex_source_length_c \
      "$_nop9b" 2>/dev/null || true
    "$OC" --weaken-symbol=_parser_asm_lex_source_data_c \
      --weaken-symbol=_parser_asm_lex_source_length_c \
      "$_nop9b" 2>/dev/null || true
  fi
  case " $G05_OBJS " in
    *" lex_source_data_nopark_a64.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/lex_source_data_nopark_a64.o $G05_OBJS"
      export G05_OBJS
      echo "g05_cap_tip_reapply: prepended lex_source_data_nopark_a64.o" >&2
      ;;
  esac
fi

# knife256/10.2: 256-slot wrap_buf first-wins (16-slot thin_glue smashes dep fats).
if [ ! -s build_asm/selfhost_pabi/lex_wrap_buf_256_a64.o ] && [ -f src/asm/lex_wrap_buf_256_a64.s ]; then
  as -o build_asm/selfhost_pabi/lex_wrap_buf_256_a64.o src/asm/lex_wrap_buf_256_a64.s
fi
if [ -s build_asm/selfhost_pabi/lex_wrap_buf_256_a64.o ]; then
  if [ -n "${OC:-}" ] && [ -s build_asm/selfhost_pabi/parser_asm_thin_glue.nop9b.o ]; then
    "$OC" --redefine-sym=_parser_asm_lex_wrap_buf_c=_parser_asm_lex_wrap_buf_c__16slot_dead \
      build_asm/selfhost_pabi/parser_asm_thin_glue.nop9b.o 2>/dev/null || true
  fi
  case " $G05_OBJS " in
    *" lex_wrap_buf_256_a64.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/lex_wrap_buf_256_a64.o $G05_OBJS"
      export G05_OBJS
      echo "g05_cap_tip_reapply: prepended lex_wrap_buf_256_a64.o" >&2
      ;;
  esac
fi

# knife256/10.2: overload mid empty-reject → caller-arg mid for string.length.
if [ -s build_asm/selfhost_pabi/glue_overload_mid_empty_reject_soft.o ]; then
  case " $G05_OBJS " in
    *" glue_overload_mid_empty_reject_soft.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/glue_overload_mid_empty_reject_soft.o $G05_OBJS"
      export G05_OBJS
      echo "g05_cap_tip_reapply: prepended glue_overload_mid_empty_reject_soft.o" >&2
      ;;
  esac
fi
set +a
# Prefer this-wave vehicles from cold g05 when present
export G05_XLANG_C="${G05_XLANG_C:-xlang-c}"
export G05_BOOTSTRAP="${G05_BOOTSTRAP:-bootstrap_xlangc}"
export XLANG_G05_ALLOW_STALE_LEAF="${XLANG_G05_ALLOW_STALE_LEAF:-1}"
export G05_OUT='xlang.cap_g05_l2'
export G05_SYNC_ASM=0

# Cap tip L4: demote m8_g05 only when thin overlay is IN G05_OBJS and has T.
# (assign_emit_thin may exist on disk but omit from frozen env — demoting then
# leaves undef assign_elf_c. INDEX prepend below adds it; demote runs after.)
if [ -s build_asm/selfhost_pabi/m8_reloc_stubs.o ]; then
  cp -f build_asm/selfhost_pabi/m8_reloc_stubs.o build_asm/selfhost_pabi/m8_reloc_stubs_g05.o
fi

# knife256/10.2: Cap tip match_module_bytes returns stack pad → match arms
# Color.Green keep var_idx=-1 (enum has no variant). Prepend BSS get/set soft.
# PLATFORM: MACOS Cap tip.
if [ -f src/asm/match_module_slot_a64.s ]; then
  clang -c -o build_asm/selfhost_pabi/match_module_slot_a64.o src/asm/match_module_slot_a64.s \
    || { echo "g05_cap_tip_reapply: match_module_slot assemble failed" >&2; exit 1; }
fi
if [ -s build_asm/selfhost_pabi/match_module_slot_a64.o ]; then
  case " $G05_OBJS " in
    *" build_asm/selfhost_pabi/match_module_slot_a64.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/match_module_slot_a64.o $G05_OBJS"
      export G05_OBJS
      echo "g05_cap_tip_reapply: prepended match_module_slot_a64.o" >&2
      ;;
  esac
  # Demote seed-bridge hollow twins so BSS soft first-wins (else ld duplicate).
  _oc_mm="${LLVM_OBJCOPY:-}"
  [ -n "$_oc_mm" ] || { [ -x /opt/homebrew/opt/llvm/bin/llvm-objcopy ] && _oc_mm=/opt/homebrew/opt/llvm/bin/llvm-objcopy; }
  [ -n "$_oc_mm" ] || { [ -x /usr/local/opt/llvm/bin/llvm-objcopy ] && _oc_mm=/usr/local/opt/llvm/bin/llvm-objcopy; }
  if [ -n "$_oc_mm" ] && [ -s src/x_seed_bridge.o ]; then
    [ -s src/x_seed_bridge.o.bak_cap ] || cp -f src/x_seed_bridge.o src/x_seed_bridge.o.bak_cap
    cp -f src/x_seed_bridge.o.bak_cap src/x_seed_bridge.o
    "$_oc_mm" \
      --redefine-sym=_pipeline_match_module_bytes=_pipeline_match_module_bytes__demoted \
      --redefine-sym=_pipeline_parser_set_match_module=_pipeline_parser_set_match_module__demoted \
      --redefine-sym=_pipeline_parser_get_match_module=_pipeline_parser_get_match_module__demoted \
      src/x_seed_bridge.o \
      && echo "g05_cap_tip_reapply: demoted seed_bridge match_module get/set/bytes" >&2
  fi
fi

# knife256/10.2: Cap tip Split_* named size 0/8 → no x8 sret on split_at call.
# Soft named_layout_size + size_simple → 32; demote/retarget pipeline_abi.
# True-cold wipe drops these; assemble hand-asm (no host-cc .c).
# PLATFORM: MACOS Cap tip.
# size_simple authority is named_size_thin (not 2-arg Split soft)
if [ ! -s build_asm/selfhost_pabi/typeck_named_layout_size_split_soft.o ] \
  && [ -f src/asm/named_layout_size_split_a64.s ]; then
  as -arch arm64 -o build_asm/selfhost_pabi/typeck_named_layout_size_split_soft.o \
    src/asm/named_layout_size_split_a64.s \
    && echo "g05_cap_tip_reapply: assembled typeck_named_layout_size_split_soft.o" >&2 \
    || rm -f build_asm/selfhost_pabi/typeck_named_layout_size_split_soft.o
fi
if [ -s build_asm/selfhost_pabi/typeck_named_layout_size_split_soft.o ]; then
  case " $G05_OBJS " in
    *" build_asm/selfhost_pabi/typeck_named_layout_size_split_soft.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/typeck_named_layout_size_split_soft.o $G05_OBJS"
      export G05_OBJS
      echo "g05_cap_tip_reapply: prepended typeck_named_layout_size_split_soft.o" >&2
      ;;
  esac
fi
if [ -s build_asm/selfhost_pabi/typeck_size_simple_split_soft.o ]; then
  case " $G05_OBJS " in
    *" build_asm/selfhost_pabi/typeck_size_simple_split_soft.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/typeck_size_simple_split_soft.o $G05_OBJS"
      export G05_OBJS
      echo "g05_cap_tip_reapply: prepended typeck_size_simple_split_soft.o" >&2
      ;;
  esac
fi
if [ -s build_asm/selfhost_pabi/typeck_asm_local_slot_bytes_split_soft.o ]; then
  case " $G05_OBJS " in
    *" build_asm/selfhost_pabi/typeck_asm_local_slot_bytes_split_soft.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/typeck_asm_local_slot_bytes_split_soft.o $G05_OBJS"
      export G05_OBJS
      echo "g05_cap_tip_reapply: prepended typeck_asm_local_slot_bytes_split_soft.o" >&2
      ;;
  esac
fi
if [ -s build_asm/selfhost_pabi/asm_local_slot_reg_offset_split_soft.o ]; then
  case " $G05_OBJS " in
    *" build_asm/selfhost_pabi/asm_local_slot_reg_offset_split_soft.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/asm_local_slot_reg_offset_split_soft.o $G05_OBJS"
      export G05_OBJS
      echo "g05_cap_tip_reapply: prepended asm_local_slot_reg_offset_split_soft.o" >&2
      ;;
  esac
fi
if [ -s build_asm/selfhost_pabi/fill_local_slots_split_soft.o ]; then
  case " $G05_OBJS " in
    *" build_asm/selfhost_pabi/fill_local_slots_split_soft.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/fill_local_slots_split_soft.o $G05_OBJS"
      export G05_OBJS
      echo "g05_cap_tip_reapply: prepended fill_local_slots_split_soft.o" >&2
      ;;
  esac
fi

# knife256/10.2: Result call-return size soft
# knife256/10.2: tip-compile rt_fmt_one.x when soft .o missing (m8 hollow ret0).
if [ ! -s build_asm/selfhost_pabi/rt_fmt_one_a64.o ] && [ -f src/runtime/rt_fmt_one.x ]; then
  _fmt_xl="$XLANG"
  [ -x ./xlang.restored_1952 ] && _fmt_xl="./xlang.restored_1952"
  if XLANG_PREFER_ASM_O=1 "$_fmt_xl" -backend asm -c src/runtime/rt_fmt_one.x \
      -o build_asm/selfhost_pabi/rt_fmt_one_a64.o.tmp.o >/dev/null 2>&1 \
    && nm -m build_asm/selfhost_pabi/rt_fmt_one_a64.o.tmp.o 2>/dev/null | grep -v weak | grep -q 'external _driver_fmt_one_file$'; then
    mv -f build_asm/selfhost_pabi/rt_fmt_one_a64.o.tmp.o build_asm/selfhost_pabi/rt_fmt_one_a64.o
    echo "g05_cap_tip_reapply: tip-compiled rt_fmt_one_a64.o" >&2
  else
    rm -f build_asm/selfhost_pabi/rt_fmt_one_a64.o.tmp.o
  fi
fi
# knife256/10.2: Cap tip m8 hollow stubbed driver_fmt_one_file (ret0) — real rt_fmt_one first-wins.
if [ -s build_asm/selfhost_pabi/rt_fmt_one_a64.o ]; then
  case " $G05_OBJS " in
    *" build_asm/selfhost_pabi/rt_fmt_one_a64.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/rt_fmt_one_a64.o $G05_OBJS"
      echo "g05_cap_tip_reapply: prepended rt_fmt_one_a64.o" >&2
      ;;
  esac
# llvm-objcopy before fmt demote (set -u)
_oc_sz="${LLVM_OBJCOPY:-}"
[ -n "$_oc_sz" ] || { [ -x /opt/homebrew/opt/llvm/bin/llvm-objcopy ] && _oc_sz=/opt/homebrew/opt/llvm/bin/llvm-objcopy; }
[ -n "$_oc_sz" ] || { [ -x /usr/local/opt/llvm/bin/llvm-objcopy ] && _oc_sz=/usr/local/opt/llvm/bin/llvm-objcopy; }
  for _fmt_stub in build_asm/selfhost_pabi/m8_reloc_stubs.o build_asm/selfhost_pabi/m8_reloc_stubs_g05.o; do
    if [ -s "$_fmt_stub" ] && nm "$_fmt_stub" 2>/dev/null | grep -q 'T _driver_fmt_one_file$'; then
      "$_oc_sz" --redefine-sym=_driver_fmt_one_file=_driver_fmt_one_file__demoted "$_fmt_stub"         && echo "g05_cap_tip_reapply: demoted $_fmt_stub driver_fmt_one_file" >&2 || true
    fi
  done
fi


# knife256/10.2: Cap tip bake_scalar + add_common over m8 hollow ret0 (toplevel-let DATA).
# True-cold wipe drops these softs; tip-compile from .x (no host-cc .c).
if [ ! -s build_asm/selfhost_pabi/add_common_sym_soft.o ]   && [ -f src/runtime_pipeline_abi_add_common_sym_soft.x ]; then
  _acs_xl="$XLANG"
  [ -x ./xlang ] && _acs_xl="./xlang"
  if XLANG_PREFER_ASM_O=1 "$_acs_xl" -backend asm -c       src/runtime_pipeline_abi_add_common_sym_soft.x       -o build_asm/selfhost_pabi/add_common_sym_soft.o 2>/dev/null     && [ -s build_asm/selfhost_pabi/add_common_sym_soft.o ]; then
    echo "g05_cap_tip_reapply: tip-compiled add_common_sym_soft.o" >&2
  else
    rm -f build_asm/selfhost_pabi/add_common_sym_soft.o
  fi
fi
if [ ! -s build_asm/selfhost_pabi/bake_scalar_imm_soft.o ]   && [ -f src/runtime_pipeline_abi_bake_scalar_imm_soft.x ]; then
  _bks_xl="$XLANG"
  [ -x ./xlang ] && _bks_xl="./xlang"
  if XLANG_PREFER_ASM_O=1 "$_bks_xl" -backend asm -c       src/runtime_pipeline_abi_bake_scalar_imm_soft.x       -o build_asm/selfhost_pabi/bake_scalar_imm_soft.o 2>/dev/null     && [ -s build_asm/selfhost_pabi/bake_scalar_imm_soft.o ]; then
    echo "g05_cap_tip_reapply: tip-compiled bake_scalar_imm_soft.o" >&2
  else
    rm -f build_asm/selfhost_pabi/bake_scalar_imm_soft.o
  fi
fi
if [ -s build_asm/selfhost_pabi/bake_scalar_imm_soft.o ]; then
  case " $G05_OBJS " in
    *" build_asm/selfhost_pabi/bake_scalar_imm_soft.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/bake_scalar_imm_soft.o $G05_OBJS"
      export G05_OBJS
      echo "g05_cap_tip_reapply: prepended bake_scalar_imm_soft.o" >&2
      ;;
  esac
fi
if [ -s build_asm/selfhost_pabi/add_common_sym_soft.o ]; then
  case " $G05_OBJS " in
    *" build_asm/selfhost_pabi/add_common_sym_soft.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/add_common_sym_soft.o $G05_OBJS"
      export G05_OBJS
      echo "g05_cap_tip_reapply: prepended add_common_sym_soft.o" >&2
      ;;
  esac
fi

if [ -s build_asm/selfhost_pabi/call_return_byte_size_result_soft.o ]; then
  case " $G05_OBJS " in
    *" build_asm/selfhost_pabi/call_return_byte_size_result_soft.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/call_return_byte_size_result_soft.o $G05_OBJS"
      echo "g05_cap_tip_reapply: prepended call_return_byte_size_result_soft.o" >&2
      ;;
  esac
fi
if [ -s build_asm/selfhost_pabi/field_access_effective_offset_split_soft.o ]; then
  case " $G05_OBJS " in
    *" build_asm/selfhost_pabi/field_access_effective_offset_split_soft.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/field_access_effective_offset_split_soft.o $G05_OBJS"
      export G05_OBJS
      echo "g05_cap_tip_reapply: prepended field_access_effective_offset_split_soft.o" >&2
      ;;
  esac
fi
_oc_sz="${LLVM_OBJCOPY:-}"
[ -n "$_oc_sz" ] || { [ -x /opt/homebrew/opt/llvm/bin/llvm-objcopy ] && _oc_sz=/opt/homebrew/opt/llvm/bin/llvm-objcopy; }
[ -n "$_oc_sz" ] || { [ -x /usr/local/opt/llvm/bin/llvm-objcopy ] && _oc_sz=/usr/local/opt/llvm/bin/llvm-objcopy; }
if [ -n "$_oc_sz" ] && [ -s build_asm/selfhost_pabi/pabi_weak.o ] \
   && [ -s build_asm/selfhost_pabi/typeck_named_layout_size_split_soft.o ]; then
  [ -s build_asm/selfhost_pabi/pabi_weak.o.bak_cap ] || cp -f build_asm/selfhost_pabi/pabi_weak.o build_asm/selfhost_pabi/pabi_weak.o.bak_cap
  cp -f build_asm/selfhost_pabi/pabi_weak.o.bak_cap build_asm/selfhost_pabi/pabi_weak.o
  _sz_redefs=(
    --redefine-sym=_glue_type_named_layout_size_any_module_elf_c=_glue_type_named_layout_size_any_module_elf_c__demoted
  )
  if [ -s build_asm/selfhost_pabi/typeck_size_simple_split_soft.o ]; then
    _sz_redefs+=(--redefine-sym=_glue_type_size_simple=_glue_type_size_simple__demoted)
  fi
  if [ -s build_asm/selfhost_pabi/typeck_asm_local_slot_bytes_split_soft.o ]; then
    _sz_redefs+=(--redefine-sym=_asm_local_slot_bytes=_asm_local_slot_bytes__demoted)
  fi
  if [ -s build_asm/selfhost_pabi/asm_local_slot_reg_offset_split_soft.o ]; then
    _sz_redefs+=(--redefine-sym=_asm_local_slot_reg_offset=_asm_local_slot_reg_offset__demoted)
  fi
  if [ -s build_asm/selfhost_pabi/fill_local_slots_split_soft.o ]; then
    _sz_redefs+=(--redefine-sym=_pipeline_asm_fill_local_slots=_pipeline_asm_fill_local_slots__demoted)
  fi
  if [ -s build_asm/selfhost_pabi/call_return_byte_size_result_soft.o ]; then
    _sz_redefs+=(--redefine-sym=_glue_call_return_byte_size_c=_glue_call_return_byte_size_c__demoted)
  fi
  # knife256/10.2: the missing symbols live in the cap665 thins.
  # Bodies that pabi already defines stay local in those thins, so pabi
  # remains the public definition. Do not weaken or rename them here.
  # PLATFORM: MACOS Cap tip.
  "$_oc_sz" "${_sz_redefs[@]}" build_asm/selfhost_pabi/pabi_weak.o \
    && echo "g05_cap_tip_reapply: demoted pabi_weak Split size/slot/call_return softs" >&2
  # Also demote tip pipeline_abi body if it still owns call_return T
  if [ -s build_asm/selfhost_pabi/call_return_byte_size_result_soft.o ] \
     && [ -s src/runtime_pipeline_abi.o ]; then
    if nm src/runtime_pipeline_abi.o 2>/dev/null | grep -q 'T _glue_call_return_byte_size_c$'; then
      "$_oc_sz" --redefine-sym=_glue_call_return_byte_size_c=_glue_call_return_byte_size_c__demoted \
        src/runtime_pipeline_abi.o \
        && echo "g05_cap_tip_reapply: demoted pipeline_abi call_return" >&2
    fi
  fi
fi
# Demote hollow split_at in leaf mod.o so hand-asm slice.o wins at user link.
# True-cold may rebuild mod.o later; demote runs here and again after slice install.
_demote_slice_mod() {
  local _oc="${1:-${_oc_sz:-${OC:-}}}"
  if [ -z "$_oc" ] || [ ! -s ../core/slice/mod.o ]; then
    return 0
  fi
  if ! nm -gU ../core/slice/mod.o 2>/dev/null | grep -qE 'T _core_slice_split_at_(i32|u8|u64)$'; then
    return 0
  fi
  [ -s ../core/slice/mod.o.bak_pre_split ] || cp -f ../core/slice/mod.o ../core/slice/mod.o.bak_pre_split
  "$_oc" \
    --redefine-sym=_core_slice_split_at_i32=_core_slice_split_at_i32__demoted \
    --redefine-sym=_core_slice_split_at_u8=_core_slice_split_at_u8__demoted \
    --redefine-sym=_core_slice_split_at_u64=_core_slice_split_at_u64__demoted \
    ../core/slice/mod.o \
    && echo "g05_cap_tip_reapply: demoted leaf mod.o split_at (slice.o wins)" >&2 \
    || echo "g05_cap_tip_reapply: WARN demote leaf mod.o split_at failed" >&2
}
_demote_slice_mod "${_oc_sz:-}"

# knife256/10.2: Cap tip/LEGACY pure-asm of runtime_slice_glue.x is hollow
# (bl next-insn). Install hand-asm leaf into ../core/slice/slice.o.
# PLATFORM: MACOS Cap tip leaf (not tip product).
if [ -f src/asm/runtime_slice_glue_a64.s ]; then
  clang -c -o ../core/slice/slice.o src/asm/runtime_slice_glue_a64.s \
    && echo "g05_cap_tip_reapply: installed hand-asm core/slice/slice.o" >&2 \
    || echo "g05_cap_tip_reapply: WARN slice glue install failed" >&2
fi
_demote_slice_mod "${_oc_sz:-${OC:-}}"

# knife256/10.2: Cap tip String (>16B) by-value callees are hollow (8B GP
# slot +0x100). Callers already AAPCS64-byref. Install hand-asm byref
# bodies; demote Cap tip twins in ../std/string/string.o. PLATFORM: MACOS.
if [ -f src/asm/runtime_string_byref_a64.s ]; then
  _sbr_o=build_asm/selfhost_pabi/string_byref_a64.o
  _oc_sbr="${_oc_sz:-${OC:-}}"
  [ -n "$_oc_sbr" ] || { [ -x /opt/homebrew/opt/llvm/bin/llvm-objcopy ] && _oc_sbr=/opt/homebrew/opt/llvm/bin/llvm-objcopy; }
  if clang -c -arch arm64 src/asm/runtime_string_byref_a64.s -o "$_sbr_o" 2>/dev/null \
    && [ -s "$_sbr_o" ] && [ -s ../std/string/string.o ] && [ -n "$_oc_sbr" ]; then
    [ -s ../std/string/string.o.bak_pre_byref ] || cp -f ../std/string/string.o ../std/string/string.o.bak_pre_byref
    cp -f ../std/string/string.o.bak_pre_byref ../std/string/string.o
    _sbr_redefs=()
    for _s in length_String is_empty_String string_get string_eq string_compare \
      string_find_char string_rfind_char string_starts_with string_ends_with \
      string_find_slice string_contains string_copy_to string_eq_view \
      string_compare_view trim; do
      _sym="_std_string_${_s}"
      if nm -gU ../std/string/string.o 2>/dev/null | grep -q "T ${_sym}$"; then
        _sbr_redefs+=("--redefine-sym=${_sym}=${_sym}__hollow")
      fi
    done
    if [ "${#_sbr_redefs[@]}" -gt 0 ]; then
      "$_oc_sbr" "${_sbr_redefs[@]}" ../std/string/string.o \
        && ld -r -o ../std/string/string.o.tmp "$_sbr_o" ../std/string/string.o \
        && mv -f ../std/string/string.o.tmp ../std/string/string.o \
        && echo "g05_cap_tip_reapply: installed string byref overlay (${#_sbr_redefs[@]} demoted)" >&2 \
        || echo "g05_cap_tip_reapply: WARN string byref overlay failed" >&2
    fi
  fi
fi

# knife256/10.2: Cap tip Set_i32 (>16B) by-value callees hollow; insert's
# internal slot reloc also breaks under redefine→__hollow. Hand-asm byref
# find/contains/length/slot/insert/remove. Prefer asm; no FORCE_CC.
# PLATFORM: MACOS Cap tip.
if [ -f src/asm/runtime_set_byref_a64.s ]; then
  _set_o=build_asm/selfhost_pabi/set_byref_a64.o
  _oc_set="${_oc_sz:-${OC:-}}"
  [ -n "$_oc_set" ] || { [ -x /opt/homebrew/opt/llvm/bin/llvm-objcopy ] && _oc_set=/opt/homebrew/opt/llvm/bin/llvm-objcopy; }
  if clang -c -arch arm64 src/asm/runtime_set_byref_a64.s -o "$_set_o" 2>/dev/null \
    && [ -s "$_set_o" ] && [ -s ../std/set/set.o ] && [ -n "$_oc_set" ]; then
    [ -s ../std/set/set.o.bak_pre_byref ] || cp -f ../std/set/set.o ../std/set/set.o.bak_pre_byref
    cp -f ../std/set/set.o.bak_pre_byref ../std/set/set.o
    _set_redefs=()
    for _sym in _std_set_find_Set_i32_i32 _std_set_contains_key_Set_i32_i32 \
      _std_set_length_Set_i32 _std_set_is_empty _std_set_slot_Set_i32_i32 \
      _std_set_insert_Set_i32_ptr_i32 _std_set_remove_Set_i32_ptr_i32; do
      if nm -gU ../std/set/set.o 2>/dev/null | grep -q "T ${_sym}$"; then
        _set_redefs+=("--redefine-sym=${_sym}=${_sym}__hollow")
      fi
    done
    if [ "${#_set_redefs[@]}" -gt 0 ]; then
      "$_oc_set" "${_set_redefs[@]}" ../std/set/set.o \
        && ld -r -o ../std/set/set.o.tmp "$_set_o" ../std/set/set.o \
        && mv -f ../std/set/set.o.tmp ../std/set/set.o \
        && echo "g05_cap_tip_reapply: installed set byref overlay (${#_set_redefs[@]} demoted)" >&2 \
        || echo "g05_cap_tip_reapply: WARN set byref overlay failed" >&2
    fi
  fi
fi


# knife256/10.2: Cap tip leftover compress — wipe drops zlib Init2 glue;
# nested core_mem U never pulls mem.o. Ensure glue + gzip mem stubs.
# Prefer asm; no FORCE_CC. PLATFORM: MACOS Cap tip.
if [ -f scripts/cap_tip_ensure_compress_leave_darwin.sh ]; then
  bash scripts/cap_tip_ensure_compress_leave_darwin.sh \
    && echo "g05_cap_tip_reapply: ensured Cap tip compress leave" >&2 \
    || echo "g05_cap_tip_reapply: WARN compress leave ensure failed" >&2
fi

# knife256/10.2: Cap tip leftover FS — true-cold wipe drops fs.o; Cap tip
# cannot rebuild formal std.fs. Ensure leave via LEGACY pure-asm + Darwin
# ___error + dir_cap merge. Prefer asm; no FORCE_CC. PLATFORM: MACOS.
if [ -f scripts/cap_tip_ensure_fs_leave_darwin.sh ]; then
  if [ -x ./xlang.product_legacy_bak ] || [ -x "${XLANG:-}" ]; then
    bash scripts/cap_tip_ensure_fs_leave_darwin.sh ../std/fs/fs.o \
      && echo "g05_cap_tip_reapply: ensured Cap tip fs leave" >&2 \
      || echo "g05_cap_tip_reapply: WARN fs leave ensure failed" >&2
  fi
fi

# knife256/10.2: Cap tip Queue_i32 (>16B) by-value at/get/length hollow;
# push_* call at(*q) → SEGV on leftover run-queue. Also queue.o U
# _sync_queue_contention_smoke_c (BLD001). Hand-asm byref + weak smoke
# ld -r into queue.o. Prefer asm; no FORCE_CC / host-cc .c.
# PLATFORM: MACOS Cap tip.
if [ -f src/asm/runtime_queue_byref_a64.s ]; then
  _q_o=build_asm/selfhost_pabi/queue_byref_a64.o
  _q_smoke=build_asm/selfhost_pabi/queue_smoke_weak_a64.o
  _oc_q="${_oc_sz:-${OC:-}}"
  [ -n "$_oc_q" ] || { [ -x /opt/homebrew/opt/llvm/bin/llvm-objcopy ] && _oc_q=/opt/homebrew/opt/llvm/bin/llvm-objcopy; }
  if clang -c -arch arm64 src/asm/runtime_queue_byref_a64.s -o "$_q_o" 2>/dev/null \
    && [ -s "$_q_o" ] && [ -s ../std/queue/queue.o ] && [ -n "$_oc_q" ]; then
    [ -s ../std/queue/queue.o.bak_pre_byref ] || cp -f ../std/queue/queue.o ../std/queue/queue.o.bak_pre_byref
    cp -f ../std/queue/queue.o.bak_pre_byref ../std/queue/queue.o
    _q_redefs=()
    for _sym in _std_queue_at_Queue_i32_i32 _std_queue_get \
      _std_queue_length_Queue_i32 _std_queue_is_empty_Queue_i32 \
      _std_queue_grow_Queue_i32_ptr \
      _std_queue_push_back_Queue_i32_ptr_i32 _std_queue_push_front \
      _std_queue_pop_back _std_queue_pop_front_Queue_i32_ptr; do
      if nm -gU ../std/queue/queue.o 2>/dev/null | grep -q "T ${_sym}$"; then
        _q_redefs+=("--redefine-sym=${_sym}=${_sym}__hollow")
      fi
    done
    # Weak smoke: satisfy queue.o U without pulling OS-mutex contention.o.
    _q_extra=("$_q_o")
    if [ -f src/asm/runtime_queue_smoke_weak_a64.s ] \
      && clang -c -arch arm64 src/asm/runtime_queue_smoke_weak_a64.s -o "$_q_smoke" 2>/dev/null \
      && [ -s "$_q_smoke" ]; then
      _q_extra+=("$_q_smoke")
    fi
    if [ "${#_q_redefs[@]}" -gt 0 ]; then
      "$_oc_q" "${_q_redefs[@]}" ../std/queue/queue.o \
        && ld -r -o ../std/queue/queue.o.tmp "${_q_extra[@]}" ../std/queue/queue.o \
        && mv -f ../std/queue/queue.o.tmp ../std/queue/queue.o \
        && "$_oc_q" --weaken-symbol=_sync_queue_contention_smoke_c ../std/queue/queue.o \
        && echo "g05_cap_tip_reapply: installed queue byref overlay (${#_q_redefs[@]} demoted + smoke)" >&2 \
        || echo "g05_cap_tip_reapply: WARN queue byref overlay failed" >&2
    fi
  fi
fi

# knife256/10.2: Cap tip net leftover — two UNDEFs:
#   _thread_set_qos_class_self_c (thread.o) and
#   _xlang_net_worker_accept_entry_ptr_c (net.o).
# Prefer pure-asm: Cap tip thread-glue-pure (25 _c) + weak *_impl stubs;
# darwin net_workers pure + weak io submit; net.o ____error retarget.
# No host-cc seed .c / FORCE_CC / pin. PLATFORM: MACOS Cap tip.
_cap_tip_net_leftover_leaves() {
  local _oc="${_oc_sz:-${OC:-}}"
  [ -n "$_oc" ] || { [ -x /opt/homebrew/opt/llvm/bin/llvm-objcopy ] && _oc=/opt/homebrew/opt/llvm/bin/llvm-objcopy; }
  [ -n "$_oc" ] || { [ -x /usr/local/opt/llvm/bin/llvm-objcopy ] && _oc=/usr/local/opt/llvm/bin/llvm-objcopy; }
  mkdir -p build_asm/selfhost_pabi
  # thread_glue: Cap tip pure _c + weak residual stubs + strong Darwin
  # pthread impl (self/create/join/dummy). Prefer asm; no host-cc rest.
  if [ -x ./xlang_asm ] && [ -f src/asm/runtime_thread_glue.x ] \
     && [ -f src/asm/runtime_thread_impl_stubs_a64.s ]; then
    local _tg_thin _tg_impl _tg_dar
    _tg_thin=build_asm/selfhost_pabi/thread_glue_thin_a64.o
    _tg_impl=build_asm/selfhost_pabi/thread_impl_stubs_a64.o
    _tg_dar=build_asm/selfhost_pabi/thread_impl_darwin_a64.o
    if bash scripts/ensure_host_cc_seed_o.sh thread-glue-pure "$_tg_thin" 2>/dev/null \
       && [ -s "$_tg_thin" ] \
       && clang -c -arch arm64 src/asm/runtime_thread_impl_stubs_a64.s -o "$_tg_impl" 2>/dev/null \
       && [ -s "$_tg_impl" ] \
       && { [ ! -f src/asm/runtime_thread_impl_darwin_a64.s ] \
            || clang -c -arch arm64 src/asm/runtime_thread_impl_darwin_a64.s -o "$_tg_dar" 2>/dev/null; } \
       && { if [ -s "$_tg_dar" ]; then
             ld -r -o runtime_thread_glue.o "$_tg_thin" "$_tg_impl" "$_tg_dar" 2>/dev/null
           else
             ld -r -o runtime_thread_glue.o "$_tg_thin" "$_tg_impl" 2>/dev/null
           fi; }; then
      echo "g05_cap_tip_reapply: installed thread_glue pure+stubs+darwin-impl (no host-cc)" >&2
    else
      echo "g05_cap_tip_reapply: WARN thread_glue pure+impl-stubs failed" >&2
      if [ -s "$CACHE/leaves/runtime_thread_glue.o" ]; then
        cp -f "$CACHE/leaves/runtime_thread_glue.o" runtime_thread_glue.o           && echo "g05_cap_tip_reapply: restored thread_glue from L4 leaves cache" >&2
      fi
    fi
  fi
  # net_workers darwin pure; demote affinity twin; merge weak io submit
  if [ -x ./xlang_asm ] && [ -f src/asm/runtime_net_workers_darwin.x ] \
     && [ -f src/asm/runtime_net_io_weak_stubs_a64.s ] && [ -n "$_oc" ]; then
    local _nw _nw_io
    _nw=build_asm/selfhost_pabi/net_workers_darwin.o
    _nw_io=build_asm/selfhost_pabi/net_io_weak_stubs.o
    if ./xlang_asm -backend asm -c src/asm/runtime_net_workers_darwin.x -o "$_nw" 2>/dev/null \
       && [ -s "$_nw" ] \
       && clang -c -arch arm64 src/asm/runtime_net_io_weak_stubs_a64.s -o "$_nw_io" 2>/dev/null \
       && [ -s "$_nw_io" ]; then
      if nm -gU "$_nw" 2>/dev/null | grep -q 'T _thread_set_affinity_self_c$'; then
        "$_oc" --redefine-sym=_thread_set_affinity_self_c=_thread_set_affinity_self_c__net_weak "$_nw" || true
      fi
      if ld -r -o runtime_net_workers.o "$_nw_io" "$_nw" 2>/dev/null; then
        echo "g05_cap_tip_reapply: installed net_workers + weak io submit stubs" >&2
      else
        echo "g05_cap_tip_reapply: WARN net_workers merge failed" >&2
      fi
    else
      echo "g05_cap_tip_reapply: WARN net_workers darwin pure failed" >&2
      if [ -s "$CACHE/leaves/runtime_net_workers.o" ]; then
        cp -f "$CACHE/leaves/runtime_net_workers.o" runtime_net_workers.o           && echo "g05_cap_tip_reapply: restored net_workers from L4 leaves cache" >&2
      fi
    fi
  fi
  # Cap tip net.o libc mangling: ____error → ___error (Darwin)
  if [ -n "$_oc" ] && [ -s ../std/net/net.o ]; then
    if nm -u ../std/net/net.o 2>/dev/null | grep -q '^____error$'; then
      [ -s ../std/net/net.o.bak_pre_errno ] || cp -f ../std/net/net.o ../std/net/net.o.bak_pre_errno
      "$_oc" --redefine-sym=____error=___error --redefine-sym=____fcntl=___fcntl \
        ../std/net/net.o \
        && echo "g05_cap_tip_reapply: retargeted net.o ____error/____fcntl" >&2 \
        || echo "g05_cap_tip_reapply: WARN net.o errno retarget failed" >&2
    fi
  fi
  # need_net companion driver.o leaf (prefer asm formal)
  if [ -f src/asm/std_io_driver_formal_darwin.x ] && [ -x ./xlang_asm ]; then
    mkdir -p ../std/io
    if [ ! -s ../std/io/driver.o ] || [ src/asm/std_io_driver_formal_darwin.x -nt ../std/io/driver.o ]; then
      if ./xlang_asm -backend asm -c src/asm/std_io_driver_formal_darwin.x \
           -o ../std/io/driver.o 2>/dev/null && [ -s ../std/io/driver.o ]; then
        echo "g05_cap_tip_reapply: installed std/io/driver.o (formal darwin)" >&2
      fi
    fi
  fi
  # Formal driver.o strong wins vs stubs write_batch (ensure may miss weaken).
  # PLATFORM: MACOS Cap tip · pure-ld no multiply_defined.
  if [ -n "$_oc" ] && [ -s runtime_asm_io_stubs.o ] && [ -s ../std/io/driver.o ]; then
    for _ws in _std_io_driver_submit_write_batch \
               _std_io_driver_submit_read_batch_buf \
               _std_io_driver_submit_write_batch_buf; do
      if nm -m runtime_asm_io_stubs.o 2>/dev/null | grep -E " ${_ws}\$" | grep -qv weak; then
        "$_oc" --weaken-symbol="$_ws" runtime_asm_io_stubs.o 2>/dev/null \
          && echo "g05_cap_tip_reapply: weakened stubs ${_ws} (driver.o wins)" >&2 || true
      fi
    done
    unset _ws
  fi
}
_cap_tip_net_leftover_leaves

# knife256/10.2: Cap tip ondemand scans user.o only → slice/mod.o option
# UNDEFs missed when main only uses slice API. Soft-extend option needles.
# PLATFORM: MACOS Cap tip.
if [ -f src/asm/labi_od_option_slice_needles_a64.s ]; then
  clang -c -o build_asm/selfhost_pabi/labi_od_option_slice_needles_a64.o \
    src/asm/labi_od_option_slice_needles_a64.s \
    || { echo "g05_cap_tip_reapply: option_slice needles assemble failed" >&2; exit 1; }
fi
if [ -s build_asm/selfhost_pabi/labi_od_option_slice_needles_a64.o ]; then
  case " $G05_OBJS " in
    *" build_asm/selfhost_pabi/labi_od_option_slice_needles_a64.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/labi_od_option_slice_needles_a64.o $G05_OBJS"
      export G05_OBJS
      echo "g05_cap_tip_reapply: prepended labi_od_option_slice_needles_a64.o" >&2
      ;;
  esac
  _oc_od="${LLVM_OBJCOPY:-}"
  [ -n "$_oc_od" ] || { [ -x /opt/homebrew/opt/llvm/bin/llvm-objcopy ] && _oc_od=/opt/homebrew/opt/llvm/bin/llvm-objcopy; }
  [ -n "$_oc_od" ] || { [ -x /usr/local/opt/llvm/bin/llvm-objcopy ] && _oc_od=/usr/local/opt/llvm/bin/llvm-objcopy; }
  if [ -n "$_oc_od" ] && [ -s src/runtime_link_abi.o ]; then
    [ -s src/runtime_link_abi.o.bak_cap ] || cp -f src/runtime_link_abi.o src/runtime_link_abi.o.bak_cap
    cp -f src/runtime_link_abi.o.bak_cap src/runtime_link_abi.o
    "$_oc_od" \
      --redefine-sym=_labi_od_simple_group_sym_count=_labi_od_simple_group_sym_count__demoted \
      --redefine-sym=_labi_od_simple_group_sym_at=_labi_od_simple_group_sym_at__demoted \
      src/runtime_link_abi.o \
      && echo "g05_cap_tip_reapply: demoted link_abi option/slice needles" >&2
    python3 scripts/g05_cap_tip_link_abi_needle_retarget.py src/runtime_link_abi.o \
      && echo "g05_cap_tip_reapply: retargeted link_abi needle callers" >&2
  fi
fi

# knife256/10.2: Cap tip skip-typeck dep layouts leave Split_*.left type_ref=0
# → INDEX on sp.left fails "subscript base". Prepend field type_ref/offset softs.
# PLATFORM: MACOS Cap tip.
if [ -s build_asm/selfhost_pabi/typeck_field_type_ref_deps_soft.o ]; then
  case " $G05_OBJS " in
    *" build_asm/selfhost_pabi/typeck_field_type_ref_deps_soft.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/typeck_field_type_ref_deps_soft.o $G05_OBJS"
      export G05_OBJS
      echo "g05_cap_tip_reapply: prepended typeck_field_type_ref_deps_soft.o" >&2
      ;;
  esac
fi
if [ -s build_asm/selfhost_pabi/typeck_field_offset_deps_soft.o ]; then
  case " $G05_OBJS " in
    *" build_asm/selfhost_pabi/typeck_field_offset_deps_soft.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/typeck_field_offset_deps_soft.o $G05_OBJS"
      export G05_OBJS
      echo "g05_cap_tip_reapply: prepended typeck_field_offset_deps_soft.o" >&2
      ;;
  esac
fi

# knife256/10.2: Cap tip find_layout name_byte_at!=name[j] clobber → Type.method miss.
if [ -s build_asm/selfhost_pabi/typeck_soa_find_layout_idx_by_name_soft.o ]; then
  case " $G05_OBJS " in
    *" build_asm/selfhost_pabi/typeck_soa_find_layout_idx_by_name_soft.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/typeck_soa_find_layout_idx_by_name_soft.o $G05_OBJS"
      export G05_OBJS
      echo "g05_cap_tip_reapply: prepended typeck_soa_find_layout_idx_by_name_soft.o" >&2
      ;;
  esac
fi

if [ -s build_asm/selfhost_pabi/typeck_type_is_free_type_param_soft.o ]; then
  case " $G05_OBJS " in
    *" build_asm/selfhost_pabi/typeck_type_is_free_type_param_soft.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/typeck_type_is_free_type_param_soft.o $G05_OBJS"
      export G05_OBJS
      echo "g05_cap_tip_reapply: prepended typeck_type_is_free_type_param_soft.o" >&2
      ;;
  esac
fi
if [ -s build_asm/selfhost_pabi/typeck_method_call_resolve_generic_bound_soft.o ]; then
  case " $G05_OBJS " in
    *" build_asm/selfhost_pabi/typeck_method_call_resolve_generic_bound_soft.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/typeck_method_call_resolve_generic_bound_soft.o $G05_OBJS"
      echo "g05_cap_tip_reapply: prepended typeck_method_call_resolve_generic_bound_soft.o" >&2
      ;;
  esac
fi
if [ -s build_asm/selfhost_pabi/generic_bound_scan_from_stash_a64.o ]; then
  case " $G05_OBJS " in
    *" build_asm/selfhost_pabi/generic_bound_scan_from_stash_a64.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/generic_bound_scan_from_stash_a64.o $G05_OBJS"
      echo "g05_cap_tip_reapply: prepended generic_bound_scan_from_stash_a64.o" >&2
      ;;
  esac
fi

# Same-TU demoted call sites: trampoline __demoted -> soft.
if [ -s build_asm/selfhost_pabi/typeck_soa_find_layout_idx_by_name_demoted_tramp_a64.o ]; then
  case " $G05_OBJS " in
    *" build_asm/selfhost_pabi/typeck_soa_find_layout_idx_by_name_demoted_tramp_a64.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/typeck_soa_find_layout_idx_by_name_demoted_tramp_a64.o $G05_OBJS"
      export G05_OBJS
      echo "g05_cap_tip_reapply: prepended find_layout demoted trampoline" >&2
      ;;
  esac
fi

if [ -s build_asm/selfhost_pabi/typeck_type_is_free_type_param_demoted_tramp_a64.o ]; then
  case " $G05_OBJS " in
    *" build_asm/selfhost_pabi/typeck_type_is_free_type_param_demoted_tramp_a64.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/typeck_type_is_free_type_param_demoted_tramp_a64.o $G05_OBJS"
      export G05_OBJS
      echo "g05_cap_tip_reapply: prepended free_param demoted trampoline" >&2
      ;;
  esac
fi
if [ -s build_asm/selfhost_pabi/typeck_method_call_resolve_generic_bound_demoted_tramp_a64.o ]; then
  case " $G05_OBJS " in
    *" build_asm/selfhost_pabi/typeck_method_call_resolve_generic_bound_demoted_tramp_a64.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/typeck_method_call_resolve_generic_bound_demoted_tramp_a64.o $G05_OBJS"
      echo "g05_cap_tip_reapply: prepended generic_bound demoted trampoline" >&2
      ;;
  esac
fi

# knife256/10.2: ARRAY_LIT kind 46 stores lane bytes via
# pipeline_asm_emit_vector_let_init. Other kinds return -3 so VAR try_let
# does not swallow scalar i=i+1. Do not assemble the emptied decline .s
# (it no longer defines the symbol). PLATFORM: MACOS|ARM64.
# Tip-compile decline with Cap tip product ./xlang (idle-sized), NOT ./xlang_asm.
# Reject truncated .o (<30KB; hung xlang_asm left bad bodies @0x1bac).
# Unset XLANG_CAP_TIP_L4_CACHE for this compile (seed path BLD001). PLATFORM: MACOS Cap tip.
if [ -f src/asm/vector_let_init_array_lit_a64.x ] && [ -x ./xlang ]; then
  _dec_o=build_asm/selfhost_pabi/vector_let_init_decline_a64.o
  _dec_sz=$(wc -c <"$_dec_o" 2>/dev/null || echo 0)
  if [ "$_dec_sz" -lt 30000 ]; then
    rm -f "$_dec_o"
    env -u XLANG -u XLANG_FORCE -u FORCE -u PREFER -u G05 -u RUN_ALL_USE_C \
      -u XLANG_CAP_TIP_L4_CACHE \
      XLANG_PREFER_ASM_O=1 ./xlang -backend asm -c \
      src/asm/vector_let_init_array_lit_a64.x \
      -o "$_dec_o" \
      || { echo "g05_cap_tip_reapply: vector let-init array-lit compile failed" >&2; exit 1; }
    echo "g05_cap_tip_reapply: tip-compiled vector_let_init_decline_a64.o" >&2
  else
    echo "g05_cap_tip_reapply: reuse good vector_let_init_decline_a64.o (sz=$_dec_sz)" >&2
  fi
fi
if [ -s build_asm/selfhost_pabi/vector_let_init_decline_a64.o ]; then
  case " $G05_OBJS " in
    *" build_asm/selfhost_pabi/vector_let_init_decline_a64.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/vector_let_init_decline_a64.o $G05_OBJS"
      export G05_OBJS
      echo "g05_cap_tip_reapply: prepended vector_let_init_decline_a64.o" >&2
      ;;
  esac
fi

# knife256/10.2: Cap tip frozen env omits assign dispatcher; m8 hollow returns 0
# so a[i]= is a silent no-op (fmt-wrap 3≠16). Prepend VAR+INDEX thin
# (src/asm/assign_emit_index_only_a64.s → assign_emit_thin_a64.o). FIELD/DEREF stay no-op; VAR for while body. Restore/build from cache or .s. PLATFORM: MACOS Cap tip.
# Prefer VAR+INDEX .s when present (while body i=i+1); do not keep stale INDEX-only .o.
if [ -f src/asm/assign_emit_var_index_a64.s ]; then
  clang -c -o build_asm/selfhost_pabi/assign_emit_thin_a64.o src/asm/assign_emit_var_index_a64.s \
    || { echo "g05_cap_tip_reapply: assign_emit_var_index assemble failed" >&2; exit 1; }
  echo "g05_cap_tip_reapply: rebuilt assign_emit_thin from var_index.s" >&2
elif [ ! -s build_asm/selfhost_pabi/assign_emit_thin_a64.o ]; then
  if [ -s "$CACHE/pabi/assign_emit_thin_a64.o" ]; then
    cp -f "$CACHE/pabi/assign_emit_thin_a64.o" build_asm/selfhost_pabi/assign_emit_thin_a64.o
  elif [ -f src/asm/assign_emit_index_only_a64.s ]; then
    clang -c -o build_asm/selfhost_pabi/assign_emit_thin_a64.o src/asm/assign_emit_index_only_a64.s \
      || { echo "g05_cap_tip_reapply: assign_emit_thin assemble failed" >&2; exit 1; }
  fi
fi
if [ -s build_asm/selfhost_pabi/assign_emit_thin_a64.o ]; then
  case " $G05_OBJS " in
    *" build_asm/selfhost_pabi/assign_emit_thin_a64.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/assign_emit_thin_a64.o $G05_OBJS"
      export G05_OBJS
      echo "g05_cap_tip_reapply: prepended assign_emit_thin_a64.o (INDEX assign)" >&2
      ;;
  esac
fi

# knife256/10.2: Cap tip diag.o human/with_code/print_header X-codegen clobber
# → SEGV on illegal char (L003). Demote Cap tip human/with_code; prepend
# write-based overlay (src/asm/diag_report_human_cap_a64.s). PLATFORM: MACOS Cap tip.
OC_L003="${LLVM_OBJCOPY:-}"
if [ -z "$OC_L003" ]; then
  for c in /opt/homebrew/opt/llvm/bin/llvm-objcopy /usr/local/opt/llvm/bin/llvm-objcopy; do
    [ -x "$c" ] && OC_L003=$c && break
  done
fi
if [ -n "$OC_L003" ] && [ -s src/diag.o ]; then
  # Weaken (not redefine): redefine rewrites same-TU vreportf→*_dead and
  # check still SEGV139 in the dead body. Weak + Cap overlay strong interposes.
  # PLATFORM: MACOS Cap tip.
  if nm -m src/diag.o 2>/dev/null | grep -q 'external _diag_report_human$'; then
    [ -s src/diag.o.bak_cap ] || cp -f src/diag.o src/diag.o.bak_cap
    "$OC_L003" \
      --weaken-symbol=_diag_report_human \
      --weaken-symbol=_diag_report_with_code \
      --weaken-symbol=_diag_report \
      src/diag.o
    echo "g05_cap_tip_reapply: weakened Cap tip diag human/with_code" >&2
  fi
fi
if [ ! -s build_asm/selfhost_pabi/diag_report_human_cap_a64.o ]; then
  if [ -s "$CACHE/pabi/diag_report_human_cap_a64.o" ]; then
    cp -f "$CACHE/pabi/diag_report_human_cap_a64.o" build_asm/selfhost_pabi/diag_report_human_cap_a64.o
  elif [ -f src/asm/diag_report_human_cap_a64.s ]; then
    clang -c -o build_asm/selfhost_pabi/diag_report_human_cap_a64.o src/asm/diag_report_human_cap_a64.s \
      || { echo "g05_cap_tip_reapply: L003 human overlay assemble failed" >&2; exit 1; }
  fi
fi
if [ -s build_asm/selfhost_pabi/diag_report_human_cap_a64.o ]; then
  case " $G05_OBJS " in
    *" build_asm/selfhost_pabi/diag_report_human_cap_a64.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/diag_report_human_cap_a64.o $G05_OBJS"
      export G05_OBJS
      echo "g05_cap_tip_reapply: prepended diag_report_human_cap_a64.o (L003)" >&2
      ;;
  esac
fi


# knife256/10.2: Cap tip diag snap/ctx hollow → check SEGV. Soft LE loaders +
# ctx getters/setters/restore/push_file; demote Cap tip diag.o twins.
# PLATFORM: MACOS Cap tip.
if [ ! -s build_asm/selfhost_pabi/diag_snap_load_ptr_a64.o ]; then
  if [ -s "$CACHE/pabi/diag_snap_load_ptr_a64.o" ]; then
    cp -f "$CACHE/pabi/diag_snap_load_ptr_a64.o" build_asm/selfhost_pabi/diag_snap_load_ptr_a64.o
  elif [ -f src/asm/diag_snap_load_ptr_a64.s ]; then
    clang -c -o build_asm/selfhost_pabi/diag_snap_load_ptr_a64.o src/asm/diag_snap_load_ptr_a64.s \
      || { echo "g05_cap_tip_reapply: diag_snap soft assemble failed" >&2; exit 1; }
  fi
fi
if [ -s build_asm/selfhost_pabi/diag_snap_load_ptr_a64.o ]; then
  case " $G05_OBJS " in
    *" build_asm/selfhost_pabi/diag_snap_load_ptr_a64.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/diag_snap_load_ptr_a64.o $G05_OBJS"
      export G05_OBJS
      echo "g05_cap_tip_reapply: prepended diag_snap_load_ptr_a64.o (check)" >&2
      ;;
  esac
fi
if [ -n "$OC_L003" ] && [ -s src/diag.o ]; then
  [ -s src/diag.o.bak_cap ] || cp -f src/diag.o src/diag.o.bak_cap
  # Restore bak then weaken report+ctx+snap (Cap/soft strong first-win).
  # Do not redefine→*_dead: same-TU diag_vreportf would call the dead body
  # (check SEGV139). PLATFORM: MACOS Cap tip.
  cp -f src/diag.o.bak_cap src/diag.o
  "$OC_L003" \
    --weaken-symbol=_diag_report_human \
    --weaken-symbol=_diag_report_with_code \
    --weaken-symbol=_diag_report \
    --weaken-symbol=_diag_restore \
    --weaken-symbol=_diag_push_file \
    --weaken-symbol=_diag_ctx_get_file \
    --weaken-symbol=_diag_ctx_get_source \
    --weaken-symbol=_diag_ctx_get_source_len \
    --weaken-symbol=_diag_ctx_get_use_color \
    --weaken-symbol=_diag_ctx_set_all \
    --weaken-symbol=_diag_snap_load_ptr \
    --weaken-symbol=_diag_snap_load_usize \
    --weaken-symbol=_diag_snap_load_i32 \
    --weaken-symbol=_diag_snap_store_ptr \
    --weaken-symbol=_diag_snap_store_usize \
    --weaken-symbol=_diag_snap_store_i32 \
    src/diag.o
  echo "g05_cap_tip_reapply: weakened Cap tip diag report/ctx/snap" >&2
fi


# Demote m8 symbols whose Cap tip thins are now in G05_OBJS (after INDEX/L003 prepend).
_oc="${LLVM_OBJCOPY:-}"
[ -n "$_oc" ] || { [ -x /opt/homebrew/opt/llvm/bin/llvm-objcopy ] && _oc=/opt/homebrew/opt/llvm/bin/llvm-objcopy; }
if [ -n "$_oc" ] && [ -s build_asm/selfhost_pabi/m8_reloc_stubs_g05.o ]; then
  for _pair in \
    "build_asm/selfhost_pabi/body_sync_let_order.o|_backend_emit_block_body_sync_elf" \
    "build_asm/selfhost_pabi/body_sync_let_order.o|_pipeline_asm_emit_block_body_sync_elf" \
    "build_asm/selfhost_pabi/return_sret.o|_pipeline_asm_emit_return_elf_impl" \
    "build_asm/selfhost_pabi/macho_write_a64.o|_platform_macho_write_macho_o_to_buf" \
    "build_asm/selfhost_pabi/assign_emit_thin_a64.o|_pipeline_asm_emit_assign_elf_c"; do
    _thin="${_pair%%|*}"
    _s="${_pair##*|}"
    case " $G05_OBJS " in
      *" ${_thin} "*)
        if [ -s "$_thin" ] && nm -gU "$_thin" 2>/dev/null | grep -q "T ${_s}$"; then
          "$_oc" --redefine-sym="${_s}=${_s}_m8_g05_dead" build_asm/selfhost_pabi/m8_reloc_stubs_g05.o 2>/dev/null || true
        fi
        ;;
    esac
  done
fi

# knife256/10.2: m8 pipeline_elf_ctx_add_common_sym is an 8-byte ret0.
# Line 159 recopies m8_reloc_stubs.o over the g05 stub and can restore that
# strong hollow after add_common_sym_soft.o is prepended. Weaken this one
# symbol so the soft wins. Do not redefine it: a redefine rewrites relocs
# inside the stub. The soft stores shndx 65522; macho_write already emits
# that shndx as a Mach-O common.
# PLATFORM: MACOS — Apple ld rejects two strong definitions of one symbol.
if [ -n "${_oc:-}" ] && [ -s build_asm/selfhost_pabi/add_common_sym_soft.o ] \
   && [ -s build_asm/selfhost_pabi/m8_reloc_stubs_g05.o ]; then
  case " $G05_OBJS " in
    *" build_asm/selfhost_pabi/add_common_sym_soft.o "*)
      "$_oc" --weaken-symbol=_pipeline_elf_ctx_add_common_sym \
        build_asm/selfhost_pabi/m8_reloc_stubs_g05.o 2>/dev/null \
        && echo "g05_cap_tip_reapply: weakened m8 add_common_sym (soft wins)" >&2 || true
      ;;
  esac
fi

# knife256/10.2: weaken leftover glue_sysv_arg_byte_size_c so Cap tip thin
# first-wins; redefine-sym would rename packer call sites to _dispatch_dead.
# PLATFORM: MACOS Cap tip.
if [ -n "$OC" ] && [ -s src/asm/backend_call_dispatch.o ]; then
  if [ -s src/asm/backend_call_dispatch.o.bak_pre_argbs ]; then
    cp -f src/asm/backend_call_dispatch.o.bak_pre_argbs src/asm/backend_call_dispatch.o
  elif [ -s "$CACHE/backend_call_dispatch.o.bak_pre_argbs" ]; then
    cp -f "$CACHE/backend_call_dispatch.o.bak_pre_argbs" src/asm/backend_call_dispatch.o
  fi
  if nm -m src/asm/backend_call_dispatch.o 2>/dev/null | grep -q 'external _glue_sysv_arg_byte_size_c$'; then
    "$OC" --weaken-symbol=_glue_sysv_arg_byte_size_c src/asm/backend_call_dispatch.o
    echo "g05_cap_tip_reapply: weakened dispatch arg_byte_size (thin wins)" >&2
  fi
fi

# knife256/10.2: the 10.7MB product runs the fixed_array_copy thin for
# these four names. pabi and return_sret still have the older bodies.
# A strong older body drops the wide-array return copy (4-layer probe
# then SIGSEGV). Weaken them so the thin is the one definition.
# PLATFORM: MACOS Cap tip.
if [ -s build_asm/selfhost_pabi/cap665_fixed_array_copy.o ] && [ -n "${OC:-}" ]; then
  "$OC" \
    --weaken-symbol=_glue_call_arg_var_use_lea_not_load_elf_c \
    --weaken-symbol=_glue_struct_lit_store_fixed_array_field_elf_c \
    --weaken-symbol=_pipeline_asm_emit_array_lit_flat_elf_c \
    build_asm/selfhost_pabi/pabi_weak.o \
    && echo "g05_cap_tip_reapply: weakened pabi fixed-array bodies" >&2
  if [ -s build_asm/selfhost_pabi/return_sret.o ]; then
    "$OC" --weaken-symbol=_pipeline_asm_emit_return_elf_impl \
      build_asm/selfhost_pabi/return_sret.o \
      && echo "g05_cap_tip_reapply: weakened return_sret emit_return" >&2
  fi
fi

# knife256/10.2: five symbols the frozen env no longer defines.
# Authority is the thin .x each one is written in. Objects are produced
# by the current product (-backend asm -c), not a second body.
# PLATFORM: MACOS Cap tip.
for _cap665 in \
  build_asm/selfhost_pabi/cap665_lane_f32_binop.o \
  build_asm/selfhost_pabi/cap665_func_return_byte_size.o \
  build_asm/selfhost_pabi/cap665_fixed_array_copy.o \
  build_asm/selfhost_pabi/cap665_fa_only.o \
  build_asm/selfhost_pabi/cap665_modlet_elem_const.o \
  build_asm/selfhost_pabi/cap665_lane_f32_lit_operand.o \
  build_asm/selfhost_pabi/cap665_lane_scalar_binop.o \
  build_asm/selfhost_pabi/cap665_addr_of_call.o \
  build_asm/selfhost_pabi/cap665_keep_stubs.o
do
  if [ -s "$_cap665" ]; then
    case " $G05_OBJS " in
      *" $_cap665 "*) ;;
      *)
        G05_OBJS="$_cap665 $G05_OBJS"
        export G05_OBJS
        echo "g05_cap_tip_reapply: prepended $(basename "$_cap665")" >&2
        ;;
    esac
  fi
done

rm -f xlang.cap_g05_l2


# knife256/10.2: type_ref_to_suffix empty-reject (caller-arg mid needs it too).
if [ -s build_asm/selfhost_pabi/glue_type_ref_suffix_empty_reject_soft.o ]; then
  case " $G05_OBJS " in
    *" glue_type_ref_suffix_empty_reject_soft.o "*) ;;
    *)
      G05_OBJS="build_asm/selfhost_pabi/glue_type_ref_suffix_empty_reject_soft.o $G05_OBJS"
      export G05_OBJS
      echo "g05_cap_tip_reapply: prepended glue_type_ref_suffix_empty_reject_soft.o" >&2
      ;;
  esac
fi
# knife256/10.2: demote dispatch mid so empty-reject soft first-wins (after ensure rebuild).
# WEAKEN (not redefine): redefine rewrites call sites inside dispatch.o to __bcd_dead.
if [ -n "${OC:-}" ] && [ -s src/asm/backend_call_dispatch.o ]; then
  if [ -s build_asm/selfhost_pabi/glue_overload_mid_empty_reject_soft.o ]; then
    "$OC" --weaken-symbol=_glue_asm_build_func_overload_mid_c \
      src/asm/backend_call_dispatch.o 2>/dev/null \
      && echo "g05_cap_tip_reapply: weakened dispatch overload mid (empty-reject wins)" >&2 || true
  fi
  if [ -s build_asm/selfhost_pabi/glue_type_ref_suffix_empty_reject_soft.o ]; then
    "$OC" --weaken-symbol=_glue_asm_type_ref_to_suffix_c \
      --weaken-symbol=_glue_type_kind_to_suffix_c \
      src/asm/backend_call_dispatch.o 2>/dev/null \
      && echo "g05_cap_tip_reapply: weakened dispatch type_ref_to_suffix (empty-reject wins)" >&2 || true
  fi
fi
# knife256/10.2: Cap tip G05_OBJS may still miss overlays after thin cache restore
# (true-cold wipe + incomplete CACHE/pabi). Rebuild from known .x with LEGACY
# heat, then drop any still-missing paths from G05_OBJS so pure-ld does not
# ENOENT. No FORCE_CC / host-cc .c. PLATFORM: MACOS Cap tip.
_cap_tip_fill_missing_objs() {
  local xl="$XLANG"
  local o src rc=0
  mkdir -p build_asm/selfhost_pabi src/asm
  # Restore any remaining recipe objs from cache root / pabi/
  if [ -n "${CACHE:-}" ]; then
    [ -f "$CACHE/pthin_stretch.o" ] && cp -f "$CACHE/pthin_stretch.o" src/asm/pthin_stretch.o
    [ -f "$CACHE/arg_byte_size_a64.o" ] && cp -f "$CACHE/arg_byte_size_a64.o" build_asm/selfhost_pabi/arg_byte_size_a64.o
    if [ -d "$CACHE/pabi" ]; then
      cp -f "$CACHE/pabi"/*.o build_asm/selfhost_pabi/ 2>/dev/null || true
    fi
  fi
  # out.o|src.x pairs for Cap tip overlays commonly wiped
  while IFS='|' read -r o src; do
    [ -n "$o" ] || continue
    [ -s "$o" ] && continue
    [ -f "$src" ] || continue
    echo "g05_cap_tip_reapply: rebuild missing $o <- $src" >&2
    if ! ( export XLANG_PREFER_ASM_O=1; unset G05_X_O_WEAK G05_X_O_WEAK_FUNCS G05_X_O_SYM_RENAME;
           . scripts/pure_ld_shared.sh;
           pure_asm_x_to_o "$o" "$src" ) || [ ! -s "$o" ]; then
      # LEGACY -backend asm -c fallback (still no host-cc .c)
      if [ -x "$xl" ]; then
        "$xl" -backend asm -c -o "$o" "$src" 2>/dev/null || rm -f "$o"
      fi
    fi
    [ -s "$o" ] || echo "g05_cap_tip_reapply: WARN still missing $o" >&2
  done <<'MAP'
build_asm/selfhost_pabi/simd_at_call_a64.o|src/asm/simd_at_call_inline_a64.x
build_asm/selfhost_pabi/arg_byte_size_a64.o|src/runtime_pipeline_abi_arg_byte_size_thin.x
build_asm/selfhost_pabi/index_eff_addr_scaled_a64.o|src/runtime_pipeline_abi_index_eff_addr_scaled_thin.x
build_asm/selfhost_pabi/parser_asm_struct_dup_field_soft.o|src/asm/parser_asm_struct_dup_field_soft.x
build_asm/selfhost_pabi/pthin_imports_a64.o|src/asm/pthin_imports.x
src/asm/pthin_stretch.o|src/asm/pthin_stretch.x
build_asm/selfhost_pabi/local_slot_ptr_tramp_a64.o|src/runtime_pipeline_abi_local_slot_ptr_tramp_thin.x
build_asm/selfhost_pabi/fixed_array_let_init_module_var.o|src/pabi_fixed_array_let_init_module_var_one.x
build_asm/selfhost_pabi/vector_let_init_stubdead.o|src/pabi_vector_let_init_stubdead_one.x
build_asm/selfhost_pabi/vector_let_init_mangled.o|src/pabi_vector_let_init_mangled_one.x
build_asm/selfhost_pabi/vector_let_init_nested.o|src/pabi_vector_let_init_nested_one.x
build_asm/selfhost_pabi/index_elem_wrap.o|src/pabi_index_elem_wrap_one.x
build_asm/selfhost_pabi/index_elem_from_type.o|src/pabi_index_elem_from_type_one.x
build_asm/selfhost_pabi/index_elem_true_i8.o|src/pabi_index_elem_byte_sz_one.x
build_asm/selfhost_pabi/emit_index_thin_a64.o|src/runtime_pipeline_abi_emit_index_thin.x
build_asm/selfhost_pabi/emit_index_arms_true_i8.o|src/pabi_emit_index_arms_one.x
build_asm/selfhost_pabi/emit_index_elf_true_i8.o|src/pabi_emit_index_elf_one.x
build_asm/selfhost_pabi/assign_index_true_i8.o|src/pabi_assign_index_one.x
build_asm/selfhost_pabi/force_esz_true_i8.o|src/pabi_force_esz_one.x
build_asm/selfhost_pabi/array_lit_esz_true_i8.o|src/pabi_elem_byte_sz_one.x
build_asm/selfhost_pabi/fixed_array_total_bytes_true_pack.o|src/pabi_fixed_array_total_bytes_one.x
build_asm/selfhost_pabi/assign_field_seed.o|src/pabi_assign_field_one.x
build_asm/selfhost_pabi/runtime_pipeline_abi_deref_narrow_thin.o|src/runtime_pipeline_abi_deref_narrow_thin.x
build_asm/selfhost_pabi/struct_lit_fields_a64.o|src/runtime_pipeline_abi_struct_lit_fields_thin.x
build_asm/selfhost_pabi/arm64_param_home_a64.o|src/runtime_pipeline_abi_arm64_param_home_thin.x
build_asm/selfhost_pabi/w156_guard_a64.o|src/runtime_pipeline_abi_w156_guard_thin.x
build_asm/selfhost_pabi/macho_undef_cap_a64.o|src/runtime_pipeline_abi_macho_undef_cap_thin.x
build_asm/selfhost_pabi/trait_check_noop_a64.o|src/asm/trait_check_noop_thin.x
build_asm/selfhost_pabi/enum_ns_tag_a64.o|src/runtime_pipeline_abi_enum_ns_tag_thin.x
build_asm/selfhost_pabi/param_ptr_slot_a64.o|src/runtime_pipeline_abi_param_ptr_slot_thin.x
build_asm/selfhost_pabi/fa_array_lit_a64.o|src/runtime_pipeline_abi_fixed_array_copy_thin.x
build_asm/selfhost_pabi/add_common_sym_soft.o|src/runtime_pipeline_abi_add_common_sym_soft.x
build_asm/selfhost_pabi/named_size.o|src/runtime_pipeline_abi_named_size_thin.x
build_asm/selfhost_pabi/bake_scalar_imm_soft.o|src/runtime_pipeline_abi_bake_scalar_imm_soft.x
MAP
  # Cap tip G05_OBJS has no mega pabi — pull egg faces that softs/overlays need.
  if [ -s src/runtime_pipeline_abi.o ]; then
    _fill_exp=$(mktemp "${TMPDIR:-/tmp}/cap_tip_fill.XXXXXX.exp")
    _fill_o=build_asm/selfhost_pabi/cap_tip_pabi_sym_fill.o
    printf '%s\n' \
      _glue_wide_i32_vec_array_bytes \
      _pipeline_lane_operand_emit_let_block_chain \
      _glue_emit_vector_type_let_init_elf_c \
      _glue_array_lit_force_esz_from_elem_type_c \
      _pipeline_asm_array_lit_elem_byte_sz_c \
      _pipeline_asm_emit_field_access_elf_fast_c \
      >"$_fill_exp"
    if ld -r -o "$_fill_o" -exported_symbols_list "$_fill_exp" \
         src/runtime_pipeline_abi.o 2>/dev/null \
      && [ -s "$_fill_o" ] \
      && nm -gU "$_fill_o" 2>/dev/null | grep -q 'T _glue_wide_i32_vec_array_bytes$'; then
      :
    elif [ -n "${CACHE:-}" ] && [ -s "$CACHE/pabi/cap_tip_pabi_sym_fill.o" ]; then
      cp -f "$CACHE/pabi/cap_tip_pabi_sym_fill.o" "$_fill_o"
      echo "g05_cap_tip_reapply: restored cap_tip_pabi_sym_fill.o from cache" >&2
    fi
    if [ -s "$_fill_o" ] && nm -gU "$_fill_o" 2>/dev/null | grep -q 'T _glue_wide_i32_vec_array_bytes$'; then
      case " $G05_OBJS " in
        *" $_fill_o "*) ;;
        *) G05_OBJS="$_fill_o $G05_OBJS"; export G05_OBJS
           echo "g05_cap_tip_reapply: prepended cap_tip_pabi_sym_fill.o (wide/lane)" >&2 ;;
      esac
    fi
    rm -f "$_fill_exp"
  fi
# knife256/10.2: idle glue_emit_vector is the 13KB body INSIDE sym_fill (from
# runtime_pipeline_abi). Tip-compiled decline is 7KB and infinite-loops at +0x230.
# Globalize fill glue; demote decline glue; demote fill local array_lit (use pabi T).
# PLATFORM: MACOS Cap tip.
if [ -f build_asm/selfhost_pabi/cap_tip_pabi_sym_fill.o ]; then
  _oc_sf=""
  for c in /opt/homebrew/opt/llvm/bin/llvm-objcopy /usr/local/opt/llvm/bin/llvm-objcopy; do
    [ -x "$c" ] && _oc_sf=$c && break
  done
  if [ -n "$_oc_sf" ]; then
    "$_oc_sf" \
      --globalize-symbol=_glue_emit_vector_type_let_init_elf_c \
      --redefine-sym=_pipeline_asm_emit_array_lit_force_esz_elf_c=_pipeline_asm_emit_array_lit_force_esz_elf_c_symfill_localdead \
      --redefine-sym=_pipeline_asm_emit_array_lit_elf_c=_pipeline_asm_emit_array_lit_elf_c_symfill_localdead \
      build_asm/selfhost_pabi/cap_tip_pabi_sym_fill.o \
      && echo "g05_cap_tip_reapply: globalized fill glue_emit_vector; demoted fill array_lit locals" >&2 || true
  fi
fi
if [ -f build_asm/selfhost_pabi/vector_let_init_decline_a64.o ]; then
  _oc_sf=""
  for c in /opt/homebrew/opt/llvm/bin/llvm-objcopy /usr/local/opt/llvm/bin/llvm-objcopy; do
    [ -x "$c" ] && _oc_sf=$c && break
  done
  if [ -n "$_oc_sf" ]; then
    "$_oc_sf" \
      --redefine-sym=_glue_emit_vector_type_let_init_elf_c=_glue_emit_vector_type_let_init_elf_c_decline_dead \
      build_asm/selfhost_pabi/vector_let_init_decline_a64.o \
      && echo "g05_cap_tip_reapply: demoted decline glue_emit_vector (fill 13KB wins)" >&2 || true
  fi
fi

# knife256/10.2: true_i8 index arms lack i32 load → sum2 emits ptr+ptr (exit 10+128=138).
# Prepend emit_index_thin (has backend_enc_load_i32); demote true_i8 elf/arms.
# PLATFORM: MACOS Cap tip.
if [ -f src/runtime_pipeline_abi_emit_index_thin.x ] && [ -x ./xlang ]; then
  _ix_o=build_asm/selfhost_pabi/emit_index_thin_a64.o
  if [ ! -s "$_ix_o" ] || [ "$(wc -c <"$_ix_o")" -lt 5000 ]; then
    env -u XLANG -u XLANG_FORCE -u FORCE -u PREFER -u G05 -u RUN_ALL_USE_C \
      -u XLANG_CAP_TIP_L4_CACHE \
      XLANG_PREFER_ASM_O=1 ./xlang -backend asm -c \
      src/runtime_pipeline_abi_emit_index_thin.x -o "$_ix_o" \
      || { echo "g05_cap_tip_reapply: emit_index_thin compile failed" >&2; exit 1; }
    echo "g05_cap_tip_reapply: tip-compiled emit_index_thin_a64.o" >&2
  fi
  case " $G05_OBJS " in
    *" $_ix_o "*) ;;
    *) G05_OBJS="$_ix_o $G05_OBJS"; export G05_OBJS
       echo "g05_cap_tip_reapply: prepended emit_index_thin_a64.o" >&2 ;;
  esac
fi
_oc_ix=""
for c in /opt/homebrew/opt/llvm/bin/llvm-objcopy /usr/local/opt/llvm/bin/llvm-objcopy; do
  [ -x "$c" ] && _oc_ix=$c && break
done
if [ -n "$_oc_ix" ]; then
  for _pair in \
    "build_asm/selfhost_pabi/emit_index_arms_true_i8.o:_glue_emit_index_load_arms_elf_c" \
    "build_asm/selfhost_pabi/emit_index_elf_true_i8.o:_pipeline_asm_emit_index_elf_c"; do
    _o="${_pair%%:*}"; _s="${_pair##*:}"
    if [ -f "$_o" ] && nm "$_o" 2>/dev/null | grep -q "T ${_s}$"; then
      "$_oc_ix" --redefine-sym=${_s}=${_s}__true_i8_dead "$_o" \
        && echo "g05_cap_tip_reapply: demoted $_s (index thin wins)" >&2 || true
    fi
  done
fi

# knife256/10.2: r[i].field — var_field returns -99; without field_access_elf_fast
# fallback asm_expr_rec emits nothing (exit 10/138). Tip-compile asm_expr_thin
# whenever the .o lacks the fast undef (stale overlay from before 3eb614d94).
# PLATFORM: MACOS Cap tip.
if [ -f src/runtime_pipeline_abi_asm_expr_thin.x ] && [ -x ./xlang ]; then
  _aer_o=build_asm/selfhost_pabi/asm_expr_rec.o
  _aer_need=0
  if [ ! -s "$_aer_o" ]; then
    _aer_need=1
  elif ! nm -u "$_aer_o" 2>/dev/null | grep -q '_pipeline_asm_emit_field_access_elf_fast_c'; then
    _aer_need=1
  elif [ src/runtime_pipeline_abi_asm_expr_thin.x -nt "$_aer_o" ]; then
    _aer_need=1
  fi
  if [ "$_aer_need" = 1 ]; then
    env -u XLANG -u XLANG_FORCE -u FORCE -u PREFER -u G05 -u RUN_ALL_USE_C \
      -u XLANG_CAP_TIP_L4_CACHE \
      XLANG_PREFER_ASM_O=1 ./xlang -backend asm -c \
      src/runtime_pipeline_abi_asm_expr_thin.x -o "$_aer_o" \
      || { echo "g05_cap_tip_reapply: asm_expr_thin compile failed" >&2; exit 1; }
    echo "g05_cap_tip_reapply: tip-compiled asm_expr_rec.o (INDEX field fast)" >&2
  fi
  case " $G05_OBJS " in
    *" $_aer_o "*) ;;
    *) G05_OBJS="$_aer_o $G05_OBJS"; export G05_OBJS
       echo "g05_cap_tip_reapply: prepended asm_expr_rec.o" >&2 ;;
  esac
fi

  # fa_array_lit lives in fixed_array_copy_thin — ensure on link if rebuilt
  if [ -s build_asm/selfhost_pabi/fa_array_lit_a64.o ]; then
    case " $G05_OBJS " in
      *" build_asm/selfhost_pabi/fa_array_lit_a64.o "*) ;;
      *) G05_OBJS="build_asm/selfhost_pabi/fa_array_lit_a64.o $G05_OBJS"; export G05_OBJS
         echo "g05_cap_tip_reapply: prepended fa_array_lit_a64.o" >&2 ;;
    esac
  fi
  # Assemble hand-asm Cap tip sidecars that have no .x (g05_relink_env Darwin).
  if [ ! -s build_asm/selfhost_pabi/index_base_rbx_rest_a64.o ]; then
    _rs=build_asm/selfhost_pabi/index_base_rbx_rest_a64.s
    cat > "$_rs" <<'ASM'
.globl _glue_try_index_var_or_field_base_to_rbx_elf_rest
.p2align 2
_glue_try_index_var_or_field_base_to_rbx_elf_rest:
    mov w0, #-2
    ret
ASM
    as -arch arm64 -o build_asm/selfhost_pabi/index_base_rbx_rest_a64.o "$_rs" \
      && echo "g05_cap_tip_reapply: assembled index_base_rbx_rest_a64.o" >&2 \
      || rm -f build_asm/selfhost_pabi/index_base_rbx_rest_a64.o
  fi
  if [ ! -s build_asm/selfhost_pabi/typeck_return_mismatch_breadcrumb_a64.o ] \
    && [ -f src/asm/typeck_return_mismatch_breadcrumb_a64.s ]; then
    as -arch arm64 -o build_asm/selfhost_pabi/typeck_return_mismatch_breadcrumb_a64.o \
      src/asm/typeck_return_mismatch_breadcrumb_a64.s \
      && echo "g05_cap_tip_reapply: assembled typeck_return_mismatch_breadcrumb_a64.o" >&2 \
      || rm -f build_asm/selfhost_pabi/typeck_return_mismatch_breadcrumb_a64.o
  fi
  # Breadcrumb peel calls __demoted; demote the product body in driver_diagnostic.
  if [ -s build_asm/selfhost_pabi/typeck_return_mismatch_breadcrumb_a64.o ] \
    && [ -s src/runtime_driver_diagnostic.o ] && [ -n "${OC:-}" ]; then
    if nm -gU src/runtime_driver_diagnostic.o 2>/dev/null \
         | grep -q ' T _driver_diagnostic_typeck_return_mismatch$' \
      && ! nm -gU src/runtime_driver_diagnostic.o 2>/dev/null \
         | grep -q ' T _driver_diagnostic_typeck_return_mismatch__demoted$'; then
      "$OC" --redefine-sym=_driver_diagnostic_typeck_return_mismatch=_driver_diagnostic_typeck_return_mismatch__demoted \
        src/runtime_driver_diagnostic.o 2>/dev/null \
        && echo "g05_cap_tip_reapply: demoted driver_diagnostic return_mismatch → __demoted" >&2 \
        || true
    fi
  fi
  if [ ! -s build_asm/selfhost_pabi/cimp_a64.o ] \
    && [ -f src/runtime_pipeline_abi_collect_imports_thin.x ]; then
    _cimp_bin="$xl"
    if XLANG_PREFER_ASM_O=1 "$_cimp_bin" -backend asm -c \
         src/runtime_pipeline_abi_collect_imports_thin.x \
         -o build_asm/selfhost_pabi/cimp_a64.o 2>/dev/null \
      && [ -s build_asm/selfhost_pabi/cimp_a64.o ]; then
      echo "g05_cap_tip_reapply: rebuilt cimp_a64.o" >&2
    else
      rm -f build_asm/selfhost_pabi/cimp_a64.o
    fi
  fi
  # Ensure typeck demoted body exists (mangled redefine may have run in soft_prep)
  if [ -s build_asm/selfhost_pabi/typeck_x.cap_repr_weak.o ] \
    && [ -s build_asm/selfhost_pabi/typeck_get_dep_ptr_named_soft.o ]; then
    if ! nm -gU build_asm/selfhost_pabi/typeck_x.cap_repr_weak.o 2>/dev/null \
         | grep -q ' T _typeck_get_dep_return_type_in_caller_arena__demoted$'; then
      if [ -n "${OC:-}" ]; then
        "$OC" --redefine-sym=_typeck_get_dep_return_type_in_caller_arena_i32_i32_ASTArena_ptr_PipelineDepCtx_ptr_reti32=_typeck_get_dep_return_type_in_caller_arena__demoted \
          build_asm/selfhost_pabi/typeck_x.cap_repr_weak.o 2>/dev/null \
          && echo "g05_cap_tip_reapply: demoted mangled get_dep → __demoted" >&2 || true
      fi
    fi
  fi
  # Drop still-missing paths from G05_OBJS (avoid ld errno=2)
  local kept="" miss=0
  for o in $G05_OBJS; do
    if [ -s "$o" ]; then
      kept="$kept $o"
    else
      echo "g05_cap_tip_reapply: skip missing link obj $o" >&2
      miss=$((miss + 1))
    fi
  done
  G05_OBJS=$(echo "$kept" | sed 's/^ *//')
  export G05_OBJS
  echo "g05_cap_tip_reapply: G05_OBJS after fill/skip=$(echo $G05_OBJS | wc -w | tr -d ' ') (skipped $miss)" >&2
  # Same for WINNERS pairs — drop pairs whose object is missing
  if [ -n "${G05_LINK_WINNERS:-}" ]; then
    local wkept=""
    for pair in $G05_LINK_WINNERS; do
      local wobj="${pair#*=}"
      if [ -s "$wobj" ]; then
        wkept="$wkept $pair"
      else
        echo "g05_cap_tip_reapply: skip winner $pair (obj missing)" >&2
      fi
    done
    G05_LINK_WINNERS=$(echo "$wkept" | sed 's/^ *//')
    export G05_LINK_WINNERS
  fi

  # knife256/10.2: CACHE/pabi bulk restore above stomps Cap tip weakens done
  # earlier in this script (pabi_weak / return_sret). Re-apply so fa_array /
  # thin first-wins. Also drop typeck_ctfe when cap_repr_weak covers its T
  # set (0 unique), and weaken panic getenv so runtime_link_abi wins.
  # No FORCE_CC / KEEP_C / host-cc .c. PLATFORM: MACOS Cap tip.
  if [ -n "${OC:-}" ]; then
    if [ -s build_asm/selfhost_pabi/pabi_weak.o ]       && [ -s build_asm/selfhost_pabi/fa_array_lit_a64.o ]; then
      "$OC"         --weaken-symbol=_glue_call_arg_var_use_lea_not_load_elf_c         --weaken-symbol=_glue_struct_lit_store_fixed_array_field_elf_c         --weaken-symbol=_pipeline_asm_emit_array_lit_flat_elf_c         build_asm/selfhost_pabi/pabi_weak.o         && echo "g05_cap_tip_reapply: post-fill re-weaken pabi fixed-array bodies" >&2         || true
    fi
    if [ -s build_asm/selfhost_pabi/return_sret.o ]       && [ -s build_asm/selfhost_pabi/fa_array_lit_a64.o ]; then
      "$OC" --weaken-symbol=_pipeline_asm_emit_return_elf_impl         build_asm/selfhost_pabi/return_sret.o         && echo "g05_cap_tip_reapply: post-fill re-weaken return_sret emit_return" >&2         || true
    fi
    if [ -s runtime_panic.o ] && [ -s src/runtime_link_abi.o ]; then
      "$OC" --weaken-symbol=_link_abi_getenv         --weaken-symbol=_link_abi_getenv_impl         runtime_panic.o         && echo "g05_cap_tip_reapply: post-fill weaken panic getenv (link_abi wins)" >&2         || true
    fi
  # Ensure add_common / bake softs survive CACHE/pabi stomp; m8 ret0 must stay weak.
  if [ ! -s build_asm/selfhost_pabi/add_common_sym_soft.o ] \
    && [ -f src/runtime_pipeline_abi_add_common_sym_soft.x ] && [ -x "${XLANG:-}" ]; then
    XLANG_PREFER_ASM_O=1 "$XLANG" -backend asm -c \
      src/runtime_pipeline_abi_add_common_sym_soft.x \
      -o build_asm/selfhost_pabi/add_common_sym_soft.o 2>/dev/null || true
  fi
  if [ -s build_asm/selfhost_pabi/add_common_sym_soft.o ]; then
    case " $G05_OBJS " in
      *" build_asm/selfhost_pabi/add_common_sym_soft.o "*) ;;
      *) G05_OBJS="build_asm/selfhost_pabi/add_common_sym_soft.o $G05_OBJS"; export G05_OBJS
         echo "g05_cap_tip_reapply: post-fill prepended add_common_sym_soft.o" >&2 ;;
    esac
  fi
  if [ -s build_asm/selfhost_pabi/bake_scalar_imm_soft.o ]; then
    case " $G05_OBJS " in
      *" build_asm/selfhost_pabi/bake_scalar_imm_soft.o "*) ;;
      *) G05_OBJS="build_asm/selfhost_pabi/bake_scalar_imm_soft.o $G05_OBJS"; export G05_OBJS
         echo "g05_cap_tip_reapply: post-fill prepended bake_scalar_imm_soft.o" >&2 ;;
    esac
  fi
  if [ -n "${OC:-}" ] && [ -s build_asm/selfhost_pabi/add_common_sym_soft.o ] \
    && [ -s build_asm/selfhost_pabi/m8_reloc_stubs_g05.o ]; then
    case " $G05_OBJS " in
      *" build_asm/selfhost_pabi/add_common_sym_soft.o "*)
        "$OC" --weaken-symbol=_pipeline_elf_ctx_add_common_sym \
          build_asm/selfhost_pabi/m8_reloc_stubs_g05.o \
          && echo "g05_cap_tip_reapply: post-fill re-weaken m8 add_common (soft wins)" >&2 \
          || true
        ;;
    esac
  fi
  # knife256/10.2: CACHE/pabi bulk restore stomps early m8→macho_write demote;
  # pure-ld then sees duplicate _platform_macho_write_macho_o_to_buf vs
  # macho_write_a64.o. Re-demote after stomp. Prefer asm thin; no FORCE_CC.
  # PLATFORM: MACOS Cap tip.
  if [ -n "${OC:-}" ] && [ -s build_asm/selfhost_pabi/macho_write_a64.o ] \
    && [ -s build_asm/selfhost_pabi/m8_reloc_stubs_g05.o ]; then
    case " $G05_OBJS " in
      *" build_asm/selfhost_pabi/macho_write_a64.o "*)
        if nm -gU build_asm/selfhost_pabi/macho_write_a64.o 2>/dev/null \
             | grep -q 'T _platform_macho_write_macho_o_to_buf$' \
           && nm -gU build_asm/selfhost_pabi/m8_reloc_stubs_g05.o 2>/dev/null \
             | grep -q 'T _platform_macho_write_macho_o_to_buf$'; then
          "$OC" --redefine-sym=_platform_macho_write_macho_o_to_buf=_platform_macho_write_macho_o_to_buf_m8_g05_dead \
            build_asm/selfhost_pabi/m8_reloc_stubs_g05.o \
            && echo "g05_cap_tip_reapply: post-fill re-demote m8 macho_write (thin wins)" >&2 \
            || true
        fi
        ;;
    esac
  fi
  fi
  # Post-fill: size/layout softs + re-demote pabi (CACHE/pabi stomps demote).
  if [ ! -s build_asm/selfhost_pabi/typeck_named_layout_size_split_soft.o ] \
    && [ -f src/asm/named_layout_size_split_a64.s ]; then
    as -arch arm64 -o build_asm/selfhost_pabi/typeck_named_layout_size_split_soft.o \
      src/asm/named_layout_size_split_a64.s \
      && echo "g05_cap_tip_reapply: post-fill assemble named_layout soft" >&2 || true
  fi
  if [ -s build_asm/selfhost_pabi/typeck_named_layout_size_split_soft.o ]; then
    case " $G05_OBJS " in
      *" build_asm/selfhost_pabi/typeck_named_layout_size_split_soft.o "*) ;;
      *) G05_OBJS="build_asm/selfhost_pabi/typeck_named_layout_size_split_soft.o $G05_OBJS"; export G05_OBJS
         echo "g05_cap_tip_reapply: post-fill prepended named_layout soft" >&2 ;;
    esac
  fi
  if [ -n "${OC:-}" ] && [ -s build_asm/selfhost_pabi/pabi_weak.o ] \
    && [ -s build_asm/selfhost_pabi/typeck_named_layout_size_split_soft.o ]; then
    [ -s build_asm/selfhost_pabi/pabi_weak.o.bak_cap ] \
      || cp -f build_asm/selfhost_pabi/pabi_weak.o build_asm/selfhost_pabi/pabi_weak.o.bak_cap
    cp -f build_asm/selfhost_pabi/pabi_weak.o.bak_cap build_asm/selfhost_pabi/pabi_weak.o
    _pf_redefs=(--redefine-sym=_glue_type_named_layout_size_any_module_elf_c=_glue_type_named_layout_size_any_module_elf_c__demoted)
    # Keep named_size size_simple; demote pabi twin if bak restored it.
    if nm -gU build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null \
         | grep -q '_glue_type_size_simple$' \
      && nm -gU build_asm/selfhost_pabi/named_size.o 2>/dev/null \
         | grep -q 'T _glue_type_size_simple$'; then
      _pf_redefs+=(--redefine-sym=_glue_type_size_simple=_glue_type_size_simple__demoted)
    fi
    "$OC" "${_pf_redefs[@]}" build_asm/selfhost_pabi/pabi_weak.o \
      && echo "g05_cap_tip_reapply: post-fill re-demote pabi layout/size (named_size wins)" >&2 || true
    # bak_cap restore above re-strongs fixed-array bodies; re-weaken for fa_array.
    if [ -s build_asm/selfhost_pabi/fa_array_lit_a64.o ]; then
      "$OC" \
        --weaken-symbol=_glue_call_arg_var_use_lea_not_load_elf_c \
        --weaken-symbol=_glue_struct_lit_store_fixed_array_field_elf_c \
        --weaken-symbol=_pipeline_asm_emit_array_lit_flat_elf_c \
        build_asm/selfhost_pabi/pabi_weak.o \
        && echo "g05_cap_tip_reapply: post-fill re-weaken pabi fixed-array after size demote" >&2 \
        || true
    fi
  fi
  # Post-fill: layout_glue orch (CACHE/pabi may restore hollow).
  if [ -f src/runtime_pipeline_abi_typeck_orch_thin.x ] && [ -x "${XLANG:-}" ]; then
    if ! nm -gU build_asm/selfhost_pabi/typeck_orch_layout_glue_a64.o 2>/dev/null \
         | grep -q 'T _typeck_x_type_size_from_layout_glue$'; then
      if XLANG_PREFER_ASM_O=1 "$XLANG" -backend asm -c \
          src/runtime_pipeline_abi_typeck_orch_thin.x \
          -o /tmp/cap_tip_orch.tmp.o 2>/dev/null; then
        echo '_typeck_x_type_size_from_layout_glue
_typeck_x_type_align_from_layout_glue' > /tmp/cap_tip_orch_layout.exp
        ld -r -o build_asm/selfhost_pabi/typeck_orch_layout_glue_a64.o \
          -exported_symbols_list /tmp/cap_tip_orch_layout.exp \
          /tmp/cap_tip_orch.tmp.o 2>/dev/null \
          || cp -f /tmp/cap_tip_orch.tmp.o build_asm/selfhost_pabi/typeck_orch_layout_glue_a64.o
        rm -f /tmp/cap_tip_orch.tmp.o /tmp/cap_tip_orch_layout.exp
        echo "g05_cap_tip_reapply: post-fill tip-compiled orch layout_glue" >&2
      fi
    fi
  fi
  if [ -s build_asm/selfhost_pabi/typeck_orch_layout_glue_a64.o ]; then
    case " $G05_OBJS " in
      *" build_asm/selfhost_pabi/typeck_orch_layout_glue_a64.o "*) ;;
      *) G05_OBJS="build_asm/selfhost_pabi/typeck_orch_layout_glue_a64.o $G05_OBJS"; export G05_OBJS ;;
    esac
    if [ -n "${OC:-}" ] && [ -s build_asm/selfhost_pabi/pabi_weak.o.bak_cap ]; then
      cp -f build_asm/selfhost_pabi/pabi_weak.o.bak_cap build_asm/selfhost_pabi/pabi_weak.o
      "$OC" \
        --redefine-sym=_glue_type_size_simple=_glue_type_size_simple__demoted \
        --redefine-sym=_glue_type_named_layout_size_any_module_elf_c=_glue_type_named_layout_size_any_module_elf_c__demoted \
        --redefine-sym=_typeck_x_type_size_from_layout_glue=_typeck_x_type_size_from_layout_glue__demoted \
        --redefine-sym=_typeck_x_type_align_from_layout_glue=_typeck_x_type_align_from_layout_glue__demoted \
        build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
      # re-weaken fixed-array after bak restore
      if [ -s build_asm/selfhost_pabi/fa_array_lit_a64.o ]; then
        "$OC" \
          --weaken-symbol=_glue_call_arg_var_use_lea_not_load_elf_c \
          --weaken-symbol=_glue_struct_lit_store_fixed_array_field_elf_c \
          --weaken-symbol=_pipeline_asm_emit_array_lit_flat_elf_c \
          build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null || true
      fi
      echo "g05_cap_tip_reapply: post-fill re-demote pabi size+layout_glue" >&2
    fi
  fi
  # Post-fill: ensure named_size keeps live size_simple (cache may have demoted copy).
  if [ -f src/runtime_pipeline_abi_named_size_thin.x ] && [ -x "${XLANG:-}" ]; then
    if ! nm -gU build_asm/selfhost_pabi/named_size.o 2>/dev/null \
         | grep -q 'T _glue_type_size_simple$'; then
      XLANG_PREFER_ASM_O=1 "$XLANG" -backend asm -c \
        src/runtime_pipeline_abi_named_size_thin.x \
        -o build_asm/selfhost_pabi/named_size.o 2>/dev/null \
        && echo "g05_cap_tip_reapply: post-fill tip-compiled named_size.o" >&2 || true
    fi
  fi
  if [ -s build_asm/selfhost_pabi/typeck_x.cap_repr_weak.o ]; then
    local kept2="" dropped_ctfe=0
    for o in $G05_OBJS; do
      case "$o" in
        */typeck_ctfe.o|typeck_ctfe.o)
          echo "g05_cap_tip_reapply: drop typeck_ctfe (cap_repr_weak covers T set)" >&2
          dropped_ctfe=1
          ;;
        *) kept2="$kept2 $o" ;;
      esac
    done
    if [ "$dropped_ctfe" = 1 ]; then
      G05_OBJS=$(echo "$kept2" | sed 's/^ *//')
      export G05_OBJS
      echo "g05_cap_tip_reapply: G05_OBJS after ctfe filter=$(echo $G05_OBJS | wc -w | tr -d ' ')" >&2
    fi
  fi
}
_cap_tip_fill_missing_objs

# Keep the product that is on disk. relink always overwrites xlang_asm.
# PLATFORM: MACOS Cap tip.
_cap_prev=build_asm/xlang.pre_cap_tip_reapply
rm -f "$_cap_prev"
if [ -x xlang ]; then
  cp -f xlang "$_cap_prev"
fi
# Cap tip: KEEP darwin_tramp so mega/fill locals redirect to overlay T
# (index thin, fill glue 13KB). Decline glue stays demoted. PLATFORM: MACOS Cap tip.
unset XLANG_SKIP_DARWIN_TRAMP
# knife256/10.2: Cap tip DepCtx path-only overlay — multi-import `xlang check`
# needs GrowVec import_path APIs; full dep_ctx_thin demote broke multi-file
# (foo.o not linked). Keep only import_path+sidecar globals; localize rest so
# fill/weak keep build DepCtx. PLATFORM: MACOS Cap tip.
if [ -f src/runtime_pipeline_abi_dep_ctx_thin.x ] && [ -x ./xlang ] && [ "${XLANG_CAP_TIP_DEPCTX_PATH:-0}" = "1" ]; then
  _dct_src=build_asm/selfhost_pabi/dep_ctx_thin_a64.o
  _dct_o=build_asm/selfhost_pabi/dep_ctx_path_only_a64.o
  if [ ! -s "$_dct_src" ] || [ src/runtime_pipeline_abi_dep_ctx_thin.x -nt "$_dct_src" ]; then
    env -u XLANG -u XLANG_FORCE -u FORCE -u PREFER -u G05 -u RUN_ALL_USE_C \
      -u XLANG_CAP_TIP_L4_CACHE \
      XLANG_PREFER_ASM_O=1 ./xlang -backend asm -c \
      src/runtime_pipeline_abi_dep_ctx_thin.x -o "$_dct_src" \
      || { echo "g05_cap_tip_reapply: dep_ctx_thin compile failed" >&2; exit 1; }
    echo "g05_cap_tip_reapply: tip-compiled dep_ctx_thin_a64.o" >&2
  fi
  if [ -s "$_dct_src" ] && [ -n "${OC_L003:-}" ]; then
    cp -f "$_dct_src" "$_dct_o"
    python3 - "$_dct_o" "${OC_L003}" <<'PYPATH'
import subprocess, sys
path_o, oc = sys.argv[1], sys.argv[2]
KEEP = {
  "_pipeline_dep_ctx_import_path_byte_at",
  "_pipeline_dep_ctx_import_path_copy64",
  "_pipeline_dep_ctx_import_path_len",
  "_pipeline_dep_ctx_set_import_path",
  "_pipeline_pipe_dep_sc_at",
  "_pipeline_pipe_dep_sc_free",
  "_pipeline_pipe_dep_sc_gv",
  "_pipeline_pipe_dep_sc_max",
  "_pipeline_pipe_dep_sc_off_ctx",
  "_pipeline_pipe_dep_sc_off_dep_arenas",
  "_pipeline_pipe_dep_sc_off_dep_modules",
  "_pipeline_pipe_dep_sc_off_dep_path_lens",
  "_pipeline_pipe_dep_sc_off_dep_path_rows",
  "_pipeline_pipe_dep_sc_off_empty_param_backup",
  "_pipeline_pipe_dep_sc_off_empty_param_indices",
  "_pipeline_pipe_dep_sc_off_lib_root_lens",
  "_pipeline_pipe_dep_sc_off_lib_root_rows",
  "_pipeline_pipe_dep_sc_off_used",
  "_pipeline_pipe_dep_sc_size",
  "_pipeline_pipe_depctx_ensure_slot",
  "_pipeline_pipe_depctx_sidecar_get",
}
out = subprocess.check_output(["nm", "-gU", path_o], text=True)
locals_ = []
for line in out.splitlines():
    parts = line.split()
    if len(parts) >= 3 and parts[1] == "T" and parts[2].startswith("_") and parts[2] not in KEEP:
        locals_.append(parts[2])
if locals_:
    args = [oc] + [f"--localize-symbol={s}" for s in locals_] + [path_o]
    subprocess.check_call(args)
print(f"g05_cap_tip_reapply: path-only thin globals keep={len(KEEP)} localized={len(locals_)}", file=sys.stderr)
PYPATH
  fi
  if [ -s "$_dct_o" ]; then
    case " $G05_OBJS " in
      *" $_dct_o "*) ;;
      *) G05_OBJS="$_dct_o $G05_OBJS"; export G05_OBJS
         echo "g05_cap_tip_reapply: prepended dep_ctx_path_only_a64.o" >&2 ;;
    esac
  fi
  # knife256/10.2: ast_* import_path still live in fill/glue; tramp to pipeline_* thin.
  _dct_tramp=build_asm/selfhost_pabi/dep_ctx_ast_tramp_a64.o
  if [ -f src/asm/../.. ] || true; then
    if [ ! -s "$_dct_tramp" ] || [ scripts/g05_cap_tip_reapply_darwin.sh -nt "$_dct_tramp" ]; then
      cat > build_asm/selfhost_pabi/dep_ctx_ast_tramp_a64.s <<'ASMTRAMP'
/* knife256/10.2: Cap tip — ast_pipeline_dep_ctx_import_path* → pipeline_* thin. */
	.align 2
	.globl _ast_pipeline_dep_ctx_set_import_path
_ast_pipeline_dep_ctx_set_import_path:
	b _pipeline_dep_ctx_set_import_path
	.globl _ast_pipeline_dep_ctx_import_path_len
_ast_pipeline_dep_ctx_import_path_len:
	b _pipeline_dep_ctx_import_path_len
	.globl _ast_pipeline_dep_ctx_import_path_byte_at
_ast_pipeline_dep_ctx_import_path_byte_at:
	b _pipeline_dep_ctx_import_path_byte_at
	.globl _ast_pipeline_dep_ctx_import_path_copy64
_ast_pipeline_dep_ctx_import_path_copy64:
	b _pipeline_dep_ctx_import_path_copy64
ASMTRAMP
      clang -c -arch arm64 build_asm/selfhost_pabi/dep_ctx_ast_tramp_a64.s -o "$_dct_tramp" \
        || { echo "g05_cap_tip_reapply: ast tramp assemble failed" >&2; exit 1; }
      echo "g05_cap_tip_reapply: assembled dep_ctx_ast_tramp_a64.o" >&2
    fi
  fi
  if [ -s "$_dct_tramp" ]; then
    case " $G05_OBJS " in
      *" $_dct_tramp "*) ;;
      *) G05_OBJS="$_dct_tramp $G05_OBJS"; export G05_OBJS
         echo "g05_cap_tip_reapply: prepended dep_ctx_ast_tramp_a64.o" >&2 ;;
    esac
  fi
  if [ -n "${OC_L003:-}" ] && [ -s "$_dct_o" ]; then
    python3 - "$_dct_o" "${OC_L003}" <<'PYDCT'
import subprocess, sys, os
thin, oc = sys.argv[1], sys.argv[2]
# Demote ONLY remaining global T twins (import_path + sidecar).
out = subprocess.check_output(["nm", "-gU", thin], text=True)
want = {parts[2] for line in out.splitlines()
        for parts in [line.split()]
        if len(parts) >= 3 and parts[1] == "T" and parts[2].startswith("_")}
want |= {
  "_ast_pipeline_dep_ctx_set_import_path",
  "_ast_pipeline_dep_ctx_import_path_len",
  "_ast_pipeline_dep_ctx_import_path_byte_at",
  "_ast_pipeline_dep_ctx_import_path_copy64",
}
for o in ("build_asm/selfhost_pabi/pabi_weak.o", "src/runtime_pipeline_abi.o",
          "src/runtime_driver_strict_glue_stubs.o"):
    if not os.path.isfile(o) or os.path.getsize(o) == 0:
        continue
    nmout = subprocess.check_output(["nm", "-gU", o], text=True)
    redefs = []
    for line in nmout.splitlines():
        parts = line.split()
        if len(parts) >= 3 and parts[1] == "T" and parts[2] in want:
            redefs.append(f"--redefine-sym={parts[2]}={parts[2]}__fill_dead")
    if redefs:
        for i in range(0, len(redefs), 40):
            subprocess.check_call([oc] + redefs[i:i+40] + [o])
        print(f"g05_cap_tip_reapply: demoted {o} dep_ctx path twins ({len(redefs)})", file=sys.stderr)
PYDCT
  fi
fi


# knife256/10.2: Cap tip G05_OBJS has call_spill.o but omits addr_of_call.o
# → U _glue_addr_simd_lane_type_c. Prepend cache/leaf addr_of_call.o and
# weaken pabi_weak emit_addr_of so thin first-wins (avoid dup). Else weak
# pure-asm stub (return 0). No FORCE_CC / host-cc .c. PLATFORM: MACOS.
_aoc=build_asm/selfhost_pabi/addr_of_call.o
if [ ! -s "$_aoc" ] && [ -s "$CACHE/pabi/addr_of_call.o" ]; then
  cp -f "$CACHE/pabi/addr_of_call.o" "$_aoc"
fi
if [ -s "$_aoc" ] && nm -gU "$_aoc" 2>/dev/null | grep -q 'T _glue_addr_simd_lane_type_c$'; then
  case " $G05_OBJS " in
    *" $_aoc "*|*" build_asm/selfhost_pabi/addr_of_call.o "*) ;;
    *)
      G05_OBJS="$_aoc $G05_OBJS"
      export G05_OBJS
      echo "g05_cap_tip_reapply: prepended addr_of_call.o (simd_lane_type)" >&2
      ;;
  esac
  if [ -n "${OC:-}" ] && [ -s build_asm/selfhost_pabi/pabi_weak.o ]; then
    if nm -gU build_asm/selfhost_pabi/pabi_weak.o 2>/dev/null          | grep -q 'T _pipeline_asm_emit_addr_of_elf_c$'; then
      "$OC" --weaken-symbol=_pipeline_asm_emit_addr_of_elf_c         build_asm/selfhost_pabi/pabi_weak.o         && echo "g05_cap_tip_reapply: weakened pabi_weak emit_addr_of (addr_of_call wins)" >&2         || true
    fi
  fi
elif [ -f src/asm/glue_addr_simd_lane_type_stub_a64.s ]; then
  _simd_stub=build_asm/selfhost_pabi/glue_addr_simd_lane_type_stub_a64.o
  if clang -c -arch arm64 src/asm/glue_addr_simd_lane_type_stub_a64.s -o "$_simd_stub" 2>/dev/null \
     && [ -s "$_simd_stub" ]; then
    case " $G05_OBJS " in
      *" $_simd_stub "*) ;;
      *)
        G05_OBJS="$_simd_stub $G05_OBJS"
        export G05_OBJS
        echo "g05_cap_tip_reapply: prepended glue_addr_simd_lane_type weak stub" >&2
        ;;
    esac
  fi
fi

bash scripts/g05_relink_xlang.sh

if [ ! -x xlang.cap_g05_l2 ]; then
  echo "g05_cap_tip_reapply: xlang.cap_g05_l2 missing" >&2
  exit 1
fi

# knife256/10.2: do not replace the product when the wide-array return
# probe is not 110. Exit 110 is the program's status, so set -e must
# not treat it as a script failure. PLATFORM: MACOS Cap tip.
if [ -f ../tests/boundary/ret_fixed_s24.x ]; then
  rm -f build_asm/cap_tip_s24_probe
  _s24_rc=1
  set +e
  ./xlang.cap_g05_l2 -o build_asm/cap_tip_s24_probe ../tests/boundary/ret_fixed_s24.x
  if [ $? -eq 0 ] && [ -x build_asm/cap_tip_s24_probe ]; then
    build_asm/cap_tip_s24_probe
    _s24_rc=$?
  fi
  set -e
  if [ "$_s24_rc" != 110 ]; then
    echo "g05_cap_tip_reapply: ret_fixed_s24 exit ${_s24_rc}, previous product kept" >&2
    if [ -x "$_cap_prev" ]; then
      for _n in xlang xlang_asm xlang-c bootstrap_xlangc; do
        rm -f "$_n"
        cp -f "$_cap_prev" "$_n"
        chmod +x "$_n"
      done
      codesign -s - -f --timestamp=none xlang xlang_asm xlang-c bootstrap_xlangc >/dev/null 2>&1 || true
    fi
    exit 1
  fi
fi

# Cap tip-as-product (never leave LEGACY as tip)
cp -f xlang.cap_g05_l2 xlang
cp -f xlang.cap_g05_l2 xlang_asm
cp -f xlang.cap_g05_l2 xlang-c
cp -f xlang.cap_g05_l2 bootstrap_xlangc
codesign -s - -f xlang xlang_asm xlang-c bootstrap_xlangc xlang.cap_g05_l2 >/dev/null 2>&1 || true

SZ=$(stat -f '%z' xlang 2>/dev/null || stat -c '%s' xlang)
echo "g05_cap_tip_reapply: Cap tip product size=$SZ"
# Cap tip identity ~9.3MB (reject LEGACY ~25MB)
if [ "$SZ" -gt 12000000 ]; then
  echo "g05_cap_tip_reapply: FAIL product size $SZ looks LEGACY (want ~9.3MB Cap tip)" >&2
  exit 1
fi
if [ "$SZ" -lt 7000000 ]; then
  echo "g05_cap_tip_reapply: FAIL product size $SZ too small" >&2
  exit 1
fi
echo "g05_cap_tip_reapply: OK Cap tip-as-product size=$SZ"
