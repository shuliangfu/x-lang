// Thin pure: wave312/368b/382 M2 — elf_ctx Cap residual C→.x (was wave273 C thin).
// ELF ctx accessors + write_o (+ label/reloc/PGO); excludes macho_write
// (owned by runtime_pipeline_abi_macho_write_thin — same as C thin).
// G.7: bodies match runtime_pipeline_abi.x wave273 leave (ELF portion).
// PRODUCT inject wave382 HARD BAN reinject both ends — keep prior overlay
// (MACOS PREFER / LINUX -E from w368b). Tip Darwin reinject BRANCH26;
// Ubuntu tip PREFER reinject SEGV (probe flaky) → stamp only.
// wave368: w312_* helpers via unsafe (T001).
// PLATFORM: SHARED · BAN reinject both ends.

export extern "C" function driver_diagnostic_asm_macho_missing_und_reloc(reloc_idx: i32): void;
export extern "C" function driver_diagnostic_asm_macho_empty_reloc(reloc_idx: i32): void;
export extern "C" function driver_diagnostic_asm_elf_unresolved_patch(name: *u8, name_len: i32): void;
export extern function codegen_out_buf_len(out: *u8): i32;
export extern function codegen_out_buf_set_len(out: *u8, n: i32): void;
export extern "C" function link_abi_getenv(name: *u8): *u8;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;


/**
 * LE i32 load via unsafe (T001). PLATFORM: SHARED.
 * wave368: wrap for PREFER_ASM pure-asm leave.
 */
function w312_load(base: *u8, off: i32): i32 {
  unsafe { return pipe_load_i32_le(base, off); }
}

/**
 * LE i32 store via unsafe (T001). PLATFORM: SHARED.
 */
function w312_store(base: *u8, off: i32, v: i32): void {
  unsafe { pipe_store_i32_le(base, off, v); }
}

/**
 * codegen_out_buf_len via unsafe (T001). PLATFORM: SHARED.
 */
function w312_out_len(out: *u8): i32 {
  unsafe { return codegen_out_buf_len(out); }
}

/**
 * codegen_out_buf_set_len via unsafe (T001). PLATFORM: SHARED.
 */
function w312_out_set_len(out: *u8, n: i32): void {
  unsafe { codegen_out_buf_set_len(out, n); }
}

/**
 * link_abi_getenv via unsafe (T001). PLATFORM: SHARED.
 */
function w312_getenv(name: *u8): *u8 {
  unsafe { return link_abi_getenv(name); }
}

/**
 * memcpy via unsafe (T001). PLATFORM: SHARED.
 */
function w312_memcpy(dst: *u8, src: *u8, n: usize): *u8 {
  unsafe { return memcpy(dst, src, n); }
}

/**
 * memset via unsafe (T001). PLATFORM: SHARED.
 */
function w312_memset(dst: *u8, c: i32, n: usize): *u8 {
  unsafe { return memset(dst, c, n); }
}

/**
 * driver_diagnostic_asm_macho_missing_und_reloc via unsafe (T001).
 * PLATFORM: SHARED.
 */
function w312_diag_macho_missing_und(reloc_idx: i32): void {
  unsafe { driver_diagnostic_asm_macho_missing_und_reloc(reloc_idx); }
}

/**
 * driver_diagnostic_asm_macho_empty_reloc via unsafe (T001).
 * PLATFORM: SHARED.
 */
function w312_diag_macho_empty(reloc_idx: i32): void {
  unsafe { driver_diagnostic_asm_macho_empty_reloc(reloc_idx); }
}

/**
 * driver_diagnostic_asm_elf_unresolved_patch via unsafe (T001).
 * PLATFORM: SHARED.
 */
function w312_diag_elf_unresolved(name: *u8, name_len: i32): void {
  unsafe { driver_diagnostic_asm_elf_unresolved_patch(name, name_len); }
}

function pipe_elf_table_cap(): i32 { return 16384; }
function pipe_elf_reloc_heap_cap(): i32 { return 16384; }
function pipe_elf_reloc_total_cap(): i32 { return 32768; }
function pipe_elf_code_buf_cap(): i32 { return 8716288; }
function pipe_elf_code_hot_cap(): i32 { return 1048576; }
function pipe_elf_shnx_text(): i32 { return 1; }
function pipe_elf_shnx_hot(): i32 { return 2; }
function pipe_elf_shnx_unlikely(): i32 { return 3; }
/**
 * F7: section index for the read-only data section (__DATA,__const on Mach-O).
 * Vtable static data with absolute pointer relocations lives here, separate
 * from __TEXT,__text which is pure_instructions and rejects such relocations.
 * PLATFORM: SHARED freestanding ELF leave.
 */
function pipe_elf_shnx_data(): i32 { return 4; }
function pipe_elf_undef_cap(): i32 { return 256; }
function pipe_elf_macho_undef_cap(): i32 { return 256; }
function pipe_elf_pgo_undef_cap(): i32 { return 32; }
function pipe_elf_codegen_out_cap(): i32 { return 9437184; }

// Entry sizes
function pipe_elf_label_esz(): i32 { return 264; }
function pipe_elf_patch_esz(): i32 { return 268; }
function pipe_elf_reloc_esz(): i32 { return 8; }
function pipe_elf_reloc_name_esz(): i32 { return 256; }
function pipe_elf_sym_esz(): i32 { return 268; }
function pipe_elf_reloc_heap_esz(): i32 { return 12; }

// Field offsets inside PipelineElfCtxAccess
function pipe_elf_off_code_len(): i32 { return 0; }
function pipe_elf_off_labels(): i32 { return 4; }
function pipe_elf_off_num_labels(): i32 { return 4325380; }
function pipe_elf_off_patches(): i32 { return 4325384; }
function pipe_elf_off_num_patches(): i32 { return 8716296; }
function pipe_elf_off_relocs(): i32 { return 8716300; }
function pipe_elf_off_reloc_sym_names(): i32 { return 8847372; }
function pipe_elf_off_num_relocs(): i32 { return 13041676; }
function pipe_elf_off_syms(): i32 { return 13041680; }
function pipe_elf_off_num_syms(): i32 { return 17432592; }
function pipe_elf_off_sym_name_len(): i32 { return 17432596; }
function pipe_elf_off_e_machine(): i32 { return 17432600; }
function pipe_elf_off_reloc_type_r_pc32(): i32 { return 17432604; }
function pipe_elf_off_current_frame_size(): i32 { return 17432608; }
function pipe_elf_off_macho_uscore(): i32 { return 17432612; }
function pipe_elf_off_code_hot_len(): i32 { return 17432616; }
function pipe_elf_off_emit_hot(): i32 { return 17432620; }
function pipe_elf_sizeof_access(): i32 { return 17432624; }
function pipe_elf_off_code_data(): i32 { return 17432624; }
function pipe_elf_off_code_hot_data(): i32 { return 26148912; }
function pipe_elf_off_sym_name_data(): i32 { return 27197488; }

// Label entry sub-offsets
function pipe_elf_lab_off_name(): i32 { return 0; }
function pipe_elf_lab_off_name_len(): i32 { return 256; }
function pipe_elf_lab_off_offset(): i32 { return 260; }
// Patch entry
function pipe_elf_pat_off_rel32(): i32 { return 0; }
function pipe_elf_pat_off_name(): i32 { return 4; }
function pipe_elf_pat_off_name_len(): i32 { return 260; }
function pipe_elf_pat_off_imm_bits(): i32 { return 264; }
// Reloc entry
function pipe_elf_rel_off_offset(): i32 { return 0; }
function pipe_elf_rel_off_name_len(): i32 { return 4; }
// Sym entry
function pipe_elf_sym_off_name(): i32 { return 0; }
function pipe_elf_sym_off_name_len(): i32 { return 256; }
function pipe_elf_sym_off_offset(): i32 { return 260; }
function pipe_elf_sym_off_shndx(): i32 { return 264; }
// Heap reloc entry
function pipe_elf_rh_off_offset(): i32 { return 0; }
function pipe_elf_rh_off_name_len(): i32 { return 4; }
function pipe_elf_rh_off_shndx(): i32 { return 8; }

// ---------------------------------------------------------------------------
// BSS sidecars (G.7 single process tables; bind owner on reset)
// ---------------------------------------------------------------------------
let g_pipe_elf_reloc_sidecar_owner: *u8 = 0 as *u8;
let g_pipe_elf_reloc_heap: u8[196608] = [];
// Cap 4.2.8: RELOC_HEAP_CAP(16384) × 256-byte name rows (was 128 → 2097152).
let g_pipe_elf_reloc_sym_heap: u8[4194304] = [];

let g_pipe_elf_shndx_sidecar_owner: *u8 = 0 as *u8;
let g_pipe_elf_label_shndx: u8[65536] = [];
let g_pipe_elf_patch_shndx: u8[65536] = [];
let g_pipe_elf_reloc_shndx: u8[65536] = [];

let g_pipe_elf_common_owner: *u8 = 0 as *u8;
let g_pipe_elf_sym_is_common: u8[16384] = [];
let g_pipe_elf_sym_common_size: u8[65536] = [];
let g_pipe_elf_sym_common_align: u8[65536] = [];

let g_pipe_elf_reloc_r_type: u8[65536] = [];
// default -1 per entry: init on reset via memset 0xff
let g_pipe_elf_reloc_r_pcrel: u8[16384] = [];

let g_pipe_elf_label_mod_scope_base: i32 = 0;
let g_pipe_elf_label_mod_scope_active: i32 = 0;

// Writer workspace (avoids huge pure stack frames; single-threaded compile)
let g_pipe_elf_ws_undef_names: u8[32768] = [];
let g_pipe_elf_ws_undef_lens: u8[1024] = [];
let g_pipe_elf_ws_und_src: u8[1024] = [];
let g_pipe_elf_ws_und_lens: u8[1024] = [];
let g_pipe_elf_ws_pgo_undef_names: u8[4096] = [];
let g_pipe_elf_ws_pgo_undef_lens: u8[256] = [];
let g_pipe_elf_ws_ehdr: u8[256] = [];
let g_pipe_elf_ws_shdr: u8[1280] = [];
let g_pipe_elf_ws_ent: u8[256] = [];
let g_pipe_elf_ws_seg: u8[152] = [];
let g_pipe_elf_ws_hdr32: u8[32] = [];
let g_pipe_elf_ws_lc: u8[48] = [];
let g_pipe_elf_ws_name: u8[256] = [];
let g_pipe_elf_ws_name2: u8[256] = [];
let g_pipe_elf_ws_rela: u8[24] = [];
/* F7: shstrtab is 63 bytes once .data + .rela.data are appended after the
 * historic 46-byte ".text.symtab.strtab.shstrtab.rela.text" blob.
 * PLATFORM: LINUX ELF writer (buffer shared with the Mach-O path unused). */
let g_pipe_elf_ws_shstr_std: u8[64] = [];
let g_pipe_elf_ws_shstr_pgo: u8[107] = [];
let g_pipe_elf_ws_shstr_ready: i32 = 0;
/* F7: Mach-O writer workspace for the second LC_SEGMENT_64 (__DATA,__const).
 * Single-threaded compile; reused per module. */
let g_pipe_elf_ws_seg2: u8[152] = [];
/* F7: data section buffer for vtable static data (read-only data with absolute
 * pointer relocations; cannot live in __TEXT,__text which is pure_instructions).
 * Single-threaded compile; reset per-module via pipeline_elf_ctx_reset_data. */
let g_pipe_elf_data_buf: u8[65536] = [];
let g_pipe_elf_data_len: i32 = 0;
let g_pipe_elf_data_owner: *u8 = 0 as *u8;
/* F7: shndx override (0 = no override; 4 = data section). When non-zero,
 * pipe_elf_current_shndx returns this value, so new relocs/syms/labels are
 * tagged as data-section. Set before emitting vtable statics; clear after.
 * Single-threaded compile; safe as a global mutable. */
let g_pipe_elf_shndx_override: i32 = 0;

/**
 * Byte equality for name rows.
 * @param a *u8 @param a_len i32 @param b *u8 @param b_len i32
 * @return i32 - 1 equal, 0 not
 * PLATFORM: SHARED freestanding ELF leave.
 */
function pipe_elf_name_eq(a: *u8, a_len: i32, b: *u8, b_len: i32): i32 {
  if (a_len != b_len) {
    return 0;
  }
  if (a_len < 0) {
    return 0;
  }
  if (a_len == 0) {
    return 1;
  }
  if (a == 0 as *u8 || b == 0 as *u8) {
    return 0;
  }
  let i: i32 = 0;
  while (i < a_len) {
    unsafe {
      if (a[i] != b[i]) {
        return 0;
      }
    }
    i = i + 1;
  }
  return 1;
}

/**
 * Store i32 LE into flat u8 BSS array at element index.
 */
function pipe_elf_bss_store_i32(blob: *u8, idx: i32, v: i32): void {
  if (blob == 0 as *u8 || idx < 0) {
    return;
  }
  w312_store(blob, idx * 4, v);
}

/**
 * Load i32 LE from flat u8 BSS array at element index.
 */
function pipe_elf_bss_load_i32(blob: *u8, idx: i32): i32 {
  if (blob == 0 as *u8 || idx < 0) {
    return 0;
  }
  return w312_load(blob, idx * 4);
}

/**
 * Pointer to label entry i within ctx.
 */
function pipe_elf_label_at(ctx: *u8, i: i32): *u8 {
  if (ctx == 0 as *u8 || i < 0) {
    return 0 as *u8;
  }
  let off: i64 = (pipe_elf_off_labels() as i64) + (i as i64) * (pipe_elf_label_esz() as i64);
  return ctx + (off as usize);
}

/**
 * Pointer to patch entry i.
 */
function pipe_elf_patch_at(ctx: *u8, i: i32): *u8 {
  if (ctx == 0 as *u8 || i < 0) {
    return 0 as *u8;
  }
  let off: i64 = (pipe_elf_off_patches() as i64) + (i as i64) * (pipe_elf_patch_esz() as i64);
  return ctx + (off as usize);
}

