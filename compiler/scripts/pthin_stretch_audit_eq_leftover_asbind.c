/* leftover_asbind eq battery — 7.2.1b v5.55
 *
 * leftover_helpers whose ABI is (kind, source, token_start, ident_len,
 * next_kind, next_start, next_len) are already .x T in
 * pthin_stretch_audit.x, but they have no k_cases row: the generator
 * only tables lex:/lex_inout: audits. twins.h does not keep a static
 * C copy of import_as_bind, but a 7-param first-kind ABI still cannot
 * be a k_cases row (harness cases are lex-first).
 *
 * This TU does NOT include twins.h. It links audit_x.o (product .x)
 * and compares against an inline copy of the gated C twin (same body
 * as the suite leftover helper under FROM_X). Source is an opaque
 * parser_asm_slice_u8*; .x takes *u8 and calls lex_source_data_c.
 *
 * The C twin is a spelling check plus bind_name_validate:
 *   import_as_bind — TOKEN_IDENT + ident_len==2 + bytes "as" at
 *     token_start (token_start+1 must sit inside source->length),
 *     then TOKEN_IDENT + next_len>0 goes through bind_name_validate
 *     on source->data + next_start.
 * This file externs bind_name_validate rather than copying
 * ident_byte_ok a third time.
 *
 * Corpus is exhaustive TokenKind on each kind slot (the other slot
 * fixed at IDENT) plus IDENT+"as" spelling / length / token_start
 * corners and next-ident byte-class / length / next_start corners
 * (not a file-offset walk of product .x files). Stay inside
 * remaining >= ident_len / next_len so C data+off vs .x unwrap+off
 * cannot diverge on uninit / OOB.
 *
 * Homogeneous family is 7-param as-bind only — do not mix
 * peek_kind_chain arrays, simd_builtin_deep_from_at lex_after_ident,
 * import_path_post validate wraps, collect_imports_preamble
 * three-kind, or validate_toplevel stretch.x tables in this TU.
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

extern int32_t parser_asm_stretch_import_as_bind_audit_c(int32_t kind, const uint8_t *source,
                                                         size_t token_start, int32_t ident_len,
                                                         int32_t next_kind, size_t next_start,
                                                         int32_t next_len);

/* Harness TU (twins.h) already exports the C bind_name_validate authority. */
extern int32_t parser_asm_stretch_bind_name_validate_c(const uint8_t *name, int32_t len);

/* Gated C twin body (suite leftover helper). Static name does not
 * collide with the .x T symbol resolved from audit_x.o. */
static int32_t c_ref_import_as_bind(int32_t kind, struct parser_asm_slice_u8 *source,
                                    size_t token_start, int32_t ident_len, int32_t next_kind,
                                    size_t next_start, int32_t next_len) {
  if (!source || !source->data)
    return 0;
  if (kind != (int32_t)TOKEN_IDENT || ident_len != 2)
    return 0;
  if (token_start + 1 >= source->length)
    return 0;
  if (source->data[token_start] != (uint8_t)'a' || source->data[token_start + 1] != (uint8_t)'s')
    return 0;
  if (next_kind != (int32_t)TOKEN_IDENT || next_len <= 0)
    return 0;
  return parser_asm_stretch_bind_name_validate_c(source->data + next_start, next_len);
}

typedef int32_t (*x_fn)(int32_t kind, const uint8_t *source, size_t token_start, int32_t ident_len,
                        int32_t next_kind, size_t next_start, int32_t next_len);
typedef int32_t (*c_fn)(int32_t kind, struct parser_asm_slice_u8 *source, size_t token_start,
                        int32_t ident_len, int32_t next_kind, size_t next_start, int32_t next_len);

typedef struct {
  const char *name;
  x_fn x_ver;
  c_fn c_ref;
} leftover_asbind_case;

static const leftover_asbind_case k_leftover_asbind[] = {
    {"import_as_bind", parser_asm_stretch_import_as_bind_audit_c, c_ref_import_as_bind},
};

