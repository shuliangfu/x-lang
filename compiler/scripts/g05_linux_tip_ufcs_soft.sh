#!/usr/bin/env bash
# g05_linux_tip_ufcs_soft.sh — tip-cold Linux: UFCS soft + lex stub + ELF retarget peel.
# Source from g05_relink_env after typeck peel+10.37 demote (cwd=compiler/).
# Sets: _G05_TYPECK_X_O=retarget peel; prepends soft+stub to _PABI_TIP_PEEL.
# PLATFORM: LINUX|x86_64 tip. Do not wire CGB soft (SEGV on bound_method*).
set -e
# Prefer live peel from caller; fall back to default path.
_peel="${_G05_TYPECK_X_O:-${_G05_LINUX_UFCS_PEEL:-build_asm/selfhost_pabi/typeck_x_binop_cmp_peel.o}}"
if [ ! -s "$_peel" ]; then
  if [ -f typeck_x.o ]; then
    mkdir -p build_asm/selfhost_pabi
    cp -f typeck_x.o build_asm/selfhost_pabi/typeck_x_binop_cmp_peel.o
    _peel=build_asm/selfhost_pabi/typeck_x_binop_cmp_peel.o
  else
    echo "g05_linux_tip_ufcs_soft: missing peel $_peel" >&2
    exit 1
  fi
fi
mkdir -p build_asm/selfhost_pabi

_oc=""
if command -v llvm-objcopy >/dev/null 2>&1; then _oc=llvm-objcopy
elif command -v objcopy >/dev/null 2>&1; then _oc=objcopy
else
  echo "g05_linux_tip_ufcs_soft: need objcopy" >&2
  exit 1
fi

_soft_o=build_asm/selfhost_pabi/typeck_method_call_generic_ufcs_soft.o
_soft_x=src/typeck/typeck_method_call_generic_ufcs_soft.x
_xl="${XLANG:-}"
if [ -z "$_xl" ] || [ ! -x "$_xl" ]; then
  if [ -x ./xlang ]; then _xl=$PWD/xlang
  elif [ -x ./xlang_asm ]; then _xl=$PWD/xlang_asm
  fi
fi
if [ -x "$_xl" ] && [ -f "$_soft_x" ]; then
  _bak="${_soft_o}.bak_soft"
  [ -s "$_soft_o" ] && cp -f "$_soft_o" "$_bak"
  if "$_xl" -L . -backend asm -c "$_soft_x" -o "$_soft_o" >/tmp/g05_linux_ufcs_soft_emit.log 2>&1 \
    && [ -s "$_soft_o" ]; then
    echo "g05_linux_tip_ufcs_soft: emitted $_soft_o" >&2
  elif [ -s "$_bak" ]; then
    cp -f "$_bak" "$_soft_o"
    echo "g05_linux_tip_ufcs_soft: keep prior $_soft_o" >&2
  else
    echo "g05_linux_tip_ufcs_soft: ERROR emit $_soft_x failed" >&2
    cat /tmp/g05_linux_ufcs_soft_emit.log >&2 || true
    exit 1
  fi
elif [ ! -s "$_soft_o" ]; then
  echo "g05_linux_tip_ufcs_soft: ERROR no soft .o and no XLANG" >&2
  exit 1
fi

_lex_s=src/asm/generic_bound_scan_from_stash_x86_64.s
_lex_o=build_asm/selfhost_pabi/generic_bound_scan_from_stash_x86_64.o
as -o "$_lex_o" "$_lex_s" || { echo "g05_linux_tip_ufcs_soft: as lex stub failed" >&2; exit 1; }

_dem=/tmp/g05_linux_ufcs_peel_demote_$$.o
_rt=build_asm/selfhost_pabi/typeck_x_ufcs_soft_retarget.o
cp -f "$_peel" "$_dem"
"$_oc" --redefine-sym=typeck_method_call_generic_ufcs=typeck_method_call_generic_ufcs_mega "$_dem"
python3 scripts/g05_elf_retarget_soft_syms.py "$_dem" "$_rt" \
  typeck_method_call_generic_ufcs_mega=typeck_method_call_generic_ufcs
rm -f "$_dem"
_G05_TYPECK_X_O="$_rt"
_PABI_TIP_PEEL="$_soft_o $_lex_o ${_PABI_TIP_PEEL:-}"
export _G05_TYPECK_X_O _PABI_TIP_PEEL
echo "g05_linux_tip_ufcs_soft: peel=$_rt soft+lex prepended" >&2
