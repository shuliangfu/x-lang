// Thin pure: wave296 M2 — pipeline_codegen_outbuf Cap residual C→.x
// (was wave289 C thin). emit_float_lit_c / emit_expr_try_propagate_c
// + local append helpers. No BSS. No FROM_X gate.
// G.7: bodies match seeds/runtime_pipeline_abi.from_x.c
// WAVE289_CODEGEN_OUTBUF_ALWAYS.
// PRODUCT inject: -E+$CC via pipeline_abi_inject_codegen_outbuf_thin
// (ALLOW_E_REPLACE + stamp). Local u8[64] + snprintf float face need
// host-cc C twin (same class as w294 digit-loop red under pure-asm).
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.
//
// snprintf is declared fixed-arity (buf, size, fmt, f64): SysV/AAPCS64
// place the first float the same as a variadic "%.17g" call — bit-identical
// to the wave289 C thin host snprintf path.

export extern function codegen_out_buf_len(out: *u8): i32;
export extern function codegen_out_buf_set_len(out: *u8, n: i32): void;
export extern function codegen_emit_bytes_from_ptr(out: *u8, p: *u8, n: i32): i32;
export extern function codegen_emit_expr(arena: *u8, out: *u8, expr_ref: i32, ctx: *u8): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
export extern "C" function snprintf(buf: *u8, size: usize, fmt: *u8, v: f64): i32;

const W289_OUTBUF_CAP: i32 = 9437184;

/**
 * Reconstruct IEEE f64 from LE lo/hi i32 parts (wave289 union path).
 * PLATFORM: SHARED — freestanding twin of wave289 bits reconstruct.
 */
function w289_f64_from_bits(lo: i32, hi: i32): f64 {
  let buf: u8[8];
  let out: f64 = 0 as f64;
  pipe_store_i32_le(&buf[0], 0, lo);
  pipe_store_i32_le(&buf[0], 4, hi);
  unsafe {
    memcpy((&out as *u8), &buf[0], 8 as usize);
  }
  return out;
}

/**
 * Append n bytes from p into out starting at len. Returns 0 / -1.
 * PLATFORM: SHARED — seed ALWAYS residual (wave296 .x thin).
 */
function w289_glue_codegen_out_append_bytes(out: *u8, p: *u8, n: i32): i32 {
  let i: i32 = 0;
  let len: i32 = 0;
  if (out == (0 as *u8) || p == (0 as *u8) || n < 0) {
    return -1;
  }
  unsafe {
    len = codegen_out_buf_len(out);
  }
  while (i < n) {
    if (len >= W289_OUTBUF_CAP - 1) {
      return -1;
    }
    out[len] = p[i];
    len = len + 1;
    i = i + 1;
  }
  unsafe {
    codegen_out_buf_set_len(out, len);
  }
  return 0;
}

/**
 * Append a NUL-terminated C string into out. Null s → 0. Returns 0 / -1.
 * PLATFORM: SHARED — seed ALWAYS residual (wave296 .x thin).
 */
function w289_glue_codegen_out_append_cstr(out: *u8, s: *u8): i32 {
  let one: u8[1];
  if (s == (0 as *u8)) {
    return 0;
  }
  while (s[0] != 0) {
    one[0] = s[0];
    if (w289_glue_codegen_out_append_bytes(out, &one[0], 1) != 0) {
      return -1;
    }
    s = s + 1;
  }
  return 0;
}

/**
 * C-backend float literal emit for codegen emit_expr (EXPR_FLOAT_LIT).
 * Prefer float_val; if 0.0 but bits_lo/hi non-zero, reconstruct via IEEE LE words.
 * Integer-looking tokens get a trailing ".0". Returns 0 on success, -1 on failure.
 * PLATFORM: SHARED freestanding Cap leave (wave296 .x thin · -E+$CC).
 */
#[no_mangle]
export function pipeline_codegen_emit_float_lit_c(out: *u8, float_val: f64, bits_lo: i32, bits_hi: i32): i32 {
  let buf: u8[64];
  let n: i32 = 0;
  let i: i32 = 0;
  let has_dot: i32 = 0;
  let has_e: i32 = 0;
  let v: f64 = float_val;
  let fmt: *u8 = "%.17g";
  if (out == (0 as *u8)) {
    return -1;
  }
  if (v == (0 as f64) && (bits_lo != 0 || bits_hi != 0)) {
    v = w289_f64_from_bits(bits_lo, bits_hi);
  }
  unsafe {
    n = snprintf(&buf[0], 64 as usize, fmt, v);
  }
  if (n <= 0 || n >= 64) {
    return -1;
  }
  while (i < n) {
    if (buf[i] == 46 || buf[i] == 44) {
      has_dot = 1;
    }
    if (buf[i] == 101 || buf[i] == 69) {
      has_e = 1;
    }
    i = i + 1;
  }
  if (has_dot == 0 && has_e == 0 && n < 61) {
    buf[n] = 46;
    n = n + 1;
    buf[n] = 48;
    n = n + 1;
    buf[n] = 0;
  }
  return w289_glue_codegen_out_append_cstr(out, &buf[0]);
}

/**
 * ERR-01 C codegen: GNU statement-expression desugar for `expr?` try-propagate.
 * Emits `({ struct core_result_Result_i32 __xlang_q = <op>; if (__xlang_q.err != 0)
 * return __xlang_q; __xlang_q.value; })` around operand.
 * @return 0 success, -1 on null/bad ref/emit failure.
 * PLATFORM: SHARED freestanding Cap leave (wave296 .x thin).
 */
#[no_mangle]
export function pipeline_codegen_emit_expr_try_propagate_c(arena: *u8, out: *u8, expr_ref: i32, ctx: *u8): i32 {
  let op: i32 = 0;
  let pre: *u8 = "({ struct core_result_Result_i32 __xlang_q = ";
  let suf: *u8 = "; if (__xlang_q.err != 0) return __xlang_q; __xlang_q.value; })";
  let pre_len: i32 = 45;
  let suf_len: i32 = 63;
  let rc: i32 = 0;
  if (arena == (0 as *u8) || out == (0 as *u8) || expr_ref <= 0) {
    return -1;
  }
  unsafe {
    op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  }
  if (op <= 0) {
    return -1;
  }
  unsafe {
    rc = codegen_emit_bytes_from_ptr(out, pre, pre_len);
  }
  if (rc != 0) {
    return -1;
  }
  unsafe {
    rc = codegen_emit_expr(arena, out, op, ctx);
  }
  if (rc != 0) {
    return -1;
  }
  unsafe {
    return codegen_emit_bytes_from_ptr(out, suf, suf_len);
  }
}
