// Linked ELF-ctx layout face for the 65536-label table.
//
// The source of the numbers is runtime_pipeline_abi_elf_ctx_thin.x
// (wave651 patches 16384→65536, wave652 labels 16384→65536). Those
// getters are file-private, and the thin is not linked: the inject
// path is a hard no-op. The linked copies are weak and still return
// the 16384 layout (num_labels at 4325380). pipeline_sizeof_elf_ctx
// already returns 53477424, the end of this 65536 layout, so the
// allocation is large enough. Readers call the getters; the 16384
// immediates live only inside those getters.
//
// This file is the strong global face of that same layout. It does
// not change pipe_elf_table_cap. That symbol stays 16384 and is the
// reloc inline/heap split, and the shndx sidecars are 65536 bytes
// (16384 i32 slots). add_label / append_patch therefore still call
// the existing shndx setters, which refuse an index past 16383.
// A later label reads back as .text. Resolve already forces .text
// when PGO is off and the two section indexes differ.
//
// g05_relink_env.sh compiles this on Linux only and links it ahead
// of pabi. Darwin and Windows stay on their current sizeof until
// that value is the same 53477424 end. Do not rebuild the pabi egg.
// PLATFORM: LINUX link. Layout numbers are the shared thin.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
export extern function pipe_elf_current_shndx(ctx: *u8): i32;
export extern function pipe_elf_label_at(ctx: *u8, i: i32): *u8;
export extern function pipe_elf_patch_at(ctx: *u8, i: i32): *u8;
export extern function pipe_elf_lab_off_name(): i32;
export extern function pipe_elf_lab_off_name_len(): i32;
export extern function pipe_elf_lab_off_offset(): i32;
export extern function pipe_elf_pat_off_rel32(): i32;
export extern function pipe_elf_pat_off_name(): i32;
export extern function pipe_elf_pat_off_name_len(): i32;
export extern function pipe_elf_pat_off_imm_bits(): i32;
export extern function pipe_elf_name_eq(a: *u8, a_len: i32, b: *u8, b_len: i32): i32;
export extern function pipe_elf_label_shndx_set(ctx_bytes: *u8, idx: i32, shndx: i32): void;
export extern function pipe_elf_patch_shndx_set(ctx_bytes: *u8, idx: i32, shndx: i32): void;

/**
 * Little-endian i32 load. Unsafe because the installed helper is extern.
 * @param base *u8 — object base; caller rejects null
 * @param off i32 — byte offset
 * @return i32 — loaded value
 * PLATFORM: LINUX — overlay calls the linked helper.
 */
function w1607_load(base: *u8, off: i32): i32 {
  unsafe { return pipe_load_i32_le(base, off); }
}

/**
 * Little-endian i32 store. Unsafe because the installed helper is extern.
 * @param base *u8 — object base; caller rejects null
 * @param off i32 — byte offset
 * @param v i32 — value to store
 * @return void
 * PLATFORM: LINUX — overlay calls the linked helper.
 */
function w1607_store(base: *u8, off: i32, v: i32): void {
  unsafe { pipe_store_i32_le(base, off, v); }
}

/**
 * Copy n bytes. Unsafe because memcpy is extern.
 * @param dst *u8 — destination
 * @param src *u8 — source
 * @param n usize — byte count
 * @return *u8 — dst
 * PLATFORM: LINUX.
 */
function w1607_memcpy(dst: *u8, src: *u8, n: usize): *u8 {
  unsafe { return memcpy(dst, src, n); }
}

/**
 * Label table capacity. wave652: 65536. Not pipe_elf_table_cap.
 * @return i32 — 65536
 * PLATFORM: LINUX — strong face of the thin's private cap.
 */
#[no_mangle]
export function pipe_elf_label_cap(): i32 { return 65536; }

/**
 * Patch table capacity. wave651: 65536. Not pipe_elf_table_cap.
 * @return i32 — 65536
 * PLATFORM: LINUX — strong face of the thin's private cap.
 */
#[no_mangle]
export function pipe_elf_patch_cap(): i32 { return 65536; }

/**
 * Byte offset of num_labels. 4 + 65536 * 264.
 * @return i32 — 17301508
 * PLATFORM: LINUX.
 */
#[no_mangle]
export function pipe_elf_off_num_labels(): i32 { return 17301508; }

/**
 * Byte offset of the patch array. Immediately after num_labels.
 * @return i32 — 17301512
 * PLATFORM: LINUX.
 */
#[no_mangle]
export function pipe_elf_off_patches(): i32 { return 17301512; }