/**
 * Pointer to inline reloc entry i.
 */
function pipe_elf_reloc_at(ctx: *u8, i: i32): *u8 {
  if (ctx == 0 as *u8 || i < 0) {
    return 0 as *u8;
  }
  let off: i64 = (pipe_elf_off_relocs() as i64) + (i as i64) * (pipe_elf_reloc_esz() as i64);
  return ctx + (off as usize);
}

/**
 * Pointer to reloc_sym_names[i].bytes.
 */
function pipe_elf_reloc_name_row(ctx: *u8, i: i32): *u8 {
  if (ctx == 0 as *u8 || i < 0) {
    return 0 as *u8;
  }
  let off: i64 = (pipe_elf_off_reloc_sym_names() as i64) + (i as i64) * (pipe_elf_reloc_name_esz() as i64);
  return ctx + (off as usize);
}

/**
 * Pointer to sym entry i.
 */
function pipe_elf_sym_at(ctx: *u8, i: i32): *u8 {
  if (ctx == 0 as *u8 || i < 0) {
    return 0 as *u8;
  }
  let off: i64 = (pipe_elf_off_syms() as i64) + (i as i64) * (pipe_elf_sym_esz() as i64);
  return ctx + (off as usize);
}

/**
 * Heap reloc entry base for heap index hi.
 */
function pipe_elf_reloc_heap_at(hi: i32): *u8 {
  if (hi < 0 || hi >= pipe_elf_reloc_heap_cap()) {
    return 0 as *u8;
  }
  let off: i64 = (hi as i64) * (pipe_elf_reloc_heap_esz() as i64);
  return &g_pipe_elf_reloc_heap[0] + (off as usize);
}

/**
 * Heap reloc sym name row for heap index hi.
 */
function pipe_elf_reloc_sym_heap_at(hi: i32): *u8 {
  if (hi < 0 || hi >= pipe_elf_reloc_heap_cap()) {
    return 0 as *u8;
  }
  // Cap 4.2.8: row stride 256 (was wave580 128).
  let off: i64 = (hi as i64) * 256;
  return &g_pipe_elf_reloc_sym_heap[0] + (off as usize);
}

/**
 * XLANG_WPO_PGO_HOT=1 enables .text.hot dual-section emit.
 * @return i32 - 1 enabled, 0 off
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_pgo_hot_enabled(): i32 {
  let e: *u8 = 0 as *u8;
  unsafe {
    e = w312_getenv("XLANG_WPO_PGO_HOT");
  }
  if (e == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (e[0] == 0) {
      return 0;
    }
    if (e[0] == 48) {
      if (e[1] == 0 || e[1] == 10) {
        return 0;
      }
    }
  }
  return 1;
}

/**
 * Set current function emit target section (hot vs cold).
 * @param ctx_bytes *u8 - ElfCodegenCtx*
 * @param hot i32 - non-zero => .text.hot
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_set_emit_hot(ctx_bytes: *u8, hot: i32): void {
  if (ctx_bytes == 0 as *u8) {
    return;
  }
  let v: i32 = 0;
  if (hot != 0) {
    v = 1;
  }
  w312_store(ctx_bytes, pipe_elf_off_emit_hot(), v);
}

/**
 * .text + .text.hot encoded byte sum (empty __text reject uses this).
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_total_code_len(ctx_bytes: *u8): i32 {
  if (ctx_bytes == 0 as *u8) {
    return 0;
  }
  return w312_load(ctx_bytes, pipe_elf_off_code_len()) + w312_load(ctx_bytes, pipe_elf_off_code_hot_len());
}

/**
 * Current emit section encoded length (x86 call patch rel32_at relative to this).
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_emit_code_len(ctx_bytes: *u8): i32 {
  if (ctx_bytes == 0 as *u8) {
    return 0;
  }
  if (pipeline_elf_pgo_hot_enabled() != 0 && w312_load(ctx_bytes, pipe_elf_off_emit_hot()) != 0) {
    return w312_load(ctx_bytes, pipe_elf_off_code_hot_len());
  }
  return w312_load(ctx_bytes, pipe_elf_off_code_len());
}

/**
 * F7: Reset the data section buffer at module start.
 * Must be called once per module BEFORE emitting any vtable statics.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_reset_data(ctx_bytes: *u8): void {
  g_pipe_elf_data_len = 0;
  g_pipe_elf_data_owner = ctx_bytes;
}

/**
 * F7: Current data section length (bytes already emitted to data buf).
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_emit_data_len(ctx_bytes: *u8): i32 {
  if (ctx_bytes == 0 as *u8) {
    return 0;
  }
  return g_pipe_elf_data_len;
}

/**
 * F7: Pointer to data section buffer start.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_data_data_ptr(ctx_bytes: *u8): *u8 {
  if (ctx_bytes == 0 as *u8) {
    return 0 as *u8;
  }
  return &g_pipe_elf_data_buf[0];
}

/**
 * F7: Append 4 bytes (little-endian u32) to the data section buffer.
 * Returns 0 ok, -1 overflow/null.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_append_data_u32_le(ctx_bytes: *u8, word: u32): i32 {
  if (ctx_bytes == 0 as *u8) {
    return -1;
  }
  if (g_pipe_elf_data_len < 0) {
    g_pipe_elf_data_len = 0;
  }
  if (g_pipe_elf_data_len + 4 > 65536) {
    return -1;
  }
  let off: i32 = g_pipe_elf_data_len;
  unsafe {
    g_pipe_elf_data_buf[off] = ((word & 255) as u32) as u8;
    g_pipe_elf_data_buf[off + 1] = (((word / 256) & 255) as u32) as u8;
    g_pipe_elf_data_buf[off + 2] = (((word / 65536) & 255) as u32) as u8;
    g_pipe_elf_data_buf[off + 3] = (((word / 16777216) & 255) as u32) as u8;
  }
  g_pipe_elf_data_len = off + 4;
  return 0;
}

/**
 * F7: Append `n` zero bytes to the data section buffer (reserve + clear).
 * Used by modlet prepare to place a .data cell before poking ARRAY_LIT bytes.
 * @param ctx_bytes *u8 — ElfCodegenCtx*
 * @param n i32 — byte count; n<=0 is a no-op success
 * @return i32 — 0 ok; -1 overflow/null
 * PLATFORM: SHARED freestanding · ELF .data + Mach-O __DATA,__const.
 */
#[no_mangle]
export function pipeline_elf_ctx_append_data_zeros(ctx_bytes: *u8, n: i32): i32 {
  if (ctx_bytes == 0 as *u8) {
    return 0 - 1;
  }
  if (n <= 0) {
    return 0;
  }
  if (g_pipe_elf_data_len < 0) {
    g_pipe_elf_data_len = 0;
  }
  if (g_pipe_elf_data_len + n > 65536) {
    return 0 - 1;
  }
  let off: i32 = g_pipe_elf_data_len;
  let i: i32 = 0;
  while (i < n) {
    unsafe {
      g_pipe_elf_data_buf[off + i] = 0 as u8;
    }
    i = i + 1;
  }
  g_pipe_elf_data_len = off + n;
  return 0;
}

/**
 * F7: Poke one byte into an already-reserved data-section offset.
 * @param ctx_bytes *u8 — ElfCodegenCtx*
 * @param off i32 — absolute offset within g_pipe_elf_data_buf
 * @param b i32 — byte value (low 8 bits)
 * @return i32 — 0 ok; -1 OOB/null
 * PLATFORM: SHARED freestanding · ELF .data + Mach-O __DATA,__const.
 */
#[no_mangle]
export function pipeline_elf_ctx_data_poke_u8(ctx_bytes: *u8, off: i32, b: i32): i32 {
  if (ctx_bytes == 0 as *u8 || off < 0 || off >= g_pipe_elf_data_len) {
    return 0 - 1;
  }
  unsafe {
    g_pipe_elf_data_buf[off] = (b & 255) as u8;
  }
  return 0;
}

/**
 * F7: Set/clear shndx override. When set to 4 (data section), subsequent
 * relocs/syms/labels are tagged as data-section. Set to 0 to restore default
 * (text section). Single-threaded compile; safe as a global mutable.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_set_shndx_override(ctx_bytes: *u8, shndx: i32): void {
  g_pipe_elf_shndx_override = shndx;
}

/**
 * Current emit ELF section index.
 * F7: respects the shndx override (when non-zero, returns it so new
 * relocs/syms/labels are tagged as data-section).
 */
function pipe_elf_current_shndx(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return pipe_elf_shnx_text();
  }
  if (g_pipe_elf_shndx_override != 0) {
    return g_pipe_elf_shndx_override;
  }
  if (pipeline_elf_pgo_hot_enabled() != 0) {
    if (w312_load(ctx, pipe_elf_off_emit_hot()) != 0) {
      return pipe_elf_shnx_hot();
    }
    return pipe_elf_shnx_unlikely();
  }
  return pipe_elf_shnx_text();
}

/**
 * Code buffer pointer for section index.
 */
function pipe_elf_code_buf(ctx_bytes: *u8, shndx: i32): *u8 {
  if (ctx_bytes == 0 as *u8) {
    return 0 as *u8;
  }
  if (shndx == pipe_elf_shnx_hot()) {
    return ctx_bytes + (pipe_elf_off_code_hot_data() as usize);
  }
  return ctx_bytes + (pipe_elf_off_code_data() as usize);
}

/**
 * Section encoded length by shndx.
 */
function pipe_elf_section_len(ctx: *u8, shndx: i32): i32 {
  if (ctx == 0 as *u8) {
    return 0;
  }
  if (shndx == pipe_elf_shnx_hot()) {
    return w312_load(ctx, pipe_elf_off_code_hot_len());
  }
  return w312_load(ctx, pipe_elf_off_code_len());
}

/**
 * Append machine code bytes into current emit section.
 * @return i32 - 0 ok, -1 full/null
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_append_bytes(ctx_bytes: *u8, ptr: *u8, n: i32): i32 {
  if (ctx_bytes == 0 as *u8 || ptr == 0 as *u8 || n < 0) {
    return -1;
  }
  let buf: *u8 = 0 as *u8;
  let len_off: i32 = pipe_elf_off_code_len();
  let cap: i32 = pipe_elf_code_buf_cap();
  if (pipeline_elf_pgo_hot_enabled() != 0 && w312_load(ctx_bytes, pipe_elf_off_emit_hot()) != 0) {
    buf = ctx_bytes + (pipe_elf_off_code_hot_data() as usize);
    len_off = pipe_elf_off_code_hot_len();
    cap = pipe_elf_code_hot_cap();
  } else {
    buf = ctx_bytes + (pipe_elf_off_code_data() as usize);
  }
  let cur: i32 = w312_load(ctx_bytes, len_off);
  if (cur + n > cap) {
    return -1;
  }
  let i: i32 = 0;
  while (i < n) {
    unsafe {
      buf[cur + i] = ptr[i];
    }
    i = i + 1;
  }
  w312_store(ctx_bytes, len_off, cur + n);
  return 0;
}

/**
 * Reset COMMON object sidecar for this ctx owner.
 */
function pipe_elf_common_sidecar_reset(ctx_bytes: *u8): void {
  g_pipe_elf_common_owner = ctx_bytes;
  unsafe {
    w312_memset(&g_pipe_elf_sym_is_common[0], 0, 16384 as usize);
    w312_memset(&g_pipe_elf_sym_common_size[0], 0, 65536 as usize);
    w312_memset(&g_pipe_elf_sym_common_align[0], 0, 65536 as usize);
  }
}

/**
 * Default reloc section when sidecar unset.
 */
function pipe_elf_default_reloc_shndx(): i32 {
  if (pipeline_elf_pgo_hot_enabled() != 0) {
    return pipe_elf_shnx_unlikely();
  }
  return pipe_elf_shnx_text();
}

/**
 * Reset label/patch/reloc shndx sidecars.
 */
function pipe_elf_shndx_sidecar_reset(ctx_bytes: *u8): void {
  g_pipe_elf_shndx_sidecar_owner = ctx_bytes;
  unsafe {
    w312_memset(&g_pipe_elf_label_shndx[0], 0, 65536 as usize);
    w312_memset(&g_pipe_elf_patch_shndx[0], 0, 65536 as usize);
    w312_memset(&g_pipe_elf_reloc_shndx[0], 0, 65536 as usize);
  }
}

function pipe_elf_label_shndx_at(ctx_bytes: *u8, idx: i32): i32 {
  if (ctx_bytes == 0 as *u8 || idx < 0 || idx >= pipe_elf_table_cap()) {
    return pipe_elf_shnx_text();
  }
  if (g_pipe_elf_shndx_sidecar_owner != ctx_bytes || pipe_elf_bss_load_i32(&g_pipe_elf_label_shndx[0], idx) == 0) {
    return pipe_elf_default_reloc_shndx();
  }
  return pipe_elf_bss_load_i32(&g_pipe_elf_label_shndx[0], idx);
}

function pipe_elf_label_shndx_set(ctx_bytes: *u8, idx: i32, shndx: i32): void {
  if (ctx_bytes == 0 as *u8 || idx < 0 || idx >= pipe_elf_table_cap()) {
    return;
  }
  g_pipe_elf_shndx_sidecar_owner = ctx_bytes;
  pipe_elf_bss_store_i32(&g_pipe_elf_label_shndx[0], idx, shndx);
}

function pipe_elf_patch_shndx_at(ctx_bytes: *u8, idx: i32): i32 {
  if (ctx_bytes == 0 as *u8 || idx < 0 || idx >= pipe_elf_table_cap()) {
    return pipe_elf_shnx_text();
  }
  if (g_pipe_elf_shndx_sidecar_owner != ctx_bytes || pipe_elf_bss_load_i32(&g_pipe_elf_patch_shndx[0], idx) == 0) {
    return pipe_elf_default_reloc_shndx();
  }
  return pipe_elf_bss_load_i32(&g_pipe_elf_patch_shndx[0], idx);
}

