/* seeds/pthin_body_tl.from_x.c — G-02f-327 P2 parser thin body_tl
 * Logic source: src/asm/pthin_body_tl.x
 * Hybrid: XLANG_PTHIN_BODY_TL_FROM_X + ld -r into parser_asm_thin_glue.o
 *
 * Body: seeds/parser_asm/parser_asm_body_tl_slice.inc (~971)
 * is_fn_sig_scalar + diag_first_ident + diag_skip_let_const_into + body_skip_into
 * + skip_one_top_level_{let,const} + cfg_skip_pending_top_level
 *
 * Hybrid P18b/P18c (XLANG_PTHIN_BODY_TL_BODIES_FROM_X): portable skip
 * walks, the scalar TOKEN table, cfg_skip, and diag_first_ident come
 * from pthin_body_tl.x; this TU keeps by-value trampolines plus
 * P010–P014 / onefunc_param_name_dup C. Language has no lexer_init /
 * struct-by-value; the diag_first_ident trampoline inits the lexer.
 * Cold: no BODIES define, full .inc.
 * Do not reuse XLANG_PTHIN_BODY_TL_FROM_X for P18b/P18c bodies.
 * PLATFORM: SHARED — do not assemble parser.x.
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser_asm_stretch_audit_gate.h"
#include "token.h"

/* PLATFORM: SHARED — 7.2.1 P18b/P18c Route C + B-minus (2026-09-13).
 * pthin_body_tl.x TOKEN_* are pin copies of this enum.
 * token.h remains the authority; fire if the pin drifts. */
_Static_assert((int)TOKEN_EOF == 0, "body_tl.x TOKEN_EOF pin");
_Static_assert((int)TOKEN_FUNCTION == 1, "body_tl.x TOKEN_FUNCTION pin");
_Static_assert((int)TOKEN_LET == 2, "body_tl.x TOKEN_LET pin");
_Static_assert((int)TOKEN_CONST == 3, "body_tl.x TOKEN_CONST pin");
_Static_assert((int)TOKEN_IF == 4, "body_tl.x TOKEN_IF pin");
_Static_assert((int)TOKEN_STRUCT == 19, "body_tl.x TOKEN_STRUCT pin");
_Static_assert((int)TOKEN_EXTERN == 54, "body_tl.x TOKEN_EXTERN pin");
_Static_assert((int)TOKEN_ASYNC == 55, "body_tl.x TOKEN_ASYNC pin");
_Static_assert((int)TOKEN_IDENT == 59, "body_tl.x TOKEN_IDENT pin");
_Static_assert((int)TOKEN_I32 == 60, "body_tl.x TOKEN_I32 pin");
_Static_assert((int)TOKEN_BOOL == 61, "body_tl.x TOKEN_BOOL pin");
_Static_assert((int)TOKEN_U8 == 62, "body_tl.x TOKEN_U8 pin");
_Static_assert((int)TOKEN_U32 == 63, "body_tl.x TOKEN_U32 pin");
_Static_assert((int)TOKEN_U64 == 64, "body_tl.x TOKEN_U64 pin");
_Static_assert((int)TOKEN_I64 == 65, "body_tl.x TOKEN_I64 pin");
_Static_assert((int)TOKEN_USIZE == 66, "body_tl.x TOKEN_USIZE pin");
_Static_assert((int)TOKEN_VOID == 79, "body_tl.x TOKEN_VOID pin");
_Static_assert((int)TOKEN_LBRACKET == 86, "body_tl.x TOKEN_LBRACKET pin");
_Static_assert((int)TOKEN_RBRACKET == 87, "body_tl.x TOKEN_RBRACKET pin");
_Static_assert((int)TOKEN_COLON == 91, "body_tl.x TOKEN_COLON pin");
_Static_assert((int)TOKEN_SEMICOLON == 95, "body_tl.x TOKEN_SEMICOLON pin");
_Static_assert((int)TOKEN_STAR == 98, "body_tl.x TOKEN_STAR pin");
_Static_assert((int)TOKEN_ASSIGN == 117, "body_tl.x TOKEN_ASSIGN pin");
_Static_assert((int)TOKEN_STRING == 130, "body_tl.x TOKEN_STRING pin");

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

extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                            struct parser_asm_slice_u8 *data);
extern void parser_asm_lex_from_result_val_into(struct parser_asm_lexer *out, struct parser_asm_lexer_result r);
extern struct parser_asm_lexer parser_asm_lexer_init_c(void);
extern void parser_lex_from_lexer_result_ptr_into(struct parser_asm_lexer *out, struct parser_asm_lexer_result *r);
extern void parser_asm_skip_one_if_statement_into_slice_c(struct parser_asm_lexer_result *out,
                                                          struct parser_asm_lexer lex,
                                                          struct parser_asm_slice_u8 *source);
extern void parser_asm_skip_one_struct_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                                     struct parser_asm_slice_u8 *source);
extern void parser_asm_skip_one_function_full_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                                            struct parser_asm_slice_u8 *source);

#ifdef XLANG_PTHIN_BODY_TL_BODIES_FROM_X
/* .x product bodies (pointer ABI). C names stay on the trampolines.
 * is_fn_sig_scalar keeps the same C name (Route C, no trampoline). */
extern int32_t parser_asm_diag_skip_let_const_into_c(void *lex_inout, void *source);
extern int32_t parser_asm_body_skip_let_const_then_if_into_c(void *lex_inout, void *source);
extern int32_t parser_asm_skip_one_top_level_let_into_c(void *lex_inout, void *source);
extern int32_t parser_asm_skip_one_top_level_const_into_c(void *lex_inout, void *source);
extern int32_t parser_asm_cfg_skip_pending_top_level_into_c(void *lex_inout, void *source, int32_t *pending);
extern int32_t parser_asm_diag_first_ident_len_into_c(void *lex_inout, void *source);

void parser_asm_diag_skip_let_const_into_slice_c(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                                                 struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer cur;
  if (!out || !source)
    return;
  cur = lex;
  (void)parser_asm_diag_skip_let_const_into_c(&cur, source);
  lexer_next_into(out, cur, source);
}

void parser_asm_body_skip_let_const_then_if_into_slice_c(struct parser_asm_lexer_result *out,
                                                         struct parser_asm_lexer lex,
                                                         struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer cur;
  if (!out || !source)
    return;
  cur = lex;
  (void)parser_asm_body_skip_let_const_then_if_into_c(&cur, source);
  lexer_next_into(out, cur, source);
}

void parser_asm_skip_one_top_level_let_into_slice_c(struct parser_asm_lexer *out,
                                                    struct parser_asm_lexer lex,
                                                    struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer cur;
  if (!out || !source) {
    if (out)
      *out = lex;
    return;
  }
  cur = lex;
  (void)parser_asm_skip_one_top_level_let_into_c(&cur, source);
  *out = cur;
}

void parser_asm_skip_one_top_level_const_into_slice_c(struct parser_asm_lexer *out,
                                                      struct parser_asm_lexer lex,
                                                      struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer cur;
  if (!out || !source) {
    if (out)
      *out = lex;
    return;
  }
  cur = lex;
  (void)parser_asm_skip_one_top_level_const_into_c(&cur, source);
  *out = cur;
}

void parser_asm_cfg_skip_pending_top_level_into_slice_c(struct parser_asm_lexer *lex,
                                                                struct parser_asm_slice_u8 *source,
                                                                int32_t *pending) {
  if (!lex || !source || !pending || !*pending)
    return;
  (void)parser_asm_cfg_skip_pending_top_level_into_c(lex, source, pending);
}

int32_t parser_asm_diag_first_ident_len_slice_c(struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer lex;
  if (!source)
    return -2;
  lex = parser_asm_lexer_init_c();
  return parser_asm_diag_first_ident_len_into_c(&lex, source);
}
#endif /* XLANG_PTHIN_BODY_TL_BODIES_FROM_X */

#include "parser_asm_body_tl_slice.inc"

int labi_pthin_body_tl_slice_marker(void) {
  return 1;
}
