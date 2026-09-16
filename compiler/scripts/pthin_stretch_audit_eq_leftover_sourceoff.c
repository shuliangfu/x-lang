/* leftover_sourceoff eq battery — 7.2.1b v5.52
 *
 * leftover_helpers whose ABI is (source, token_start, name_len) are
 * already .x T in pthin_stretch_audit.x, but they have no k_cases row:
 * the generator only tables lex:/lex_inout: audits. twins.h also keeps
 * static C copies under some product names (struct_field_bind /
 * enum_variant_bind / import_select_item_bind / vector_type_ident) so
 * c_ref twins keep C authority — those statics shadow the .x T in the
 * harness TU.
 *
 * This TU does NOT include twins.h. It links audit_x.o (product .x)
 * and compares against inline copies of the gated C twins (same
 * bodies as suite leftover helpers under FROM_X). Source is an opaque
 * parser_asm_slice_u8*; .x takes *u8 and calls lex_source_data_c.
 *
 * Five of six C twins are G.7 thin wraps of bind_name_validate on
 * source->data + token_start. vector_type_ident adds i3x* / Vec*
 * special-cases then the same wrap. This file externs bind_name_validate
 * rather than copying ident_byte_ok a third time.
 *
 * Corpus is ident byte-class + length corners + token_start offsets +
 * vector spellings (not a file-offset walk of product .x files).
 * Callers always pass lexer ident spans (remaining >= name_len); the
 * battery stays inside that contract so C name_buf copy vs .x direct
 * pointer cannot diverge on uninit / OOB.
 *
 * classify / import_path_score stay stretch.x (G.7; not leftover-to-audit).
 * PLATFORM: SHARED — compiled into the existing eq harness.
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct parser_asm_slice_u8 {
  uint8_t *data;
  size_t length;
};

extern int32_t parser_asm_stretch_struct_field_bind_audit_c(const uint8_t *source, size_t token_start,
                                                           int32_t name_len);
extern int32_t parser_asm_stretch_enum_variant_bind_audit_c(const uint8_t *source, size_t token_start,
                                                           int32_t name_len);
extern int32_t parser_asm_stretch_field_access_name_audit_c(const uint8_t *source, size_t token_start,
                                                           int32_t name_len);
extern int32_t parser_asm_stretch_import_select_bind_audit_c(const uint8_t *source, size_t token_start,
                                                            int32_t name_len);
extern int32_t parser_asm_stretch_import_select_item_bind_audit_c(const uint8_t *source, size_t token_start,
                                                                 int32_t name_len);
extern int32_t parser_asm_stretch_vector_type_ident_audit_c(const uint8_t *source, size_t token_start,
                                                           int32_t nlen);

/* Harness TU (twins.h) already exports the C bind_name_validate authority. */
extern int32_t parser_asm_stretch_bind_name_validate_c(const uint8_t *name, int32_t len);

/* Gated C twin bodies (suite leftover helpers). Static names do not
 * collide with the .x T symbols resolved from audit_x.o. */
static int32_t c_ref_struct_field_bind(struct parser_asm_slice_u8 *source, size_t token_start,
                                      int32_t name_len) {
  if (!source || name_len <= 0)
    return 0;
  return parser_asm_stretch_bind_name_validate_c(source->data + token_start, name_len);
}

static int32_t c_ref_enum_variant_bind(struct parser_asm_slice_u8 *source, size_t token_start,
                                      int32_t name_len) {
  if (!source || name_len <= 0)
    return 0;
  return parser_asm_stretch_bind_name_validate_c(source->data + token_start, name_len);
}

static int32_t c_ref_field_access_name(struct parser_asm_slice_u8 *source, size_t token_start,
                                      int32_t name_len) {
  if (!source || name_len <= 0)
    return 0;
  return parser_asm_stretch_bind_name_validate_c(source->data + token_start, name_len);
}

static int32_t c_ref_import_select_bind(struct parser_asm_slice_u8 *source, size_t token_start,
                                       int32_t name_len) {
  if (!source || name_len <= 0)
    return 0;
  return parser_asm_stretch_bind_name_validate_c(source->data + token_start, name_len);
}