function pipe_elf_patch_shndx_set(ctx_bytes: *u8, idx: i32, shndx: i32): void {
  if (ctx_bytes == 0 as *u8 || idx < 0 || idx >= pipe_elf_table_cap()) {
    return;
  }
  g_pipe_elf_shndx_sidecar_owner = ctx_bytes;
  pipe_elf_bss_store_i32(&g_pipe_elf_patch_shndx[0], idx, shndx);
}

function pipe_elf_reloc_shndx_set(ctx_bytes: *u8, idx: i32, shndx: i32): void {
  if (ctx_bytes == 0 as *u8 || idx < 0) {
    return;
  }
  if (idx < pipe_elf_table_cap()) {
    g_pipe_elf_shndx_sidecar_owner = ctx_bytes;
    pipe_elf_bss_store_i32(&g_pipe_elf_reloc_shndx[0], idx, shndx);
    return;
  }
  if (g_pipe_elf_reloc_sidecar_owner != ctx_bytes) {
    pipeline_elf_ctx_reloc_sidecar_reset(ctx_bytes);
  }
  let hi: i32 = idx - pipe_elf_table_cap();
  let h: *u8 = pipe_elf_reloc_heap_at(hi);
  if (h != 0 as *u8) {
    w312_store(h, pipe_elf_rh_off_shndx(), shndx);
  }
}

/**
 * Bind reloc sidecar owner; clear typed reloc rows; reset shndx sidecars.
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_reloc_sidecar_reset(ctx_bytes: *u8): void {
  g_pipe_elf_reloc_sidecar_owner = ctx_bytes;
  pipe_elf_shndx_sidecar_reset(ctx_bytes);
  unsafe {
    w312_memset(&g_pipe_elf_reloc_r_type[0], 0, 65536 as usize);
    w312_memset(&g_pipe_elf_reloc_r_pcrel[0], 255, 16384 as usize);
  }
}

/**
 * Read reloc[idx].offset (inline or heap).
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_reloc_offset_at(ctx_bytes: *u8, idx: i32): i32 {
  if (ctx_bytes == 0 as *u8 || idx < 0) {
    return 0;
  }
  let nr: i32 = w312_load(ctx_bytes, pipe_elf_off_num_relocs());
  if (idx >= nr) {
    return 0;
  }
  if (idx < pipe_elf_table_cap()) {
    let r: *u8 = pipe_elf_reloc_at(ctx_bytes, idx);
    return w312_load(r, pipe_elf_rel_off_offset());
  }
  if (g_pipe_elf_reloc_sidecar_owner != ctx_bytes) {
    return 0;
  }
  let hi: i32 = idx - pipe_elf_table_cap();
  let h: *u8 = pipe_elf_reloc_heap_at(hi);
  if (h == 0 as *u8) {
    return 0;
  }
  return w312_load(h, pipe_elf_rh_off_offset());
}

/**
 * Read reloc target section index.
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_reloc_shndx_at(ctx_bytes: *u8, idx: i32): i32 {
  if (ctx_bytes == 0 as *u8 || idx < 0) {
    return 1;
  }
  let nr: i32 = w312_load(ctx_bytes, pipe_elf_off_num_relocs());
  if (idx >= nr) {
    return pipe_elf_shnx_text();
  }
  if (idx < pipe_elf_table_cap()) {
    if (g_pipe_elf_shndx_sidecar_owner == ctx_bytes && pipe_elf_bss_load_i32(&g_pipe_elf_reloc_shndx[0], idx) != 0) {
      return pipe_elf_bss_load_i32(&g_pipe_elf_reloc_shndx[0], idx);
    }
    return pipe_elf_default_reloc_shndx();
  }
  if (g_pipe_elf_reloc_sidecar_owner != ctx_bytes) {
    return pipe_elf_shnx_text();
  }
  let hi: i32 = idx - pipe_elf_table_cap();
  let h: *u8 = pipe_elf_reloc_heap_at(hi);
  if (h == 0 as *u8) {
    return pipe_elf_shnx_text();
  }
  let sh: i32 = w312_load(h, pipe_elf_rh_off_shndx());
  if (sh != 0) {
    return sh;
  }
  return pipe_elf_default_reloc_shndx();
}

/**
 * Read export symbol st_shndx.
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_sym_shndx_at(ctx_bytes: *u8, idx: i32): i32 {
  if (ctx_bytes == 0 as *u8 || idx < 0) {
    return 1;
  }
  let ns: i32 = w312_load(ctx_bytes, pipe_elf_off_num_syms());
  if (idx >= ns) {
    return pipe_elf_shnx_text();
  }
  let s: *u8 = pipe_elf_sym_at(ctx_bytes, idx);
  let sh: i32 = w312_load(s, pipe_elf_sym_off_shndx());
  if (sh != 0) {
    return sh;
  }
  if (pipeline_elf_pgo_hot_enabled() != 0) {
    return pipe_elf_shnx_unlikely();
  }
  return pipe_elf_shnx_text();
}

/**
 * .text machine-code buffer pointer (writers must use this, not X code_data[]).
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_code_data_ptr(ctx_bytes: *u8): *u8 {
  if (ctx_bytes == 0 as *u8) {
    return 0 as *u8;
  }
  return pipe_elf_code_buf(ctx_bytes, pipe_elf_shnx_text());
}

/**
 * Write reloc[idx].offset.
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_reloc_offset_set(ctx_bytes: *u8, idx: i32, offset: i32): void {
  if (ctx_bytes == 0 as *u8 || idx < 0) {
    return;
  }
  let nr: i32 = w312_load(ctx_bytes, pipe_elf_off_num_relocs());
  if (idx >= nr) {
    return;
  }
  if (idx < pipe_elf_table_cap()) {
    let r: *u8 = pipe_elf_reloc_at(ctx_bytes, idx);
    w312_store(r, pipe_elf_rel_off_offset(), offset);
    return;
  }
  if (g_pipe_elf_reloc_sidecar_owner != ctx_bytes) {
    return;
  }
  let hi: i32 = idx - pipe_elf_table_cap();
  let h: *u8 = pipe_elf_reloc_heap_at(hi);
  if (h != 0 as *u8) {
    w312_store(h, pipe_elf_rh_off_offset(), offset);
  }
}

/**
 * Reset multi-module label scope base (elf_ctx_reset).
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_label_mod_scope_reset(): void {
  g_pipe_elf_label_mod_scope_base = 0;
}

/**
 * Allocate next module label scope base (+256 slots).
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_label_mod_scope_next_module(): i32 {
  let base: i32 = g_pipe_elf_label_mod_scope_base;
  g_pipe_elf_label_mod_scope_base = g_pipe_elf_label_mod_scope_base + 256;
  return base;
}

/**
 * Begin module: bump active label scope (avoid .L_0 collisions across modules).
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_label_mod_scope_begin_module(): void {
  g_pipe_elf_label_mod_scope_active = pipeline_elf_label_mod_scope_next_module();
}

/**
 * Active module ELF local-label scope.
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_label_mod_scope_active(): i32 {
  return g_pipe_elf_label_mod_scope_active;
}


/**
 * Add or update a local label at offset in current emit section.
 * @return i32 - 0 ok, -1 full/null
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_add_label(ctx_bytes: *u8, name: *u8, name_len: i32, offset: i32): i32 {
  if (ctx_bytes == 0 as *u8 || name == 0 as *u8 || name_len < 0) {
    return -1;
  }
  let shndx: i32 = pipe_elf_current_shndx(ctx_bytes);
  let nl: i32 = w312_load(ctx_bytes, pipe_elf_off_num_labels());
  let l: i32 = 0;
  while (l < nl) {
    let lab: *u8 = pipe_elf_label_at(ctx_bytes, l);
    let llen: i32 = w312_load(lab, pipe_elf_lab_off_name_len());
    if (pipe_elf_name_eq(lab + (pipe_elf_lab_off_name() as usize), llen, name, name_len) != 0) {
      w312_store(lab, pipe_elf_lab_off_offset(), offset);
      pipe_elf_label_shndx_set(ctx_bytes, l, shndx);
      return 0;
    }
    l = l + 1;
  }
  if (nl >= pipe_elf_table_cap()) {
    return -1;
  }
  let li: i32 = nl;
  let lab2: *u8 = pipe_elf_label_at(ctx_bytes, li);
  let n: i32 = name_len;
  // Cap 4.2.8: labels.name[256] content ≤255 (was wave580 128 → asm -o long-name CG002).
  if (n > 255) {
    n = 255;
  }
  if (n < 0) {
    n = 0;
  }
  if (n > 0) {
    unsafe {
      w312_memcpy(lab2 + (pipe_elf_lab_off_name() as usize), name, n as usize);
    }
  }
  w312_store(lab2, pipe_elf_lab_off_name_len(), n);
  w312_store(lab2, pipe_elf_lab_off_offset(), offset);
  pipe_elf_label_shndx_set(ctx_bytes, li, shndx);
  w312_store(ctx_bytes, pipe_elf_off_num_labels(), nl + 1);
  return 0;
}

/**
 * Ensure forward-jump placeholder label (offset=-1) exists.
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_ensure_label(ctx_bytes: *u8, name: *u8, name_len: i32): i32 {
  if (ctx_bytes == 0 as *u8 || name == 0 as *u8 || name_len < 0) {
    return -1;
  }
  let nl: i32 = w312_load(ctx_bytes, pipe_elf_off_num_labels());
  let l: i32 = 0;
  while (l < nl) {
    let lab: *u8 = pipe_elf_label_at(ctx_bytes, l);
    let llen: i32 = w312_load(lab, pipe_elf_lab_off_name_len());
    if (pipe_elf_name_eq(lab + (pipe_elf_lab_off_name() as usize), llen, name, name_len) != 0) {
      return 0;
    }
    l = l + 1;
  }
  return pipeline_elf_ctx_add_label(ctx_bytes, name, name_len, -1);
}

/**
 * Pad current emit section to 4-byte alignment (Mach-O/ELF function entry).
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_pad_code_to_4(ctx_bytes: *u8): i32 {
  if (ctx_bytes == 0 as *u8) {
    return -1;
  }
  let pad: u8[1] = [0];
  while ((pipeline_elf_ctx_emit_code_len(ctx_bytes) % 4) != 0) {
    if (pipeline_elf_ctx_append_bytes(ctx_bytes, &pad[0], 1) != 0) {
      return -1;
    }
  }
  return 0;
}

/**
 * Record export symbol; name bytes go into sym_name_data pool (cap 131072).
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_add_sym(ctx_bytes: *u8, name: *u8, name_len: i32, offset: i32): i32 {
  if (ctx_bytes == 0 as *u8 || name == 0 as *u8 || name_len < 0) {
    return -1;
  }
  let ns: i32 = w312_load(ctx_bytes, pipe_elf_off_num_syms());
  if (ns >= pipe_elf_table_cap()) {
    return -1;
  }
  if (g_pipe_elf_common_owner != ctx_bytes) {
    pipe_elf_common_sidecar_reset(ctx_bytes);
  }
  let copy_len: i32 = name_len;
  // Cap 4.2.8: sym name pool holds '_' + ≤255 AST content (was wave580 128).
  if (copy_len > 256) {
    copy_len = 256;
  }
  if (copy_len < 0) {
    copy_len = 0;
  }
  let snl: i32 = w312_load(ctx_bytes, pipe_elf_off_sym_name_len());
  if (snl + copy_len > 131072) {
    return -1;
  }
  let sym_pool: *u8 = ctx_bytes + (pipe_elf_off_sym_name_data() as usize);
  let k: i32 = 0;
  while (k < copy_len) {
    unsafe {
      sym_pool[snl + k] = name[k];
    }
    k = k + 1;
  }
  w312_store(ctx_bytes, pipe_elf_off_sym_name_len(), snl + copy_len);
  let se: *u8 = pipe_elf_sym_at(ctx_bytes, ns);
  w312_store(se, pipe_elf_sym_off_name_len(), copy_len);
  w312_store(se, pipe_elf_sym_off_offset(), offset);
  let shndx: i32 = pipe_elf_shnx_text();
  if (g_pipe_elf_shndx_override != 0) {
    shndx = g_pipe_elf_shndx_override;
  } else if (pipeline_elf_pgo_hot_enabled() != 0 && w312_load(ctx_bytes, pipe_elf_off_emit_hot()) != 0) {
    shndx = pipe_elf_shnx_hot();
  } else if (pipeline_elf_pgo_hot_enabled() != 0) {
    shndx = pipe_elf_shnx_unlikely();
  }
  w312_store(se, pipe_elf_sym_off_shndx(), shndx);
  unsafe {
    g_pipe_elf_sym_is_common[ns] = 0;
  }
  w312_store(ctx_bytes, pipe_elf_off_num_syms(), ns + 1);
  return 0;
}

/**
 * Add SHN_COMMON object symbol (linker BSS, writable). Used by modlet mutable lets.
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_add_common_sym(ctx_bytes: *u8, name: *u8, name_len: i32, sym_size: i32, sym_align: i32): i32 {
  if (ctx_bytes == 0 as *u8 || name == 0 as *u8 || name_len <= 0 || sym_size <= 0) {
    return -1;
  }
  let al: i32 = sym_align;
  if (al <= 0) {
    al = 8;
  }
  if (g_pipe_elf_common_owner != ctx_bytes) {
    pipe_elf_common_sidecar_reset(ctx_bytes);
  }
  if (pipeline_elf_ctx_add_sym(ctx_bytes, name, name_len, sym_size) != 0) {
    return -1;
  }
  let si: i32 = w312_load(ctx_bytes, pipe_elf_off_num_syms()) - 1;
  if (si < 0 || si >= pipe_elf_table_cap()) {
    return -1;
  }
  unsafe {
    g_pipe_elf_sym_is_common[si] = 1;
  }
  pipe_elf_bss_store_i32(&g_pipe_elf_sym_common_size[0], si, sym_size);
  pipe_elf_bss_store_i32(&g_pipe_elf_sym_common_align[0], si, al);
  let se: *u8 = pipe_elf_sym_at(ctx_bytes, si);
  w312_store(se, pipe_elf_sym_off_shndx(), 65522);
  return 0;
}

/**
 * Query whether sym[s] is SHN_COMMON (linker BSS / Mach-O tentative).
 * G.7 single authority with add_common_sym / g_pipe_elf_* sidecar.
 * macho_write_thin.c MUST call this — its private static sidecars stay empty
 * and previously wrote COMMON as N_SECT in __TEXT (file-level let → _Lxml
 * mid-function; Darwin ld -r BRANCH26).
 * @param ctx_bytes *u8 - ElfCodegenCtx*
 * @param s i32 - symbol index
 * @return i32 - 1 if common for this ctx; 0 otherwise
 * PLATFORM: SHARED freestanding · MACOS writer co-path.
 */
