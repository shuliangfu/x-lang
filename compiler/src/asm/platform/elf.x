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
// See implementation.
// See implementation.
// See implementation.
// See implementation.
//

const codegen_outbuf_abi = import("codegen_outbuf_abi");

/* See implementation. */
export extern function pipeline_elf_ctx_append_patch(ctx: *u8, rel32_offset: i32, name: *u8, name_len:
i32, imm_bits: i32): i32;
export extern function pipeline_elf_ctx_append_reloc(ctx: *u8, offset: i32, name: *u8, name_len: i32): i32;
export extern function pipeline_elf_ctx_add_label(ctx: *u8, name: *u8, name_len: i32, offset: i32): i32;
export extern function pipeline_elf_ctx_ensure_label(ctx: *u8, name: *u8, name_len: i32): i32;
/** See implementation for details. */
export extern function pipeline_elf_ctx_reloc_sym_name_ptr(ctx: *u8, idx: i32): *u8;
export extern function pipeline_elf_ctx_reloc_sym_name_copy64(ctx: *u8, idx: i32, dst: *u8): void;
export extern function pipeline_elf_ctx_reloc_name_len(ctx: *u8, idx: i32): i32;
/** See implementation for details. */
export extern function pipeline_elf_ctx_patch_imm_bits_at(ctx: *u8, patch_idx: i32): i32;
/* See implementation. */
export extern function pipeline_elf_ctx_reloc_offset_at(ctx: *u8, idx: i32): i32;
export extern function pipeline_elf_ctx_reloc_offset_set(ctx: *u8, idx: i32, offset: i32): void;
export extern function pipeline_elf_ctx_reloc_sidecar_reset(ctx: *u8): void;
/** See implementation for details. */
export extern function pipeline_elf_ctx_resolve_patches(ctx: *u8): i32;
export extern function pipeline_elf_ctx_reloc_shndx_at(ctx: *u8, idx: i32): i32;
export extern function pipeline_elf_ctx_sym_shndx_at(ctx: *u8, idx: i32): i32;
export extern function pipeline_elf_pgo_hot_enabled(): i32;
export extern function pipeline_elf_ctx_set_emit_hot(ctx: *u8, hot: i32): void;
export extern function pipeline_elf_ctx_append_bytes(ctx: *u8, ptr: *u8, n: i32): i32;
export extern function pipeline_elf_ctx_code_data_ptr(ctx: *u8): *u8;
export extern function pipeline_elf_write_o_pgo_to_buf(ctx: *u8, out: *CodegenOutBuf): i32;
/* See implementation. */
export extern function pipeline_elf_write_o_standard_to_buf_c(ctx: *u8, out: *CodegenOutBuf): i32;
/* See implementation. */
export extern function driver_diagnostic_asm_elf_unresolved_patch(name: *u8, name_len: i32): void;
/* See implementation. */
export extern function pipeline_elf_log_unresolved_patch(ctx: *ElfCodegenCtx, patch_idx: i32): void;

/* See implementation. */
export struct ElfLabelEntry {
  name: u8[64];
  name_len: i32;
  offset: i32;
}

/** See implementation for details. */
export struct ElfPatchEntry {
  rel32_offset: i32;
  name: u8[64];
  name_len: i32;
  /* See implementation. */
  patch_imm_bits: i32;
}

/**
* See implementation.
* See implementation.
* See implementation.
*/
export struct ElfRelocEntry {
  offset: i32;
  name_len: i32;
}

export struct ElfRelocSymName64 {
  bytes: u8[64];
}

/* See implementation. */
export struct ElfSymEntry {
  name: u8[64];
  name_len: i32;
  offset: i32;
  /** ELF st_shndx：1=.text，2=.text.hot（PGO-Lite）。 */
  sym_shndx: i32;
}