static int32_t c_ref_import_select_item_bind(struct parser_asm_slice_u8 *source, size_t token_start,
                                            int32_t name_len) {
  if (!source || name_len <= 0)
    return 0;
  return parser_asm_stretch_bind_name_validate_c(source->data + token_start, name_len);
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

typedef int32_t (*x_fn)(const uint8_t *source, size_t token_start, int32_t name_len);
typedef int32_t (*c_fn)(struct parser_asm_slice_u8 *source, size_t token_start, int32_t name_len);

typedef struct {
  const char *name;
  x_fn x_ver;
  c_fn c_ref;
} leftover_sourceoff_case;

static const leftover_sourceoff_case k_leftover_sourceoff[] = {
    {"struct_field_bind", parser_asm_stretch_struct_field_bind_audit_c, c_ref_struct_field_bind},
    {"enum_variant_bind", parser_asm_stretch_enum_variant_bind_audit_c, c_ref_enum_variant_bind},
    {"field_access_name", parser_asm_stretch_field_access_name_audit_c, c_ref_field_access_name},
    {"import_select_bind", parser_asm_stretch_import_select_bind_audit_c, c_ref_import_select_bind},
    {"import_select_item_bind", parser_asm_stretch_import_select_item_bind_audit_c,
     c_ref_import_select_item_bind},
    {"vector_type_ident", parser_asm_stretch_vector_type_ident_audit_c, c_ref_vector_type_ident},
};

static int leftover_sourceoff_selected(const char *name) {
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

static int check_pair(const leftover_sourceoff_case *cs, struct parser_asm_slice_u8 *sl,
                      size_t token_start, int32_t name_len, long *checks, int *fail) {
  const uint8_t *xsrc = sl ? (const uint8_t *)sl : 0;
  int32_t xv = cs->x_ver(xsrc, token_start, name_len);
  int32_t cv = cs->c_ref(sl, token_start, name_len);
  if (checks)
    (*checks)++;
  if (xv != cv) {
    printf("FAIL leftover_sourceoff %s off=%zu len=%d .x=%d c=%d span=", cs->name,
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
 * leftover_sourceoff eq over ident byte-class + length + token_start corners.
 * Caller owns checks/fail counters.
 * @param checks long* — incremented per (case, sample) pair; null ignored
 * @param fail int* — incremented on mismatch; null ignored
 * @return int — 0 ok; 1 if any mismatch
 * PLATFORM: SHARED.
 */
int leftover_sourceoff_eq_run(long *checks, int *fail) {
  static const int32_t k_null_lens[] = {-1, 0, 1, 4, 63, 64, 100};
  static const size_t k_null_offs[] = {0, 1, 8};
  static const int32_t k_lens[] = {0, 1, 2, 5, 62, 63, 64, 65, 100};
  static const size_t k_offs[] = {0, 1, 7, 8, 64};
  static const char *k_lits[] = {"",     "a",     "A",      "_",     "0",     "a0",  "main",
                                 "foo_bar", "_x",  "0x",     "a.b",    "I32",   " ",   "\n",
                                 "a-b",     "fn",  "struct", "import"};
  static const char *k_vec[] = {"i3x4", "i3x8", "i3xy", "i32x", "i32x4", "Vec4f", "Vec", "vector",
                                "VEC4f", "i3X4"};
  size_t ci;
  int any_fail = 0;
  int32_t b;
  size_t li;
  size_t ni;
  size_t oi;
  uint8_t buf[512];
  struct parser_asm_slice_u8 sl;

  memset(buf, (int)'x', sizeof(buf));
  sl.data = buf;
  sl.length = sizeof(buf);

  for (ci = 0; ci < sizeof(k_leftover_sourceoff) / sizeof(k_leftover_sourceoff[0]); ci++) {
    int cs_is_vector;
    if (!leftover_sourceoff_selected(k_leftover_sourceoff[ci].name))
      continue;
    cs_is_vector = strcmp(k_leftover_sourceoff[ci].name, "vector_type_ident") == 0;

    for (oi = 0; oi < sizeof(k_null_offs) / sizeof(k_null_offs[0]); oi++) {
      for (ni = 0; ni < sizeof(k_null_lens) / sizeof(k_null_lens[0]); ni++) {
        if (check_pair(&k_leftover_sourceoff[ci], 0, k_null_offs[oi], k_null_lens[ni], checks, fail))
          any_fail = 1;
      }
    }

    /* First-byte class at a non-zero offset so token_start is exercised. */
    for (b = 0; b < 256; b++) {
      buf[8] = (uint8_t)b;
      if (check_pair(&k_leftover_sourceoff[ci], &sl, 8, 1, checks, fail))
        any_fail = 1;
    }
    buf[8] = (uint8_t)'x';

    buf[8] = (uint8_t)'a';
    for (b = 0; b < 256; b++) {
      buf[9] = (uint8_t)b;
      if (check_pair(&k_leftover_sourceoff[ci], &sl, 8, 2, checks, fail))
        any_fail = 1;
    }
    buf[8] = (uint8_t)'x';
    buf[9] = (uint8_t)'x';

    for (oi = 0; oi < sizeof(k_offs) / sizeof(k_offs[0]); oi++) {
      for (ni = 0; ni < sizeof(k_lens) / sizeof(k_lens[0]); ni++) {
        size_t off = k_offs[oi];
        int32_t n = k_lens[ni];
        /* Stay inside remaining >= name_len so C name_buf vs .x pointer match. */
        if (n > 0 && off + (size_t)n > sl.length)
          continue;
        if (check_pair(&k_leftover_sourceoff[ci], &sl, off, n, checks, fail))
          any_fail = 1;
      }
    }

    for (li = 0; li < sizeof(k_lits) / sizeof(k_lits[0]); li++) {
      const uint8_t *p = (const uint8_t *)k_lits[li];
      int32_t n = (int32_t)strlen(k_lits[li]);
      if (n > 0)
        memcpy(buf + 8, p, (size_t)n);
      if (check_pair(&k_leftover_sourceoff[ci], &sl, 8, n, checks, fail))
        any_fail = 1;
      if (n > 0)
        memset(buf + 8, (int)'x', (size_t)n);
    }

    for (li = 0; li < sizeof(k_vec) / sizeof(k_vec[0]); li++) {
      const uint8_t *p = (const uint8_t *)k_vec[li];
      int32_t n = (int32_t)strlen(k_vec[li]);
      memcpy(buf + 8, p, (size_t)n);
      if (check_pair(&k_leftover_sourceoff[ci], &sl, 8, n, checks, fail))
        any_fail = 1;
      /* vector_type_ident only: i3x* / Vec* prefix with remaining == 3,
       * nlen == 5 hits the special-case return-1 before bind_name_validate.
       * Other helpers (and non-matching prefixes) would OOB / uninit-diverge. */
      if (cs_is_vector && n >= 3 &&
          ((p[0] == 105 && p[1] == 51 && p[2] == 120) ||
           (p[0] == 86 && p[1] == 101 && p[2] == 99))) {
        struct parser_asm_slice_u8 shortsl;
        shortsl.data = buf;
        shortsl.length = 8 + 3;
        if (check_pair(&k_leftover_sourceoff[ci], &shortsl, 8, 5, checks, fail))
          any_fail = 1;
      }
      memset(buf + 8, (int)'x', (size_t)n);
    }
  }
  return any_fail;
}
