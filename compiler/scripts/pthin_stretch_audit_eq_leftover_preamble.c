/* leftover_preamble eq battery — 7.2.1b v5.59
 *
 * leftover_helpers whose ABI is (kind, next_kind, third_kind, source) are
 * already .x T in pthin_stretch_audit.x, but they have no k_cases row:
 * the generator only tables lex:/lex_inout: audits. twins.h does not
 * keep a static C copy of collect_imports_preamble (gated in the suite
 * leftover helper), but a first-kind three-kind ABI still cannot be a
 * k_cases row (harness cases are lex-first).
 *
 * This TU does NOT include twins.h. It links audit_x.o (product .x)
 * and compares against an inline copy of the gated C twin (same body
 * as the suite leftover helper under FROM_X). Source is an opaque
 * pointer (.x *u8; C void*). Both sides only test source non-null:
 *   null source → 0
 *   live source → 1
 * classify_toplevel is called and discarded (C (void)classify; .x
 * cls then both branches return 1). That is the honest flatten —
 * this locks it, it does not "fix" the tautology.
 *
 * Flattened body (v5.48) is a thin wrap of classify_toplevel_c —
 * already stretch.x / twins.h authority. This file externs that
 * symbol rather than copying classify / keyword tables (G.7).
 *
 * Corpus is exhaustive TokenKind on each kind slot (the other two
 * fixed at CONST/IDENT/ASSIGN) plus a small cartesian of
 * classify-hit kinds and null/live/nodata/empty source samples.
 * Not a file-offset walk of product .x files.
 *
 * Homogeneous family is collect_imports_preamble three-kind wrap
 * only — do not mix simd_builtin_deep_from_at lex_after_ident in
 * this TU. classify / import_path_score stay stretch.x (G.7; not
 * leftover-to-audit). PLATFORM: SHARED — compiled into the existing
 * eq harness.
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

extern int32_t parser_asm_stretch_collect_imports_preamble_audit_c(int32_t kind, int32_t next_kind,
                                                                  int32_t third_kind,
                                                                  const uint8_t *source);

/* Harness TU (twins.h) already exports the C classify_toplevel authority. */
extern int32_t parser_asm_stretch_classify_toplevel_c(int32_t kind, int32_t next_kind,
                                                     int32_t third_kind);

/* Gated C twin body (suite leftover helper). Static name does not
 * collide with the .x T symbol resolved from audit_x.o. */
static int32_t c_ref_collect_imports_preamble(int32_t kind, int32_t next_kind, int32_t third_kind,
                                             void *source) {
  if (!source)
    return 0;
  (void)parser_asm_stretch_classify_toplevel_c(kind, next_kind, third_kind);
  return 1;
}

typedef int32_t (*x_fn)(int32_t kind, int32_t next_kind, int32_t third_kind, const uint8_t *source);
typedef int32_t (*c_fn)(int32_t kind, int32_t next_kind, int32_t third_kind, void *source);

typedef struct {
  const char *name;
  x_fn x_ver;
  c_fn c_ref;
} leftover_preamble_case;

static const leftover_preamble_case k_leftover_preamble[] = {
    {"collect_imports_preamble", parser_asm_stretch_collect_imports_preamble_audit_c,
     c_ref_collect_imports_preamble},
};