/**
* See implementation.
* See implementation.
* See implementation.
* sym_name_data + elf_sym_name_ptr。
*/
allow(padding) struct ElfCodegenCtx {
  code_len: i32;
  /**
  * See implementation.
  * See implementation.
  * See implementation.
  */
  labels: ElfLabelEntry[16384];
  num_labels: i32;
  patches: ElfPatchEntry[16384];
  num_patches: i32;
  relocs: ElfRelocEntry[16384];
  reloc_sym_names: ElfRelocSymName64[16384];
  num_relocs: i32;
  syms: ElfSymEntry[16384];
  num_syms: i32;
/** See implementation for details. */
  sym_name_len: i32;
  /* See implementation. */
  e_machine: i32;
/** See implementation for details. */
  reloc_type_r_pc32: i32;
/** See implementation for details. */
  current_frame_size: i32;
  /**
  * See implementation.
  * See implementation.
  * See implementation.
  * See implementation.
  */
  macho_leading_underscore: i32;
  /* See implementation. */
  code_hot_len: i32;
  /* See implementation. */
  emit_hot: i32;
  /* See implementation. */
  code_data: u8[8716288];
  /* See implementation. */
  code_hot_data: u8[1048576];
  /* See implementation. */
  sym_name_data: u8[131072];
}

/** Exported function `elf_to_u8`.
 * Implements `elf_to_u8`.
 * @param val i32
 * @return u8
 */
export function elf_to_u8(val: i32): u8 {
  return val as u8;
}

/** Exported function `elf_u32_byte_at`.
 * Implements `elf_u32_byte_at`.
 * @param val i64
 * @param byte_idx i32
 * @return u8
 */
export function elf_u32_byte_at(val: i64, byte_idx: i32): u8 {
  let u: u32 = val as u32;
  if (byte_idx == 0) {
    return (u & 255) as u8;
  }
  if (byte_idx == 1) {
    return ((u >> 8) & 255) as u8;
  }
  if (byte_idx == 2) {
    return ((u >> 16) & 255) as u8;
  }
  return ((u >> 24) & 255) as u8;
}

/**
* See implementation.
* See implementation.
* See implementation.
*/
export function elf_clear_u8_64(ptr: *u8): void {
  let i: i32 = 0;
  while (i < 64) {
    ptr[i] = 0;
    i = i + 1;
  }
}

/**
* See implementation.
* See implementation.
* See implementation.
*/
export function elf_copy_u8_n(dst: *u8, src: *u8, n: i32): void {
  let i: i32 = 0;
  while (i < n && i < 64) {
    dst[i] = src[i];
    i = i + 1;
  }
}

/** See implementation for details. */
export extern function pipeline_elf_label_mod_scope_reset(): void;

/** Exported function `elf_ctx_reset`.
 * Implements `elf_ctx_reset`.
 * @param ctx *ElfCodegenCtx
 * @return void
 */
export function elf_ctx_reset(ctx: *ElfCodegenCtx): void {
  ctx.code_len = 0;
  ctx.code_hot_len = 0;
  ctx.emit_hot = 0;
  ctx.num_labels = 0;
  ctx.num_patches = 0;
  ctx.num_relocs = 0;
  ctx.num_syms = 0;
  ctx.sym_name_len = 0;
  ctx.macho_leading_underscore = 0;
  pipeline_elf_label_mod_scope_reset();
  pipeline_elf_ctx_reloc_sidecar_reset(ctx as *u8);
}

/** Exported function `elf_section_code_len`.
 * Query helper `elf_section_code_len`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function elf_section_code_len(ctx: *ElfCodegenCtx): i32 {
  if (pipeline_elf_pgo_hot_enabled() != 0 && ctx.emit_hot != 0) {
    return ctx.code_hot_len;
  }
  return ctx.code_len;
}

/** Exported function `append_elf_bytes`.
 * Implements `append_elf_bytes`.
 * @param ctx *ElfCodegenCtx
 * @param ptr *u8
 * @param n i32
 * @return i32
 */
export function append_elf_bytes(ctx: *ElfCodegenCtx, ptr: *u8, n: i32): i32 {
  return pipeline_elf_ctx_append_bytes(ctx as *u8, ptr, n);
}

/** Exported function `elf_pad_code_to_4`.
 * Implements `elf_pad_code_to_4`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function elf_pad_code_to_4(ctx: *ElfCodegenCtx): i32 {
  let pad: u8[1] = [0];
  while (elf_section_code_len(ctx) % 4 != 0) {
    if (append_elf_bytes(ctx, pad, 1) != 0) {
      return -1;
    }
  }
  return 0;
}

/** Exported function `elf_add_label`.
 * Implements `elf_add_label`.
 * @param ctx *ElfCodegenCtx
 * @param name *u8
 * @param name_len i32
 * @return i32
 */
