/* leftover_fromat eq battery — 7.2.1b v5.60
 *
 * leftover_helpers whose ABI is (at_kind, ident_kind, source, ident_start,
 * ident_len, lex_after_ident) are already .x T in pthin_stretch_audit.x,
 * but they have no k_cases row: the generator only tables lex:/lex_inout:
 * audits. twins.h also keeps a static C copy of
 * simd_builtin_deep_from_at under the product name so c_ref twins keep
 * C authority — that static shadows the .x T in the harness TU.
 *
 * This TU does NOT include twins.h. It links audit_x.o (product .x)
 * and compares against an inline copy of the gated C twin (same body
 * as the suite leftover helper under FROM_X). Source is an opaque
 * parser_asm_slice_u8*; .x takes *u8. lex_after_ident is an opaque
 * lexer cursor after the ident (C copies *lex then walks; .x passes
 * through paren_expr_head which restore-trios — both net-zero).
 *
 * Flattened body (v5.42) is a thin combinator of simd_builtin +
 * vector_type_ident (IDENT only) + paren_expr_head + builtin_vec_token.
 * This file inlines the gated C sub-bodies (spelling / i3x*|Vec*|
 * bind_name_validate / LPAREN-not-RPAREN walk / seven vec kinds)
 * rather than copying classify / keyword / score tables (G.7).
 *
 * Honest flatten lock (do not "fix"):
 *   !source || at_kind != AT → 0
 *   C skips paren when lex_after_ident is null; .x always calls
 *   paren_expr_head, which returns 0 on null lex. Return values agree.
 *   Any sub-score > 0 → 1.
 *
 * Corpus is exhaustive TokenKind on each kind slot with null lex,
 * AT+IDENT ident spelling / length / token_start corners (null lex),
 * builtin_vec kinds, and short live-lex snippets at a few start-pos
 * (not a file-offset walk of product .x files). Do not feed a nodata
 * slice to a live lex (lexer_next_into would see a null data pointer).
 *
 * Homogeneous family is simd_builtin_deep_from_at only — this is the
 * last leftover_helper. classify / import_path_score stay stretch.x
 * (G.7; not leftover-to-audit). PLATFORM: SHARED — compiled into the
 * existing eq harness.
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "token.h"

struct parser_asm_slice_u8 {
  uint8_t *data;
  size_t length;
};

struct parser_asm_lexer {
  size_t pos;
  int32_t line;
  int32_t col;
};

struct parser_asm_token {
  int32_t kind;
  int32_t line;
  int32_t col;
  int64_t int_val;
  double float_val;
  uint8_t *ident;
  int32_t ident_len;
};

struct parser_asm_lexer_result {
  struct parser_asm_lexer next_lex;
  struct parser_asm_token tok;
  size_t token_start;
};

extern int32_t parser_asm_stretch_simd_builtin_deep_from_at_audit_c(
    int32_t at_kind, int32_t ident_kind, const uint8_t *source, size_t ident_start,
    int32_t ident_len, const uint8_t *lex_after_ident);

extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                            struct parser_asm_slice_u8 *source);

/* Harness TU (twins.h) already exports the C bind_name_validate authority. */
extern int32_t parser_asm_stretch_bind_name_validate_c(const uint8_t *name, int32_t len);

static struct parser_asm_lexer lex_init(void) {
  struct parser_asm_lexer lex;
  lex.pos = 0;
  lex.line = 1;
  lex.col = 1;
  return lex;
}

static int lex_eq(const struct parser_asm_lexer *a, const struct parser_asm_lexer *b) {
  return a->pos == b->pos && a->line == b->line && a->col == b->col;
}

/* Gated C sub-bodies (suite leftover helpers / twins.h). Static names
 * do not collide with the .x T symbols resolved from audit_x.o. */