/**
 * Byte offset of num_patches. After 65536 patch entries of 268 bytes.
 * @return i32 — 34865160
 * PLATFORM: LINUX.
 */
#[no_mangle]
export function pipe_elf_off_num_patches(): i32 { return 34865160; }

/**
 * Byte offset of the inline reloc array.
 * @return i32 — 34865164
 * PLATFORM: LINUX.
 */
#[no_mangle]
export function pipe_elf_off_relocs(): i32 { return 34865164; }

/**
 * Byte offset of inline reloc symbol names.
 * @return i32 — 34996236
 * PLATFORM: LINUX.
 */
#[no_mangle]
export function pipe_elf_off_reloc_sym_names(): i32 { return 34996236; }

/**
 * Byte offset of num_relocs.
 * @return i32 — 39190540
 * PLATFORM: LINUX.
 */
#[no_mangle]
export function pipe_elf_off_num_relocs(): i32 { return 39190540; }

/**
 * Byte offset of the symbol array.
 * @return i32 — 39190544
 * PLATFORM: LINUX.
 */
#[no_mangle]
export function pipe_elf_off_syms(): i32 { return 39190544; }

/**
 * Byte offset of num_syms.
 * @return i32 — 43581456
 * PLATFORM: LINUX.
 */
#[no_mangle]
export function pipe_elf_off_num_syms(): i32 { return 43581456; }

/**
 * Byte offset of the symbol-name pool length.
 * @return i32 — 43581460
 * PLATFORM: LINUX.
 */
#[no_mangle]
export function pipe_elf_off_sym_name_len(): i32 { return 43581460; }

/**
 * Byte offset of e_machine.
 * @return i32 — 43581464
 * PLATFORM: LINUX.
 */
#[no_mangle]
export function pipe_elf_off_e_machine(): i32 { return 43581464; }

/**
 * Byte offset of the default reloc type.
 * @return i32 — 43581468
 * PLATFORM: LINUX.
 */
#[no_mangle]
export function pipe_elf_off_reloc_type_r_pc32(): i32 { return 43581468; }

/**
 * Byte offset of the current frame size.
 * @return i32 — 43581472
 * PLATFORM: LINUX.
 */
#[no_mangle]
export function pipe_elf_off_current_frame_size(): i32 { return 43581472; }

/**
 * Byte offset of the Mach-O leading-underscore flag.
 * @return i32 — 43581476
 * PLATFORM: LINUX.
 */
#[no_mangle]
export function pipe_elf_off_macho_uscore(): i32 { return 43581476; }

/**
 * Byte offset of the hot-section code length.
 * @return i32 — 43581480
 * PLATFORM: LINUX.
 */
#[no_mangle]
export function pipe_elf_off_code_hot_len(): i32 { return 43581480; }

/**
 * Byte offset of the emit-hot flag.
 * @return i32 — 43581484
 * PLATFORM: LINUX.
 */
#[no_mangle]
export function pipe_elf_off_emit_hot(): i32 { return 43581484; }

/**
 * Byte size of the access header. Same number as code_data.
 * @return i32 — 43581488
 * PLATFORM: LINUX.
 */
#[no_mangle]
export function pipe_elf_sizeof_access(): i32 { return 43581488; }

/**
 * Byte offset of the .text code buffer.
 * @return i32 — 43581488
 * PLATFORM: LINUX.
 */
#[no_mangle]
export function pipe_elf_off_code_data(): i32 { return 43581488; }

/**
 * Byte offset of the hot code buffer. code_data + 8716288.
 * @return i32 — 52297776
 * PLATFORM: LINUX.
 */
#[no_mangle]
export function pipe_elf_off_code_hot_data(): i32 { return 52297776; }

/**
 * Byte offset of the symbol-name pool. code_hot_data + 1048576.
 * @return i32 — 53346352
 * PLATFORM: LINUX.
 */
#[no_mangle]
export function pipe_elf_off_sym_name_data(): i32 { return 53346352; }

/**
 * Add or update a local label. Same steps as the thin's body.
 * The full check is pipe_elf_label_cap (65536), not pipe_elf_table_cap.
 * Section index for an entry at or past 16383 is left to the existing
 * setter, whose sidecar holds 16384 i32 slots.
 * @param ctx_bytes *u8 — ELF context; null returns -1
 * @param name *u8 — label bytes; null returns -1
 * @param name_len i32 — byte count; negative returns -1; stored length ≤ 255
 * @param offset i32 — code offset of the label
 * @return i32 — 0 stored, -1 full or null
 * PLATFORM: LINUX — strong override of the weak 16384 body.
 */
