/* leftover_twokind eq battery — 7.2.1b v5.54
 *
 * leftover_helpers whose ABI is (at_kind, ident_kind, source, ident_start,
 * ident_len) are already .x T in pthin_stretch_audit.x, but they have no
 * k_cases row: the generator only tables lex:/lex_inout: audits. twins.h
 * also keeps a static C copy of simd_builtin under the product name so
 * c_ref twins keep C authority — that static shadows the .x T in the
 * harness TU.
 *
 * This TU does NOT include twins.h. It links audit_x.o (product .x)
 * and compares against an inline copy of the gated C twin (same body
 * as the suite leftover helper under FROM_X). Source is an opaque
 * parser_asm_slice_u8*; .x takes *u8 and calls lex_source_data_c.
 *
 * The C twin is a spelling check (not bind_name_validate):
 *   simd_builtin — TOKEN_AT + TOKEN_IDENT + ident_len>0, then
 *     ident_len==7 "shuffle" or ident_len==6 "select" at ident_start
 *     (bytes must sit inside source->length).
 *
 * Corpus is exhaustive TokenKind on each kind slot (the other slot
 * fixed at the gating value) plus AT+IDENT ident spelling / length /
 * token_start corners (not a file-offset walk of product .x files).
 * Stay inside remaining >= ident_len so C data+off vs .x unwrap+off
 * cannot diverge on uninit / OOB.
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

extern int32_t parser_asm_stretch_simd_builtin_audit_c(int32_t at_kind, int32_t ident_kind,
                                                       const uint8_t *source, size_t ident_start,
                                                       int32_t ident_len);

/* Gated C twin body (suite leftover helper). Static name does not
 * collide with the .x T symbol resolved from audit_x.o. */
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

typedef int32_t (*x_fn)(int32_t at_kind, int32_t ident_kind, const uint8_t *source,
                        size_t ident_start, int32_t ident_len);
typedef int32_t (*c_fn)(int32_t at_kind, int32_t ident_kind, struct parser_asm_slice_u8 *source,
                        size_t ident_start, int32_t ident_len);

typedef struct {
  const char *name;
  x_fn x_ver;
  c_fn c_ref;
} leftover_twokind_case;

static const leftover_twokind_case k_leftover_twokind[] = {
    {"simd_builtin", parser_asm_stretch_simd_builtin_audit_c, c_ref_simd_builtin},
};

