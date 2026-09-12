/* seeds/pthin_expr_binop.from_x.c — G-02f-284 P2 parser thin P4 binop
 * Logic source: src/asm/pthin_expr_binop.x
 * Hybrid: XLANG_PTHIN_EXPR_BINOP_FROM_X + ld -r into parser_asm_thin_glue.o
 *
 * Body: seeds/parser_asm/parser_asm_expr_binop_slice.inc
 * Types must match parser_asm_thin_c.from_x.c (layout-locked).
 * P2 Darwin -o: slice-local 1-token peek cache for left-assoc chains
 * (term…logor re-lexed the same unconsumed token once per level).
 * P2 Darwin -o: parse_logor_into used to invoke the || chain twice from the
 * same start lex (stretch padding). Product keeps one chain; stretch audits
 * stay no-op unless XLANG_PARSER_STRETCH_AUDIT. audit_fn on single_tok_chain
 * uses the same gate (was extra-lexing every bitand…logor expr).
 *
 * Hybrid P4bb (XLANG_PTHIN_EXPR_BINOP_BODIES_FROM_X): portable
 * TOKEN→ExprKind comes from pthin_expr_binop.x; this TU keeps wrap
 * plus arena parse. Cold: no BODIES define, full .inc.
 * Do not reuse XLANG_PTHIN_EXPR_BINOP_FROM_X for P4bb bodies.
 * PLATFORM: SHARED — do not assemble parser.x.
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser_asm_stretch_audit_gate.h"
#include "token.h"

/* PLATFORM: SHARED — 7.2.1 P4bb Route C (2026-09-13).
 * pthin_expr_binop.x TOKEN_* are pin copies of this enum.
 * token.h remains the authority; fire if the pin drifts. */
_Static_assert((int)TOKEN_PLUS == 96, "binop.x TOKEN_PLUS pin");
_Static_assert((int)TOKEN_MINUS == 97, "binop.x TOKEN_MINUS pin");
_Static_assert((int)TOKEN_STAR == 98, "binop.x TOKEN_STAR pin");
_Static_assert((int)TOKEN_SLASH == 99, "binop.x TOKEN_SLASH pin");
_Static_assert((int)TOKEN_PERCENT == 100, "binop.x TOKEN_PERCENT pin");
_Static_assert((int)TOKEN_AMP == 101, "binop.x TOKEN_AMP pin");
_Static_assert((int)TOKEN_PIPE == 102, "binop.x TOKEN_PIPE pin");
_Static_assert((int)TOKEN_CARET == 103, "binop.x TOKEN_CARET pin");
_Static_assert((int)TOKEN_LSHIFT == 104, "binop.x TOKEN_LSHIFT pin");
_Static_assert((int)TOKEN_RSHIFT == 105, "binop.x TOKEN_RSHIFT pin");
_Static_assert((int)TOKEN_EQ == 118, "binop.x TOKEN_EQ pin");
_Static_assert((int)TOKEN_NE == 119, "binop.x TOKEN_NE pin");
_Static_assert((int)TOKEN_LT == 120, "binop.x TOKEN_LT pin");
_Static_assert((int)TOKEN_GT == 121, "binop.x TOKEN_GT pin");
_Static_assert((int)TOKEN_LE == 122, "binop.x TOKEN_LE pin");
_Static_assert((int)TOKEN_GE == 123, "binop.x TOKEN_GE pin");
_Static_assert((int)TOKEN_AMPAMP == 124, "binop.x TOKEN_AMPAMP pin");
_Static_assert((int)TOKEN_PIPEPIPE == 125, "binop.x TOKEN_PIPEPIPE pin");

#ifdef XLANG_PTHIN_EXPR_BINOP_BODIES_FROM_X
/* .x product body (same C name for Route C scalar table). */
extern int32_t parser_asm_binop_token_to_expr_kind_c(int32_t kind);
#endif

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

/** 与 parser.x ParseExprResult 布局一致（bool→i32）。 */
struct parser_asm_parse_expr_result {
  int32_t ok;
  int32_t expr_ref;
  struct parser_asm_lexer next_lex;
};

/** 与 mega / x_seed_bridge 扁平 ast_Expr 一致。 */
struct parser_asm_ast_expr {
  int32_t kind;
  int32_t resolved_type_ref;
  int32_t line;
  int32_t col;
  int64_t int_val;
  double float_val;
  uint8_t var_name[256];
  int32_t var_name_len;
  int32_t binop_left_ref;
  int32_t binop_right_ref;
  int32_t unary_operand_ref;
  int32_t if_cond_ref;
  int32_t if_then_ref;
  int32_t if_else_ref;
  int32_t block_ref;
  int32_t match_matched_ref;
  int32_t match_arm_base;
  int32_t match_num_arms;
  int32_t field_access_base_ref;
  uint8_t field_access_field_name[256];
  int32_t field_access_field_len;
  int32_t field_access_is_enum_variant;
  int32_t field_access_offset;
  int32_t field_access_soa_stride;
  int32_t index_base_ref;
  int32_t index_index_ref;
  int32_t index_base_is_slice;
  int32_t call_callee_ref;
  int32_t call_arg_base;
  int32_t call_num_args;
  int32_t call_num_type_args;
  int32_t method_call_base_ref;
  uint8_t method_call_name[256];
  int32_t method_call_name_len;
  int32_t method_call_arg_base;
  int32_t method_call_num_args;
  int32_t const_folded_val;
  int32_t const_folded_valid;
  int32_t index_proven_in_bounds;
  uint8_t struct_lit_struct_name[256];
  int32_t struct_lit_struct_name_len;
  int32_t struct_lit_field_base;
  int32_t struct_lit_num_fields;
  int32_t array_lit_elem_base;
  int32_t array_lit_num_elems;
  int32_t float_bits_lo;
  int32_t float_bits_hi;
  int32_t enum_variant_tag;
  int32_t as_operand_ref;
  int32_t as_target_type_ref;
  int32_t call_resolved_func_index;
  int32_t call_resolved_dep_index;
};

