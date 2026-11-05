/**
 * PLATFORM: MACOS|DARWIN arm64 tip PE only —
 * tip_l4_tip_pe_println_method_call_p001 (follow-on after unary twin).
 *
 * Residual: tip primary+string twins live; tip
 * parser_asm_string_lit_decode_span_x_into_c hollow (1 bl vs Cap 7) →
 * decode -1 → string out_ok=0 → P001 on string/hello. Soft Cap/Prefer/
 * Cap aside/Win banned.
 *
 * Tip-local host-cc twins: decode_span_x_into + string + primary dispatcher.
 */
#include <stddef.h>
#include <stdint.h>

enum {
  TOKEN_IF = 4,
  TOKEN_MATCH = 18,
  TOKEN_AT = 129,
  TOKEN_STRING = 130,
  EXPR_STRING_LIT = 59
};

extern int32_t parser_asm_lex_peek_kind_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_step_kind_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_tok_line_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_tok_col_c(void *lex_inout, void *source);
extern size_t parser_asm_lex_peek_token_start_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_ident_len_c(void *lex_inout, void *source);

extern int32_t ast_ast_arena_expr_alloc(void *arena);
extern void pipeline_expr_set_kind(void *arena, int32_t er, int32_t kind);
extern void pipeline_expr_set_line_col(void *arena, int32_t er, int32_t line,
                                      int32_t col);
extern void pipeline_expr_set_common_zeros_c(void *arena, int32_t er);
extern uint8_t *parser_asm_lex_source_data_c(void *source);
extern size_t parser_asm_lex_source_length_c(void *source);
extern uint8_t parser_asm_primary_ident_byte(uint8_t *data, size_t token_start,
                                            int32_t i);
extern int32_t parser_asm_string_lit_append_byte_ptr_c(void *arena,
                                                      int32_t head_ref,
                                                      int32_t b, int32_t line,
                                                      int32_t col);

extern int32_t parser_asm_string_lit_decode_span_ptr_c(void *arena, int32_t ref,
                                                      void *source, size_t q0,
                                                      int32_t nlen, int32_t tl,
                                                      int32_t tc);

extern int32_t parser_parse_at_simd_builtin_ptr_into_c(void *arena,
                                                      void *lex_inout,
                                                      void *source,
                                                      int32_t *out_ok,
                                                      int32_t *out_expr_ref);
extern int32_t parser_asm_primary_literal_x_into_c(
    void *arena, void *lex_inout, void *source, int32_t *out_ok,
    int32_t *out_expr_ref, int32_t *mc_arg_buf, int32_t *arg_buf,
    int32_t *parsed_refs, int32_t *pending_refs, uint8_t *mangled,
    uint8_t *name_buf);
extern int32_t parser_asm_primary_break_continue_x_into_c(void *arena,
                                                         void *lex_inout,
                                                         void *source,
                                                         int32_t *out_ok,
                                                         int32_t *out_expr_ref);
extern int32_t parser_asm_primary_return_x_into_c(void *arena, void *lex_inout,
                                                 void *source, int32_t *out_ok,
                                                 int32_t *out_expr_ref);
extern int32_t parser_parse_match_ptr_into_c(void *arena, void *lex_inout,
                                            void *source, int32_t *out_ok,
                                            int32_t *out_expr_ref);
extern int32_t parser_asm_primary_panic_x_into_c(void *arena, void *lex_inout,
                                                void *source, int32_t *out_ok,
                                                int32_t *out_expr_ref);
extern int32_t parser_asm_primary_ident_x_into_c(
    void *arena, void *lex_inout, void *source, int32_t *out_ok,
    int32_t *out_expr_ref, int32_t *mc_arg_buf, int32_t *arg_buf,
    int32_t *parsed_refs, int32_t *pending_refs, uint8_t *mangled,
    uint8_t *name_buf);
extern int32_t parser_asm_primary_paren_x_into_c(
    void *arena, void *lex_inout, void *source, int32_t *out_ok,
    int32_t *out_expr_ref, int32_t *mc_arg_buf, int32_t *arg_buf,
    int32_t *parsed_refs, int32_t *pending_refs, uint8_t *mangled,
    uint8_t *name_buf);
extern int32_t parser_asm_primary_array_x_into_c(
    void *arena, void *lex_inout, void *source, int32_t *out_ok,
    int32_t *out_expr_ref, int32_t *mc_arg_buf, int32_t *arg_buf,
    int32_t *parsed_refs, int32_t *pending_refs, uint8_t *mangled,
    uint8_t *name_buf);
