/**
 * PLATFORM: WINDOWS tip PE only — override tip-peel stale primary_array.
 *
 * Root (刀 11.45): Win xlang_asm.exe keeps
 *   __stale_prim_parser_asm_primary_array_x_into_c
 * as a 5-byte `jmp` into primary_suffix_loop (no `[...]` consume).
 * parse_primary_into_slice_c → stale parse_primary_x → that stub on
 * TOKEN_LBRACKET. Nonempty `T[N] = [lit,…]` body lets then soft-fail /
 * leak into module top-level → P012 (hello / core.fmt num_digits).
 * Empty `[]` stays on the shallow body_lets walk (OK). Darwin tip OK.
 *
 * Strong T under the stale name wins over the weak jmp stub on relink.
 * Do NOT raise Soft Cap / tiphead; do NOT unique-rename fmt (hollow ban).
 */
#include <stdint.h>

enum { TOKEN_LBRACKET = 86, TOKEN_RBRACKET = 87, TOKEN_COMMA = 90 };
enum { EXPR_ARRAY_LIT = 46 };

extern int32_t parser_asm_lex_peek_kind_c(void *lex_inout, void *source);
extern void parser_asm_lex_step_kind_c(void *lex_inout, void *source);
extern int32_t ast_ast_arena_expr_alloc(void *arena);
extern void pipeline_expr_set_kind(void *arena, int32_t ref, int32_t kind);
extern void pipeline_expr_set_common_zeros_c(void *arena, int32_t ref);
extern void pipeline_expr_set_line_col(void *arena, int32_t ref, int32_t line, int32_t col);
extern int32_t pipeline_expr_append_array_lit_elem(void *arena, int32_t arr_ref, int32_t elem_ref);
extern int32_t parser_parse_expr_ptr_into_c(void *arena, void *lex_inout, void *source, int32_t *out_ok,
                                           int32_t *out_expr_ref);
extern int32_t __stale_prim_parser_asm_primary_suffix_loop_x_into_c(
    void *arena, void *source, void *lex_inout, int32_t *out_ok, int32_t *out_expr_ref, int32_t *mc_arg_buf,
    int32_t *arg_buf, int32_t *parsed_refs, int32_t *pending_refs, void *mangled, void *name_buf);

/**
 * @return 1 handled (incl. fail via *out_ok=0); 0 not LBRACKET.
 * ABI twin of parser_asm_primary_array_x_into_c (pthin_expr_primary.x).
 */
int32_t __stale_prim_parser_asm_primary_array_x_into_c(void *arena, void *lex_inout, void *source,
                                                       int32_t *out_ok, int32_t *out_expr_ref,
                                                       int32_t *mc_arg_buf, int32_t *arg_buf,
                                                       int32_t *parsed_refs, int32_t *pending_refs,
                                                       void *mangled, void *name_buf) {
  int32_t kind;
  int32_t ref;
  int32_t eok;
  int32_t eref;

  if (!arena || !lex_inout || !source || !out_ok || !out_expr_ref)
    return 0;
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_LBRACKET)
    return 0;
  parser_asm_lex_step_kind_c(lex_inout, source);
  ref = ast_ast_arena_expr_alloc(arena);
  if (ref == 0) {
    *out_ok = 0;
    return 1;
  }
  pipeline_expr_set_kind(arena, ref, EXPR_ARRAY_LIT);
  pipeline_expr_set_common_zeros_c(arena, ref);
  pipeline_expr_set_line_col(arena, ref, 0, 0);
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_RBRACKET) {
    for (;;) {
      eok = 0;
      eref = 0;
      if (parser_parse_expr_ptr_into_c(arena, lex_inout, source, &eok, &eref) == 0 || eok == 0 ||
          eref == 0) {
        *out_ok = 0;
        return 1;
      }
      if (pipeline_expr_append_array_lit_elem(arena, ref, eref) < 0) {
        *out_ok = 0;
        return 1;
      }
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind == TOKEN_COMMA) {
        parser_asm_lex_step_kind_c(lex_inout, source);
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (kind == TOKEN_RBRACKET)
          break;
      } else {
        break;
      }
    }
  }
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_RBRACKET) {
    *out_ok = 0;
    return 1;
  }
  parser_asm_lex_step_kind_c(lex_inout, source);
  *out_ok = 1;
  *out_expr_ref = ref;
  (void)__stale_prim_parser_asm_primary_suffix_loop_x_into_c(arena, source, lex_inout, out_ok, out_expr_ref,
                                                            mc_arg_buf, arg_buf, parsed_refs, pending_refs,
                                                            mangled, name_buf);
  return 1;
}