#[no_mangle]
export function pipeline_elf_ctx_sym_is_common_at(ctx_bytes: *u8, s: i32): i32 {
  if (ctx_bytes == 0 as *u8 || s < 0 || s >= pipe_elf_table_cap()) {
    return 0;
  }
  if (g_pipe_elf_common_owner != ctx_bytes) {
    return 0;
  }
  unsafe {
    if (g_pipe_elf_sym_is_common[s] != 0) {
      return 1;
    }
  }
  return 0;
}

/**
 * COMMON symbol size (bytes) for Mach-O n_value / ELF st_size.
 * @param ctx_bytes *u8 - ElfCodegenCtx*
 * @param s i32 - symbol index
 * @return i32 - size; 0 if not common / OOB
 * PLATFORM: SHARED freestanding · MACOS writer co-path.
 */
#[no_mangle]
export function pipeline_elf_ctx_sym_common_size_at(ctx_bytes: *u8, s: i32): i32 {
  if (pipeline_elf_ctx_sym_is_common_at(ctx_bytes, s) == 0) {
    return 0;
  }
  return pipe_elf_bss_load_i32(&g_pipe_elf_sym_common_size[0], s);
}

/**
 * COMMON symbol align (bytes) for Mach-O n_desc GET_COMM_ALIGN.
 * @param ctx_bytes *u8 - ElfCodegenCtx*
 * @param s i32 - symbol index
 * @return i32 - align; 0 if not common / OOB
 * PLATFORM: SHARED freestanding · MACOS writer co-path.
 */
#[no_mangle]
export function pipeline_elf_ctx_sym_common_align_at(ctx_bytes: *u8, s: i32): i32 {
  if (pipeline_elf_ctx_sym_is_common_at(ctx_bytes, s) == 0) {
    return 0;
  }
  return pipe_elf_bss_load_i32(&g_pipe_elf_sym_common_align[0], s);
}

/**
 * Reloc r_type sidecar (0 = writer default BRANCH26; 3=PAGE21; 4=PAGEOFF12;
 * 200=absolute64 sentinel). G.7: macho_write_thin must use this — private
 * reloc_r_type statics stay empty and ADRP got BRANCH26 (ld -r reject).
 * @param ctx_bytes *u8 - ElfCodegenCtx* (owner check)
 * @param r i32 - reloc index
 * @return i32 - stored type or 0
 * PLATFORM: SHARED freestanding · MACOS writer co-path.
 */
#[no_mangle]
export function pipeline_elf_ctx_reloc_r_type_at(ctx_bytes: *u8, r: i32): i32 {
  if (ctx_bytes == 0 as *u8 || r < 0 || r >= pipe_elf_table_cap()) {
    return 0;
  }
  if (g_pipe_elf_reloc_sidecar_owner != ctx_bytes) {
    return 0;
  }
  return pipe_elf_bss_load_i32(&g_pipe_elf_reloc_r_type[0], r);
}

/**
 * Reloc r_pcrel sidecar (255/-1 = writer default; 0/1 explicit).
 * @param ctx_bytes *u8 - ElfCodegenCtx*
 * @param r i32 - reloc index
 * @return i32 - -1 default; else 0 or 1
 * PLATFORM: SHARED freestanding · MACOS writer co-path.
 */
#[no_mangle]
export function pipeline_elf_ctx_reloc_r_pcrel_at(ctx_bytes: *u8, r: i32): i32 {
  if (ctx_bytes == 0 as *u8 || r < 0 || r >= pipe_elf_table_cap()) {
    return 0 - 1;
  }
  if (g_pipe_elf_reloc_sidecar_owner != ctx_bytes) {
    return 0 - 1;
  }
  let v: i32 = 0;
  unsafe {
    v = g_pipe_elf_reloc_r_pcrel[r] as i32;
  }
  if (v == 255) {
    return 0 - 1;
  }
  return v;
}

/**
 * Read macho_leading_underscore (Darwin call/reloc prefix '_').
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_macho_leading_underscore(ctx_bytes: *u8): i32 {
  if (ctx_bytes == 0 as *u8) {
    return 0;
  }
  return w312_load(ctx_bytes, pipe_elf_off_macho_uscore());
}

/**
 * Append rel32/imm patch slot.
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 * Note: host residual forced imm_bits=19 on Apple aarch64 when 0; pure relies on
 * infer_patch_imm_bits at resolve time (SHARED-safe, same end result).
 */
#[no_mangle]
export function pipeline_elf_ctx_append_patch(ctx_bytes: *u8, rel32_offset: i32, name: *u8, name_len: i32, imm_bits: i32): i32 {
  if (ctx_bytes == 0 as *u8 || name == 0 as *u8 || name_len < 0) {
    return -1;
  }
  let np: i32 = w312_load(ctx_bytes, pipe_elf_off_num_patches());
  if (np >= pipe_elf_table_cap()) {
    return -1;
  }
  let bits: i32 = imm_bits;
  let pi: i32 = np;
  let ent: *u8 = pipe_elf_patch_at(ctx_bytes, pi);
  w312_store(ent, pipe_elf_pat_off_rel32(), rel32_offset);
  let n: i32 = name_len;
  // Cap 4.2.8: patches.name[256] content ≤255 (was wave580 128).
  if (n > 255) {
    n = 255;
  }
  if (n < 0) {
    n = 0;
  }
  if (n > 0) {
    unsafe {
      w312_memcpy(ent + (pipe_elf_pat_off_name() as usize), name, n as usize);
    }
  }
  w312_store(ent, pipe_elf_pat_off_name_len(), n);
  w312_store(ent, pipe_elf_pat_off_imm_bits(), bits);
  pipe_elf_patch_shndx_set(ctx_bytes, pi, pipe_elf_current_shndx(ctx_bytes));
  w312_store(ctx_bytes, pipe_elf_off_num_patches(), np + 1);
  return 0;
}

/**
 * Read patch imm_bits at index; OOB -> 0.
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_patch_imm_bits_at(ctx_bytes: *u8, patch_idx: i32): i32 {
  if (ctx_bytes == 0 as *u8 || patch_idx < 0 || patch_idx >= pipe_elf_table_cap()) {
    return 0;
  }
  let np: i32 = w312_load(ctx_bytes, pipe_elf_off_num_patches());
  if (patch_idx >= np) {
    return 0;
  }
  let p: *u8 = pipe_elf_patch_at(ctx_bytes, patch_idx);
  return w312_load(p, pipe_elf_pat_off_imm_bits());
}

function pipe_elf_read_u32_le(ctx_bytes: *u8, shndx: i32, off: i32): i32 {
  if (ctx_bytes == 0 as *u8 || off < 0) {
    return 0;
  }
  if (off + 3 >= pipe_elf_section_len(ctx_bytes, shndx)) {
    return 0;
  }
  let code: *u8 = pipe_elf_code_buf(ctx_bytes, shndx);
  let b0: u32 = 0;
  let b1: u32 = 0;
  let b2: u32 = 0;
  let b3: u32 = 0;
  unsafe {
    b0 = code[off] as u32;
    b1 = code[off + 1] as u32;
    b2 = code[off + 2] as u32;
    b3 = code[off + 3] as u32;
  }
  return (b0 + b1 * 256 + b2 * 65536 + b3 * 16777216) as i32;
}

function pipe_elf_write_u32_le(ctx_bytes: *u8, shndx: i32, off: i32, word: i32): void {
  if (ctx_bytes == 0 as *u8 || off < 0) {
    return;
  }
  if (off + 3 >= pipe_elf_section_len(ctx_bytes, shndx)) {
    return;
  }
  let code: *u8 = pipe_elf_code_buf(ctx_bytes, shndx);
  let u: u32 = word as u32;
  unsafe {
    code[off] = (u & 255) as u8;
    code[off + 1] = ((u / 256) & 255) as u8;
    code[off + 2] = ((u / 65536) & 255) as u8;
    code[off + 3] = ((u / 16777216) & 255) as u8;
  }
}

function pipe_elf_infer_patch_imm_bits(ctx_bytes: *u8, shndx: i32, rel32_offset: i32): i32 {
  if (ctx_bytes == 0 as *u8 || rel32_offset < 0) {
    return 0;
  }
  if (rel32_offset + 3 >= pipe_elf_section_len(ctx_bytes, shndx)) {
    return 0;
  }
  let code: *u8 = pipe_elf_code_buf(ctx_bytes, shndx);
  let op8: i32 = 0;
  unsafe {
    op8 = code[rel32_offset + 3] as i32;
  }
  if (op8 == 52 || op8 == 53 || op8 == 84) {
    return 19;
  }
  if (op8 == 20 || op8 == 148) {
    return 26;
  }
  if (op8 == 99 || op8 == 103) {
    return 13;
  }
  if (op8 == 111) {
    return 21;
  }
  return 0;
}

// Cap residual diagnostics (host-cc in pipeline_glue); pure resolve calls these.

/**
 * Log unresolved patch note (label hit count). Best-effort; resolve already diags.
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_log_unresolved_patch(ctx: *u8, patch_idx: i32): void {
  // Cap residual used diag_reportf varargs; pure keeps resolve-path driver_diagnostic.
  // Body intentionally light (no varargs face). PLATFORM: SHARED.
  if (ctx == 0 as *u8 || patch_idx < 0) {
    return;
  }
  let _np: i32 = w312_load(ctx, pipe_elf_off_num_patches());
  if (patch_idx >= _np) {
    return;
  }
  return;
}

/**
 * Resolve cbz/b/rel32 patches in ctx. Returns 0 ok, -1 unresolved.
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_resolve_patches(ctx_bytes: *u8): i32 {
  if (ctx_bytes == 0 as *u8) {
    return -1;
  }
  let e_machine: i32 = w312_load(ctx_bytes, pipe_elf_off_e_machine());
  let np: i32 = w312_load(ctx_bytes, pipe_elf_off_num_patches());
  let p: i32 = 0;
  while (p < np) {
    let patch: *u8 = pipe_elf_patch_at(ctx_bytes, p);
    let rel32_offset: i32 = w312_load(patch, pipe_elf_pat_off_rel32());
    let patch_shndx: i32 = pipe_elf_patch_shndx_at(ctx_bytes, p);
    let target_offset: i32 = -1;
    let target_shndx: i32 = patch_shndx;
    let pname: *u8 = patch + (pipe_elf_pat_off_name() as usize);
    let plen: i32 = w312_load(patch, pipe_elf_pat_off_name_len());
    let nl: i32 = w312_load(ctx_bytes, pipe_elf_off_num_labels());
    let l: i32 = 0;
    while (l < nl) {
      let lab: *u8 = pipe_elf_label_at(ctx_bytes, l);
      let llen: i32 = w312_load(lab, pipe_elf_lab_off_name_len());
      if (pipe_elf_name_eq(pname, plen, lab + (pipe_elf_lab_off_name() as usize), llen) != 0) {
        target_offset = w312_load(lab, pipe_elf_lab_off_offset());
        target_shndx = pipe_elf_label_shndx_at(ctx_bytes, l);
        break;
      }
      l = l + 1;
    }
    if (target_offset < 0) {
      unsafe {
        w312_diag_elf_unresolved(pname, plen);
      }
      pipeline_elf_log_unresolved_patch(ctx_bytes, p);
      return -1;
    }
    if (patch_shndx != target_shndx) {
      let code_len: i32 = w312_load(ctx_bytes, pipe_elf_off_code_len());
      let hot_len: i32 = w312_load(ctx_bytes, pipe_elf_off_code_hot_len());
      if (pipeline_elf_pgo_hot_enabled() == 0) {
        patch_shndx = pipe_elf_shnx_text();
        target_shndx = pipe_elf_shnx_text();
      } else if (rel32_offset >= 0 && rel32_offset + 4 <= code_len && target_offset >= 0 && target_offset <= code_len) {
        patch_shndx = pipe_elf_shnx_text();
        target_shndx = pipe_elf_shnx_text();
      } else if (rel32_offset >= 0 && rel32_offset + 4 <= hot_len && target_offset >= 0 && target_offset <= hot_len) {
        patch_shndx = pipe_elf_shnx_hot();
        target_shndx = pipe_elf_shnx_hot();
      } else {
        unsafe {
          w312_diag_elf_unresolved(pname, plen);
        }
        return -1;
      }
    }
    let imm_bits: i32 = w312_load(patch, pipe_elf_pat_off_imm_bits());
    if (imm_bits == 0) {
      imm_bits = pipe_elf_infer_patch_imm_bits(ctx_bytes, patch_shndx, rel32_offset);
    }
    let delta: i32 = 0;
    if (e_machine == 183 || imm_bits == 19 || imm_bits == 26) {
      delta = target_offset - rel32_offset;
    } else {
      delta = target_offset - (rel32_offset + 4);
    }
    if (e_machine == 183 || imm_bits == 19 || imm_bits == 26) {
      let insn: i32 = pipe_elf_read_u32_le(ctx_bytes, patch_shndx, rel32_offset);
      let imm: i32 = delta / 4;
      if (imm_bits == 26) {
        insn = (insn & (0 - 1048576)) | (imm & 67108863);
      } else if (imm_bits == 19) {
        insn = (insn & (0 - 16777121)) | ((imm & 524287) << 5);
      }
      pipe_elf_write_u32_le(ctx_bytes, patch_shndx, rel32_offset, insn);
    } else if (e_machine == 243 || imm_bits == 13 || imm_bits == 21) {
      let insn2: i32 = pipe_elf_read_u32_le(ctx_bytes, patch_shndx, rel32_offset);
      let val: i32 = delta >> 1;
      if (imm_bits == 13) {
        let b_imm: i32 = val & 8191;
        insn2 = (insn2 & 2097183) | ((b_imm & 4096) << 19) | ((b_imm & 4032) << 20) | ((b_imm & 30) << 7) | ((b_imm & 2048) >> 4);
      } else if (imm_bits == 21) {
        let j_imm: i32 = val & 2097151;
        insn2 = (insn2 & 4095) | ((j_imm & 524288) << 11) | ((j_imm & 1023) << 21) | ((j_imm & 1024) << 8) | ((j_imm & 522240) << 1);
      }
      pipe_elf_write_u32_le(ctx_bytes, patch_shndx, rel32_offset, insn2);
    } else {
      pipe_elf_write_u32_le(ctx_bytes, patch_shndx, rel32_offset, delta);
    }
    p = p + 1;
  }
  return 0;
}

/**
 * Append external reloc; >TABLE_CAP uses heap sidecar.
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_append_reloc(ctx_bytes: *u8, offset: i32, name: *u8, name_len: i32): i32 {
  if (ctx_bytes == 0 as *u8 || name == 0 as *u8 || name_len <= 0) {
    return -1;
  }
  unsafe {
    if (name[0] == 0) {
      return -1;
    }
  }
  let nr: i32 = w312_load(ctx_bytes, pipe_elf_off_num_relocs());
  if (nr >= pipe_elf_reloc_total_cap()) {
    return -1;
  }
  let ri: i32 = nr;
  let sym_row: *u8 = 0 as *u8;
  if (ri < pipe_elf_table_cap()) {
    let ent: *u8 = pipe_elf_reloc_at(ctx_bytes, ri);
    w312_store(ent, pipe_elf_rel_off_offset(), offset);
    sym_row = pipe_elf_reloc_name_row(ctx_bytes, ri);
  } else {
    if (g_pipe_elf_reloc_sidecar_owner != ctx_bytes) {
      pipeline_elf_ctx_reloc_sidecar_reset(ctx_bytes);
    }
    let hi: i32 = ri - pipe_elf_table_cap();
    let hent: *u8 = pipe_elf_reloc_heap_at(hi);
    if (hent == 0 as *u8) {
      return -1;
    }
    w312_store(hent, pipe_elf_rh_off_offset(), offset);
    sym_row = pipe_elf_reloc_sym_heap_at(hi);
  }
  pipe_elf_reloc_shndx_set(ctx_bytes, ri, pipe_elf_current_shndx(ctx_bytes));
  // Cap 4.2.8: reloc_sym_names.bytes[256] (was wave580 memset/clamp 128).
  unsafe {
    w312_memset(sym_row, 0, 256 as usize);
  }
  let n: i32 = name_len;
  if (n > 255) {
    n = 255;
  }
  if (n < 0) {
    n = 0;
  }
  if (n > 0) {
    unsafe {
      w312_memcpy(sym_row, name, n as usize);
    }
  }
  if (ri < pipe_elf_table_cap()) {
    let ent2: *u8 = pipe_elf_reloc_at(ctx_bytes, ri);
    w312_store(ent2, pipe_elf_rel_off_name_len(), n);
    pipe_elf_bss_store_i32(&g_pipe_elf_reloc_r_type[0], ri, 0);
    unsafe {
      g_pipe_elf_reloc_r_pcrel[ri] = 255;
    }
  } else {
    let hi2: i32 = ri - pipe_elf_table_cap();
    let h2: *u8 = pipe_elf_reloc_heap_at(hi2);
    if (h2 != 0 as *u8) {
      w312_store(h2, pipe_elf_rh_off_name_len(), n);
    }
  }
  w312_store(ctx_bytes, pipe_elf_off_num_relocs(), nr + 1);
  return 0;
}

/**
 * Append reloc with explicit r_type / r_pcrel (arm64 ADRP/PAGEOFF modlet).
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_append_reloc_typed(ctx_bytes: *u8, offset: i32, name: *u8, name_len: i32, r_type: i32, r_pcrel: i32): i32 {
  if (pipeline_elf_ctx_append_reloc(ctx_bytes, offset, name, name_len) != 0) {
    return -1;
  }
  let ri: i32 = w312_load(ctx_bytes, pipe_elf_off_num_relocs()) - 1;
  if (ri >= 0 && ri < pipe_elf_table_cap()) {
    pipe_elf_bss_store_i32(&g_pipe_elf_reloc_r_type[0], ri, r_type);
    if (r_pcrel < 0) {
      unsafe {
        g_pipe_elf_reloc_r_pcrel[ri] = 255;
      }
    } else {
      let pv: u8 = 0;
      if (r_pcrel != 0) {
        pv = 1;
      }
      unsafe {
        g_pipe_elf_reloc_r_pcrel[ri] = pv;
      }
    }
  }
  return 0;
}

/**
 * Append an absolute 64-bit pointer relocation (data slot holding a symbol address).
 *
 * F7 vtable statics store function pointers in a read-only data array, mirroring
 * the -E codegen path's `static void* vtable[] = { &wrapper_fn };`. Such a slot
 * requires an ABSOLUTE pointer reloc — NOT the default pc-relative branch reloc
 * that the untyped `pipeline_elf_ctx_append_reloc` produces (which on Mach-O
 * defaults to ARM64_RELOC_BRANCH26 and is rejected by ld on non-b/bl bytes).
 *
 * Sentinels:
 *   - r_type  = 200 (sentinel "absolute64"; both writers map to platform type)
 *   - r_pcrel = 0   (absolute, not pc-relative)
 *
 * The writers (Mach-O @ pipeline_macho_write_o_to_buf_c, ELF @
 * pipeline_elf_write_o_standard_to_buf_c) recognize r_type==200 and emit:
 *   - Mach-O arm64: r_type=0 (ARM64_RELOC_UNSIGNED), r_pcrel=0, r_length=3
 *   - ELF x86_64:   R_X86_64_64 (=1) with r_addend=0
 *   - ELF arm64:    R_AARCH64_ABS64 (=257) with r_addend=0
 *   - ELF riscv64:  R_RISCV_64 (=2) with r_addend=0
 *
 * @param ctx_bytes *u8  ElfCodegenCtx
 * @param offset    i32  byte offset within the section where the 8-byte slot lives
 * @param name      *u8  symbol name bytes (the wrapper function / target symbol)
 * @param name_len  i32  length of name
 * @return i32 0 ok, -1 fail
 * PLATFORM: SHARED freestanding ELF leave — G.7 single authority for absolute64.
 */