extern int32_t parser_asm_parse_if_expr_x_into_c(void *arena, void *lex_inout,
                                                void *source, int32_t type_ref,
                                                int32_t *out_ok,
                                                int32_t *out_expr_ref);
extern int32_t parser_asm_primary_lbrace_x_into_c(
    void *arena, void *lex_inout, void *source, int32_t *out_ok,
    int32_t *out_expr_ref, int32_t *mc_arg_buf, int32_t *arg_buf,
    int32_t *parsed_refs, int32_t *pending_refs, uint8_t *mangled,
    uint8_t *name_buf);

int32_t parser_asm_string_lit_decode_span_x_into_c(void *arena, int32_t head_ref,
                                                  void *source, size_t q0,
                                                  int32_t nlen, int32_t line,
                                                  int32_t col) {
  int32_t ri;
  uint8_t c;
  uint8_t b;
  uint8_t n;
  int32_t consumed;
  uint8_t h1;
  uint8_t h2;
  int32_t v1;
  int32_t v2;
  uint8_t *data;
  size_t slen;
  if (!arena || !source || head_ref <= 0)
    return -1;
  if (nlen < 0)
    nlen = 0;
  data = parser_asm_lex_source_data_c(source);
  slen = parser_asm_lex_source_length_c(source);
  if (!data)
    return -1;
  ri = 0;
  while (ri < nlen) {
    c = 0;
    consumed = 1;
    if (q0 + (size_t)ri < slen)
      c = parser_asm_primary_ident_byte(data, q0, ri);
    b = c;
    if (c == 92 && (ri + 1) < nlen) {
      n = 0;
      if (q0 + (size_t)(ri + 1) < slen)
        n = parser_asm_primary_ident_byte(data, q0, ri + 1);
      if (n == 110) {
        b = 10;
        consumed = 2;
      } else if (n == 116) {
        b = 9;
        consumed = 2;
      } else if (n == 114) {
        b = 13;
        consumed = 2;
      } else if (n == 48) {
        b = 0;
        consumed = 2;
      } else if (n == 92 || n == 34) {
        b = n;
        consumed = 2;
      } else if (n == 120 && (ri + 3) < nlen) {
        h1 = 0;
        h2 = 0;
        v1 = -1;
        v2 = -1;
        if (q0 + (size_t)(ri + 2) < slen)
          h1 = parser_asm_primary_ident_byte(data, q0, ri + 2);
        if (q0 + (size_t)(ri + 3) < slen)
          h2 = parser_asm_primary_ident_byte(data, q0, ri + 3);
        if (h1 >= 48 && h1 <= 57)
          v1 = (int32_t)h1 - 48;
        if (h1 >= 97 && h1 <= 102)
          v1 = (int32_t)h1 - 97 + 10;
        if (h1 >= 65 && h1 <= 70)
          v1 = (int32_t)h1 - 65 + 10;
        if (h2 >= 48 && h2 <= 57)
          v2 = (int32_t)h2 - 48;
        if (h2 >= 97 && h2 <= 102)
          v2 = (int32_t)h2 - 97 + 10;
        if (h2 >= 65 && h2 <= 70)
          v2 = (int32_t)h2 - 65 + 10;
        if (v1 >= 0 && v2 >= 0) {
          b = (uint8_t)((v1 * 16) + v2);
          consumed = 4;
        } else {
          b = n;
          consumed = 2;
        }
      } else {
        b = n;
        consumed = 2;
      }
    }
    if (parser_asm_string_lit_append_byte_ptr_c(arena, head_ref, (int32_t)b, line,
                                               col) != 0)
      return -1;
    ri = ri + consumed;
  }
  return 0;
}