static int leftover_preamble_selected(const char *name) {
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

static int check_one(const leftover_preamble_case *cs, int32_t kind, int32_t next_kind,
                     int32_t third_kind, struct parser_asm_slice_u8 *sl, long *checks, int *fail) {
  const uint8_t *xsrc = sl ? (const uint8_t *)sl : 0;
  int32_t xv = cs->x_ver(kind, next_kind, third_kind, xsrc);
  int32_t cv = cs->c_ref(kind, next_kind, third_kind, sl);
  if (checks)
    (*checks)++;
  if (xv != cv) {
    printf("FAIL leftover_preamble %s kind=%d next=%d third=%d src=%s .x=%d c=%d\n", cs->name,
           (int)kind, (int)next_kind, (int)third_kind,
           sl && sl->data ? "live" : (sl ? "nodata" : "null"), (int)xv, (int)cv);
    if (fail)
      (*fail)++;
    return 1;
  }
  return 0;
}

/**
 * leftover_preamble eq over exhaustive TokenKind on each kind slot
 * plus a small cartesian of classify-hit kinds and source samples.
 * Caller owns checks/fail counters.
 * @param checks long* — incremented per (case, sample) pair; null ignored
 * @param fail int* — incremented on mismatch; null ignored
 * @return int — 0 ok; 1 if any mismatch
 * PLATFORM: SHARED.
 */
int leftover_preamble_eq_run(long *checks, int *fail) {
  static const int32_t k_extra[] = {-1, -2, 256, 512, 1024, 0x7fffffff};
  static const int32_t k_tops[] = {
      (int32_t)TOKEN_EOF,    (int32_t)TOKEN_FUNCTION, (int32_t)TOKEN_LET,    (int32_t)TOKEN_CONST,
      (int32_t)TOKEN_STRUCT, (int32_t)TOKEN_ENUM,     (int32_t)TOKEN_TRAIT,  (int32_t)TOKEN_IMPL,
      (int32_t)TOKEN_IMPORT, (int32_t)TOKEN_EXTERN,   (int32_t)TOKEN_IDENT,  (int32_t)TOKEN_ASSIGN,
  };
  size_t ci;
  int any_fail = 0;
  int32_t kind;
  int32_t last = (int32_t)TOKEN_NULL;
  size_t ei;
  size_t ti;
  size_t ni;
  size_t gi;
  uint8_t srcbuf[8];
  struct parser_asm_slice_u8 sl;
  struct parser_asm_slice_u8 sl_nodata;
  struct parser_asm_slice_u8 sl_empty;

  memset(srcbuf, (int)'s', sizeof(srcbuf));
  sl.data = srcbuf;
  sl.length = sizeof(srcbuf);
  sl_nodata.data = 0;
  sl_nodata.length = 0;
  sl_empty.data = srcbuf;
  sl_empty.length = 0;

  for (ci = 0; ci < sizeof(k_leftover_preamble) / sizeof(k_leftover_preamble[0]); ci++) {
    if (!leftover_preamble_selected(k_leftover_preamble[ci].name))
      continue;

    /* Kind gating: exhaustive one slot, others fixed at the CONST
     * IDENT ASSIGN classify-hit triple. Null + live source per kind
     * (return only depends on source non-null; classify is discarded). */
    for (kind = 0; kind <= last + 8; kind++) {
      if (check_one(&k_leftover_preamble[ci], kind, (int32_t)TOKEN_IDENT, (int32_t)TOKEN_ASSIGN, 0,
                    checks, fail))
        any_fail = 1;
      if (check_one(&k_leftover_preamble[ci], kind, (int32_t)TOKEN_IDENT, (int32_t)TOKEN_ASSIGN, &sl,
                    checks, fail))
        any_fail = 1;
      if (check_one(&k_leftover_preamble[ci], (int32_t)TOKEN_CONST, kind, (int32_t)TOKEN_ASSIGN, 0,
                    checks, fail))
        any_fail = 1;
      if (check_one(&k_leftover_preamble[ci], (int32_t)TOKEN_CONST, kind, (int32_t)TOKEN_ASSIGN, &sl,
                    checks, fail))
        any_fail = 1;
      if (check_one(&k_leftover_preamble[ci], (int32_t)TOKEN_CONST, (int32_t)TOKEN_IDENT, kind, 0,
                    checks, fail))
        any_fail = 1;
      if (check_one(&k_leftover_preamble[ci], (int32_t)TOKEN_CONST, (int32_t)TOKEN_IDENT, kind, &sl,
                    checks, fail))
        any_fail = 1;
    }
    for (ei = 0; ei < sizeof(k_extra) / sizeof(k_extra[0]); ei++) {
      if (check_one(&k_leftover_preamble[ci], k_extra[ei], (int32_t)TOKEN_IDENT,
                    (int32_t)TOKEN_ASSIGN, 0, checks, fail))
        any_fail = 1;
      if (check_one(&k_leftover_preamble[ci], k_extra[ei], (int32_t)TOKEN_IDENT,
                    (int32_t)TOKEN_ASSIGN, &sl, checks, fail))
        any_fail = 1;
      if (check_one(&k_leftover_preamble[ci], (int32_t)TOKEN_CONST, k_extra[ei],
                    (int32_t)TOKEN_ASSIGN, 0, checks, fail))
        any_fail = 1;
      if (check_one(&k_leftover_preamble[ci], (int32_t)TOKEN_CONST, k_extra[ei],
                    (int32_t)TOKEN_ASSIGN, &sl, checks, fail))
        any_fail = 1;
      if (check_one(&k_leftover_preamble[ci], (int32_t)TOKEN_CONST, (int32_t)TOKEN_IDENT,
                    k_extra[ei], 0, checks, fail))
        any_fail = 1;
      if (check_one(&k_leftover_preamble[ci], (int32_t)TOKEN_CONST, (int32_t)TOKEN_IDENT,
                    k_extra[ei], &sl, checks, fail))
        any_fail = 1;
    }

    /* nodata / empty: C and .x only test the source pointer, so both
     * return 1 (non-null). A few fixed triples lock that, not a full
     * kind cartesian. */
    if (check_one(&k_leftover_preamble[ci], (int32_t)TOKEN_CONST, (int32_t)TOKEN_IDENT,
                  (int32_t)TOKEN_ASSIGN, &sl_nodata, checks, fail))
      any_fail = 1;
    if (check_one(&k_leftover_preamble[ci], (int32_t)TOKEN_CONST, (int32_t)TOKEN_IDENT,
                  (int32_t)TOKEN_ASSIGN, &sl_empty, checks, fail))
      any_fail = 1;
    if (check_one(&k_leftover_preamble[ci], (int32_t)TOKEN_IMPORT, 0, 0, &sl_nodata, checks, fail))
      any_fail = 1;
    if (check_one(&k_leftover_preamble[ci], (int32_t)TOKEN_IMPORT, 0, 0, &sl_empty, checks, fail))
      any_fail = 1;
    if (check_one(&k_leftover_preamble[ci], (int32_t)TOKEN_EOF, (int32_t)TOKEN_EOF,
                  (int32_t)TOKEN_EOF, &sl_nodata, checks, fail))
      any_fail = 1;
    if (check_one(&k_leftover_preamble[ci], (int32_t)TOKEN_EOF, (int32_t)TOKEN_EOF,
                  (int32_t)TOKEN_EOF, &sl_empty, checks, fail))
      any_fail = 1;

    /* Small cartesian of classify-hit kinds × null + live. Locks that
     * every classify branch still returns 1 when source is live. */
    for (ti = 0; ti < sizeof(k_tops) / sizeof(k_tops[0]); ti++) {
      for (ni = 0; ni < sizeof(k_tops) / sizeof(k_tops[0]); ni++) {
        for (gi = 0; gi < sizeof(k_tops) / sizeof(k_tops[0]); gi++) {
          if (check_one(&k_leftover_preamble[ci], k_tops[ti], k_tops[ni], k_tops[gi], 0, checks,
                        fail))
            any_fail = 1;
          if (check_one(&k_leftover_preamble[ci], k_tops[ti], k_tops[ni], k_tops[gi], &sl, checks,
                        fail))
            any_fail = 1;
        }
      }
    }
  }
  return any_fail;
}
