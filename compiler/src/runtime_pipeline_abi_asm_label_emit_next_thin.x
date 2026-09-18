// Thin pure: wave294/353/520 M2 — pipeline_asm_emit_next_label Cap peer.
// Peer-flat Soft Cap (wave520): digit loops live in
// runtime_pipeline_abi_asm_label_digits_thin.x — Ubuntu tip CG002 when
// digits+emit+format_label share one tip TU.
// G.7: body matches seeds WAVE288_ASM_LABEL_FORMAT_ALWAYS emit_next.
// PRODUCT inject via asm_label_format inject (digits+emit+format_id).
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function pipeline_asm_ctx_layout(ctx: *u8): *u8;
export extern function pipeline_elf_label_mod_scope_active(): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function w520_format_u32_to_buf(buf: *u8, off: i32, max: i32, val: i32): i32;

/* AsmFuncCtxLayout LE: frame_size@0 next_offset@4 num_locals@8 label_counter@12 */
const W288_OFF_LABEL_COUNTER: i32 = 12;

/**
 * Emit unique local label ".Lf<scope>_<n>" into buf; advance label_counter.
 * @return total label length (>=4) or -1 on null/undersized buf.
 * PLATFORM: SHARED freestanding Cap leave (wave520 peer-flat).
 */
#[no_mangle]
export function pipeline_asm_emit_next_label_c(ctx: *u8, buf: *u8, buf_size: i32): i32 {
  let ly: *u8 = 0 as *u8;
  let n: i32 = 0;
  let id: i32 = 0;
  let scope: i32 = 0;
  let off: i32 = 0;
  if (ctx == (0 as *u8) || buf == (0 as *u8) || buf_size < 8) {
    return 0 - 1;
  }
  unsafe {
    ly = pipeline_asm_ctx_layout(ctx);
  }
  if (ly == (0 as *u8)) {
    return 0 - 1;
  }
  unsafe {
    scope = pipeline_elf_label_mod_scope_active();
  }
  buf[0] = 46;
  buf[1] = 76;
  buf[2] = 102;
  off = 3;
  unsafe {
    n = w520_format_u32_to_buf(buf, off, buf_size - off, scope);
  }
  if (n <= 0) {
    n = 1;
  }
  off = off + n;
  if (off + 2 >= buf_size) {
    return 0 - 1;
  }
  buf[off] = 95;
  off = off + 1;
  unsafe {
    id = pipe_load_i32_le(ly, W288_OFF_LABEL_COUNTER);
    pipe_store_i32_le(ly, W288_OFF_LABEL_COUNTER, id + 1);
    n = w520_format_u32_to_buf(buf, off, buf_size - off, id);
  }
  if (n <= 0) {
    n = 1;
  }
  return off + n;
}
