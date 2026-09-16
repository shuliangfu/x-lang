/* leftover_validate eq battery — 7.2.1b v5.57
 *
 * leftover_helpers whose ABI is (kind, ident_len, token_start, source)
 * are already .x T in pthin_stretch_audit.x, but they have no k_cases
 * row: the generator only tables lex:/lex_inout: audits. twins.h does
 * not keep a static C copy of validate_toplevel_token, but a first-kind
 * span/bounds ABI still cannot be a k_cases row (harness cases are
 * lex-first).
 *
 * This TU does NOT include twins.h. It links audit_x.o (product .x)
 * and compares against an inline copy of the gated C twin (same body
 * as the suite leftover helper under FROM_X). Source is an opaque
 * parser_asm_slice_u8*; .x takes *u8 and calls lex_source_data_c /
 * lex_source_length_c.
 *
 * Flattened body (v5.49) is EOF / ident_len<=0 / span — not the
 * historical token_run_len + verify_kw tables (those stay stretch.x;
 * G.7 do not copy). Keywords have ident_len=0 so the table path is
 * skipped (return 1). IDENT with ident_len>0 keeps the span check.
 * TOKEN_EOF returns 1 *before* the span check, so EOF+overflow is 1
 * while IDENT+overflow is 0.
 *
 * Corpus is exhaustive TokenKind (ident_len<=0, in-span, overflow)
 * plus ident_len / token_start / slen corners including unsigned-add
 * wrap and a nodata slice (this helper checks !data; it is not a
 * live-lex walk). Not a file-offset walk of product .x files.
 *
 * Homogeneous family is validate_toplevel span/bounds only — do not
 * mix simd_builtin_deep_from_at lex_after_ident, import_path_post
 * validate wraps, or collect_imports_preamble three-kind in this TU.
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

extern int32_t parser_asm_stretch_validate_toplevel_token_c(int32_t kind, int32_t ident_len,
                                                            size_t token_start,
                                                            const uint8_t *source);

/* Gated C twin body (suite leftover helper). Static name does not
 * collide with the .x T symbol resolved from audit_x.o. */
static int32_t c_ref_validate_toplevel_token(int32_t kind, int32_t ident_len, size_t token_start,
                                            struct parser_asm_slice_u8 *source) {
  if (!source)
    return 0;
  if (!source->data)
    return 0;
  if (kind == (int32_t)TOKEN_EOF)
    return 1;
  if (ident_len <= 0)
    return 1;
  if (token_start + (size_t)ident_len > source->length)
    return 0;
  return 1;
}

typedef int32_t (*x_fn)(int32_t kind, int32_t ident_len, size_t token_start, const uint8_t *source);
typedef int32_t (*c_fn)(int32_t kind, int32_t ident_len, size_t token_start,
                       struct parser_asm_slice_u8 *source);

typedef struct {
  const char *name;
  x_fn x_ver;
  c_fn c_ref;
} leftover_validate_case;

static const leftover_validate_case k_leftover_validate[] = {
    {"validate_toplevel_token", parser_asm_stretch_validate_toplevel_token_c,
     c_ref_validate_toplevel_token},
};

