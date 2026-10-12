// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// See implementation.
//
// See implementation.
// .obj,
// See implementation.
// 62).
//
// See implementation.
// elf_name_eq_arr_to_pool).
//

const codegen_outbuf_abi = import("codegen_outbuf_abi");
const elf = import("platform.elf");

/* See implementation. */
export extern function pipeline_elf_ctx_reloc_sym_name_copy64(ctx: *u8, idx: i32, dst: *u8): void;
export extern function pipeline_elf_ctx_reloc_name_len(ctx: *u8, idx: i32): i32;
export extern function pipeline_elf_ctx_reloc_offset_at(ctx: *u8, idx: i32): i32;
export extern function pipeline_elf_ctx_reloc_shndx_at(ctx: *u8, idx: i32): i32;
export extern function pipeline_elf_ctx_reloc_r_type_at(ctx: *u8, r: i32): i32;
export extern function pipeline_elf_ctx_emit_data_len(ctx: *u8): i32;
export extern function pipeline_elf_ctx_data_data_ptr(ctx: *u8): *u8;

/** Exported function `coff_append`.
 * Implements `coff_append`.
 * @param out *CodegenOutBuf
 * @param ptr *u8
 * @param n i32
 * @return i32
 */
export function coff_append(out: *CodegenOutBuf, ptr: *u8, n: i32): i32 {
  let i: i32 = 0;
  while (i < n && out.length < 9437184) {
    out.data[out.length] = ptr[i];
    out.length = out.length + 1;
    i = i + 1;
  }
  if (i < n) { return -1; }
  return 0;
}

/** Store a little-endian i32 into buf[at..at+3]. PLATFORM: SHARED. */
function coff_put32(buf: *u8, at: i32, v: i32): void {
  buf[at] = elf.elf_to_u8(v);
  buf[at + 1] = elf.elf_to_u8(v >> 8);
  buf[at + 2] = elf.elf_to_u8(v >> 16);
  buf[at + 3] = elf.elf_to_u8(v >> 24);
}

/**
 * 1 when reloc r patches a .data slot: ELF shndx 4, or the absolute64
 * sentinel (r_type 200), which every caller uses only for data slots. On
 * Windows the shndx override lands in a second BSS copy of the leftover pabi,
 * so the shndx sidecar alone still reads .text there. Twin of the seed's
 * seed_coff_reloc_is_data. PLATFORM: WINDOWS.
 */
function coff_reloc_is_data(ctx: *ElfCodegenCtx, r: i32, has_data: i32): i32 {
  if (has_data == 0) {
    return 0;
  }
  let sh: i32 = 0;
  let rt: i32 = 0;
  unsafe {
    sh = pipeline_elf_ctx_reloc_shndx_at(ctx as *u8, r);
    rt = pipeline_elf_ctx_reloc_r_type_at(ctx as *u8, r);
  }
  if (sh == 4 || rt == 200) {
    return 1;
  }
  return 0;
}

/**
 * Write a PE/COFF .obj from ElfCodegenCtx into CodegenOutBuf.
 * Twin of seeds/user_asm_seed_bridge.from_x.c::seed_platform_coff_write_coff_o_to_buf
 * (the seed stays product authority until this .x replaces it; keep both in step).
 * - reloc names missing from syms are appended as EXTERNAL UNDEF (sym_shndx 0);
 * - ELF shndx 4 (module data) becomes COFF section 2 `.data`, filled from the
 *   baker's data buffer;
 * - w1506 (10.28): relocs that patch a .data slot (coff_reloc_is_data) go in
 *   the .data relocation table as IMAGE_REL_AMD64_ADDR64; .text relocs stay REL32 except the
 *   absolute64 sentinel (r_type 200), which is ADDR64 too;
 * - COMMON symbols (ELF SHN_COMMON 65522) emit as IMAGE_SYM_UNDEFINED
 *   + Value=size + EXTERNAL so the linker allocates writable BSS.
 * @param ctx *ElfCodegenCtx — filled ELF codegen context (e_machine must be 62)
 * @param out *CodegenOutBuf — destination object bytes
 * @return i32 — byte length on success, -1 on failure
 * PLATFORM: WINDOWS leftover-PE / SHARED COFF cross-emit
 */
