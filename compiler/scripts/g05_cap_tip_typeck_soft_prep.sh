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
  build_asm/selfhost_pabi/typeck_x.cap_repr_weak.o
python3 scripts/g05_cap_tip_typeck_retarget.py build_asm/selfhost_pabi/typeck_x.cap_repr_weak.o
echo "g05_cap_tip_typeck_soft_prep: OK"
