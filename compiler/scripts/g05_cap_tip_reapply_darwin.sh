#!/usr/bin/env bash
# g05_cap_tip_reapply_darwin.sh — after cold g05 (LEGACY-sized product), re-link Cap tip.
# Does NOT restore a prior Cap tip binary as tip (banned). Relinks this-wave from
# Cap tip env + recipe objects (cache softs/dual_gp/macho/dep_prerun bak).
# PLATFORM: MACOS Cap tip sidecar. Run from compiler/.
set -euo pipefail
cd "$(dirname "$0")/.."

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

# named_size demote (Cap tip dual_gp wins size)
if [ -f build_asm/selfhost_pabi/named_size.o ]; then
  if nm -gU build_asm/selfhost_pabi/named_size.o 2>/dev/null | grep -q 'T _glue_type_size_simple$'; then
    "$OC" \
      --redefine-sym=_pipeline_named_size_layout_matches_c=_pipeline_named_size_layout_matches_c_namedsizedead \
      --redefine-sym=_glue_type_size_simple=_glue_type_size_simple_namedsizedead \
      build_asm/selfhost_pabi/named_size.o
    echo "g05_cap_tip_reapply: named_size demoted"
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
# PLATFORM: MACOS Cap tip.
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
if [ -n "$_oc_sz" ] && [ -s ../core/slice/mod.o ]; then
  [ -s ../core/slice/mod.o.bak_pre_split ] || cp -f ../core/slice/mod.o ../core/slice/mod.o.bak_pre_split
  cp -f ../core/slice/mod.o.bak_pre_split ../core/slice/mod.o
  "$_oc_sz" \
    --redefine-sym=_core_slice_split_at_i32=_core_slice_split_at_i32__demoted \
    --redefine-sym=_core_slice_split_at_u8=_core_slice_split_at_u8__demoted \
    --redefine-sym=_core_slice_split_at_u64=_core_slice_split_at_u64__demoted \
    ../core/slice/mod.o \
    && echo "g05_cap_tip_reapply: demoted leaf mod.o split_at (slice.o wins)" >&2
fi

# knife256/10.2: Cap tip/LEGACY pure-asm of runtime_slice_glue.x is hollow
# (bl next-insn). Install hand-asm leaf into ../core/slice/slice.o.
# PLATFORM: MACOS Cap tip leaf (not tip product).
if [ -f src/asm/runtime_slice_glue_a64.s ]; then
  clang -c -o ../core/slice/slice.o src/asm/runtime_slice_glue_a64.s \
    && echo "g05_cap_tip_reapply: installed hand-asm core/slice/slice.o" >&2 \
    || echo "g05_cap_tip_reapply: WARN slice glue install failed" >&2
fi

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
if [ -f src/asm/vector_let_init_array_lit_a64.x ] && [ -x ./xlang_asm ]; then
  env -u XLANG -u XLANG_FORCE -u FORCE -u PREFER -u G05 -u RUN_ALL_USE_C \
    XLANG_PREFER_ASM_O=1 ./xlang_asm -backend asm -c \
    src/asm/vector_let_init_array_lit_a64.x \
    -o build_asm/selfhost_pabi/vector_let_init_decline_a64.o \
    || { echo "g05_cap_tip_reapply: vector let-init array-lit compile failed" >&2; exit 1; }
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
  if nm -gU src/diag.o 2>/dev/null | grep -qE 'T _diag_report_human$|T _diag_report_with_code$|T _diag_report$'; then
    [ -s src/diag.o.bak_cap ] || cp -f src/diag.o src/diag.o.bak_cap
    "$OC_L003" \
      --redefine-sym=_diag_report_human=_diag_report_human_diag_o_dead \
      --redefine-sym=_diag_report_with_code=_diag_report_with_code_diag_o_dead \
      --redefine-sym=_diag_report=_diag_report_diag_o_dead \
      src/diag.o
    echo "g05_cap_tip_reapply: demoted Cap tip diag human/with_code" >&2
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
  # Restore bak then demote report+ctx+snap so softs first-win (same-TU calls)
  cp -f src/diag.o.bak_cap src/diag.o
  "$OC_L003" \
    --redefine-sym=_diag_report_human=_diag_report_human_diag_o_dead \
    --redefine-sym=_diag_report_with_code=_diag_report_with_code_diag_o_dead \
    --redefine-sym=_diag_report=_diag_report_diag_o_dead \
    --redefine-sym=_diag_restore=_diag_restore_diag_o_dead \
    --redefine-sym=_diag_push_file=_diag_push_file_diag_o_dead \
    --redefine-sym=_diag_ctx_get_file=_diag_ctx_get_file_diag_o_dead \
    --redefine-sym=_diag_ctx_get_source=_diag_ctx_get_source_diag_o_dead \
    --redefine-sym=_diag_ctx_get_source_len=_diag_ctx_get_source_len_diag_o_dead \
    --redefine-sym=_diag_ctx_get_use_color=_diag_ctx_get_use_color_diag_o_dead \
    --redefine-sym=_diag_ctx_set_all=_diag_ctx_set_all_diag_o_dead \
    --redefine-sym=_diag_snap_load_ptr=_diag_snap_load_ptr_diag_o_dead \
    --redefine-sym=_diag_snap_load_usize=_diag_snap_load_usize_diag_o_dead \
    --redefine-sym=_diag_snap_load_i32=_diag_snap_load_i32_diag_o_dead \
    --redefine-sym=_diag_snap_store_ptr=_diag_snap_store_ptr_diag_o_dead \
    --redefine-sym=_diag_snap_store_usize=_diag_snap_store_usize_diag_o_dead \
    --redefine-sym=_diag_snap_store_i32=_diag_snap_store_i32_diag_o_dead \
    src/diag.o
  echo "g05_cap_tip_reapply: demoted Cap tip diag report/ctx/snap" >&2
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
build_asm/selfhost_pabi/runtime_pipeline_abi_deref_narrow_thin.o|src/runtime_pipeline_abi_deref_narrow_thin.x
build_asm/selfhost_pabi/struct_lit_fields_a64.o|src/runtime_pipeline_abi_struct_lit_fields_thin.x
build_asm/selfhost_pabi/arm64_param_home_a64.o|src/runtime_pipeline_abi_arm64_param_home_thin.x
build_asm/selfhost_pabi/w156_guard_a64.o|src/runtime_pipeline_abi_w156_guard_thin.x
build_asm/selfhost_pabi/macho_undef_cap_a64.o|src/runtime_pipeline_abi_macho_undef_cap_thin.x
build_asm/selfhost_pabi/trait_check_noop_a64.o|src/asm/trait_check_noop_thin.x
build_asm/selfhost_pabi/enum_ns_tag_a64.o|src/runtime_pipeline_abi_enum_ns_tag_thin.x
build_asm/selfhost_pabi/param_ptr_slot_a64.o|src/runtime_pipeline_abi_param_ptr_slot_thin.x
MAP
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
}
_cap_tip_fill_missing_objs

# Keep the product that is on disk. relink always overwrites xlang_asm.
# PLATFORM: MACOS Cap tip.
_cap_prev=build_asm/xlang.pre_cap_tip_reapply
rm -f "$_cap_prev"
if [ -x xlang ]; then
  cp -f xlang "$_cap_prev"
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