export function write_coff_o_to_buf(ctx: *ElfCodegenCtx, out: *CodegenOutBuf): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (ctx.e_machine != 62) {
      return -1;
    }
    let code_len: i32 = ctx.code_len;
    if (code_len < 0) {
      return -1;
    }
    /* align up to 4: mask low 2 bits; (-4) is i32 0xFFFFFFFC. */
    let align4: i32 = (code_len + 3) & (-4);
    let num_relocs: i32 = ctx.num_relocs;
    let num_syms: i32 = ctx.num_syms;
    if (num_relocs < 0 || num_syms < 0) {
      return -1;
    }
    let s: i32 = 0;
    let r: i32 = 0;
    /* Reloc names missing from syms become EXTERNAL UNDEF; otherwise the
     * COFF reloc sym_idx stays 0 (.text) and calls resolve to self. */
    while (r < num_relocs) {
      let r_sym_buf: u8[256] = [];
      pipeline_elf_ctx_reloc_sym_name_copy64(ctx as *u8, r, &r_sym_buf[0]);
      let rlen: i32 = pipeline_elf_ctx_reloc_name_len(ctx as *u8, r);
      if (rlen > 0 && rlen <= 256) {
        let found: i32 = 0;
        let m: i32 = 0;
        while (m < num_syms) {
          if (elf.elf_name_eq_arr_to_pool(r_sym_buf, rlen, elf.elf_sym_name_ptr(ctx, m),
              ctx.syms[m].name_len) != 0) {
            found = 1;
            break;
          }
          m = m + 1;
        }
        if (found == 0 && num_syms < 16384) {
          let snl: i32 = ctx.sym_name_len;
          if (snl < 0) {
            snl = 0;
          }
          if (snl + rlen <= 131072) {
            let k: i32 = 0;
            while (k < rlen) {
              ctx.sym_name_data[snl + k] = r_sym_buf[k];
              k = k + 1;
            }
            ctx.sym_name_len = snl + rlen;
            ctx.syms[num_syms].name_len = rlen;
            ctx.syms[num_syms].offset = 0;
            ctx.syms[num_syms].sym_shndx = 0;
            num_syms = num_syms + 1;
            ctx.num_syms = num_syms;
          }
        }
      }
      r = r + 1;
    }
    /* One data buffer, the baker's. shndx 4 without a payload still needs a
     * .data section so the symbol is not placed at the start of .text. */
    let data_len: i32 = pipeline_elf_ctx_emit_data_len(ctx as *u8);
    if (data_len < 0) {
      data_len = 0;
    }
    if (data_len > 65536) {
      data_len = 65536;
    }
    let data_ptr: *u8 = pipeline_elf_ctx_data_data_ptr(ctx as *u8);
    if (data_len > 0 && data_ptr == 0 as *u8) {
      return -1;
    }
    let has_data: i32 = 0;
    if (data_len > 0) {
      has_data = 1;
    }
    if (has_data == 0) {
      s = 0;
      while (s < num_syms) {
        if (ctx.syms[s].sym_shndx == 4) {
          has_data = 1;
          break;
        }
        s = s + 1;
      }
    }
    let align_data: i32 = 0;
    let nsec: i32 = 1;
    if (has_data != 0) {
      align_data = (data_len + 3) & (-4);
      nsec = 2;
    }
    let n_text_rel: i32 = 0;
    let n_data_rel: i32 = 0;
    r = 0;
    while (r < num_relocs) {
      if (coff_reloc_is_data(ctx, r, has_data) != 0) {
        n_data_rel = n_data_rel + 1;
      } else {
        n_text_rel = n_text_rel + 1;
      }
      r = r + 1;
    }
    let reloc_size: i32 = num_relocs * 10;
    let num_coff_syms: i32 = 2 + num_syms;
    let symtab_size: i32 = num_coff_syms * 18;
    let strtab_used: i32 = 4;
    s = 0;
    while (s < num_syms) {
      strtab_used = strtab_used + ctx.syms[s].name_len + 1;
      s = s + 1;
    }
    /* File header (20) + one 40-byte header per section. */
    let ptr_raw: i32 = 20 + 40 * nsec;
    let ptr_data: i32 = ptr_raw + align4;
    let ptr_reloc: i32 = ptr_raw + align4;
    if (has_data != 0) {
      ptr_reloc = ptr_data + align_data;
    }
    let ptr_reloc_data: i32 = ptr_reloc + n_text_rel * 10;
    let ptr_sym: i32 = ptr_reloc + reloc_size;

    out.length = 0;

    let fh: u8[20] = [];
    fh[0] = elf.elf_to_u8(100);
    fh[1] = elf.elf_to_u8(134);
    fh[2] = elf.elf_to_u8(nsec);
    coff_put32(&fh[0], 8, ptr_sym);
    coff_put32(&fh[0], 12, num_coff_syms);
    if (coff_append(out, &fh[0], 20) != 0) { return -1; }

    let sh: u8[40] = [];
    sh[0] = 46;
    sh[1] = 116;
    sh[2] = 101;
    sh[3] = 120;
    sh[4] = 116;
    coff_put32(&sh[0], 16, align4);
    coff_put32(&sh[0], 20, ptr_raw);
    coff_put32(&sh[0], 24, ptr_reloc);
    sh[32] = elf.elf_to_u8(n_text_rel);
    sh[33] = elf.elf_to_u8(n_text_rel >> 8);
    sh[36] = 32;
    sh[38] = 80;
    sh[39] = 96;
    if (coff_append(out, &sh[0], 40) != 0) { return -1; }

    /* .data: CNT_INITIALIZED_DATA | ALIGN_4BYTES | MEM_READ | MEM_WRITE
     * = 0xC0300040; writable because a module array is assigned. */
    if (has_data != 0) {
      let dh: u8[40] = [];
      dh[0] = 46;
      dh[1] = 100;
      dh[2] = 97;
      dh[3] = 116;
      dh[4] = 97;
      coff_put32(&dh[0], 8, data_len);
      coff_put32(&dh[0], 16, align_data);
      coff_put32(&dh[0], 20, ptr_data);
      if (n_data_rel > 0) {
        coff_put32(&dh[0], 24, ptr_reloc_data);
        dh[32] = elf.elf_to_u8(n_data_rel);
        dh[33] = elf.elf_to_u8(n_data_rel >> 8);
      }
      dh[36] = 64;
      dh[38] = 48;
      dh[39] = 192;
      if (coff_append(out, &dh[0], 40) != 0) { return -1; }
    }

    if (code_len > 0 && coff_append(out, &ctx.code_data[0], code_len) != 0) { return -1; }
    let zero: u8[1] = [];
    s = 0;
    while (s < align4 - code_len) {
      if (coff_append(out, &zero[0], 1) != 0) { return -1; }
      s = s + 1;
    }
    if (has_data != 0) {
      if (data_len > 0 && coff_append(out, data_ptr, data_len) != 0) { return -1; }
      s = 0;
      while (s < align_data - data_len) {
        if (coff_append(out, &zero[0], 1) != 0) { return -1; }
        s = s + 1;
      }
    }

    /* Pass 0 writes the .text table, pass 1 the .data table. */
    let pass: i32 = 0;
    while (pass < 2) {
      r = 0;
      while (r < num_relocs) {
        let is_data_rel: i32 = coff_reloc_is_data(ctx, r, has_data);
        if (is_data_rel == pass) {
          let rel: u8[10] = [];
          let sym_idx: i32 = 0;
          let m: i32 = 0;
          let r_sym_buf: u8[256] = [];
          pipeline_elf_ctx_reloc_sym_name_copy64(ctx as *u8, r, &r_sym_buf[0]);
          let rlen: i32 = pipeline_elf_ctx_reloc_name_len(ctx as *u8, r);
          while (m < num_syms && rlen > 0) {
            if (elf.elf_name_eq_arr_to_pool(r_sym_buf, rlen, elf.elf_sym_name_ptr(ctx, m),
                ctx.syms[m].name_len) != 0) {
              sym_idx = 2 + m;
              break;
            }
            m = m + 1;
          }
          coff_put32(&rel[0], 0, pipeline_elf_ctx_reloc_offset_at(ctx as *u8, r));
          coff_put32(&rel[0], 4, sym_idx);
          /* IMAGE_REL_AMD64_ADDR64 = 1, IMAGE_REL_AMD64_REL32 = 4. */
          rel[8] = 4;
          if (is_data_rel != 0 || pipeline_elf_ctx_reloc_r_type_at(ctx as *u8, r) == 200) {
            rel[8] = 1;
          }
          if (coff_append(out, &rel[0], 10) != 0) { return -1; }
        }
        r = r + 1;
      }
      pass = pass + 1;
    }

    /* IMAGE_SYMBOL (18B): Name[8] | Value[4] | SectionNumber[2] | Type[2] |
     * StorageClass[1] | NumberOfAuxSymbols[1]. */
    let sym_sec: u8[18] = [];
    sym_sec[0] = 46;
    sym_sec[1] = 116;
    sym_sec[2] = 101;
    sym_sec[3] = 120;
    sym_sec[4] = 116;
    sym_sec[12] = 1;
    sym_sec[16] = 3;
    sym_sec[17] = 1;
    if (coff_append(out, &sym_sec[0], 18) != 0) { return -1; }
    let aux: u8[18] = [];
    coff_put32(&aux[0], 0, align4);
    aux[4] = elf.elf_to_u8(n_text_rel);
    aux[5] = elf.elf_to_u8(n_text_rel >> 8);
    aux[14] = 1;
    if (coff_append(out, &aux[0], 18) != 0) { return -1; }

    let str_off: i32 = 4;
    s = 0;
    while (s < num_syms) {
      let ent: u8[18] = [];
      let shx: i32 = ctx.syms[s].sym_shndx;
      coff_put32(&ent[0], 4, str_off);
      // Value: function = .text offset; data = data-buffer offset;
      // COMMON = payload size (pipeline_elf_ctx_add_common_sym).
      coff_put32(&ent[0], 8, ctx.syms[s].offset);
      ent[16] = 2;
      if (shx == 65522) {
        // COMMON: IMAGE_SYM_UNDEFINED + Value=size + EXTERNAL.
        ent[12] = 0;
      } else if (shx == 0) {
        // EXTERNAL UNDEF function.
        ent[12] = 0;
        ent[14] = 32;
      } else if (has_data != 0 && shx == 4) {
        ent[12] = 2;
      } else {
        ent[12] = 1;
        ent[14] = 32;
      }
      if (coff_append(out, &ent[0], 18) != 0) { return -1; }
      str_off = str_off + ctx.syms[s].name_len + 1;
      s = s + 1;
    }

    let str_size: u8[4] = [];
    coff_put32(&str_size[0], 0, strtab_used);
    if (coff_append(out, &str_size[0], 4) != 0) { return -1; }
    s = 0;
    while (s < num_syms) {
      if (ctx.syms[s].name_len > 0
          && coff_append(out, elf.elf_sym_name_ptr(ctx, s), ctx.syms[s].name_len) != 0) {
        return -1;
      }
      if (coff_append(out, &zero[0], 1) != 0) { return -1; }
      s = s + 1;
    }
    return out.length;
  }
}
