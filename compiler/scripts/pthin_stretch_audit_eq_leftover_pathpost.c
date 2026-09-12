/* leftover_pathpost eq battery — 7.2.1b v5.58
 *
 * leftover_helpers whose ABI is (path_buf, path_len, source) are already
 * .x T in pthin_stretch_audit.x, but they have no k_cases row: the
 * generator only tables lex:/lex_inout: audits. twins.h does not keep a
 * static C copy of import_path_post (gated in the suite leftover helper),
 * but a first-path_buf ABI still cannot be a k_cases row (harness cases
 * are lex-first).
 *
 * This TU does NOT include twins.h. It links audit_x.o (product .x)
 * and compares against an inline copy of the gated C twin (same body
 * as the suite leftover helper under FROM_X). Source is an opaque
 * parser_asm_slice_u8*; .x takes *u8. Both sides ignore source except
 * the historical ABI slot (C (void)source; .x no-op null assign).
 *
 * Flattened body (v5.48) is a thin wrap of import_path_validate_c —
 * already stretch.x / twins.h authority. This file externs that
 * symbol rather than copying ident_continue / ident_byte_ok tables
 * (G.7). After a successful caller-side finalize the second
 * normalize is identity, so validate-only matches the historical
 * second finalize. Return is path_len when valid, else 0.
 *
 * Corpus is ident-byte / dot / invalid-byte / length corners
 * including the shared path_len>63 cap inside validate (this locks
 * that shared arithmetic, it does not "fix" it). Not a file-offset
 * walk of product .x files.
 *
 * Homogeneous family is import_path_post validate wrap only — do not
 * mix simd_builtin_deep_from_at lex_after_ident or
 * collect_imports_preamble three-kind in this TU. classify /
 * import_path_score stay stretch.x (G.7; not leftover-to-audit).
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

extern int32_t parser_asm_stretch_import_path_post_audit_c(uint8_t *path_buf, int32_t path_len,
                                                          const uint8_t *source);

/* Harness TU (twins.h) already exports the C import_path_validate authority. */
extern int32_t parser_asm_stretch_import_path_validate_c(const uint8_t *path, int32_t path_len);

/* Gated C twin body (suite leftover helper). Static name does not
 * collide with the .x T symbol resolved from audit_x.o. */
static int32_t c_ref_import_path_post(uint8_t *path_buf, int32_t path_len,
                                     struct parser_asm_slice_u8 *source) {
  if (!path_buf || path_len <= 0)
    return 0;
  (void)source;
  if (parser_asm_stretch_import_path_validate_c(path_buf, path_len) == 0)
    return 0;
  return path_len;
}

typedef int32_t (*x_fn)(uint8_t *path_buf, int32_t path_len, const uint8_t *source);
typedef int32_t (*c_fn)(uint8_t *path_buf, int32_t path_len, struct parser_asm_slice_u8 *source);

typedef struct {
  const char *name;
  x_fn x_ver;
  c_fn c_ref;
} leftover_pathpost_case;

static const leftover_pathpost_case k_leftover_pathpost[] = {
    {"import_path_post", parser_asm_stretch_import_path_post_audit_c, c_ref_import_path_post},
};

