/* leftover_kindarr eq battery — 7.2.1b v5.56
 *
 * leftover_helpers whose ABI is (kinds, n, lex, source) are already .x T
 * in pthin_stretch_audit.x, but they have no k_cases row: the generator
 * only tables lex:/lex_inout: audits. twins.h keeps static C copies of
 * peek_kind_chain / expr_binop_kinds_probe under the product names, so
 * those statics shadow the .x T in the harness TU.
 *
 * This TU does NOT include twins.h. It links audit_x.o (product .x)
 * and compares against inline copies of the gated C twins (same bodies
 * as the suite leftover helpers under FROM_X). C twins copy *lex and
 * walk with lexer_next_into (caller cursor unchanged). .x peek/step
 * then restore pos/line/col (net-zero, matching the historical by-val
 * copy). peek_kind_c / step_kind_c in the lex-step bridge are themselves
 * lexer_next_into adapters, so the two walks should agree on kind.
 *
 * peek_kind_chain writes up to max_peek kinds into the out-array
 * (EOF written then stop). expr_binop_kinds_probe reads kinds[] as a
 * match-set and counts consecutive hits (cap 32 then one extra).
 * peek_kind_chain_buf is already a lex-first k_cases wrap; this leftover
 * is the inner out-array-first helper.
 *
 * Corpus is short snippets + guard corners + max_peek / num_kinds
 * corners + a few start-pos landings (not a file-offset walk of
 * product .x files). Do not exercise a nodata slice: live lex would
 * feed lexer_next_into a null data pointer.
 *
 * Homogeneous family is kinds-array only — do not mix
 * simd_builtin_deep_from_at lex_after_ident, import_path_post validate
 * wraps, collect_imports_preamble three-kind, or validate_toplevel
 * stretch.x tables in this TU. classify / import_path_score stay
 * stretch.x (G.7; not leftover-to-audit).
 * PLATFORM: SHARED — compiled into the existing eq harness.
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

extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                            struct parser_asm_slice_u8 *source);

extern int32_t parser_asm_stretch_peek_kind_chain_c(int32_t *kinds, int32_t max_peek, const uint8_t *lex,
                                                    const uint8_t *source);
extern int32_t parser_asm_stretch_expr_binop_kinds_probe_c(int32_t *kinds, int32_t num_kinds,
                                                          const uint8_t *lex, const uint8_t *source);

static void lex_from_result(struct parser_asm_lexer *out, struct parser_asm_lexer_result r) {
  if (!out)
    return;
  out->pos = r.next_lex.pos;
  out->line = r.next_lex.line;
  out->col = r.next_lex.col;
}

static struct parser_asm_lexer lex_init(void) {
  struct parser_asm_lexer lex;
  lex.pos = 0;
  lex.line = 1;
  lex.col = 1;
  return lex;
}

/* Gated C twin bodies (suite leftover helpers). Static names do not
 * collide with the .x T symbols resolved from audit_x.o. */
static int32_t c_ref_peek_kind_chain(int32_t *kinds, int32_t max_peek, void *lex, void *source) {
  struct parser_asm_lexer local;
  struct parser_asm_lexer_result r;
  int32_t n;
  int32_t i;
  if (!kinds || max_peek <= 0 || !lex || !source)
    return 0;
  local = *(struct parser_asm_lexer *)lex;
  n = 0;
  lexer_next_into(&r, local, (struct parser_asm_slice_u8 *)source);
  kinds[n++] = r.tok.kind;
  for (i = 1; i < max_peek; i++) {
    if (r.tok.kind == (int32_t)TOKEN_EOF)
      break;
    lexer_next_into(&r, r.next_lex, (struct parser_asm_slice_u8 *)source);
    kinds[n++] = r.tok.kind;
  }
  return n;
}

static int32_t c_ref_expr_binop_kinds_probe(const int32_t *kinds, int32_t num_kinds, void *lex,
                                           void *source) {
  struct parser_asm_lexer local;
  struct parser_asm_lexer_result r;
  int32_t n;
  int32_t i;
  int32_t hit;
  if (!kinds || num_kinds <= 0 || !lex || !source)
    return 0;
  local = *(struct parser_asm_lexer *)lex;
  n = 0;
  lexer_next_into(&r, local, (struct parser_asm_slice_u8 *)source);
  for (;;) {
    hit = 0;
    for (i = 0; i < num_kinds; i++) {
      if (r.tok.kind == kinds[i]) {
        hit = 1;
        break;
      }
    }
    if (!hit)
      return n;
    n++;
    if (n > 32)
      return n;
    lex_from_result(&local, r);
    lexer_next_into(&r, local, (struct parser_asm_slice_u8 *)source);
  }
}

#define KINDARR_CAP 72
#define KINDARR_SENTINEL 0x7fffffff

