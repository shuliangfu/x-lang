/**
 * parser_asm_parse_bootstrap_obj.c — experimental 链 parser_parse_bootstrap.o 独立 TU。
 *
 * 瘦 parser_x.o + PARSER_ASM_THIN_GLUE_NO_SEED_PARSE 时须强符号 parse_into_buf；
 * SHUX_ASM_PARSER_PARSE_BOOTSTRAP_EMIT 对全量 parser.x 真 emit 在 seed/shux_asm 上仍会 139，
 * 故由本 TU #include seed slice，链接时 thin_c glue 解析 extern 依赖。
 * 勿与含 seed slice 的 parser_asm_thin_c.c 同链（experimental 已定义 NO_SEED_PARSE）。
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#include "token.h"
#include "ast.h"

/** 与 parser_asm_thin_c.c / token.x 布局一致。 */
struct parser_asm_token {
  int32_t kind;
  int32_t line;
  int32_t col;
  int32_t int_val;
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

struct parser_asm_try_skip_allow_result {
  struct parser_asm_lexer lex;
  int32_t skipped;
  uint8_t _pad[4];
};

struct parser_asm_library_parse_result {
  uint8_t ok;
  uint8_t _pad[4];
  struct parser_asm_lexer next_lex;
  uint8_t name[64];
  int32_t name_len;
  uint8_t _pad_tail[4];
};

struct parser_asm_collect_imports_result {
  struct parser_asm_lexer lex;
};

struct parser_asm_onefunc_result {
  int32_t ok;
  struct parser_asm_lexer next_lex;
  uint8_t name[64];
  int32_t name_len;
  int32_t num_params;
  int32_t num_generic_params;
  int32_t num_consts;
  int32_t num_lets;
  int32_t has_if_expr;
  int32_t if_cond_true;
  int32_t if_then_val;
  int32_t if_else_val;
  int32_t if_cond_expr_ref;
  int32_t has_mul;
  int32_t mul_right_val;
  int32_t has_binop;
  int32_t binop_right_val;
  int32_t binop_left_param_idx;
  int32_t binop_right_param_idx;
  int32_t has_unary_neg;
  int32_t return_val;
  int32_t has_call_expr;
  uint8_t call_callee_name[64];
  int32_t call_callee_len;
  uint8_t return_var_name[64];
  int32_t return_var_name_len;
  int32_t return_expr_ref;
  int32_t has_final_expr;
  int32_t has_explicit_return_kw;
  int32_t call_num_args;
  int32_t num_loops;
  int32_t num_for_loops;
  int32_t num_if_stmts;
  int32_t num_src_stmt_order;
  int32_t num_src_body_expr_stmts;
  int32_t func_return_type_ref;
};

/** 与 parser_asm_top_level_let_slice.c TopLevelLetResult 布局一致。 */
struct parser_asm_top_level_let_result {
  int32_t ok;
  uint8_t _pad[4];
  struct parser_asm_lexer next_lex;
};

/** 与 parser_asm_type_ref_slice.c / ast.x Type 布局一致。 */
struct ast_Type {
  int32_t kind;
  uint8_t name[64];
  int32_t name_len;
  int32_t elem_type_ref;
  int32_t array_size;
  uint8_t region_label[64];
  int32_t region_label_len;
};

/** 与 parser_asm_thin_c.c pipeline ast_Expr 布局一致。 */
struct ast_Expr {
  int32_t kind;
  int32_t resolved_type_ref;
  int32_t line;
  int32_t col;
  int32_t int_val;
  int32_t _expr_pad_before_f64;
  double float_val;
  uint8_t var_name[64];
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
  uint8_t field_access_field_name[64];
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
  int32_t method_call_base_ref;
  uint8_t method_call_name[64];
  int32_t method_call_name_len;
  int32_t method_call_arg_base;
  int32_t method_call_num_args;
  int32_t const_folded_val;
  int32_t const_folded_valid;
  int32_t index_proven_in_bounds;
  uint8_t struct_lit_struct_name[64];
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

/** 与 parser_asm_library_slice.c / ast.x Block 布局一致。 */
struct ast_Block {
  int32_t const_base;
  int32_t num_consts;
  int32_t let_base;
  int32_t num_lets;
  int32_t num_early_lets;
  int32_t loop_base;
  int32_t num_loops;
  int32_t for_loop_base;
  int32_t num_for_loops;
  int32_t if_base;
  int32_t num_if_stmts;
  int32_t region_base;
  int32_t num_regions;
  int32_t defer_base;
  int32_t num_defers;
  int32_t labeled_base;
  int32_t num_labeled_stmts;
  int32_t expr_stmt_base;
  int32_t num_expr_stmts;
  int32_t final_expr_ref;
  int32_t stmt_order_base;
  int32_t num_stmt_order;
  int32_t parent_block_ref;
};

#include "parser_asm_stretch_audit_gate.h"
#include "parser_asm_seed_parse_into_buf_slice.c"
