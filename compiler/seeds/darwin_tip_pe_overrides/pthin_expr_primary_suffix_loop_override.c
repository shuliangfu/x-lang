/**
 * PLATFORM: MACOS|DARWIN arm64 tip PE only —
 * tip_l4_tip_pe_println_method_call_p001 (follow-on after ident twin).
 *
 * Residual: tip parser_asm_primary_suffix_loop_x_into_c peeks hollow
 * (2 peek_kind vs Cap 14) → hang after ident ok=1 (dig_id before_suffix).
 * Soft Cap / Prefer / Cap aside / Win banned.
 *
 * Tip-local host-cc twin from src/asm/pthin_expr_primary.x — DOT method/
 * field, LPAREN call, early-exit for non-suffix (covers dig_id `;`).
 * LT turbofish / LBRACKET index / LBRACE struct-lit deferred.
 */
#include <stddef.h>
#include <stdint.h>

enum {
  TOKEN_TYPE = 20,
  TOKEN_PACKED = 21,
  TOKEN_SOA = 22,
  TOKEN_IDENT = 59,
  TOKEN_LPAREN = 82,
  TOKEN_RPAREN = 83,
  TOKEN_LBRACE = 84,
  TOKEN_LBRACKET = 86,
  TOKEN_COMMA = 90,
  TOKEN_DOT = 92,
  TOKEN_LT = 120,
  EXPR_FIELD_ACCESS = 44,
  EXPR_INDEX = 47,
  EXPR_CALL = 48,
  EXPR_METHOD_CALL = 49
};

extern int32_t parser_asm_lex_peek_kind_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_ident_len_c(void *lex_inout, void *source);
extern size_t parser_asm_lex_peek_token_start_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_tok_line_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_tok_col_c(void *lex_inout, void *source);
extern size_t parser_asm_lex_peek_next_pos_c(void *lex_inout, void *source);
extern uint8_t *parser_asm_lex_source_data_c(void *source);
extern size_t parser_asm_lex_source_length_c(void *source);
extern int32_t parser_asm_lex_step_kind_c(void *lex_inout, void *source);
extern size_t parser_asm_lex_pos_c(void *lex_inout);
extern void parser_asm_lex_set_pos_c(void *lex_inout, size_t pos);
extern void parser_asm_lex_set_line_c(void *lex_inout, int32_t line);
extern void parser_asm_lex_set_col_c(void *lex_inout, int32_t col);
extern size_t parser_asm_lex_at_token_pos_c(int32_t kind, size_t ts, int32_t il,
                                           size_t np);

extern int32_t ast_ast_arena_expr_alloc(void *arena);
extern void pipeline_expr_set_kind(void *arena, int32_t er, int32_t kind);
extern void pipeline_expr_set_line_col(void *arena, int32_t er, int32_t line,
                                      int32_t col);
extern void pipeline_expr_set_common_zeros_c(void *arena, int32_t er);
extern void pipeline_expr_set_method_call_c(void *arena, int32_t er,
                                           int32_t recv, uint8_t *name,
                                           int32_t nlen);
extern void pipeline_expr_set_field_access_c(void *arena, int32_t er,
                                            int32_t base, uint8_t *name,
                                            int32_t nlen);
extern void pipeline_expr_set_call_c(void *arena, int32_t er, int32_t callee,
                                    int32_t pending_n);
extern void pipeline_expr_init_call_resolve_at_ref(void *arena, int32_t er);
extern int32_t pipeline_expr_append_method_call_arg(void *arena, int32_t er,
                                                   int32_t arg);
extern int32_t pipeline_expr_append_call_arg(void *arena, int32_t er,
                                            int32_t arg);
extern int32_t pipeline_expr_append_call_type_arg(void *arena, int32_t er,
                                                 int32_t tr);
extern int32_t parser_parse_expr_ptr_into_c(void *arena, void *lex_inout,
                                           void *source, int32_t *out_ok,
                                           int32_t *out_expr_ref);

