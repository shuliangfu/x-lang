/* seeds/pthin_helpers.from_x.c — G-02f-328 P2 parser thin helpers
 * Logic source: src/asm/pthin_helpers.x
 * Hybrid: XLANG_PTHIN_HELPERS_FROM_X + ld -r into parser_asm_thin_glue.o
 *
 * Body: seeds/parser_asm/parser_asm_helpers_slice.inc
 * Hybrid P19b (XLANG_PTHIN_HELPERS_BODIES_FROM_X): portable kind/copy/pos/
 * match-kw bodies come from pthin_helpers.x; this TU keeps by-value
 * trampolines plus rewind/align. P1d ASI advance_past_* and P1e
 * parse_peek_function_name / first_token_kind trampoline when
 * XLANG_PTHIN_LEX_SKIP_BODIES_FROM_X (g05 passes P1 extra onto this TU;
 * do not add P9a as a hard gate to P19). Cold: no BODIES define, full .inc.
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

extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                            struct parser_asm_slice_u8 *data);
extern struct parser_asm_lexer_result lexer_next_buf(struct parser_asm_lexer lex, uint8_t *data, int32_t len);
extern void parser_asm_lex_from_result_val_into(struct parser_asm_lexer *out, struct parser_asm_lexer_result r);
extern struct parser_asm_lexer parser_asm_lexer_init_c(void);
extern void parser_asm_copy_slice_to_name64_buf_c(uint8_t *source, int32_t source_len, size_t start, int32_t nlen,
                                                  uint8_t *out);
extern void parser_asm_copy_slice_to_name64_at_end_slice_c(struct parser_asm_slice_u8 *source, size_t end_pos,
                                                            int32_t nlen, uint8_t *out);
extern int32_t parser_asm_stretch_token_run_len_c(int32_t kind);
extern size_t parser_asm_stretch_skip_ws_and_comments_c(const uint8_t *data, size_t len, size_t pos);
extern int32_t parser_asm_stretch_struct_field_name_kind_c(int32_t kind);
extern int32_t parser_asm_stretch_struct_field_continues_kind_c(int32_t kind);
extern int32_t parser_asm_stretch_token_is_label_start_c(int32_t cur_kind, int32_t next_kind);

/* PLATFORM: SHARED — 7.2.1 P19b Route C (2026-09-12).
 * pthin_helpers.x TOKEN_* are pin copies of this enum.
 * token.h remains the authority; fire if the pin drifts. */
_Static_assert((int)TOKEN_LET == 2, "helpers.x TOKEN_LET pin");
_Static_assert((int)TOKEN_CONST == 3, "helpers.x TOKEN_CONST pin");
_Static_assert((int)TOKEN_TYPE == 20, "helpers.x TOKEN_TYPE pin");
_Static_assert((int)TOKEN_PACKED == 21, "helpers.x TOKEN_PACKED pin");
_Static_assert((int)TOKEN_SOA == 22, "helpers.x TOKEN_SOA pin");
_Static_assert((int)TOKEN_ALIGN == 46, "helpers.x TOKEN_ALIGN pin");
_Static_assert((int)TOKEN_ASYNC == 55, "helpers.x TOKEN_ASYNC pin");
_Static_assert((int)TOKEN_IDENT == 59, "helpers.x TOKEN_IDENT pin");
_Static_assert((int)TOKEN_I32 == 60, "helpers.x TOKEN_I32 pin");

#ifdef XLANG_PTHIN_HELPERS_BODIES_FROM_X
/* .x product bodies (same C names for Route C; kind/buf split for by-value). */
extern int32_t parser_asm_import_path_dot_segment_len_kind_c(int32_t kind, int32_t ident_len);
extern void parser_asm_import_path_dot_segment_copy_buf_c(uint8_t *data, size_t length, size_t token_start,
                                                          int32_t seg_len, uint8_t *path_buf, int32_t path_len);
extern int32_t parser_asm_parser_match_kw_immediately_before_buf_c(uint8_t *data, size_t length, size_t ident_start);

int32_t parser_asm_import_path_dot_segment_len_c(struct parser_asm_token tok) {
  return parser_asm_import_path_dot_segment_len_kind_c(tok.kind, tok.ident_len);
}

void parser_asm_import_path_dot_segment_copy_slice_c(struct parser_asm_slice_u8 *source, size_t token_start,
                                                     int32_t seg_len, uint8_t *path_buf, int32_t path_len) {
  parser_asm_import_path_dot_segment_copy_buf_c(source ? source->data : (uint8_t *)0,
                                                source ? source->length : (size_t)0, token_start, seg_len,
                                                path_buf, path_len);
}

int32_t parser_asm_parser_match_kw_immediately_before_slice_c(struct parser_asm_slice_u8 *source,
                                                              size_t ident_start) {
  if (!source || !source->data)
    return 0;
  return parser_asm_parser_match_kw_immediately_before_buf_c(source->data, source->length, ident_start);
}
#else
/* slice 内 glue 先于实现定义调用 */
void parser_asm_import_path_dot_segment_copy_slice_c(struct parser_asm_slice_u8 *source, size_t token_start,
                                                     int32_t seg_len, uint8_t *path_buf, int32_t path_len);
#endif

int32_t parser_asm_parser_token_is_label_start_slice_c(struct parser_asm_lexer_result r,
                                                        struct parser_asm_slice_u8 *source);

#include "parser_asm_helpers_slice.inc"

int labi_pthin_helpers_slice_marker(void) {
  return 1;
}
