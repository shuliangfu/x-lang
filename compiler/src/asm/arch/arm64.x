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

const codegen_outbuf_abi = import("codegen_outbuf_abi");
const types = import("asm.types");

/** Exported function `emit_section_text`.
 * Implements `emit_section_text`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_section_text(out: *CodegenOutBuf): i32 {
  let line: u8[16] = [];
  line[0] = 46;
  line[1] = 116;
  line[2] = 101;
  line[3] = 120;
  line[4] = 116;
  return types.append_asm_line(out, line, 5);
}

/** Exported function `emit_globl`.
 * Implements `emit_globl`.
 * @param out *CodegenOutBuf
 * @param name u8[64]
 * @param name_len i32
 * @return i32
 */
export function emit_globl(out: *CodegenOutBuf, name: u8[64], name_len: i32): i32 {
  let buf: u8[96] = [];
  buf[0] = 46;
  buf[1] = 103;
  buf[2] = 108;
  buf[3] = 111;
  buf[4] = 98;
  buf[5] = 108;
  buf[6] = 32;
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
  let stp_line: u8[32] = [115, 116, 112, 32, 120, 50, 57, 44, 32, 120, 51, 48, 44, 32, 91, 115,
  112, 44, 32, 35, 45, 49, 54, 93, 33, 0, 0, 0, 0, 0, 0, 0];
  if (types.append_asm_line(out, stp_line, 25) != 0) {
    return -1;
  }
  let mov_line: u8[20] = [109, 111, 118, 32, 120, 50, 57, 44, 32, 115, 112, 0, 0, 0, 0, 0, 0, 0, 0,
  0];
  if (types.append_asm_line(out, mov_line, 11) != 0) {
    return -1;
  }
  let sub_buf: u8[40] = [115, 117, 98, 32, 115, 112, 44, 32, 115, 112, 44, 32, 35, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(sub_buf, 13, 12, frame_size);
  if (n < 0) {
    return -1;
  }
  return types.append_asm_line(out, sub_buf, 13 + n);
}

/** Exported function `emit_epilogue`.
 * Implements `emit_epilogue`.
 * @param out *CodegenOutBuf
 * @param frame_size i32
 * @return i32
 */
export function emit_epilogue(out: *CodegenOutBuf, frame_size: i32): i32 {
  let add_buf: u8[40] = [97, 100, 100, 32, 115, 112, 44, 32, 115, 112, 44, 32, 35, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(add_buf, 13, 12, frame_size);
  if (n < 0) {
    return -1;
  }
  if (types.append_asm_line(out, add_buf, 13 + n) != 0) {
    return -1;
  }
  let ldp_line: u8[32] = [108, 100, 112, 32, 120, 50, 57, 44, 32, 120, 51, 48, 44, 32, 91, 115,
  112, 93, 44, 32, 35, 49, 54, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  if (types.append_asm_line(out, ldp_line, 23) != 0) {
    return -1;
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
  let buf: u8[32] = [109, 111, 118, 32, 119, 48, 44, 32, 35, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(buf, 9, 12, imm32);
  if (n < 0) {
    return -1;
  }
  return types.append_asm_line(out, buf, 9 + n);
}

/** Exported function `emit_mov_imm32_to_rbx`.
 * Implements `emit_mov_imm32_to_rbx`.
 * @param out *CodegenOutBuf
 * @param imm32 i32
 * @return i32
 */
export function emit_mov_imm32_to_rbx(out: *CodegenOutBuf, imm32: i32): i32 {
  let buf: u8[32] = [109, 111, 118, 32, 119, 49, 44, 32, 35, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(buf, 9, 12, imm32);
  if (n < 0) {
    return -1;
  }
  return types.append_asm_line(out, buf, 9 + n);
}

/** Exported function `emit_mov_imm64_to_rax`.
 * Implements `emit_mov_imm64_to_rax`.
 * @param out *CodegenOutBuf
 * @param lo i32
 * @param hi i32
 * @return i32
 */
export function emit_mov_imm64_to_rax(out: *CodegenOutBuf, lo: i32, hi: i32): i32 {
  let lo0: i32 = lo & 65535;
  let lo1: i32 = (lo >> 16) & 65535;
  let hi0: i32 = hi & 65535;
  let hi1: i32 = (hi >> 16) & 65535;
  let buf: u8[40] = [109, 111, 118, 122, 32, 120, 48, 44, 32, 35, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(buf, 10, 6, lo0);
  if (n < 0) { return -1; }
  if (types.append_asm_line(out, buf, 10 + n) != 0) { return -1; }
  let movk: u8[32] = [109, 111, 118, 107, 32, 120, 48, 44, 32, 35, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  n = types.format_i32_to_buf(movk, 10, 6, lo1);
  if (n < 0) { return -1; }
  movk[10 + n] = 44;
  movk[11 + n] = 32;
  movk[12 + n] = 76;
  movk[13 + n] = 83;
  movk[14 + n] = 76;
  movk[15 + n] = 32;
  movk[16 + n] = 35;
  movk[17 + n] = 49;
  movk[18 + n] = 54;
  if (types.append_asm_line(out, movk, 19 + n) != 0) { return -1; }
  n = types.format_i32_to_buf(movk, 10, 6, hi0);
  if (n < 0) { return -1; }
  movk[10 + n] = 44;
  movk[11 + n] = 32;
  movk[12 + n] = 76;
  movk[13 + n] = 83;
  movk[14 + n] = 76;
  movk[15 + n] = 32;
  movk[16 + n] = 35;
  movk[17 + n] = 51;
  movk[18 + n] = 50;
  if (types.append_asm_line(out, movk, 19 + n) != 0) { return -1; }
  n = types.format_i32_to_buf(movk, 10, 6, hi1);
  if (n < 0) { return -1; }
  movk[10 + n] = 44;
  movk[11 + n] = 32;
  movk[12 + n] = 76;
  movk[13 + n] = 83;
  movk[14 + n] = 76;
  movk[15 + n] = 32;
  movk[16 + n] = 35;
  movk[17 + n] = 52;
  movk[18 + n] = 56;
  return types.append_asm_line(out, movk, 19 + n);
}

/** Exported function `emit_neg_eax`.
 * Implements `emit_neg_eax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_neg_eax(out: *CodegenOutBuf): i32 {
  let line: u8[16] = [110, 101, 103, 32, 119, 48, 44, 32, 119, 48, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 10);
}

/** Exported function `emit_test_eax_eax`.
 * Implements `emit_test_eax_eax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_test_eax_eax(out: *CodegenOutBuf): i32 {
  let line: u8[16] = [99, 109, 112, 32, 119, 48, 44, 32, 35, 48, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 10);
}

/** Exported function `emit_setz_movzbl_eax`.
 * Implements `emit_setz_movzbl_eax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_setz_movzbl_eax(out: *CodegenOutBuf): i32 {
  let line: u8[16] = [99, 115, 101, 116, 32, 119, 48, 44, 32, 101, 113, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 11);
}

/** Exported function `emit_cmp_rbx_rax`.
 * Comparison/utility `emit_cmp_rbx_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_cmp_rbx_rax(out: *CodegenOutBuf): i32 {
  let cmp_line: u8[16] = [99, 109, 112, 32, 119, 49, 44, 32, 119, 48, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, cmp_line, 10);
}

/** Exported function `emit_cmp_setcc`.
 * Comparison/utility `emit_cmp_setcc`.
 * @param out *CodegenOutBuf
 * @param cc i32
 * @return i32
 */
export function emit_cmp_setcc(out: *CodegenOutBuf, cc: i32): i32 {
  let cmp_line: u8[16] = [99, 109, 112, 32, 119, 49, 44, 32, 119, 48, 0, 0, 0, 0, 0, 0];
  if (types.append_asm_line(out, cmp_line, 10) != 0) {
    return -1;
  }
  let idx: i32 = cc;
  if (idx < 0) { idx = 0; }
  if (idx > 5) { idx = 5; }
/** See implementation for details. */
  let buf: u8[24] = [99, 115, 101, 116, 32, 119, 48, 44, 32, 101, 113, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0];
  if (idx == 1) {
    buf[9] = 110;
    buf[10] = 101;
  } else if (idx == 2) {
    buf[9] = 108;
    buf[10] = 116;
  } else if (idx == 3) {
    buf[9] = 108;
    buf[10] = 101;
  } else if (idx == 4) {
    buf[9] = 103;
    buf[10] = 116;
  } else if (idx == 5) {
    buf[9] = 103;
    buf[10] = 101;
  }
  return types.append_asm_line(out, buf, 11);
}

/** Exported function `emit_not_eax`.
 * Implements `emit_not_eax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_not_eax(out: *CodegenOutBuf): i32 {
  let line: u8[16] = [109, 118, 110, 32, 119, 48, 44, 32, 119, 48, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 10);
}

/** Exported function `emit_and_rbx_rax`.
 * Implements `emit_and_rbx_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_and_rbx_rax(out: *CodegenOutBuf): i32 {
  let line: u8[24] = [97, 110, 100, 32, 119, 48, 44, 32, 119, 49, 44, 32, 119, 48, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 14);
}

/** Exported function `emit_or_rbx_rax`.
 * Implements `emit_or_rbx_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_or_rbx_rax(out: *CodegenOutBuf): i32 {
  let line: u8[24] = [111, 114, 114, 32, 119, 48, 44, 32, 119, 49, 44, 32, 119, 48, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 14);
}

/** Exported function `emit_xor_rbx_rax`.
 * Implements `emit_xor_rbx_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_xor_rbx_rax(out: *CodegenOutBuf): i32 {
  let line: u8[24] = [101, 111, 114, 32, 119, 48, 44, 32, 119, 49, 44, 32, 119, 48, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 14);
}

/** Exported function `emit_shl_cl_eax`.
 * Implements `emit_shl_cl_eax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_shl_cl_eax(out: *CodegenOutBuf): i32 {
  let line: u8[24] = [108, 115, 108, 32, 119, 48, 44, 32, 119, 48, 44, 32, 119, 49, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 14);
}

/** Exported function `emit_shr_cl_eax`.
 * Implements `emit_shr_cl_eax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_shr_cl_eax(out: *CodegenOutBuf): i32 {
  let line: u8[24] = [108, 115, 114, 32, 119, 48, 44, 32, 119, 48, 44, 32, 119, 49, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 14);
}

/** Exported function `emit_sar_cl_eax`.
 * Implements `emit_sar_cl_eax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_sar_cl_eax(out: *CodegenOutBuf): i32 {
  let line: u8[24] = [97, 115, 114, 32, 119, 48, 44, 32, 119, 48, 44, 32, 119, 49, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 14);
}

/** Exported function `emit_push_rax`.
 * Implements `emit_push_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_push_rax(out: *CodegenOutBuf): i32 {
  let line: u8[32] = [115, 116, 114, 32, 120, 48, 44, 32, 91, 115, 112, 44, 32, 35, 45, 49, 54, 93,
  33, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 19);
}

/** Exported function `emit_pop_rbx`.
 * Implements `emit_pop_rbx`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_pop_rbx(out: *CodegenOutBuf): i32 {
  let line: u8[32] = [108, 100, 114, 32, 119, 49, 44, 32, 91, 115, 112, 93, 44, 32, 35, 49, 54, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 17);
}

/** Exported function `emit_pop_rax`.
 * Implements `emit_pop_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_pop_rax(out: *CodegenOutBuf): i32 {
  let line: u8[32] = [108, 100, 114, 32, 119, 48, 44, 32, 91, 115, 112, 93, 44, 32, 35, 49, 54, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 17);
}

/** Exported function `emit_add_rax_rbx`.
 * Implements `emit_add_rax_rbx`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_add_rax_rbx(out: *CodegenOutBuf): i32 {
  let line: u8[24] = [97, 100, 100, 32, 119, 48, 44, 32, 119, 48, 44, 32, 119, 49, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 14);
}

/** Exported function `emit_sub_rbx_rax_then_mov`.
 * Implements `emit_sub_rbx_rax_then_mov`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_sub_rbx_rax_then_mov(out: *CodegenOutBuf): i32 {
  let line: u8[24] = [115, 117, 98, 32, 119, 48, 44, 32, 119, 49, 44, 32, 119, 48, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 14);
}

/** Exported function `emit_sub_rax_rbx`.
 * Implements `emit_sub_rax_rbx`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_sub_rax_rbx(out: *CodegenOutBuf): i32 {
  let line: u8[24] = [115, 117, 98, 32, 119, 48, 44, 32, 119, 48, 44, 32, 119, 49, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 14);
}

/** Exported function `emit_imul_rbx_rax`.
 * Implements `emit_imul_rbx_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_imul_rbx_rax(out: *CodegenOutBuf): i32 {
  let line: u8[24] = [109, 117, 108, 32, 119, 48, 44, 32, 119, 48, 44, 32, 119, 49, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 14);
}

/** Exported function `emit_mov_rax_to_rbx`.
 * Implements `emit_mov_rax_to_rbx`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_mov_rax_to_rbx(out: *CodegenOutBuf): i32 {
  let line: u8[16] = [109, 111, 118, 32, 120, 49, 44, 32, 120, 48, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 10);
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
  let line: u8[24] = [115, 100, 105, 118, 32, 119, 48, 44, 32, 119, 48, 44, 32, 119, 49, 0, 0, 0,
  0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 15);
}

/** Exported function `emit_rem_w0_w1`.
 * Implements `emit_rem_w0_w1`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_rem_w0_w1(out: *CodegenOutBuf): i32 {
  let s1: u8[32] = [115, 116, 114, 32, 119, 48, 44, 32, 91, 115, 112, 44, 32, 35, 45, 49, 54, 93,
  33, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  if (types.append_asm_line(out, s1, 19) != 0) {
    return -1;
  }
  let s2: u8[24] = [115, 100, 105, 118, 32, 119, 48, 44, 32, 119, 48, 44, 32, 119, 49, 0, 0, 0, 0,
  0, 0, 0, 0, 0];
  if (types.append_asm_line(out, s2, 15) != 0) {
    return -1;
  }
  let s3: u8[32] = [108, 100, 114, 32, 119, 50, 44, 32, 91, 115, 112, 93, 44, 32, 35, 49, 54, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  if (types.append_asm_line(out, s3, 17) != 0) {
    return -1;
  }
  let msub_line: u8[32] = [109, 115, 117, 98, 32, 119, 48, 44, 32, 119, 48, 44, 32, 119, 49, 44,
  32, 119, 50, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, msub_line, 19);
}

/** Exported function `emit_mov_edx_to_eax`.
 * Implements `emit_mov_edx_to_eax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_mov_edx_to_eax(out: *CodegenOutBuf): i32 {
  return 0;
}

/** Exported function `emit_lea_rbp_to_rax`.
 * Implements `emit_lea_rbp_to_rax`.
 * @param out *CodegenOutBuf
 * @param offset i32
 * @return i32
 */
export function emit_lea_rbp_to_rax(out: *CodegenOutBuf, offset: i32): i32 {
  let buf: u8[48] = [115, 117, 98, 32, 120, 48, 44, 32, 120, 50, 57, 44, 32, 35, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  /* '#' is at buf[13]; write digits at buf[14]+; do not leave a NUL between '#' and digits
  (assembler reports null character). */
  let n: i32 = types.format_i32_to_buf(buf, 14, 12, offset);
  if (n < 0) {
    return -1;
  }
  return types.append_asm_line(out, buf, 14 + n);
}

/**
* See implementation.
*/
export function emit_memset_rbp_zero(out: *CodegenOutBuf, rbp_off: i32, nbytes: i32): i32 {
  if (nbytes <= 0) {
    return 0;
  }
  let s0: u8[48] = [115, 117, 98, 32, 120, 48, 44, 32, 120, 50, 57, 44, 32, 35, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n0: i32 = types.format_i32_to_buf(s0, 14, 12, rbp_off);
  if (n0 < 0) {
    return -1;
  }
  if (types.append_asm_line(out, s0, 14 + n0) != 0) {
    return -1;
  }
  let mx1: u8[24] = [109, 111, 118, 32, 120, 49, 44, 32, 120, 122, 114, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0];
  if (types.append_asm_line(out, mx1, 12) != 0) {
    return -1;
  }
  let mx2: u8[32] = [109, 111, 118, 32, 120, 50, 44, 32, 35, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n1: i32 = types.format_i32_to_buf(mx2, 9, 12, nbytes);
  if (n1 < 0) {
    return -1;
  }
  if (types.append_asm_line(out, mx2, 9 + n1) != 0) {
    return -1;
  }
  let bl: u8[16] = [98, 108, 32, 109, 101, 109, 115, 101, 116, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, bl, 9);
}

/** Exported function `emit_load_rbp_to_rax`.
 * Implements `emit_load_rbp_to_rax`.
 * @param out *CodegenOutBuf
 * @param offset i32
 * @return i32
 */
export function emit_load_rbp_to_rax(out: *CodegenOutBuf, offset: i32): i32 {
  let buf: u8[48] = [108, 100, 114, 32, 120, 48, 44, 32, 91, 120, 50, 57, 44, 32, 35, 45, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(buf, 16, 12, offset);
  if (n < 0) {
    return -1;
  }
  buf[16 + n] = 93;
  return types.append_asm_line(out, buf, 17 + n);
}

/** Exported function `emit_load_x29_pos_to_rax`.
 * Implements `emit_load_x29_pos_to_rax`.
 * @param out *CodegenOutBuf
 * @param off_pos i32
 * @return i32
 */
export function emit_load_x29_pos_to_rax(out: *CodegenOutBuf, off_pos: i32): i32 {
  let buf: u8[48] = [108, 100, 114, 32, 120, 48, 44, 32, 91, 120, 50, 57, 44, 32, 35, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(buf, 15, 12, off_pos);
  if (n < 0) {
    return -1;
  }
  buf[15 + n] = 93;
  return types.append_asm_line(out, buf, 16 + n);
}

/** Exported function `emit_store_rax_to_rbp`.
 * Implements `emit_store_rax_to_rbp`.
 * @param out *CodegenOutBuf
 * @param offset i32
 * @return i32
 */
export function emit_store_rax_to_rbp(out: *CodegenOutBuf, offset: i32): i32 {
  let buf: u8[48] = [115, 116, 114, 32, 120, 48, 44, 32, 91, 120, 50, 57, 44, 32, 35, 45, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(buf, 16, 12, offset);
  if (n < 0) {
    return -1;
  }
  buf[16 + n] = 93;
  return types.append_asm_line(out, buf, 17 + n);
}

/** Exported function `emit_store_x_reg_to_rbp`.
 * Implements `emit_store_x_reg_to_rbp`.
 * @param out *CodegenOutBuf
 * @param reg i32
 * @param offset i32
 * @return i32
 */
export function emit_store_x_reg_to_rbp(out: *CodegenOutBuf, reg: i32, offset: i32): i32 {
  let buf: u8[48] = [115, 116, 114, 32, 120, 48, 44, 32, 91, 120, 50, 57, 44, 32, 35, 45, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let rd: i32 = reg;
  if (rd < 0) { rd = 0; }
  if (rd > 7) { rd = 7; }
  buf[5] = (48 + rd) as u8;
  let n: i32 = types.format_i32_to_buf(buf, 16, 12, offset);
  if (n < 0) {
    return -1;
  }
  buf[16 + n] = 93;
  return types.append_asm_line(out, buf, 17 + n);
}

/** Exported function `emit_store_rax_to_rbx_offset`.
 * Implements `emit_store_rax_to_rbx_offset`.
 * @param out *CodegenOutBuf
 * @param offset i32
 * @param store_size i32
 * @return i32
 */
export function emit_store_rax_to_rbx_offset(out: *CodegenOutBuf, offset: i32, store_size: i32): i32 {
  if (store_size == 1) {
    let buf: u8[48] = [115, 116, 114, 98, 32, 119, 48, 44, 32, 91, 120, 49, 44, 32, 35, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    /* See implementation. */
    let n: i32 = types.format_i32_to_buf(buf, 15, 12, offset);
    if (n < 0) {
      return -1;
    }
    buf[15 + n] = 93;
    return types.append_asm_line(out, buf, 16 + n);
  }
  if (store_size == 4) {
    let buf: u8[48] = [115, 116, 114, 32, 119, 48, 44, 32, 91, 120, 49, 44, 32, 35, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    /* See implementation. */
    let n: i32 = types.format_i32_to_buf(buf, 14, 12, offset);
    if (n < 0) { return -1; }
    buf[14 + n] = 93;
    return types.append_asm_line(out, buf, 15 + n);
  }
  let buf: u8[48] = [115, 116, 114, 32, 120, 48, 44, 32, 91, 120, 49, 44, 32, 35, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(buf, 14, 12, offset);
  if (n < 0) { return -1; }
  buf[14 + n] = 93;
  return types.append_asm_line(out, buf, 15 + n);
}

/** Exported function `emit_mov_rbx_to_rax`.
 * Implements `emit_mov_rbx_to_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_mov_rbx_to_rax(out: *CodegenOutBuf): i32 {
  let line: u8[16] = [109, 111, 118, 32, 120, 48, 44, 32, 120, 49, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 10);
}

/** Exported function `emit_rax_plus_rbx_scale1`.
 * Implements `emit_rax_plus_rbx_scale1`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_rax_plus_rbx_scale1(out: *CodegenOutBuf): i32 {
  let line: u8[32] = [97, 100, 100, 32, 120, 48, 44, 32, 120, 48, 44, 32, 119, 49, 44, 32, 117,
  120, 116, 119, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 20);
}

/** Exported function `emit_rax_plus_rbx_scale4`.
 * Implements `emit_rax_plus_rbx_scale4`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_rax_plus_rbx_scale4(out: *CodegenOutBuf): i32 {
  let line: u8[32] = [97, 100, 100, 32, 120, 48, 44, 32, 120, 48, 44, 32, 119, 49, 44, 32, 117,
  120, 116, 119, 32, 35, 50, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 23);
}

/** Exported function `emit_rax_plus_rbx_scale8`.
 * Implements `emit_rax_plus_rbx_scale8`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_rax_plus_rbx_scale8(out: *CodegenOutBuf): i32 {
  let line: u8[32] = [97, 100, 100, 32, 120, 48, 44, 32, 120, 48, 44, 32, 119, 49, 44, 32, 117,
  120, 116, 119, 32, 35, 51, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 23);
}

/** Exported function `emit_store_rax_to_rbx_indirect`.
 * Implements `emit_store_rax_to_rbx_indirect`.
 * @param out *CodegenOutBuf
 * @param elem_sz i32
 * @return i32
 */
export function emit_store_rax_to_rbx_indirect(out: *CodegenOutBuf, elem_sz: i32): i32 {
  if (elem_sz == 1) {
    let ln: u8[28] = [115, 116, 114, 98, 32, 119, 48, 44, 32, 91, 120, 49, 93, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0];
    return types.append_asm_line(out, ln, 13);
  }
  if (elem_sz == 4) {
    let ln: u8[28] = [115, 116, 114, 32, 119, 48, 44, 32, 91, 120, 49, 93, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0];
    return types.append_asm_line(out, ln, 12);
  }
  let ln: u8[28] = [115, 116, 114, 32, 120, 48, 44, 32, 91, 120, 49, 93, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, ln, 12);
}

/** Exported function `emit_load_32_from_rax`.
 * Implements `emit_load_32_from_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_load_32_from_rax(out: *CodegenOutBuf): i32 {
  let line: u8[20] = [108, 100, 114, 32, 119, 48, 44, 32, 91, 120, 48, 93, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 12);
}

/** Exported function `emit_load_zext8_from_rax`.
 * Implements `emit_load_zext8_from_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_load_zext8_from_rax(out: *CodegenOutBuf): i32 {
  let line: u8[22] = [108, 100, 114, 98, 32, 119, 48, 44, 32, 91, 120, 48, 93, 0, 0, 0, 0, 0, 0, 0,
  0, 0];
  return types.append_asm_line(out, line, 13);
}

/** Exported function `emit_add_imm_to_rax`.
 * Implements `emit_add_imm_to_rax`.
 * @param out *CodegenOutBuf
 * @param imm i32
 * @return i32
 */
export function emit_add_imm_to_rax(out: *CodegenOutBuf, imm: i32): i32 {
  if (imm == 0) { return 0; }
  let buf: u8[40] = [97, 100, 100, 32, 120, 48, 44, 32, 120, 48, 44, 32, 35, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
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
  let line: u8[20] = [108, 100, 114, 32, 120, 48, 44, 32, 91, 120, 48, 93, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 12);
}

/* See implementation. */
/** Exported function `emit_ldr_sp_offset_to_wi`.
 * Implements `emit_ldr_sp_offset_to_wi`.
 * @param out *CodegenOutBuf
 * @param i i32
 * @return i32
 */
export function emit_ldr_sp_offset_to_wi(out: *CodegenOutBuf, i: i32): i32 {
  let idx: i32 = i;
  if (idx < 0) { idx = 0; }
  if (idx > 5) { idx = 5; }
  let reg: u8[6] = [48, 49, 50, 51, 52, 53];
  /* See implementation. */
  let buf: u8[40] = [108, 100, 114, 32, 119, 48, 44, 32, 91, 115, 112, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  buf[5] = reg[idx];
  if (idx == 0) {
    buf[11] = 93;
    return types.append_asm_line(out, buf, 12);
  }
  buf[11] = 44;
  buf[12] = 32;
  buf[13] = 35;
  let off: i32 = idx * 16;
  let n: i32 = types.format_i32_to_buf(buf, 14, 10, off);
  if (n < 0) { return -1; }
  buf[14 + n] = 93;
  return types.append_asm_line(out, buf, 15 + n);
}

/**
* See implementation.
* See implementation.
*/
export function emit_ldr_sp_slot_to_xreg(out: *CodegenOutBuf, slot: i32, reg: i32): i32 {
  let s: i32 = slot;
  if (s < 0) { s = 0; }
  if (s > 7) { s = 7; }
  let rd: i32 = reg;
  if (rd < 0) { rd = 0; }
  if (rd > 7) { rd = 7; }
  let digit: u8[8] = [48, 49, 50, 51, 52, 53, 54, 55];
  let buf: u8[48] = [108, 100, 114, 32, 120, 48, 44, 32, 91, 115, 112, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  buf[5] = digit[rd];
  if (s == 0) {
    buf[11] = 93;
    return types.append_asm_line(out, buf, 12);
  }
  buf[11] = 44;
  buf[12] = 32;
  buf[13] = 35;
  let offx: i32 = s * 16;
  let n: i32 = types.format_i32_to_buf(buf, 14, 12, offx);
  if (n < 0) { return -1; }
  buf[14 + n] = 93;
  return types.append_asm_line(out, buf, 15 + n);
}

/**
* See implementation.
* x(i)。
* i=0：ldr x0, [sp]；i>0：ldr xi, [sp, #i*16]。
*/
export function emit_ldr_sp_offset_to_xi(out: *CodegenOutBuf, i: i32): i32 {
  return emit_ldr_sp_slot_to_xreg(out, i, i);
}

/** Exported function `emit_mov_x0_to_arg_x`.
 * Implements `emit_mov_x0_to_arg_x`.
 * @param out *CodegenOutBuf
 * @param k i32
 * @return i32
 */
export function emit_mov_x0_to_arg_x(out: *CodegenOutBuf, k: i32): i32 {
  if (k <= 0) {
    return 0;
  }
  let idx: i32 = k;
  if (idx > 7) { idx = 7; }
  let digit: u8[8] = [48, 49, 50, 51, 52, 53, 54, 55];
  let buf: u8[16] = [109, 111, 118, 32, 120, 48, 44, 32, 120, 48, 0, 0, 0, 0, 0, 0];
  buf[5] = digit[idx];
  return types.append_asm_line(out, buf, 10);
}

/** Exported function `emit_add_sp_imm`.
 * Implements `emit_add_sp_imm`.
 * @param out *CodegenOutBuf
 * @param n i32
 * @return i32
 */
export function emit_add_sp_imm(out: *CodegenOutBuf, n: i32): i32 {
  let buf: u8[32] = [97, 100, 100, 32, 115, 112, 44, 32, 115, 112, 44, 32, 35, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let k: i32 = types.format_i32_to_buf(buf, 13, 8, n);
  if (k < 0) { return -1; }
  return types.append_asm_line(out, buf, 13 + k);
}

/** Exported function `emit_sub_sp_imm`.
 * Implements `emit_sub_sp_imm`.
 * @param out *CodegenOutBuf
 * @param n i32
 * @return i32
 */
export function emit_sub_sp_imm(out: *CodegenOutBuf, n: i32): i32 {
  let buf: u8[32] = [115, 117, 98, 32, 115, 112, 44, 32, 115, 112, 44, 32, 35, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let k: i32 = types.format_i32_to_buf(buf, 13, 8, n);
  if (k < 0) { return -1; }
  return types.append_asm_line(out, buf, 13 + k);
}

/**
* See implementation.
* See implementation.
*/
export function emit_str_x0_sp_offset(out: *CodegenOutBuf, off_bytes: i32): i32 {
  let buf: u8[48] = [115, 116, 114, 32, 120, 48, 44, 32, 91, 115, 112, 44, 32, 35, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(buf, 14, 10, off_bytes);
  if (n < 0) { return -1; }
  buf[14 + n] = 93;
  return types.append_asm_line(out, buf, 15 + n);
}

/** Exported function `emit_call`.
 * Implements `emit_call`.
 * @param out *CodegenOutBuf
 * @param name *u8
 * @param name_len i32
 * @return i32
 */
export function emit_call(out: *CodegenOutBuf, name: *u8, name_len: i32): i32 {
  let buf: u8[80] = [98, 108, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let k: i32 = 0;
  while (k < name_len && k < 76) {
    buf[3 + k] = name[k];
    k = k + 1;
  }
  return types.append_asm_line(out, buf, 3 + name_len);
}

/** Exported function `emit_jz`.
 * Implements `emit_jz`.
 * @param out *CodegenOutBuf
 * @param label *u8
 * @param label_len i32
 * @return i32
 */
export function emit_jz(out: *CodegenOutBuf, label: *u8, label_len: i32): i32 {
  let buf: u8[72] = [99, 98, 122, 32, 119, 48, 44, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let k: i32 = 0;
  while (k < label_len && k < 64) {
    buf[8 + k] = label[k];
    k = k + 1;
  }
  return types.append_asm_line(out, buf, 8 + label_len);
}

/** Exported function `emit_jeq`.
 * Implements `emit_jeq`.
 * @param out *CodegenOutBuf
 * @param label *u8
 * @param label_len i32
 * @return i32
 */
export function emit_jeq(out: *CodegenOutBuf, label: *u8, label_len: i32): i32 {
  let buf: u8[72] = [98, 101, 113, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let k: i32 = 0;
  while (k < label_len && k < 64) {
    buf[4 + k] = label[k];
    k = k + 1;
  }
  return types.append_asm_line(out, buf, 4 + label_len);
}

/** Exported function `emit_jnz`.
 * Implements `emit_jnz`.
 * @param out *CodegenOutBuf
 * @param label *u8
 * @param label_len i32
 * @return i32
 */
export function emit_jnz(out: *CodegenOutBuf, label: *u8, label_len: i32): i32 {
  let buf: u8[72] = [99, 98, 110, 122, 32, 119, 48, 44, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let k: i32 = 0;
  while (k < label_len && k < 62) {
    buf[9 + k] = label[k];
    k = k + 1;
  }
  return types.append_asm_line(out, buf, 9 + label_len);
}

/** Exported function `emit_jmp`.
 * Implements `emit_jmp`.
 * @param out *CodegenOutBuf
 * @param label *u8
 * @param label_len i32
 * @return i32
 */
export function emit_jmp(out: *CodegenOutBuf, label: *u8, label_len: i32): i32 {
  let buf: u8[72] = [98, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let k: i32 = 0;
  while (k < label_len && k < 70) {
    buf[2 + k] = label[k];
    k = k + 1;
  }
  return types.append_asm_line(out, buf, 2 + label_len);
}
