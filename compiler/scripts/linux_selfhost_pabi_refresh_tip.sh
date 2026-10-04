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
# w1493: the tip pabi keeps LOCAL copies of four C-rest modlet faces next
# to their GLOBAL .x definitions, and the rest's own calls (mega body,
# mutable lit inits, register lets) point at the local copies. prepare
# then fills g_pipeline_asm_modlet_cold while the global load/find read
# g_pipeline_asm_modlet, so any module-let access fails with CG002
# (code_len=12). elf_retarget_local_dup_relocs.py points those
# relocations at the global faces. Build .new every time and install only
# when it differs, so an unchanged tip does not touch the alias.
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
if ! python3 scripts/elf_retarget_local_dup_relocs.py "$OUT/pabi_alias.o.new" \
  pipeline_asm_modlet_prepare_and_emit_elf_c \
  pipeline_asm_modlet_seed_nonzero_inits_elf_c \
  pipeline_asm_modlet_store_from_rax_elf_c \
  pipeline_asm_modlet_name_is_shared; then
  echo "linux_selfhost_pabi_refresh_tip: modlet retarget failed" >&2
  rm -f "$OUT/pabi_alias.o.new"
  exit 1
fi
if [ -s "$OUT/pabi_alias.o" ] && cmp -s "$OUT/pabi_alias.o.new" "$OUT/pabi_alias.o"; then
  rm -f "$OUT/pabi_alias.o.new"
else
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
# 3. w1491 slot sizer: slot.o must keep pipe_slot_bytes_named_in_mod
#    strong (see linux_selfhost_pabi_sidecars.sh). Rebuild it from the
#    thin when the thin is newer or the symbol is still weak.
#    w1512: asm_fixed_array_total_bytes_mod too (same epilogue-jump bug in
#    the pabi copy: returned 1, so a local [N]Struct got an 8-byte slot).
_slot_src=src/runtime_pipeline_abi_slot_bytes_thin.x
_slot_dst="$OUT/slot.o"
if [ -f "$_slot_src" ] && { [ ! -s "$_slot_dst" ] || [ "$_slot_src" -nt "$_slot_dst" ] \
    || ! nm "$_slot_dst" | awk '$2=="T"&&$3=="pipe_slot_bytes_named_in_mod"{f++} $2=="T"&&$3=="asm_fixed_array_total_bytes_mod"{f++} END{exit f!=2}'; }; then
  _slot_tmp="$OUT/slot.tmp.o"
  if ! timeout 240 "$XL" -backend asm -c "$_slot_src" -o "$_slot_tmp"; then
    echo "linux_selfhost_pabi_refresh_tip: $_slot_src failed" >&2
    rm -f "$_slot_tmp"
    exit 1
  fi
  while read -r _sym; do
    [ -n "$_sym" ] || continue
    case "$_sym" in
      pipe_local_slot_bytes_mod|pipe_slot_bytes_named_in_mod|asm_fixed_array_total_bytes_mod) ;;
      *) objcopy --weaken-symbol="$_sym" "$_slot_tmp" ;;
    esac
  done < <(nm "$_slot_tmp" | awk '$2=="T"{print $3}')
  # w2055: the override only works under the pabi names. A renamed
  # definition (module prefix) left the buggy pabi copy live, so stop here.
  if ! nm "$_slot_tmp" | awk '$2=="T"&&$3=="pipe_slot_bytes_named_in_mod"{f++} $2=="T"&&$3=="asm_fixed_array_total_bytes_mod"{f++} $2=="T"&&$3=="pipe_local_slot_bytes_mod"{f++} END{exit f!=3}'; then
    echo "linux_selfhost_pabi_refresh_tip: $_slot_src lacks a strong slot sizer name" >&2
    rm -f "$_slot_tmp"
    exit 1
  fi
  mv -f "$_slot_tmp" "$_slot_dst"
  echo "linux_selfhost_pabi_refresh_tip: $_slot_dst (named_in_mod+fixed_array strong)"
fi
# 4. w2055 collect-deps import scan: cimp.o keeps
#    xlang_module_collect_imports_from_buf strong ahead of the pabi copy,
#    whose old C body calls the struct-returning lexer_init(). Rebuild when
#    the thin or the compiler is newer, or the name is not strong.
_cimp_src=src/runtime_pipeline_abi_collect_imports_thin.x
_cimp_dst="$OUT/cimp.o"
if [ -f "$_cimp_src" ] && { [ ! -s "$_cimp_dst" ] || [ "$_cimp_src" -nt "$_cimp_dst" ] \
    || [ "$XL" -nt "$_cimp_dst" ] \
    || ! nm "$_cimp_dst" | awk '$2=="T"&&$3=="xlang_module_collect_imports_from_buf"{f=1} END{exit !f}'; }; then
  _cimp_tmp="$OUT/cimp.tmp.o"
  rm -f "$_cimp_dst"
  if ! timeout 240 env XLANG_PREFER_ASM_O=1 "$XL" -backend asm -c "$_cimp_src" -o "$_cimp_tmp"; then
    echo "linux_selfhost_pabi_refresh_tip: $_cimp_src failed" >&2
    rm -f "$_cimp_tmp"
    exit 1
  fi
  while read -r _sym; do
    [ -n "$_sym" ] || continue
    [ "$_sym" = xlang_module_collect_imports_from_buf ] || objcopy --weaken-symbol="$_sym" "$_cimp_tmp"
  done < <(nm "$_cimp_tmp" | awk '$2=="T"{print $3}')
  if ! nm "$_cimp_tmp" | awk '$2=="T"&&$3=="xlang_module_collect_imports_from_buf"{f=1} END{exit !f}'; then
    echo "linux_selfhost_pabi_refresh_tip: $_cimp_src lacks strong xlang_module_collect_imports_from_buf" >&2
    rm -f "$_cimp_tmp"
    exit 1
  fi
  if nm -u "$_cimp_tmp" | awk '$2=="lexer_init"{f=1} END{exit !f}'; then
    echo "linux_selfhost_pabi_refresh_tip: $_cimp_src still calls lexer_init" >&2
    rm -f "$_cimp_tmp"
    exit 1
  fi
  mv -f "$_cimp_tmp" "$_cimp_dst"
  echo "linux_selfhost_pabi_refresh_tip: $_cimp_dst (collect imports strong)"
fi
echo "linux_selfhost_pabi_refresh_tip: OK"