void parser_asm_primary_suffix_loop_x_into_c(
    void *arena, void *source, void *lex_inout, int32_t *out_ok,
    int32_t *out_expr_ref, int32_t *mc_arg_buf, int32_t *arg_buf,
    int32_t *parsed_refs, int32_t *pending_refs, uint8_t *mangled,
    uint8_t *name_buf) {
  int32_t kind;
  int32_t k2;
  int32_t k3;
  size_t prev_pos;
  int32_t prev_kind;
  int32_t stall;
  int32_t mname_len;
  size_t mname_start;
  int32_t mc_ref;
  int32_t fa_ref;
  int32_t call_ref;
  int32_t callee_ref;
  int32_t n;
  int32_t ai;
  int32_t ok2;
  int32_t eref2;
  uint8_t *data;
  int32_t pending_n;
  int32_t pi;
  size_t ts;
  int32_t il;
  size_t np;
  int32_t tl;
  int32_t tc;
  (void)parsed_refs;
  (void)mangled;
  (void)name_buf;
  if (!arena || !source || !lex_inout || !out_ok || !out_expr_ref)
    return;
  data = parser_asm_lex_source_data_c(source);
  (void)parser_asm_lex_source_length_c(source);
  pending_n = 0;
  if (pending_refs) {
    for (pi = 0; pi < 8; pi++)
      pending_refs[pi] = 0;
  }
  prev_pos = 0;
  prev_kind = -1;
  stall = 0;
  for (;;) {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (parser_asm_lex_pos_c(lex_inout) == prev_pos && kind == prev_kind) {
      stall++;
      if (stall >= 4096) {
        out_ok[0] = 0;
        return;
      }
    } else {
      stall = 0;
    }
    prev_pos = parser_asm_lex_pos_c(lex_inout);
    prev_kind = kind;
    if (kind == TOKEN_DOT) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
      mname_len = -1;
      if (k2 == TOKEN_IDENT) {
        mname_len = parser_asm_lex_peek_ident_len_c(lex_inout, source);
        if (mname_len <= 0)
          mname_len = -1;
      } else if (k2 == TOKEN_TYPE) {
        mname_len = 4;
      } else if (k2 == TOKEN_SOA) {
        mname_len = 3;
      } else if (k2 == TOKEN_PACKED) {
        mname_len = 6;
      }
      if (mname_len < 0)
        return;
      if (mname_len > 255)
        mname_len = 127;
      mname_start = parser_asm_lex_peek_token_start_c(lex_inout, source);
      parser_asm_lex_step_kind_c(lex_inout, source);
      k3 = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (k3 == TOKEN_LPAREN) {
        mc_ref = ast_ast_arena_expr_alloc(arena);
        if (mc_ref == 0) {
          out_ok[0] = 0;
          return;
        }
        pipeline_expr_set_common_zeros_c(arena, mc_ref);
        pipeline_expr_set_kind(arena, mc_ref, EXPR_METHOD_CALL);
        pipeline_expr_set_method_call_c(arena, mc_ref, out_expr_ref[0],
                                       data + mname_start, mname_len);
        pipeline_expr_set_line_col(arena, mc_ref, 0, 0);
        out_expr_ref[0] = mc_ref;
        parser_asm_lex_step_kind_c(lex_inout, source);
        k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (k2 != TOKEN_RPAREN) {
          n = 0;
          for (;;) {
            if (n >= 256) {
              out_ok[0] = 0;
              return;
            }
            ok2 = 0;
            eref2 = 0;
            if (parser_parse_expr_ptr_into_c(arena, lex_inout, source, &ok2,
                                            &eref2) == 0) {
              out_ok[0] = 0;
              return;
            }
            if (ok2 == 0) {
              out_ok[0] = 0;
              return;
            }
            mc_arg_buf[n] = eref2;
            n++;
            k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
            if (k2 == TOKEN_COMMA) {
              parser_asm_lex_step_kind_c(lex_inout, source);
              continue;
            }
            if (k2 == TOKEN_RPAREN) {
              parser_asm_lex_step_kind_c(lex_inout, source);
              for (ai = 0; ai < n; ai++) {
                if (pipeline_expr_append_method_call_arg(arena, mc_ref,
                                                        mc_arg_buf[ai]) < 0) {
                  out_ok[0] = 0;
                  return;
                }
              }
              break;
            }
            out_ok[0] = 0;
            return;
          }
        } else {
          parser_asm_lex_step_kind_c(lex_inout, source);
        }
      } else {
        fa_ref = ast_ast_arena_expr_alloc(arena);
        if (fa_ref == 0) {
          out_ok[0] = 0;
          return;
        }
        pipeline_expr_set_common_zeros_c(arena, fa_ref);
        pipeline_expr_set_kind(arena, fa_ref, EXPR_FIELD_ACCESS);
        pipeline_expr_set_field_access_c(arena, fa_ref, out_expr_ref[0],
                                        data + mname_start, mname_len);
        pipeline_expr_set_line_col(arena, fa_ref, 0, 0);
        out_expr_ref[0] = fa_ref;
        k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
        ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
        il = parser_asm_lex_peek_ident_len_c(lex_inout, source);
        np = parser_asm_lex_peek_next_pos_c(lex_inout, source);
        tl = parser_asm_lex_peek_tok_line_c(lex_inout, source);
        tc = parser_asm_lex_peek_tok_col_c(lex_inout, source);
        parser_asm_lex_set_pos_c(lex_inout,
                                parser_asm_lex_at_token_pos_c(k2, ts, il, np));
        parser_asm_lex_set_line_c(lex_inout, tl);
        parser_asm_lex_set_col_c(lex_inout, tc);
      }
      continue;
    }
    if (kind == TOKEN_LPAREN) {
      callee_ref = out_expr_ref[0];
      parser_asm_lex_step_kind_c(lex_inout, source);
      call_ref = ast_ast_arena_expr_alloc(arena);
      if (call_ref == 0) {
        out_ok[0] = 0;
        return;
      }
      pipeline_expr_set_common_zeros_c(arena, call_ref);
      pipeline_expr_set_kind(arena, call_ref, EXPR_CALL);
      pipeline_expr_set_line_col(arena, call_ref, 0, 0);
      pipeline_expr_init_call_resolve_at_ref(arena, call_ref);
      pipeline_expr_set_call_c(arena, call_ref, callee_ref, pending_n);
      if (pending_n > 0 && pending_refs && pending_refs[0] > 0) {
        for (ai = 0; ai < pending_n && ai < 8; ai++) {
          if (pending_refs[ai] <= 0)
            break;
          if (pipeline_expr_append_call_type_arg(arena, call_ref,
                                                pending_refs[ai]) < 0) {
            out_ok[0] = 0;
            return;
          }
        }
      }
      pending_n = 0;
      if (pending_refs) {
        for (pi = 0; pi < 8; pi++)
          pending_refs[pi] = 0;
      }
      n = 0;
      k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (k2 != TOKEN_RPAREN) {
        for (;;) {
          if (n >= 256) {
            out_ok[0] = 0;
            return;
          }
          ok2 = 0;
          eref2 = 0;
          if (parser_parse_expr_ptr_into_c(arena, lex_inout, source, &ok2,
                                          &eref2) == 0) {
            out_ok[0] = 0;
            return;
          }
          if (ok2 == 0) {
            out_ok[0] = 0;
            return;
          }
          arg_buf[n] = eref2;
          n++;
          k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
          if (k2 == TOKEN_COMMA) {
            parser_asm_lex_step_kind_c(lex_inout, source);
            continue;
          }
          if (k2 == TOKEN_RPAREN) {
            parser_asm_lex_step_kind_c(lex_inout, source);
            break;
          }
          out_ok[0] = 0;
          return;
        }
      } else {
        parser_asm_lex_step_kind_c(lex_inout, source);
      }
      for (ai = 0; ai < n; ai++) {
        if (pipeline_expr_append_call_arg(arena, call_ref, arg_buf[ai]) < 0) {
          out_ok[0] = 0;
          return;
        }
      }
      out_expr_ref[0] = call_ref;
      continue;
    }
    /* LT / LBRACKET / LBRACE deferred — non-suffix exit (`;`, `)`, etc.). */
    return;
  }
}
