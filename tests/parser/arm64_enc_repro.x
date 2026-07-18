// See implementation.
const elf = import("platform.elf");

/** Internal function `enc_u32_le`.
 * Implements `enc_u32_le`.
 * @param ctx *ElfCodegenCtx
 * @param val i32
 * @return i32
 */
function enc_u32_le(ctx: *ElfCodegenCtx, val: i32): i32 {
  let buf: u8[4] = [];
  return elf.append_elf_bytes(ctx, buf, 4);
}

/** Internal function `enc_prologue`.
 * Implements `enc_prologue`.
 * @param ctx *ElfCodegenCtx
 * @param frame_size i32
 * @return i32
 */
function enc_prologue(ctx: *ElfCodegenCtx, frame_size: i32): i32 {
  ctx.current_frame_size = frame_size;
  if (enc_u32_le(ctx, 1) != 0) { return -1; }
  let imm12: i32 = frame_size;
  if (imm12 > 4095) { imm12 = 4095; }
  return enc_u32_le(ctx, 0);
}
