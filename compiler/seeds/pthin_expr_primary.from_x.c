/* seeds/pthin_expr_primary.from_x.c — G-02f-282 P2 parser thin P4 primary
 * Logic source: src/asm/pthin_expr_primary.x
 * Hybrid: XLANG_PTHIN_EXPR_PRIMARY_FROM_X + ld -r into parser_asm_thin_glue.o
 *
 * Bodies: finish_struct_lit_slice.inc + primary_slice.inc
 * (primary calls static parse_struct_lit_fields — same TU required)
 * Types must match parser_asm_thin_c.from_x.c (layout-locked).
 *
 * Hybrid P4b (XLANG_PTHIN_EXPR_PRIMARY_BODIES_FROM_X): portable IDENT
 * spelling / asm-option-bit / suffix_loop / IDENT head / P4bh remaining
 * parse_primary dest-buffer / P4bi parse_struct_lit_fields dest-buffer / P4bj anonymous-struct alloc (ANON_STRUCT_FROM_X) / P4bk BREAK/CONTINUE primary / P4bl suffix_loop LT relcompare rewind / P4bm STRING decode (STRING_DECODE_FROM_X; append_byte stays C) / P4bn finish_from_type_ident (FINISH_TYPE_IDENT_FROM_X; C holds name[256]) / P4bo parse_asm_bang (ASM_BANG_FROM_X; C holds tmpl[256]+regs[128]) / P4bp parse_unsafe (UNSAFE_FROM_X) / P4bq lbrace lookahead (LBRACE_LOOKAHEAD_FROM_X; C passes field_depth) / P4br ident_pre_dispatch (IDENT_PRE_DISPATCH_FROM_X; C holds tmpl[256]+regs[128])
 * come from pthin_expr_primary.x; this TU keeps slice trampolines.
 * Cold: no BODIES define, full .inc.
 * P3c mangle trampoline is compiled when this TU also sees
 * XLANG_PTHIN_TYPE_REF_BODIES_FROM_X (g05 passes P3 extra).
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#include "parser_asm_stretch_audit_gate.h"
#include "token.h"
#include "diag.h"

/* Class AE: Cap TRACE getenv/fprintf face removed from arena_expr_set. */

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