static int32_t c_ref_simd_builtin(int32_t at_kind, int32_t ident_kind,
                                  struct parser_asm_slice_u8 *source, size_t ident_start,
                                  int32_t ident_len) {
  if (!source || !source->data)
    return 0;
  if (at_kind != (int32_t)TOKEN_AT || ident_kind != (int32_t)TOKEN_IDENT || ident_len <= 0)
    return 0;
  if (ident_len == 7 && ident_start + 6 < source->length && source->data[ident_start] == 115
      && source->data[ident_start + 1] == 104 && source->data[ident_start + 2] == 117
      && source->data[ident_start + 3] == 102 && source->data[ident_start + 4] == 102
      && source->data[ident_start + 5] == 108 && source->data[ident_start + 6] == 101)
    return 1;
  if (ident_len == 6 && ident_start + 5 < source->length && source->data[ident_start] == 115
      && source->data[ident_start + 1] == 101 && source->data[ident_start + 2] == 108
      && source->data[ident_start + 3] == 101 && source->data[ident_start + 4] == 99
      && source->data[ident_start + 5] == 116)
    return 1;
  return 0;
}

static int32_t c_ref_vector_type_ident(struct parser_asm_slice_u8 *source, size_t token_start,
                                      int32_t nlen) {
  uint8_t name_buf[64];
  int32_t i;
  if (!source || nlen <= 0 || nlen > 63)
    return 0;
  for (i = 0; i < nlen && token_start + (size_t)i < source->length; i++)
    name_buf[i] = source->data[token_start + (size_t)i];
  name_buf[i < 63 ? i : 63] = 0;
  if (nlen == 5 && name_buf[0] == 105 && name_buf[1] == 51 && name_buf[2] == 120)
    return 1;
  if (nlen >= 5 && name_buf[0] == 86 && name_buf[1] == 101 && name_buf[2] == 99)
    return 1;
  return parser_asm_stretch_bind_name_validate_c(name_buf, nlen);
}

static int32_t c_ref_paren_expr_head(void *lex_inout, void *source) {
  struct parser_asm_lexer lex;
  struct parser_asm_lexer_result r;
  if (!lex_inout || !source)
    return 0;
  lex = *(struct parser_asm_lexer *)lex_inout;
  lexer_next_into(&r, lex, (struct parser_asm_slice_u8 *)source);
  if (r.tok.kind != (int32_t)TOKEN_LPAREN)
    return 0;
  lexer_next_into(&r, r.next_lex, (struct parser_asm_slice_u8 *)source);
  return r.tok.kind != (int32_t)TOKEN_RPAREN ? 1 : 0;
}

static int32_t c_ref_builtin_vec_token(int32_t kind) {
  return kind == (int32_t)TOKEN_I32X4 || kind == (int32_t)TOKEN_I32X8 || kind == (int32_t)TOKEN_I32X16
                 || kind == (int32_t)TOKEN_U32X4 || kind == (int32_t)TOKEN_U32X8
                 || kind == (int32_t)TOKEN_U32X16 || kind == (int32_t)TOKEN_F32X4
             ? 1
             : 0;
}

static int32_t c_ref_from_at(int32_t at_kind, int32_t ident_kind, struct parser_asm_slice_u8 *source,
                            size_t ident_start, int32_t ident_len, void *lex_after_ident) {
  struct parser_asm_lexer lex_after;
  int32_t score;
  if (!source || at_kind != (int32_t)TOKEN_AT)
    return 0;
  score = c_ref_simd_builtin(at_kind, ident_kind, source, ident_start, ident_len);
  if (ident_kind == (int32_t)TOKEN_IDENT)
    score += c_ref_vector_type_ident(source, ident_start, ident_len);
  if (lex_after_ident) {
    lex_after = *(struct parser_asm_lexer *)lex_after_ident;
    score += c_ref_paren_expr_head(&lex_after, source);
  }
  score += c_ref_builtin_vec_token(ident_kind);
  return score > 0 ? 1 : 0;
}

