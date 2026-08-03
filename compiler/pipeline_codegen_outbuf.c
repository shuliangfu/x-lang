/**
 * pipeline_codegen_outbuf.c — C-backend CodegenOutBuf append domain (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for appending bytes / cstr / int / byte into the
 * CodegenOutBuf struct whose layout mirrors ast_pool's codegen_out_buf_len:
 *   data[PIPELINE_CODEGEN_OUTBUF_CAP] + len
 *
 * Members (wave1101 G.7 migration from pipeline_glue.c):
 * - glue_codegen_out_append_bytes (raw byte append with capacity gate)
 * - glue_codegen_out_append_cstr  (NUL-terminated C string append)
 * - glue_codegen_out_append_int   (decimal int32 via snprintf)
 * - glue_codegen_out_append_byte  (single byte convenience wrapper)
 *
 * Callers: pipeline_codegen_emit_float_lit_c, pipeline_codegen_emit_array_*,
 * and other C-backend emit functions in pipeline_glue.c (all after #include).
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c at the
 * original definition site (L854). All members remain static (same-TU).
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

#ifndef PIPELINE_CODEGEN_OUTBUF_CAP
#define PIPELINE_CODEGEN_OUTBUF_CAP 9437184
#endif

/**
 * Append n bytes from p into out->data starting at out->len.
 *
 * Why: C-backend codegen emit writes tokens (identifiers, keywords, numeric
 * literals, punctuation) into a flat byte buffer for later flush. The
 * CodegenOutBuf layout matches ast_pool's codegen_out_buf_len so the same
 * reader works on both sides.
 *
 * Invariant: Returns 0 on success; -1 on null out/p, negative n, or
 * capacity overflow (len would exceed PIPELINE_CODEGEN_OUTBUF_CAP - 1).
 * The -1 sentinel preserves one trailing byte for NUL termination safety.
 *
 * Asm/Perf: O(n) byte copy — no realloc, no format parsing. Cold path
 * (codegen emit, not runtime).
 *
 * PLATFORM: SHARED — pure byte buffer append, no arch dependency.
 */
static int32_t glue_codegen_out_append_bytes(struct codegen_CodegenOutBuf *out, const uint8_t *p, int32_t n) {
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
 * Append a NUL-terminated C string into out.
 *
 * Why: C-backend codegen frequently emits fixed keywords / operators /
 * format fragments as string literals (e.g. " .data = ", "(sizeof(").
 *
 * Invariant: Returns 0 on success (including null s → no-op return 0);
 * -1 if any byte append overflows capacity.
 *
 * Asm/Perf: O(strlen(s)) — delegates to glue_codegen_out_append_bytes per
 * byte. Cold path (codegen emit).
 *
 * PLATFORM: SHARED.
 */
static int32_t glue_codegen_out_append_cstr(struct codegen_CodegenOutBuf *out, const char *s) {
  if (!s)
    return 0;
  while (*s) {
    if (glue_codegen_out_append_bytes(out, (const uint8_t *)s, 1) != 0)
      return -1;
    s++;
  }
  return 0;
}

/**
 * Append a decimal int32 as ASCII into out.
 *
 * Why: C-backend codegen emits array sizes, struct field counts, and
 * numeric constants as decimal tokens.
 *
 * Invariant: Returns 0 on success; -1 if the formatted string exceeds
 * 16 chars or append overflows capacity.
 *
 * Asm/Perf: O(log10(v)) — snprintf + cstr append. Cold path.
 *
 * PLATFORM: SHARED.
 */
static int32_t glue_codegen_out_append_int(struct codegen_CodegenOutBuf *out, int32_t v) {
  char buf[16];
  snprintf(buf, sizeof(buf), "%d", v);
  return glue_codegen_out_append_cstr(out, buf);
}

/**
 * Append a single byte into out.
 *
 * Why: C-backend codegen emits punctuation ('{', '.', ',', etc.) one byte
 * at a time for readability over performance (emit is cold).
 *
 * Invariant: Returns 0 on success; -1 on capacity overflow.
 *
 * Asm/Perf: O(1) — delegates to glue_codegen_out_append_bytes. Cold path.
 *
 * PLATFORM: SHARED.
 */
static int32_t glue_codegen_out_append_byte(struct codegen_CodegenOutBuf *out, uint8_t b) {
  return glue_codegen_out_append_bytes(out, &b, 1);
}

/* wave1215: pipeline_expr_unary_operand_ref_at extern fwd decl — definition
 * is extern (ast_pool_expr.c). Original fwd decl at glue.c L1050 is AFTER
 * this file's #include at L445; needed for wave1215-migrated
 * pipeline_codegen_emit_expr_try_propagate_c at EOF. */
extern int32_t pipeline_expr_unary_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref);

