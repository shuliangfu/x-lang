/* leftover_namelen eq battery — 7.2.1b v5.51
 *
 * leftover_helpers whose ABI is (name: *u8, name_len: i32) are already
 * .x T in pthin_stretch_audit.x, but they have no k_cases row: the
 * generator only tables lex:/lex_inout: audits. twins.h also keeps
 * static C copies under some product names (function_name /
 * struct_layout_name) so c_ref twins keep C authority — those statics
 * shadow the .x T in the harness TU.
 *
 * This TU does NOT include twins.h. It links audit_x.o (product .x)
 * and compares against inline copies of the gated C twins (same
 * bodies as suite leftover helpers under FROM_X). Name space is a
 * byte-class battery (not a file-offset walk): first/continue bytes
 * 0..255, length corners, null pointer, and a few ident literals.
 *
 * C twins are G.7 thin wraps of bind_name_validate (already T in the
 * harness TU via twins.h). This file externs that authority rather
 * than copying ident_byte_ok / bind_name_validate a third time.
 *
 * classify / import_path_score stay stretch.x (G.7; not leftover-to-audit).
 * PLATFORM: SHARED — compiled into the existing eq harness.
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int32_t parser_asm_stretch_function_name_audit_c(const uint8_t *name, int32_t name_len);
extern int32_t parser_asm_stretch_struct_layout_name_audit_c(const uint8_t *name, int32_t name_len);
extern int32_t parser_asm_stretch_block_bind_name_audit_c(const uint8_t *name, int32_t name_len);
extern int32_t parser_asm_stretch_collect_imports_bind_audit_c(const uint8_t *bind, int32_t bind_len);
extern int32_t parser_asm_stretch_library_field_bind_audit_c(const uint8_t *name, int32_t name_len);
extern int32_t parser_asm_stretch_library_param_bind_audit_c(const uint8_t *name, int32_t name_len);
extern int32_t parser_asm_stretch_onefunc_buf_name_audit_c(const uint8_t *name, int32_t name_len);
extern int32_t parser_asm_stretch_extern_param_bind_audit_c(const uint8_t *name, int32_t name_len);

/* Harness TU (twins.h) already exports the C bind_name_validate authority. */
extern int32_t parser_asm_stretch_bind_name_validate_c(const uint8_t *name, int32_t len);

/* Gated C twin bodies (suite leftover helpers). Static names do not
 * collide with the .x T symbols resolved from audit_x.o. */
static int32_t c_ref_function_name(const uint8_t *name, int32_t name_len) {
  return parser_asm_stretch_bind_name_validate_c(name, name_len);
}

static int32_t c_ref_struct_layout_name(const uint8_t *name, int32_t name_len) {
  return parser_asm_stretch_bind_name_validate_c(name, name_len);
}

static int32_t c_ref_block_bind_name(const uint8_t *name, int32_t name_len) {
  return parser_asm_stretch_bind_name_validate_c(name, name_len);
}

static int32_t c_ref_collect_imports_bind(const uint8_t *bind, int32_t bind_len) {
  return parser_asm_stretch_bind_name_validate_c(bind, bind_len);
}

static int32_t c_ref_library_field_bind(const uint8_t *name, int32_t name_len) {
  if (!name || name_len <= 0)
    return 0;
  return parser_asm_stretch_bind_name_validate_c(name, name_len);
}

static int32_t c_ref_library_param_bind(const uint8_t *name, int32_t name_len) {
  return parser_asm_stretch_bind_name_validate_c(name, name_len);
}

static int32_t c_ref_onefunc_buf_name(const uint8_t *name, int32_t name_len) {
  return c_ref_function_name(name, name_len);
}

static int32_t c_ref_extern_param_bind(const uint8_t *name, int32_t name_len) {
  return c_ref_library_param_bind(name, name_len);
}

typedef int32_t (*namelen_fn)(const uint8_t *name, int32_t name_len);

typedef struct {
  const char *name;
  namelen_fn x_ver;
  namelen_fn c_ref;
} leftover_namelen_case;