#[no_mangle]
export function pipeline_elf_ctx_add_label(ctx_bytes: *u8, name: *u8, name_len: i32, offset: i32): i32 {
  if (ctx_bytes == 0 as *u8 || name == 0 as *u8 || name_len < 0) {
    return -1;
  }
  let shndx: i32 = 0;
  let nl: i32 = 0;
  let l: i32 = 0;
  let name_off: i32 = 0;
  let len_off: i32 = 0;
  let disp_off: i32 = 0;
  unsafe { shndx = pipe_elf_current_shndx(ctx_bytes); }
  nl = w1607_load(ctx_bytes, pipe_elf_off_num_labels());
  unsafe {
    name_off = pipe_elf_lab_off_name();
    len_off = pipe_elf_lab_off_name_len();
    disp_off = pipe_elf_lab_off_offset();
  }
  while (l < nl) {
    let lab: *u8 = 0 as *u8;
    let llen: i32 = 0;
    let eq: i32 = 0;
    unsafe { lab = pipe_elf_label_at(ctx_bytes, l); }
    llen = w1607_load(lab, len_off);
    unsafe { eq = pipe_elf_name_eq(lab + (name_off as usize), llen, name, name_len); }
    if (eq != 0) {
      w1607_store(lab, disp_off, offset);
      unsafe { pipe_elf_label_shndx_set(ctx_bytes, l, shndx); }
      return 0;
    }
    l = l + 1;
  }
  if (nl >= pipe_elf_label_cap()) {
    return -1;
  }
  let lab2: *u8 = 0 as *u8;
  let n: i32 = name_len;
  unsafe { lab2 = pipe_elf_label_at(ctx_bytes, nl); }
  // Name row is 256 bytes; keep one byte of headroom the same way the thin does.
  if (n > 255) {
    n = 255;
  }
  if (n < 0) {
    n = 0;
  }
  if (n > 0) {
    w1607_memcpy(lab2 + (name_off as usize), name, n as usize);
  }
  w1607_store(lab2, len_off, n);
  w1607_store(lab2, disp_off, offset);
  unsafe { pipe_elf_label_shndx_set(ctx_bytes, nl, shndx); }
  w1607_store(ctx_bytes, pipe_elf_off_num_labels(), nl + 1);
  return 0;
}

/**
 * Append one rel32/imm patch. Same steps as the thin's body.
 * The full check is pipe_elf_patch_cap (65536), not pipe_elf_table_cap.
 * @param ctx_bytes *u8 — ELF context; null returns -1
 * @param rel32_offset i32 — displacement site in the current section
 * @param name *u8 — target label bytes; null returns -1
 * @param name_len i32 — byte count; negative returns -1; stored length ≤ 255
 * @param imm_bits i32 — immediate width; 0 means resolve infers it
 * @return i32 — 0 stored, -1 full or null
 * PLATFORM: LINUX — strong override of the weak 16384 body.
 */
#[no_mangle]
export function pipeline_elf_ctx_append_patch(ctx_bytes: *u8, rel32_offset: i32, name: *u8, name_len: i32, imm_bits: i32): i32 {
  if (ctx_bytes == 0 as *u8 || name == 0 as *u8 || name_len < 0) {
    return -1;
  }
  let np: i32 = 0;
  let bits: i32 = imm_bits;
  let ent: *u8 = 0 as *u8;
  let n: i32 = name_len;
  let shndx: i32 = 0;
  let rel_off: i32 = 0;
  let name_off: i32 = 0;
  let len_off: i32 = 0;
  let bits_off: i32 = 0;
  np = w1607_load(ctx_bytes, pipe_elf_off_num_patches());
  if (np >= pipe_elf_patch_cap()) {
    return -1;
  }
  unsafe {
    ent = pipe_elf_patch_at(ctx_bytes, np);
    rel_off = pipe_elf_pat_off_rel32();
    name_off = pipe_elf_pat_off_name();
    len_off = pipe_elf_pat_off_name_len();
    bits_off = pipe_elf_pat_off_imm_bits();
  }
  w1607_store(ent, rel_off, rel32_offset);
  if (n > 255) {
    n = 255;
  }
  if (n < 0) {
    n = 0;
  }
  if (n > 0) {
    w1607_memcpy(ent + (name_off as usize), name, n as usize);
  }
  w1607_store(ent, len_off, n);
  w1607_store(ent, bits_off, bits);
  unsafe {
    shndx = pipe_elf_current_shndx(ctx_bytes);
    pipe_elf_patch_shndx_set(ctx_bytes, np, shndx);
  }
  w1607_store(ctx_bytes, pipe_elf_off_num_patches(), np + 1);
  return 0;
}
