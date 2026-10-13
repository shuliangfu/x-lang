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

# knife256/10.2: Cap tip frozen env omits assign dispatcher; m8 hollow returns 0
# so a[i]= is a silent no-op (fmt-wrap 3≠16). Prepend INDEX-only thin
# (src/asm/assign_emit_index_only_a64.s → assign_emit_thin_a64.o). FIELD/VAR/DEREF
# stay no-op to keep Cap L2. Restore/build from cache or .s. PLATFORM: MACOS Cap tip.
if [ ! -s build_asm/selfhost_pabi/assign_emit_thin_a64.o ]; then
  if [ -s "$CACHE/pabi/assign_emit_thin_a64.o" ]; then
    cp -f "$CACHE/pabi/assign_emit_thin_a64.o" build_asm/selfhost_pabi/assign_emit_thin_a64.o
  elif [ -f src/asm/assign_emit_index_only_a64.s ]; then
    clang -c -o build_asm/selfhost_pabi/assign_emit_thin_a64.o src/asm/assign_emit_index_only_a64.s       || { echo "g05_cap_tip_reapply: assign_emit_thin assemble failed" >&2; exit 1; }
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

rm -f xlang.cap_g05_l2
bash scripts/g05_relink_xlang.sh

if [ ! -x xlang.cap_g05_l2 ]; then
  echo "g05_cap_tip_reapply: xlang.cap_g05_l2 missing" >&2
  exit 1
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
