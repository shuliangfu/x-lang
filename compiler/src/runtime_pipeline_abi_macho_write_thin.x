// Thin pure: wave314 M2 — macho_write Cap residual C→.x (was Darwin C thin).
// Mach-O MH_OBJECT writer + platform wrapper; 2 exports.
// G.7: bodies match mega wave273 macho portion; product F7/common/reloc
// via pipeline_elf_ctx_* (same as C thin — no dual-home elf BSS).
// File-local ws_* scratch only. PRODUCT inject: -E+$CC.
// PLATFORM: MACOS ingest · LINUX gold co-path.

export extern function codegen_out_buf_len(out: *u8): i32;
export extern function codegen_out_buf_set_len(out: *u8, n: i32): void;
export extern "C" function driver_diagnostic_asm_macho_empty_reloc(reloc_idx: i32): void;
export extern "C" function driver_diagnostic_asm_macho_missing_und_reloc(reloc_idx: i32): void;
export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;
export extern function pipe_elf_align4(n: i32): i32;
export extern function pipe_elf_bss_load_i32(blob: *u8, idx: i32): i32;
export extern function pipe_elf_bss_store_i32(blob: *u8, idx: i32, v: i32): void;
export extern function pipe_elf_macho_undef_cap(): i32;
export extern function pipe_elf_name_eq(a: *u8, a_len: i32, b: *u8, b_len: i32): i32;
export extern function pipe_elf_off_code_len(): i32;
export extern function pipe_elf_off_e_machine(): i32;
export extern function pipe_elf_off_num_relocs(): i32;
export extern function pipe_elf_off_num_syms(): i32;
export extern function pipe_elf_off_sym_name_data(): i32;
export extern function pipe_elf_out_append(out: *u8, p: *u8, n: i32): i32;
export extern function pipe_elf_reloc_is_defined(ctx: *u8, ctx_bytes: *u8, reloc_idx: i32, rname: *u8, rlen: i32): i32;
export extern function pipe_elf_shnx_data(): i32;
export extern function pipe_elf_store_i32_bytes(dst: *u8, off: i32, v: i32): void;
export extern function pipe_elf_sym_at(ctx: *u8, i: i32): *u8;
export extern function pipe_elf_sym_name_off(ctx: *u8, sym_idx: i32): i32;
export extern function pipe_elf_sym_off_name_len(): i32;
export extern function pipe_elf_sym_off_offset(): i32;
export extern function pipe_elf_table_cap(): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipeline_elf_ctx_code_data_ptr(ctx_bytes: *u8): *u8;
export extern function pipeline_elf_ctx_data_data_ptr(ctx_bytes: *u8): *u8;
export extern function pipeline_elf_ctx_emit_data_len(ctx_bytes: *u8): i32;
export extern function pipeline_elf_ctx_reloc_name_len(ctx_bytes: *u8, idx: i32): i32;
export extern function pipeline_elf_ctx_reloc_offset_at(ctx_bytes: *u8, idx: i32): i32;
export extern function pipeline_elf_ctx_reloc_r_pcrel_at(ctx_bytes: *u8, r: i32): i32;
export extern function pipeline_elf_ctx_reloc_r_type_at(ctx_bytes: *u8, r: i32): i32;
export extern function pipeline_elf_ctx_reloc_shndx_at(ctx_bytes: *u8, idx: i32): i32;
export extern function pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes: *u8, idx: i32, dst: *u8): void;
export extern function pipeline_elf_ctx_reloc_sym_name_ptr(ctx_bytes: *u8, idx: i32): *u8;
export extern function pipeline_elf_ctx_resolve_patches(ctx_bytes: *u8): i32;
export extern function pipeline_elf_ctx_sym_common_align_at(ctx_bytes: *u8, s: i32): i32;
export extern function pipeline_elf_ctx_sym_common_size_at(ctx_bytes: *u8, s: i32): i32;
export extern function pipeline_elf_ctx_sym_is_common_at(ctx_bytes: *u8, s: i32): i32;
export extern function pipeline_elf_ctx_sym_shndx_at(ctx_bytes: *u8, idx: i32): i32;