#[no_mangle]
export function pipeline_elf_ctx_append_reloc_absolute64(
  ctx_bytes: *u8, offset: i32, name: *u8, name_len: i32): i32 {
  /* r_type=200 sentinel; r_pcrel=0 (absolute). Writers map 200 → platform type. */
  return pipeline_elf_ctx_append_reloc_typed(ctx_bytes, offset, name, name_len, 200, 0);
}

/**
 * Pointer to reloc_sym_names[idx] (inline or heap).
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_reloc_sym_name_ptr(ctx_bytes: *u8, idx: i32): *u8 {
  if (ctx_bytes == 0 as *u8 || idx < 0) {
    return 0 as *u8;
  }
  let nr: i32 = w312_load(ctx_bytes, pipe_elf_off_num_relocs());
  if (idx >= nr) {
    return 0 as *u8;
  }
  if (idx < pipe_elf_table_cap()) {
    return pipe_elf_reloc_name_row(ctx_bytes, idx);
  }
  if (g_pipe_elf_reloc_sidecar_owner != ctx_bytes) {
    return 0 as *u8;
  }
  return pipe_elf_reloc_sym_heap_at(idx - pipe_elf_table_cap());
}

/**
 * Copy reloc name row into dst[256] (ABI name kept as copy64; Cap 4.2.8 payload 256).
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes: *u8, idx: i32, dst: *u8): void {
  if (dst == 0 as *u8) {
    return;
  }
  unsafe {
    w312_memset(dst, 0, 256 as usize);
  }
  let src: *u8 = pipeline_elf_ctx_reloc_sym_name_ptr(ctx_bytes, idx);
  if (src == 0 as *u8) {
    return;
  }
  if (ctx_bytes == 0 as *u8) {
    return;
  }
  let nr: i32 = w312_load(ctx_bytes, pipe_elf_off_num_relocs());
  if (idx < 0 || idx >= nr) {
    return;
  }
  let k: i32 = 0;
  while (k < 128) {
    unsafe {
      dst[k] = src[k];
    }
    k = k + 1;
  }
}

/**
 * Read reloc name_len (inline or heap).
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_reloc_name_len(ctx_bytes: *u8, idx: i32): i32 {
  if (ctx_bytes == 0 as *u8 || idx < 0) {
    return 0;
  }
  let nr: i32 = w312_load(ctx_bytes, pipe_elf_off_num_relocs());
  if (idx >= nr) {
    return 0;
  }
  if (idx < pipe_elf_table_cap()) {
    let r: *u8 = pipe_elf_reloc_at(ctx_bytes, idx);
    return w312_load(r, pipe_elf_rel_off_name_len());
  }
  if (g_pipe_elf_reloc_sidecar_owner != ctx_bytes) {
    return 0;
  }
  let h: *u8 = pipe_elf_reloc_heap_at(idx - pipe_elf_table_cap());
  if (h == 0 as *u8) {
    return 0;
  }
  return w312_load(h, pipe_elf_rh_off_name_len());
}


function pipe_elf_pgo_undef_name_row(i: i32): *u8 {
  return &g_pipe_elf_ws_pgo_undef_names[0] + ((i * 128) as usize);
}
function pipe_elf_pgo_undef_len_at(i: i32): i32 {
  return pipe_elf_bss_load_i32(&g_pipe_elf_ws_pgo_undef_lens[0], i);
}
function pipe_elf_pgo_undef_len_set(i: i32, v: i32): void {
  pipe_elf_bss_store_i32(&g_pipe_elf_ws_pgo_undef_lens[0], i, v);
}

function pipe_elf_init_shstr_pgo(): void {
  let p: *u8 = &g_pipe_elf_ws_shstr_pgo[0];
  unsafe {
    w312_memset(p, 0, 107 as usize);
    p[1] = 46;
    p[2] = 116;
    p[3] = 101;
    p[4] = 120;
    p[5] = 116;
    p[7] = 46;
    p[8] = 116;
    p[9] = 101;
    p[10] = 120;
    p[11] = 116;
    p[12] = 46;
    p[13] = 104;
    p[14] = 111;
    p[15] = 116;
    p[17] = 46;
    p[18] = 116;
    p[19] = 101;
    p[20] = 120;
    p[21] = 116;
    p[22] = 46;
    p[23] = 117;
    p[24] = 110;
    p[25] = 108;
    p[26] = 105;
    p[27] = 107;
    p[28] = 101;
    p[29] = 108;
    p[30] = 121;
    p[32] = 46;
    p[33] = 115;
    p[34] = 121;
    p[35] = 109;
    p[36] = 116;
    p[37] = 97;
    p[38] = 98;
    p[40] = 46;
    p[41] = 115;
    p[42] = 116;
    p[43] = 114;
    p[44] = 116;
    p[45] = 97;
    p[46] = 98;
    p[48] = 46;
    p[49] = 115;
    p[50] = 104;
    p[51] = 115;
    p[52] = 116;
    p[53] = 114;
    p[54] = 116;
    p[55] = 97;
    p[56] = 98;
    p[58] = 46;
    p[59] = 114;
    p[60] = 101;
    p[61] = 108;
    p[62] = 97;
    p[63] = 46;
    p[64] = 116;
    p[65] = 101;
    p[66] = 120;
    p[67] = 116;
    p[69] = 46;
    p[70] = 114;
    p[71] = 101;
    p[72] = 108;
    p[73] = 97;
    p[74] = 46;
    p[75] = 116;
    p[76] = 101;
    p[77] = 120;
    p[78] = 116;
    p[79] = 46;
    p[80] = 104;
    p[81] = 111;
    p[82] = 116;
    p[84] = 46;
    p[85] = 114;
    p[86] = 101;
    p[87] = 108;
    p[88] = 97;
    p[89] = 46;
    p[90] = 116;
    p[91] = 101;
    p[92] = 120;
    p[93] = 116;
    p[94] = 46;
    p[95] = 117;
    p[96] = 110;
    p[97] = 108;
    p[98] = 105;
    p[99] = 107;
    p[100] = 101;
    p[101] = 108;
    p[102] = 121;
  }
}

function pipe_elf_pgo_emit_rela_for_sh(ctx_bytes: *u8, out: *u8, want_sh: i32, num_undef: i32, ns: i32): i32 {
  let nr: i32 = w312_load(ctx_bytes, pipe_elf_off_num_relocs());
  let r: i32 = 0;
  while (r < nr) {
    if (pipeline_elf_ctx_reloc_shndx_at(ctx_bytes, r) != want_sh) {
      r = r + 1;
      continue;
    }
    let rela: *u8 = &g_pipe_elf_ws_rela[0];
    unsafe {
      w312_memset(rela, 0, 24 as usize);
      rela[16] = 252; rela[17] = 255; rela[18] = 255; rela[19] = 255;
      rela[20] = 255; rela[21] = 255; rela[22] = 255; rela[23] = 255;
    }
    pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, r, &g_pipe_elf_ws_name[0]);
    let rlen: i32 = pipeline_elf_ctx_reloc_name_len(ctx_bytes, r);
    let sym_idx: i32 = 0;
    let m: i32 = 0;
    let sym_pool: *u8 = ctx_bytes + (pipe_elf_off_sym_name_data() as usize);
    while (m < ns) {
      let se: *u8 = pipe_elf_sym_at(ctx_bytes, m);
      let slen: i32 = w312_load(se, pipe_elf_sym_off_name_len());
      let off: i32 = pipe_elf_sym_name_off(ctx_bytes, m);
      if (pipe_elf_name_eq(sym_pool + (off as usize), slen, &g_pipe_elf_ws_name[0], rlen) != 0) {
        sym_idx = m + 3;
        break;
      }
      m = m + 1;
    }
    if (sym_idx == 0) {
      let u: i32 = 0;
      while (u < num_undef) {
        if (pipe_elf_name_eq(pipe_elf_pgo_undef_name_row(u), pipe_elf_pgo_undef_len_at(u), &g_pipe_elf_ws_name[0], rlen) != 0) {
          sym_idx = ns + 3 + u;
          break;
        }
        u = u + 1;
      }
    }
    let roff: i32 = pipeline_elf_ctx_reloc_offset_at(ctx_bytes, r);
    pipe_elf_store_i32_bytes(rela, 0, roff);
    let rtype: i32 = pipe_elf_call_reloc_type(ctx_bytes, ctx_bytes, r, &g_pipe_elf_ws_name[0], rlen);
    pipe_elf_store_i32_bytes(rela, 8, rtype);
    pipe_elf_store_i32_bytes(rela, 12, sym_idx);
    if (pipe_elf_out_append(out, rela, 24) != 0) {
      return -1;
    }
    r = r + 1;
  }
  return 0;
}

/**
 * PGO-Lite: emit .text (empty) / .text.hot / .text.unlikely ELF64 ET_REL .o.
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_write_o_pgo_to_buf(ctx_bytes: *u8, out: *u8): i32 {
  if (ctx_bytes == 0 as *u8 || out == 0 as *u8) {
    return -1;
  }
  let unlikely: *u8 = ctx_bytes + (pipe_elf_off_code_data() as usize);
  let hot: *u8 = ctx_bytes + (pipe_elf_off_code_hot_data() as usize);
  let code_unlikely_len: i32 = w312_load(ctx_bytes, pipe_elf_off_code_len());
  let code_hot_len: i32 = w312_load(ctx_bytes, pipe_elf_off_code_hot_len());
  let e_machine: i32 = w312_load(ctx_bytes, pipe_elf_off_e_machine());
  let ns: i32 = w312_load(ctx_bytes, pipe_elf_off_num_syms());
  let nr: i32 = w312_load(ctx_bytes, pipe_elf_off_num_relocs());
  let num_undef: i32 = 0;
  let num_text_rela: i32 = 0;
  let num_hot_rela: i32 = 0;
  let num_unlikely_rela: i32 = 0;
  let r0: i32 = 0;
  while (r0 < nr) {
    pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, r0, &g_pipe_elf_ws_name[0]);
    let rlen: i32 = pipeline_elf_ctx_reloc_name_len(ctx_bytes, r0);
    if (pipe_elf_reloc_is_defined(ctx_bytes, ctx_bytes, r0, &g_pipe_elf_ws_name[0], rlen) == 0) {
      let dup: i32 = 0;
      let u0: i32 = 0;
      while (u0 < num_undef) {
        if (pipe_elf_name_eq(pipe_elf_pgo_undef_name_row(u0), pipe_elf_pgo_undef_len_at(u0), &g_pipe_elf_ws_name[0], rlen) != 0) {
          dup = 1;
          break;
        }
        u0 = u0 + 1;
      }
      if (dup == 0 && num_undef < pipe_elf_pgo_undef_cap()) {
        if (rlen > 128) {
          rlen = 128;
        }
        if (rlen > 0) {
          unsafe {
            w312_memcpy(pipe_elf_pgo_undef_name_row(num_undef), &g_pipe_elf_ws_name[0], rlen as usize);
          }
        }
        pipe_elf_pgo_undef_len_set(num_undef, rlen);
        num_undef = num_undef + 1;
      }
    }
    let rsh: i32 = pipeline_elf_ctx_reloc_shndx_at(ctx_bytes, r0);
    if (rsh == pipe_elf_shnx_hot()) {
      num_hot_rela = num_hot_rela + 1;
    } else if (rsh == pipe_elf_shnx_unlikely()) {
      num_unlikely_rela = num_unlikely_rela + 1;
    } else {
      num_text_rela = num_text_rela + 1;
    }
    r0 = r0 + 1;
  }
  let strtab_off: i32 = 1;
  let s: i32 = 0;
  while (s < ns) {
    let se: *u8 = pipe_elf_sym_at(ctx_bytes, s);
    strtab_off = strtab_off + w312_load(se, pipe_elf_sym_off_name_len()) + 1;
    s = s + 1;
  }
  s = 0;
  while (s < num_undef) {
    strtab_off = strtab_off + pipe_elf_pgo_undef_len_at(s) + 1;
    s = s + 1;
  }
  let strtab_size: i32 = strtab_off;
  let symtab_ents: i32 = 3 + ns + num_undef;
  let symtab_size: i32 = symtab_ents * 24;
  let align_hot: i32 = pipe_elf_align4(code_hot_len);
  let align_unlikely: i32 = pipe_elf_align4(code_unlikely_len);
  let off_text: i32 = 64;
  let off_hot: i32 = off_text;
  let off_unlikely: i32 = off_hot + align_hot;
  let off_strtab: i32 = off_unlikely + align_unlikely;
  let off_shstrtab: i32 = off_strtab + strtab_size;
  let off_symtab: i32 = off_shstrtab + 107;
  let off_rela_text: i32 = off_symtab + symtab_size;
  let off_rela_hot: i32 = off_rela_text + num_text_rela * 24;
  let off_rela_unlikely: i32 = off_rela_hot + num_hot_rela * 24;
  let off_shdr: i32 = off_rela_unlikely + num_unlikely_rela * 24;
  let ehdr: *u8 = &g_pipe_elf_ws_ehdr[0];
  unsafe {
    w312_memset(ehdr, 0, 128 as usize);
    ehdr[0] = 127; ehdr[1] = 69; ehdr[2] = 76; ehdr[3] = 70;
    ehdr[4] = 2; ehdr[5] = 1; ehdr[6] = 1; ehdr[16] = 1;
    ehdr[18] = ((e_machine as u32) & 255) as u8;
    ehdr[19] = (((e_machine as u32) / 256) & 255) as u8;
    ehdr[52] = 64; ehdr[58] = 64; ehdr[60] = 10; ehdr[62] = 6;
  }
  pipe_elf_store_i32_bytes(ehdr, 40, off_shdr);
  w312_out_set_len(out, 0);
  if (pipe_elf_out_append(out, ehdr, 64) != 0) {
    return -1;
  }
  if (code_hot_len > 0) {
    if (pipe_elf_out_append(out, hot, code_hot_len) != 0) {
      return -1;
    }
  }
  let z0: u8[1] = [0];
  s = code_hot_len;
  while (s < align_hot) {
    if (pipe_elf_out_append(out, &z0[0], 1) != 0) {
      return -1;
    }
    s = s + 1;
  }
  if (code_unlikely_len > 0) {
    if (pipe_elf_out_append(out, unlikely, code_unlikely_len) != 0) {
      return -1;
    }
  }
  s = code_unlikely_len;
  while (s < align_unlikely) {
    if (pipe_elf_out_append(out, &z0[0], 1) != 0) {
      return -1;
    }
    s = s + 1;
  }
  if (pipe_elf_out_append(out, &z0[0], 1) != 0) {
    return -1;
  }
  let sym_pool: *u8 = ctx_bytes + (pipe_elf_off_sym_name_data() as usize);
  s = 0;
  while (s < ns) {
    let se2: *u8 = pipe_elf_sym_at(ctx_bytes, s);
    let nlen: i32 = w312_load(se2, pipe_elf_sym_off_name_len());
    if (nlen > 0) {
      if (pipe_elf_out_append(out, sym_pool + (pipe_elf_sym_name_off(ctx_bytes, s) as usize), nlen) != 0) {
        return -1;
      }
    }
    if (pipe_elf_out_append(out, &z0[0], 1) != 0) {
      return -1;
    }
    s = s + 1;
  }
  s = 0;
  while (s < num_undef) {
    let ul: i32 = pipe_elf_pgo_undef_len_at(s);
    if (ul > 0) {
      if (pipe_elf_out_append(out, pipe_elf_pgo_undef_name_row(s), ul) != 0) {
        return -1;
      }
    }
    if (pipe_elf_out_append(out, &z0[0], 1) != 0) {
      return -1;
    }
    s = s + 1;
  }
  pipe_elf_init_shstr_pgo();
  if (pipe_elf_out_append(out, &g_pipe_elf_ws_shstr_pgo[0], 107) != 0) {
    return -1;
  }
  // 3 STT_SECTION symbols
  let ent: *u8 = &g_pipe_elf_ws_ent[0];
  let sec: i32 = 1;
  while (sec <= 3) {
    unsafe {
      w312_memset(ent, 0, 24 as usize);
      ent[4] = 3; ent[6] = (sec as u8);
    }
    if (sec == 2) {
      pipe_elf_store_i32_bytes(ent, 8, code_hot_len);
    } else if (sec == 3) {
      pipe_elf_store_i32_bytes(ent, 8, code_unlikely_len);
    }
    if (pipe_elf_out_append(out, ent, 24) != 0) {
      return -1;
    }
    sec = sec + 1;
  }
  let str_off: i32 = 1;
  s = 0;
  while (s < ns) {
    unsafe {
      w312_memset(ent, 0, 24 as usize);
    }
    let is_common: i32 = 0;
    if (g_pipe_elf_common_owner == ctx_bytes && s < pipe_elf_table_cap()) {
      unsafe {
        if (g_pipe_elf_sym_is_common[s] != 0) {
          is_common = 1;
        }
      }
    }
    let shndx: i32 = pipeline_elf_ctx_sym_shndx_at(ctx_bytes, s);
    pipe_elf_store_i32_bytes(ent, 0, str_off);
    let se3: *u8 = pipe_elf_sym_at(ctx_bytes, s);
    if (is_common != 0) {
      let csize: i32 = pipe_elf_bss_load_i32(&g_pipe_elf_sym_common_size[0], s);
      let calign: i32 = pipe_elf_bss_load_i32(&g_pipe_elf_sym_common_align[0], s);
      if (calign <= 0) {
        calign = 8;
      }
      if (csize <= 0) {
        csize = 8;
      }
      unsafe {
        ent[4] = 17; ent[6] = 242; ent[7] = 255;
      }
      pipe_elf_store_i32_bytes(ent, 8, calign);
      pipe_elf_store_i32_bytes(ent, 16, csize);
    } else {
      unsafe {
        ent[4] = 18;
        ent[6] = ((shndx as u32) & 255) as u8;
        ent[7] = (((shndx as u32) / 256) & 255) as u8;
      }
      pipe_elf_store_i32_bytes(ent, 8, w312_load(se3, pipe_elf_sym_off_offset()));
    }
    if (pipe_elf_out_append(out, ent, 24) != 0) {
      return -1;
    }
    str_off = str_off + w312_load(se3, pipe_elf_sym_off_name_len()) + 1;
    s = s + 1;
  }
  s = 0;
  while (s < num_undef) {
    unsafe {
      w312_memset(ent, 0, 24 as usize);
      ent[4] = 18;
    }
    pipe_elf_store_i32_bytes(ent, 0, str_off);
    if (pipe_elf_out_append(out, ent, 24) != 0) {
      return -1;
    }
    str_off = str_off + pipe_elf_pgo_undef_len_at(s) + 1;
    s = s + 1;
  }
  if (pipe_elf_pgo_emit_rela_for_sh(ctx_bytes, out, pipe_elf_shnx_text(), num_undef, ns) != 0) {
    return -1;
  }
  if (pipe_elf_pgo_emit_rela_for_sh(ctx_bytes, out, pipe_elf_shnx_hot(), num_undef, ns) != 0) {
    return -1;
  }
  if (pipe_elf_pgo_emit_rela_for_sh(ctx_bytes, out, pipe_elf_shnx_unlikely(), num_undef, ns) != 0) {
    return -1;
  }
  // 10 section headers
  let sh: *u8 = &g_pipe_elf_ws_shdr[0];
  unsafe {
    w312_memset(sh, 0, 640 as usize);
  }
  // text (empty size 0)
  let t: *u8 = sh + (64 as usize);
  unsafe {
    t[0] = 1; t[4] = 1; t[8] = 6;
  }
  pipe_elf_store_i32_bytes(t, 24, off_text);
  // hot
  let h: *u8 = sh + (128 as usize);
  unsafe {
    h[0] = 7; h[4] = 1; h[8] = 6;
  }
  pipe_elf_store_i32_bytes(h, 24, off_hot);
  pipe_elf_store_i32_bytes(h, 32, code_hot_len);
  // unlikely
  let u: *u8 = sh + (192 as usize);
  unsafe {
    u[0] = 17; u[4] = 1; u[8] = 6;
  }
  pipe_elf_store_i32_bytes(u, 24, off_unlikely);
  pipe_elf_store_i32_bytes(u, 32, code_unlikely_len);
  // sym
  let sy: *u8 = sh + (256 as usize);
  unsafe {
    sy[0] = 32; sy[4] = 2;
  }
  pipe_elf_store_i32_bytes(sy, 24, off_symtab);
  pipe_elf_store_i32_bytes(sy, 32, symtab_size);
  unsafe {
    sy[40] = 5; sy[44] = 1; sy[56] = 24;
  }
  // str
  let st: *u8 = sh + (320 as usize);
  unsafe {
    st[0] = 40; st[4] = 3;
  }
  pipe_elf_store_i32_bytes(st, 24, off_strtab);
  pipe_elf_store_i32_bytes(st, 32, strtab_size);
  unsafe {
    st[48] = 1;
  }
  // shstr
  let ssh: *u8 = sh + (384 as usize);
  unsafe {
    ssh[0] = 48; ssh[4] = 3;
  }
  pipe_elf_store_i32_bytes(ssh, 24, off_shstrtab);
  unsafe {
    ssh[32] = 107; ssh[48] = 1;
  }
  // rela text
  let rt: *u8 = sh + (448 as usize);
  unsafe {
    rt[0] = 58; rt[4] = 4;
  }
  pipe_elf_store_i32_bytes(rt, 24, off_rela_text);
  pipe_elf_store_i32_bytes(rt, 32, num_text_rela * 24);
  unsafe {
    rt[40] = 4; rt[44] = 1; rt[56] = 24;
  }
  // rela hot
  let rh: *u8 = sh + (512 as usize);
  unsafe {
    rh[0] = 71; rh[4] = 4;
  }
  pipe_elf_store_i32_bytes(rh, 24, off_rela_hot);
  pipe_elf_store_i32_bytes(rh, 32, num_hot_rela * 24);
  unsafe {
    rh[40] = 4; rh[44] = 2; rh[56] = 24;
  }
  // rela unlikely
  let ru: *u8 = sh + (576 as usize);
  unsafe {
    ru[0] = 86; ru[4] = 4;
  }
  pipe_elf_store_i32_bytes(ru, 24, off_rela_unlikely);
  pipe_elf_store_i32_bytes(ru, 32, num_unlikely_rela * 24);
  unsafe {
    ru[40] = 4; ru[44] = 3; ru[56] = 24;
  }
  let hi: i32 = 0;
  while (hi < 10) {
    if (pipe_elf_out_append(out, sh + ((hi * 64) as usize), 64) != 0) {
      return -1;
    }
    hi = hi + 1;
  }
  return w312_out_len(out);
}

// (wave273 pgo writer; writers continue)


/**
 * Append n bytes into CodegenOutBuf (data[9437184] + length i32 LE).
 * @return i32 - 0 ok, -1 overflow
 * PLATFORM: SHARED freestanding ELF leave.
 */
