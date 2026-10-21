#!/bin/bash
# Build the Linux self-host sidecars that g05_relink_env.sh links ahead of
# src/runtime_pipeline_abi.o.
#
# The product compiler compiles the committed thins. Colliding extra
# symbols are weakened so the stale body in runtime_pipeline_abi.o does
# not win, and so thin-only helpers do not replace product definitions.
# Do not PREFER these thins into that object. Do not gcc -E them.
#
# pipeline_asm_emit_return_elf_impl is emitted in the same .text as the
# two array bodies. Its bounds checks relocate to xlang_panic_, which
# the freestanding link does not define. Those two calls are noped and
# their relocs dropped. The product strong definition of that symbol
# stays the one that runs.
#
# PLATFORM: LINUX x86_64. Darwin and Windows skip.
# Usage (from compiler/): bash scripts/linux_selfhost_pabi_sidecars.sh
set -euo pipefail
cd "$(dirname "$0")/.."

if [ "$(uname -s)" != "Linux" ]; then
  echo "linux_selfhost_pabi_sidecars: skip $(uname -s)"
  exit 0
fi
# note743o: tip-cold tip/bootstrap may be CG002; try each product then
# seeds/bootstrap_xlangc.<os>.<arch> (same pin-egg as note743k/l/m/n).
# PLATFORM: LINUX.
_sidecar_xls=""
for _c in ./xlang ./xlang_asm ./bootstrap_xlangc ./xlang-c; do
  if [ -x "$_c" ]; then
    case " $_sidecar_xls " in
      *" $_c "*) ;;
      *) _sidecar_xls="$_sidecar_xls $_c" ;;
    esac
  fi
done
_sc_os="$(uname -s 2>/dev/null | tr "[:upper:]" "[:lower:]")"
_sc_arch="$(uname -m 2>/dev/null)"
case "$_sc_os" in darwin) _sc_os=darwin ;; linux) _sc_os=linux ;; *) _sc_os="" ;; esac
case "$_sc_arch" in x86_64|amd64) _sc_arch=x86_64 ;; arm64|aarch64) _sc_arch=arm64 ;; *) _sc_arch="" ;; esac
if [ -n "$_sc_os" ] && [ -n "$_sc_arch" ]; then
  _sc_egg="seeds/bootstrap_xlangc.${_sc_os}.${_sc_arch}"
  if [ -x "$_sc_egg" ]; then
    case " $_sidecar_xls " in
      *" $_sc_egg "*) ;;
      *) _sidecar_xls="$_sidecar_xls $_sc_egg" ;;
    esac
  fi
fi
if [ -z "$_sidecar_xls" ]; then
  echo "linux_selfhost_pabi_sidecars: no xl / pin-egg" >&2
  exit 1
fi

OUT=build_asm/selfhost_pabi
WORK="$(mktemp -d "${TMPDIR:-/tmp}/selfhost_pabi.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
# note743s: never rm -rf "$OUT". g05_ensure evals g05_relink_env first and
# drops pure overlays (call_spill / cltd_cqo / elf_layout_64k / …) into the
# same dir; a full wipe then leaves G05_OBJS listing ghosts → MISSING×19.
# Clear only sidecar-owned faces (+ READY / egg stub); keep peer overlays.
# PLATFORM: LINUX.
mkdir -p "$OUT"
_sidecar_owned="slot.o esz.o loc.o lea.o rec.o two.o one.o as.o sizeof.o base.o spill.o assign.o modlet.o pabi_alias.o elem_const.o index_elem_from_type.o index_elem_true_i8.o index_elem_wrap.o emit_index_arms_true_i8.o emit_index_elf_true_i8.o assign_index_true_i8.o force_esz_true_i8.o array_lit_esz_true_i8.o index_base_rbx_egg_stub.o index_base_rbx_egg_stub.s READY"
for _sf in $_sidecar_owned; do
  rm -f "$OUT/$_sf"
done
rm -f "$OUT"/runtime_pipeline_abi_fnptr_as_*.o

# Weaken every global function except the names passed after dst.
weaken_keep() {
  local src="$1"
  local dst="$2"
  shift 2
  cp "$src" "$dst"
  local keeps=" $* "
  local sym
  while read -r sym; do
    [ -n "$sym" ] || continue
    case "$keeps" in
      *" $sym "*) ;;
      *) objcopy --weaken-symbol="$sym" "$dst" ;;
    esac
  done < <(nm "$src" | awk '$2=="T"{print $3}')
}

