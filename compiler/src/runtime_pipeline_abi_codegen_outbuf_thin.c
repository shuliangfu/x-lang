/*
 * Thin pure: wave289 pipeline_codegen_outbuf Cap residual leave (ALWAYS host-cc).
 * G.7: bodies match seeds/runtime_pipeline_abi.from_x.c
 * WAVE289_CODEGEN_OUTBUF_ALWAYS (emit_float_lit_c / emit_expr_try_propagate_c
 * + file-local append helpers). No BSS. No FROM_X gate.
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED host-cc codegen_outbuf Cap residual leave.
 */

/* XLANG_PABI_CODEGEN_OUTBUF_THIN_BEGIN */

#include <stdint.h>
#include <stdio.h>

#ifndef PIPELINE_CODEGEN_OUTBUF_CAP
#define PIPELINE_CODEGEN_OUTBUF_CAP 9437184
#endif

extern int32_t codegen_out_buf_len(void *out);
extern void codegen_out_buf_set_len(void *out, int32_t n);
extern int32_t codegen_emit_bytes_from_ptr(void *out, uint8_t *p, int32_t n);
extern int32_t codegen_emit_expr(void *arena, void *out, int32_t expr_ref, void *ctx);
extern int32_t pipeline_expr_unary_operand_ref_at(void *arena, int32_t expr_ref);

/**
 * Append n bytes from p into out starting at len. Returns 0 / -1.
 * PLATFORM: SHARED — seed ALWAYS residual (wave289).
 */
static int32_t w289_glue_codegen_out_append_bytes(void *out, const uint8_t *p, int32_t n) {
  int32_t i;
  int32_t len;
  uint8_t *data;
  if (!out || !p || n < 0)
    return -1;
  len = codegen_out_buf_len(out);
  data = (uint8_t *)out;
  for (i = 0; i < n; i++) {
    if (len >= PIPELINE_CODEGEN_OUTBUF_CAP - 1)
      return -1;
    data[len++] = p[i];
  }
  codegen_out_buf_set_len(out, len);
  return 0;
}

/**
 * Append a NUL-terminated C string into out. Null s → 0. Returns 0 / -1.
 * PLATFORM: SHARED — seed ALWAYS residual (wave289).
 */
static int32_t w289_glue_codegen_out_append_cstr(void *out, const char *s) {
  if (!s)
    return 0;
  while (*s) {
    if (w289_glue_codegen_out_append_bytes(out, (const uint8_t *)s, 1) != 0)
      return -1;
    s++;
  }
  return 0;
}

/**
 * C-backend float literal emit for codegen emit_expr (EXPR_FLOAT_LIT).
 * Prefer float_val; if 0.0 but bits_lo/hi non-zero, reconstruct via IEEE LE words.
 * Integer-looking tokens get a trailing ".0". Returns 0 on success, -1 on failure.
 * PLATFORM: SHARED freestanding Cap leave (wave289 seed ALWAYS).
 */
int32_t pipeline_codegen_emit_float_lit_c(void *out, double float_val, int32_t bits_lo, int32_t bits_hi) {
  char buf[64];
  int n;
  int i;
  int has_dot = 0;
  int has_e = 0;
  double v = float_val;
  union {
    double d;
    struct {
      uint32_t lo;
      uint32_t hi;
    } w;
  } u;

  if (!out)
    return -1;
  if (v == 0.0 && (bits_lo != 0 || bits_hi != 0)) {
    u.w.lo = (uint32_t)bits_lo;
    u.w.hi = (uint32_t)bits_hi;
    v = u.d;
  }
  n = snprintf(buf, sizeof(buf), "%.17g", v);
  if (n <= 0 || n >= (int)sizeof(buf))
    return -1;
  for (i = 0; i < n; i++) {
    if (buf[i] == '.' || buf[i] == ',')
      has_dot = 1;
    if (buf[i] == 'e' || buf[i] == 'E')
      has_e = 1;
  }
  if (!has_dot && !has_e && n < (int)sizeof(buf) - 3) {
    buf[n++] = '.';
    buf[n++] = '0';
    buf[n] = '\0';
  }
  return w289_glue_codegen_out_append_cstr(out, buf);
}

/**
 * ERR-01 C codegen: GNU statement-expression desugar for `expr?` try-propagate.
 * Emits `({ struct core_result_Result_i32 __xlang_q = <op>; if (__xlang_q.err != 0)
 * return __xlang_q; __xlang_q.value; })` around operand.
 * @return 0 success, -1 on null/bad ref/emit failure.
 * PLATFORM: SHARED freestanding Cap leave (wave289 seed ALWAYS).
 */
int32_t pipeline_codegen_emit_expr_try_propagate_c(void *arena, void *out, int32_t expr_ref, void *ctx) {
  int32_t op;
  static const uint8_t pre[] = "({ struct core_result_Result_i32 __xlang_q = ";
  static const uint8_t suf[] = "; if (__xlang_q.err != 0) return __xlang_q; __xlang_q.value; })";

  (void)ctx;
  if (!arena || !out || expr_ref <= 0)
    return -1;
  op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  if (op <= 0)
    return -1;
  if (codegen_emit_bytes_from_ptr(out, (uint8_t *)pre, (int32_t)(sizeof(pre) - 1)) != 0)
    return -1;
  if (codegen_emit_expr(arena, out, op, ctx) != 0)
    return -1;
  return codegen_emit_bytes_from_ptr(out, (uint8_t *)suf, (int32_t)(sizeof(suf) - 1));
}

/* XLANG_PABI_CODEGEN_OUTBUF_THIN_END */
