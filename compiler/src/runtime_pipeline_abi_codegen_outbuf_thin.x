// Thin pure: wave296/355/521 M2 — pipeline_codegen_outbuf Cap residual C→.x
// (was wave289 C thin). emit_float_lit_c / emit_expr_try_propagate_c.
// wave521 Soft Cap: peer-flat append (see codegen_outbuf_append_thin.x);
//   BSS float/bits buf (ban stack u8[64]); pipe-cell mid n/rc/op (Ubuntu
//   tip mid `x=call()` starve). tipU Soft Cap; stamp → w521;
//   tip PRODUCT reinject HARD BAN (keep prior PREFER overlay).
// G.7: bodies match seeds WAVE289_CODEGEN_OUTBUF_ALWAYS.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.
//
// snprintf is declared fixed-arity (buf, size, fmt, f64): SysV/AAPCS64
// place the first float the same as a variadic "%.17g" call — bit-identical
// to the wave289 C thin host snprintf path.

export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
export extern "C" function snprintf(buf: *u8, size: usize, fmt: *u8, v: f64): i32;
export extern function w521_codegen_out_append_cstr(out: *u8, s: *u8): i32;
export extern function codegen_emit_bytes_from_ptr(out: *u8, p: *u8, n: i32): i32;
export extern function codegen_emit_expr(arena: *u8, out: *u8, expr_ref: i32, ctx: *u8): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;

/* wave521: BSS float scratch — tip CG002 risk on stack u8[64] in shared TU. */
let g_w521_float_buf: u8[64] = [];
let g_w521_bits: u8[8] = [];

/**
 * Reconstruct IEEE f64 from LE lo/hi i32 parts (wave289 union path).
 * PLATFORM: SHARED — freestanding twin of wave289 bits reconstruct.
 */
function w289_f64_from_bits(lo: i32, hi: i32): f64 {
  let out: f64 = 0 as f64;
  unsafe {
    pipe_store_i32_le(&g_w521_bits[0], 0, lo);
    pipe_store_i32_le(&g_w521_bits[0], 4, hi);
    memcpy((&out as *u8), &g_w521_bits[0], 8 as usize);
  }
  return out;
}

/**
 * C-backend float literal emit for codegen emit_expr (EXPR_FLOAT_LIT).
 * Prefer float_val; if 0.0 but bits_lo/hi non-zero, reconstruct via IEEE LE words.
 * Integer-looking tokens get a trailing ".0". Returns 0 on success, -1 on failure.
 * Pipe-cell: ban mid `n=snprintf` / `rc=append_cstr`.
 * PLATFORM: SHARED freestanding Cap leave (wave521 peer-flat).
 */
#[no_mangle]
export function pipeline_codegen_emit_float_lit_c(out: *u8, float_val: f64, bits_lo: i32, bits_hi: i32): i32 {
  let ncell: u8[4] = [];
  let rccell: u8[4] = [];
  let i: i32 = 0;
  let has_dot: i32 = 0;
  let has_e: i32 = 0;
  let v: f64 = float_val;
  let fmt: *u8 = "%.17g";
  if (out == (0 as *u8)) {
    return 0 - 1;
  }
  if (v == (0 as f64) && (bits_lo != 0 || bits_hi != 0)) {
    v = w289_f64_from_bits(bits_lo, bits_hi);
  }
  unsafe {
    pipe_store_i32_le(&ncell[0], 0, snprintf(&g_w521_float_buf[0], 64 as usize, fmt, v));
    if (pipe_load_i32_le(&ncell[0], 0) <= 0 || pipe_load_i32_le(&ncell[0], 0) >= 64) {
      return 0 - 1;
    }
  }
  while (i < 64) {
    unsafe {
      if (i >= pipe_load_i32_le(&ncell[0], 0)) {
        break;
      }
    }
    if (g_w521_float_buf[i] == 46 || g_w521_float_buf[i] == 44) {
      has_dot = 1;
    }
    if (g_w521_float_buf[i] == 101 || g_w521_float_buf[i] == 69) {
      has_e = 1;
    }
    i = i + 1;
  }
  unsafe {
    if (has_dot == 0 && has_e == 0 && pipe_load_i32_le(&ncell[0], 0) < 61) {
      g_w521_float_buf[pipe_load_i32_le(&ncell[0], 0)] = 46;
      pipe_store_i32_le(&ncell[0], 0, pipe_load_i32_le(&ncell[0], 0) + 1);
      g_w521_float_buf[pipe_load_i32_le(&ncell[0], 0)] = 48;
      pipe_store_i32_le(&ncell[0], 0, pipe_load_i32_le(&ncell[0], 0) + 1);
      g_w521_float_buf[pipe_load_i32_le(&ncell[0], 0)] = 0;
    }
    pipe_store_i32_le(&rccell[0], 0, w521_codegen_out_append_cstr(out, &g_w521_float_buf[0]));
  }
  unsafe {
    return pipe_load_i32_le(&rccell[0], 0);
  }
}

/**
 * ERR-01 C codegen: GNU statement-expression desugar for `expr?` try-propagate.
 * Emits `({ struct core_result_Result_i32 __xlang_q = <op>; if (__xlang_q.err != 0)
 * return __xlang_q; __xlang_q.value; })` around operand.
 * Pipe-cell: ban mid `op=/rc=call()`.
 * @return 0 success, -1 on null/bad ref/emit failure.
 * PLATFORM: SHARED freestanding Cap leave (wave521 peer-flat).
 */
#[no_mangle]
export function pipeline_codegen_emit_expr_try_propagate_c(arena: *u8, out: *u8, expr_ref: i32, ctx: *u8): i32 {
  let opcell: u8[4] = [];
  let rccell: u8[4] = [];
  let pre: *u8 = "({ struct core_result_Result_i32 __xlang_q = ";
  let suf: *u8 = "; if (__xlang_q.err != 0) return __xlang_q; __xlang_q.value; })";
  if (arena == (0 as *u8) || out == (0 as *u8) || expr_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&opcell[0], 0, pipeline_expr_unary_operand_ref_at(arena, expr_ref));
    if (pipe_load_i32_le(&opcell[0], 0) <= 0) {
      return 0 - 1;
    }
    pipe_store_i32_le(&rccell[0], 0, codegen_emit_bytes_from_ptr(out, pre, 45));
    if (pipe_load_i32_le(&rccell[0], 0) != 0) {
      return 0 - 1;
    }
    pipe_store_i32_le(&rccell[0], 0, codegen_emit_expr(
      arena, out, pipe_load_i32_le(&opcell[0], 0), ctx
    ));
    if (pipe_load_i32_le(&rccell[0], 0) != 0) {
      return 0 - 1;
    }
    pipe_store_i32_le(&rccell[0], 0, codegen_emit_bytes_from_ptr(out, suf, 63));
  }
  unsafe {
    return pipe_load_i32_le(&rccell[0], 0);
  }
}