function pipe_elf_out_append(out: *u8, p: *u8, n: i32): i32 {
  if (out == 0 as *u8 || p == 0 as *u8 || n < 0) {
    return -1;
  }
  let len: i32 = w312_out_len(out);
  if (len + n > pipe_elf_codegen_out_cap()) {
    return -1;
  }
  let i: i32 = 0;
  while (i < n) {
    unsafe {
      out[len + i] = p[i];
    }
    i = i + 1;
  }
  w312_out_set_len(out, len + n);
  return 0;
}

/**
 * Byte offset of sym_idx name in sym_name_data pool.
 */
function pipe_elf_sym_name_off(ctx: *u8, sym_idx: i32): i32 {
  let off: i32 = 0;
  let i: i32 = 0;
  let ns: i32 = w312_load(ctx, pipe_elf_off_num_syms());
  while (i < sym_idx && i < ns) {
    let se: *u8 = pipe_elf_sym_at(ctx, i);
    off = off + w312_load(se, pipe_elf_sym_off_name_len());
    i = i + 1;
  }
  return off;
}

/**
 * Whether reloc target name matches a defined export symbol.
 */
function pipe_elf_reloc_is_defined(ctx: *u8, ctx_bytes: *u8, reloc_idx: i32, rname: *u8, rlen: i32): i32 {
  if (ctx == 0 as *u8 || ctx_bytes == 0 as *u8 || rname == 0 as *u8 || rlen <= 0) {
    return 0;
  }
  let sym_pool: *u8 = ctx_bytes + (pipe_elf_off_sym_name_data() as usize);
  let ns: i32 = w312_load(ctx, pipe_elf_off_num_syms());
  let m: i32 = 0;
  while (m < ns) {
    let se: *u8 = pipe_elf_sym_at(ctx, m);
    let slen: i32 = w312_load(se, pipe_elf_sym_off_name_len());
    let off: i32 = pipe_elf_sym_name_off(ctx, m);
    if (pipe_elf_name_eq(sym_pool + (off as usize), slen, rname, rlen) != 0) {
      return 1;
    }
    m = m + 1;
  }
  return 0;
}