static const leftover_namelen_case k_leftover_namelen[] = {
    {"function_name", parser_asm_stretch_function_name_audit_c, c_ref_function_name},
    {"struct_layout_name", parser_asm_stretch_struct_layout_name_audit_c, c_ref_struct_layout_name},
    {"block_bind_name", parser_asm_stretch_block_bind_name_audit_c, c_ref_block_bind_name},
    {"collect_imports_bind", parser_asm_stretch_collect_imports_bind_audit_c,
     c_ref_collect_imports_bind},
    {"library_field_bind", parser_asm_stretch_library_field_bind_audit_c, c_ref_library_field_bind},
    {"library_param_bind", parser_asm_stretch_library_param_bind_audit_c, c_ref_library_param_bind},
    {"onefunc_buf_name", parser_asm_stretch_onefunc_buf_name_audit_c, c_ref_onefunc_buf_name},
    {"extern_param_bind", parser_asm_stretch_extern_param_bind_audit_c, c_ref_extern_param_bind},
};

static int leftover_namelen_selected(const char *name) {
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

static void dump_name(const uint8_t *name, int32_t name_len) {
  int32_t i;
  int32_t n;
  if (!name) {
    printf("(null)");
    return;
  }
  n = name_len;
  if (n < 0)
    n = 0;
  if (n > 16)
    n = 16;
  for (i = 0; i < n; i++)
    printf("%02x", (unsigned)name[i]);
  if (name_len > 16)
    printf("...");
}

static int check_pair(const leftover_namelen_case *cs, const uint8_t *name, int32_t name_len,
                      long *checks, int *fail) {
  int32_t xv = cs->x_ver(name, name_len);
  int32_t cv = cs->c_ref(name, name_len);
  if (checks)
    (*checks)++;
  if (xv != cv) {
    printf("FAIL leftover_namelen %s len=%d .x=%d c=%d name=", cs->name, (int)name_len, (int)xv,
           (int)cv);
    dump_name(name, name_len);
    printf("\n");
    if (fail)
      (*fail)++;
    return 1;
  }
  return 0;
}

/**
 * leftover_namelen eq over ident byte-class + length corners.
 * Caller owns checks/fail counters.
 * @param checks long* — incremented per (case, sample) pair; null ignored
 * @param fail int* — incremented on mismatch; null ignored
 * @return int — 0 ok; 1 if any mismatch
 * PLATFORM: SHARED.
 */
int leftover_namelen_eq_run(long *checks, int *fail) {
  static const int32_t k_null_lens[] = {-1, 0, 1, 4, 63, 64, 100};
  static const int32_t k_lens[] = {0, 1, 2, 62, 63, 64, 65, 100};
  static const char *k_lits[] = {"",     "a",     "A",      "_",     "0",     "a0",  "main",
                                 "foo_bar", "_x",  "0x",     "a.b",    "I32",   " ",   "\n",
                                 "a-b",     "fn",  "struct", "import"};
  size_t ci;
  int any_fail = 0;
  int32_t b;
  size_t li;
  size_t ni;
  uint8_t one[1];
  uint8_t two[2];
  uint8_t longbuf[128];

  memset(longbuf, (int)'x', sizeof(longbuf));

  for (ci = 0; ci < sizeof(k_leftover_namelen) / sizeof(k_leftover_namelen[0]); ci++) {
    if (!leftover_namelen_selected(k_leftover_namelen[ci].name))
      continue;

    for (ni = 0; ni < sizeof(k_null_lens) / sizeof(k_null_lens[0]); ni++) {
      if (check_pair(&k_leftover_namelen[ci], 0, k_null_lens[ni], checks, fail))
        any_fail = 1;
    }

    for (b = 0; b < 256; b++) {
      one[0] = (uint8_t)b;
      if (check_pair(&k_leftover_namelen[ci], one, 1, checks, fail))
        any_fail = 1;
    }

    two[0] = (uint8_t)'a';
    for (b = 0; b < 256; b++) {
      two[1] = (uint8_t)b;
      if (check_pair(&k_leftover_namelen[ci], two, 2, checks, fail))
        any_fail = 1;
    }

    for (ni = 0; ni < sizeof(k_lens) / sizeof(k_lens[0]); ni++) {
      if (check_pair(&k_leftover_namelen[ci], longbuf, k_lens[ni], checks, fail))
        any_fail = 1;
    }

    for (li = 0; li < sizeof(k_lits) / sizeof(k_lits[0]); li++) {
      const uint8_t *p = (const uint8_t *)k_lits[li];
      int32_t n = (int32_t)strlen(k_lits[li]);
      if (check_pair(&k_leftover_namelen[ci], p, n, checks, fail))
        any_fail = 1;
    }
  }
  return any_fail;
}