// File-local scratch (not product sidecars). Product F7/common/reloc go through
// pipeline_elf_ctx_* accessors so this thin does not dual-home elf_ctx BSS.
// PLATFORM: SHARED — Darwin ingest writer; LINUX gold co-path unused for Mach-O.
let g_pipe_elf_ws_name: u8[256] = [];
let g_pipe_elf_ws_name2: u8[256] = [];
let g_pipe_elf_ws_und_src: u8[1024] = [];
let g_pipe_elf_ws_und_lens: u8[1024] = [];
let g_pipe_elf_ws_hdr32: u8[32] = [];
let g_pipe_elf_ws_seg: u8[152] = [];
let g_pipe_elf_ws_seg2: u8[152] = [];
let g_pipe_elf_ws_lc: u8[48] = [];
let g_pipe_elf_ws_ent: u8[256] = [];

function pipe_macho_link_name_extra_byte(name_ptr: *u8): i32 {
  if (name_ptr == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (name_ptr[0] != 95) {
      return 1;
    }
  }
  return 0;
}

/**
 * Encode Mach-O common-symbol alignment into n_desc (GET_COMM_ALIGN).
 * Apple ld: when n_desc align bits are 0, section __DATA,__common alignment is
 * size-derived (up to 0x8000 for multi-MiB commons) and then reduced to the
 * segment max 0x4000 with a warning. Explicit log2(align) in n_desc stops
 * that derivation. Floor at 8 (log2=3) so n_desc is never 0; cap at 2^14 so
 * we never request more than the segment maximum.
 * @param calign i32 — byte alignment from add_common_sym (usually 1..16)
 * @return i32 — log2 to store in n_desc[15:8]
 * PLATFORM: MACOS|DARWIN — Mach-O nlist_64 n_desc only; ELF uses st_value.
 */
function pipe_macho_common_align_log2(calign: i32): i32 {
  let a: i32 = calign;
  if (a < 8) {
    a = 8;
  }
  if (a > 16384) {
    a = 16384;
  }
  let lg: i32 = 3;
  while (lg < 14) {
    let step: i32 = 1;
    let k: i32 = 0;
    while (k < lg) {
      step = step * 2;
      k = k + 1;
    }
    if (step >= a) {
      return lg;
    }
    lg = lg + 1;
  }
  return 14;
}

/**
 * Mach-O MH_OBJECT writer for pure-asm -o .o (product g05 Darwin).
 * Aligns with clang -c objects so Darwin clang -r onto hybrid pabi.o
 * does not silently poison ELF finalize (CG002 elf_ec=-1):
 *   · empty LC_SEGMENT_64.segname (sections still __TEXT,__text)
 *   · omit empty __DATA (emit_data_seg)
 *   · no dummy nlist[0]; r_symbolnum is 0-based
 *   · LC_DYSYMTAB after LC_SYMTAB (nlocals=0, nextdef=ns, nundef=nu)
 *   · __text flags 0x80000400; S_ATTR_EXT_RELOC only when nreloc>0
 * Commons stay in the ns prefix (historical nlist order; not re-sorted).
 * @param ctx_bytes *u8 — PipelineElfCtx
 * @param out *u8 — CodegenOutBuf
 * @return i32 — out length on success, -1 fail
 * wave273 pure-owned leave.
 * PLATFORM: MACOS|DARWIN writer (linked SHARED; unused unless use_macho_o).
 */
