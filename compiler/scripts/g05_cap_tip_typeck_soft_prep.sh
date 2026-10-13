#!/usr/bin/env bash
# g05_cap_tip_typeck_soft_prep.sh — tip pure-asm softs + Mach-O retarget typeck_x.cap_repr_weak.o
# PLATFORM: MACOS Cap tip sidecar. Run from compiler/ before g05_env_cap_tip_darwin.sh relink.
set -e
cd "$(dirname "$0")/.."
. scripts/pure_ld_shared.sh
export XLANG="${XLANG:-$PWD/xlang}"
pure_asm_x_to_o build_asm/selfhost_pabi/typeck_call_arg_ptr_named_soft.o \
  src/typeck/typeck_call_arg_ptr_named_soft.x
pure_asm_x_to_o build_asm/selfhost_pabi/typeck_get_dep_ptr_named_soft.o \
  src/typeck/typeck_get_dep_ptr_named_soft.x
pure_asm_x_to_o build_asm/selfhost_pabi/typeck_type_refs_equal_soft.o \
  src/typeck/typeck_type_refs_equal_soft.x
OC="${LLVM_OBJCOPY:-}"
if [ -z "$OC" ]; then
  for c in /opt/homebrew/opt/llvm/bin/llvm-objcopy /usr/local/opt/llvm/bin/llvm-objcopy; do
    [ -x "$c" ] && OC=$c && break
  done
fi
[ -n "$OC" ] || { echo "need llvm-objcopy" >&2; exit 1; }
cp -f typeck_x.o build_asm/selfhost_pabi/typeck_x.cap_repr_weak.o
"$OC" \
  --redefine-sym=_typeck_call_arg_repr_compatible_ok=_typeck_call_arg_repr_compatible_ok__demoted \
  --redefine-sym=_typeck_get_dep_return_type_in_caller_arena=_typeck_get_dep_return_type_in_caller_arena__demoted \
  --redefine-sym=_typeck_type_refs_equal=_typeck_type_refs_equal__demoted \
  build_asm/selfhost_pabi/typeck_x.cap_repr_weak.o
python3 scripts/g05_cap_tip_typeck_retarget.py build_asm/selfhost_pabi/typeck_x.cap_repr_weak.o
echo "g05_cap_tip_typeck_soft_prep: OK"

# knife256/10.2: demote pthin p6 pack_dup_field so Cap tip soft can first-win.
# Without this, pure-ld hits duplicate symbol with parser_asm_struct_dup_field_soft.o.
_NOP9B="build_asm/selfhost_pabi/parser_asm_thin_glue.nop9b.o"
_MEM="g05_pthin_p6.jJKZX5"
if [ -f "$_NOP9B" ] && [ -f build_asm/selfhost_pabi/parser_asm_struct_dup_field_soft.o ]; then
  if nm "$_NOP9B" 2>/dev/null | grep -q 'T _parser_asm_struct_layout_pack_dup_field_c$'; then
    _OC="${OC:-}"
    if [ -z "$_OC" ]; then
      _OC="$(command -v llvm-objcopy || true)"
      [ -z "$_OC" ] && _OC="$(xcrun -f llvm-objcopy 2>/dev/null || true)"
    fi
    if [ -n "$_OC" ]; then
      _ABS_NOP9B="$(pwd)/$_NOP9B"
      mkdir -p /tmp/g05_dup_dem
      ar p "$_ABS_NOP9B" "$_MEM" > /tmp/g05_dup_dem/mem.o 2>/dev/null || true
      if [ -s /tmp/g05_dup_dem/mem.o ]; then
        if "$_OC" --redefine-sym             _parser_asm_struct_layout_pack_dup_field_c=_parser_asm_struct_layout_pack_dup_field_c__demoted             /tmp/g05_dup_dem/mem.o /tmp/g05_dup_dem/mem_dem.o; then
          cp /tmp/g05_dup_dem/mem_dem.o /tmp/g05_dup_dem/"$_MEM"
          (cd /tmp/g05_dup_dem && ar r "$_ABS_NOP9B" "$_MEM")
          echo "g05_cap_tip_typeck_soft_prep: demoted pack_dup_field in nop9b"
        fi
      fi
    fi
  fi
fi
