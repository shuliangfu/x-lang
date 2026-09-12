/* seeds/pthin_diag_late.from_x.c — G-02f-326 P2 parser thin diag_late
 * Logic source: src/asm/pthin_diag_late.x
 * Hybrid: XLANG_PTHIN_DIAG_LATE_FROM_X + ld -r into parser_asm_thin_glue.o
 *
 * Body: seeds/parser_asm/parser_asm_diag_late_slice.inc (~269)
 * diag_after_imports_then_structs + diag_fail_at_token_kind + diag_skip_let_const_buf + body_skip_buf
 *
 * Hybrid P17b (XLANG_PTHIN_DIAG_LATE_BODIES_FROM_X): portable after_structs
 * + fail_at_token_kind walks come from pthin_diag_late.x; this TU keeps
 * the by-value trampolines plus buf skip. Cold: no BODIES define, full
 * .inc. Do not reuse XLANG_PTHIN_DIAG_LATE_FROM_X for P17b bodies.
 * PLATFORM: SHARED — do not assemble parser.x.
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser_asm_stretch_audit_gate.h"
#include "token.h"

/* PLATFORM: SHARED — 7.2.1 P17b B-minus (2026-09-13).
 * pthin_diag_late.x TOKEN_* are pin copies of this enum.
 * token.h remains the authority; fire if the pin drifts. */
_Static_assert((int)TOKEN_EOF == 0, "diag_late.x TOKEN_EOF pin");
_Static_assert((int)TOKEN_FUNCTION == 1, "diag_late.x TOKEN_FUNCTION pin");
_Static_assert((int)TOKEN_RETURN == 11, "diag_late.x TOKEN_RETURN pin");
_Static_assert((int)TOKEN_STRUCT == 19, "diag_late.x TOKEN_STRUCT pin");
_Static_assert((int)TOKEN_IDENT == 59, "diag_late.x TOKEN_IDENT pin");
_Static_assert((int)TOKEN_U8 == 62, "diag_late.x TOKEN_U8 pin");
_Static_assert((int)TOKEN_INT == 80, "diag_late.x TOKEN_INT pin");
_Static_assert((int)TOKEN_LPAREN == 82, "diag_late.x TOKEN_LPAREN pin");
_Static_assert((int)TOKEN_RPAREN == 83, "diag_late.x TOKEN_RPAREN pin");
_Static_assert((int)TOKEN_LBRACE == 84, "diag_late.x TOKEN_LBRACE pin");
_Static_assert((int)TOKEN_RBRACE == 85, "diag_late.x TOKEN_RBRACE pin");
_Static_assert((int)TOKEN_LBRACKET == 86, "diag_late.x TOKEN_LBRACKET pin");
_Static_assert((int)TOKEN_RBRACKET == 87, "diag_late.x TOKEN_RBRACKET pin");
_Static_assert((int)TOKEN_COMMA == 90, "diag_late.x TOKEN_COMMA pin");
_Static_assert((int)TOKEN_COLON == 91, "diag_late.x TOKEN_COLON pin");
_Static_assert((int)TOKEN_SEMICOLON == 95, "diag_late.x TOKEN_SEMICOLON pin");
_Static_assert((int)TOKEN_STAR == 98, "diag_late.x TOKEN_STAR pin");

struct parser_asm_token {
  int32_t kind;
  int32_t line;
  int32_t col;
  int64_t int_val;
  double float_val;
  uint8_t *ident;
  int32_t ident_len;
};

struct parser_asm_lexer {
  size_t pos;
  int32_t line;
  int32_t col;
};

struct parser_asm_lexer_result {
  struct parser_asm_lexer next_lex;
  struct parser_asm_token tok;
  size_t token_start;
};

struct parser_asm_slice_u8 {
  uint8_t *data;
  size_t length;
};




extern struct parser_asm_lexer_result lexer_next_buf(struct parser_asm_lexer lex, uint8_t *data, int32_t len);
extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *data);
extern void parser_asm_body_skip_let_const_then_if_into_slice_c(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source);
extern struct parser_asm_lexer parser_asm_diag_lex_after_imports_slice_c(struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_is_fn_sig_scalar_type_token_c(int32_t kind);
extern int32_t parser_asm_is_pointee_type_token_c(int32_t kind);
extern void parser_asm_lex_from_result_val_into(struct parser_asm_lexer *out, struct parser_asm_lexer_result r);
extern struct parser_asm_lexer parser_asm_lexer_init_c(void);
extern struct parser_asm_lexer parser_asm_skip_one_struct_slice_c(struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_array_type_bracket_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_bind_name_validate_c(const uint8_t *name, int32_t len);
extern int32_t parser_asm_stretch_diag_after_imports_structs_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_after_imports_then_structs_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_fail_at_token_kind_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_fn_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_diag_fn_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_fn_header_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_diag_fn_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_diag_fn_param_sig_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_diag_fn_return_type_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_diag_skip_let_const_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_skip_let_const_type_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_skip_let_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_toplevel_after_imports_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_fields_body_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_header_audit_c(void *lex_inout, void *source);

#ifdef XLANG_PTHIN_DIAG_LATE_BODIES_FROM_X
/* .x product bodies (pointer ABI). C names stay on the trampolines. */
extern int32_t parser_asm_diag_after_imports_then_structs_into_c(void *lex_inout, void *source);
extern int32_t parser_asm_diag_fail_at_token_kind_from_lex_c(void *lex_inout, void *source);

struct parser_asm_lexer_result parser_asm_diag_after_imports_then_structs_slice_c(
    struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer_result r;
  struct parser_asm_lexer cur;
  if (!source) {
    memset(&r, 0, sizeof(r));
    r.next_lex = lex;
    r.tok.kind = (int32_t)TOKEN_EOF;
    return r;
  }
  cur = lex;
  parser_asm_diag_after_imports_then_structs_into_c(&cur, source);
  lexer_next_into(&r, cur, source);
  return r;
}

int32_t parser_asm_diag_fail_at_token_kind_slice_c(struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer lex;
  struct parser_asm_lexer cur;
  if (!source)
    return (int32_t)TOKEN_EOF;
  lex = parser_asm_diag_lex_after_imports_slice_c(source);
  cur = lex;
  return parser_asm_diag_fail_at_token_kind_from_lex_c(&cur, source);
}
#endif /* XLANG_PTHIN_DIAG_LATE_BODIES_FROM_X */

#include "parser_asm_diag_late_slice.inc"

int labi_pthin_diag_late_slice_marker(void) {
  return 1;
}
