/* seeds/pthin_type_ref.from_x.c — G-02f-280 P2 parser thin P3 type_ref
 * Logic source: src/asm/pthin_type_ref.x
 * Hybrid: XLANG_PTHIN_TYPE_REF_FROM_X + ld -r into parser_asm_thin_glue.o
 *
 * Body: seeds/parser_asm/parser_asm_type_ref_slice.inc
 * Types must match parser_asm_thin_c.from_x.c (layout-locked).
 *
 * Hybrid P3b (XLANG_PTHIN_TYPE_REF_BODIES_FROM_X): portable kind / dyn /
 * vector-ident bodies come from pthin_type_ref.x; this TU keeps slice
 * trampolines plus arena parse. Cold: no BODIES define, full .inc.
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser_asm_stretch_audit_gate.h"
#include "token.h"

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

/* Helpers from thin mega rest. */
extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                            struct parser_asm_slice_u8 *data);
extern void parser_lex_from_lexer_result_ptr_into(struct parser_asm_lexer *out,
                                                 struct parser_asm_lexer_result *r);
extern void parser_asm_copy_slice_to_name64_slice_c(struct parser_asm_slice_u8 *source, size_t start,
                                                   int32_t nlen, uint8_t *out);
extern void parser_asm_copy_slice_to_name64_at_end_slice_c(struct parser_asm_slice_u8 *source,
                                                          size_t end_pos, int32_t nlen, uint8_t *out);
extern int32_t parser_asm_is_pointee_type_token_c(int32_t kind);

/* PLATFORM: SHARED — 7.2.1 P3b Route C (2026-09-13).
 * pthin_type_ref.x TOKEN_* are pin copies of this enum.
 * token.h remains the authority; fire if the pin drifts. */
_Static_assert((int)TOKEN_FUNCTION == 1, "type_ref.x TOKEN_FUNCTION pin");
_Static_assert((int)TOKEN_IMPL == 50, "type_ref.x TOKEN_IMPL pin");
_Static_assert((int)TOKEN_IDENT == 59, "type_ref.x TOKEN_IDENT pin");
_Static_assert((int)TOKEN_I32 == 60, "type_ref.x TOKEN_I32 pin");
_Static_assert((int)TOKEN_BOOL == 61, "type_ref.x TOKEN_BOOL pin");
_Static_assert((int)TOKEN_U8 == 62, "type_ref.x TOKEN_U8 pin");
_Static_assert((int)TOKEN_U32 == 63, "type_ref.x TOKEN_U32 pin");
_Static_assert((int)TOKEN_U64 == 64, "type_ref.x TOKEN_U64 pin");
_Static_assert((int)TOKEN_I64 == 65, "type_ref.x TOKEN_I64 pin");
_Static_assert((int)TOKEN_USIZE == 66, "type_ref.x TOKEN_USIZE pin");
_Static_assert((int)TOKEN_ISIZE == 67, "type_ref.x TOKEN_ISIZE pin");
_Static_assert((int)TOKEN_I32X4 == 68, "type_ref.x TOKEN_I32X4 pin");
_Static_assert((int)TOKEN_I32X8 == 69, "type_ref.x TOKEN_I32X8 pin");
_Static_assert((int)TOKEN_I32X16 == 70, "type_ref.x TOKEN_I32X16 pin");
_Static_assert((int)TOKEN_U32X4 == 71, "type_ref.x TOKEN_U32X4 pin");
_Static_assert((int)TOKEN_U32X8 == 72, "type_ref.x TOKEN_U32X8 pin");
_Static_assert((int)TOKEN_U32X16 == 73, "type_ref.x TOKEN_U32X16 pin");
_Static_assert((int)TOKEN_F32X4 == 74, "type_ref.x TOKEN_F32X4 pin");
_Static_assert((int)TOKEN_F32 == 77, "type_ref.x TOKEN_F32 pin");
_Static_assert((int)TOKEN_F64 == 78, "type_ref.x TOKEN_F64 pin");
_Static_assert((int)TOKEN_VOID == 79, "type_ref.x TOKEN_VOID pin");
_Static_assert((int)TOKEN_LBRACKET == 86, "type_ref.x TOKEN_LBRACKET pin");
_Static_assert((int)TOKEN_STAR == 98, "type_ref.x TOKEN_STAR pin");

#ifdef XLANG_PTHIN_TYPE_REF_BODIES_FROM_X
/* .x product bodies (same C names for Route C; buf split for dyn). */
extern int32_t parser_asm_type_ref_token_starts_type_c(int32_t kind);
extern int32_t parser_asm_type_ref_builtin_kind_ord_c(int32_t tok_kind);
extern int32_t parser_asm_type_ref_ident_is_dyn_buf_c(uint8_t *data, size_t length, size_t token_start,
                                                     int32_t ident_len);
extern int32_t parser_asm_vector_type_ident_pack_c(uint8_t *data, size_t length, size_t token_start,
                                                  int32_t ident_len);

static int32_t parser_asm_type_ref_ident_is_dyn_c(struct parser_asm_slice_u8 *source,
                                                  struct parser_asm_lexer_result *r) {
  if (!source || !r)
    return 0;
  if (r->tok.kind != (int32_t)TOKEN_IDENT || r->tok.ident_len != 3)
    return 0;
  return parser_asm_type_ref_ident_is_dyn_buf_c(source->data, source->length, r->token_start, r->tok.ident_len);
}
#endif

/* mega rest 中为 static；本 TU 自备等价实现（layout 一致）。 */
static void parser_asm_lex_from_result_val_into(struct parser_asm_lexer *out,
                                               struct parser_asm_lexer_result r) {
  if (!out)
    return;
  out->pos = r.next_lex.pos;
  out->line = r.next_lex.line;
  out->col = r.next_lex.col;
}

#include "parser_asm_type_ref_slice.inc"

int labi_pthin_type_ref_slice_marker(void) {
  return 1;
}
