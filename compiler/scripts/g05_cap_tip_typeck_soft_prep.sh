#!/usr/bin/env bash
# g05_cap_tip_typeck_soft_prep.sh — tip pure-asm softs + Mach-O retarget typeck_x.cap_repr_weak.o
# PLATFORM: MACOS Cap tip sidecar. Run from compiler/ before g05_env_cap_tip_darwin.sh relink.
set -e
cd "$(dirname "$0")/.."
. scripts/pure_ld_shared.sh
# Prefer LEGACY bak for soft emit (Cap tip pure-asm truncates call_arg soft).
if [ -z "${XLANG:-}" ] || [ ! -x "${XLANG:-}" ]; then
  if [ -x "$PWD/xlang.product_legacy_bak" ]; then
    export XLANG="$PWD/xlang.product_legacy_bak"
  else
    export XLANG="$PWD/xlang"
  fi
fi

# Cap tip/LEGACY pure-asm .x soft emit may be empty; keep prior .o if rebuild fails.
_soft_keep() {
  local o="$1" x="$2"
  local bak="${o}.bak_soft"
  [ -s "$o" ] && cp -f "$o" "$bak"
  if pure_asm_x_to_o "$o" "$x"; then
    if [ -s "$bak" ]; then
      local prev now
      prev=$(wc -c < "$bak" | tr -d ' ')
      now=$(wc -c < "$o" | tr -d ' ')
      if [ "$now" -lt $((prev * 9 / 10)) ]; then
        echo "g05_cap_tip_typeck_soft_prep: emit shrank $o $prev->$now; restore" >&2
        cp -f "$bak" "$o"
      fi
    fi
    return 0
  fi
  if [ -s "$bak" ]; then
    cp -f "$bak" "$o"
    echo "g05_cap_tip_typeck_soft_prep: keep prior $o (pure-asm empty)" >&2
    return 0
  fi
  if [ -s "$o" ]; then
    echo "g05_cap_tip_typeck_soft_prep: keep prior $o" >&2
    return 0
  fi
  echo "g05_cap_tip_typeck_soft_prep: missing soft $o" >&2
  return 1
}
_soft_keep build_asm/selfhost_pabi/typeck_call_arg_ptr_named_soft.o \
  src/typeck/typeck_call_arg_ptr_named_soft.x
_soft_keep build_asm/selfhost_pabi/typeck_get_dep_ptr_named_soft.o \
  src/typeck/typeck_get_dep_ptr_named_soft.x
# hand-asm equal soft (pure-asm .x truncates and greens NAMED vs i32)
as -arch arm64 -o build_asm/selfhost_pabi/typeck_type_refs_equal_soft.o \
  src/asm/typeck_type_refs_equal_hardfail_a64.s \
  || { echo "g05_cap_tip_typeck_soft_prep: equal asm soft failed" >&2; exit 1; }
_soft_keep build_asm/selfhost_pabi/typeck_field_unknown_hard_fail_soft.o \
  src/typeck/typeck_field_unknown_hard_fail_soft.x
_soft_keep build_asm/selfhost_pabi/typeck_field_type_ref_deps_soft.o \
  src/typeck/typeck_field_type_ref_deps_soft.x
_soft_keep build_asm/selfhost_pabi/typeck_field_offset_deps_soft.o \
  src/typeck/typeck_field_offset_deps_soft.x
OC="${LLVM_OBJCOPY:-}"
if [ -z "$OC" ]; then
  for c in /opt/homebrew/opt/llvm/bin/llvm-objcopy /usr/local/opt/llvm/bin/llvm-objcopy; do
    [ -x "$c" ] && OC=$c && break
  done
fi
[ -n "$OC" ] || { echo "need llvm-objcopy" >&2; exit 1; }
# knife256/10.2: hand-asm try_propagate hardfail (pure-asm .x emit empty on Cap tip)
# Always reassemble from .s so identity/enclosing fixes land.
as -arch arm64 -o build_asm/selfhost_pabi/typeck_try_propagate_hardfail_a64.o \
  src/asm/typeck_try_propagate_hardfail_a64.s \
  || { echo "g05_cap_tip_typeck_soft_prep: try_propagate asm soft failed" >&2; exit 1; }
cp -f typeck_x.o build_asm/selfhost_pabi/typeck_x.cap_repr_weak.o
"$OC" \
  --redefine-sym=_typeck_call_arg_repr_compatible_ok=_typeck_call_arg_repr_compatible_ok__demoted \
  --redefine-sym=_typeck_get_dep_return_type_in_caller_arena=_typeck_get_dep_return_type_in_caller_arena__demoted \
  --redefine-sym=_typeck_type_refs_equal=_typeck_type_refs_equal__demoted \
  --redefine-sym=_typeck_field_unknown_hard_fail=_typeck_field_unknown_hard_fail__demoted \
  --redefine-sym=_typeck_check_expr_try_propagate=_typeck_check_expr_try_propagate__demoted \
  --redefine-sym=_typeck_get_field_type_ref_from_layout_deps=_typeck_get_field_type_ref_from_layout_deps__demoted \
  --redefine-sym=_typeck_get_field_offset_from_layout_deps=_typeck_get_field_offset_from_layout_deps__demoted \
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