compile_one() {
  local src="$1"
  local dst="$2"
  local xl
  echo "linux_selfhost_pabi_sidecars: $src"
  for xl in $_sidecar_xls; do
    rm -f "$dst"
    if timeout 240 "$xl" -c -backend asm -o "$dst" "$src" >/dev/null 2>&1 \
      && [ -s "$dst" ]; then
      echo "linux_selfhost_pabi_sidecars: OK via $xl (note743o)" >&2
      return 0
    fi
    rm -f "$dst"
  done
  echo "linux_selfhost_pabi_sidecars: ERROR pure-asm failed for $src" >&2
  return 1
}

compile_one src/runtime_pipeline_abi_slot_bytes_thin.x "$WORK/slot.o"
compile_one src/runtime_pipeline_abi_fnptr_array_esz_thin.x "$WORK/esz.o"
compile_one src/runtime_pipeline_abi_asm_locals_thin.x "$WORK/loc.o"
compile_one src/runtime_pipeline_abi_fixed_array_copy_helpers_thin.x "$WORK/lea.o"
compile_one src/runtime_pipeline_abi_asm_expr_helpers_thin.x "$WORK/rec.o"
# note743p / w987: PREFER_ASM_O so DIV/MOD in the copy thin do not emit
# extra xlang_panic_ relocs. Without it egg/tip emits 4; nop_panic expected
# 2 (bounds checks) or 0 when PREFER drops all panic faces. PLATFORM: LINUX.
echo "linux_selfhost_pabi_sidecars: src/runtime_pipeline_abi_fixed_array_copy_thin.x"
_two_ok=0
for xl in $_sidecar_xls; do
  rm -f "$WORK/two_raw.o"
  if timeout 240 env XLANG_PREFER_ASM_O=1 "$xl" -c -backend asm \
    -o "$WORK/two_raw.o" src/runtime_pipeline_abi_fixed_array_copy_thin.x >/dev/null 2>&1 \
    && [ -s "$WORK/two_raw.o" ]; then
    echo "linux_selfhost_pabi_sidecars: OK via $xl PREFER (note743p)" >&2
    _two_ok=1
    break
  fi
  rm -f "$WORK/two_raw.o"
done
if [ "$_two_ok" != "1" ]; then
  echo "linux_selfhost_pabi_sidecars: ERROR pure-asm failed for fixed_array_copy_thin" >&2
  exit 1
fi
compile_one src/runtime_pipeline_abi_for_call_args_thin.x "$WORK/one.o"
compile_one src/runtime_pipeline_abi_fnptr_as_thin.x "$WORK/as_raw.o"
compile_one src/runtime_pipeline_abi_elf_codegen_forwarders_thin.x "$WORK/forwarders.o"

for src in src/runtime_pipeline_abi_fnptr_as_*.x; do
  base="$(basename "$src" .x)"
  if [ "$base" = "runtime_pipeline_abi_fnptr_as_thin" ]; then
    continue
  fi
  compile_one "$src" "$OUT/${base}.o"
done

cat > "$WORK/nop_panic.py" <<'PY'
import struct, sys
src, dst = sys.argv[1], sys.argv[2]
data = bytearray(open(src, "rb").read())
e_shoff, = struct.unpack_from("<Q", data, 40)
e_shentsize, = struct.unpack_from("<H", data, 58)
e_shnum, = struct.unpack_from("<H", data, 60)
e_shstrndx, = struct.unpack_from("<H", data, 62)
secs = []
for i in range(e_shnum):
    off = e_shoff + i * e_shentsize
    raw = bytearray(data[off:off + e_shentsize])
    u = struct.unpack_from("<IIQQQQIIQQ", raw)
    secs.append({
        "i": i, "raw": raw, "name_off": u[0], "type": u[1],
        "offset": u[4], "size": u[5], "link": u[6], "info": u[7],
    })
shstr = bytes(data[secs[e_shstrndx]["offset"]:secs[e_shstrndx]["offset"] + secs[e_shstrndx]["size"]])
for s in secs:
    end = shstr.find(b"\0", s["name_off"])
    s["name"] = shstr[s["name_off"]:end].decode()
