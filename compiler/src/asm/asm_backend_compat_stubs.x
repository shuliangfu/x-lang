// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

export extern "C" function pipeline_elf_ctx_append_bytes(ctx: *u8, ptr: *u8, n: i32): i32;

/** Exported function `asm_backend_compat_stubs_x_doc_anchor`.
 * Implements `asm_backend_compat_stubs_x_doc_anchor`.
 * @return i32
 */
export function asm_backend_compat_stubs_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-99 / G-02f-139：format ---- */

// shu_format_u32_to_buf: see function docblock below.
#[no_mangle]
/** Exported function `shu_format_u32_to_buf`.
 * Implements `shu_format_u32_to_buf`.
 * @param buf *u8
 * @param off i32
 * @param max i32
 * @param u u32
 * @return i32
 */
export function shu_format_u32_to_buf(buf: *u8, off: i32, max: i32, u: u32): i32 {
  if (buf == 0) { return 0 - 1; }
  if (max < 1) { return 0 - 1; }
  let tmp: u8[10] = [];
  let num_digits: i32 = 0;
  let v: u32 = u;
  // digit_chars '0'+d
  while (v > 0) {
    if (num_digits >= 10) { break; }
    let d: u32 = v % 10;
    tmp[num_digits] = (48 + (d as i32)) as u8;
    num_digits = num_digits + 1;
    v = v / 10;
  }
  if (num_digits == 0) {
    buf[off] = 48;
    return 1;
  }
  if (num_digits > max) { return 0 - 1; }
  let idx: i32 = 0;
  while (idx < num_digits) {
    buf[off + idx] = tmp[num_digits - 1 - idx];
    idx = idx + 1;
  }
  return num_digits;
}

#[no_mangle]
/** Exported function `shu_elf_ctx_append_u32_le`.
 * Implements `shu_elf_ctx_append_u32_le`.
 * @param elf_ctx *u8
 * @param word u32
 * @return i32
 */
export function shu_elf_ctx_append_u32_le(elf_ctx: *u8, word: u32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let b0: u8 = (word & 255) as u8;
  let b1: u8 = ((word / 256) & 255) as u8;
  let b2: u8 = ((word / 65536) & 255) as u8;
  let b3: u8 = ((word / 16777216) & 255) as u8;
  let r: i32 = 0;
  unsafe { r = pipeline_elf_ctx_append_bytes(elf_ctx, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = pipeline_elf_ctx_append_bytes(elf_ctx, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = pipeline_elf_ctx_append_bytes(elf_ctx, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = pipeline_elf_ctx_append_bytes(elf_ctx, &b3, 1); }
  return r;
}

#[no_mangle]
/** Exported function `shu_arm64_mov_imm32_to_w0_c`.
 * Implements `shu_arm64_mov_imm32_to_w0_c`.
 * @param elf_ctx *u8
 * @param imm32 i32
 * @return i32
 */
export function shu_arm64_mov_imm32_to_w0_c(elf_ctx: *u8, imm32: i32): i32 {
  // See implementation.
  let u: u32 = imm32 as u32;
  let lo: u32 = u & 65535;
  let hi: u32 = (u / 65536) & 65535;
  // 0x52800000 | (lo << 5)
  if (shu_elf_ctx_append_u32_le(elf_ctx, 1384120320 | (lo * 32)) != 0) {
    return 0 - 1;
  }
  if (hi != 0) {
    // 0x72800000 | (hi << 5)
    if (shu_elf_ctx_append_u32_le(elf_ctx, 1920991232 | (hi * 32)) != 0) {
      return 0 - 1;
    }
  }
  return 0;
}
