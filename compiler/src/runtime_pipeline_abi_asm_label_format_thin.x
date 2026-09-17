// Thin pure: wave294/353 M2 — pipeline_asm_label_format Cap residual C→.x
// (was wave288 C thin). emit_next_label_c / format_label_id_c + local
// decimal format helpers (no snprintf).
// G.7: bodies match seeds/runtime_pipeline_abi.from_x.c
// WAVE288_ASM_LABEL_FORMAT_ALWAYS. No BSS. No FROM_X gate.
// PRODUCT inject wave353: PREFER_ASM both ends (digit loops write into
// caller buf — no local u8[N]; historic w294 Darwin SEGV ban lifted after
// Cap A／FileView). Stamp w353.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.
//
// Note: inventory wave294 _stubs/xlang_x_stubs host wrappers are already
// seed-only (absent). This leaf reuses the wave slot for host-cc→0.

export extern function pipeline_asm_ctx_layout(ctx: *u8): *u8;
export extern function pipeline_elf_label_mod_scope_active(): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/* AsmFuncCtxLayout LE: frame_size@0 next_offset@4 num_locals@8 label_counter@12 */
const W288_OFF_LABEL_COUNTER: i32 = 12;

/**
 * Write unsigned decimal digits of val into buf[off..]. Returns bytes written or -1.
 * No local fixed array: pure-asm `u8[N]` locals have poisoned stack bases
 * (Darwin L2 rv/opt/si SIGSEGV in w288_format_u32_to_buf). Digits go into
 * the caller's buf reversed, then reverse in-place in that slice.
 * PLATFORM: SHARED — freestanding twin of w288_glue_format_u32_to_buf (no snprintf).
 */
function w288_format_u32_to_buf(buf: *u8, off: i32, max: i32, val: i32): i32 {
  let n: i32 = 0;
  let i: i32 = 0;
  let t: i32 = val;
  let dig: i32 = 0;
  let a: u8 = 0;
  if (buf == (0 as *u8) || max <= 0 || off < 0) {
    return -1;
  }
  /* Treat val as unsigned for digit extract when non-negative; clamp neg → 0. */
  if (t < 0) {
    t = 0;
  }
  if (t == 0) {
    if (max < 1) {
      return -1;
    }
    buf[off] = 48;
    return 1;
  }
  /* Write least-significant digit first at buf[off..]; cap at max. */
  while (t > 0) {
    if (n >= max) {
      return -1;
    }
    dig = t % 10;
    buf[off + n] = (48 + dig) as u8;
    n = n + 1;
    t = t / 10;
  }
  /* Reverse buf[off .. off+n) into normal decimal order. */
  i = 0;
  while (i < n / 2) {
    a = buf[off + i];
    buf[off + i] = buf[off + n - 1 - i];
    buf[off + n - 1 - i] = a;
    i = i + 1;
  }
  return n;
}

/**
 * Write signed decimal digits of val into buf[off..]. Returns bytes written or -1.
 * PLATFORM: SHARED — freestanding twin of w288_glue_format_i32_to_buf (no snprintf).
 */
function w288_format_i32_to_buf(buf: *u8, off: i32, max: i32, val: i32): i32 {
  let start: i32 = off;
  let v: i32 = val;
  let n: i32 = 0;
  if (buf == (0 as *u8) || max <= 0 || off < 0) {
    return -1;
  }
  if (v < 0) {
    if (max < 2) {
      return -1;
    }
    buf[off] = 45;
    start = off + 1;
    /* Label ids are small; INT_MIN not expected — clamp magnitude. */
    if (v == (0 - 2147483647 - 1)) {
      v = 2147483647;
    } else {
      v = 0 - v;
    }
    n = w288_format_u32_to_buf(buf, start, max - 1, v);
    if (n < 0) {
      return -1;
    }
    return n + 1;
  }
  return w288_format_u32_to_buf(buf, off, max, v);
}

/**
 * Emit unique local label ".Lf<scope>_<n>" into buf; advance label_counter.
 * @return total label length (>=4) or -1 on null/undersized buf.
 * PLATFORM: SHARED freestanding Cap leave (wave294 .x thin).
 */
#[no_mangle]
export function pipeline_asm_emit_next_label_c(ctx: *u8, buf: *u8, buf_size: i32): i32 {
  let ly: *u8 = 0 as *u8;
  let n: i32 = 0;
  let id: i32 = 0;
  let scope: i32 = 0;
  let off: i32 = 0;
  if (ctx == (0 as *u8) || buf == (0 as *u8) || buf_size < 8) {
    return -1;
  }
  unsafe {
    ly = pipeline_asm_ctx_layout(ctx);
  }
  if (ly == (0 as *u8)) {
    return -1;
  }
  unsafe {
    scope = pipeline_elf_label_mod_scope_active();
  }
  buf[0] = 46;
  buf[1] = 76;
  buf[2] = 102;
  off = 3;
  n = w288_format_u32_to_buf(buf, off, buf_size - off, scope);
  if (n <= 0) {
    n = 1;
  }
  off = off + n;
  if (off + 2 >= buf_size) {
    return -1;
  }
  buf[off] = 95;
  off = off + 1;
  unsafe {
    id = pipe_load_i32_le(ly, W288_OFF_LABEL_COUNTER);
    pipe_store_i32_le(ly, W288_OFF_LABEL_COUNTER, id + 1);
  }
  n = w288_format_u32_to_buf(buf, off, buf_size - off, id);
  if (n <= 0) {
    n = 1;
  }
  return off + n;
}

/**
 * Format fixed-prefix label ".L_<id>" into buf (does not advance counter).
 * @return total label length (>=4) or -1 on null/undersized buf.
 * PLATFORM: SHARED freestanding Cap leave (wave294 .x thin).
 */
#[no_mangle]
export function pipeline_asm_format_label_id_c(buf: *u8, buf_size: i32, id: i32): i32 {
  let n: i32 = 0;
  if (buf == (0 as *u8) || buf_size < 4) {
    return -1;
  }
  buf[0] = 46;
  buf[1] = 76;
  buf[2] = 95;
  n = w288_format_i32_to_buf(buf, 3, buf_size - 3, id);
  if (n <= 0) {
    n = 1;
  }
  return 3 + n;
}