static int leftover_validate_selected(const char *name) {
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

static int check_one(const leftover_validate_case *cs, int32_t kind, int32_t ident_len,
                     size_t token_start, struct parser_asm_slice_u8 *sl, long *checks, int *fail) {
  const uint8_t *xsrc = sl ? (const uint8_t *)sl : 0;
  int32_t xv = cs->x_ver(kind, ident_len, token_start, xsrc);
  int32_t cv = cs->c_ref(kind, ident_len, token_start, sl);
  if (checks)
    (*checks)++;
  if (xv != cv) {
    printf("FAIL leftover_validate %s kind=%d len=%d off=%zu slen=%zu data=%s .x=%d c=%d\n",
           cs->name, (int)kind, (int)ident_len, (size_t)token_start,
           sl ? (size_t)sl->length : (size_t)0, sl && sl->data ? "live" : (sl ? "nodata" : "null"),
           (int)xv, (int)cv);
    if (fail)
      (*fail)++;
    return 1;
  }
  return 0;
}

/**
 * leftover_validate eq over exhaustive TokenKind (ident_len<=0, in-span,
 * overflow) plus ident_len / token_start / slen corners, unsigned-add
 * wrap, and a nodata slice.
 * Caller owns checks/fail counters.
 * @param checks long* — incremented per (case, sample) pair; null ignored
 * @param fail int* — incremented on mismatch; null ignored
 * @return int — 0 ok; 1 if any mismatch
 * PLATFORM: SHARED.
 */
int leftover_validate_eq_run(long *checks, int *fail) {
  static const int32_t k_extra[] = {-1, -2, 256, 512, 1024, 0x7fffffff};
  static const int32_t k_lens[] = {-100, -1, 0, 1, 2, 3, 4, 8, 16, 32, 33, 63, 64,
                                   127,  128, 255, 256, 1024, 0x7fffffff};
  static const size_t k_slens[] = {0, 1, 4, 8, 16, 32};
  static const int32_t k_span_kinds[] = {(int32_t)TOKEN_EOF, (int32_t)TOKEN_IDENT, (int32_t)TOKEN_I32,
                                         0, -1, (int32_t)TOKEN_NULL, 256};
  size_t ci;
  int any_fail = 0;
  int32_t kind;
  int32_t last = (int32_t)TOKEN_NULL;
  size_t ei;
  size_t li;
  size_t si;
  size_t oi;
  size_t ki;
  uint8_t buf[64];
  struct parser_asm_slice_u8 sl;
  struct parser_asm_slice_u8 sl_nodata;
  struct parser_asm_slice_u8 sl_empty;

  memset(buf, (int)'x', sizeof(buf));
  sl.data = buf;
  sl.length = 8;
  sl_nodata.data = 0;
  sl_nodata.length = 0;
  sl_empty.data = buf;
  sl_empty.length = 0;

  for (ci = 0; ci < sizeof(k_leftover_validate) / sizeof(k_leftover_validate[0]); ci++) {
    if (!leftover_validate_selected(k_leftover_validate[ci].name))
      continue;

    /* Exhaustive kind × three span classes on a live 8-byte slice:
     * ident_len<=0 → 1; in-span ident_len=4 off=0 → 1; overflow
     * ident_len=4 off=6 (6+4>8) → EOF=1, others=0. Plus one null
     * source sample per kind. */
    for (kind = 0; kind <= last + 8; kind++) {
      if (check_one(&k_leftover_validate[ci], kind, 0, 0, 0, checks, fail))
        any_fail = 1;
      if (check_one(&k_leftover_validate[ci], kind, 0, 0, &sl, checks, fail))
        any_fail = 1;
      if (check_one(&k_leftover_validate[ci], kind, -1, 0, &sl, checks, fail))
        any_fail = 1;
      if (check_one(&k_leftover_validate[ci], kind, 4, 0, &sl, checks, fail))
        any_fail = 1;
      if (check_one(&k_leftover_validate[ci], kind, 4, 6, &sl, checks, fail))
        any_fail = 1;
    }
    for (ei = 0; ei < sizeof(k_extra) / sizeof(k_extra[0]); ei++) {
      if (check_one(&k_leftover_validate[ci], k_extra[ei], 0, 0, 0, checks, fail))
        any_fail = 1;
      if (check_one(&k_leftover_validate[ci], k_extra[ei], 0, 0, &sl, checks, fail))
        any_fail = 1;
      if (check_one(&k_leftover_validate[ci], k_extra[ei], -1, 0, &sl, checks, fail))
        any_fail = 1;
      if (check_one(&k_leftover_validate[ci], k_extra[ei], 4, 0, &sl, checks, fail))
        any_fail = 1;
      if (check_one(&k_leftover_validate[ci], k_extra[ei], 4, 6, &sl, checks, fail))
        any_fail = 1;
    }

    /* Non-null slice with data==0: C early-outs on !data; .x unwraps. */
    if (check_one(&k_leftover_validate[ci], (int32_t)TOKEN_IDENT, 4, 0, &sl_nodata, checks, fail))
      any_fail = 1;
    if (check_one(&k_leftover_validate[ci], (int32_t)TOKEN_EOF, 4, 0, &sl_nodata, checks, fail))
      any_fail = 1;
    if (check_one(&k_leftover_validate[ci], (int32_t)TOKEN_IDENT, 0, 0, &sl_nodata, checks, fail))
      any_fail = 1;

    /* Empty live slice (data live, length 0). */
    if (check_one(&k_leftover_validate[ci], (int32_t)TOKEN_EOF, 4, 0, &sl_empty, checks, fail))
      any_fail = 1;
    if (check_one(&k_leftover_validate[ci], (int32_t)TOKEN_IDENT, 0, 0, &sl_empty, checks, fail))
      any_fail = 1;
    if (check_one(&k_leftover_validate[ci], (int32_t)TOKEN_IDENT, 1, 0, &sl_empty, checks, fail))
      any_fail = 1;

    /* ident_len / token_start / slen cartesian on a few kinds, including
     * unsigned-add wrap (SIZE_MAX + ident_len). Both sides wrap the
     * same way; this locks that shared arithmetic, it does not "fix" it. */
    for (si = 0; si < sizeof(k_slens) / sizeof(k_slens[0]); si++) {
      size_t slen = k_slens[si];
      size_t offs[9];
      size_t n_off;
      sl.data = buf;
      sl.length = slen;
      n_off = 0;
      offs[n_off++] = 0;
      offs[n_off++] = 1;
      offs[n_off++] = 2;
      offs[n_off++] = slen;
      offs[n_off++] = slen + 1;
      if (slen > 0)
        offs[n_off++] = slen - 1;
      offs[n_off++] = (size_t)-3;
      offs[n_off++] = (size_t)-1;
      offs[n_off++] = (size_t)-2;
      for (ki = 0; ki < sizeof(k_span_kinds) / sizeof(k_span_kinds[0]); ki++) {
        for (li = 0; li < sizeof(k_lens) / sizeof(k_lens[0]); li++) {
          for (oi = 0; oi < n_off; oi++) {
            if (check_one(&k_leftover_validate[ci], k_span_kinds[ki], k_lens[li], offs[oi], &sl,
                          checks, fail))
              any_fail = 1;
          }
        }
      }
    }
    sl.data = buf;
    sl.length = 8;
  }
  return any_fail;
}
