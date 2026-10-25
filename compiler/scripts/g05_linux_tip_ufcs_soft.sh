#!/usr/bin/env bash
# g05_linux_tip_ufcs_soft.sh — tip-cold Linux: UFCS soft + lex stub + ELF retarget peel.
# Source from g05_relink_env after typeck peel+10.37 demote (cwd=compiler/).
# Sets: _G05_TYPECK_X_O=retarget peel; prepends soft+stub to _PABI_TIP_PEEL.
# PLATFORM: LINUX|x86_64 tip. CGB soft omitted (bound_method SEGV).
# Soft emit needs a tip-capable host (bootstrap often CG002); if emit fails and
# no prior .o, SKIP UFCS (return 0) so tip-cold can finish; hot-apply after.
set -e
_peel="${_G05_TYPECK_X_O:-${_G05_LINUX_UFCS_PEEL:-build_asm/selfhost_pabi/typeck_x_binop_cmp_peel.o}}"
if [ ! -s "$_peel" ]; then
  if [ -f typeck_x.o ]; then
    mkdir -p build_asm/selfhost_pabi
    cp -f typeck_x.o build_asm/selfhost_pabi/typeck_x_binop_cmp_peel.o
    _peel=build_asm/selfhost_pabi/typeck_x_binop_cmp_peel.o
  else
    echo "g05_linux_tip_ufcs_soft: SKIP missing peel" >&2
    return 0 2>/dev/null || exit 0
  fi
fi
mkdir -p build_asm/selfhost_pabi

_oc=""
if command -v llvm-objcopy >/dev/null 2>&1; then _oc=llvm-objcopy
elif command -v objcopy >/dev/null 2>&1; then _oc=objcopy
else
  echo "g05_linux_tip_ufcs_soft: SKIP need objcopy" >&2
  return 0 2>/dev/null || exit 0
fi

_soft_o=build_asm/selfhost_pabi/typeck_method_call_generic_ufcs_soft.o
_soft_x=src/typeck/typeck_method_call_generic_ufcs_soft.x
# Prefer cache outside wipe (tip-cold step1 wipes build_asm)
_soft_cache=/tmp/xlang_soft_cache_linux/typeck_method_call_generic_ufcs_soft.o
if [ ! -s "$_soft_o" ] && [ -s "$_soft_cache" ]; then
  cp -f "$_soft_cache" "$_soft_o"
  echo "g05_linux_tip_ufcs_soft: restored soft from cache" >&2
fi

_xl="${XLANG:-}"
_try_emit() {
  local xl="$1"
  [ -x "$xl" ] || return 1
  [ -f "$_soft_x" ] || return 1
  rm -f "${_soft_o}.partial"
  if "$xl" -backend asm -c -o "${_soft_o}.partial" "$_soft_x" \
      >/tmp/g05_linux_ufcs_soft_emit.log 2>&1 \
    && [ -s "${_soft_o}.partial" ]; then
    mv -f "${_soft_o}.partial" "$_soft_o"
    mkdir -p /tmp/xlang_soft_cache_linux
    cp -f "$_soft_o" "$_soft_cache"
    echo "g05_linux_tip_ufcs_soft: emitted via $xl" >&2
    return 0
  fi
  rm -f "${_soft_o}.partial"
  return 1
}

if ! _try_emit "${_xl:-}"; then
  for _c in ./xlang ./xlang_asm ./xlang-c ./bootstrap_xlangc /tmp/xlang_ufcs_only; do
    _try_emit "$_c" && break
  done
fi

if [ ! -s "$_soft_o" ]; then
  echo "g05_linux_tip_ufcs_soft: SKIP no soft.o (bootstrap CG002 common on tip-cold); tip continues without UFCS" >&2
  return 0 2>/dev/null || exit 0
fi

_lex_s=src/asm/generic_bound_scan_from_stash_x86_64.s
_lex_o=build_asm/selfhost_pabi/generic_bound_scan_from_stash_x86_64.o
as -o "$_lex_o" "$_lex_s" || {
  echo "g05_linux_tip_ufcs_soft: SKIP as lex stub failed" >&2
  return 0 2>/dev/null || exit 0
}

