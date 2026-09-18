// Thin pure: wave294/353/520 M2 — pipeline_asm_format_label_id Cap peer.
// Peer-flat Soft Cap (wave520): digit loops live in
// runtime_pipeline_abi_asm_label_digits_thin.x — Ubuntu tip CG002 when
// digits+emit+format_label share one tip TU.
// G.7: body matches seeds WAVE288_ASM_LABEL_FORMAT_ALWAYS format_label_id.
// PRODUCT inject via asm_label_format inject (digits+emit+format_id).
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function w520_format_i32_to_buf(buf: *u8, off: i32, max: i32, val: i32): i32;

/**
 * Format fixed-prefix label ".L_<id>" into buf (does not advance counter).
 * @return total label length (>=4) or -1 on null/undersized buf.
 * PLATFORM: SHARED freestanding Cap leave (wave520 peer-flat).
 */
#[no_mangle]
export function pipeline_asm_format_label_id_c(buf: *u8, buf_size: i32, id: i32): i32 {
  let n: i32 = 0;
  if (buf == (0 as *u8) || buf_size < 4) {
    return 0 - 1;
  }
  buf[0] = 46;
  buf[1] = 76;
  buf[2] = 95;
  unsafe {
    n = w520_format_i32_to_buf(buf, 3, buf_size - 3, id);
  }
  if (n <= 0) {
    n = 1;
  }
  return 3 + n;
}
