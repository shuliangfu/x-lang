/**
 * PLATFORM: WINDOWS tip PE only — knife 11.63.
 *
 * Tip Prefer peel left __stale_parser_asm_parse_postfix_slice_x_into_c
 * as e9 → pipeline_type_init_slice_c (WRONG arity/semantics). Soft Cap
 * Prefer has live parser_asm_parse_postfix_slice_x_into_c; tip has only
 * an 8-byte miswired thunk. Soft Cap byte mix banned.
 *
 * Callers: live tip postfix_array (T[] / T[]<label> arm) @ e8→0x1405c7b08.
 * Tip-local C twin of pthin_type_ref.x
 * parser_asm_parse_postfix_slice_x_into_c. Calls tip PE symbols only.
 */
#include <stdint.h>
#include <stddef.h>

enum {
  TOKEN_IDENT = 59,
  TOKEN_RBRACKET = 87,
  TOKEN_LT = 120,
  TOKEN_GT = 121
};

extern int32_t parser_asm_lex_peek_kind_c(void *lex_inout, void *source);
extern void parser_asm_lex_step_kind_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_ident_len_c(void *lex_inout, void *source);
extern size_t parser_asm_lex_peek_token_start_c(void *lex_inout, void *source);
extern uint8_t *parser_asm_lex_source_data_c(void *source);
extern int32_t parser_asm_lex_source_length_c(void *source);
extern void parser_asm_copy_slice_to_name64_buf_c(uint8_t *data, int32_t slen, size_t ts,
                                                 int32_t nlen, uint8_t *out);
extern int32_t ast_ast_arena_type_alloc(void *arena);
extern void pipeline_type_init_slice_c(void *arena, int32_t slice_ref, int32_t elem_tr,
                                      uint8_t *label, int32_t nlen);

/* Win64: rcx=arena rdx=elem_tr r8=lex r9=source [rsp+0x28]=label_scratch */
int32_t parser_asm_parse_postfix_slice_x_into_c(void *arena, int32_t elem_tr, void *lex_inout,
                                               void *source, uint8_t *label_scratch) {
  int32_t kind;
  int32_t nlen;
  int32_t slice_ref;
  uint8_t *data;
  int32_t slen;
  size_t ts;
  if (!arena || !lex_inout || !source || elem_tr == 0)
    return 0;
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_RBRACKET)
    return 0;
  parser_asm_lex_step_kind_c(lex_inout, source);
  slice_ref = ast_ast_arena_type_alloc(arena);
  if (slice_ref == 0)
    return 0;
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind == TOKEN_LT) {
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    nlen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    if (kind != TOKEN_IDENT || nlen <= 0 || nlen > 255 || !label_scratch)
      return 0;
    ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
    parser_asm_lex_step_kind_c(lex_inout, source);
    data = parser_asm_lex_source_data_c(source);
    slen = parser_asm_lex_source_length_c(source);
    if (!data)
      return 0;
    parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, nlen, label_scratch);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_GT)
      return 0;
    parser_asm_lex_step_kind_c(lex_inout, source);
    pipeline_type_init_slice_c(arena, slice_ref, elem_tr, label_scratch, nlen);
    return slice_ref;
  }
  pipeline_type_init_slice_c(arena, slice_ref, elem_tr, 0, 0);
  return slice_ref;
}