export function elf_add_label(ctx: *ElfCodegenCtx, name: *u8, name_len: i32): i32 {
  return pipeline_elf_ctx_add_label(ctx as *u8, name, name_len, elf_section_code_len(ctx));
}

/** Exported function `elf_ensure_label_slot`.
 * Implements `elf_ensure_label_slot`.
 * @param ctx *ElfCodegenCtx
 * @param name *u8
 * @param name_len i32
 * @return i32
 */
export function elf_ensure_label_slot(ctx: *ElfCodegenCtx, name: *u8, name_len: i32): i32 {
  return pipeline_elf_ctx_ensure_label(ctx as *u8, name, name_len);
}

/** Exported function `elf_add_patch`.
 * Implements `elf_add_patch`.
 * @param ctx *ElfCodegenCtx
 * @param rel32_offset i32
 * @param name *u8
 * @param name_len i32
 * @return i32
 */
export function elf_add_patch(ctx: *ElfCodegenCtx, rel32_offset: i32, name: *u8, name_len: i32): i32 {
  return elf_add_patch_with_bits(ctx, rel32_offset, name, name_len, 0);
}

/* See implementation. */
export function elf_add_patch_with_bits(ctx: *ElfCodegenCtx, rel32_offset: i32, name: *u8, name_len: i32,
imm_bits: i32): i32 {
  return pipeline_elf_ctx_append_patch(ctx as *u8, rel32_offset, name, name_len, imm_bits);
}

/** Exported function `elf_add_reloc`.
 * Implements `elf_add_reloc`.
 * @param ctx *ElfCodegenCtx
 * @param offset i32
 * @param name *u8
 * @param name_len i32
 * @return i32
 */
export function elf_add_reloc(ctx: *ElfCodegenCtx, offset: i32, name: *u8, name_len: i32): i32 {
  return pipeline_elf_ctx_append_reloc(ctx as *u8, offset, name, name_len);
}

/**
* See implementation.
* See implementation.
* See implementation.
*/
export function elf_sym_name_ptr(ctx: *ElfCodegenCtx, sym_idx: i32): *u8 {
  let off: i32 = 0;
  let i: i32 = 0;
  while (i < sym_idx) {
    off = off + ctx.syms[i].name_len;
    i = i + 1;
  }
  return &ctx.sym_name_data[off];
}

/**
* See implementation.
* See implementation.
* See implementation.
*/
export function elf_add_sym(ctx: *ElfCodegenCtx, name: *u8, name_len: i32, offset: i32): i32 {
  if (ctx.num_syms >= 16384) {
    return -1;
  }
  let copy_len: i32 = name_len;
  if (copy_len > 64) {
    copy_len = 64;
  }
  if (copy_len < 0) {
    copy_len = 0;
  }
  if (ctx.sym_name_len + copy_len > 131072) {
    return -1;
  }
  let k: i32 = 0;
  while (k < copy_len) {
    ctx.sym_name_data[ctx.sym_name_len] = name[k];
    ctx.sym_name_len = ctx.sym_name_len + 1;
    k = k + 1;
  }
  ctx.syms[ctx.num_syms].name_len = copy_len;
  ctx.syms[ctx.num_syms].offset = offset;
  if (pipeline_elf_pgo_hot_enabled() != 0 && ctx.emit_hot != 0) {
    ctx.syms[ctx.num_syms].sym_shndx = 2;
  } else if (pipeline_elf_pgo_hot_enabled() != 0) {
    ctx.syms[ctx.num_syms].sym_shndx = 3;
  } else {
    ctx.syms[ctx.num_syms].sym_shndx = 1;
  }
  ctx.num_syms = ctx.num_syms + 1;
  return 0;
}

/** Exported function `elf_name_eq`.
 * Implements `elf_name_eq`.
 * @param a u8[64]
 * @param a_len i32
 * @param b u8[64]
 * @param b_len i32
 * @return i32
 */