static int leftover_asbind_selected(const char *name) {
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

static void dump_span(const uint8_t *data, size_t off, int32_t nlen) {
  int32_t i;
  int32_t n;
  if (!data) {
    printf("(null-data)");
    return;
  }
  n = nlen;
  if (n < 0)
    n = 0;
  if (n > 16)
    n = 16;
  for (i = 0; i < n; i++)
    printf("%02x", (unsigned)data[off + (size_t)i]);
  if (nlen > 16)
    printf("...");
}

static int check_pair(const leftover_asbind_case *cs, int32_t kind, struct parser_asm_slice_u8 *sl,
                      size_t token_start, int32_t ident_len, int32_t next_kind, size_t next_start,
                      int32_t next_len, long *checks, int *fail) {
  const uint8_t *xsrc = sl ? (const uint8_t *)sl : 0;
  int32_t xv = cs->x_ver(kind, xsrc, token_start, ident_len, next_kind, next_start, next_len);
  int32_t cv = cs->c_ref(kind, sl, token_start, ident_len, next_kind, next_start, next_len);
  if (checks)
    (*checks)++;
  if (xv != cv) {
    printf("FAIL leftover_asbind %s kind=%d off=%zu len=%d next=%d noff=%zu nlen=%d .x=%d c=%d as=",
           cs->name, (int)kind, (size_t)token_start, (int)ident_len, (int)next_kind,
           (size_t)next_start, (int)next_len, (int)xv, (int)cv);
    dump_span(sl && sl->data ? sl->data : 0, token_start, ident_len);
    printf(" next=");
    dump_span(sl && sl->data ? sl->data : 0, next_start, next_len);
    printf("\n");
    if (fail)
      (*fail)++;
    return 1;
  }
  return 0;
}

/**
 * leftover_asbind eq over exhaustive TokenKind on each kind slot plus
 * IDENT+"as" spelling / length / token_start corners and next-ident
 * byte-class / length / next_start corners.
 * Caller owns checks/fail counters.
 * @param checks long* — incremented per (case, sample) pair; null ignored
 * @param fail int* — incremented on mismatch; null ignored
 * @return int — 0 ok; 1 if any mismatch
 * PLATFORM: SHARED.
 */
int leftover_asbind_eq_run(long *checks, int *fail) {
  static const int32_t k_extra[] = {-1, -2, 256, 512, 1024, 0x7fffffff};
  static const int32_t k_null_lens[] = {-1, 0, 1, 2, 4, 63, 64, 100};
  static const size_t k_null_offs[] = {0, 1, 8};
  static const int32_t k_as_lens[] = {0, 1, 2, 3, 4, 63, 64};
  static const int32_t k_next_lens[] = {0, 1, 2, 5, 62, 63, 64, 65, 100};
  static const size_t k_offs[] = {0, 1, 7, 8, 64};
  static const char *k_as_lits[] = {"", "a", "s", "as", "As", "aS", "AS", "ass", "as_", "fn"};
  static const char *k_next_lits[] = {"",     "a",     "A",      "_",     "0",     "a0",  "main",
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
  struct parser_asm_slice_u8 sl_nodata;
  uint8_t tiny[32];
  struct parser_asm_slice_u8 sl_tiny;

  memset(buf, (int)'x', sizeof(buf));
  memcpy(buf + 8, "as", 2);
  memcpy(buf + 16, "main", 4);
  sl.data = buf;
  sl.length = sizeof(buf);
  sl_nodata.data = 0;
  sl_nodata.length = 0;

  for (ci = 0; ci < sizeof(k_leftover_asbind) / sizeof(k_leftover_asbind[0]); ci++) {
    if (!leftover_asbind_selected(k_leftover_asbind[ci].name))
      continue;

    /* Kind gating: exhaustive `kind` with next_kind=IDENT, exhaustive
     * next_kind with kind=IDENT. One null-source sample + one valid
     * "as"+"main" span per kind. Length / offset corners run only at
     * IDENT+IDENT (below). */
    for (kind = 0; kind <= last + 8; kind++) {
      if (check_pair(&k_leftover_asbind[ci], kind, 0, 0, 0, (int32_t)TOKEN_IDENT, 0, 0, checks,
                     fail))
        any_fail = 1;
      if (check_pair(&k_leftover_asbind[ci], kind, &sl, 8, 2, (int32_t)TOKEN_IDENT, 16, 4, checks,
                     fail))
        any_fail = 1;
      if (check_pair(&k_leftover_asbind[ci], (int32_t)TOKEN_IDENT, 0, 0, 0, kind, 0, 0, checks, fail))
        any_fail = 1;
      if (check_pair(&k_leftover_asbind[ci], (int32_t)TOKEN_IDENT, &sl, 8, 2, kind, 16, 4, checks,
                     fail))
        any_fail = 1;
    }
    for (ei = 0; ei < sizeof(k_extra) / sizeof(k_extra[0]); ei++) {
      if (check_pair(&k_leftover_asbind[ci], k_extra[ei], 0, 0, 0, (int32_t)TOKEN_IDENT, 0, 0,
                     checks, fail))
        any_fail = 1;
      if (check_pair(&k_leftover_asbind[ci], k_extra[ei], &sl, 8, 2, (int32_t)TOKEN_IDENT, 16, 4,
                     checks, fail))
        any_fail = 1;
      if (check_pair(&k_leftover_asbind[ci], (int32_t)TOKEN_IDENT, 0, 0, 0, k_extra[ei], 0, 0,
                     checks, fail))
        any_fail = 1;
      if (check_pair(&k_leftover_asbind[ci], (int32_t)TOKEN_IDENT, &sl, 8, 2, k_extra[ei], 16, 4,
                     checks, fail))
        any_fail = 1;
    }

    /* Non-null slice with data==0: C early-outs on !data; .x unwraps. */
    if (check_pair(&k_leftover_asbind[ci], (int32_t)TOKEN_IDENT, &sl_nodata, 8, 2,
                   (int32_t)TOKEN_IDENT, 16, 4, checks, fail))
      any_fail = 1;

    for (oi = 0; oi < sizeof(k_null_offs) / sizeof(k_null_offs[0]); oi++) {
      for (ni = 0; ni < sizeof(k_null_lens) / sizeof(k_null_lens[0]); ni++) {
        if (check_pair(&k_leftover_asbind[ci], (int32_t)TOKEN_IDENT, 0, k_null_offs[oi],
                       k_null_lens[ni], (int32_t)TOKEN_IDENT, k_null_offs[oi], k_null_lens[ni],
                       checks, fail))
          any_fail = 1;
      }
    }

    /* ident_len != 2 corners with "as" bytes at off=8 (must all fail). */
    memcpy(buf + 8, "as", 2);
    memcpy(buf + 16, "main", 4);
    for (ni = 0; ni < sizeof(k_as_lens) / sizeof(k_as_lens[0]); ni++) {
      if (check_pair(&k_leftover_asbind[ci], (int32_t)TOKEN_IDENT, &sl, 8, k_as_lens[ni],
                     (int32_t)TOKEN_IDENT, 16, 4, checks, fail))
        any_fail = 1;
    }

    /* First-byte class on a 2-byte "as" span (only 'a' matches). */
    memcpy(buf + 8, "as", 2);
    for (b = 0; b < 256; b++) {
      buf[8] = (uint8_t)b;
      if (check_pair(&k_leftover_asbind[ci], (int32_t)TOKEN_IDENT, &sl, 8, 2, (int32_t)TOKEN_IDENT,
                     16, 4, checks, fail))
        any_fail = 1;
    }
    memcpy(buf + 8, "as", 2);

    /* Second-byte class on "as"[1] (only 's' matches). */
    buf[8] = (uint8_t)'a';
    for (b = 0; b < 256; b++) {
      buf[9] = (uint8_t)b;
      if (check_pair(&k_leftover_asbind[ci], (int32_t)TOKEN_IDENT, &sl, 8, 2, (int32_t)TOKEN_IDENT,
                     16, 4, checks, fail))
        any_fail = 1;
    }
    memcpy(buf + 8, "as", 2);

    /* Next-ident first-byte class (bind_name_validate) at a non-zero offset. */
    memcpy(buf + 16, "main", 4);
    for (b = 0; b < 256; b++) {
      buf[16] = (uint8_t)b;
      if (check_pair(&k_leftover_asbind[ci], (int32_t)TOKEN_IDENT, &sl, 8, 2, (int32_t)TOKEN_IDENT,
                     16, 1, checks, fail))
        any_fail = 1;
    }
    memcpy(buf + 16, "main", 4);

    buf[16] = (uint8_t)'a';
    for (b = 0; b < 256; b++) {
      buf[17] = (uint8_t)b;
      if (check_pair(&k_leftover_asbind[ci], (int32_t)TOKEN_IDENT, &sl, 8, 2, (int32_t)TOKEN_IDENT,
                     16, 2, checks, fail))
        any_fail = 1;
    }
    memcpy(buf + 16, "main", 4);

    /* "as" offset × ident_len; stay remaining >= ident_len. Next ident
     * stays at 16/"main" unless the as-span would overlap it — then skip. */
    for (oi = 0; oi < sizeof(k_offs) / sizeof(k_offs[0]); oi++) {
      for (ni = 0; ni < sizeof(k_as_lens) / sizeof(k_as_lens[0]); ni++) {
        size_t off = k_offs[oi];
        int32_t n = k_as_lens[ni];
        if (n > 0 && off + (size_t)n > sl.length)
          continue;
        if (n > 0 && off < 16 && off + (size_t)n > 16)
          continue;
        memcpy(buf + off, "asxx", 4);
        if (check_pair(&k_leftover_asbind[ci], (int32_t)TOKEN_IDENT, &sl, off, n,
                       (int32_t)TOKEN_IDENT, 16, 4, checks, fail))
          any_fail = 1;
        memset(buf + off, (int)'x', 4);
      }
    }
    memcpy(buf + 8, "as", 2);
    memcpy(buf + 16, "main", 4);

    /* Next-ident offset × length; stay remaining >= next_len. "as" stays
     * at 8. Skip overlap with the 2-byte as-span. */
    for (oi = 0; oi < sizeof(k_offs) / sizeof(k_offs[0]); oi++) {
      for (ni = 0; ni < sizeof(k_next_lens) / sizeof(k_next_lens[0]); ni++) {
        size_t off = k_offs[oi];
        int32_t n = k_next_lens[ni];
        if (n > 0 && off + (size_t)n > sl.length)
          continue;
        if (n > 0 && off < 10 && off + (size_t)n > 8)
          continue;
        if (check_pair(&k_leftover_asbind[ci], (int32_t)TOKEN_IDENT, &sl, 8, 2,
                       (int32_t)TOKEN_IDENT, off, n, checks, fail))
          any_fail = 1;
      }
    }

    for (li = 0; li < sizeof(k_as_lits) / sizeof(k_as_lits[0]); li++) {
      const uint8_t *p = (const uint8_t *)k_as_lits[li];
      int32_t n = (int32_t)strlen(k_as_lits[li]);
      if (n > 0)
        memcpy(buf + 8, p, (size_t)n);
      if (check_pair(&k_leftover_asbind[ci], (int32_t)TOKEN_IDENT, &sl, 8, n, (int32_t)TOKEN_IDENT,
                     16, 4, checks, fail))
        any_fail = 1;
      if (n == 2)
        if (check_pair(&k_leftover_asbind[ci], (int32_t)TOKEN_IDENT, &sl, 8, 2,
                       (int32_t)TOKEN_IDENT, 16, 4, checks, fail))
          any_fail = 1;
      if (n > 0)
        memset(buf + 8, (int)'x', (size_t)n);
    }
    memcpy(buf + 8, "as", 2);
    memcpy(buf + 16, "main", 4);

    for (li = 0; li < sizeof(k_next_lits) / sizeof(k_next_lits[0]); li++) {
      const uint8_t *p = (const uint8_t *)k_next_lits[li];
      int32_t n = (int32_t)strlen(k_next_lits[li]);
      if (n > 0)
        memcpy(buf + 16, p, (size_t)n);
      if (check_pair(&k_leftover_asbind[ci], (int32_t)TOKEN_IDENT, &sl, 8, 2, (int32_t)TOKEN_IDENT,
                     16, n, checks, fail))
        any_fail = 1;
      if (n > 0)
        memset(buf + 16, (int)'x', (size_t)n);
    }
    memcpy(buf + 8, "as", 2);
    memcpy(buf + 16, "main", 4);

    /* Tight source->length vs token_start+1 (the C `>= length` gate). */
    memset(tiny, (int)'x', sizeof(tiny));
    memcpy(tiny + 8, "as", 2);
    memcpy(tiny + 16, "main", 4);
    sl_tiny.data = tiny;
    sl_tiny.length = 8 + 1; /* token_start+1 == length → "as" fail */
    if (check_pair(&k_leftover_asbind[ci], (int32_t)TOKEN_IDENT, &sl_tiny, 8, 2,
                   (int32_t)TOKEN_IDENT, 16, 4, checks, fail))
      any_fail = 1;
    sl_tiny.length = 8 + 2; /* token_start+1 < length, but next at 16 OOB */
    if (check_pair(&k_leftover_asbind[ci], (int32_t)TOKEN_IDENT, &sl_tiny, 8, 2,
                   (int32_t)TOKEN_IDENT, 8, 2, checks, fail))
      any_fail = 1;
    sl_tiny.length = 20; /* "as" at 8 + "main" at 16 both inside */
    if (check_pair(&k_leftover_asbind[ci], (int32_t)TOKEN_IDENT, &sl_tiny, 8, 2,
                   (int32_t)TOKEN_IDENT, 16, 4, checks, fail))
      any_fail = 1;
  }
  return any_fail;
}
