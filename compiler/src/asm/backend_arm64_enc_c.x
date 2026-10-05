// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// w1523: pure .x body of src/asm/backend_arm64_enc_c.o.
// It replaces the cc build of seeds/backend_arm64_enc_c.from_x.c.
// Only five helpers were left in that seed. The ARM64 encoders in
// backend_enc_dispatch_thin.x call them:
//   arm64_enc_frame_size_store / arm64_enc_frame_size_load
//   arm64_enc_addsub_sp_imm_chunks
//   arm64_enc_add_rd_rn_imm_chunks
//   arm64_enc_x19_sp_off
// The frame size is a module-level let (the seed used a C static).
// Each instruction word is built in i32 bits. A word above 0x7fffffff is
// written as its negative i32 value. The byte order is little-endian.
// PLATFORM: SHARED. Only the ARM64 target (ta==1) calls these at run time.

/** Anchor so g05 ensure can tell this object is the pure .x build.
 * @return i32 always 0
 */
export function backend_arm64_enc_c_x_doc_anchor(): i32 {
  return 0;
}

export extern "C" function pipeline_elf_ctx_append_bytes(ctx: *u8, ptr: *u8, n: i32): i32;

/** Frame size set by the prologue and read by the epilogue and ret_imm32.
 * Emit is single-threaded. */
let w1523_arm64_enc_frame_size: i32 = 0;

/** Append one ARM64 instruction word as four little-endian bytes.
 * A null context returns -1 and appends nothing.
 * @param elf_ctx *u8 emit context
 * @param word i32 instruction bits
 * @return i32 0 on success, -1 on failure
 */
function w1523_arm64_enc_u32_le(elf_ctx: *u8, word: i32): i32 {
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  let w: u32 = word as u32;
  let b: u8[4] = [0, 0, 0, 0];
  b[0] = (w & 255) as u8;
  b[1] = ((w >> 8) & 255) as u8;
  b[2] = ((w >> 16) & 255) as u8;
  b[3] = ((w >> 24) & 255) as u8;
  unsafe {
    return pipeline_elf_ctx_append_bytes(elf_ctx, &b[0], 4);
  }
}

/** Store the frame size for the epilogue.
 * A null context returns -1 and leaves the stored size unchanged.
 * @param elf_ctx *u8 emit context
 * @param fs i32 frame bytes
 * @return i32 0 on success, -1 on a null context
 */
#[no_mangle]
export function arm64_enc_frame_size_store(elf_ctx: *u8, fs: i32): i32 {
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  w1523_arm64_enc_frame_size = fs;
  return 0;
}

/** Read the frame size stored by the prologue.
 * @return i32 stored frame bytes
 */
#[no_mangle]
export function arm64_enc_frame_size_load(): i32 {
  return w1523_arm64_enc_frame_size;
}

/** Move SP by imm bytes in chunks of at most 4080.
 * A negative imm is treated as 0.
 * sub sp,sp,#c is 0xD10003FF | (c << 10). add sp,sp,#c is 0x910003FF | (c << 10).
 * @param elf_ctx *u8 emit context
 * @param imm i32 byte delta
 * @param is_sub i32 nonzero for sub, 0 for add
 * @return i32 0 on success, -1 on failure
 */
#[no_mangle]
export function arm64_enc_addsub_sp_imm_chunks(elf_ctx: *u8, imm: i32, is_sub: i32): i32 {
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  let base: i32 = 0 - 1862269953;
  if (is_sub != 0) {
    base = 0 - 788528129;
  }
  let left: i32 = imm;
  if (left < 0) {
    left = 0;
  }
  /* AAPCS64: SP must stay 16-byte aligned. imm12 max for ADD/SUB is 4095,
   * but 4095%16==15 misaligns SP after each chunk and crashes on stp/ldp.
   * Use 4080 (0xFF0) — largest 12-bit multiple of 16. w2060 Darwin parser
   * pure-asm SEGV (parser_parse_into_buf) traced to repeated sub sp,#0xfff. */
  while (left > 0) {
    let chunk: i32 = left;
    if (chunk > 4080) {
      chunk = 4080;
    }
    if (w1523_arm64_enc_u32_le(elf_ctx, base | (chunk << 10)) != 0) {
      return 0 - 1;
    }
    left = left - chunk;
  }
  return 0;
}