static int leftover_twokind_selected(const char *name) {
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

static int check_pair(const leftover_twokind_case *cs, int32_t at_kind, int32_t ident_kind,
                      struct parser_asm_slice_u8 *sl, size_t ident_start, int32_t ident_len,
                      long *checks, int *fail) {
  const uint8_t *xsrc = sl ? (const uint8_t *)sl : 0;
  int32_t xv = cs->x_ver(at_kind, ident_kind, xsrc, ident_start, ident_len);
  int32_t cv = cs->c_ref(at_kind, ident_kind, sl, ident_start, ident_len);
  if (checks)
    (*checks)++;
  if (xv != cv) {
    printf("FAIL leftover_twokind %s at=%d ident=%d off=%zu len=%d .x=%d c=%d span=", cs->name,
           (int)at_kind, (int)ident_kind, (size_t)ident_start, (int)ident_len, (int)xv, (int)cv);
    dump_span(sl && sl->data ? sl->data : 0, ident_start, ident_len);
    printf("\n");
    if (fail)
      (*fail)++;
    return 1;
  }
  return 0;
}

/**
 * leftover_twokind eq over exhaustive TokenKind on each kind slot plus
 * AT+IDENT ident spelling / length / token_start corners.
 * Caller owns checks/fail counters.
 * @param checks long* — incremented per (case, sample) pair; null ignored
 * @param fail int* — incremented on mismatch; null ignored
 * @return int — 0 ok; 1 if any mismatch
 * PLATFORM: SHARED.
 */
int leftover_twokind_eq_run(long *checks, int *fail) {
  static const int32_t k_extra[] = {-1, -2, 256, 512, 1024, 0x7fffffff};
  static const int32_t k_null_lens[] = {-1, 0, 1, 4, 6, 7, 63, 64, 100};
  static const size_t k_null_offs[] = {0, 1, 8};
  static const int32_t k_lens[] = {0, 1, 5, 6, 7, 8, 63, 64, 65};
  static const size_t k_offs[] = {0, 1, 7, 8, 64};
  static const char *k_lits[] = {"",         "a",      "shuffle", "select", "Shuffle", "SELECT",
                                 "shuffl",   "selects", "shufflex", "i32x4",  "Vec4",    "as",
                                 "main",     "foo_bar", " ",       "\n",     "fn",      "@shuffle"};
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
  struct parser_asm_slice_u8 sl_nodata;
  uint8_t tiny[32];
  struct parser_asm_slice_u8 sl_tiny;

  memset(buf, (int)'x', sizeof(buf));
  memcpy(buf + 8, "shuffle", 7);
  sl.data = buf;
  sl.length = sizeof(buf);
  sl_nodata.data = 0;
  sl_nodata.length = 0;

  for (ci = 0; ci < sizeof(k_leftover_twokind) / sizeof(k_leftover_twokind[0]); ci++) {
    if (!leftover_twokind_selected(k_leftover_twokind[ci].name))
      continue;

    /* Kind gating: exhaustive at_kind with ident_kind=IDENT, exhaustive
     * ident_kind with at_kind=AT. One null-source sample + one valid
     * "shuffle" span per kind. Length / offset corners run only at
     * AT+IDENT (below). */
    for (kind = 0; kind <= last + 8; kind++) {
      if (check_pair(&k_leftover_twokind[ci], kind, (int32_t)TOKEN_IDENT, 0, 0, 0, checks, fail))
        any_fail = 1;
      if (check_pair(&k_leftover_twokind[ci], kind, (int32_t)TOKEN_IDENT, &sl, 8, 7, checks, fail))
        any_fail = 1;
      if (check_pair(&k_leftover_twokind[ci], (int32_t)TOKEN_AT, kind, 0, 0, 0, checks, fail))
        any_fail = 1;
      if (check_pair(&k_leftover_twokind[ci], (int32_t)TOKEN_AT, kind, &sl, 8, 7, checks, fail))
        any_fail = 1;
    }
    for (ei = 0; ei < sizeof(k_extra) / sizeof(k_extra[0]); ei++) {
      if (check_pair(&k_leftover_twokind[ci], k_extra[ei], (int32_t)TOKEN_IDENT, 0, 0, 0, checks,
                     fail))
        any_fail = 1;
      if (check_pair(&k_leftover_twokind[ci], k_extra[ei], (int32_t)TOKEN_IDENT, &sl, 8, 7, checks,
                     fail))
        any_fail = 1;
      if (check_pair(&k_leftover_twokind[ci], (int32_t)TOKEN_AT, k_extra[ei], 0, 0, 0, checks, fail))
        any_fail = 1;
      if (check_pair(&k_leftover_twokind[ci], (int32_t)TOKEN_AT, k_extra[ei], &sl, 8, 7, checks,
                     fail))
        any_fail = 1;
    }

    /* Non-null slice with data==0: C early-outs on !data; .x unwraps. */
    if (check_pair(&k_leftover_twokind[ci], (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, &sl_nodata, 0,
                   7, checks, fail))
      any_fail = 1;

    for (oi = 0; oi < sizeof(k_null_offs) / sizeof(k_null_offs[0]); oi++) {
      for (ni = 0; ni < sizeof(k_null_lens) / sizeof(k_null_lens[0]); ni++) {
        if (check_pair(&k_leftover_twokind[ci], (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, 0,
                       k_null_offs[oi], k_null_lens[ni], checks, fail))
          any_fail = 1;
      }
    }

    /* First-byte class on a 7-byte "shuffle" span (only 's' matches). */
    memcpy(buf + 8, "shuffle", 7);
    for (b = 0; b < 256; b++) {
      buf[8] = (uint8_t)b;
      if (check_pair(&k_leftover_twokind[ci], (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, &sl, 8, 7,
                     checks, fail))
        any_fail = 1;
    }
    memcpy(buf + 8, "shuffle", 7);

    /* Continue-byte class on shuffle[1] (only 'h' matches). */
    buf[8] = (uint8_t)'s';
    for (b = 0; b < 256; b++) {
      buf[9] = (uint8_t)b;
      if (check_pair(&k_leftover_twokind[ci], (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, &sl, 8, 7,
                     checks, fail))
        any_fail = 1;
    }
    memcpy(buf + 8, "shuffle", 7);

    /* First-byte class on a 6-byte "select" span (only 's' matches). */
    memcpy(buf + 8, "select", 6);
    for (b = 0; b < 256; b++) {
      buf[8] = (uint8_t)b;
      if (check_pair(&k_leftover_twokind[ci], (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, &sl, 8, 6,
                     checks, fail))
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
        if (check_pair(&k_leftover_twokind[ci], (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, &sl, off, n,
                       checks, fail))
          any_fail = 1;
        memcpy(buf + off, "select", 6);
        if (check_pair(&k_leftover_twokind[ci], (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, &sl, off, n,
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
      if (check_pair(&k_leftover_twokind[ci], (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, &sl, 8, n,
                     checks, fail))
        any_fail = 1;
      if (n > 0)
        memset(buf + 8, (int)'x', (size_t)n);
    }
    memcpy(buf + 8, "shuffle", 7);

    /* Tight source->length vs ident_start+6 / +5 (the C `< length` gate). */
    memset(tiny, (int)'x', sizeof(tiny));
    memcpy(tiny + 8, "shuffle", 7);
    sl_tiny.data = tiny;
    sl_tiny.length = 8 + 6; /* ident_start+6 == length → shuffle fail */
    if (check_pair(&k_leftover_twokind[ci], (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, &sl_tiny, 8, 7,
                   checks, fail))
      any_fail = 1;
    sl_tiny.length = 8 + 7; /* ident_start+6 < length → shuffle pass */
    if (check_pair(&k_leftover_twokind[ci], (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, &sl_tiny, 8, 7,
                   checks, fail))
      any_fail = 1;
    memcpy(tiny + 8, "select", 6);
    sl_tiny.length = 8 + 5; /* ident_start+5 == length → select fail */
    if (check_pair(&k_leftover_twokind[ci], (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, &sl_tiny, 8, 6,
                   checks, fail))
      any_fail = 1;
    sl_tiny.length = 8 + 6; /* ident_start+5 < length → select pass */
    if (check_pair(&k_leftover_twokind[ci], (int32_t)TOKEN_AT, (int32_t)TOKEN_IDENT, &sl_tiny, 8, 6,
                   checks, fail))
      any_fail = 1;
  }
  return any_fail;
}