static int leftover_fromat_selected(const char *name) {
  const char *only = getenv("EQ_ONLY");
  char buf[2048];
  size_t n;
  char *tok;
  char *save;
  if (!only || !only[0])
    return 1;
  n = strlen(only);
  if (n >= sizeof(buf))
    n = sizeof(buf) - 1;
  memcpy(buf, only, n);
  buf[n] = 0;
  for (tok = strtok_r(buf, ",", &save); tok; tok = strtok_r(0, ",", &save)) {
    while (*tok == ' ' || *tok == '\t')
      tok++;
    if (!*tok)
      continue;
    if (strstr(name, tok))
      return 1;
  }
  return 0;
}

static void dump_span(const uint8_t *data, size_t ident_start, int32_t ident_len) {
  int32_t i;
  int32_t n;
  if (!data) {
    printf("(null-data)");
    return;
  }
  n = ident_len;
  if (n < 0)
    n = 0;
  if (n > 16)
    n = 16;
  for (i = 0; i < n; i++)
    printf("%02x", (unsigned)data[ident_start + (size_t)i]);
  if (ident_len > 16)
    printf("...");
}

static int check_one(const char *tag, int32_t at_kind, int32_t ident_kind,
                     struct parser_asm_slice_u8 *sl, size_t ident_start, int32_t ident_len,
                     struct parser_asm_lexer *lex, long *checks, int *fail) {
  struct parser_asm_lexer lex_x;
  struct parser_asm_lexer lex_c;
  struct parser_asm_lexer lex0;
  const uint8_t *xsrc;
  const uint8_t *xlex;
  int32_t xv;
  int32_t cv;
  int mismatch;

  lex0 = lex ? *lex : lex_init();
  lex_x = lex0;
  lex_c = lex0;
  xsrc = sl ? (const uint8_t *)sl : 0;
  xlex = lex ? (const uint8_t *)&lex_x : 0;
  xv = parser_asm_stretch_simd_builtin_deep_from_at_audit_c(at_kind, ident_kind, xsrc, ident_start,
                                                           ident_len, xlex);
  cv = c_ref_from_at(at_kind, ident_kind, sl, ident_start, ident_len, lex ? (void *)&lex_c : 0);
  if (checks)
    (*checks)++;
  mismatch = xv != cv;
  if (!mismatch && lex && (!lex_eq(&lex_x, &lex0) || !lex_eq(&lex_c, &lex0)))
    mismatch = 1;
  if (mismatch) {
    printf("FAIL leftover_fromat %s at=%d ident=%d off=%zu len=%d .x=%d c=%d span=", tag, (int)at_kind,
           (int)ident_kind, (size_t)ident_start, (int)ident_len, (int)xv, (int)cv);
    dump_span(sl && sl->data ? sl->data : 0, ident_start, ident_len);
    if (lex)
      printf(" lex_x=%zu/%d/%d lex_c=%zu/%d/%d orig=%zu/%d/%d", (size_t)lex_x.pos, (int)lex_x.line,
             (int)lex_x.col, (size_t)lex_c.pos, (int)lex_c.line, (int)lex_c.col, (size_t)lex0.pos,
             (int)lex0.line, (int)lex0.col);
    printf("\n");
    if (fail)
      (*fail)++;
    return 1;
  }
  return 0;
}

/**
 * leftover_fromat eq over exhaustive TokenKind on each kind slot (null
 * lex) plus AT+IDENT ident corners and short live-lex snippets.
 * Caller owns checks/fail counters.
 * @param checks long* — incremented per (case, sample) pair; null ignored
 * @param fail int* — incremented on mismatch; null ignored
 * @return int — 0 ok; 1 if any mismatch
 * PLATFORM: SHARED.
 */
