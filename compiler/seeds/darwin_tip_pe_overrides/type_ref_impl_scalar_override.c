/**
 * PLATFORM: MACOS|DARWIN arm64 tip PE only — tip_l4_tip_pe_onefunc_impl.
 *
 * Tip PE pure-asm (w1152 pthin_type_ref_darwin_pure) hollow-emits
 * type_ref_impl / scalar / peel, and builtin_vec falsely lex_step_kind
 * even when peek is not a vec token (void→brace). Cap vec peeks
 * elem_ord<0 and returns 0 without stepping. Gate FROM_X is presence
 * only → hollow wins → `: void` fails in parse_one_function_impl →
 * tip_after.o drops `_main` (BLD001). Soft Cap Prefer / Cap aside /
 * Win banned.
 *
 * Tip-local host-cc twins of src/asm/pthin_type_ref.x (scalar + peel +
 * impl + vec). g05_relink_env prepends this .o and weakens the hollow
 * tip symbols in parser_asm_thin_glue.o so the twins win.
 */
#include <stddef.h>
#include <stdint.h>

enum {
  TOKEN_FUNCTION = 1,
  TOKEN_IMPL = 50,
  TOKEN_IDENT = 59,
  TOKEN_LBRACKET = 86,
  TOKEN_STAR = 98
};

extern int32_t parser_asm_lex_peek_kind_c(void *lex_inout, void *source);
extern void parser_asm_lex_step_kind_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_ident_len_c(void *lex_inout, void *source);
extern size_t parser_asm_lex_peek_token_start_c(void *lex_inout, void *source);
extern size_t parser_asm_lex_pos_c(void *lex_inout);
extern int32_t parser_asm_lex_line_c(void *lex_inout);
extern int32_t parser_asm_lex_col_c(void *lex_inout);
extern void parser_asm_lex_set_pos_c(void *lex_inout, size_t pos);
extern void parser_asm_lex_set_line_c(void *lex_inout, int32_t line);
extern void parser_asm_lex_set_col_c(void *lex_inout, int32_t col);
extern int32_t parser_asm_lex_peek_tok_line_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_tok_col_c(void *lex_inout, void *source);
extern uint8_t *parser_asm_lex_source_data_c(void *source);
extern int32_t parser_asm_lex_source_length_c(void *source);

extern int32_t parser_asm_type_ref_builtin_kind_ord_c(int32_t tok_kind);
extern int32_t parser_asm_type_ref_ident_is_dyn_buf_c(uint8_t *data, size_t length,
                                                     size_t token_start, int32_t ident_len);
extern int32_t parser_asm_type_ref_token_starts_type_c(int32_t kind);
extern void parser_report_dyn_prefix_p013_c(int32_t line, int32_t col);
extern int32_t parser_asm_parse_type_ref_ptr_into_c(void *arena, void *lex_inout, void *source);

extern int32_t ast_ast_arena_type_alloc(void *arena);
extern int32_t pipeline_type_init_primitive_kind_at(void *arena, int32_t ref, int32_t ord);

extern int32_t parser_asm_parse_fn_type_x_into_c(void *arena, void *lex_inout, void *source);
extern int32_t parser_asm_parse_star_type_x_into_c(void *arena, void *lex_inout, void *source,
                                                  uint8_t *name_scratch, int32_t *qn_len_slot,
                                                  uint8_t *label_scratch);
extern int32_t parser_asm_parse_prefix_array_x_into_c(void *arena, void *lex_inout, void *source,
                                                     uint8_t *label_scratch);
extern int32_t parser_asm_builtin_vec_token_elem_ord(int32_t kind);
extern int32_t parser_asm_builtin_vec_token_lanes(int32_t kind);
extern int32_t pipeline_type_ensure_by_kind_ord(void *arena, int32_t ord);
extern int32_t pipeline_type_init_compound_kind_at(void *arena, int32_t ref, int32_t kind,
                                                   int32_t elem_tr, int32_t lanes);
extern int32_t parser_asm_parse_postfix_array_x_into_c(void *arena, int32_t type_ref,
                                                      void *lex_inout, void *source,
                                                      uint8_t *label_scratch);
extern int32_t parser_asm_parse_type_ref_impl_ident_x(void *arena, void *lex_inout, void *source,
                                                     uint8_t *name_scratch, int32_t *qn_len_slot,
                                                     uint8_t *label_scratch);

enum { TYPE_VECTOR = 13 };

int32_t parser_asm_parse_builtin_vec_type_x_into_c(void *arena, void *lex_inout, void *source) {
  int32_t kind;
  int32_t elem_ord;
  int32_t lanes;
  int32_t elem_tr;
  int32_t vec_ref;
  int32_t ok;
  if (!arena || !lex_inout || !source)
    return 0;
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  elem_ord = parser_asm_builtin_vec_token_elem_ord(kind);
  /* Cap: non-vec → return 0 with lex unchanged. Hollow tip steps anyway. */
  if (elem_ord < 0)
    return 0;
  lanes = parser_asm_builtin_vec_token_lanes(kind);
  parser_asm_lex_step_kind_c(lex_inout, source);
  elem_tr = pipeline_type_ensure_by_kind_ord(arena, elem_ord);
  if (elem_tr == 0)
    return 0;
  vec_ref = ast_ast_arena_type_alloc(arena);
  if (vec_ref == 0)
    return 0;
  ok = pipeline_type_init_compound_kind_at(arena, vec_ref, TYPE_VECTOR, elem_tr, lanes);
  if (ok == 0)
    return 0;
  return vec_ref;
}

