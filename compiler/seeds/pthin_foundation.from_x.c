/* seeds/pthin_foundation.from_x.c — G-02f-329 / Class AD P20 foundation
 * Logic source: src/asm/pthin_foundation.x (zeros under BODIES_FROM_X)
 * Hybrid: XLANG_PTHIN_FOUNDATION_FROM_X + ld -r into parser_asm_thin_glue.o
 *
 * lexer_init + arena_expr_get/set stay host-cc (by-value structs).
 * Cap expr-watch removed Class AD.
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>

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

/* 与 thin mega 一致的扁平 expr 布局（memcpy 桥接） */
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

/* Class AD P20b: pin offsets used by pthin_foundation.x (layout authority = this struct). */
_Static_assert(offsetof(struct parser_asm_ast_expr, resolved_type_ref) == 4, "foundation off resolved_type_ref");
_Static_assert(offsetof(struct parser_asm_ast_expr, binop_left_ref) == 292, "foundation off binop_left_ref");
_Static_assert(offsetof(struct parser_asm_ast_expr, binop_right_ref) == 296, "foundation off binop_right_ref");
_Static_assert(offsetof(struct parser_asm_ast_expr, unary_operand_ref) == 300, "foundation off unary_operand_ref");
_Static_assert(offsetof(struct parser_asm_ast_expr, if_cond_ref) == 304, "foundation off if_cond_ref");
_Static_assert(offsetof(struct parser_asm_ast_expr, if_then_ref) == 308, "foundation off if_then_ref");
_Static_assert(offsetof(struct parser_asm_ast_expr, if_else_ref) == 312, "foundation off if_else_ref");
_Static_assert(offsetof(struct parser_asm_ast_expr, block_ref) == 316, "foundation off block_ref");
_Static_assert(offsetof(struct parser_asm_ast_expr, match_matched_ref) == 320, "foundation off match_matched_ref");
_Static_assert(offsetof(struct parser_asm_ast_expr, match_arm_base) == 324, "foundation off match_arm_base");
_Static_assert(offsetof(struct parser_asm_ast_expr, match_num_arms) == 328, "foundation off match_num_arms");
_Static_assert(offsetof(struct parser_asm_ast_expr, field_access_base_ref) == 332, "foundation off field_access_base_ref");
_Static_assert(offsetof(struct parser_asm_ast_expr, field_access_field_len) == 592, "foundation off field_access_field_len");
_Static_assert(offsetof(struct parser_asm_ast_expr, field_access_is_enum_variant) == 596, "foundation off field_access_is_enum_variant");
_Static_assert(offsetof(struct parser_asm_ast_expr, field_access_offset) == 600, "foundation off field_access_offset");
_Static_assert(offsetof(struct parser_asm_ast_expr, index_base_ref) == 608, "foundation off index_base_ref");
_Static_assert(offsetof(struct parser_asm_ast_expr, index_index_ref) == 612, "foundation off index_index_ref");
_Static_assert(offsetof(struct parser_asm_ast_expr, index_base_is_slice) == 616, "foundation off index_base_is_slice");
_Static_assert(offsetof(struct parser_asm_ast_expr, call_callee_ref) == 620, "foundation off call_callee_ref");
_Static_assert(offsetof(struct parser_asm_ast_expr, call_arg_base) == 624, "foundation off call_arg_base");
_Static_assert(offsetof(struct parser_asm_ast_expr, call_num_args) == 628, "foundation off call_num_args");
_Static_assert(offsetof(struct parser_asm_ast_expr, call_num_type_args) == 632, "foundation off call_num_type_args");
_Static_assert(offsetof(struct parser_asm_ast_expr, method_call_base_ref) == 636, "foundation off method_call_base_ref");
_Static_assert(offsetof(struct parser_asm_ast_expr, method_call_name_len) == 896, "foundation off method_call_name_len");
_Static_assert(offsetof(struct parser_asm_ast_expr, method_call_arg_base) == 900, "foundation off method_call_arg_base");
_Static_assert(offsetof(struct parser_asm_ast_expr, method_call_num_args) == 904, "foundation off method_call_num_args");
_Static_assert(offsetof(struct parser_asm_ast_expr, const_folded_val) == 908, "foundation off const_folded_val");
_Static_assert(offsetof(struct parser_asm_ast_expr, const_folded_valid) == 912, "foundation off const_folded_valid");
_Static_assert(offsetof(struct parser_asm_ast_expr, index_proven_in_bounds) == 916, "foundation off index_proven_in_bounds");
_Static_assert(offsetof(struct parser_asm_ast_expr, struct_lit_field_base) == 1180, "foundation off struct_lit_field_base");
_Static_assert(offsetof(struct parser_asm_ast_expr, struct_lit_num_fields) == 1184, "foundation off struct_lit_num_fields");
_Static_assert(offsetof(struct parser_asm_ast_expr, array_lit_elem_base) == 1188, "foundation off array_lit_elem_base");
_Static_assert(offsetof(struct parser_asm_ast_expr, array_lit_num_elems) == 1192, "foundation off array_lit_num_elems");
_Static_assert(offsetof(struct parser_asm_ast_expr, enum_variant_tag) == 1204, "foundation off enum_variant_tag");
_Static_assert(offsetof(struct parser_asm_ast_expr, as_operand_ref) == 1208, "foundation off as_operand_ref");
_Static_assert(offsetof(struct parser_asm_ast_expr, as_target_type_ref) == 1212, "foundation off as_target_type_ref");
_Static_assert(offsetof(struct parser_asm_ast_expr, call_resolved_func_index) == 1216, "foundation off call_resolved_func_index");
_Static_assert(offsetof(struct parser_asm_ast_expr, call_resolved_dep_index) == 1220, "foundation off call_resolved_dep_index");
_Static_assert(sizeof(struct parser_asm_ast_expr) == 1224, "foundation sizeof parser_asm_ast_expr");

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

struct parser_asm_lexer parser_asm_lexer_init_c(void) {
  struct parser_asm_lexer lex;
  lex.pos = 0;
  lex.line = 1;
  lex.col = 1;
  return lex;
}

#include "parser_asm_foundation_slice.inc"

int labi_pthin_foundation_slice_marker(void) {
  return 1;
}