_dem=/tmp/g05_linux_ufcs_peel_demote_$$.o
_rt=build_asm/selfhost_pabi/typeck_x_ufcs_soft_retarget.o
cp -f "$_peel" "$_dem"
"$_oc" --redefine-sym=typeck_method_call_generic_ufcs=typeck_method_call_generic_ufcs_mega "$_dem" || {
  echo "g05_linux_tip_ufcs_soft: SKIP demote failed" >&2
  rm -f "$_dem"
  return 0 2>/dev/null || exit 0
}
python3 scripts/g05_elf_retarget_soft_syms.py "$_dem" "$_rt" \
  typeck_method_call_generic_ufcs_mega=typeck_method_call_generic_ufcs || {
  echo "g05_linux_tip_ufcs_soft: SKIP elf retarget failed" >&2
  rm -f "$_dem"
  return 0 2>/dev/null || exit 0
}
rm -f "$_dem"
_G05_TYPECK_X_O="$_rt"
_PABI_TIP_PEEL="$_soft_o $_lex_o ${_PABI_TIP_PEEL:-}"
export _G05_TYPECK_X_O _PABI_TIP_PEEL
echo "g05_linux_tip_ufcs_soft: peel=$_rt soft+lex prepended" >&2

# --- 10.22 take_field_slice: reverse_infer soft + call_arg thin (optional) ---
_ri_o=build_asm/selfhost_pabi/typeck_field_reverse_infer_soft.o
_ri_x=src/typeck/typeck_field_reverse_infer_soft.x
_ri_cache=/tmp/xlang_soft_cache_linux/typeck_field_reverse_infer_soft.o
_ca_o=build_asm/selfhost_pabi/call_arg_struct_lit_field.o
_ca_x=src/runtime_pipeline_abi_call_arg_struct_lit_field_thin.x
_ca_cache=/tmp/xlang_soft_cache_linux/call_arg_struct_lit_field.o

_try_soft_emit() {
  local out="$1" src="$2" cache="$3" xl
  if [ -s "$out" ]; then return 0; fi
  if [ -s "$cache" ]; then cp -f "$cache" "$out"; return 0; fi
  for xl in "${XLANG:-}" ./xlang ./xlang_asm /tmp/xlang_ufcs_only; do
    [ -x "$xl" ] || continue
    [ -f "$src" ] || continue
    if "$xl" -backend asm -c -o "${out}.partial" "$src" >/tmp/g05_linux_tfs_emit.log 2>&1 \
      && [ -s "${out}.partial" ]; then
      mv -f "${out}.partial" "$out"
      mkdir -p /tmp/xlang_soft_cache_linux
      cp -f "$out" "$cache"
      return 0
    fi
    rm -f "${out}.partial"
  done
  return 1
}

if _try_soft_emit "$_ri_o" "$_ri_x" "$_ri_cache"; then
  case " ${_PABI_TIP_PEEL:-} " in
    *" typeck_field_reverse_infer_soft.o "*) ;;
    *) _PABI_TIP_PEEL="$_ri_o ${_PABI_TIP_PEEL:-}"; export _PABI_TIP_PEEL
       echo "g05_linux_tip_ufcs_soft: prepended reverse_infer soft" >&2 ;;
  esac
fi
if _try_soft_emit "$_ca_o" "$_ca_x" "$_ca_cache"; then
  case " ${_PABI_TIP_PEEL:-} " in
    *" call_arg_struct_lit_field.o "*) ;;
    *) _PABI_TIP_PEEL="$_ca_o ${_PABI_TIP_PEEL:-}"; export _PABI_TIP_PEEL
       echo "g05_linux_tip_ufcs_soft: prepended call_arg soft" >&2 ;;
  esac
fi

# --- 10.22: array_lit durable strong (STRUCT_LIT.field→[]T) ---
_du_o=build_asm/selfhost_pabi/array_lit_durable_thin.o
_du_x=src/runtime_pipeline_abi_array_lit_durable_thin.x
_du_cache=/tmp/xlang_soft_cache_linux/array_lit_durable_thin.o
if _try_soft_emit "$_du_o" "$_du_x" "$_du_cache"; then
  case " ${_PABI_TIP_PEEL:-} " in
    *" array_lit_durable_thin.o "*) ;;
    *) _PABI_TIP_PEEL="$_du_o ${_PABI_TIP_PEEL:-}"; export _PABI_TIP_PEEL
       echo "g05_linux_tip_ufcs_soft: prepended array_lit_durable thin" >&2 ;;
  esac
fi