int32_t parser_asm_parse_builtin_scalar_type_x_into_c(void *arena, void *lex_inout, void *source) {
  int32_t kind;
  int32_t ord;
  int32_t type_ref;
  int32_t ok;
  if (!arena || !lex_inout || !source)
    return 0;
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  ord = parser_asm_type_ref_builtin_kind_ord_c(kind);
  if (ord < 0)
    return 0;
  parser_asm_lex_step_kind_c(lex_inout, source);
  type_ref = ast_ast_arena_type_alloc(arena);
  if (type_ref == 0)
    return 0;
  ok = pipeline_type_init_primitive_kind_at(arena, type_ref, ord);
  if (ok == 0)
    return 0;
  return type_ref;
}

int32_t parser_asm_peel_dyn_impl_prefix_x_into_c(void *arena, void *lex_inout, void *source) {
  int32_t kind;
  int32_t kind2;
  int32_t nlen;
  size_t ts;
  int32_t slen;
  uint8_t *data;
  size_t pos0;
  int32_t line0;
  int32_t col0;
  int32_t dyn_line;
  int32_t dyn_col;
  int32_t inner;
  if (!arena || !lex_inout || !source)
    return 0;
  pos0 = parser_asm_lex_pos_c(lex_inout);
  line0 = parser_asm_lex_line_c(lex_inout);
  col0 = parser_asm_lex_col_c(lex_inout);
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind == TOKEN_IDENT) {
    nlen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
    data = parser_asm_lex_source_data_c(source);
    slen = parser_asm_lex_source_length_c(source);
    if (parser_asm_type_ref_ident_is_dyn_buf_c(data, (size_t)slen, ts, nlen) != 0) {
      dyn_line = parser_asm_lex_peek_tok_line_c(lex_inout, source);
      dyn_col = parser_asm_lex_peek_tok_col_c(lex_inout, source);
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind2 = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (parser_asm_type_ref_token_starts_type_c(kind2) != 0) {
        parser_report_dyn_prefix_p013_c(dyn_line, dyn_col);
        return 0;
      }
      parser_asm_lex_set_pos_c(lex_inout, pos0);
      parser_asm_lex_set_line_c(lex_inout, line0);
      parser_asm_lex_set_col_c(lex_inout, col0);
      return 0;
    }
  } else if (kind == TOKEN_IMPL) {
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind2 = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (parser_asm_type_ref_token_starts_type_c(kind2) != 0) {
      inner = parser_asm_parse_type_ref_ptr_into_c(arena, lex_inout, source);
      return inner;
    }
    parser_asm_lex_set_pos_c(lex_inout, pos0);
    parser_asm_lex_set_line_c(lex_inout, line0);
    parser_asm_lex_set_col_c(lex_inout, col0);
    return 0;
  }
  return 0;
}

int32_t parser_asm_parse_type_ref_impl_x_into_c(void *arena, void *lex_inout, void *source,
                                               uint8_t *name_scratch, int32_t *qn_len_slot,
                                               uint8_t *label_scratch) {
  int32_t peeled;
  int32_t kind;
  size_t pos0;
  int32_t line0;
  int32_t col0;
  int32_t type_ref;
  if (!arena || !lex_inout || !source)
    return 0;
  if (!name_scratch || !qn_len_slot || !label_scratch)
    return 0;
  pos0 = parser_asm_lex_pos_c(lex_inout);
  line0 = parser_asm_lex_line_c(lex_inout);
  col0 = parser_asm_lex_col_c(lex_inout);
  peeled = parser_asm_peel_dyn_impl_prefix_x_into_c(arena, lex_inout, source);
  if (peeled != 0)
    return peeled;
  if (parser_asm_lex_pos_c(lex_inout) != pos0)
    return 0;
  if (parser_asm_lex_line_c(lex_inout) != line0)
    return 0;
  if (parser_asm_lex_col_c(lex_inout) != col0)
    return 0;
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind == TOKEN_FUNCTION)
    return parser_asm_parse_fn_type_x_into_c(arena, lex_inout, source);
  if (kind == TOKEN_STAR)
    return parser_asm_parse_star_type_x_into_c(arena, lex_inout, source, name_scratch, qn_len_slot,
                                              label_scratch);
  if (kind == TOKEN_LBRACKET)
    return parser_asm_parse_prefix_array_x_into_c(arena, lex_inout, source, label_scratch);
  type_ref = parser_asm_parse_builtin_vec_type_x_into_c(arena, lex_inout, source);
  if (type_ref != 0)
    return type_ref;
  type_ref = parser_asm_parse_builtin_scalar_type_x_into_c(arena, lex_inout, source);
  if (type_ref != 0)
    return parser_asm_parse_postfix_array_x_into_c(arena, type_ref, lex_inout, source, label_scratch);
  if (kind == TOKEN_IDENT)
    return parser_asm_parse_type_ref_impl_ident_x(arena, lex_inout, source, name_scratch, qn_len_slot,
                                                 label_scratch);
  return 0;
}
