/* seeds/pthin_expr_primary.from_x.c — G-02f-282 P2 parser thin P4 primary
 * Logic source: src/asm/pthin_expr_primary.x
 * Hybrid: XLANG_PTHIN_EXPR_PRIMARY_FROM_X + ld -r into parser_asm_thin_glue.o
 *
 * Bodies: finish_struct_lit_slice.inc + primary_slice.inc
 * (primary calls static parse_struct_lit_fields — same TU required)
 * Types must match parser_asm_thin_c.from_x.c (layout-locked).
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser_asm_stretch_audit_gate.h"
#include "token.h"
#include "diag.h"

/* wave244 G.7: env via public pure thin link_abi_getenv (wave222 → _impl host getenv);
 * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl.
 * PLATFORM: SHARED orch / host getenv residual via single face.
 * Compiler-only TU (parser thin glue) — not in user STD_AND_PANIC bag. */
extern char *link_abi_getenv(const char *name);

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
  int32_t call_num_type_args;
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

struct ast_Expr {
  int32_t kind;
  int32_t resolved_type_ref;
  int32_t line;
  int32_t col;
  int64_t int_val;
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
  int32_t call_num_type_args;
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

extern struct ast_Expr ast_arena_expr_get(void *arena, int32_t ref);
extern void ast_arena_expr_set(void *arena, int32_t ref, struct ast_Expr e);

/* get 非 static 在 mega rest；hybrid 时本 TU 仅声明，避免 ld -r 双定义。 */
struct parser_asm_ast_expr parser_asm_arena_expr_get_c(void *arena, int32_t ref);

/* primary_slice.inc 期望 static set/zeros 同 TU（mega 中亦为 static）。 */
static void parser_asm_arena_expr_set_c(void *arena, int32_t ref, struct parser_asm_ast_expr ae) {
  struct ast_Expr e;
  const char *trace_name;
  const char *trace_type;
  int trace_ty;
  int trace_hit;
  memcpy(&e, &ae, sizeof(e));
  trace_name = link_abi_getenv("XLANG_TRACE_EXPR_NAME");
  trace_type = link_abi_getenv("XLANG_TRACE_TYPE_REF");
  trace_ty = 0;
  trace_hit = 0;
  if (trace_name && *trace_name && e.var_name_len > 0) {
    size_t want_len = strlen(trace_name);
    if ((int32_t)want_len == e.var_name_len && want_len < sizeof(e.var_name) &&
        memcmp(e.var_name, trace_name, want_len) == 0)
      trace_hit = 1;
  }
  if (trace_type && *trace_type) {
    trace_ty = atoi(trace_type);
    if (trace_ty != 0 && e.resolved_type_ref == trace_ty)
      trace_hit = 1;
  }
  if (trace_hit) {
    fprintf(stderr,
            "note: parser expr watch: expr=%d kind=%d block=%d ty=%d left=%d right=%d name_len=%d name=%.*s\n",
            (int)ref, (int)e.kind, (int)e.block_ref, (int)e.resolved_type_ref, (int)e.binop_left_ref,
            (int)e.binop_right_ref, (int)e.var_name_len, (int)e.var_name_len, (const char *)e.var_name);
  }
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

extern void parser_asm_lex_from_result_val_into(struct parser_asm_lexer *out, struct parser_asm_lexer_result r);
extern struct parser_asm_lexer parser_asm_lex_at_token_from_result_c(struct parser_asm_lexer_result r);

/* struct_lit first: primary uses static parse_struct_lit_fields_c from this slice. */
#include "parser_asm_finish_struct_lit_slice.inc"
#include "parser_asm_primary_slice.inc"

int labi_pthin_expr_primary_slice_marker(void) {
  return 2; /* finish_struct_lit + primary */
}