int32_t parser_asm_primary_string_x_into_c(void *arena, void *lex_inout,
                                           void *source, int32_t *out_ok,
                                           int32_t *out_expr_ref) {
  int32_t kind;
  int32_t ref;
  int32_t tl;
  int32_t tc;
  size_t q0;
  int32_t nlen;
  if (!arena || !lex_inout || !source || !out_ok || !out_expr_ref)
    return 0;
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_STRING)
    return 0;
  tl = parser_asm_lex_peek_tok_line_c(lex_inout, source);
  tc = parser_asm_lex_peek_tok_col_c(lex_inout, source);
  q0 = parser_asm_lex_peek_token_start_c(lex_inout, source);
  nlen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
  parser_asm_lex_step_kind_c(lex_inout, source);
  ref = ast_ast_arena_expr_alloc(arena);
  if (ref == 0) {
    out_ok[0] = 0;
    return 1;
  }
  pipeline_expr_set_kind(arena, ref, EXPR_STRING_LIT);
  pipeline_expr_set_line_col(arena, ref, tl, tc);
  pipeline_expr_set_common_zeros_c(arena, ref);
  {
    int32_t d = parser_asm_string_lit_decode_span_ptr_c(arena, ref, source, q0, nlen, tl,
                                              tc);
    if (d != 0) {
      out_ok[0] = 0;
      return 1;
    }
  }
  for (;;) {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_STRING)
      break;
    q0 = parser_asm_lex_peek_token_start_c(lex_inout, source);
    nlen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    if (parser_asm_string_lit_decode_span_ptr_c(arena, ref, source, q0, nlen, tl,
                                                tc) != 0) {
      out_ok[0] = 0;
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
  }
  out_ok[0] = 1;
  out_expr_ref[0] = ref;
  return 1;
}

int32_t parser_asm_parse_primary_x_into_c(void *arena, void *lex_inout,
                                         void *source, int32_t *out_ok,
                                         int32_t *out_expr_ref,
                                         int32_t *mc_arg_buf, int32_t *arg_buf,
                                         int32_t *parsed_refs,
                                         int32_t *pending_refs,
                                         uint8_t *mangled, uint8_t *name_buf) {
  int32_t kind;
  int32_t rc;
  if (!arena || !lex_inout || !source || !out_ok || !out_expr_ref)
    return 0;
  out_ok[0] = 0;
  out_expr_ref[0] = 0;
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  rc = parser_asm_primary_string_x_into_c(arena, lex_inout, source, out_ok,
                                          out_expr_ref);
  if (rc != 0)
    return 1;
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind == TOKEN_AT) {
    rc = parser_parse_at_simd_builtin_ptr_into_c(arena, lex_inout, source,
                                                 out_ok, out_expr_ref);
    if (rc == 0)
      out_ok[0] = 0;
    return 1;
  }
  rc = parser_asm_primary_literal_x_into_c(arena, lex_inout, source, out_ok,
                                           out_expr_ref, mc_arg_buf, arg_buf,
                                           parsed_refs, pending_refs, mangled,
                                           name_buf);
  if (rc != 0)
    return 1;
  rc = parser_asm_primary_break_continue_x_into_c(arena, lex_inout, source,
                                                  out_ok, out_expr_ref);
  if (rc != 0)
    return 1;
  rc = parser_asm_primary_return_x_into_c(arena, lex_inout, source, out_ok,
                                          out_expr_ref);
  if (rc != 0)
    return 1;
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind == TOKEN_MATCH) {
    rc = parser_parse_match_ptr_into_c(arena, lex_inout, source, out_ok,
                                       out_expr_ref);
    if (rc == 0)
      out_ok[0] = 0;
    return 1;
  }
  rc = parser_asm_primary_panic_x_into_c(arena, lex_inout, source, out_ok,
                                         out_expr_ref);
  if (rc != 0)
    return 1;
  rc = parser_asm_primary_ident_x_into_c(arena, lex_inout, source, out_ok,
                                         out_expr_ref, mc_arg_buf, arg_buf,
                                         parsed_refs, pending_refs, mangled,
                                         name_buf);
  if (rc != 0)
    return 1;
  rc = parser_asm_primary_paren_x_into_c(arena, lex_inout, source, out_ok,
                                         out_expr_ref, mc_arg_buf, arg_buf,
                                         parsed_refs, pending_refs, mangled,
                                         name_buf);
  if (rc != 0)
    return 1;
  rc = parser_asm_primary_array_x_into_c(arena, lex_inout, source, out_ok,
                                         out_expr_ref, mc_arg_buf, arg_buf,
                                         parsed_refs, pending_refs, mangled,
                                         name_buf);
  if (rc != 0)
    return 1;
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind == TOKEN_IF) {
    rc = parser_asm_parse_if_expr_x_into_c(arena, lex_inout, source, 0, out_ok,
                                           out_expr_ref);
    if (rc == 0)
      out_ok[0] = 0;
    return 1;
  }
  rc = parser_asm_primary_lbrace_x_into_c(arena, lex_inout, source, out_ok,
                                          out_expr_ref, mc_arg_buf, arg_buf,
                                          parsed_refs, pending_refs, mangled,
                                          name_buf);
  if (rc != 0)
    return 1;
  out_ok[0] = 0;
  return 1;
}