struct ast_Expr {
  int32_t kind;
  int32_t resolved_type_ref;
  int32_t line;
  int32_t col;
  int64_t int_val;
  double float_val;
  uint8_t var_name[256];
  int32_t var_name_len;
  int32_t binop_left_ref;
  int32_t binop_right_ref;
  int32_t unary_operand_ref;
  int32_t if_cond_ref;
  int32_t if_then_ref;
  int32_t if_else_ref;
  int32_t block_ref;
  int32_t match_matched_ref;
  int32_t match_arm_base;
  int32_t match_num_arms;
  int32_t field_access_base_ref;
  uint8_t field_access_field_name[256];
  int32_t field_access_field_len;
  int32_t field_access_is_enum_variant;
  int32_t field_access_offset;
  int32_t field_access_soa_stride;
  int32_t index_base_ref;
  int32_t index_index_ref;
  int32_t index_base_is_slice;
  int32_t call_callee_ref;
  int32_t call_arg_base;
  int32_t call_num_args;
  int32_t call_num_type_args;
  int32_t method_call_base_ref;
  uint8_t method_call_name[256];
  int32_t method_call_name_len;
  int32_t method_call_arg_base;
  int32_t method_call_num_args;
  int32_t const_folded_val;
  int32_t const_folded_valid;
  int32_t index_proven_in_bounds;
  uint8_t struct_lit_struct_name[256];
  int32_t struct_lit_struct_name_len;
  int32_t struct_lit_field_base;
  int32_t struct_lit_num_fields;
  int32_t array_lit_elem_base;
  int32_t array_lit_num_elems;
  int32_t float_bits_lo;
  int32_t float_bits_hi;
  int32_t enum_variant_tag;
  int32_t as_operand_ref;
  int32_t as_target_type_ref;
  int32_t call_resolved_func_index;
  int32_t call_resolved_dep_index;
};

extern struct ast_Expr ast_arena_expr_get(void *arena, int32_t ref);
extern void ast_arena_expr_set(void *arena, int32_t ref, struct ast_Expr e);
extern int32_t ast_ast_arena_expr_alloc(void *arena);

/* get 非 static 在 mega rest；hybrid 时本 TU 仅声明。 */
struct parser_asm_ast_expr parser_asm_arena_expr_get_c(void *arena, int32_t ref);

/* binop_slice.inc 期望 static set/zeros 同 TU。 */
static void parser_asm_arena_expr_set_c(void *arena, int32_t ref, struct parser_asm_ast_expr ae) {
  struct ast_Expr e;
  memcpy(&e, &ae, sizeof(e));
  ast_arena_expr_set(arena, ref, e);
}

static void parser_asm_expr_set_common_zeros_c(struct parser_asm_ast_expr *e) {
  if (!e)
    return;
  e->resolved_type_ref = 0;
  e->binop_left_ref = 0;
  e->binop_right_ref = 0;
  e->unary_operand_ref = 0;
  e->if_cond_ref = 0;
  e->if_then_ref = 0;
  e->if_else_ref = 0;
  e->block_ref = 0;
  e->match_matched_ref = 0;
  e->match_arm_base = 0;
  e->match_num_arms = 0;
  e->match_arm_base = 0;
  e->enum_variant_tag = 0;
  e->field_access_base_ref = 0;
  e->field_access_field_len = 0;
  e->field_access_is_enum_variant = 0;
  e->field_access_offset = 0;
  e->index_base_ref = 0;
  e->index_index_ref = 0;
  e->index_base_is_slice = 0;
  e->call_callee_ref = 0;
  e->call_arg_base = 0;
  e->call_num_args = 0;
  e->call_num_type_args = 0;
  e->method_call_base_ref = 0;
  e->method_call_name_len = 0;
  e->method_call_arg_base = 0;
  e->method_call_num_args = 0;
  e->const_folded_val = 0;
  e->const_folded_valid = 0;
  e->index_proven_in_bounds = 0;
  e->struct_lit_field_base = 0;
  e->struct_lit_num_fields = 0;
  e->array_lit_elem_base = 0;
  e->array_lit_num_elems = 0;
  e->as_operand_ref = 0;
  e->as_target_type_ref = 0;
  e->call_resolved_func_index = -1;
  e->call_resolved_dep_index = -1;
}

extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                            struct parser_asm_slice_u8 *data);
extern void parser_asm_lex_from_result_val_into(struct parser_asm_lexer *out, struct parser_asm_lexer_result r);

#include "parser_asm_expr_binop_slice.inc"

int labi_pthin_expr_binop_slice_marker(void) {
  return 10; /* term…logor 十级 */
}