static int leftover_pathpost_selected(const char *name) {
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

static void dump_path(const uint8_t *path, int32_t path_len) {
  int32_t i;
  int32_t n;
  if (!path) {
    printf("(null)");
    return;
  }
  n = path_len;
  if (n < 0)
    n = 0;
  if (n > 16)
    n = 16;
  for (i = 0; i < n; i++)
    printf("%02x", (unsigned)path[i]);
  if (path_len > 16)
    printf("...");
}

static int check_one(const leftover_pathpost_case *cs, uint8_t *path_buf, int32_t path_len,
                     struct parser_asm_slice_u8 *sl, long *checks, int *fail) {
  const uint8_t *xsrc = sl ? (const uint8_t *)sl : 0;
  int32_t xv = cs->x_ver(path_buf, path_len, xsrc);
  int32_t cv = cs->c_ref(path_buf, path_len, sl);
  if (checks)
    (*checks)++;
  if (xv != cv) {
    printf("FAIL leftover_pathpost %s len=%d src=%s .x=%d c=%d path=", cs->name, (int)path_len,
           sl && sl->data ? "live" : (sl ? "nodata" : "null"), (int)xv, (int)cv);
    dump_path(path_buf, path_len);
    printf("\n");
    if (fail)
      (*fail)++;
    return 1;
  }
  return 0;
}

/**
 * leftover_pathpost eq over ident-byte / dot / invalid-byte / length
 * corners, plus null path_buf and unused-source samples.
 * Caller owns checks/fail counters.
 * @param checks long* — incremented per (case, sample) pair; null ignored
 * @param fail int* — incremented on mismatch; null ignored
 * @return int — 0 ok; 1 if any mismatch
 * PLATFORM: SHARED.
 */
int leftover_pathpost_eq_run(long *checks, int *fail) {
  static const int32_t k_null_lens[] = {-100, -1, 0, 1, 3, 7, 63, 64, 100, 0x7fffffff};
  static const int32_t k_lens[] = {-1, 0, 1, 2, 3, 7, 8, 16, 32, 62, 63, 64, 65, 100, 256,
                                   0x7fffffff};
  static const char *k_lits[] = {"",        "a",      "A",       "_",      "0",     "a0",
                                 "foo",     "foo.bar", "std.io", "foo.bar.baz", "I32",  " ",
                                 "\n",      "a-b",     "foo/bar", "foo@bar", ".",    "..",
                                 "foo.",    ".foo",    "1foo",    "_x.y2"};
  static const uint8_t k_bytes[] = {'a', 'Z', '0', '_', '.', '-', '/', ' ', '@', 0, 127, 255};
  size_t ci;
  int any_fail = 0;
  size_t li;
  size_t ni;
  size_t bi;
  size_t pi;
  uint8_t longbuf[128];
  uint8_t srcbuf[8];
  struct parser_asm_slice_u8 sl;
  struct parser_asm_slice_u8 sl_nodata;
  struct parser_asm_slice_u8 sl_empty;

  memset(longbuf, (int)'x', sizeof(longbuf));
  memset(srcbuf, (int)'s', sizeof(srcbuf));
  sl.data = srcbuf;
  sl.length = sizeof(srcbuf);
  sl_nodata.data = 0;
  sl_nodata.length = 0;
  sl_empty.data = srcbuf;
  sl_empty.length = 0;

  for (ci = 0; ci < sizeof(k_leftover_pathpost) / sizeof(k_leftover_pathpost[0]); ci++) {
    if (!leftover_pathpost_selected(k_leftover_pathpost[ci].name))
      continue;

    /* Null path_buf: both sides early-out regardless of source. */
    for (ni = 0; ni < sizeof(k_null_lens) / sizeof(k_null_lens[0]); ni++) {
      if (check_one(&k_leftover_pathpost[ci], 0, k_null_lens[ni], 0, checks, fail))
        any_fail = 1;
      if (check_one(&k_leftover_pathpost[ci], 0, k_null_lens[ni], &sl, checks, fail))
        any_fail = 1;
      if (check_one(&k_leftover_pathpost[ci], 0, k_null_lens[ni], &sl_nodata, checks, fail))
        any_fail = 1;
    }

    /* Literal paths: copy into longbuf so path_len can exceed strlen
     * (validate stops at NUL; leftover still returns the caller's
     * path_len when the capped prefix is valid). */
    for (li = 0; li < sizeof(k_lits) / sizeof(k_lits[0]); li++) {
      size_t lit_n = strlen(k_lits[li]);
      memset(longbuf, 0, sizeof(longbuf));
      if (lit_n > 0)
        memcpy(longbuf, k_lits[li], lit_n < sizeof(longbuf) ? lit_n : sizeof(longbuf));
      for (ni = 0; ni < sizeof(k_lens) / sizeof(k_lens[0]); ni++) {
        if (check_one(&k_leftover_pathpost[ci], longbuf, k_lens[ni], 0, checks, fail))
          any_fail = 1;
        if (check_one(&k_leftover_pathpost[ci], longbuf, k_lens[ni], &sl, checks, fail))
          any_fail = 1;
        if (check_one(&k_leftover_pathpost[ci], longbuf, k_lens[ni], &sl_nodata, checks, fail))
          any_fail = 1;
        if (check_one(&k_leftover_pathpost[ci], longbuf, k_lens[ni], &sl_empty, checks, fail))
          any_fail = 1;
      }
    }

    /* Fill-byte buffers: all ident, all dots, all invalid, mixed. */
    memset(longbuf, (int)'x', sizeof(longbuf));
    for (ni = 0; ni < sizeof(k_lens) / sizeof(k_lens[0]); ni++) {
      if (check_one(&k_leftover_pathpost[ci], longbuf, k_lens[ni], &sl, checks, fail))
        any_fail = 1;
    }
    memset(longbuf, (int)'.', sizeof(longbuf));
    for (ni = 0; ni < sizeof(k_lens) / sizeof(k_lens[0]); ni++) {
      if (check_one(&k_leftover_pathpost[ci], longbuf, k_lens[ni], &sl, checks, fail))
        any_fail = 1;
    }
    memset(longbuf, (int)'-', sizeof(longbuf));
    for (ni = 0; ni < sizeof(k_lens) / sizeof(k_lens[0]); ni++) {
      if (check_one(&k_leftover_pathpost[ci], longbuf, k_lens[ni], &sl, checks, fail))
        any_fail = 1;
    }

    /* Single-byte class at pos 0 and pos 3 on an otherwise-ident buffer. */
    for (bi = 0; bi < sizeof(k_bytes) / sizeof(k_bytes[0]); bi++) {
      static const size_t k_pos[] = {0, 3};
      for (pi = 0; pi < sizeof(k_pos) / sizeof(k_pos[0]); pi++) {
        memset(longbuf, (int)'a', sizeof(longbuf));
        longbuf[k_pos[pi]] = k_bytes[bi];
        if (check_one(&k_leftover_pathpost[ci], longbuf, 1, &sl, checks, fail))
          any_fail = 1;
        if (check_one(&k_leftover_pathpost[ci], longbuf, 4, &sl, checks, fail))
          any_fail = 1;
        if (check_one(&k_leftover_pathpost[ci], longbuf, 8, &sl, checks, fail))
          any_fail = 1;
        if (check_one(&k_leftover_pathpost[ci], longbuf, 63, &sl, checks, fail))
          any_fail = 1;
        if (check_one(&k_leftover_pathpost[ci], longbuf, 64, &sl, checks, fail))
          any_fail = 1;
      }
    }
  }
  return any_fail;
}