#[no_mangle]
export function pipeline_macho_write_o_to_buf_c(ctx_bytes: *u8, out: *u8): i32 {
  if (ctx_bytes == 0 as *u8 || out == 0 as *u8) {
    return -1;
  }
  if (pipeline_elf_ctx_resolve_patches(ctx_bytes) != 0) {
    return -1;
  }
  let code: *u8 = pipeline_elf_ctx_code_data_ptr(ctx_bytes);
  let code_len: i32 = pipe_load_i32_le(ctx_bytes, pipe_elf_off_code_len());
  let sym_pool: *u8 = ctx_bytes + (pipe_elf_off_sym_name_data() as usize);
  let ns: i32 = pipe_load_i32_le(ctx_bytes, pipe_elf_off_num_syms());
  let nr: i32 = pipe_load_i32_le(ctx_bytes, pipe_elf_off_num_relocs());
  let nu: i32 = 0;
  let rx: i32 = 0;
  while (rx < nr) {
    pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, rx, &g_pipe_elf_ws_name[0]);
    let rlen: i32 = pipeline_elf_ctx_reloc_name_len(ctx_bytes, rx);
    if (pipe_elf_reloc_is_defined(ctx_bytes, ctx_bytes, rx, &g_pipe_elf_ws_name[0], rlen) != 0) {
      rx = rx + 1;
      continue;
    }
    let dup: i32 = -1;
    let us: i32 = 0;
    while (us < nu) {
      let sr: i32 = pipe_elf_bss_load_i32(&g_pipe_elf_ws_und_src[0], us);
      pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, sr, &g_pipe_elf_ws_name2[0]);
      let ulen: i32 = pipe_elf_bss_load_i32(&g_pipe_elf_ws_und_lens[0], us);
      if (pipe_elf_name_eq(&g_pipe_elf_ws_name[0], rlen, &g_pipe_elf_ws_name2[0], ulen) != 0) {
        dup = us;
        break;
      }
      us = us + 1;
    }
    if (dup >= 0) {
      rx = rx + 1;
      continue;
    }
    if (nu >= pipe_elf_macho_undef_cap()) {
      return -1;
    }
    if (rlen <= 0) {
      unsafe {
        driver_diagnostic_asm_macho_empty_reloc(rx);
      }
      return -1;
    }
    pipe_elf_bss_store_i32(&g_pipe_elf_ws_und_src[0], nu, rx);
    pipe_elf_bss_store_i32(&g_pipe_elf_ws_und_lens[0], nu, rlen);
    nu = nu + 1;
    rx = rx + 1;
  }
  let strtab_size: i32 = 1;
  let s: i32 = 0;
  while (s < ns) {
    let off: i32 = pipe_elf_sym_name_off(ctx_bytes, s);
    let se: *u8 = pipe_elf_sym_at(ctx_bytes, s);
    let extra: i32 = pipe_macho_link_name_extra_byte(sym_pool + (off as usize));
    strtab_size = strtab_size + pipe_load_i32_le(se, pipe_elf_sym_off_name_len()) + extra + 1;
    s = s + 1;
  }
  let ui: i32 = 0;
  while (ui < nu) {
    let sr2: i32 = pipe_elf_bss_load_i32(&g_pipe_elf_ws_und_src[0], ui);
    let und_ptr: *u8 = pipeline_elf_ctx_reloc_sym_name_ptr(ctx_bytes, sr2);
    let extra2: i32 = pipe_macho_link_name_extra_byte(und_ptr);
    strtab_size = strtab_size + pipe_elf_bss_load_i32(&g_pipe_elf_ws_und_lens[0], ui) + extra2 + 1;
    ui = ui + 1;
  }
  /* clang MH_OBJECT: no dummy nlist[0]. strtab[0] stays the empty NUL. */
  let symtab_ents: i32 = ns + nu;
  let symtab_size: i32 = symtab_ents * 16;
  let lc_build_size: i32 = 24;
  let lc_dysym_size: i32 = 80;
  /* F7: data section (vtable statics with absolute pointer relocs).
   * Count data relocs BEFORE sizeofcmds: empty __DATA must drop the
   * second LC_SEGMENT_64 so ncmds/sizeofcmds stay consistent. */
  let data_len: i32 = pipeline_elf_ctx_emit_data_len(ctx_bytes);
  if (data_len < 0) {
    data_len = 0;
  }
  let data_buf: *u8 = pipeline_elf_ctx_data_data_ptr(ctx_bytes);
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
  /* Omit empty F7 __DATA LC_SEGMENT_64 when there are no data bytes and
   * no data relocs. Darwin clang -r of a two-segment MH_OBJECT onto
   * hybrid pabi.o can succeed and still poison ELF finalize (CG002
   * elf_ec=-1 out_len=0, hello included). Keep the second segment when
   * vtable/static data or ARM64_RELOC_UNSIGNED lives there.
   * PLATFORM: MACOS|DARWIN writer; ELF path unchanged. */
  let emit_data_seg: i32 = 0;
  if (data_len > 0 || nr_data > 0) {
    emit_data_seg = 1;
  }
  let sizeofcmds: i32 = 152 + lc_build_size + 24 + lc_dysym_size;
  if (emit_data_seg != 0) {
    sizeofcmds = sizeofcmds + 152;
  }
  let off_text: i32 = 32 + sizeofcmds;
  let off_data: i32 = pipe_elf_align4(off_text + code_len);
  let off_sym: i32 = pipe_elf_align4(off_data + data_len);
  let off_str: i32 = off_sym + symtab_size;
  let off_reloc_text: i32 = off_str + strtab_size;
  let off_reloc_data: i32 = off_reloc_text + nr_text * 8;
  let off_reloc: i32 = off_reloc_text;  /* keep for backward compat (text relocs) */
  codegen_out_buf_set_len(out, 0);
  let cputype: i32 = 16777223;
  let cpusubtype: i32 = 3;
  let em: i32 = pipe_load_i32_le(ctx_bytes, pipe_elf_off_e_machine());
  if (em == 183) {
    cputype = 16777228;
    cpusubtype = 0;
  }
  let hdr: *u8 = &g_pipe_elf_ws_hdr32[0];
  unsafe {
    memset(hdr, 0, 32 as usize);
    hdr[0] = 207; hdr[1] = 250; hdr[2] = 237; hdr[3] = 254;
  }
  pipe_elf_store_i32_bytes(hdr, 4, cputype);
  pipe_elf_store_i32_bytes(hdr, 8, cpusubtype);
  unsafe {
    hdr[12] = 1;
    /* ncmds = 4 (seg + BUILD + SYMTAB + DYSYMTAB), or 5 with __DATA. */
    if (emit_data_seg != 0) {
      hdr[16] = 5;
    } else {
      hdr[16] = 4;
    }
  }
  pipe_elf_store_i32_bytes(hdr, 20, sizeofcmds);
  if (pipe_elf_out_append(out, hdr, 32) != 0) {
    return -1;
  }
  let seg: *u8 = &g_pipe_elf_ws_seg[0];
  unsafe {
    memset(seg, 0, 152 as usize);
    seg[0] = 25; seg[4] = 152;
    /* clang MH_OBJECT: LC_SEGMENT_64.segname is empty; section still
     * names __TEXT,__text. Named __TEXT + empty __DATA poisoned Darwin
     * clang -r even after the second segment was stripped. */
  }
  pipe_elf_store_i32_bytes(seg, 32, code_len);
  pipe_elf_store_i32_bytes(seg, 40, off_text);
  pipe_elf_store_i32_bytes(seg, 48, code_len);
  unsafe {
    seg[56] = 7; seg[60] = 7; seg[64] = 1;
    seg[72] = 95; seg[73] = 95; seg[74] = 116; seg[75] = 101; seg[76] = 120; seg[77] = 116;
    seg[88] = 95; seg[89] = 95; seg[90] = 84; seg[91] = 69; seg[92] = 88; seg[93] = 84;
  }
  pipe_elf_store_i32_bytes(seg, 112, code_len);
  pipe_elf_store_i32_bytes(seg, 120, off_text);
  /* F7: __TEXT,__text reloc table now only covers text-section relocs. */
  pipe_elf_store_i32_bytes(seg, 128, off_reloc_text);
  unsafe {
    seg[132] = ((nr_text as u32) & 255) as u8;
    seg[133] = (((nr_text as u32) / 256) & 255) as u8;
    /* S_ATTR_PURE_INSTRUCTIONS|S_ATTR_SOME_INSTRUCTIONS = 0x80000400.
     * S_ATTR_EXT_RELOC (0x40000) only when this section has relocs. */
    seg[136] = 0;
    seg[137] = 4;
    if (nr_text > 0) {
      seg[138] = 4;
    } else {
      seg[138] = 0;
    }
    seg[139] = 128;
  }
  if (pipe_elf_out_append(out, seg, 152) != 0) {
    return -1;
  }
  /* F7: emit second LC_SEGMENT_64 for __DATA,__const (vtable static data).
   * This segment is writable at link time (initprot=rw-) so absolute 64-bit
   * pointer relocations (ARM64_RELOC_UNSIGNED) can be applied; ld rejects
   * these in __TEXT,__text which is pure_instructions.
   * Layout: segment_command_64 (72 bytes) + section_64 (80 bytes) = 152.
   * MH_OBJECT: __DATA.vmaddr MUST NOT overlap __TEXT.vmaddr+[0,vmsize).
   * Both at 0 with nonzero vmsize → ld "vm range overlaps". Place __DATA at
   * code_len (section addrs sequential, clang MH_OBJECT style). */
  let data_vmaddr: i32 = code_len;
  if (data_vmaddr < 0) {
    data_vmaddr = 0;
  }
  /* Pointer slots require 8-byte alignment (ld: "pointer not aligned"). */
  data_vmaddr = (data_vmaddr + 7) & (0 - 8);
  if (emit_data_seg != 0) {
  let seg2: *u8 = &g_pipe_elf_ws_seg2[0];
  unsafe {
    memset(seg2, 0, 152 as usize);
    seg2[0] = 25; seg2[4] = 152;  /* LC_SEGMENT_64, cmdsize=152 */
    seg2[8] = 95; seg2[9] = 95; seg2[10] = 68; seg2[11] = 65; seg2[12] = 84; seg2[13] = 65;  /* "__DATA" */
  }
  pipe_elf_store_i32_bytes(seg2, 24, data_vmaddr); /* vmaddr (low 4 bytes); hi zeroed */
  pipe_elf_store_i32_bytes(seg2, 32, data_len);   /* vmsize (low 4 bytes) */
  pipe_elf_store_i32_bytes(seg2, 40, off_data);    /* fileoff (low 4 bytes) */
  pipe_elf_store_i32_bytes(seg2, 48, data_len);    /* filesize (low 4 bytes) */
  unsafe {
    seg2[56] = 7; seg2[60] = 3;  /* maxprot=rwx, initprot=rw- */
    seg2[64] = 1;  /* nsects = 1 */
    /* section_64.sectname = "__data" at seg2+72.
     * Was "__const": final ld maps __const RO, so mutable modlet ARRAY_LIT
     * counters (fmt g_fmt_*_n = [0]/[1]) SIGBUS on store. Library-TU .data
     * bake needs a writable home; vtable statics are fine in __data too.
     * PLATFORM: MACOS|DARWIN — __DATA,__data (writable); ELF stays .data. */
    seg2[72] = 95; seg2[73] = 95; seg2[74] = 100; seg2[75] = 97; seg2[76] = 116; seg2[77] = 97;
    /* section_64.segname = "__DATA" at seg2+88 */
    seg2[88] = 95; seg2[89] = 95; seg2[90] = 68; seg2[91] = 65; seg2[92] = 84; seg2[93] = 65;
  }
  pipe_elf_store_i32_bytes(seg2, 104, data_vmaddr); /* section_64.addr (match segment vmaddr) */
  pipe_elf_store_i32_bytes(seg2, 112, data_len);   /* section_64.size */
  pipe_elf_store_i32_bytes(seg2, 120, off_data);    /* section_64.offset */
  pipe_elf_store_i32_bytes(seg2, 128, off_reloc_data);  /* section_64.reloff */
  unsafe {
    seg2[124] = 3;  /* section_64.align = 2^3 (8-byte pointers) */
    seg2[132] = ((nr_data as u32) & 255) as u8;    /* section_64.nreloc (low 2 bytes) */
    seg2[133] = (((nr_data as u32) / 256) & 255) as u8;
    seg2[136] = 0; seg2[137] = 0; seg2[138] = 0; seg2[139] = 0;  /* section_64.flags = 0 (S_REGULAR) */
  }
  if (pipe_elf_out_append(out, seg2, 152) != 0) {
    return -1;
  }
  }
  let lc_bv: *u8 = &g_pipe_elf_ws_lc[0];
  unsafe {
    memset(lc_bv, 0, 24 as usize);
    lc_bv[0] = 50;
  }
  pipe_elf_store_i32_bytes(lc_bv, 4, lc_build_size);
  unsafe {
    lc_bv[8] = 1;
  }
  let ver: i32 = 720896;
  pipe_elf_store_i32_bytes(lc_bv, 12, ver);
  pipe_elf_store_i32_bytes(lc_bv, 16, ver);
  if (pipe_elf_out_append(out, lc_bv, lc_build_size) != 0) {
    return -1;
  }
  let lc_sym: *u8 = &g_pipe_elf_ws_lc[0] + (24 as usize);
  unsafe {
    memset(lc_sym, 0, 24 as usize);
    lc_sym[0] = 2; lc_sym[4] = 24;
  }
  pipe_elf_store_i32_bytes(lc_sym, 8, off_sym);
  pipe_elf_store_i32_bytes(lc_sym, 12, symtab_ents);
  pipe_elf_store_i32_bytes(lc_sym, 16, off_str);
  pipe_elf_store_i32_bytes(lc_sym, 20, strtab_size);
  if (pipe_elf_out_append(out, lc_sym, 24) != 0) {
    return -1;
  }
  /* LC_DYSYMTAB (cmd=0x0b, cmdsize=80). Reuse nlist workspace; written
   * before any nlist. Grouping matches nlist order: ns ext-def then nu undef.
   * Commons stay inside the ns prefix (not re-sorted this knife). */
  let lc_dys: *u8 = &g_pipe_elf_ws_ent[0];
  unsafe {
    memset(lc_dys, 0, 80 as usize);
    lc_dys[0] = 11;
    lc_dys[4] = 80;
  }
  pipe_elf_store_i32_bytes(lc_dys, 20, ns);
  pipe_elf_store_i32_bytes(lc_dys, 24, ns);
  pipe_elf_store_i32_bytes(lc_dys, 28, nu);
  if (pipe_elf_out_append(out, lc_dys, lc_dysym_size) != 0) {
    return -1;
  }
  if (code_len > 0 && code != 0 as *u8) {
    if (pipe_elf_out_append(out, code, code_len) != 0) {
      return -1;
    }
  }
  let z0: u8[1] = [0];
  /* F7: padding between text and data (alignment 4); always emit so the file
   * position lands at off_data regardless of whether the data section is used. */
  let pad_data: i32 = off_data - off_text - code_len;
  let pd: i32 = 0;
  while (pd < pad_data) {
    if (pipe_elf_out_append(out, &z0[0], 1) != 0) {
      return -1;
    }
    pd = pd + 1;
  }
  /* F7: emit data section bytes (__DATA,__const). */
  if (data_len > 0 && data_buf != 0 as *u8) {
    if (pipe_elf_out_append(out, data_buf, data_len) != 0) {
      return -1;
    }
  }
  /* F7: pad now spans from end of data to start of symtab (was: text to symtab). */
  let pad: i32 = off_sym - off_data - data_len;
  let z: i32 = 0;
  while (z < pad) {
    if (pipe_elf_out_append(out, &z0[0], 1) != 0) {
      return -1;
    }
    z = z + 1;
  }
  let str_off: i32 = 1;
  s = 0;
  while (s < ns) {
    let ent: *u8 = &g_pipe_elf_ws_ent[0];
    unsafe {
      memset(ent, 0, 16 as usize);
    }
    pipe_elf_store_i32_bytes(ent, 0, str_off);
    let se2: *u8 = pipe_elf_sym_at(ctx_bytes, s);
    let sym_va: i32 = pipe_load_i32_le(se2, pipe_elf_sym_off_offset());
    let is_common: i32 = pipeline_elf_ctx_sym_is_common_at(ctx_bytes, s);
    if (is_common != 0) {
      let csize: i32 = pipeline_elf_ctx_sym_common_size_at(ctx_bytes, s);
      let calign: i32 = pipeline_elf_ctx_sym_common_align_at(ctx_bytes, s);
      let alg: i32 = 0;
      let ndesc: i32 = 0;
      if (csize <= 0) {
        csize = 8;
      }
      if (calign <= 0) {
        calign = 8;
      }
      /* N_UNDF|N_EXT + n_value=size + n_desc GET_COMM_ALIGN (see
       * pipe_macho_common_align_log2). Leaving n_desc=0 made Apple ld
       * size-derive __common section align to 0x8000 for 4MiB fmt paths.
       * PLATFORM: MACOS|DARWIN. */
      alg = pipe_macho_common_align_log2(calign);
      ndesc = alg * 256;
      unsafe {
        ent[4] = 1; ent[5] = 0;
        ent[6] = (ndesc & 255) as u8;
        ent[7] = ((ndesc / 256) & 255) as u8;
      }
      pipe_elf_store_i32_bytes(ent, 8, csize);
    } else {
      unsafe {
        ent[4] = 15;  /* N_SECT */
      }
      /* F7: set n_sect based on symbol's shndx. 1 = __TEXT,__text; 2 = __DATA,__const.
       * n_value for N_SECT is the address in the file's address space = section
       * addr + offset-in-section. Text section addr is 0; data section addr is
       * data_vmaddr (= code_len). */
      let sym_shndx: i32 = pipeline_elf_ctx_sym_shndx_at(ctx_bytes, s);
      let n_sect: i32 = 1;
      let n_val: i32 = sym_va;
      if (sym_shndx == pipe_elf_shnx_data()) {
        n_sect = 2;
        n_val = data_vmaddr + sym_va;
      }
      unsafe {
        ent[5] = n_sect as u8;
      }
      pipe_elf_store_i32_bytes(ent, 8, n_val);
    }
    if (pipe_elf_out_append(out, ent, 16) != 0) {
      return -1;
    }
    let offn: i32 = pipe_elf_sym_name_off(ctx_bytes, s);
    str_off = str_off + pipe_load_i32_le(se2, pipe_elf_sym_off_name_len()) + pipe_macho_link_name_extra_byte(sym_pool + (offn as usize)) + 1;
    s = s + 1;
  }
  let uu: i32 = 0;
  while (uu < nu) {
    let entu: *u8 = &g_pipe_elf_ws_ent[0];
    unsafe {
      memset(entu, 0, 16 as usize);
      entu[4] = 1;
    }
    pipe_elf_store_i32_bytes(entu, 0, str_off);
    if (pipe_elf_out_append(out, entu, 16) != 0) {
      return -1;
    }
    let sr3: i32 = pipe_elf_bss_load_i32(&g_pipe_elf_ws_und_src[0], uu);
    let und_ptr2: *u8 = pipeline_elf_ctx_reloc_sym_name_ptr(ctx_bytes, sr3);
    str_off = str_off + pipe_elf_bss_load_i32(&g_pipe_elf_ws_und_lens[0], uu) + pipe_macho_link_name_extra_byte(und_ptr2) + 1;
    uu = uu + 1;
  }
  if (pipe_elf_out_append(out, &z0[0], 1) != 0) {
    return -1;
  }
  let uscore: u8[1] = [95];
  s = 0;
  while (s < ns) {
    let off2: i32 = pipe_elf_sym_name_off(ctx_bytes, s);
    let nm: *u8 = sym_pool + (off2 as usize);
    let se3: *u8 = pipe_elf_sym_at(ctx_bytes, s);
    let nlen: i32 = pipe_load_i32_le(se3, pipe_elf_sym_off_name_len());
    if (pipe_macho_link_name_extra_byte(nm) != 0) {
      if (pipe_elf_out_append(out, &uscore[0], 1) != 0) {
        return -1;
      }
    }
    if (nlen > 0) {
      if (pipe_elf_out_append(out, nm, nlen) != 0) {
        return -1;
      }
    }
    if (pipe_elf_out_append(out, &z0[0], 1) != 0) {
      return -1;
    }
    s = s + 1;
  }
  uu = 0;
  while (uu < nu) {
    let sr4: i32 = pipe_elf_bss_load_i32(&g_pipe_elf_ws_und_src[0], uu);
    let und_ptr3: *u8 = pipeline_elf_ctx_reloc_sym_name_ptr(ctx_bytes, sr4);
    if (pipe_macho_link_name_extra_byte(und_ptr3) != 0) {
      if (pipe_elf_out_append(out, &uscore[0], 1) != 0) {
        return -1;
      }
    }
    let ul2: i32 = pipe_elf_bss_load_i32(&g_pipe_elf_ws_und_lens[0], uu);
    if (ul2 > 0 && und_ptr3 != 0 as *u8) {
      if (pipe_elf_out_append(out, und_ptr3, ul2) != 0) {
        return -1;
      }
    }
    if (pipe_elf_out_append(out, &z0[0], 1) != 0) {
      return -1;
    }
    uu = uu + 1;
  }
  let rel_type: i32 = 2;
  let rel_len: i32 = 2;
  /* F7: two-pass reloc emission — text-section relocs first (shndx != 4),
   * then data-section relocs (shndx == 4). Sequential append matches the file
   * layout: off_reloc_text then off_reloc_data. */
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
      let ri: *u8 = &g_pipe_elf_ws_ent[0];
      pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, r, &g_pipe_elf_ws_name[0]);
      let rlen2: i32 = pipeline_elf_ctx_reloc_name_len(ctx_bytes, r);
      let sym_idx: i32 = 0;
      let found_def: i32 = 0;
      let m: i32 = 0;
      while (m < ns) {
        let offm: i32 = pipe_elf_sym_name_off(ctx_bytes, m);
        let se4: *u8 = pipe_elf_sym_at(ctx_bytes, m);
        let slen: i32 = pipe_load_i32_le(se4, pipe_elf_sym_off_name_len());
        if (pipe_elf_name_eq(&g_pipe_elf_ws_name[0], rlen2, sym_pool + (offm as usize), slen) != 0) {
          sym_idx = m;
          found_def = 1;
          break;
        }
        m = m + 1;
      }
      if (found_def == 0) {
        let uslot: i32 = -1;
        let us2: i32 = 0;
        while (us2 < nu) {
          let sr5: i32 = pipe_elf_bss_load_i32(&g_pipe_elf_ws_und_src[0], us2);
          pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, sr5, &g_pipe_elf_ws_name2[0]);
          let ul3: i32 = pipe_elf_bss_load_i32(&g_pipe_elf_ws_und_lens[0], us2);
          if (pipe_elf_name_eq(&g_pipe_elf_ws_name[0], rlen2, &g_pipe_elf_ws_name2[0], ul3) != 0) {
            uslot = us2;
            break;
          }
          us2 = us2 + 1;
        }
        if (uslot < 0) {
          unsafe {
            driver_diagnostic_asm_macho_missing_und_reloc(r);
          }
          return -1;
        }
        sym_idx = ns + uslot;
      }
      let use_type: i32 = rel_type;
      let use_pcrel: i32 = 1;
      if (r < pipe_elf_table_cap()) {
        let rt: i32 = pipeline_elf_ctx_reloc_r_type_at(ctx_bytes, r);
        if (rt != 0) {
          use_type = rt;
        }
        let rp: i32 = pipeline_elf_ctx_reloc_r_pcrel_at(ctx_bytes, r);
        // product accessor: -1 means default; else override pcrel.
        if (rp != -1) {
          use_pcrel = rp;
        }
      }
      // F7 absolute64: map sentinel r_type=200 → ARM64_RELOC_UNSIGNED (type=0,
      // pcrel=0, length=3 for a quad-word pointer). Without this, vtable data
      // slots fall through to the default BRANCH26 branch reloc and ld rejects
      // ("ARM64_RELOC_BRANCH26 relocation on non-b/bl instruction").
      let eff_len: i32 = rel_len;
      if (use_type == 200) {
        use_type = 0;
        use_pcrel = 0;
        eff_len = 3;
      }
      /* r_symbolnum is 0-based after dropping dummy nlist[0]. */
      let r_sym: i32 = sym_idx;
      let word2: i32 = (r_sym & 16777215) | ((use_pcrel & 1) << 24) | (eff_len << 25) | (1 << 27) | (use_type << 28);
      let roff: i32 = pipeline_elf_ctx_reloc_offset_at(ctx_bytes, r);
      pipe_elf_store_i32_bytes(ri, 0, roff);
      pipe_elf_store_i32_bytes(ri, 4, word2);
      if (pipe_elf_out_append(out, ri, 8) != 0) {
        return -1;
      }
      r = r + 1;
    }
    pass = pass + 1;
  }
  return codegen_out_buf_len(out);
}

/**
 * Product surface: Darwin user_asm_seed_bridge weak_import target.
 * wave273 pure-owned leave.
 * PLATFORM: MACOS pure-asm (linked SHARED).
 */
#[no_mangle]
export function platform_macho_write_macho_o_to_buf(elf_ctx: *u8, out_buf: *u8): i32 {
  if (elf_ctx == 0 as *u8 || out_buf == 0 as *u8) {
    return -1;
  }
  return pipeline_macho_write_o_to_buf_c(elf_ctx, out_buf);
}
