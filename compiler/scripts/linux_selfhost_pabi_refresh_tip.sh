#!/bin/bash
# w1483: refresh the tip-dependent part of build_asm/selfhost_pabi after
# g05_ensure rebuilt src/runtime_pipeline_abi.o, without regenerating the
# whole sidecar folder (linux_selfhost_pabi_sidecars.sh):
#   1. pabi_alias.o = copy of the current src pabi (+ _rest alias only if
#      the tip object does not define it already). A stale alias links the
#      old pabi and silently drops the new injected thins.
#   2. asl_*.o = arr_struct_lit peers the tip pabi leaves U (HARD BAN
#      PREFER into the .o). g05_relink_env.sh appends them when present.
# Product compiler (./xlang_asm, else ./xlang) builds the SHARED thins.
# PLATFORM: LINUX x86_64. Darwin and Windows skip.
# Usage (from compiler/): bash scripts/linux_selfhost_pabi_refresh_tip.sh
set -euo pipefail
cd "$(dirname "$0")/.."

if [ "$(uname -s)" != "Linux" ]; then
  exit 0
fi
OUT=build_asm/selfhost_pabi
if [ ! -f "$OUT/READY" ]; then
  echo "linux_selfhost_pabi_refresh_tip: no $OUT/READY; skip"
  exit 0
fi
XL=./xlang_asm
[ -x "$XL" ] || XL=./xlang
if [ ! -x "$XL" ]; then
  echo "linux_selfhost_pabi_refresh_tip: no product compiler" >&2
  exit 1
fi

# 1. pabi_alias
if [ ! -s "$OUT/pabi_alias.o" ] || ! cmp -s src/runtime_pipeline_abi.o "$OUT/pabi_alias.o"; then
  cp -f src/runtime_pipeline_abi.o "$OUT/pabi_alias.o.new"
  if ! nm "$OUT/pabi_alias.o.new" | awk '$3=="glue_try_index_var_or_field_base_to_rbx_elf_rest"{found=1} END{exit !found}'; then
    _base_addr=$(nm "$OUT/pabi_alias.o.new" | awk '$3=="glue_try_index_var_or_field_base_to_rbx_elf_c"{print $1; exit}')
    if [ -z "$_base_addr" ]; then
      echo "linux_selfhost_pabi_refresh_tip: index base symbol missing" >&2
      rm -f "$OUT/pabi_alias.o.new"
      exit 1
    fi
    objcopy --add-symbol "glue_try_index_var_or_field_base_to_rbx_elf_rest=.text:0x${_base_addr},global,function" "$OUT/pabi_alias.o.new"
  fi
  mv -f "$OUT/pabi_alias.o.new" "$OUT/pabi_alias.o"
  echo "linux_selfhost_pabi_refresh_tip: pabi_alias.o <- src/runtime_pipeline_abi.o"
fi

# 2. arr_struct_lit peers
for _asl in call_bulk call_elems copy_bulk copy_elems call_one_elem; do
  _src="src/runtime_pipeline_abi_arr_struct_lit_${_asl}_thin.x"
  _dst="$OUT/asl_$_asl.o"
  # .o suffix required: the driver picks object output by extension.
  _tmp="$OUT/asl_$_asl.tmp.o"
  if [ -s "$_dst" ] && [ ! "$_src" -nt "$_dst" ] && [ ! "$XL" -nt "$_dst" ]; then
    continue
  fi
  if ! timeout 240 env XLANG_PREFER_ASM_O=1 "$XL" -backend asm -c "$_src" -o "$_tmp"; then
    echo "linux_selfhost_pabi_refresh_tip: $_src failed" >&2
    rm -f "$_tmp"
    exit 1
  fi
  mv -f "$_tmp" "$_dst"
  echo "linux_selfhost_pabi_refresh_tip: $_dst"
done
echo "linux_selfhost_pabi_refresh_tip: OK"