/* ========================================================================== *
 * wave1215 G.7: pipeline_codegen_emit_expr_try_propagate_c migrated from
 * pipeline_glue.c L4138-4158. Colocated with C-backend codegen outbuf domain
 * (this file; #include at glue.c L445).
 *
 * Members (1 fn):
 *  - pipeline_codegen_emit_expr_try_propagate_c (ERR-01 GNU stmt expr desugar)
 *
 * Deps:
 *  - pipeline_expr_unary_operand_ref_at (extern fwd decl above; original
 *    glue.c L1050 is after L445)
 *  - codegen_emit_expr / codegen_emit_bytes_from_ptr (extern, declared
 *    in-function-body — same pattern as original)
 *
 * Callers: no TU-internal callsites. Sole callers are seeds
 * (codegen.x / runtime_pipeline_abi.x) via extern.
 *
 * PLATFORM: SHARED — C codegen path, no arch branch.
 * ========================================================================== */

/**
 * ERR-01 C codegen: GNU statement expression desugar for `expr?` operator.
 *
 * Why: the `?` operator (try-propagate) needs to early-return on error and
 *      unwrap the value on success. In C codegen, this is expressed via
 *      GNU statement expressions: `({ Result __q = <expr>; if (__q.err) return __q; __q.value; })`.
 *      This function emits the pre/suf wrapper around the operand expr.
 * Contract: NULL arena/out or expr_ref<=0 -> -1; op<=0 -> -1.
 *           Returns 0 on success, -1 on failure.
 * Asm/Perf: O(1) — two byte appends + one recursive codegen_emit_expr call.
 * PLATFORM: SHARED — C codegen path, no arch branch.
 */
int32_t pipeline_codegen_emit_expr_try_propagate_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                                   int32_t expr_ref, struct ast_PipelineDepCtx *ctx) {
  extern int32_t codegen_emit_expr(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out, int32_t expr_ref,
                                   struct ast_PipelineDepCtx *ctx);
  extern int32_t codegen_emit_bytes_from_ptr(struct codegen_CodegenOutBuf *out, uint8_t *p, int32_t n);
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

/* wave1235 G.7: pipeline_codegen_emit_float_lit_c migrated from pipeline_glue.c
 * to this file's EOF (colocated with sole callee glue_codegen_out_append_cstr
 * at L76 — codegen outbuf append domain). Deps: struct codegen_CodegenOutBuf
 * (global) + snprintf (libc, visible via glue.c TU #include chain).
 * Sole extern caller: codegen_gen.c L10593 + codegen.x seed.
 * PLATFORM: SHARED. */

/**
 * C-backend float literal emit for codegen.x emit_expr (EXPR_FLOAT_LIT).
 * Purpose: host snprintf of a real decimal/hex-free C double token into CodegenOutBuf.
 * Prefer float_val; if float_val is 0.0 but bits_lo/hi are non-zero, reconstruct via IEEE bits
 * (little-endian lo/hi layout matches typeck_float64_bits_lo/hi).
 * Returns 0 on success, -1 on failure. Integer-looking tokens get a trailing ".0".
 * PLATFORM: SHARED — product M2 force-regen of codegen.x links this; also mirrored in
 * seeds/pipeline_glue_strict_minimal.from_x.c for Darwin g05 (no full standalone glue).
 */
int32_t pipeline_codegen_emit_float_lit_c(struct codegen_CodegenOutBuf *out, double float_val,
                                         int32_t bits_lo, int32_t bits_hi) {
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
  return glue_codegen_out_append_cstr(out, buf);
}
