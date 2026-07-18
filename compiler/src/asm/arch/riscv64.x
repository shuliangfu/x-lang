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
//
// See implementation.
// See implementation.
// See implementation.

const codegen_outbuf_abi = import("codegen_outbuf_abi");
const types = import("asm.types");

/** Exported function `emit_section_text`.
 * Implements `emit_section_text`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_section_text(out: *CodegenOutBuf): i32 {
  let line: u8[16] = [46, 116, 101, 120, 116, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 5);
}

/** Exported function `emit_globl`.
 * Implements `emit_globl`.
 * @param out *CodegenOutBuf
 * @param name *u8
 * @param name_len i32
 * @return i32
 */
export function emit_globl(out: *CodegenOutBuf, name: *u8, name_len: i32): i32 {
  let buf: u8[96] = [46, 103, 108, 111, 98, 108, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let k: i32 = 0;
  while (k < name_len && k < 88) {
    buf[7 + k] = name[k];
    k = k + 1;
  }
  return types.append_asm_line(out, buf, 7 + name_len);
}

/** Exported function `emit_label`.
 * Implements `emit_label`.
 * @param out *CodegenOutBuf
 * @param name *u8
 * @param name_len i32
 * @return i32
 */
export function emit_label(out: *CodegenOutBuf, name: *u8, name_len: i32): i32 {
  let i: i32 = 0;
  while (i < name_len && out.len < 8388608) {
    out.data[out.len] = name[i];
    out.len = out.len + 1;
    i = i + 1;
  }
  if (out.len < 8388608) {
    out.data[out.len] = 58;
    out.len = out.len + 1;
  }
  if (out.len < 8388608) {
    out.data[out.len] = 10;
    out.len = out.len + 1;
    return 0;
  }
  return -1;
}

/** Exported function `emit_prologue`.
 * Implements `emit_prologue`.
 * @param out *CodegenOutBuf
 * @param frame_size i32
 * @return i32
 */
export function emit_prologue(out: *CodegenOutBuf, frame_size: i32): i32 {
  if (frame_size < 16) {
    let sz: i32 = 16;
    let addi_buf: u8[48] = [97, 100, 100, 105, 32, 115, 112, 44, 32, 115, 112, 44, 32, 45, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    let n: i32 = types.format_i32_to_buf(addi_buf, 14, 8, sz);
    if (n < 0) { return -1; }
    if (types.append_asm_line(out, addi_buf, 14 + n) != 0) { return -1; }
    let sd_buf: u8[48] = [115, 100, 32, 114, 97, 44, 32, 56, 40, 115, 112, 41, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    return types.append_asm_line(out, sd_buf, 12);
  }
  let addi_buf: u8[48] = [97, 100, 100, 105, 32, 115, 112, 44, 32, 115, 112, 44, 32, 45, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(addi_buf, 14, 12, frame_size);
  if (n < 0) { return -1; }
  if (types.append_asm_line(out, addi_buf, 14 + n) != 0) { return -1; }
  let off_ra: i32 = frame_size - 8;
  let sd_ra: u8[48] = [115, 100, 32, 114, 97, 44, 32, 0, 0, 0, 0, 0, 40, 115, 112, 41, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let no: i32 = types.format_i32_to_buf(sd_ra, 7, 8, off_ra);
  if (no < 0) { return -1; }
  sd_ra[7 + no] = 40;
  sd_ra[8 + no] = 115;
  sd_ra[9 + no] = 112;
  sd_ra[10 + no] = 41;
  if (types.append_asm_line(out, sd_ra, 11 + no) != 0) { return -1; }
  let off_s0: i32 = frame_size - 16;
  let sd_s0: u8[48] = [115, 100, 32, 115, 48, 44, 32, 0, 0, 0, 0, 0, 40, 115, 112, 41, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  no = types.format_i32_to_buf(sd_s0, 7, 8, off_s0);
  if (no < 0) { return -1; }
  sd_s0[7 + no] = 40;
  sd_s0[8 + no] = 115;
  sd_s0[9 + no] = 112;
  sd_s0[10 + no] = 41;
  if (types.append_asm_line(out, sd_s0, 11 + no) != 0) { return -1; }
  let addi_s0: u8[48] = [97, 100, 100, 105, 32, 115, 48, 44, 32, 115, 112, 44, 32, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  no = types.format_i32_to_buf(addi_s0, 13, 12, frame_size);
  if (no < 0) { return -1; }
  return types.append_asm_line(out, addi_s0, 13 + no);
}

/** Exported function `emit_epilogue`.
 * Implements `emit_epilogue`.
 * @param out *CodegenOutBuf
 * @param frame_size i32
 * @return i32
 */
export function emit_epilogue(out: *CodegenOutBuf, frame_size: i32): i32 {
  if (frame_size < 16) {
    let ld_line: u8[16] = [108, 100, 32, 114, 97, 44, 32, 56, 40, 115, 112, 41, 0, 0, 0, 0];
    if (types.append_asm_line(out, ld_line, 12) != 0) { return -1; }
    let addi_line: u8[24] = [97, 100, 100, 105, 32, 115, 112, 44, 32, 115, 112, 44, 32, 49, 54, 0,
    0, 0, 0, 0, 0, 0, 0, 0];
    if (types.append_asm_line(out, addi_line, 15) != 0) { return -1; }
  } else {
    let off_s0: i32 = frame_size - 16;
    let ld_s0: u8[48] = [108, 100, 32, 115, 48, 44, 32, 0, 0, 0, 0, 0, 40, 115, 112, 41, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    let no: i32 = types.format_i32_to_buf(ld_s0, 7, 8, off_s0);
    if (no < 0) { return -1; }
    ld_s0[7 + no] = 40;
    ld_s0[8 + no] = 115;
    ld_s0[9 + no] = 112;
    ld_s0[10 + no] = 41;
    if (types.append_asm_line(out, ld_s0, 11 + no) != 0) { return -1; }
    let off_ra: i32 = frame_size - 8;
    let ld_ra: u8[48] = [108, 100, 32, 114, 97, 44, 32, 0, 0, 0, 0, 0, 40, 115, 112, 41, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    no = types.format_i32_to_buf(ld_ra, 7, 8, off_ra);
    if (no < 0) { return -1; }
    ld_ra[7 + no] = 40;
    ld_ra[8 + no] = 115;
    ld_ra[9 + no] = 112;
    ld_ra[10 + no] = 41;
    if (types.append_asm_line(out, ld_ra, 11 + no) != 0) { return -1; }
    let addi_buf: u8[48] = [97, 100, 100, 105, 32, 115, 112, 44, 32, 115, 112, 44, 32, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    let na: i32 = types.format_i32_to_buf(addi_buf, 13, 12, frame_size);
    if (na < 0) { return -1; }
    if (types.append_asm_line(out, addi_buf, 13 + na) != 0) { return -1; }
  }
  let ret_line: u8[8] = [114, 101, 116, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, ret_line, 3);
}

/** Exported function `emit_ret_imm32`.
 * Implements `emit_ret_imm32`.
 * @param out *CodegenOutBuf
 * @param imm32 i32
 * @return i32
 */
export function emit_ret_imm32(out: *CodegenOutBuf, imm32: i32): i32 {
  let buf: u8[32] = [108, 105, 32, 97, 48, 44, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(buf, 7, 12, imm32);
  if (n < 0) { return -1; }
  return types.append_asm_line(out, buf, 7 + n);
}

/** Exported function `emit_mov_imm64_to_rax`.
 * Implements `emit_mov_imm64_to_rax`.
 * @param out *CodegenOutBuf
 * @param lo i32
 * @param hi i32
 * @return i32
 */
export function emit_mov_imm64_to_rax(out: *CodegenOutBuf, lo: i32, hi: i32): i32 {
  let buf: u8[32] = [108, 105, 32, 97, 48, 44, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(buf, 7, 12, lo);
  if (n < 0) { return -1; }
  if (types.append_asm_line(out, buf, 7 + n) != 0) { return -1; }
  if (hi == 0) { return 0; }
  let slli_line: u8[24] = [115, 108, 108, 105, 32, 97, 48, 44, 32, 97, 48, 44, 32, 51, 50, 0, 0, 0,
  0, 0, 0, 0, 0, 0];
  if (types.append_asm_line(out, slli_line, 16) != 0) { return -1; }
  let srli_line: u8[24] = [115, 114, 108, 105, 32, 97, 48, 44, 32, 97, 48, 44, 32, 51, 50, 0, 0, 0,
  0, 0, 0, 0, 0, 0];
  if (types.append_asm_line(out, srli_line, 16) != 0) { return -1; }
  let hi20: i32 = (hi >> 12) & 1048575;
  let hi12: i32 = hi & 4095;
  if (hi12 >= 2048) { hi20 = hi20 + 1; }
  let lui_buf: u8[32] = [108, 117, 105, 32, 116, 48, 44, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  n = types.format_i32_to_buf(lui_buf, 8, 10, hi20);
  if (n < 0) { return -1; }
  if (types.append_asm_line(out, lui_buf, 8 + n) != 0) { return -1; }
  let addi_buf: u8[32] = [97, 100, 100, 105, 32, 116, 48, 44, 32, 116, 48, 44, 32, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  n = types.format_i32_to_buf(addi_buf, 13, 10, hi12);
  if (n < 0) { return -1; }
  if (types.append_asm_line(out, addi_buf, 13 + n) != 0) { return -1; }
  let slli_t0: u8[24] = [115, 108, 108, 105, 32, 116, 48, 44, 32, 116, 48, 44, 32, 51, 50, 0, 0, 0,
  0, 0, 0, 0, 0, 0];
  if (types.append_asm_line(out, slli_t0, 16) != 0) { return -1; }
  let add_line: u8[16] = [97, 100, 100, 32, 97, 48, 44, 32, 97, 48, 44, 32, 116, 48, 0, 0];
  return types.append_asm_line(out, add_line, 15);
}
/** Exported function `emit_mov_imm32_to_rbx`.
 * Implements `emit_mov_imm32_to_rbx`.
 * @param out *CodegenOutBuf
 * @param imm32 i32
 * @return i32
 */
export function emit_mov_imm32_to_rbx(out: *CodegenOutBuf, imm32: i32): i32 {
  let buf: u8[32] = [108, 105, 32, 97, 49, 44, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(buf, 7, 12, imm32);
  if (n < 0) { return -1; }
  return types.append_asm_line(out, buf, 7 + n);
}
/** Exported function `emit_neg_eax`.
 * Implements `emit_neg_eax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_neg_eax(out: *CodegenOutBuf): i32 {
  let line: u8[16] = [110, 101, 103, 32, 97, 48, 44, 32, 97, 48, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 10);
}
/** Exported function `emit_test_eax_eax`.
 * Implements `emit_test_eax_eax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_test_eax_eax(out: *CodegenOutBuf): i32 {
  return 0;
}
/** Exported function `emit_setz_movzbl_eax`.
 * Implements `emit_setz_movzbl_eax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_setz_movzbl_eax(out: *CodegenOutBuf): i32 {
  let line: u8[20] = [115, 101, 113, 122, 32, 97, 48, 44, 32, 97, 48, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 11);
}
/** Exported function `emit_push_rax`.
 * Implements `emit_push_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_push_rax(out: *CodegenOutBuf): i32 {
  let l1: u8[32] = [97, 100, 100, 105, 32, 115, 112, 44, 32, 115, 112, 44, 32, 45, 49, 54, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  if (types.append_asm_line(out, l1, 16) != 0) { return -1; }
  let l2: u8[20] = [115, 100, 32, 97, 48, 44, 32, 48, 40, 115, 112, 41, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, l2, 12);
}
/** Exported function `emit_pop_rbx`.
 * Implements `emit_pop_rbx`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_pop_rbx(out: *CodegenOutBuf): i32 {
  let l1: u8[20] = [108, 100, 32, 97, 49, 44, 32, 48, 40, 115, 112, 41, 0, 0, 0, 0, 0, 0, 0, 0];
  if (types.append_asm_line(out, l1, 12) != 0) { return -1; }
  let l2: u8[32] = [97, 100, 100, 105, 32, 115, 112, 44, 32, 115, 112, 44, 32, 49, 54, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, l2, 15);
}
/** Exported function `emit_pop_rax`.
 * Implements `emit_pop_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_pop_rax(out: *CodegenOutBuf): i32 {
  let l1: u8[20] = [108, 100, 32, 97, 48, 44, 32, 48, 40, 115, 112, 41, 0, 0, 0, 0, 0, 0, 0, 0];
  if (types.append_asm_line(out, l1, 12) != 0) { return -1; }
  let l2: u8[32] = [97, 100, 100, 105, 32, 115, 112, 44, 32, 115, 112, 44, 32, 49, 54, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, l2, 15);
}
/** Exported function `emit_add_rax_rbx`.
 * Implements `emit_add_rax_rbx`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_add_rax_rbx(out: *CodegenOutBuf): i32 {
  let line: u8[24] = [97, 100, 100, 32, 97, 48, 44, 32, 97, 48, 44, 32, 97, 49, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0];
  return types.append_asm_line(out, line, 14);
}
/** Exported function `emit_sub_rbx_rax_then_mov`.
 * Implements `emit_sub_rbx_rax_then_mov`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_sub_rbx_rax_then_mov(out: *CodegenOutBuf): i32 {
  let line: u8[24] = [115, 117, 98, 32, 97, 48, 44, 32, 97, 49, 44, 32, 97, 48, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0];
  return types.append_asm_line(out, line, 14);
}
/** Exported function `emit_imul_rbx_rax`.
 * Implements `emit_imul_rbx_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_imul_rbx_rax(out: *CodegenOutBuf): i32 {
  let line: u8[24] = [109, 117, 108, 32, 97, 48, 44, 32, 97, 48, 44, 32, 97, 49, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0];
  return types.append_asm_line(out, line, 14);
}
/** Exported function `emit_mov_rax_to_rbx`.
 * Implements `emit_mov_rax_to_rbx`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_mov_rax_to_rbx(out: *CodegenOutBuf): i32 {
  let line: u8[16] = [109, 118, 32, 97, 49, 44, 32, 97, 48, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 9);
}
/** Exported function `emit_cltd`.
 * Implements `emit_cltd`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_cltd(out: *CodegenOutBuf): i32 {
  return 0;
}
/** Exported function `emit_idiv_rbx`.
 * Implements `emit_idiv_rbx`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_idiv_rbx(out: *CodegenOutBuf): i32 {
  let line: u8[24] = [100, 105, 118, 32, 97, 48, 44, 32, 97, 48, 44, 32, 97, 49, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0];
  return types.append_asm_line(out, line, 14);
}
/** Exported function `emit_mov_edx_to_eax`.
 * Implements `emit_mov_edx_to_eax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_mov_edx_to_eax(out: *CodegenOutBuf): i32 {
  return 0;
}
/** Exported function `emit_mov_rbx_to_rax`.
 * Implements `emit_mov_rbx_to_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_mov_rbx_to_rax(out: *CodegenOutBuf): i32 {
  let line: u8[16] = [109, 118, 32, 97, 48, 44, 32, 97, 49, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 9);
}
/** Exported function `emit_test_setz`.
 * Implements `emit_test_setz`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_test_setz(out: *CodegenOutBuf): i32 {
  let line: u8[20] = [115, 101, 113, 122, 32, 97, 48, 44, 32, 97, 48, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 11);
}
/** Exported function `emit_cmp_rbx_rax`.
 * Comparison/utility `emit_cmp_rbx_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_cmp_rbx_rax(out: *CodegenOutBuf): i32 {
  let sub_line: u8[24] = [115, 117, 98, 32, 97, 48, 44, 32, 97, 49, 44, 32, 97, 48, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0];
  return types.append_asm_line(out, sub_line, 14);
}

/** Exported function `emit_cmp_setcc`.
 * Comparison/utility `emit_cmp_setcc`.
 * @param out *CodegenOutBuf
 * @param cc i32
 * @return i32
 */
export function emit_cmp_setcc(out: *CodegenOutBuf, cc: i32): i32 {
  let idx: i32 = cc;
  if (idx < 0) { idx = 0; }
  if (idx > 5) { idx = 5; }
  if (idx == 0) {
    let sub_line: u8[24] = [115, 117, 98, 32, 97, 48, 44, 32, 97, 49, 44, 32, 97, 48, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0];
    if (types.append_asm_line(out, sub_line, 14) != 0) { return -1; }
    let seqz_line: u8[20] = [115, 101, 113, 122, 32, 97, 48, 44, 32, 97, 48, 0, 0, 0, 0, 0, 0, 0,
    0, 0];
    return types.append_asm_line(out, seqz_line, 11);
  }
  if (idx == 1) {
    let sub_line: u8[24] = [115, 117, 98, 32, 97, 48, 44, 32, 97, 49, 44, 32, 97, 48, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0];
    if (types.append_asm_line(out, sub_line, 14) != 0) { return -1; }
    let snez_line: u8[20] = [115, 110, 101, 122, 32, 97, 48, 44, 32, 97, 48, 0, 0, 0, 0, 0, 0, 0,
    0, 0];
    return types.append_asm_line(out, snez_line, 11);
  }
  if (idx == 2) {
    let slt_line: u8[24] = [115, 108, 116, 32, 97, 48, 44, 32, 97, 49, 44, 32, 97, 48, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0];
    return types.append_asm_line(out, slt_line, 14);
  }
  if (idx == 3) {
    let slt_line: u8[24] = [115, 108, 116, 32, 97, 48, 44, 32, 97, 48, 44, 32, 97, 49, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0];
    if (types.append_asm_line(out, slt_line, 14) != 0) { return -1; }
    let xori_line: u8[24] = [120, 111, 114, 105, 32, 97, 48, 44, 32, 97, 48, 44, 32, 49, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0];
    return types.append_asm_line(out, xori_line, 14);
  }
  if (idx == 4) {
    let slt_line: u8[24] = [115, 108, 116, 32, 97, 48, 44, 32, 97, 48, 44, 32, 97, 49, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0];
    return types.append_asm_line(out, slt_line, 14);
  }
  let slt_line: u8[24] = [115, 108, 116, 32, 97, 48, 44, 32, 97, 49, 44, 32, 97, 48, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0];
  if (types.append_asm_line(out, slt_line, 14) != 0) { return -1; }
  let xori_line: u8[24] = [120, 111, 114, 105, 32, 97, 48, 44, 32, 97, 48, 44, 32, 49, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, xori_line, 14);
}
/** Exported function `emit_not_eax`.
 * Implements `emit_not_eax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_not_eax(out: *CodegenOutBuf): i32 {
  let line: u8[20] = [110, 111, 116, 32, 97, 48, 44, 32, 97, 48, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 10);
}
/** Exported function `emit_and_rbx_rax`.
 * Implements `emit_and_rbx_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_and_rbx_rax(out: *CodegenOutBuf): i32 {
  let line: u8[24] = [97, 110, 100, 32, 97, 48, 44, 32, 97, 49, 44, 32, 97, 48, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0];
  return types.append_asm_line(out, line, 14);
}
/** Exported function `emit_or_rbx_rax`.
 * Implements `emit_or_rbx_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_or_rbx_rax(out: *CodegenOutBuf): i32 {
  let line: u8[24] = [111, 114, 32, 97, 48, 44, 32, 97, 49, 44, 32, 97, 48, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0];
  return types.append_asm_line(out, line, 14);
}
/** Exported function `emit_xor_rbx_rax`.
 * Implements `emit_xor_rbx_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_xor_rbx_rax(out: *CodegenOutBuf): i32 {
  let line: u8[24] = [120, 111, 114, 32, 97, 48, 44, 32, 97, 49, 44, 32, 97, 48, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0];
  return types.append_asm_line(out, line, 14);
}
/** Exported function `emit_mov_rbx_to_ecx`.
 * Implements `emit_mov_rbx_to_ecx`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_mov_rbx_to_ecx(out: *CodegenOutBuf): i32 {
  return 0;
}
/** Exported function `emit_shl_cl_eax`.
 * Implements `emit_shl_cl_eax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_shl_cl_eax(out: *CodegenOutBuf): i32 {
  let line: u8[24] = [115, 108, 108, 32, 97, 48, 44, 32, 97, 48, 44, 32, 97, 49, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0];
  return types.append_asm_line(out, line, 14);
}
/** Exported function `emit_shr_cl_eax`.
 * Implements `emit_shr_cl_eax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_shr_cl_eax(out: *CodegenOutBuf): i32 {
  let line: u8[24] = [115, 114, 108, 32, 97, 48, 44, 32, 97, 48, 44, 32, 97, 49, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0];
  return types.append_asm_line(out, line, 14);
}
/** Exported function `emit_sar_cl_eax`.
 * Implements `emit_sar_cl_eax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_sar_cl_eax(out: *CodegenOutBuf): i32 {
  let line: u8[24] = [115, 114, 97, 32, 97, 48, 44, 32, 97, 48, 44, 32, 97, 49, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0];
  return types.append_asm_line(out, line, 14);
}
/** Exported function `emit_store_rax_to_rbp`.
 * Implements `emit_store_rax_to_rbp`.
 * @param out *CodegenOutBuf
 * @param offset i32
 * @return i32
 */
export function emit_store_rax_to_rbp(out: *CodegenOutBuf, offset: i32): i32 {
  let buf: u8[48] = [115, 100, 32, 97, 48, 44, 32, 45, 0, 0, 0, 0, 40, 115, 48, 41, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(buf, 8, 10, offset);
  if (n < 0) { return -1; }
  buf[8 + n] = 40;
  buf[9 + n] = 115;
  buf[10 + n] = 48;
  buf[11 + n] = 41;
  return types.append_asm_line(out, buf, 12 + n);
}
/** Exported function `emit_load_rbp_to_rax`.
 * Implements `emit_load_rbp_to_rax`.
 * @param out *CodegenOutBuf
 * @param offset i32
 * @return i32
 */
export function emit_load_rbp_to_rax(out: *CodegenOutBuf, offset: i32): i32 {
  let buf: u8[48] = [108, 100, 32, 97, 48, 44, 32, 45, 0, 0, 0, 0, 40, 115, 48, 41, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(buf, 8, 10, offset);
  if (n < 0) { return -1; }
  buf[8 + n] = 40;
  buf[9 + n] = 115;
  buf[10 + n] = 48;
  buf[11 + n] = 41;
  return types.append_asm_line(out, buf, 12 + n);
}
/** Exported function `emit_lea_rbp_to_rax`.
 * Implements `emit_lea_rbp_to_rax`.
 * @param out *CodegenOutBuf
 * @param offset i32
 * @return i32
 */
export function emit_lea_rbp_to_rax(out: *CodegenOutBuf, offset: i32): i32 {
  let buf: u8[48] = [97, 100, 100, 105, 32, 97, 48, 44, 32, 115, 48, 44, 32, 45, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(buf, 14, 10, offset);
  if (n < 0) { return -1; }
  return types.append_asm_line(out, buf, 14 + n);
}
/** Exported function `emit_rax_plus_rbx_scale1`.
 * Implements `emit_rax_plus_rbx_scale1`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_rax_plus_rbx_scale1(out: *CodegenOutBuf): i32 {
  let ln: u8[24] = [97, 100, 100, 32, 97, 48, 44, 32, 97, 48, 44, 32, 97, 49, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0];
  return types.append_asm_line(out, ln, 14);
}
/** a0 = a0 + a1*4：slli a1, a1, 2; add a0, a0, a1。 */
export function emit_rax_plus_rbx_scale4(out: *CodegenOutBuf): i32 {
  let slli_line: u8[24] = [115, 108, 108, 105, 32, 97, 49, 44, 32, 97, 49, 44, 32, 50, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0];
  if (types.append_asm_line(out, slli_line, 14) != 0) { return -1; }
  let add_line: u8[24] = [97, 100, 100, 32, 97, 48, 44, 32, 97, 48, 44, 32, 97, 49, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0];
  return types.append_asm_line(out, add_line, 14);
}
/** a0 += a1*8：slli a1,a1,3；add。 */
export function emit_rax_plus_rbx_scale8(out: *CodegenOutBuf): i32 {
  let slli_line: u8[24] = [115, 108, 108, 105, 32, 97, 49, 44, 32, 97, 49, 44, 32, 51, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0];
  if (types.append_asm_line(out, slli_line, 14) != 0) { return -1; }
  let add_line: u8[24] = [97, 100, 100, 32, 97, 48, 44, 32, 97, 48, 44, 32, 97, 49, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0];
  return types.append_asm_line(out, add_line, 14);
}
/** Exported function `emit_store_rax_to_rbx_indirect`.
 * Implements `emit_store_rax_to_rbx_indirect`.
 * @param out *CodegenOutBuf
 * @param elem_sz i32
 * @return i32
 */
export function emit_store_rax_to_rbx_indirect(out: *CodegenOutBuf, elem_sz: i32): i32 {
  if (elem_sz == 1) {
    let ln: u8[24] = [115, 98, 32, 97, 48, 44, 32, 48, 40, 97, 49, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0];
    return types.append_asm_line(out, ln, 12);
  }
  if (elem_sz == 4) {
    let ln: u8[24] = [115, 119, 32, 97, 48, 44, 32, 48, 40, 97, 49, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0];
    return types.append_asm_line(out, ln, 12);
  }
  let ln: u8[24] = [115, 100, 32, 97, 48, 44, 32, 48, 40, 97, 49, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0];
  return types.append_asm_line(out, ln, 12);
}
/** Exported function `emit_load_32_from_rax`.
 * Implements `emit_load_32_from_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_load_32_from_rax(out: *CodegenOutBuf): i32 {
  let line: u8[20] = [108, 119, 32, 97, 48, 44, 32, 48, 40, 97, 48, 41, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 12);
}
/** Exported function `emit_load_zext8_from_rax`.
 * Implements `emit_load_zext8_from_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_load_zext8_from_rax(out: *CodegenOutBuf): i32 {
  let line: u8[24] = [108, 98, 117, 32, 97, 48, 44, 32, 48, 40, 97, 48, 41, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0];
  return types.append_asm_line(out, line, 14);
}
/** Exported function `emit_add_imm_to_rax`.
 * Implements `emit_add_imm_to_rax`.
 * @param out *CodegenOutBuf
 * @param imm i32
 * @return i32
 */
export function emit_add_imm_to_rax(out: *CodegenOutBuf, imm: i32): i32 {
  if (imm == 0) { return 0; }
  let buf: u8[40] = [97, 100, 100, 105, 32, 97, 48, 44, 32, 97, 48, 44, 32, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(buf, 13, 12, imm);
  if (n < 0) { return -1; }
  return types.append_asm_line(out, buf, 13 + n);
}
/** Exported function `emit_load_64_from_rax`.
 * Implements `emit_load_64_from_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_load_64_from_rax(out: *CodegenOutBuf): i32 {
  let line: u8[20] = [108, 100, 32, 97, 48, 44, 32, 48, 40, 97, 48, 41, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 12);
}
/** Exported function `emit_store_rax_to_rbx_offset`.
 * Implements `emit_store_rax_to_rbx_offset`.
 * @param out *CodegenOutBuf
 * @param offset i32
 * @param store_size i32
 * @return i32
 */
export function emit_store_rax_to_rbx_offset(out: *CodegenOutBuf, offset: i32, store_size: i32): i32 {
  if (store_size == 4) {
    let buf: u8[48] = [115, 119, 32, 97, 48, 44, 32, 0, 0, 0, 0, 0, 40, 97, 49, 41, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    let n: i32 = types.format_i32_to_buf(buf, 8, 10, offset);
    if (n < 0) { return -1; }
    buf[8 + n] = 40;
    buf[9 + n] = 97;
    buf[10 + n] = 49;
    buf[11 + n] = 41;
    return types.append_asm_line(out, buf, 12 + n);
  }
  let buf: u8[48] = [115, 100, 32, 97, 48, 44, 32, 0, 0, 0, 0, 0, 40, 97, 49, 41, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(buf, 8, 10, offset);
  if (n < 0) { return -1; }
  buf[8 + n] = 40;
  buf[9 + n] = 97;
  buf[10 + n] = 49;
  buf[11 + n] = 41;
  return types.append_asm_line(out, buf, 12 + n);
}
/** Exported function `emit_mov_rax_to_arg_reg`.
 * Implements `emit_mov_rax_to_arg_reg`.
 * @param out *CodegenOutBuf
 * @param k i32
 * @return i32
 */
export function emit_mov_rax_to_arg_reg(out: *CodegenOutBuf, k: i32): i32 {
  let idx: i32 = k;
  if (idx < 0) { idx = 0; }
  if (idx > 7) { idx = 7; }
  if (idx == 0) { return 0; }
  let buf: u8[24] = [109, 118, 32, 97, 48, 44, 32, 97, 48, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0];
  let digits: u8[8] = [48, 49, 50, 51, 52, 53, 54, 55];
  buf[4] = digits[idx];
  return types.append_asm_line(out, buf, 9);
}
/** Exported function `emit_call`.
 * Implements `emit_call`.
 * @param out *CodegenOutBuf
 * @param name *u8
 * @param name_len i32
 * @return i32
 */
export function emit_call(out: *CodegenOutBuf, name: *u8, name_len: i32): i32 {
  let buf: u8[80] = [106, 97, 108, 32, 114, 97, 44, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let k: i32 = 0;
  while (k < name_len && k < 72) {
    buf[8 + k] = name[k];
    k = k + 1;
  }
  return types.append_asm_line(out, buf, 8 + name_len);
}
/** Exported function `emit_jz`.
 * Implements `emit_jz`.
 * @param out *CodegenOutBuf
 * @param label *u8
 * @param label_len i32
 * @return i32
 */
export function emit_jz(out: *CodegenOutBuf, label: *u8, label_len: i32): i32 {
  let buf: u8[72] = [98, 101, 113, 122, 32, 97, 48, 44, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let k: i32 = 0;
  while (k < label_len && k < 62) {
    buf[9 + k] = label[k];
    k = k + 1;
  }
  return types.append_asm_line(out, buf, 9 + label_len);
}

/** Exported function `emit_jeq`.
 * Implements `emit_jeq`.
 * @param out *CodegenOutBuf
 * @param label *u8
 * @param label_len i32
 * @return i32
 */
export function emit_jeq(out: *CodegenOutBuf, label: *u8, label_len: i32): i32 {
  return emit_jz(out, label, label_len);
}
/** Exported function `emit_jnz`.
 * Implements `emit_jnz`.
 * @param out *CodegenOutBuf
 * @param label *u8
 * @param label_len i32
 * @return i32
 */
export function emit_jnz(out: *CodegenOutBuf, label: *u8, label_len: i32): i32 {
  let buf: u8[72] = [98, 110, 101, 122, 32, 97, 48, 44, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let k: i32 = 0;
  while (k < label_len && k < 61) {
    buf[10 + k] = label[k];
    k = k + 1;
  }
  return types.append_asm_line(out, buf, 10 + label_len);
}
/** Exported function `emit_jmp`.
 * Implements `emit_jmp`.
 * @param out *CodegenOutBuf
 * @param label *u8
 * @param label_len i32
 * @return i32
 */
export function emit_jmp(out: *CodegenOutBuf, label: *u8, label_len: i32): i32 {
  let buf: u8[72] = [106, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let k: i32 = 0;
  while (k < label_len && k < 68) {
    buf[2 + k] = label[k];
    k = k + 1;
  }
  return types.append_asm_line(out, buf, 2 + label_len);
}

/**
* See implementation.
*/
export function emit_memset_rbp_zero(out: *CodegenOutBuf, rbp_off: i32, nbytes: i32): i32 {
  if (nbytes <= 0) {
    return 0;
  }
  if (emit_lea_rbp_to_rax(out, rbp_off) != 0) {
    return -1;
  }
  let z1: u8[24] = [109, 118, 32, 97, 49, 44, 32, 122, 101, 114, 111, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0];
  if (types.append_asm_line(out, z1, 12) != 0) {
    return -1;
  }
  let li: u8[32] = [108, 105, 32, 97, 50, 44, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n2: i32 = types.format_i32_to_buf(li, 8, 10, nbytes);
  if (n2 < 0) {
    return -1;
  }
  if (types.append_asm_line(out, li, 8 + n2) != 0) {
    return -1;
  }
  let ca: u8[24] = [99, 97, 108, 108, 32, 109, 101, 109, 115, 101, 116, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0];
  return types.append_asm_line(out, ca, 11);
}
/** Exported function `emit_ldr_sp_offset_to_wi`.
 * Implements `emit_ldr_sp_offset_to_wi`.
 * @param out *CodegenOutBuf
 * @param i i32
 * @return i32
 */
export function emit_ldr_sp_offset_to_wi(out: *CodegenOutBuf, i: i32): i32 { return 0; }
/** Exported function `emit_add_sp_imm`.
 * Implements `emit_add_sp_imm`.
 * @param out *CodegenOutBuf
 * @param n i32
 * @return i32
 */
export function emit_add_sp_imm(out: *CodegenOutBuf, n: i32): i32 {
  if (n <= 0) {
    return 0;
  }
  let buf: u8[36] = [97, 100, 100, 105, 32, 115, 112, 44, 32, 115, 112, 44, 32, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let k: i32 = types.format_i32_to_buf(buf, 13, 10, n);
  if (k < 0) {
    return -1;
  }
  return types.append_asm_line(out, buf, 13 + k);
}
/** Exported function `emit_rem_w0_w1`.
 * Implements `emit_rem_w0_w1`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_rem_w0_w1(out: *CodegenOutBuf): i32 {
  let line: u8[24] = [114, 101, 109, 32, 97, 48, 44, 32, 97, 48, 44, 32, 97, 49, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0];
  return types.append_asm_line(out, line, 14);
}