/**
 * x86_64 call reloc type: defined PC32, UND PLT32; explicit sidecar wins.
 */
function pipe_elf_call_reloc_type(ctx: *u8, ctx_bytes: *u8, reloc_idx: i32, rname: *u8, rlen: i32): i32 {
  if (ctx == 0 as *u8) {
    return 2;
  }
  if (reloc_idx >= 0 && reloc_idx < pipe_elf_table_cap()) {
    let rt: i32 = pipe_elf_bss_load_i32(&g_pipe_elf_reloc_r_type[0], reloc_idx);
    if (rt != 0) {
      return rt;
    }
  }
  let em: i32 = w312_load(ctx, pipe_elf_off_e_machine());
  if (em == 62 && pipe_elf_reloc_is_defined(ctx, ctx_bytes, reloc_idx, rname, rlen) == 0) {
    return 4;
  }
  return w312_load(ctx, pipe_elf_off_reloc_type_r_pc32());
}

/**
 * Write signed 64-bit r_addend into rela bytes[16..23].
 */
function pipe_elf_rela_set_addend64(rela_buf: *u8, addend_lo: i32, addend_hi: i32): void {
  // Common case addend = -4 => lo=0xFFFFFFFC hi=0xFFFFFFFF
  let u0: u32 = addend_lo as u32;
  let u1: u32 = addend_hi as u32;
  unsafe {
    rela_buf[16] = (u0 & 255) as u8;
    rela_buf[17] = ((u0 / 256) & 255) as u8;
    rela_buf[18] = ((u0 / 65536) & 255) as u8;
    rela_buf[19] = ((u0 / 16777216) & 255) as u8;
    rela_buf[20] = (u1 & 255) as u8;
    rela_buf[21] = ((u1 / 256) & 255) as u8;
    rela_buf[22] = ((u1 / 65536) & 255) as u8;
    rela_buf[23] = ((u1 / 16777216) & 255) as u8;
  }
}

function pipe_elf_store_i32_bytes(dst: *u8, off: i32, v: i32): void {
  let u: u32 = v as u32;
  unsafe {
    dst[off] = (u & 255) as u8;
    dst[off + 1] = ((u / 256) & 255) as u8;
    dst[off + 2] = ((u / 65536) & 255) as u8;
    dst[off + 3] = ((u / 16777216) & 255) as u8;
  }
}

function pipe_elf_align4(n: i32): i32 {
  // (n + 3) & ~3
  return (n + 3) & (0 - 4);
}

/**
 * 8-byte file/section alignment for ELF .data (vtable pointer slots).
 * @param n i32 — unaligned size or file offset
 * @return i32 — n rounded up to a multiple of 8
 * PLATFORM: LINUX ELF writer — pointer slots need sh_addralign=8.
 */
function pipe_elf_align8(n: i32): i32 {
  // (n + 7) & ~7
  return (n + 7) & (0 - 8);
}

/**
 * Size of the standard (non-PGO) ELF shstrtab including F7 .data / .rela.data.
 * @return i32 — 63
 * PLATFORM: LINUX ELF writer.
 */
function pipe_elf_shstr_std_size(): i32 {
  return 63;
}

function pipe_elf_ws_undef_name_row(i: i32): *u8 {
  return &g_pipe_elf_ws_undef_names[0] + ((i * 128) as usize);
}

function pipe_elf_ws_undef_len_at(i: i32): i32 {
  return pipe_elf_bss_load_i32(&g_pipe_elf_ws_undef_lens[0], i);
}

function pipe_elf_ws_undef_len_set(i: i32, v: i32): void {
  pipe_elf_bss_store_i32(&g_pipe_elf_ws_undef_lens[0], i, v);
}

function pipe_elf_init_shstr_std(): void {
  // Historic 46-byte blob (name offsets 1/8/16/24/34 kept) plus F7:
  //   [45] ".data\0"      [51] ".rela.data\0"   total 63.
  // Section header index 4 is .data so pipe_elf_shnx_data()==4 is the ELF st_shndx.
  let p: *u8 = &g_pipe_elf_ws_shstr_std[0];
  unsafe {
    w312_memset(p, 0, 64 as usize);
    p[1] = 46; p[2] = 116; p[3] = 101; p[4] = 120; p[5] = 116;
    p[7] = 46; p[8] = 115; p[9] = 121; p[10] = 109; p[11] = 116; p[12] = 97; p[13] = 98;
    p[15] = 46; p[16] = 115; p[17] = 116; p[18] = 114; p[19] = 116; p[20] = 97; p[21] = 98;
    p[23] = 46; p[24] = 115; p[25] = 104; p[26] = 115; p[27] = 116; p[28] = 114; p[29] = 116; p[30] = 97; p[31] = 98;
    p[33] = 46; p[34] = 114; p[35] = 101; p[36] = 108; p[37] = 97; p[38] = 46; p[39] = 116; p[40] = 101; p[41] = 120; p[42] = 116;
    /* ".data" at 45 */
    p[45] = 46; p[46] = 100; p[47] = 97; p[48] = 116; p[49] = 97;
    /* ".rela.data" at 51 */
    p[51] = 46; p[52] = 114; p[53] = 101; p[54] = 108; p[55] = 97;
    p[56] = 46; p[57] = 100; p[58] = 97; p[59] = 116; p[60] = 97;
  }
}

/**
 * Standard ELF64 ET_REL .o writer (non-PGO). PGO routes to the pgo writer.
 *
 * F7: always emits .data at ELF section index 4 (matches pipe_elf_shnx_data)
 * plus .rela.text / .rela.data split by the reloc shndx sidecar. Vtable
 * statics with absolute64 pointer slots must live in .data — putting them
 * in .text makes ld report TEXTREL and the linked image SIGSEGV.
 *
 * Layout (section header indices):
 *   0 NULL  1 .text  2 .symtab  3 .strtab  4 .data
 *   5 .shstrtab  6 .rela.text  7 .rela.data
 *
 * @param ctx_bytes *u8 — ElfCodegenCtx
 * @param out *u8 — CodegenOutBuf
 * @return i32 — out length on success, -1 fail
 * PLATFORM: LINUX primary (ELF); linked SHARED. Mach-O twin is
 * pipeline_macho_write_o_to_buf_c (already splits __DATA,__const).
 */
