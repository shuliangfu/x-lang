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
if [ ! -x ./xlang ]; then
  echo "linux_selfhost_pabi_sidecars: ./xlang missing" >&2
  exit 1
fi

OUT=build_asm/selfhost_pabi
WORK="$(mktemp -d "${TMPDIR:-/tmp}/selfhost_pabi.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
rm -rf "$OUT"
mkdir -p "$OUT"

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
  echo "linux_selfhost_pabi_sidecars: $src"
  timeout 240 ./xlang -c -backend asm -o "$dst" "$src"
}

compile_one src/runtime_pipeline_abi_slot_bytes_thin.x "$WORK/slot.o"
compile_one src/runtime_pipeline_abi_fnptr_array_esz_thin.x "$WORK/esz.o"
compile_one src/runtime_pipeline_abi_asm_locals_thin.x "$WORK/loc.o"
compile_one src/runtime_pipeline_abi_fixed_array_copy_helpers_thin.x "$WORK/lea.o"
compile_one src/runtime_pipeline_abi_asm_expr_helpers_thin.x "$WORK/rec.o"
compile_one src/runtime_pipeline_abi_fixed_array_copy_thin.x "$WORK/two_raw.o"
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

weaken_keep "$WORK/slot.o" "$OUT/slot.o" pipe_local_slot_bytes_mod
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
# PLATFORM: LINUX.
compile_one src/runtime_pipeline_abi_modlet_thin.x "$WORK/modlet_raw.o"
python3 "$WORK/nop_panic.py" "$WORK/modlet_raw.o" "$OUT/modlet.o"
if objdump -r "$OUT/modlet.o" | grep -q 'xlang_panic_'; then
  echo "linux_selfhost_pabi_sidecars: modlet panic reloc survived" >&2
  exit 1
fi

# nm from compiler/ — the object with the assign and spill bytes.
_base_addr=$(nm src/runtime_pipeline_abi.o | awk '$3=="glue_try_index_var_or_field_base_to_rbx_elf_c"{print $1; exit}')
if [ -z "$_base_addr" ]; then
  echo "linux_selfhost_pabi_sidecars: index base symbol missing" >&2
  exit 1
fi
cp -f src/runtime_pipeline_abi.o "$OUT/pabi_alias.o"
objcopy --add-symbol "glue_try_index_var_or_field_base_to_rbx_elf_rest=.text:0x${_base_addr},global,function" "$OUT/pabi_alias.o"
# The source object is not modified. The alias is an extra name for the
# same text so the new strong body can call it.
if ! nm "$OUT/pabi_alias.o" | awk '$3=="glue_try_index_var_or_field_base_to_rbx_elf_c"{found=1} END{exit !found}'; then
  echo "linux_selfhost_pabi_sidecars: alias dropped the original symbol" >&2
  exit 1
fi

: > "$OUT/READY"
echo "linux_selfhost_pabi_sidecars: OK $OUT"