int leftover_fromat_eq_run(long *checks, int *fail) {
  static const int32_t k_extra[] = {-1, -2, 256, 512, 1024, 0x7fffffff};
  static const int32_t k_null_lens[] = {-1, 0, 1, 4, 6, 7, 63, 64, 100};
  static const size_t k_null_offs[] = {0, 1, 8};
  static const int32_t k_lens[] = {0, 1, 5, 6, 7, 8, 63, 64, 65};
  static const size_t k_offs[] = {0, 1, 7, 8, 64};
  static const char *k_lits[] = {"",         "a",      "shuffle", "select", "Shuffle", "SELECT",
                                 "shuffl",   "selects", "shufflex", "i32x4",  "i3x4",    "Vec4",
                                 "Vec4f",    "as",      "main",     "foo_bar", " ",      "\n",
                                 "fn",       "@shuffle", "123",     "i32x",   "vec4"};
  static const int32_t k_vec[] = {
      (int32_t)TOKEN_I32X4, (int32_t)TOKEN_I32X8, (int32_t)TOKEN_I32X16, (int32_t)TOKEN_U32X4,
      (int32_t)TOKEN_U32X8, (int32_t)TOKEN_U32X16, (int32_t)TOKEN_F32X4, (int32_t)TOKEN_I32,
      (int32_t)TOKEN_IDENT, (int32_t)TOKEN_LPAREN,
  };
  static const char *k_snips[] = {
      "",       " ",      "\n",     "a",      "(",     "()",     "(x)",    "(x,y)",
      ")",      "i32x4",  "@",      "@shuffle", "@shuffle()", "foo()", " (x)",
      "((x))",  "( )",    "(;",     "(\n)",
  };
  static const size_t k_pos[] = {0, 1, 2};
  int any_fail = 0;
  int32_t b;
  int32_t kind;
  int32_t last = (int32_t)TOKEN_NULL;
  size_t li;
  size_t ni;
  size_t oi;
  size_t ei;
  size_t vi;
  size_t si;
  size_t pi;
  uint8_t buf[512];
  struct parser_asm_slice_u8 sl;
  struct parser_asm_slice_u8 sl_nodata;
  uint8_t tiny[32];
  struct parser_asm_slice_u8 sl_tiny;
  struct parser_asm_lexer lex;
  struct parser_asm_slice_u8 sl_snip;

  if (!leftover_fromat_selected("simd_builtin_deep_from_at"))
    return 0;

  memset(buf, (int)'x', sizeof(buf));
  memcpy(buf + 8, "shuffle", 7);
  sl.data = buf;
  sl.length = sizeof(buf);
  sl_nodata.data = 0;
  sl_nodata.length = 0;
  lex = lex_init();

  /* Kind gating with null lex: exhaustive at_kind (ident=IDENT) and
   * ident_kind (at=AT). Return only depends on AT plus any sub-score;
   * paren is skipped (C) / null-lex 0 (.x). */
  for (kind = 0; kind <= last + 8; kind++) {
    if (check_one("kind_at_nullsrc", kind, (int32_t)TOKEN_IDENT, 0, 0, 0, 0, checks, fail))
      any_fail = 1;
    if (check_one("kind_at_live", kind, (int32_t)TOKEN_IDENT, &sl, 8, 7, 0, checks, fail))
      any_fail = 1;
    if (check_one("kind_ident_nullsrc", (int32_t)TOKEN_AT, kind, 0, 0, 0, 0, checks, fail))
      any_fail = 1;
    if (check_one("kind_ident_live", (int32_t)TOKEN_AT, kind, &sl, 8, 7, 0, checks, fail))
      any_fail = 1;
  }
  for (ei = 0; ei < sizeof(k_extra) / sizeof(k_extra[0]); ei++) {
    if (check_one("extra_at_nullsrc", k_extra[ei], (int32_t)TOKEN_IDENT, 0, 0, 0, 0, checks, fail))
      any_fail = 1;
    if (check_one("extra_at_live", k_extra[ei], (int32_t)TOKEN_IDENT, &sl, 8, 7, 0, checks, fail))
      any_fail = 1;
    if (check_one("extra_ident_nullsrc", (int32_t)TOKEN_AT, k_extra[ei], 0, 0, 0, 0, checks, fail))
      any_fail = 1;
    if (check_one("extra_ident_live", (int32_t)TOKEN_AT, k_extra[ei], &sl, 8, 7, 0, checks, fail))
      any_fail = 1;
  }

  /* Non-null slice with data==0 + null lex: C simd early-outs on !data;
   * vector copies 0 bytes when length==0. Do not pair with live lex. */
  if (check_one("nodata", (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, &sl_nodata, 0, 7, 0, checks,
                fail))
    any_fail = 1;

  for (oi = 0; oi < sizeof(k_null_offs) / sizeof(k_null_offs[0]); oi++) {
    for (ni = 0; ni < sizeof(k_null_lens) / sizeof(k_null_lens[0]); ni++) {
      if (check_one("nullsrc_offlen", (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, 0, k_null_offs[oi],
                    k_null_lens[ni], 0, checks, fail))
        any_fail = 1;
    }
  }

  /* First-byte class on a 7-byte "shuffle" span (null lex). */
  memcpy(buf + 8, "shuffle", 7);
  for (b = 0; b < 256; b++) {
    buf[8] = (uint8_t)b;
    if (check_one("shuffle_b0", (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, &sl, 8, 7, 0, checks,
                  fail))
      any_fail = 1;
  }
  memcpy(buf + 8, "shuffle", 7);

  for (oi = 0; oi < sizeof(k_offs) / sizeof(k_offs[0]); oi++) {
    for (ni = 0; ni < sizeof(k_lens) / sizeof(k_lens[0]); ni++) {
      size_t off = k_offs[oi];
      int32_t n = k_lens[ni];
      if (n > 0 && off + (size_t)n > sl.length)
        continue;
      memcpy(buf + off, "shuffle", 7);
      if (check_one("offlen_shuffle", (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, &sl, off, n, 0,
                    checks, fail))
        any_fail = 1;
      memcpy(buf + off, "select", 6);
      if (check_one("offlen_select", (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, &sl, off, n, 0,
                    checks, fail))
        any_fail = 1;
      memcpy(buf + off, "i32x4", 5);
      if (check_one("offlen_i32x4", (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, &sl, off, n, 0,
                    checks, fail))
        any_fail = 1;
      memcpy(buf + off, "Vec4f", 5);
      if (check_one("offlen_Vec4f", (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, &sl, off, n, 0,
                    checks, fail))
        any_fail = 1;
      memset(buf + off, (int)'x', 7);
    }
  }
  memcpy(buf + 8, "shuffle", 7);

  for (li = 0; li < sizeof(k_lits) / sizeof(k_lits[0]); li++) {
    const uint8_t *p = (const uint8_t *)k_lits[li];
    int32_t n = (int32_t)strlen(k_lits[li]);
    if (n > 0)
      memcpy(buf + 8, p, (size_t)n);
    if (check_one("lit", (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, &sl, 8, n, 0, checks, fail))
      any_fail = 1;
    if (n > 0)
      memset(buf + 8, (int)'x', (size_t)n);
  }
  memcpy(buf + 8, "shuffle", 7);

  /* Tight in-bounds source->length (remaining >= ident_len). Do not feed
   * IDENT spans with off+nlen > length: .x vector_type_ident unwraps
   * data+off and would read past the slice cap, while C copies only
   * in-bounds bytes — leftover_sourceoff already locked that rule.
   * simd_builtin's `< length` spelling gate is leftover_twokind. */
  memset(tiny, (int)'x', sizeof(tiny));
  memcpy(tiny + 8, "shuffle", 7);
  sl_tiny.data = tiny;
  sl_tiny.length = 8 + 7;
  if (check_one("tiny_shuffle_pass", (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, &sl_tiny, 8, 7, 0,
                checks, fail))
    any_fail = 1;
  memcpy(tiny + 8, "select", 6);
  sl_tiny.length = 8 + 6;
  if (check_one("tiny_select_pass", (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, &sl_tiny, 8, 6, 0,
                checks, fail))
    any_fail = 1;

  /* builtin_vec kinds × null lex (IDENT already covered above). */
  for (vi = 0; vi < sizeof(k_vec) / sizeof(k_vec[0]); vi++) {
    if (check_one("vec_nullsrc", (int32_t)TOKEN_AT, k_vec[vi], 0, 0, 0, 0, checks, fail))
      any_fail = 1;
    if (check_one("vec_live", (int32_t)TOKEN_AT, k_vec[vi], &sl, 8, 7, 0, checks, fail))
      any_fail = 1;
    if (check_one("vec_notat", (int32_t)TOKEN_IDENT, k_vec[vi], &sl, 8, 7, 0, checks, fail))
      any_fail = 1;
  }

  /* Live-lex snippets. ident_len=0 + IDENT isolates paren (simd / vector
   * / builtin_vec all 0). I32X4 isolates builtin_vec OR. LPAREN isolates
   * a non-IDENT non-vec ident_kind. */
  for (si = 0; si < sizeof(k_snips) / sizeof(k_snips[0]); si++) {
    const char *s = k_snips[si];
    size_t slen = strlen(s);
    sl_snip.data = (uint8_t *)(uintptr_t)s;
    sl_snip.length = slen;
    for (pi = 0; pi < sizeof(k_pos) / sizeof(k_pos[0]); pi++) {
      if (k_pos[pi] > slen)
        continue;
      lex = lex_init();
      lex.pos = k_pos[pi];
      if (check_one("lex_idlen0", (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, &sl_snip, 0, 0, &lex,
                    checks, fail))
        any_fail = 1;
      lex = lex_init();
      lex.pos = k_pos[pi];
      if (check_one("lex_i32x4", (int32_t)TOKEN_AT, (int32_t)TOKEN_I32X4, &sl_snip, 0, 0, &lex,
                    checks, fail))
        any_fail = 1;
      lex = lex_init();
      lex.pos = k_pos[pi];
      if (check_one("lex_lparen_kind", (int32_t)TOKEN_AT, (int32_t)TOKEN_LPAREN, &sl_snip, 0, 0,
                    &lex, checks, fail))
        any_fail = 1;
      lex = lex_init();
      lex.pos = k_pos[pi];
      if (check_one("lex_notat", (int32_t)TOKEN_IDENT, (int32_t)TOKEN_IDENT, &sl_snip, 0, 0, &lex,
                    checks, fail))
        any_fail = 1;
    }
    /* Guard: live source + null lex on the same snippet. */
    if (check_one("snip_nulllex", (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, &sl_snip, 0, 0, 0,
                  checks, fail))
      any_fail = 1;
  }

  /* Live lex + shuffle span (paren OR simd). Cursor at 0 on the 512-byte
   * 'x' buffer is not LPAREN, so paren is 0; simd still 1 at off=8. */
  lex = lex_init();
  if (check_one("lex_shuffle", (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, &sl, 8, 7, &lex, checks,
                fail))
    any_fail = 1;

  /* Null lex vs live lex on empty / paren-only snippets with ident_len=0. */
  sl_snip.data = (uint8_t *)(uintptr_t)"(x)";
  sl_snip.length = 3;
  lex = lex_init();
  if (check_one("paren_x_live", (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, &sl_snip, 0, 0, &lex,
                checks, fail))
    any_fail = 1;
  if (check_one("paren_x_nulllex", (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, &sl_snip, 0, 0, 0,
                checks, fail))
    any_fail = 1;
  sl_snip.data = (uint8_t *)(uintptr_t)"()";
  sl_snip.length = 2;
  lex = lex_init();
  if (check_one("paren_empty_live", (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, &sl_snip, 0, 0, &lex,
                checks, fail))
    any_fail = 1;

  return any_fail;
}
