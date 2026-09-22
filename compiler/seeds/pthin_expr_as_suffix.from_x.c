/* seeds/pthin_expr_as_suffix.from_x.c — G-02f-285 P2 parser thin P4 as_suffix
 * Logic source: src/asm/pthin_expr_as_suffix.x
 * Hybrid: XLANG_PTHIN_EXPR_AS_SUFFIX_FROM_X + ld -r into parser_asm_thin_glue.o
 *
 * Body: seeds/parser_asm/parser_asm_as_suffix_slice.inc
 *
 * Hybrid P4as/P4ad (XLANG_PTHIN_EXPR_AS_SUFFIX_BODIES_FROM_X): portable
 * TRY_PROPAGATE + EXPR_AS wrap dest-buffer and parse dest-buffer come from
 * pthin_expr_as_suffix.x; this TU keeps wrap trampolines plus peek-after
 * / parse trampolines. Cold: no BODIES define, full .inc.
 * Do not reuse XLANG_PTHIN_EXPR_AS_SUFFIX_FROM_X for P4as/P4ad bodies.
 * G.7: pipeline_expr_set_unary_operand_c lives in the P4u seed
 * (unary_operand_ref); pipeline_expr_set_as_c lives here (as_* slots).
 * Do not copy set_unary into this seed and do not FORCE pabi mega.
 * PLATFORM: SHARED — do not assemble parser.x.
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser_asm_stretch_audit_gate.h"
#include "token.h"

/* PLATFORM: SHARED — 7.2.1 P4ad. pthin_expr_as_suffix.x TOKEN_* are pin
 * copies of this enum. token.h remains the authority; fire if the pin drifts. */
_Static_assert((int)TOKEN_RPAREN == 83, "as_suffix.x TOKEN_RPAREN pin");
_Static_assert((int)TOKEN_RBRACE == 85, "as_suffix.x TOKEN_RBRACE pin");
_Static_assert((int)TOKEN_RBRACKET == 87, "as_suffix.x TOKEN_RBRACKET pin");
_Static_assert((int)TOKEN_COMMA == 90, "as_suffix.x TOKEN_COMMA pin");
_Static_assert((int)TOKEN_SEMICOLON == 95, "as_suffix.x TOKEN_SEMICOLON pin");
_Static_assert((int)TOKEN_QUESTION == 127, "as_suffix.x TOKEN_QUESTION pin");
_Static_assert((int)TOKEN_AS == 128, "as_suffix.x TOKEN_AS pin");

#ifdef XLANG_PTHIN_EXPR_AS_SUFFIX_BODIES_FROM_X
/* .x product bodies (same C names for Route C wraps + parse dest-buffer). */
extern int32_t parser_asm_try_propagate_wrap_into_c(void *arena, int32_t *out_ok, int32_t *out_expr_ref,
                                                    int32_t inner_ref);
extern int32_t parser_asm_as_wrap_into_c(void *arena, int32_t *out_ok, int32_t *out_expr_ref, int32_t inner_ref,
                                         int32_t type_ref);
extern int32_t parser_asm_parse_as_suffix_x_into_c(void *arena, void *lex_inout, void *source, int32_t *out_ok,
                                                   int32_t *out_expr_ref);
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

struct parser_asm_parse_expr_result {
  int32_t ok;
  int32_t expr_ref;
  struct parser_asm_lexer next_lex;
};

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

/* PLATFORM: SHARED — 7.2.1 P4as B-minus. ExprKind pins + consumer-wave
 * writer. pabi inject-only skips new rest symbols, so this T lives in
 * the P4as seed (recompiled every g05). Pointer = pipeline_arena_expr_ptr.
 * Layout ≡ W278_Expr; P4uc already pinned unary_operand_ref==300.
 * as_operand_ref=1208 / as_target_type_ref=1212 (late offsets). */
_Static_assert(offsetof(struct ast_Expr, unary_operand_ref) == 300, "P4as unary_operand_ref offset ≡ W278_Expr");
_Static_assert(offsetof(struct ast_Expr, as_operand_ref) == 1208, "P4as as_operand_ref offset ≡ W278_Expr");
_Static_assert(offsetof(struct ast_Expr, as_target_type_ref) == 1212, "P4as as_target_type_ref offset ≡ W278_Expr");
extern void *pipeline_arena_expr_ptr(void *a, int32_t ref);
void pipeline_expr_set_as_c(void *a, int32_t er, int32_t operand_ref, int32_t type_ref) {
  struct ast_Expr *ex;
  if (!a || er <= 0)
    return;
  ex = (struct ast_Expr *)pipeline_arena_expr_ptr(a, er);
  if (!ex)
    return;
  ex->as_operand_ref = operand_ref;
  ex->as_target_type_ref = type_ref;
}

