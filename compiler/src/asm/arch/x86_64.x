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

/** Exported function `emit_prologue`.
 * Implements `emit_prologue`.
 * @param out *CodegenOutBuf
 * @param frame_size i32
 * @return i32
 */
export function emit_prologue(out: *CodegenOutBuf, frame_size: i32): i32 {
  let line: u8[64] = [112, 117, 115, 104, 113, 32, 37, 114, 98, 112, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  if (types.append_asm_line(out, line, 11) != 0) {
    return -1;
  }
  let mov_line: u8[32] = [109, 111, 118, 113, 32, 37, 114, 115, 112, 44, 32, 37, 114, 98, 112, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  if (types.append_asm_line(out, mov_line, 15) != 0) {
    return -1;
  }
  /* See implementation. */
  let sub_buf: u8[32] = [115, 117, 98, 113, 32, 36, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(sub_buf, 6, 10, frame_size);
  if (n < 0) {
    return -1;
  }
  sub_buf[6 + n] = 44;
  sub_buf[6 + n + 1] = 32;
  sub_buf[6 + n + 2] = 37;
  sub_buf[6 + n + 3] = 114;
  sub_buf[6 + n + 4] = 115;
  sub_buf[6 + n + 5] = 112;
  return types.append_asm_line(out, sub_buf, 6 + n + 6);
}

/** Exported function `emit_epilogue`.
 * Implements `emit_epilogue`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_epilogue(out: *CodegenOutBuf): i32 {
  let line: u8[64] = [109, 111, 118, 113, 32, 37, 114, 115, 112, 44, 32, 37, 114, 98, 112, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = 15;
  if (types.append_asm_line(out, line, n) != 0) {
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
  let buf: u8[32] = [109, 111, 118, 108, 32, 36, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(buf, 6, 12, imm32);
  if (n < 0) {
    return -1;
  }
  buf[6 + n] = 44;
  buf[6 + n + 1] = 32;
  buf[6 + n + 2] = 37;
  buf[6 + n + 3] = 101;
  buf[6 + n + 4] = 97;
  buf[6 + n + 5] = 120;
  return types.append_asm_line(out, buf, 6 + n + 6);
}

/** Exported function `emit_mov_imm32_to_rbx`.
 * Implements `emit_mov_imm32_to_rbx`.
 * @param out *CodegenOutBuf
 * @param imm32 i32
 * @return i32
 */
export function emit_mov_imm32_to_rbx(out: *CodegenOutBuf, imm32: i32): i32 {
  let buf: u8[32] = [109, 111, 118, 108, 32, 36, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(buf, 6, 12, imm32);
  if (n < 0) {
    return -1;
  }
  buf[6 + n] = 44;
  buf[6 + n + 1] = 32;
  buf[6 + n + 2] = 37;
  buf[6 + n + 3] = 101;
  buf[6 + n + 4] = 98;
  buf[6 + n + 5] = 120;
  return types.append_asm_line(out, buf, 6 + n + 6);
}

/** Exported function `emit_mov_imm64_to_rax`.
 * Implements `emit_mov_imm64_to_rax`.
 * @param out *CodegenOutBuf
 * @param lo i32
 * @param hi i32
 * @return i32
 */
export function emit_mov_imm64_to_rax(out: *CodegenOutBuf, lo: i32, hi: i32): i32 {
  let prefix: u8[8] = [109, 111, 118, 113, 32, 36, 48, 120];
  let buf: u8[40] = [];
  buf[24] = 44;
  buf[25] = 32;
  buf[26] = 37;
  buf[27] = 114;
  buf[28] = 97;
  buf[29] = 120;
  let i: i32 = 0;
  while (i < 8) {
    buf[i] = prefix[i];
    i = i + 1;
  }
  if (types.format_u32_hex8_to_buf(buf, 8, hi) != 8) { return -1; }
  if (types.format_u32_hex8_to_buf(buf, 16, lo) != 8) { return -1; }
  return types.append_asm_line(out, buf, 26);
}

/** Exported function `emit_add`.
 * Implements `emit_add`.
 * @param out *CodegenOutBuf
 * @param dst_reg *u8
 * @param dst_len i32
 * @param src_reg *u8
 * @param src_len i32
 * @return i32
 */
export function emit_add(out: *CodegenOutBuf, dst_reg: *u8, dst_len: i32, src_reg: *u8, src_len: i32): i32
{
  let line: u8[64] = [97, 100, 100, 113, 32, 37, 114, 97, 120, 44, 32, 37, 114, 98, 120, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = 15;
  return types.append_asm_line(out, line, n);
}

/** See implementation for details. */
/** Exported function `emit_mov_rax_to_arg_reg`.
 * Implements `emit_mov_rax_to_arg_reg`.
 * @param out *CodegenOutBuf
 * @param k i32
 * @return i32
 */
export function emit_mov_rax_to_arg_reg(out: *CodegenOutBuf, k: i32): i32 {
  let names: u8[24] = [114, 100, 105, 0, 114, 115, 105, 0, 114, 100, 120, 0, 114, 99, 120, 0, 114, 56,
  0, 0, 114, 57, 0, 0];
  let idx: i32 = k;
  if (idx < 0) { idx = 0; }
  if (idx > 5) { idx = 5; }
  let reg_len: i32 = 3;
  if (idx == 4 || idx == 5) { reg_len = 2; }
  let buf: u8[32] = [109, 111, 118, 113, 32, 37, 114, 97, 120, 44, 32, 37, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let i: i32 = 0;
  while (i < reg_len && i < 4) {
    buf[12 + i] = names[idx * 4 + i];
    i = i + 1;
  }
  return types.append_asm_line(out, buf, 12 + i);
}

/** Exported function `emit_call`.
 * Implements `emit_call`.
 * @param out *CodegenOutBuf
 * @param name u8[64]
 * @param name_len i32
 * @return i32
 */
export function emit_call(out: *CodegenOutBuf, name: u8[64], name_len: i32): i32 {
  let buf: u8[80] = [];
  buf[0] = 99;
  buf[1] = 97;
  buf[2] = 108;
  buf[3] = 108;
  buf[4] = 32;
  let k: i32 = 0;
  while (k < name_len && k < 74) {
    buf[5 + k] = name[k];
    k = k + 1;
  }
  return types.append_asm_line(out, buf, 5 + name_len);
}

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
 * @param name u8[64]
 * @param name_len i32
 * @return i32
 */
export function emit_globl(out: *CodegenOutBuf, name: u8[64], name_len: i32): i32 {
  let buf: u8[80] = [];
  buf[0] = 46;
  buf[1] = 103;
  buf[2] = 108;
  buf[3] = 111;
  buf[4] = 98;
  buf[5] = 108;
  buf[6] = 32;
  let k: i32 = 0;
  while (k < name_len && k < 72) {
    buf[7 + k] = name[k];
    k = k + 1;
  }
  return types.append_asm_line(out, buf, 7 + name_len);
}

/** Exported function `emit_push_rax`.
 * Implements `emit_push_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_push_rax(out: *CodegenOutBuf): i32 {
  let line: u8[16] = [112, 117, 115, 104, 113, 32, 37, 114, 97, 120, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 10);
}

/** Exported function `emit_add_rsp_imm`.
 * Implements `emit_add_rsp_imm`.
 * @param out *CodegenOutBuf
 * @param nbytes i32
 * @return i32
 */
export function emit_add_rsp_imm(out: *CodegenOutBuf, nbytes: i32): i32 {
  if (nbytes <= 0) {
    return 0;
  }
  let buf: u8[36] = [97, 100, 100, 113, 32, 36, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(buf, 6, 12, nbytes);
  if (n < 0) {
    return -1;
  }
  buf[6 + n] = 44;
  buf[7 + n] = 32;
  buf[8 + n] = 37;
  buf[9 + n] = 114;
  buf[10 + n] = 115;
  buf[11 + n] = 112;
  return types.append_asm_line(out, buf, 12 + n);
}

/** Exported function `emit_pop_rbx`.
 * Implements `emit_pop_rbx`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_pop_rbx(out: *CodegenOutBuf): i32 {
  let line: u8[16] = [112, 111, 112, 113, 32, 37, 114, 98, 120, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 9);
}

/** Exported function `emit_pop_rax`.
 * Implements `emit_pop_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_pop_rax(out: *CodegenOutBuf): i32 {
  let line: u8[16] = [112, 111, 112, 113, 32, 37, 114, 97, 120, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 9);
}

/** Exported function `emit_add_rax_rbx`.
 * Implements `emit_add_rax_rbx`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_add_rax_rbx(out: *CodegenOutBuf): i32 {
  let line: u8[32] = [97, 100, 100, 113, 32, 37, 114, 98, 120, 44, 32, 37, 114, 97, 120, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 15);
}

/** Exported function `emit_sub_rbx_rax_then_mov`.
 * Implements `emit_sub_rbx_rax_then_mov`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_sub_rbx_rax_then_mov(out: *CodegenOutBuf): i32 {
  let sub_line: u8[32] = [115, 117, 98, 113, 32, 37, 114, 97, 120, 44, 32, 37, 114, 98, 120, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  if (types.append_asm_line(out, sub_line, 15) != 0) {
    return -1;
  }
  let mov_line: u8[32] = [109, 111, 118, 113, 32, 37, 114, 98, 120, 44, 32, 37, 114, 97, 120, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, mov_line, 15);
}

/** Exported function `emit_imul_rbx_rax`.
 * Implements `emit_imul_rbx_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_imul_rbx_rax(out: *CodegenOutBuf): i32 {
  let line: u8[32] = [105, 109, 117, 108, 113, 32, 37, 114, 98, 120, 44, 32, 37, 114, 97, 120, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 16);
}

/** Exported function `emit_cltd`.
 * Implements `emit_cltd`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_cltd(out: *CodegenOutBuf): i32 {
  let line: u8[8] = [99, 108, 116, 100, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 4);
}

/** Exported function `emit_idiv_rbx`.
 * Implements `emit_idiv_rbx`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_idiv_rbx(out: *CodegenOutBuf): i32 {
  let line: u8[32] = [105, 100, 105, 118, 108, 32, 37, 101, 98, 120, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 10);
}

/** Exported function `emit_mov_edx_to_eax`.
 * Implements `emit_mov_edx_to_eax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_mov_edx_to_eax(out: *CodegenOutBuf): i32 {
  let line: u8[32] = [109, 111, 118, 108, 32, 37, 101, 100, 120, 44, 32, 37, 101, 97, 120, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 15);
}

/** Exported function `emit_neg_eax`.
 * Implements `emit_neg_eax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_neg_eax(out: *CodegenOutBuf): i32 {
  let line: u8[16] = [110, 101, 103, 108, 32, 37, 101, 97, 120, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 9);
}

/** Exported function `emit_setz_movzbl_eax`.
 * Implements `emit_setz_movzbl_eax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_setz_movzbl_eax(out: *CodegenOutBuf): i32 {
  let line1: u8[16] = [115, 101, 116, 122, 32, 37, 97, 108, 0, 0, 0, 0, 0, 0, 0, 0];
  if (types.append_asm_line(out, line1, 8) != 0) {
    return -1;
  }
  let line2: u8[24] = [109, 111, 118, 122, 98, 108, 32, 37, 97, 108, 44, 32, 37, 101, 97, 120, 0,
  0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line2, 16);
}

/** Exported function `emit_mov_rax_to_rbx`.
 * Implements `emit_mov_rax_to_rbx`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_mov_rax_to_rbx(out: *CodegenOutBuf): i32 {
  let line: u8[32] = [109, 111, 118, 113, 32, 37, 114, 97, 120, 44, 32, 37, 114, 98, 120, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 15);
}

/** Exported function `emit_mov_rbx_to_rax`.
 * Implements `emit_mov_rbx_to_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_mov_rbx_to_rax(out: *CodegenOutBuf): i32 {
  let line: u8[32] = [109, 111, 118, 113, 32, 37, 114, 98, 120, 44, 32, 37, 114, 97, 120, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 15);
}

/** Exported function `emit_test_eax_eax`.
 * Implements `emit_test_eax_eax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_test_eax_eax(out: *CodegenOutBuf): i32 {
  let line: u8[32] = [116, 101, 115, 116, 32, 37, 101, 97, 120, 44, 32, 37, 101, 97, 120, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 15);
}

/** Exported function `emit_cmp_rbx_rax`.
 * Comparison/utility `emit_cmp_rbx_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_cmp_rbx_rax(out: *CodegenOutBuf): i32 {
  let cmp_line: u8[32] = [99, 109, 112, 108, 32, 37, 101, 97, 120, 44, 32, 37, 101, 98, 120, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, cmp_line, 15);
}

/** Exported function `emit_cmp_setcc`.
 * Comparison/utility `emit_cmp_setcc`.
 * @param out *CodegenOutBuf
 * @param cc i32
 * @return i32
 */
export function emit_cmp_setcc(out: *CodegenOutBuf, cc: i32): i32 {
  let cmp_line: u8[32] = [99, 109, 112, 108, 32, 37, 101, 97, 120, 44, 32, 37, 101, 98, 120, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  if (types.append_asm_line(out, cmp_line, 15) != 0) {
    return -1;
  }
  let setcc_names: u8[48] = [115, 101, 116, 101, 0, 0, 0, 0, 115, 101, 116, 110, 101, 0, 0, 0, 115, 101,
  116, 108, 0, 0, 0, 0, 115, 101, 116, 108, 101, 0, 0, 0, 115, 101, 116, 103, 0, 0, 0, 0, 115, 101,
  116, 103, 101, 0, 0, 0];
  let idx: i32 = cc;
  if (idx < 0) { idx = 0; }
  if (idx > 5) { idx = 5; }
  let len: i32 = 4;
  if (idx == 1 || idx == 3 || idx == 5) { len = 5; }
  let buf: u8[24] = [115, 101, 116, 0, 0, 0, 32, 37, 97, 108, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0];
  let k: i32 = 0;
  while (k < len && k < 8) {
    buf[k] = setcc_names[idx * 8 + k];
    k = k + 1;
  }
  buf[k] = 32;
  buf[k + 1] = 37;
  buf[k + 2] = 97;
  buf[k + 3] = 108;
  if (types.append_asm_line(out, buf, k + 4) != 0) {
    return -1;
  }
  let line2: u8[24] = [109, 111, 118, 122, 98, 108, 32, 37, 97, 108, 44, 32, 37, 101, 97, 120, 0,
  0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line2, 16);
}

/** Exported function `emit_not_eax`.
 * Implements `emit_not_eax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_not_eax(out: *CodegenOutBuf): i32 {
  let line: u8[16] = [110, 111, 116, 108, 32, 37, 101, 97, 120, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 9);
}

/** Exported function `emit_and_rbx_rax`.
 * Implements `emit_and_rbx_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_and_rbx_rax(out: *CodegenOutBuf): i32 {
  let line: u8[20] = [97, 110, 100, 108, 32, 37, 101, 98, 120, 44, 32, 37, 101, 97, 120, 0, 0, 0,
  0, 0];
  return types.append_asm_line(out, line, 15);
}

/** Exported function `emit_or_rbx_rax`.
 * Implements `emit_or_rbx_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_or_rbx_rax(out: *CodegenOutBuf): i32 {
  let line: u8[20] = [111, 114, 108, 32, 37, 101, 98, 120, 44, 32, 37, 101, 97, 120, 0, 0, 0, 0, 0,
  0];
  return types.append_asm_line(out, line, 14);
}

/** Exported function `emit_xor_rbx_rax`.
 * Implements `emit_xor_rbx_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_xor_rbx_rax(out: *CodegenOutBuf): i32 {
  let line: u8[20] = [120, 111, 114, 108, 32, 37, 101, 98, 120, 44, 32, 37, 101, 97, 120, 0, 0, 0,
  0, 0];
  return types.append_asm_line(out, line, 15);
}

/** Exported function `emit_mov_rbx_to_ecx`.
 * Implements `emit_mov_rbx_to_ecx`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_mov_rbx_to_ecx(out: *CodegenOutBuf): i32 {
  let line: u8[24] = [109, 111, 118, 108, 32, 37, 101, 98, 120, 44, 32, 37, 101, 99, 120, 0, 0, 0,
  0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 15);
}

/** Exported function `emit_shl_cl_eax`.
 * Implements `emit_shl_cl_eax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_shl_cl_eax(out: *CodegenOutBuf): i32 {
  let line: u8[20] = [115, 97, 108, 108, 32, 37, 99, 108, 44, 32, 37, 101, 97, 120, 0, 0, 0, 0, 0,
  0];
  return types.append_asm_line(out, line, 14);
}

/** Exported function `emit_shr_cl_eax`.
 * Implements `emit_shr_cl_eax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_shr_cl_eax(out: *CodegenOutBuf): i32 {
  let line: u8[20] = [115, 104, 114, 108, 32, 37, 99, 108, 44, 32, 37, 101, 97, 120, 0, 0, 0, 0, 0,
  0];
  return types.append_asm_line(out, line, 14);
}

/** Exported function `emit_sar_cl_eax`.
 * Implements `emit_sar_cl_eax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_sar_cl_eax(out: *CodegenOutBuf): i32 {
  let line: u8[20] = [115, 97, 114, 108, 32, 37, 99, 108, 44, 32, 37, 101, 97, 120, 0, 0, 0, 0, 0,
  0];
  return types.append_asm_line(out, line, 14);
}

/** Exported function `emit_store_rax_to_rbp`.
 * Implements `emit_store_rax_to_rbp`.
 * @param out *CodegenOutBuf
 * @param offset i32
 * @return i32
 */
export function emit_store_rax_to_rbp(out: *CodegenOutBuf, offset: i32): i32 {
  let buf: u8[48] = [109, 111, 118, 113, 32, 37, 114, 97, 120, 44, 32, 45, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(buf, 12, 12, offset);
  if (n < 0) {
    return -1;
  }
  buf[12 + n] = 40;
  buf[13 + n] = 37;
  buf[14 + n] = 114;
  buf[15 + n] = 98;
  buf[16 + n] = 112;
  buf[17 + n] = 41;
  return types.append_asm_line(out, buf, 18 + n);
}

/** Exported function `emit_load_rbp_to_rax`.
 * Implements `emit_load_rbp_to_rax`.
 * @param out *CodegenOutBuf
 * @param offset i32
 * @return i32
 */
export function emit_load_rbp_to_rax(out: *CodegenOutBuf, offset: i32): i32 {
  let buf: u8[48] = [109, 111, 118, 113, 32, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(buf, 6, 12, offset);
  if (n < 0) {
    return -1;
  }
  buf[6 + n] = 40;
  buf[7 + n] = 37;
  buf[8 + n] = 114;
  buf[9 + n] = 98;
  buf[10 + n] = 112;
  buf[11 + n] = 41;
  buf[12 + n] = 44;
  buf[13 + n] = 32;
  buf[14 + n] = 37;
  buf[15 + n] = 114;
  buf[16 + n] = 97;
  buf[17 + n] = 120;
  return types.append_asm_line(out, buf, 18 + n);
}

/** Exported function `emit_lea_rbp_to_rax`.
 * Implements `emit_lea_rbp_to_rax`.
 * @param out *CodegenOutBuf
 * @param offset i32
 * @return i32
 */
export function emit_lea_rbp_to_rax(out: *CodegenOutBuf, offset: i32): i32 {
  let buf: u8[48] = [108, 101, 97, 113, 32, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(buf, 6, 12, offset);
  if (n < 0) {
    return -1;
  }
  buf[6 + n] = 40;
  buf[7 + n] = 37;
  buf[8 + n] = 114;
  buf[9 + n] = 98;
  buf[10 + n] = 112;
  buf[11 + n] = 41;
  buf[12 + n] = 44;
  buf[13 + n] = 32;
  buf[14 + n] = 37;
  buf[15 + n] = 114;
  buf[16 + n] = 97;
  buf[17 + n] = 120;
  return types.append_asm_line(out, buf, 18 + n);
}

/** Exported function `emit_rax_plus_rbx_scale1`.
 * Implements `emit_rax_plus_rbx_scale1`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_rax_plus_rbx_scale1(out: *CodegenOutBuf): i32 {
  let line: u8[48] = [108, 101, 97, 113, 32, 40, 37, 114, 97, 120, 44, 37, 114, 98, 120, 44, 49,
  41, 44, 32, 37, 114, 97, 120, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0];
  return types.append_asm_line(out, line, 24);
}

/** Exported function `emit_rax_plus_rbx_scale4`.
 * Implements `emit_rax_plus_rbx_scale4`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_rax_plus_rbx_scale4(out: *CodegenOutBuf): i32 {
  let line: u8[48] = [108, 101, 97, 113, 32, 40, 37, 114, 97, 120, 44, 37, 114, 98, 120, 44, 52,
  41, 44, 32, 37, 114, 97, 120, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0];
  return types.append_asm_line(out, line, 24);
}

/** Exported function `emit_rax_plus_rbx_scale8`.
 * Implements `emit_rax_plus_rbx_scale8`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_rax_plus_rbx_scale8(out: *CodegenOutBuf): i32 {
  let line: u8[48] = [108, 101, 97, 113, 32, 40, 37, 114, 97, 120, 44, 37, 114, 98, 120, 44, 56,
  41, 44, 32, 37, 114, 97, 120, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0];
  return types.append_asm_line(out, line, 24);
}

/** Exported function `emit_store_rax_to_rbx_indirect`.
 * Implements `emit_store_rax_to_rbx_indirect`.
 * @param out *CodegenOutBuf
 * @param elem_sz i32
 * @return i32
 */
export function emit_store_rax_to_rbx_indirect(out: *CodegenOutBuf, elem_sz: i32): i32 {
  if (elem_sz == 1) {
    let ln: u8[32] = [109, 111, 118, 98, 32, 37, 97, 108, 44, 32, 40, 37, 114, 98, 120, 41, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    return types.append_asm_line(out, ln, 16);
  }
  if (elem_sz == 4) {
    let ln: u8[32] = [109, 111, 118, 108, 32, 37, 101, 97, 120, 44, 32, 40, 37, 114, 98, 120, 41,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    return types.append_asm_line(out, ln, 17);
  }
  let ln: u8[32] = [109, 111, 118, 113, 32, 37, 114, 97, 120, 44, 32, 40, 37, 114, 98, 120, 41, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, ln, 17);
}

/** Exported function `emit_load_32_from_rax`.
 * Implements `emit_load_32_from_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_load_32_from_rax(out: *CodegenOutBuf): i32 {
  let line: u8[32] = [109, 111, 118, 108, 32, 40, 37, 114, 97, 120, 41, 44, 32, 37, 101, 97, 120,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 17);
}

/** Exported function `emit_load_zext8_from_rax`.
 * Implements `emit_load_zext8_from_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_load_zext8_from_rax(out: *CodegenOutBuf): i32 {
  let line: u8[40] = [109, 111, 118, 122, 98, 108, 32, 40, 37, 114, 97, 120, 41, 44, 32, 37, 101,
  97, 120, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 17);
}

/** Exported function `emit_add_imm_to_rax`.
 * Implements `emit_add_imm_to_rax`.
 * @param out *CodegenOutBuf
 * @param imm i32
 * @return i32
 */
export function emit_add_imm_to_rax(out: *CodegenOutBuf, imm: i32): i32 {
  if (imm == 0) { return 0; }
  let buf: u8[32] = [97, 100, 100, 113, 32, 36, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = types.format_i32_to_buf(buf, 6, 12, imm);
  if (n < 0) { return -1; }
  buf[6 + n] = 44;
  buf[7 + n] = 32;
  buf[8 + n] = 37;
  buf[9 + n] = 114;
  buf[10 + n] = 97;
  buf[11 + n] = 120;
  return types.append_asm_line(out, buf, 12 + n);
}

/** Exported function `emit_load_64_from_rax`.
 * Implements `emit_load_64_from_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function emit_load_64_from_rax(out: *CodegenOutBuf): i32 {
  let line: u8[32] = [109, 111, 118, 113, 32, 40, 37, 114, 97, 120, 41, 44, 32, 37, 114, 97, 120,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, line, 17);
}

/** Exported function `emit_store_rax_to_rbx_offset`.
 * Implements `emit_store_rax_to_rbx_offset`.
 * @param out *CodegenOutBuf
 * @param offset i32
 * @param store_size i32
 * @return i32
 */
export function emit_store_rax_to_rbx_offset(out: *CodegenOutBuf, offset: i32, store_size: i32): i32 {
  /* See implementation. */
  let buf: u8[48] = [109, 111, 118, 108, 32, 37, 101, 97, 120, 44, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  if (store_size == 8) {
    buf[3] = 113;
    buf[6] = 114;
  }
  let n: i32 = types.format_i32_to_buf(buf, 11, 12, offset);
  if (n < 0) { return -1; }
  buf[11 + n] = 40;
  buf[12 + n] = 37;
  buf[13 + n] = 114;
  buf[14 + n] = 98;
  buf[15 + n] = 120;
  buf[16 + n] = 41;
  return types.append_asm_line(out, buf, 17 + n);
}

/** Exported function `emit_jz`.
 * Implements `emit_jz`.
 * @param out *CodegenOutBuf
 * @param label *u8
 * @param label_len i32
 * @return i32
 */
export function emit_jz(out: *CodegenOutBuf, label: *u8, label_len: i32): i32 {
  let test_line: u8[32] = [116, 101, 115, 116, 32, 37, 101, 97, 120, 44, 32, 37, 101, 97, 120, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  if (types.append_asm_line(out, test_line, 15) != 0) {
    return -1;
  }
  let buf: u8[40] = [106, 101, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let k: i32 = 0;
  while (k < label_len && k < 32) {
    buf[3 + k] = label[k];
    k = k + 1;
  }
  return types.append_asm_line(out, buf, 3 + label_len);
}

/** Exported function `emit_jeq`.
 * Implements `emit_jeq`.
 * @param out *CodegenOutBuf
 * @param label *u8
 * @param label_len i32
 * @return i32
 */
export function emit_jeq(out: *CodegenOutBuf, label: *u8, label_len: i32): i32 {
  let buf: u8[40] = [106, 101, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let k: i32 = 0;
  while (k < label_len && k < 32) {
    buf[3 + k] = label[k];
    k = k + 1;
  }
  return types.append_asm_line(out, buf, 3 + label_len);
}

/** Exported function `emit_jnz`.
 * Implements `emit_jnz`.
 * @param out *CodegenOutBuf
 * @param label *u8
 * @param label_len i32
 * @return i32
 */
export function emit_jnz(out: *CodegenOutBuf, label: *u8, label_len: i32): i32 {
  let test_line: u8[32] = [116, 101, 115, 116, 32, 37, 101, 97, 120, 44, 32, 37, 101, 97, 120, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  if (types.append_asm_line(out, test_line, 15) != 0) {
    return -1;
  }
  let buf: u8[40] = [106, 110, 101, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let k: i32 = 0;
  while (k < label_len && k < 32) {
    buf[4 + k] = label[k];
    k = k + 1;
  }
  return types.append_asm_line(out, buf, 4 + label_len);
}

/** Exported function `emit_jmp`.
 * Implements `emit_jmp`.
 * @param out *CodegenOutBuf
 * @param label *u8
 * @param label_len i32
 * @return i32
 */
export function emit_jmp(out: *CodegenOutBuf, label: *u8, label_len: i32): i32 {
  let buf: u8[40] = [106, 109, 112, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let k: i32 = 0;
  while (k < label_len && k < 32) {
    buf[4 + k] = label[k];
    k = k + 1;
  }
  return types.append_asm_line(out, buf, 4 + label_len);
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
    let colon: u8[1] = [58];
    out.data[out.len] = colon[0];
    out.len = out.len + 1;
  }
  if (out.len < 8388608) {
    let nl: u8[1] = [10];
    out.data[out.len] = nl[0];
    out.len = out.len + 1;
    return 0;
  }
  return -1;
}

/**
* See implementation.
* See implementation.
*/
export function emit_memset_rbp_zero(out: *CodegenOutBuf, rbp_off: i32, nbytes: i32): i32 {
  if (nbytes <= 0) {
    return 0;
  }
  let lea: u8[48] = [108, 101, 97, 113, 32, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n0: i32 = types.format_i32_to_buf(lea, 6, 12, rbp_off);
  if (n0 < 0) {
    return -1;
  }
  lea[6 + n0] = 40;
  lea[7 + n0] = 37;
  lea[8 + n0] = 114;
  lea[9 + n0] = 98;
  lea[10 + n0] = 112;
  lea[11 + n0] = 41;
  lea[12 + n0] = 44;
  lea[13 + n0] = 32;
  lea[14 + n0] = 37;
  lea[15 + n0] = 114;
  lea[16 + n0] = 100;
  lea[17 + n0] = 105;
  if (types.append_asm_line(out, lea, 18 + n0) != 0) {
    return -1;
  }
  let xr: u8[20] = [120, 111, 114, 108, 32, 37, 101, 115, 105, 44, 32, 37, 101, 115, 105, 0, 0, 0,
  0, 0];
  if (types.append_asm_line(out, xr, 15) != 0) {
    return -1;
  }
  let mv: u8[32] = [109, 111, 118, 108, 32, 36, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n1: i32 = types.format_i32_to_buf(mv, 6, 10, nbytes);
  if (n1 < 0) {
    return -1;
  }
  mv[6 + n1] = 44;
  mv[7 + n1] = 32;
  mv[8 + n1] = 37;
  mv[9 + n1] = 101;
  mv[10 + n1] = 100;
  mv[11 + n1] = 120;
  if (types.append_asm_line(out, mv, 12 + n1) != 0) {
    return -1;
  }
  let cl: u8[16] = [99, 97, 108, 108, 32, 109, 101, 109, 115, 101, 116, 0, 0, 0, 0, 0];
  return types.append_asm_line(out, cl, 11);
}
