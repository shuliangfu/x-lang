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