/* 与 type_ref_slice / mega rest TypeKind 一致。 */
struct ast_Type {
  int32_t kind;
  uint8_t name[256];
  int32_t name_len;
  int32_t elem_type_ref;
  int32_t array_size;
  uint8_t region_label[256];
  int32_t region_label_len;
};

enum {
  PARSER_ASM_TYPE_I32 = 0,
  PARSER_ASM_TYPE_BOOL = 1,
  PARSER_ASM_TYPE_U8 = 2,
  PARSER_ASM_TYPE_U32 = 3,
  PARSER_ASM_TYPE_U64 = 4,
  PARSER_ASM_TYPE_I64 = 5,
  PARSER_ASM_TYPE_USIZE = 6,
  PARSER_ASM_TYPE_ISIZE = 7,
  PARSER_ASM_TYPE_NAMED = 8,
  PARSER_ASM_TYPE_PTR = 9,
  PARSER_ASM_TYPE_ARRAY = 10,
  PARSER_ASM_TYPE_SLICE = 11,
  PARSER_ASM_TYPE_LINEAR = 12,
  PARSER_ASM_TYPE_VECTOR = 13,
  PARSER_ASM_TYPE_F32 = 14,
  PARSER_ASM_TYPE_F64 = 15,
  PARSER_ASM_TYPE_VOID = 16
};

extern struct ast_Expr ast_arena_expr_get(void *arena, int32_t ref);
extern void ast_arena_expr_set(void *arena, int32_t ref, struct ast_Expr e);
extern int32_t ast_ast_arena_expr_alloc(void *arena);
extern int32_t ast_ast_arena_type_alloc(void *arena);
extern struct ast_Type ast_arena_type_get(void *arena, int32_t ref);
extern void ast_arena_type_set(void *arena, int32_t ref, struct ast_Type t);
extern int32_t parser_asm_alloc_pointee_type_ref_from_tok_c(void *arena, struct parser_asm_slice_u8 *source,
                                                           struct parser_asm_lexer_result *r);
/* Full type_ref parser entry — as_suffix after `as` (scalars / NAMED / *T /
 * []T / [N]T / SIMD). PLATFORM: SHARED. */
extern int32_t parser_asm_parse_type_ref_for_arena_into_slice_c(void *arena, struct parser_asm_lexer lex,
                                                                struct parser_asm_slice_u8 *source,
                                                                struct parser_asm_lexer *out_lex);

struct parser_asm_ast_expr parser_asm_arena_expr_get_c(void *arena, int32_t ref);

static void parser_asm_arena_expr_set_c(void *arena, int32_t ref, struct parser_asm_ast_expr ae) {
  struct ast_Expr e;
  memcpy(&e, &ae, sizeof(e));
  ast_arena_expr_set(arena, ref, e);
}

/* Class AE: zeros authority = pthin_foundation.x (P20b) / foundation seed; no per-slice host-cc twin. */
void parser_asm_expr_set_common_zeros_c(struct parser_asm_ast_expr *e);

extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                            struct parser_asm_slice_u8 *data);
extern void parser_asm_lex_from_result_val_into(struct parser_asm_lexer *out, struct parser_asm_lexer_result r);
extern void parser_lex_from_lexer_result_ptr_into(struct parser_asm_lexer *out,
                                                 struct parser_asm_lexer_result *r);

#include "parser_asm_as_suffix_slice.inc"

/* PLATFORM: SHARED — 7.2.1 P4as. pthin_expr_as_suffix.x ExprKind pins. */
_Static_assert(PARSER_ASM_EXPR_AS == 54, "as_suffix.x EXPR_AS pin");
_Static_assert(PARSER_ASM_EXPR_TRY_PROPAGATE == 58, "as_suffix.x EXPR_TRY_PROPAGATE pin");

int labi_pthin_expr_as_suffix_slice_marker(void) {
  return 1;
}