/** ADD Xd, Xn, #imm with chunks of at most 4080 (match SP).
 * When rd differs from rn, mov xd,xn (0xAA0003E0 | rn << 16 | rd) comes first.
 * A negative imm emits SUB chunks. INT_MIN is refused.
 * add xd,xd,#c is 0x91000000. sub xd,xd,#c is 0xD1000000.
 * @param elf_ctx *u8 emit context
 * @param rd i32 destination register 0..30
 * @param rn i32 source register 0..30
 * @param imm i32 signed byte addend
 * @return i32 0 on success, -1 on failure
 */
#[no_mangle]
export function arm64_enc_add_rd_rn_imm_chunks(elf_ctx: *u8, rd: i32, rn: i32, imm: i32): i32 {
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (rd < 0) {
    return 0 - 1;
  }
  if (rd > 30) {
    return 0 - 1;
  }
  if (rn < 0) {
    return 0 - 1;
  }
  if (rn > 30) {
    return 0 - 1;
  }
  let base: i32 = 0 - 1862270976;
  let left: i32 = imm;
  if (left < 0) {
    if (left == 0 - 2147483647 - 1) {
      return 0 - 1;
    }
    base = 0 - 788529152;
    left = 0 - left;
  }
  if (rd != rn) {
    if (w1523_arm64_enc_u32_le(elf_ctx, (0 - 1442839584) | (rn << 16) | rd) != 0) {
      return 0 - 1;
    }
  }
  let rdrd: i32 = (rd << 5) | rd;
  /* Match arm64_enc_addsub_sp_imm_chunks: 4080 not 4095. Tip parse_into_buf
   * did sub sp,#0xff0 then add x16,#0xfff — frame locals drifted and
   * return stmts were not seen (implicit tail return). */
  while (left > 0) {
    let chunk: i32 = left;
    if (chunk > 4080) {
      chunk = 4080;
    }
    if (w1523_arm64_enc_u32_le(elf_ctx, base | (chunk << 10) | rdrd) != 0) {
      return 0 - 1;
    }
    left = left - chunk;
  }
  return 0;
}

/** Save or restore x19 at [sp, #off].
 * off must be at least 0 and a multiple of 8.
 * Up to 32760 uses one STR/LDR (0xF90003F3 / 0xF94003F3 | (off/8) << 10).
 * Larger offsets build x16 = sp + off (0x910003F0, then 0x91000210 | c << 10)
 * and use str/ldr x19,[x16] (0xF9000213 / 0xF9400213).
 * @param elf_ctx *u8 emit context
 * @param off i32 byte offset from SP
 * @param is_ldr i32 nonzero for LDR, 0 for STR
 * @return i32 0 on success, -1 on failure
 */
#[no_mangle]
export function arm64_enc_x19_sp_off(elf_ctx: *u8, off: i32, is_ldr: i32): i32 {
  if (elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (off < 0) {
    return 0 - 1;
  }
  if ((off & 7) != 0) {
    return 0 - 1;
  }
  if (off <= 32760) {
    let base: i32 = 0 - 117439501;
    if (is_ldr != 0) {
      base = 0 - 113245197;
    }
    let scaled: i32 = off >> 3;
    return w1523_arm64_enc_u32_le(elf_ctx, base | (scaled << 10));
  }
  if (w1523_arm64_enc_u32_le(elf_ctx, 0 - 1862269968) != 0) {
    return 0 - 1;
  }
  let left: i32 = off;
  /* Same 4080 chunk as SP adjust — keep [sp+#off] address math aligned. */
  while (left > 0) {
    let chunk: i32 = left;
    if (chunk > 4080) {
      chunk = 4080;
    }
    if (w1523_arm64_enc_u32_le(elf_ctx, (0 - 1862270448) | (chunk << 10)) != 0) {
      return 0 - 1;
    }
    left = left - chunk;
  }
  let fin: i32 = 0 - 117439981;
  if (is_ldr != 0) {
    fin = 0 - 113245677;
  }
  return w1523_arm64_enc_u32_le(elf_ctx, fin);
}