static int leftover_kindarr_selected(const char *name) {
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

static void fill_sentinels(int32_t *kinds) {
  int32_t i;
  for (i = 0; i < KINDARR_CAP; i++)
    kinds[i] = KINDARR_SENTINEL;
}

static int lex_eq(const struct parser_asm_lexer *a, const struct parser_asm_lexer *b) {
  return a->pos == b->pos && a->line == b->line && a->col == b->col;
}

static void dump_kinds(const int32_t *kinds, int32_t n) {
  int32_t i;
  int32_t show;
  show = n;
  if (show < 0)
    show = 0;
  if (show > 8)
    show = 8;
  for (i = 0; i < show; i++) {
    if (i)
      printf(",");
    printf("%d", (int)kinds[i]);
  }
  if (n > 8)
    printf(",...");
}

static int check_peek(const char *tag, int32_t *kinds_arg, int32_t max_peek, struct parser_asm_lexer *lex,
                      struct parser_asm_slice_u8 *sl, long *checks, int *fail) {
  struct parser_asm_lexer lex_x;
  struct parser_asm_lexer lex_c;
  struct parser_asm_lexer lex0;
  int32_t kinds_x[KINDARR_CAP];
  int32_t kinds_c[KINDARR_CAP];
  int32_t *x_kinds;
  int32_t *c_kinds;
  const uint8_t *xlex;
  const uint8_t *xsrc;
  int32_t xv;
  int32_t cv;
  int32_t i;
  int mismatch;

  lex0 = lex ? *lex : lex_init();
  lex_x = lex0;
  lex_c = lex0;
  fill_sentinels(kinds_x);
  fill_sentinels(kinds_c);
  x_kinds = kinds_arg ? kinds_x : 0;
  c_kinds = kinds_arg ? kinds_c : 0;
  xlex = lex ? (const uint8_t *)&lex_x : 0;
  xsrc = sl ? (const uint8_t *)sl : 0;
  xv = parser_asm_stretch_peek_kind_chain_c(x_kinds, max_peek, xlex, xsrc);
  cv = c_ref_peek_kind_chain(c_kinds, max_peek, lex ? (void *)&lex_c : 0, sl);
  if (checks)
    (*checks)++;
  mismatch = xv != cv;
  if (!mismatch && kinds_arg) {
    for (i = 0; i < KINDARR_CAP; i++) {
      if (kinds_x[i] != kinds_c[i]) {
        mismatch = 1;
        break;
      }
    }
  }
  if (!mismatch && lex && (!lex_eq(&lex_x, &lex0) || !lex_eq(&lex_c, &lex0)))
    mismatch = 1;
  if (mismatch) {
    printf("FAIL leftover_kindarr peek_kind_chain %s max=%d .x=%d c=%d xk=", tag, (int)max_peek,
           (int)xv, (int)cv);
    dump_kinds(kinds_x, xv);
    printf(" ck=");
    dump_kinds(kinds_c, cv);
    printf(" lex_x=%zu/%d/%d lex_c=%zu/%d/%d orig=%zu/%d/%d\n", (size_t)lex_x.pos, (int)lex_x.line,
           (int)lex_x.col, (size_t)lex_c.pos, (int)lex_c.line, (int)lex_c.col, (size_t)lex0.pos,
           (int)lex0.line, (int)lex0.col);
    if (fail)
      (*fail)++;
    return 1;
  }
  return 0;
}

static int check_probe(const char *tag, int32_t *kinds, int32_t num_kinds, struct parser_asm_lexer *lex,
                       struct parser_asm_slice_u8 *sl, long *checks, int *fail) {
  struct parser_asm_lexer lex_x;
  struct parser_asm_lexer lex_c;
  struct parser_asm_lexer lex0;
  const uint8_t *xlex;
  const uint8_t *xsrc;
  int32_t xv;
  int32_t cv;

  lex0 = lex ? *lex : lex_init();
  lex_x = lex0;
  lex_c = lex0;
  xlex = lex ? (const uint8_t *)&lex_x : 0;
  xsrc = sl ? (const uint8_t *)sl : 0;
  xv = parser_asm_stretch_expr_binop_kinds_probe_c(kinds, num_kinds, xlex, xsrc);
  cv = c_ref_expr_binop_kinds_probe(kinds, num_kinds, lex ? (void *)&lex_c : 0, sl);
  if (checks)
    (*checks)++;
  if (xv != cv || (lex && (!lex_eq(&lex_x, &lex0) || !lex_eq(&lex_c, &lex0)))) {
    printf("FAIL leftover_kindarr expr_binop_kinds_probe %s nk=%d .x=%d c=%d lex_x=%zu/%d/%d "
           "lex_c=%zu/%d/%d orig=%zu/%d/%d\n",
           tag, (int)num_kinds, (int)xv, (int)cv, (size_t)lex_x.pos, (int)lex_x.line, (int)lex_x.col,
           (size_t)lex_c.pos, (int)lex_c.line, (int)lex_c.col, (size_t)lex0.pos, (int)lex0.line,
           (int)lex0.col);
    if (fail)
      (*fail)++;
    return 1;
  }
  return 0;
}

/**
 * leftover_kindarr eq over kinds-array leftover helpers (peek out-array +
 * probe match-set) against gated C twins on short snippets and guard
 * corners. Caller owns checks/fail counters.
 * @param checks long* — incremented per (helper, sample) pair; null ignored
 * @param fail int* — incremented on mismatch; null ignored
 * @return int — 0 ok; 1 if any mismatch
 * PLATFORM: SHARED.
 */
int leftover_kindarr_eq_run(long *checks, int *fail) {
  static const char *k_snips[] = {
      "",
      " ",
      "\n",
      "a",
      "ab",
      "a+b",
      "a + b",
      "a+b*c-d/e",
      "+ - * /",
      "1+2+3+4+5",
      "<< >>",
      "fn foo()",
      "()",
      "{}",
      "a.b",
      "a,b,c",
      ";;;",
      "== !=",
      "&& ||",
      "@",
      "import x",
      "<<<<",
      "+ + + +",
      "a a a a",
  };
  static const int32_t k_max[] = {-100, -1, 0, 1, 2, 3, 4, 6, 8, 32, 33, 64};
  static const size_t k_pos[] = {0, 1, 2, 3};
  static const int32_t k_set_plus[] = {(int32_t)TOKEN_PLUS};
  static const int32_t k_set_arith[] = {(int32_t)TOKEN_PLUS, (int32_t)TOKEN_MINUS, (int32_t)TOKEN_STAR,
                                        (int32_t)TOKEN_SLASH};
  static const int32_t k_set_shift[] = {(int32_t)TOKEN_LSHIFT};
  static const int32_t k_set_ident[] = {(int32_t)TOKEN_IDENT};
  static const int32_t k_set_eof[] = {(int32_t)TOKEN_EOF};
  static const int32_t k_set_mix[] = {(int32_t)TOKEN_IDENT, (int32_t)TOKEN_PLUS};
  static const int32_t k_set_unk[] = {999};
  static const int32_t k_set_lparen[] = {(int32_t)TOKEN_LPAREN};
  static const int32_t k_set_int[] = {(int32_t)TOKEN_INT};
  struct {
    const char *tag;
    const int32_t *kinds;
    int32_t n;
  } k_sets[9];
  uint8_t long_idents[256];
  struct parser_asm_slice_u8 sl;
  struct parser_asm_lexer lex;
  int32_t dummy_kinds[KINDARR_CAP];
  int32_t *no_kinds = 0;
  size_t si;
  size_t mi;
  size_t pi;
  size_t seti;
  int any_fail = 0;
  int32_t i;
  int32_t off;
  int peek_on;
  int probe_on;

  k_sets[0].tag = "plus";
  k_sets[0].kinds = k_set_plus;
  k_sets[0].n = 1;
  k_sets[1].tag = "arith";
  k_sets[1].kinds = k_set_arith;
  k_sets[1].n = 4;
  k_sets[2].tag = "shift";
  k_sets[2].kinds = k_set_shift;
  k_sets[2].n = 1;
  k_sets[3].tag = "ident";
  k_sets[3].kinds = k_set_ident;
  k_sets[3].n = 1;
  k_sets[4].tag = "eof";
  k_sets[4].kinds = k_set_eof;
  k_sets[4].n = 1;
  k_sets[5].tag = "ident+plus";
  k_sets[5].kinds = k_set_mix;
  k_sets[5].n = 2;
  k_sets[6].tag = "unk";
  k_sets[6].kinds = k_set_unk;
  k_sets[6].n = 1;
  k_sets[7].tag = "lparen";
  k_sets[7].kinds = k_set_lparen;
  k_sets[7].n = 1;
  k_sets[8].tag = "int";
  k_sets[8].kinds = k_set_int;
  k_sets[8].n = 1;

  peek_on = leftover_kindarr_selected("peek_kind_chain");
  probe_on = leftover_kindarr_selected("expr_binop_kinds_probe");
  if (!peek_on && !probe_on)
    return 0;

  dummy_kinds[0] = 0;
  lex = lex_init();

  /* Guard corners: null kinds / lex / source and n<=0. */
  if (peek_on) {
    if (check_peek("null_all", no_kinds, 4, 0, 0, checks, fail))
      any_fail = 1;
    if (check_peek("null_kinds", no_kinds, 4, &lex, 0, checks, fail))
      any_fail = 1;
    sl.data = (uint8_t *)(uintptr_t)"a";
    sl.length = 1;
    if (check_peek("null_lex", dummy_kinds, 4, 0, &sl, checks, fail))
      any_fail = 1;
    if (check_peek("null_src", dummy_kinds, 4, &lex, 0, checks, fail))
      any_fail = 1;
    if (check_peek("max0", dummy_kinds, 0, &lex, &sl, checks, fail))
      any_fail = 1;
    if (check_peek("max-1", dummy_kinds, -1, &lex, &sl, checks, fail))
      any_fail = 1;
  }
  if (probe_on) {
    if (check_probe("null_all", 0, 1, 0, 0, checks, fail))
      any_fail = 1;
    if (check_probe("null_kinds", 0, 1, &lex, 0, checks, fail))
      any_fail = 1;
    sl.data = (uint8_t *)(uintptr_t)"a";
    sl.length = 1;
    if (check_probe("null_lex", dummy_kinds, 1, 0, &sl, checks, fail))
      any_fail = 1;
    if (check_probe("null_src", dummy_kinds, 1, &lex, 0, checks, fail))
      any_fail = 1;
    if (check_probe("nk0", dummy_kinds, 0, &lex, &sl, checks, fail))
      any_fail = 1;
    if (check_probe("nk-1", dummy_kinds, -1, &lex, &sl, checks, fail))
      any_fail = 1;
  }

  for (si = 0; si < sizeof(k_snips) / sizeof(k_snips[0]); si++) {
    const char *s = k_snips[si];
    size_t slen = strlen(s);
    sl.data = (uint8_t *)(uintptr_t)s;
    sl.length = slen + 1; /* NUL sentinel, matching harness batteries */
    for (pi = 0; pi < sizeof(k_pos) / sizeof(k_pos[0]); pi++) {
      if (k_pos[pi] > slen)
        continue;
      lex = lex_init();
      lex.pos = k_pos[pi];
      if (peek_on) {
        for (mi = 0; mi < sizeof(k_max) / sizeof(k_max[0]); mi++) {
          char tag[80];
          snprintf(tag, sizeof(tag), "snip%zu_pos%zu", si, (size_t)k_pos[pi]);
          if (check_peek(tag, dummy_kinds, k_max[mi], &lex, &sl, checks, fail))
            any_fail = 1;
        }
      }
      if (probe_on) {
        for (seti = 0; seti < sizeof(k_sets) / sizeof(k_sets[0]); seti++) {
          char tag[80];
          snprintf(tag, sizeof(tag), "snip%zu_pos%zu_%s", si, (size_t)k_pos[pi], k_sets[seti].tag);
          if (check_probe(tag, (int32_t *)(uintptr_t)k_sets[seti].kinds, k_sets[seti].n, &lex, &sl,
                          checks, fail))
            any_fail = 1;
        }
      }
    }
    /* length = slen without the extra NUL (tight slice). */
    sl.length = slen;
    lex = lex_init();
    if (peek_on) {
      if (check_peek("tight", dummy_kinds, 4, &lex, &sl, checks, fail))
        any_fail = 1;
    }
    if (probe_on) {
      if (check_probe("tight_ident", (int32_t *)(uintptr_t)k_set_ident, 1, &lex, &sl, checks, fail))
        any_fail = 1;
      if (check_probe("tight_plus", (int32_t *)(uintptr_t)k_set_plus, 1, &lex, &sl, checks, fail))
        any_fail = 1;
    }
  }

  /* 40 spaced idents lock the probe n>32 extra-hit cap and peek max_peek
   * against a long homogeneous kind run. */
  off = 0;
  for (i = 0; i < 40; i++) {
    if (i)
      long_idents[off++] = (uint8_t)' ';
    long_idents[off++] = (uint8_t)'a';
  }
  long_idents[off] = 0;
  sl.data = long_idents;
  sl.length = (size_t)off + 1;
  lex = lex_init();
  if (peek_on) {
    if (check_peek("40ident_max1", dummy_kinds, 1, &lex, &sl, checks, fail))
      any_fail = 1;
    if (check_peek("40ident_max32", dummy_kinds, 32, &lex, &sl, checks, fail))
      any_fail = 1;
    if (check_peek("40ident_max33", dummy_kinds, 33, &lex, &sl, checks, fail))
      any_fail = 1;
    if (check_peek("40ident_max64", dummy_kinds, 64, &lex, &sl, checks, fail))
      any_fail = 1;
  }
  if (probe_on) {
    if (check_probe("40ident", (int32_t *)(uintptr_t)k_set_ident, 1, &lex, &sl, checks, fail))
      any_fail = 1;
    if (check_probe("40ident_plus", (int32_t *)(uintptr_t)k_set_plus, 1, &lex, &sl, checks, fail))
      any_fail = 1;
  }

  return any_fail;
}