sym = next(s for s in secs if s["type"] == 2)
strtab = bytes(data[secs[sym["link"]]["offset"]:secs[sym["link"]]["offset"] + secs[sym["link"]]["size"]])
panic_idx = None
for i in range(sym["size"] // 24):
    st_name, = struct.unpack_from("<I", data, sym["offset"] + i * 24)
    name = strtab[st_name:strtab.find(b"\0", st_name)].decode()
    if name == "xlang_panic_":
        panic_idx = i
if panic_idx is None:
    open(dst, "wb").write(data)
    print("no xlang_panic_ in copy thin")
    sys.exit(0)
text = next(s for s in secs if s["name"] in (".text", "text"))
blobs = {text["i"]: bytearray(data[text["offset"]:text["offset"] + text["size"]])}
noped = 0
for s in secs:
    if s["i"] == text["i"]:
        continue
    if s["size"] == 0 or s["type"] == 8:
        blobs[s["i"]] = b""
        continue
    blob = bytearray(data[s["offset"]:s["offset"] + s["size"]])
    if s["type"] == 4 and s["info"] == text["i"]:
        keep = bytearray()
        for i in range(s["size"] // 24):
            o = i * 24
            r_off, r_info, _r_add = struct.unpack_from("<QQq", blob, o)
            if (r_info >> 32) == panic_idx:
                call_at = r_off - 1
                text_blob = blobs[text["i"]]
                if text_blob[call_at] != 0xE8:
                    raise SystemExit("expected e8 at text+%#x" % call_at)
                text_blob[call_at:call_at + 5] = b"\x90" * 5
                noped += 1
            else:
                keep += blob[o:o + 24]
        blobs[s["i"]] = bytes(keep)
        s["size"] = len(keep)
        continue
    blobs[s["i"]] = bytes(blob)
# note743p.1: contract stays expected 2 (bounds checks). Do not widen the
# count gate. PREFER_ASM_O on copy thin only drops DIV/MOD extras; if the
# object has no xlang_panic_ at all, the early exit above already applies.
if noped != 2:
    raise SystemExit("expected 2 panic calls, noped %d" % noped)
out = bytearray(data[:64])
for s in sorted(secs, key=lambda s: s["offset"] if s["offset"] else 10**18):
    blob = blobs[s["i"]]
    if not blob:
        struct.pack_into("<Q", s["raw"], 24, 0)
        struct.pack_into("<Q", s["raw"], 32, s["size"] if s["type"] == 8 else 0)
        continue
    while len(out) % 8:
        out += b"\0"
    struct.pack_into("<Q", s["raw"], 24, len(out))
    struct.pack_into("<Q", s["raw"], 32, len(blob))
    out += blob
while len(out) % 8:
    out += b"\0"
struct.pack_into("<Q", out, 40, len(out))
for s in secs:
    out += s["raw"]
open(dst, "wb").write(out)
print("noped", noped)
PY
python3 "$WORK/nop_panic.py" "$WORK/two_raw.o" "$WORK/two_stripped.o"

# w1491: pipe_slot_bytes_named_in_mod stays strong too. The copy in
# runtime_pipeline_abi.o jumps to its epilogue from the name-match while
# (returns 1), so every struct local got an 8/16-byte slot and overlapped
# its neighbours (runtime_read_file_malloc_impl view vs out_len).
# w1512: asm_fixed_array_total_bytes_mod has the same bug in the pabi copy
# (returns 1, so a local [N]Struct got an 8-byte slot); keep slot.o's.
weaken_keep "$WORK/slot.o" "$OUT/slot.o" pipe_local_slot_bytes_mod pipe_slot_bytes_named_in_mod \
  asm_fixed_array_total_bytes_mod
weaken_keep "$WORK/esz.o" "$OUT/esz.o" \
  pipeline_asm_array_lit_elem_byte_sz_c \
  glue_array_lit_force_esz_from_elem_type_c \
  glue_fixed_array_temp_bytes
weaken_keep "$WORK/loc.o" "$OUT/loc.o" pipeline_asm_local_offset_c
weaken_keep "$WORK/lea.o" "$OUT/lea.o" glue_call_arg_var_use_lea_not_load_elf_c
weaken_keep "$WORK/rec.o" "$OUT/rec.o" pipeline_asm_emit_expr_elf_rec
weaken_keep "$WORK/two_stripped.o" "$OUT/two.o" \
  glue_struct_lit_store_fixed_array_field_elf_c \
  pipeline_asm_emit_array_lit_flat_elf_c
weaken_keep "$WORK/one.o" "$OUT/one.o" pipeline_asm_emit_expr_elf_for_call_args
weaken_keep "$WORK/as_raw.o" "$OUT/as.o" pipeline_asm_emit_as_elf_impl
weaken_keep "$WORK/forwarders.o" "$OUT/sizeof.o" pipeline_sizeof_elf_ctx

if nm -u "$OUT/two.o" | awk '{print $2}' | grep -qx 'xlang_panic_'; then
  # A leftover undefined name with no reloc does not fail the link.
  # A remaining reloc would. objdump is the check.
  if objdump -r "$OUT/two.o" | grep -q 'xlang_panic_'; then
    echo "linux_selfhost_pabi_sidecars: panic reloc survived" >&2
    exit 1
  fi
fi

# w944: module-level array index address, then the spill walker compiled
# by a compiler that already emits that store. The walker calls the
# previous body under a second name so locals and fields stay there.
compile_one src/runtime_pipeline_abi_index_base_rbx_thin.x "$OUT/base.o"
compile_one src/runtime_pipeline_abi_w157_sum_thin.x "$WORK/sum_raw.o"
python3 "$WORK/nop_panic.py" "$WORK/sum_raw.o" "$WORK/sum_noped.o"
objcopy \
  --redefine-sym w157_sum_expr_call_spill_bytes=w944_sum_expr_spill_helper \
  --weaken-symbol glue_sum_block_slice_reent_dc_bytes_c \
  --weaken-symbol w157_walk_block_rec_x \
  "$WORK/sum_noped.o" "$OUT/spill.o"
if objdump -r "$OUT/spill.o" | grep -q 'xlang_panic_'; then
  echo "linux_selfhost_pabi_sidecars: spill panic reloc survived" >&2
  exit 1
fi

# w945: assignment. The gcc body jumps to the epilogue after the
# pointer peel, so `*p = v` returns success and emits no store. This
# object falls through to the scalar store. Extra exports stay weak so
# glue_emit_assign_rhs_to_rax_elf_c remains the product body.
# PLATFORM: LINUX. Do not PREFER this into runtime_pipeline_abi.o.
compile_one src/runtime_pipeline_abi_assign_thin.x "$WORK/assign_raw.o"
weaken_keep "$WORK/assign_raw.o" "$OUT/assign.o" \
  pipeline_asm_emit_assign_elf_c \
  asg_thin_align_next_offset \
  asg_thin_ctx_off_next_offset \
  asg_thin_load_i32_le \
  asg_thin_store_i32_le
if objdump -r "$OUT/assign.o" | grep -q 'xlang_panic_'; then
  echo "linux_selfhost_pabi_sidecars: assign panic reloc survived" >&2
  exit 1
fi

# w946: module STRUCT_LIT array init. The baker treated S { v: 1 } as a
# scalar constant and returned -1, so prepare aborted with code_len 0.
# This object is the whole modlet family and its one table. Do not weaken
# a member of that family. Do not PREFER this into runtime_pipeline_abi.o.
# w987: PREFER_ASM_O so DIV/MOD in the folder do not emit xlang_panic_
# relocs (nop_panic expected 2, tip now emits 4 without PREFER).
# PLATFORM: LINUX.
echo "linux_selfhost_pabi_sidecars: src/runtime_pipeline_abi_modlet_thin.x"
_modlet_ok=0
for xl in $_sidecar_xls; do
  rm -f "$OUT/modlet.o"
  if timeout 240 env XLANG_PREFER_ASM_O=1 "$xl" -c -backend asm \
    -o "$OUT/modlet.o" src/runtime_pipeline_abi_modlet_thin.x >/dev/null 2>&1 \
    && [ -s "$OUT/modlet.o" ]; then
    echo "linux_selfhost_pabi_sidecars: modlet OK via $xl (note743o)" >&2
    _modlet_ok=1
    break
  fi
  rm -f "$OUT/modlet.o"
done
if [ "$_modlet_ok" != "1" ]; then
  echo "linux_selfhost_pabi_sidecars: modlet tip failed" >&2
  exit 1
fi
if objdump -r "$OUT/modlet.o" | grep -q 'xlang_panic_'; then
  echo "linux_selfhost_pabi_sidecars: modlet panic reloc survived" >&2
  exit 1
fi

# nm from compiler/ — the object with the assign and spill bytes.
# note743r / note743f: tip peel may leave glue_try_index_*_rbx as U-only
# (no address). Require T/W; if missing, synthesize the historical egg
# face (ret -2), ld -r into the alias, then add _rest. No host-cc .c.
# PLATFORM: LINUX x86_64.
_base_addr=$(nm src/runtime_pipeline_abi.o | awk '$2 ~ /^[TtWw]$/ && $3=="glue_try_index_var_or_field_base_to_rbx_elf_c"{print $1; found=1} END{exit 0}')
_base_addr=$(printf '%s\n' "$_base_addr" | head -n1)
cp -f src/runtime_pipeline_abi.o "$OUT/pabi_alias.o"
if [ -z "$_base_addr" ]; then
  _egg_s="$OUT/index_base_rbx_egg_stub.s"
  _egg_o="$OUT/index_base_rbx_egg_stub.o"
  cat > "$_egg_s" <<'EOF'
.globl glue_try_index_var_or_field_base_to_rbx_elf_c
.type glue_try_index_var_or_field_base_to_rbx_elf_c, @function
glue_try_index_var_or_field_base_to_rbx_elf_c:
    movl $0xfffffffe, %eax
    ret
.size glue_try_index_var_or_field_base_to_rbx_elf_c, .-glue_try_index_var_or_field_base_to_rbx_elf_c
EOF
  if ! as --64 -o "$_egg_o" "$_egg_s"; then
    echo "linux_selfhost_pabi_sidecars: index base egg stub assemble failed" >&2
    exit 1
  fi
  if ! ld -r -o "$OUT/pabi_alias.o" src/runtime_pipeline_abi.o "$_egg_o"; then
    echo "linux_selfhost_pabi_sidecars: ld -r tip+egg stub failed" >&2
    exit 1
  fi
  _base_addr=$(nm "$OUT/pabi_alias.o" | awk '$2 ~ /^[TtWw]$/ && $3=="glue_try_index_var_or_field_base_to_rbx_elf_c"{print $1; found=1} END{exit 0}')
  _base_addr=$(printf '%s\n' "$_base_addr" | head -n1)
  if [ -z "$_base_addr" ]; then
    echo "linux_selfhost_pabi_sidecars: index base symbol missing after egg stub" >&2
    exit 1
  fi
  echo "linux_selfhost_pabi_sidecars: tip U-only index base; synthesized egg (note743r)" >&2
fi
objcopy --add-symbol "glue_try_index_var_or_field_base_to_rbx_elf_rest=.text:0x${_base_addr},global,function" "$OUT/pabi_alias.o"
# The source object is not modified. The alias is an extra name for the
# same text so the new strong body can call it.
if ! nm "$OUT/pabi_alias.o" | awk '$3=="glue_try_index_var_or_field_base_to_rbx_elf_c"{found=1} END{exit !found}'; then
  echo "linux_selfhost_pabi_sidecars: alias dropped the original symbol" >&2
  exit 1
fi
# w1493: point the C rest's calls to its local modlet copies at the
# global .x faces (one modlet table). See linux_selfhost_pabi_refresh_tip.sh.
if ! python3 scripts/elf_retarget_local_dup_relocs.py "$OUT/pabi_alias.o" \
  pipeline_asm_modlet_prepare_and_emit_elf_c \
  pipeline_asm_modlet_seed_nonzero_inits_elf_c \
  pipeline_asm_modlet_store_from_rax_elf_c \
  pipeline_asm_modlet_name_is_shared; then
  echo "linux_selfhost_pabi_sidecars: modlet retarget failed" >&2
  exit 1
fi

# w1012: true-pack ARRAY i8 (INDEX esz=1 + sext8 + assign tip + force_esz).
# Host-gcc twins first-wins over pabi. Shared C seeds (same as Darwin tip /
# Windows src/*_override.o). Do not PREFER into runtime_pipeline_abi.o.
# w2061: index-elem is three strong T from three .x. One gcc object
# defined all three names. Same-.o dual T of two link winners smashes
# i32. The _c body calls the peeler as an extern. g05_relink_env.sh
# rebuilds the same three every Linux relink. Do not gcc
# seeds/win_index_elem_byte_sz_override.c here. Darwin rebuilds the
# same three .x. w2064 compiles assign_index from its .x below.
# w2062: emit_index is two strong T from two .x. One gcc object defined
# both names. The elf body calls the arms export as an extern.
# g05_relink_env.sh rebuilds the same two every Linux relink. Darwin
# rebuilds the same two .x. Do not
# gcc seeds/emit_index_true_i8_override.c here.
# w2063: force_esz and elem_byte_sz are two strong T from two .x.
# One gcc object defined both names. Same-.o dual T smashes i32.
# g05_relink_env.sh rebuilds the same two every Linux relink. Darwin
# rebuilds the same two .x. Do not gcc seeds/force_esz_true_i8_override.c
# here. Do not PREFER
# runtime_pipeline_abi_fnptr_array_esz_thin.x. PLATFORM: LINUX.
echo "linux_selfhost_pabi_sidecars: w2061 index_elem three .x"
_ie_one() {
  local src="$1"
  local dst="$2"
  local sym="$3"
  local xl
  echo "linux_selfhost_pabi_sidecars: $src"
  for xl in $_sidecar_xls; do
    rm -f "$dst"
    if timeout 240 "$xl" -backend asm -c -o "$dst" "$src" >/dev/null 2>&1 \
      && [ -s "$dst" ] \
      && nm "$dst" 2>/dev/null | grep -E " T ${sym}\$" >/dev/null; then
      if nm "$dst" 2>/dev/null | grep -E 'xlang_panic_' >/dev/null; then
        rm -f "$dst"
        continue
      fi
      echo "linux_selfhost_pabi_sidecars: OK via $xl (note743o)" >&2
      return 0
    fi
    rm -f "$dst"
  done
  echo "linux_selfhost_pabi_sidecars: $src lacks strong $sym (all xl)" >&2
  exit 1
}
_ie_one src/pabi_index_elem_from_type_one.x \
  "$OUT/index_elem_from_type.o" \
  glue_index_elem_byte_sz_from_type_ref_c
_ie_one src/pabi_index_elem_byte_sz_one.x \
  "$OUT/index_elem_true_i8.o" \
  pipeline_asm_index_elem_byte_sz_c
_ie_one src/pabi_index_elem_wrap_one.x \
  "$OUT/index_elem_wrap.o" \
  pipeline_asm_index_elem_byte_sz
_ie_one src/pabi_emit_index_arms_one.x \
  "$OUT/emit_index_arms_true_i8.o" \
  glue_emit_index_load_arms_elf_c
_ie_one src/pabi_emit_index_elf_one.x \
  "$OUT/emit_index_elf_true_i8.o" \
  pipeline_asm_emit_index_elf_c
# w2064: one strong T. g05 rebuilds the same .x every Linux relink.
# Do not gcc seeds/assign_index_true_i8_override.c. Do not PREFER
# runtime_pipeline_abi_assign_index_thin.x. Darwin rebuilds the same .x.
# PLATFORM: LINUX.
_ie_one src/pabi_assign_index_one.x \
  "$OUT/assign_index_true_i8.o" \
  glue_emit_assign_index_elf_c
_ie_one src/pabi_force_esz_one.x \
  "$OUT/force_esz_true_i8.o" \
  glue_array_lit_force_esz_from_elem_type_c
_ie_one src/pabi_elem_byte_sz_one.x \
  "$OUT/array_lit_esz_true_i8.o" \
  pipeline_asm_array_lit_elem_byte_sz_c

# w1017: elem_const tip (DIV/MOD by zero → 0). First-wins over stale
# modlet folder when full modlet_thin T001. PLATFORM: LINUX.
echo "linux_selfhost_pabi_sidecars: w1017 elem_const tip"
_ec_ok=0
for xl in $_sidecar_xls; do
  rm -f "$OUT/elem_const.o"
  if timeout 240 env XLANG_PREFER_ASM_O=1 "$xl" -c -backend asm \
      -o "$OUT/elem_const.o" src/runtime_pipeline_abi_modlet_elem_const_thin.x >/dev/null 2>&1 \
      && [ -s "$OUT/elem_const.o" ]; then
    echo "linux_selfhost_pabi_sidecars: elem_const OK via $xl (note743o)" >&2
    _ec_ok=1
    break
  fi
  rm -f "$OUT/elem_const.o"
done
if [ "$_ec_ok" != "1" ]; then
  echo "linux_selfhost_pabi_sidecars: elem_const tip failed" >&2
  exit 1
fi
if objdump -r "$OUT/elem_const.o" | grep -q 'xlang_panic_'; then
  echo "linux_selfhost_pabi_sidecars: elem_const panic reloc" >&2
  exit 1
fi

: > "$OUT/READY"
echo "linux_selfhost_pabi_sidecars: OK $OUT"