export function elf_name_eq(a: u8[64], a_len: i32, b: u8[64], b_len: i32): i32 {
  if (a_len != b_len) {
    return 0;
  }
  let i: i32 = 0;
  while (i < a_len) {
    if (a[i] != b[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/**
* See implementation.
* See implementation.
*/
export function elf_name_eq_arr_to_pool(name: u8[64], name_len: i32, pool: *u8, pool_len: i32): i32 {
  if (name_len != pool_len) {
    return 0;
  }
  let i: i32 = 0;
  while (i < name_len) {
    if (name[i] != pool[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/** Exported function `elf_reloc_target_is_defined`.
 * Implements `elf_reloc_target_is_defined`.
 * @param ctx *ElfCodegenCtx
 * @param reloc_idx i32
 * @return i32
 */
export function elf_reloc_target_is_defined(ctx: *ElfCodegenCtx, reloc_idx: i32): i32 {
  let m: i32 = 0;
  let r_sym_buf: u8[64] = [];
  pipeline_elf_ctx_reloc_sym_name_copy64(ctx as *u8, reloc_idx, &r_sym_buf[0]);
  let rlen: i32 = pipeline_elf_ctx_reloc_name_len(ctx as *u8, reloc_idx);
  while (m < ctx.num_syms) {
    if (elf_name_eq_arr_to_pool(r_sym_buf, rlen, elf_sym_name_ptr(ctx, m), ctx.syms[m].name_len) != 0) {
      return 1;
    }
    m = m + 1;
  }
  return 0;
}

/**
 * See implementation.
* See implementation.
* See implementation.
*/
export function elf_infer_patch_imm_bits_from_code(ctx: *ElfCodegenCtx, rel32_offset: i32): i32 {
  if (rel32_offset < 0 || rel32_offset + 3 >= ctx.code_len) {
    return 0;
  }
  /* See implementation. */
  let op8: i32 = ctx.code_data[rel32_offset + 3] & 255;
  if (op8 == 52 || op8 == 53) {
    return 19;
  }
  if (op8 == 84) {
    return 19;
  }
  if (op8 == 20 || op8 == 148) {
    return 26;
  }
  return 0;
}

/**
* See implementation.
* See implementation.
*/
export function elf_read_u32_le(ctx: *ElfCodegenCtx, off: i32): i32 {
  if (off < 0 || off + 3 >= ctx.code_len) {
    return 0;
  }
  let b0: i32 = ctx.code_data[off] & 255;
  let b1: i32 = ctx.code_data[off + 1] & 255;
  let b2: i32 = ctx.code_data[off + 2] & 255;
  let b3: i32 = ctx.code_data[off + 3] & 255;
  let w1: i32 = b1 << 8;
  let w2: i32 = b2 << 16;
  let w3: i32 = b3 << 24;
  return b0 | w1 | w2 | w3;
}

/** Exported function `elf_write_u32_le`.
 * Write path helper `elf_write_u32_le`.
 * @param ctx *ElfCodegenCtx
 * @param off i32
 * @param word i32
 * @return void
 */
export function elf_write_u32_le(ctx: *ElfCodegenCtx, off: i32, word: i32): void {
  if (off < 0 || off + 3 >= ctx.code_len) {
    return;
  }
  ctx.code_data[off] = elf_u32_byte_at(word, 0);
  ctx.code_data[off + 1] = elf_u32_byte_at(word, 1);
  ctx.code_data[off + 2] = elf_u32_byte_at(word, 2);
  ctx.code_data[off + 3] = elf_u32_byte_at(word, 3);
}

/** Exported function `elf_resolve_patches`.
 * Implements `elf_resolve_patches`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function elf_resolve_patches(ctx: *ElfCodegenCtx): i32 {
  return pipeline_elf_ctx_resolve_patches(ctx as *u8);
}

/** Exported function `elf_append`.
 * Implements `elf_append`.
 * @param out *CodegenOutBuf
 * @param ptr *u8
 * @param n i32
 * @return i32
 */
export function elf_append(out: *CodegenOutBuf, ptr: *u8, n: i32): i32 {
  let i: i32 = 0;
  while (i < n && out.length < 9437184) {
    out.data[out.length] = ptr[i];
    out.length = out.length + 1;
    i = i + 1;
  }
  if (i < n) {
    return -1;
  }
  return 0;
}

/** Exported function `write_elf_o_to_buf`.
 * Write path helper `write_elf_o_to_buf`.
 * @param ctx *ElfCodegenCtx
 * @param out *CodegenOutBuf
 * @return i32
 */
export function write_elf_o_to_buf(ctx: *ElfCodegenCtx, out: *CodegenOutBuf): i32 {
  return pipeline_elf_write_o_standard_to_buf_c(ctx as *u8, out);
}
