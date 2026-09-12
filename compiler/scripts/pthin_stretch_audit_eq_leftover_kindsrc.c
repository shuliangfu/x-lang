/* leftover_kindsrc eq battery — 7.2.1b v5.53
 *
 * leftover_helpers whose ABI is (kind, source, token_start, name_len) are
 * already .x T in pthin_stretch_audit.x, but they have no k_cases row:
 * the generator only tables lex:/lex_inout: audits. twins.h also keeps
 * a static C copy of match_subject_ident under the product name so
 * c_ref twins keep C authority — that static shadows the .x T in the
 * harness TU. import_dot_segment is not static in twins.h but still
 * cannot be a k_cases row (first param is not lex:).
 *
 * This TU does NOT include twins.h. It links audit_x.o (product .x)
 * and compares against inline copies of the gated C twins (same
 * bodies as suite leftover helpers under FROM_X). Source is an opaque
 * parser_asm_slice_u8*; .x takes *u8 and calls lex_source_data_c.
 *
 * Both C twins are G.7 thin wraps of bind_name_validate on
 * source->data + token_start, gated on kind:
 *   import_dot_segment — I32/ASYNC always 1; IDENT + nlen in (0,63]
 *     goes through bind_name_validate; else 0.
 *   match_subject_ident — IDENT + nlen > 0 goes through
 *     bind_name_validate; else 0.
 * This file externs bind_name_validate rather than copying
 * ident_byte_ok a third time.
 *
 * Corpus is exhaustive TokenKind at a fixed ident span plus IDENT
 * ident byte-class + length + token_start corners (not a file-offset
 * walk of product .x files). Callers always pass lexer ident spans
 * (remaining >= name_len); the battery stays inside that contract so
 * C data+off vs .x unwrap+off cannot diverge on uninit / OOB.
 *
 * classify / import_path_score stay stretch.x (G.7; not leftover-to-audit).
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

extern int32_t parser_asm_stretch_import_dot_segment_audit_c(int32_t kind, const uint8_t *source,
                                                             size_t token_start, int32_t name_len);
extern int32_t parser_asm_stretch_match_subject_ident_audit_c(int32_t kind, const uint8_t *source,
                                                             size_t token_start, int32_t name_len);

/* Harness TU (twins.h) already exports the C bind_name_validate authority. */
extern int32_t parser_asm_stretch_bind_name_validate_c(const uint8_t *name, int32_t len);

/* Gated C twin bodies (suite leftover helpers). Static names do not
 * collide with the .x T symbols resolved from audit_x.o. */
static int32_t c_ref_import_dot_segment(int32_t kind, struct parser_asm_slice_u8 *source,
                                        size_t token_start, int32_t name_len) {
  if (kind == (int32_t)TOKEN_I32)
    return 1;
  if (kind == (int32_t)TOKEN_ASYNC)
    return 1;
  if (!source || !source->data)
    return 0;
  if (kind != (int32_t)TOKEN_IDENT || name_len <= 0 || name_len > 63)
    return 0;
  return parser_asm_stretch_bind_name_validate_c(source->data + token_start, name_len);
}

static int32_t c_ref_match_subject_ident(int32_t kind, struct parser_asm_slice_u8 *source,
                                         size_t token_start, int32_t name_len) {
  if (!source || kind != (int32_t)TOKEN_IDENT || name_len <= 0)
    return 0;
  return parser_asm_stretch_bind_name_validate_c(source->data + token_start, name_len);
}

typedef int32_t (*x_fn)(int32_t kind, const uint8_t *source, size_t token_start, int32_t name_len);
typedef int32_t (*c_fn)(int32_t kind, struct parser_asm_slice_u8 *source, size_t token_start,
                        int32_t name_len);

typedef struct {
  const char *name;
  x_fn x_ver;
  c_fn c_ref;
} leftover_kindsrc_case;

static const leftover_kindsrc_case k_leftover_kindsrc[] = {
    {"import_dot_segment", parser_asm_stretch_import_dot_segment_audit_c, c_ref_import_dot_segment},
    {"match_subject_ident", parser_asm_stretch_match_subject_ident_audit_c, c_ref_match_subject_ident},
};