#[no_mangle]
export function pipeline_elf_write_o_standard_to_buf_c(ctx_bytes: *u8, out: *u8): i32 {
  if (ctx_bytes == 0 as *u8 || out == 0 as *u8) {
    return -1;
  }
  if (pipeline_elf_pgo_hot_enabled() != 0) {
    return pipeline_elf_write_o_pgo_to_buf(ctx_bytes, out);
  }
  let code: *u8 = pipeline_elf_ctx_code_data_ptr(ctx_bytes);
  let code_len: i32 = w312_load(ctx_bytes, pipe_elf_off_code_len());
  let e_machine: i32 = w312_load(ctx_bytes, pipe_elf_off_e_machine());
  let num_undef: i32 = 0;
  let nr: i32 = w312_load(ctx_bytes, pipe_elf_off_num_relocs());
  let ns: i32 = w312_load(ctx_bytes, pipe_elf_off_num_syms());
  /* F7: data section payload (vtable statics). Always present as shndx 4. */
  let data_len: i32 = g_pipe_elf_data_len;
  if (data_len < 0) {
    data_len = 0;
  }
  let data_buf: *u8 = &g_pipe_elf_data_buf[0];
  let r0: i32 = 0;
  while (r0 < nr) {
    pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, r0, &g_pipe_elf_ws_name[0]);
    let rlen: i32 = pipeline_elf_ctx_reloc_name_len(ctx_bytes, r0);
    if (pipe_elf_reloc_is_defined(ctx_bytes, ctx_bytes, r0, &g_pipe_elf_ws_name[0], rlen) == 0) {
      let dup: i32 = 0;
      let u0: i32 = 0;
      while (u0 < num_undef) {
        if (pipe_elf_name_eq(pipe_elf_ws_undef_name_row(u0), pipe_elf_ws_undef_len_at(u0), &g_pipe_elf_ws_name[0], rlen) != 0) {
          dup = 1;
          break;
        }
        u0 = u0 + 1;
      }
      if (dup == 0 && num_undef < pipe_elf_undef_cap()) {
        if (rlen > 128) {
          rlen = 128;
        }
        if (rlen > 0) {
          unsafe {
            w312_memcpy(pipe_elf_ws_undef_name_row(num_undef), &g_pipe_elf_ws_name[0], rlen as usize);
          }
        }
        pipe_elf_ws_undef_len_set(num_undef, rlen);
        num_undef = num_undef + 1;
      }
    }
    r0 = r0 + 1;
  }
  let strtab_off: i32 = 1;
  let s: i32 = 0;
  while (s < ns) {
    let se: *u8 = pipe_elf_sym_at(ctx_bytes, s);
    strtab_off = strtab_off + w312_load(se, pipe_elf_sym_off_name_len()) + 1;
    s = s + 1;
  }
  s = 0;
  while (s < num_undef) {
    strtab_off = strtab_off + pipe_elf_ws_undef_len_at(s) + 1;
    s = s + 1;
  }
  let strtab_size: i32 = strtab_off;
  let symtab_ents: i32 = 1 + ns + num_undef;
  let symtab_size: i32 = symtab_ents * 24;
  /* F7: count text vs data relocs so each SHT_RELA covers one section. */
  let nr_text: i32 = 0;
  let nr_data: i32 = 0;
  let rc_i: i32 = 0;
  while (rc_i < nr) {
    let sd: i32 = pipeline_elf_ctx_reloc_shndx_at(ctx_bytes, rc_i);
    if (sd == pipe_elf_shnx_data()) {
      nr_data = nr_data + 1;
    } else {
      nr_text = nr_text + 1;
    }
    rc_i = rc_i + 1;
  }
  let rela_text_size: i32 = nr_text * 24;
  let rela_data_size: i32 = nr_data * 24;
  let shstr_sz: i32 = pipe_elf_shstr_std_size();
  let off_text: i32 = 64;
  let off_data: i32 = pipe_elf_align8(off_text + code_len);
  let off_strtab: i32 = off_data + pipe_elf_align8(data_len);
  let off_shstrtab: i32 = off_strtab + strtab_size;
  let off_symtab: i32 = off_shstrtab + shstr_sz;
  let off_rela_text: i32 = off_symtab + symtab_size;
  let off_rela_data: i32 = off_rela_text + rela_text_size;
  let off_shdr: i32 = off_rela_data + rela_data_size;
  let ehdr: *u8 = &g_pipe_elf_ws_ehdr[0];
  unsafe {
    w312_memset(ehdr, 0, 128 as usize);
  }
  unsafe {
    ehdr[0] = 127; ehdr[1] = 69; ehdr[2] = 76; ehdr[3] = 70;
    ehdr[4] = 2; ehdr[5] = 1; ehdr[6] = 1;
    ehdr[16] = 1;
  }
  pipe_elf_store_i32_bytes(ehdr, 18, e_machine & 65535);
  // e_machine is 16-bit at 18; store low 2 bytes carefully
  unsafe {
    ehdr[18] = ((e_machine as u32) & 255) as u8;
    ehdr[19] = (((e_machine as u32) / 256) & 255) as u8;
  }
  pipe_elf_store_i32_bytes(ehdr, 40, off_shdr);
  /* e_shnum=8, e_shstrndx=5 (.shstrtab). Index 4 is .data. */
  unsafe {
    ehdr[52] = 64; ehdr[58] = 64; ehdr[60] = 8; ehdr[62] = 5;
  }
  w312_out_set_len(out, 0);
  if (pipe_elf_out_append(out, ehdr, 64) != 0) {
    return -1;
  }
  if (code_len > 0 && code != 0 as *u8) {
    if (pipe_elf_out_append(out, code, code_len) != 0) {
      return -1;
    }
  }
  let z0: u8[1] = [0];
  /* Pad .text end so .data starts 8-aligned in the file. */
  let pad_data: i32 = off_data - off_text - code_len;
  let pd: i32 = 0;
  while (pd < pad_data) {
    if (pipe_elf_out_append(out, &z0[0], 1) != 0) {
      return -1;
    }
    pd = pd + 1;
  }
  if (data_len > 0 && data_buf != 0 as *u8) {
    if (pipe_elf_out_append(out, data_buf, data_len) != 0) {
      return -1;
    }
  }
  let pad_str: i32 = off_strtab - off_data - data_len;
  let ps: i32 = 0;
  while (ps < pad_str) {
    if (pipe_elf_out_append(out, &z0[0], 1) != 0) {
      return -1;
    }
    ps = ps + 1;
  }
  if (pipe_elf_out_append(out, &z0[0], 1) != 0) {
    return -1;
  }
  let sym_pool: *u8 = ctx_bytes + (pipe_elf_off_sym_name_data() as usize);
  s = 0;
  while (s < ns) {
    let se2: *u8 = pipe_elf_sym_at(ctx_bytes, s);
    let nlen: i32 = w312_load(se2, pipe_elf_sym_off_name_len());
    if (nlen > 0) {
      if (pipe_elf_out_append(out, sym_pool + (pipe_elf_sym_name_off(ctx_bytes, s) as usize), nlen) != 0) {
        return -1;
      }
    }
    if (pipe_elf_out_append(out, &z0[0], 1) != 0) {
      return -1;
    }
    s = s + 1;
  }
  s = 0;
  while (s < num_undef) {
    let ul: i32 = pipe_elf_ws_undef_len_at(s);
    if (ul > 0) {
      if (pipe_elf_out_append(out, pipe_elf_ws_undef_name_row(s), ul) != 0) {
        return -1;
      }
    }
    if (pipe_elf_out_append(out, &z0[0], 1) != 0) {
      return -1;
    }
    s = s + 1;
  }
  pipe_elf_init_shstr_std();
  if (pipe_elf_out_append(out, &g_pipe_elf_ws_shstr_std[0], shstr_sz) != 0) {
    return -1;
  }
  // STT_SECTION for .text (symbol index 0). Do not add a .data STT_SECTION —
  // that would shift defined/undef symbol indices used by rela r_sym.
  let ent: *u8 = &g_pipe_elf_ws_ent[0];
  unsafe {
    w312_memset(ent, 0, 24 as usize);
    ent[4] = 3; ent[6] = 1;
  }
  pipe_elf_store_i32_bytes(ent, 8, code_len);
  if (pipe_elf_out_append(out, ent, 24) != 0) {
    return -1;
  }
  let str_off: i32 = 1;
  s = 0;
  while (s < ns) {
    unsafe {
      w312_memset(ent, 0, 24 as usize);
    }
    let is_common: i32 = 0;
    if (g_pipe_elf_common_owner == ctx_bytes && s < pipe_elf_table_cap()) {
      unsafe {
        if (g_pipe_elf_sym_is_common[s] != 0) {
          is_common = 1;
        }
      }
    }
    pipe_elf_store_i32_bytes(ent, 0, str_off);
    let se3: *u8 = pipe_elf_sym_at(ctx_bytes, s);
    if (is_common != 0) {
      let csize: i32 = pipe_elf_bss_load_i32(&g_pipe_elf_sym_common_size[0], s);
      let calign: i32 = pipe_elf_bss_load_i32(&g_pipe_elf_sym_common_align[0], s);
      if (calign <= 0) {
        calign = 8;
      }
      if (csize <= 0) {
        csize = 8;
      }
      unsafe {
        ent[4] = 17; ent[6] = 242; ent[7] = 255;
      }
      pipe_elf_store_i32_bytes(ent, 8, calign);
      pipe_elf_store_i32_bytes(ent, 16, csize);
    } else {
      /* F7: st_shndx from the sidecar. 4 = .data (vtable); else .text.
       * Never emit PGO hot/unlikely indices on this non-PGO path. */
      let sym_shndx: i32 = pipeline_elf_ctx_sym_shndx_at(ctx_bytes, s);
      let elf_shndx: i32 = 1;
      if (sym_shndx == pipe_elf_shnx_data()) {
        elf_shndx = 4;
      }
      unsafe {
        ent[4] = 18;
        ent[6] = (elf_shndx & 255) as u8;
        ent[7] = ((elf_shndx / 256) & 255) as u8;
      }
      pipe_elf_store_i32_bytes(ent, 8, w312_load(se3, pipe_elf_sym_off_offset()));
    }
    if (pipe_elf_out_append(out, ent, 24) != 0) {
      return -1;
    }
    str_off = str_off + w312_load(se3, pipe_elf_sym_off_name_len()) + 1;
    s = s + 1;
  }
  s = 0;
  while (s < num_undef) {
    unsafe {
      w312_memset(ent, 0, 24 as usize);
      ent[4] = 18;
    }
    pipe_elf_store_i32_bytes(ent, 0, str_off);
    if (pipe_elf_out_append(out, ent, 24) != 0) {
      return -1;
    }
    str_off = str_off + pipe_elf_ws_undef_len_at(s) + 1;
    s = s + 1;
  }
  /* F7: two-pass rela — text-section first (shndx != 4), then data (shndx == 4).
   * Sequential append matches off_rela_text then off_rela_data. */
  let pass: i32 = 0;
  while (pass < 2) {
    let want_data: i32 = 0;
    if (pass == 1) {
      want_data = 1;
    }
    let r: i32 = 0;
    while (r < nr) {
      let r_sd: i32 = pipeline_elf_ctx_reloc_shndx_at(ctx_bytes, r);
      let is_data: i32 = 0;
      if (r_sd == pipe_elf_shnx_data()) {
        is_data = 1;
      }
      if (is_data != want_data) {
        r = r + 1;
        continue;
      }
      pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, r, &g_pipe_elf_ws_name[0]);
      let rlen2: i32 = pipeline_elf_ctx_reloc_name_len(ctx_bytes, r);
      let sym_idx: i32 = 0;
      let m: i32 = 0;
      while (m < ns) {
        let se4: *u8 = pipe_elf_sym_at(ctx_bytes, m);
        let slen: i32 = w312_load(se4, pipe_elf_sym_off_name_len());
        let off: i32 = pipe_elf_sym_name_off(ctx_bytes, m);
        if (pipe_elf_name_eq(sym_pool + (off as usize), slen, &g_pipe_elf_ws_name[0], rlen2) != 0) {
          sym_idx = m + 1;
          break;
        }
        m = m + 1;
      }
      if (sym_idx == 0) {
        let u: i32 = 0;
        while (u < num_undef) {
          if (pipe_elf_name_eq(pipe_elf_ws_undef_name_row(u), pipe_elf_ws_undef_len_at(u), &g_pipe_elf_ws_name[0], rlen2) != 0) {
            sym_idx = ns + 1 + u;
            break;
          }
          u = u + 1;
        }
      }
      let rela: *u8 = &g_pipe_elf_ws_rela[0];
      unsafe {
        w312_memset(rela, 0, 24 as usize);
      }
      pipe_elf_rela_set_addend64(rela, 0 - 4, 0 - 1);
      let roff: i32 = pipeline_elf_ctx_reloc_offset_at(ctx_bytes, r);
      pipe_elf_store_i32_bytes(rela, 0, roff);
      let rtype: i32 = pipe_elf_call_reloc_type(ctx_bytes, ctx_bytes, r, &g_pipe_elf_ws_name[0], rlen2);
      // F7 absolute64: sentinel r_type=200 → platform absolute 64-bit reloc with
      // ZERO addend (the default -4 is for 32-bit pc-relative CALL disp). Map:
      //   x86_64 (em=62)  → R_X86_64_64 = 1
      //   arm64  (em=183) → R_AARCH64_ABS64 = 257
      //   riscv64(em=243) → R_RISCV_64 = 2
      if (rtype == 200) {
        pipe_elf_rela_set_addend64(rela, 0, 0);
        if (e_machine == 62) {
          rtype = 1;
        } else if (e_machine == 183) {
          rtype = 257;
        } else if (e_machine == 243) {
          rtype = 2;
        } else {
          rtype = 1;
        }
      }
      pipe_elf_store_i32_bytes(rela, 8, rtype);
      pipe_elf_store_i32_bytes(rela, 12, sym_idx);
      if (pipe_elf_out_append(out, rela, 24) != 0) {
        return -1;
      }
      r = r + 1;
    }
    pass = pass + 1;
  }
  // section headers (8 x 64): NULL .text .symtab .strtab .data .shstrtab .rela.text .rela.data
  let sh: *u8 = &g_pipe_elf_ws_shdr[0];
  unsafe {
    w312_memset(sh, 0, 512 as usize);
  }
  // shdr0 zero
  // shdr_text index 1
  let st: *u8 = sh + (64 as usize);
  unsafe {
    st[0] = 1; st[4] = 1; st[8] = 6;
  }
  pipe_elf_store_i32_bytes(st, 24, off_text);
  pipe_elf_store_i32_bytes(st, 32, code_len);
  // shdr_sym index 2
  let ss: *u8 = sh + (128 as usize);
  unsafe {
    ss[0] = 8; ss[4] = 2;
  }
  pipe_elf_store_i32_bytes(ss, 24, off_symtab);
  pipe_elf_store_i32_bytes(ss, 32, symtab_size);
  unsafe {
    ss[40] = 3; ss[44] = 1; ss[56] = 24;
  }
  // shdr_str index 3
  let sstr: *u8 = sh + (192 as usize);
  unsafe {
    sstr[0] = 16; sstr[4] = 3;
  }
  pipe_elf_store_i32_bytes(sstr, 24, off_strtab);
  pipe_elf_store_i32_bytes(sstr, 32, strtab_size);
  unsafe {
    sstr[48] = 1;
  }
  // shdr_data index 4 — PROGBITS, SHF_WRITE|SHF_ALLOC, align 8
  let sh_data: *u8 = sh + (256 as usize);
  unsafe {
    sh_data[0] = 45; sh_data[4] = 1; sh_data[8] = 3; sh_data[48] = 8;
  }
  pipe_elf_store_i32_bytes(sh_data, 24, off_data);
  pipe_elf_store_i32_bytes(sh_data, 32, data_len);
  // shdr_shstr index 5
  let ssh: *u8 = sh + (320 as usize);
  unsafe {
    ssh[0] = 24; ssh[4] = 3;
  }
  pipe_elf_store_i32_bytes(ssh, 24, off_shstrtab);
  unsafe {
    ssh[32] = (shstr_sz & 255) as u8; ssh[48] = 1;
  }
  // shdr_rela.text index 6 — sh_info = 1 (.text)
  let sr: *u8 = sh + (384 as usize);
  unsafe {
    sr[0] = 34; sr[4] = 4; sr[8] = 2; sr[16] = 64;
  }
  pipe_elf_store_i32_bytes(sr, 24, off_rela_text);
  pipe_elf_store_i32_bytes(sr, 32, rela_text_size);
  unsafe {
    sr[40] = 2; sr[44] = 1; sr[56] = 24;
  }
  // shdr_rela.data index 7 — sh_info = 4 (.data); name offset 51
  let srd: *u8 = sh + (448 as usize);
  unsafe {
    srd[0] = 51; srd[4] = 4; srd[8] = 2; srd[16] = 64;
  }
  pipe_elf_store_i32_bytes(srd, 24, off_rela_data);
  pipe_elf_store_i32_bytes(srd, 32, rela_data_size);
  unsafe {
    srd[40] = 2; srd[44] = 4; srd[56] = 24;
  }
  let hi: i32 = 0;
  while (hi < 8) {
    if (pipe_elf_out_append(out, sh + ((hi * 64) as usize), 64) != 0) {
      return -1;
    }
    hi = hi + 1;
  }
  return w312_out_len(out);
}
