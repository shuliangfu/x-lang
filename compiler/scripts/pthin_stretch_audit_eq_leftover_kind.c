/* leftover_kind eq battery — 7.2.1b v5.50
 *
 * leftover_helpers whose first param is a token-kind scalar are already
 * .x T in pthin_stretch_audit.x, but they have no k_cases row: the
 * generator only tables lex:/lex_inout: audits. twins.h also keeps
 * static C copies under the product names so c_ref twins keep C
 * authority — those statics shadow the .x T in the harness TU.
 *
 * This TU does NOT include twins.h. It links audit_x.o (product .x)
 * and compares against inline copies of the gated C twins (same
 * bodies as suite leftover helpers under FROM_X). Kind space is
 * exhaustive (not a file-offset walk): every TokenKind plus a few
 * out-of-range values.
 *
 * classify / import_path_score stay stretch.x (G.7; not leftover-to-audit).
 * PLATFORM: SHARED — compiled into the existing eq harness.
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "token.h"

extern int32_t parser_asm_stretch_is_type_start_kind_c(int32_t kind);
extern int32_t parser_asm_stretch_enum_discriminant_kind_audit_c(int32_t kind);
extern int32_t parser_asm_stretch_const_import_kw_audit_c(int32_t after_assign_kind);
extern int32_t parser_asm_stretch_builtin_vec_token_audit_c(int32_t kind);
extern int32_t parser_asm_stretch_spawn_kw_audit_c(int32_t after_function_kind);
extern int32_t parser_asm_stretch_import_select_brace_head_audit_c(int32_t kind);

/* Gated C twin bodies (suite leftover helpers). Static names do not
 * collide with the .x T symbols resolved from audit_x.o. */
static int32_t c_ref_is_type_start_kind(int32_t kind) {
  if (kind == (int32_t)TOKEN_I32 || kind == (int32_t)TOKEN_I64 || kind == (int32_t)TOKEN_BOOL ||
      kind == (int32_t)TOKEN_U8 || kind == (int32_t)TOKEN_U32 || kind == (int32_t)TOKEN_U64 ||
      kind == (int32_t)TOKEN_USIZE || kind == (int32_t)TOKEN_VOID || kind == (int32_t)TOKEN_IDENT)
    return 1;
  return 0;
}

static int32_t c_ref_enum_discriminant_kind(int32_t kind) {
  return kind == (int32_t)TOKEN_I32 || kind == (int32_t)TOKEN_I64 || kind == (int32_t)TOKEN_INT ? 1
                                                                                              : 0;
}

static int32_t c_ref_const_import_kw(int32_t after_assign_kind) {
  return after_assign_kind == (int32_t)TOKEN_IMPORT ? 1 : 0;
}

static int32_t c_ref_builtin_vec_token(int32_t kind) {
  return kind == (int32_t)TOKEN_I32X4 || kind == (int32_t)TOKEN_I32X8 ||
                 kind == (int32_t)TOKEN_I32X16 || kind == (int32_t)TOKEN_U32X4 ||
                 kind == (int32_t)TOKEN_U32X8 || kind == (int32_t)TOKEN_U32X16 ||
                 kind == (int32_t)TOKEN_F32X4
             ? 1
             : 0;
}

static int32_t c_ref_spawn_kw(int32_t after_function_kind) {
  return after_function_kind == (int32_t)TOKEN_SPAWN ? 1 : 0;
}

static int32_t c_ref_import_select_brace_head(int32_t kind) {
  return kind == (int32_t)TOKEN_LBRACE ? 1 : 0;
}

typedef int32_t (*kind_fn)(int32_t kind);

typedef struct {
  const char *name;
  kind_fn x_ver;
  kind_fn c_ref;
} leftover_kind_case;

static const leftover_kind_case k_leftover_kind[] = {
    {"is_type_start_kind", parser_asm_stretch_is_type_start_kind_c, c_ref_is_type_start_kind},
    {"enum_discriminant_kind", parser_asm_stretch_enum_discriminant_kind_audit_c,
     c_ref_enum_discriminant_kind},
    {"const_import_kw", parser_asm_stretch_const_import_kw_audit_c, c_ref_const_import_kw},
    {"builtin_vec_token", parser_asm_stretch_builtin_vec_token_audit_c, c_ref_builtin_vec_token},
    {"spawn_kw", parser_asm_stretch_spawn_kw_audit_c, c_ref_spawn_kw},
    {"import_select_brace_head", parser_asm_stretch_import_select_brace_head_audit_c,
     c_ref_import_select_brace_head},
};

static int leftover_kind_selected(const char *name) {
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

/**
 * Exhaustive leftover_kind eq. Caller owns checks/fail counters.
 * @param checks long* — incremented per (case, kind) pair; null ignored
 * @param fail int* — incremented on mismatch; null ignored
 * @return int — 0 ok; 1 if any mismatch
 * PLATFORM: SHARED.
 */
int leftover_kind_eq_run(long *checks, int *fail) {
  static const int32_t k_extra[] = {-1, -2, 256, 512, 1024, 0x7fffffff};
  size_t ci;
  int any_fail = 0;
  int32_t kind;
  size_t ei;
  int32_t last = (int32_t)TOKEN_NULL;

  for (ci = 0; ci < sizeof(k_leftover_kind) / sizeof(k_leftover_kind[0]); ci++) {
    if (!leftover_kind_selected(k_leftover_kind[ci].name))
      continue;
    for (kind = 0; kind <= last + 8; kind++) {
      int32_t xv = k_leftover_kind[ci].x_ver(kind);
      int32_t cv = k_leftover_kind[ci].c_ref(kind);
      if (checks)
        (*checks)++;
      if (xv != cv) {
        printf("FAIL leftover_kind %s kind=%d .x=%d c=%d\n", k_leftover_kind[ci].name, (int)kind,
               (int)xv, (int)cv);
        if (fail)
          (*fail)++;
        any_fail = 1;
      }
    }
    for (ei = 0; ei < sizeof(k_extra) / sizeof(k_extra[0]); ei++) {
      int32_t xv = k_leftover_kind[ci].x_ver(k_extra[ei]);
      int32_t cv = k_leftover_kind[ci].c_ref(k_extra[ei]);
      if (checks)
        (*checks)++;
      if (xv != cv) {
        printf("FAIL leftover_kind %s kind=%d .x=%d c=%d\n", k_leftover_kind[ci].name,
               (int)k_extra[ei], (int)xv, (int)cv);
        if (fail)
          (*fail)++;
        any_fail = 1;
      }
    }
  }
  return any_fail;
}