static int leftover_kindsrc_selected(const char *name) {
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

static void dump_span(const uint8_t *data, size_t token_start, int32_t name_len) {
  int32_t i;
  int32_t n;
  if (!data) {
    printf("(null-data)");
    return;
  }
  n = name_len;
  if (n < 0)
    n = 0;
  if (n > 16)
    n = 16;
  for (i = 0; i < n; i++)
    printf("%02x", (unsigned)data[token_start + (size_t)i]);
  if (name_len > 16)
    printf("...");
}

static int check_pair(const leftover_kindsrc_case *cs, int32_t kind, struct parser_asm_slice_u8 *sl,
                      size_t token_start, int32_t name_len, long *checks, int *fail) {
  const uint8_t *xsrc = sl ? (const uint8_t *)sl : 0;
  int32_t xv = cs->x_ver(kind, xsrc, token_start, name_len);
  int32_t cv = cs->c_ref(kind, sl, token_start, name_len);
  if (checks)
    (*checks)++;
  if (xv != cv) {
    printf("FAIL leftover_kindsrc %s kind=%d off=%zu len=%d .x=%d c=%d span=", cs->name, (int)kind,
           (size_t)token_start, (int)name_len, (int)xv, (int)cv);
    dump_span(sl && sl->data ? sl->data : 0, token_start, name_len);
    printf("\n");
    if (fail)
      (*fail)++;
    return 1;
  }
  return 0;
}

/**
 * leftover_kindsrc eq over exhaustive TokenKind plus IDENT ident
 * byte-class + length + token_start corners.
 * Caller owns checks/fail counters.
 * @param checks long* — incremented per (case, sample) pair; null ignored
 * @param fail int* — incremented on mismatch; null ignored
 * @return int — 0 ok; 1 if any mismatch
 * PLATFORM: SHARED.
 */
int leftover_kindsrc_eq_run(long *checks, int *fail) {
  static const int32_t k_extra[] = {-1, -2, 256, 512, 1024, 0x7fffffff};
  static const int32_t k_null_lens[] = {-1, 0, 1, 4, 63, 64, 100};
  static const size_t k_null_offs[] = {0, 1, 8};
  static const int32_t k_lens[] = {0, 1, 2, 5, 62, 63, 64, 65, 100};
  static const size_t k_offs[] = {0, 1, 7, 8, 64};
  static const char *k_lits[] = {"",     "a",     "A",      "_",     "0",     "a0",  "main",
                                 "foo_bar", "_x",  "0x",     "a.b",    "I32",   " ",   "\n",
                                 "a-b",     "fn",  "struct", "import", "i32", "async"};
  size_t ci;
  int any_fail = 0;
  int32_t b;
  int32_t kind;
  int32_t last = (int32_t)TOKEN_NULL;
  size_t li;
  size_t ni;
  size_t oi;
  size_t ei;
  uint8_t buf[512];
  struct parser_asm_slice_u8 sl;

  memset(buf, (int)'x', sizeof(buf));
  memcpy(buf + 8, "main", 4);
  sl.data = buf;
  sl.length = sizeof(buf);

  for (ci = 0; ci < sizeof(k_leftover_kindsrc) / sizeof(k_leftover_kindsrc[0]); ci++) {
    if (!leftover_kindsrc_selected(k_leftover_kindsrc[ci].name))
      continue;

    /* Kind gating: one null-source sample + one valid span per kind.
     * Length / offset corners run only at IDENT (below). */
    for (kind = 0; kind <= last + 8; kind++) {
      if (check_pair(&k_leftover_kindsrc[ci], kind, 0, 0, 0, checks, fail))
        any_fail = 1;
      if (check_pair(&k_leftover_kindsrc[ci], kind, &sl, 8, 4, checks, fail))
        any_fail = 1;
    }
    for (ei = 0; ei < sizeof(k_extra) / sizeof(k_extra[0]); ei++) {
      if (check_pair(&k_leftover_kindsrc[ci], k_extra[ei], 0, 0, 0, checks, fail))
        any_fail = 1;
      if (check_pair(&k_leftover_kindsrc[ci], k_extra[ei], &sl, 8, 4, checks, fail))
        any_fail = 1;
    }

    for (oi = 0; oi < sizeof(k_null_offs) / sizeof(k_null_offs[0]); oi++) {
      for (ni = 0; ni < sizeof(k_null_lens) / sizeof(k_null_lens[0]); ni++) {
        if (check_pair(&k_leftover_kindsrc[ci], (int32_t)TOKEN_IDENT, 0, k_null_offs[oi],
                       k_null_lens[ni], checks, fail))
          any_fail = 1;
      }
    }

    /* First-byte class at a non-zero offset so token_start is exercised. */
    for (b = 0; b < 256; b++) {
      buf[8] = (uint8_t)b;
      if (check_pair(&k_leftover_kindsrc[ci], (int32_t)TOKEN_IDENT, &sl, 8, 1, checks, fail))
        any_fail = 1;
    }
    memcpy(buf + 8, "main", 4);

    buf[8] = (uint8_t)'a';
    for (b = 0; b < 256; b++) {
      buf[9] = (uint8_t)b;
      if (check_pair(&k_leftover_kindsrc[ci], (int32_t)TOKEN_IDENT, &sl, 8, 2, checks, fail))
        any_fail = 1;
    }
    memcpy(buf + 8, "main", 4);

    for (oi = 0; oi < sizeof(k_offs) / sizeof(k_offs[0]); oi++) {
      for (ni = 0; ni < sizeof(k_lens) / sizeof(k_lens[0]); ni++) {
        size_t off = k_offs[oi];
        int32_t n = k_lens[ni];
        /* Stay inside remaining >= name_len so C data+off vs .x unwrap match. */
        if (n > 0 && off + (size_t)n > sl.length)
          continue;
        if (check_pair(&k_leftover_kindsrc[ci], (int32_t)TOKEN_IDENT, &sl, off, n, checks, fail))
          any_fail = 1;
      }
    }

    for (li = 0; li < sizeof(k_lits) / sizeof(k_lits[0]); li++) {
      const uint8_t *p = (const uint8_t *)k_lits[li];
      int32_t n = (int32_t)strlen(k_lits[li]);
      if (n > 0)
        memcpy(buf + 8, p, (size_t)n);
      if (check_pair(&k_leftover_kindsrc[ci], (int32_t)TOKEN_IDENT, &sl, 8, n, checks, fail))
        any_fail = 1;
      if (n > 0)
        memset(buf + 8, (int)'x', (size_t)n);
    }
    memcpy(buf + 8, "main", 4);
  }
  return any_fail;
}