/** 与 parser.x ParseBlockResult 布局一致（bool→i32）。 */
struct parser_asm_parse_block_result {
  int32_t ok;
  int32_t block_ref;
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

/* get 非 static 在 mega rest；hybrid 时本 TU 仅声明，避免 ld -r 双定义。 */
struct parser_asm_ast_expr parser_asm_arena_expr_get_c(void *arena, int32_t ref);

/* primary_slice.inc 期望 static set/zeros 同 TU（mega 中亦为 static）。 */
static void parser_asm_arena_expr_set_c(void *arena, int32_t ref, struct parser_asm_ast_expr ae) {
  struct ast_Expr e;
  memcpy(&e, &ae, sizeof(e));
  /* Class AE: Cap TRACE watch (link_abi_getenv + fprintf) removed — mirror foundation Class AD. */
  ast_arena_expr_set(arena, ref, e);
}

/* Class AE: zeros authority = pthin_foundation.x (P20b) / foundation seed; no per-slice host-cc twin. */
void parser_asm_expr_set_common_zeros_c(struct parser_asm_ast_expr *e);

extern void parser_asm_lex_from_result_val_into(struct parser_asm_lexer *out, struct parser_asm_lexer_result r);
extern struct parser_asm_lexer parser_asm_lex_at_token_from_result_c(struct parser_asm_lexer_result r);

#ifdef XLANG_PTHIN_EXPR_PRIMARY_BODIES_FROM_X
/* PLATFORM: SHARED — 7.2.1 P4b Route C (2026-09-13).
 * Slice ABI stays in this TU; buf-path bodies live in pthin_expr_primary.x. */
extern int32_t parser_asm_primary_ident_is_unsafe_buf_c(uint8_t *data, size_t length, size_t token_start,
                                                       int32_t ident_len);
extern int32_t parser_asm_primary_ident_is_asm_buf_c(uint8_t *data, size_t length, size_t token_start,
                                                    int32_t ident_len);
extern int32_t parser_asm_primary_ident_is_in_buf_c(uint8_t *data, size_t length, size_t token_start,
                                                   int32_t ident_len);
extern int32_t parser_asm_primary_ident_is_out_buf_c(uint8_t *data, size_t length, size_t token_start,
                                                    int32_t ident_len);
extern int32_t parser_asm_primary_ident_is_lateout_buf_c(uint8_t *data, size_t length, size_t token_start,
                                                        int32_t ident_len);
extern int32_t parser_asm_primary_ident_is_options_buf_c(uint8_t *data, size_t length, size_t token_start,
                                                        int32_t ident_len);
extern int32_t parser_asm_primary_asm_option_bit_buf_c(uint8_t *data, size_t length, size_t token_start,
                                                      int32_t ident_len);
extern int32_t parser_asm_primary_ident_is_asm_option_name_buf_c(uint8_t *data, size_t length, size_t token_start,
                                                                int32_t ident_len);

static int32_t parser_asm_primary_ident_is_unsafe_c(struct parser_asm_slice_u8 *source, size_t token_start,
                                                    int32_t ident_len) {
  if (!source)
    return 0;
  return parser_asm_primary_ident_is_unsafe_buf_c(source->data, source->length, token_start, ident_len);
}
static int32_t parser_asm_primary_ident_is_asm_c(struct parser_asm_slice_u8 *source, size_t token_start,
                                                 int32_t ident_len) {
  if (!source)
    return 0;
  return parser_asm_primary_ident_is_asm_buf_c(source->data, source->length, token_start, ident_len);
}
static int32_t parser_asm_primary_ident_is_in_c(struct parser_asm_slice_u8 *source, size_t token_start,
                                                int32_t ident_len) {
  if (!source)
    return 0;
  return parser_asm_primary_ident_is_in_buf_c(source->data, source->length, token_start, ident_len);
}
static int32_t parser_asm_primary_ident_is_out_c(struct parser_asm_slice_u8 *source, size_t token_start,
                                                 int32_t ident_len) {
  if (!source)
    return 0;
  return parser_asm_primary_ident_is_out_buf_c(source->data, source->length, token_start, ident_len);
}
static int32_t parser_asm_primary_ident_is_lateout_c(struct parser_asm_slice_u8 *source, size_t token_start,
                                                     int32_t ident_len) {
  if (!source)
    return 0;
  return parser_asm_primary_ident_is_lateout_buf_c(source->data, source->length, token_start, ident_len);
}
static int32_t parser_asm_primary_ident_is_options_c(struct parser_asm_slice_u8 *source, size_t token_start,
                                                     int32_t ident_len) {
  if (!source)
    return 0;
  return parser_asm_primary_ident_is_options_buf_c(source->data, source->length, token_start, ident_len);
}
static int32_t parser_asm_primary_asm_option_bit_c(struct parser_asm_slice_u8 *source, size_t token_start,
                                                    int32_t ident_len) {
  if (!source)
    return 0;
  return parser_asm_primary_asm_option_bit_buf_c(source->data, source->length, token_start, ident_len);
}
static int32_t parser_asm_primary_ident_is_asm_option_name_c(struct parser_asm_slice_u8 *source, size_t token_start,
                                                             int32_t ident_len) {
  if (!source)
    return 0;
  return parser_asm_primary_ident_is_asm_option_name_buf_c(source->data, source->length, token_start, ident_len);
}
#endif /* XLANG_PTHIN_EXPR_PRIMARY_BODIES_FROM_X */

/* struct_lit first: primary uses static parse_struct_lit_fields_c from this slice. */
#include "parser_asm_finish_struct_lit_slice.inc"
#include "parser_asm_primary_slice.inc"

_Static_assert((int)TOKEN_INT == 80, "primary.x TOKEN_INT pin");
_Static_assert((int)TOKEN_FLOAT == 81, "primary.x TOKEN_FLOAT pin");
_Static_assert((int)TOKEN_IF == 4, "primary.x TOKEN_IF pin");
_Static_assert((int)TOKEN_RETURN == 11, "primary.x TOKEN_RETURN pin");
_Static_assert((int)TOKEN_PANIC == 12, "primary.x TOKEN_PANIC pin");
_Static_assert((int)TOKEN_MATCH == 18, "primary.x TOKEN_MATCH pin");
_Static_assert((int)TOKEN_LPAREN == 82, "primary.x TOKEN_LPAREN pin");
_Static_assert((int)TOKEN_RPAREN == 83, "primary.x TOKEN_RPAREN pin");
_Static_assert((int)TOKEN_LBRACE == 84, "primary.x TOKEN_LBRACE pin");
_Static_assert((int)TOKEN_RBRACE == 85, "primary.x TOKEN_RBRACE pin");
_Static_assert((int)TOKEN_LBRACKET == 86, "primary.x TOKEN_LBRACKET pin");
_Static_assert((int)TOKEN_RBRACKET == 87, "primary.x TOKEN_RBRACKET pin");
_Static_assert((int)TOKEN_FATARROW == 89, "primary.x TOKEN_FATARROW pin");
_Static_assert((int)TOKEN_COMMA == 90, "primary.x TOKEN_COMMA pin");
_Static_assert((int)TOKEN_COLON == 91, "primary.x TOKEN_COLON pin");
_Static_assert((int)TOKEN_SEMICOLON == 95, "primary.x TOKEN_SEMICOLON pin");
_Static_assert((int)TOKEN_AT == 129, "primary.x TOKEN_AT pin");
_Static_assert((int)TOKEN_STRING == 130, "primary.x TOKEN_STRING pin");
_Static_assert(PARSER_ASM_EXPR_BLOCK == 26, "primary.x EXPR_BLOCK pin");
_Static_assert(PARSER_ASM_EXPR_RETURN == 41, "primary.x EXPR_RETURN pin");
_Static_assert(PARSER_ASM_EXPR_PANIC == 42, "primary.x EXPR_PANIC pin");
_Static_assert(PARSER_ASM_EXPR_ARRAY_LIT == 46, "primary.x EXPR_ARRAY_LIT pin");
_Static_assert(PARSER_ASM_EXPR_STRING_LIT == 59, "primary.x EXPR_STRING_LIT pin");

int labi_pthin_expr_primary_slice_marker(void) {
  return 2; /* finish_struct_lit + primary */
}
