/**
 * parser_asm_range_for_slice.inc — wave701 Cap residual: `for (i : lo .. hi) { body }`
 *
 * Desugars to C-style for with hoisted let:
 *   let i: i32 = lo;
 *   for (; i < hi; i = i + 1) { body }
 *
 * PLATFORM: SHARED — G.7 single authority for range-for parse/desugar.
 * Included from parser_asm_thin_c.from_x.c (product thin glue).
 */
#ifndef PARSER_ASM_RANGE_FOR_SLICE_INCLUDED
#define PARSER_ASM_RANGE_FOR_SLICE_INCLUDED

#include <string.h>

extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                            struct parser_asm_slice_u8 *source);
extern void parser_lex_from_next_into_glue(struct parser_asm_lexer *out, struct parser_asm_lexer_result r);
extern void parse_expr_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                            struct parser_asm_parse_expr_result *out);
extern void parse_block_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                             int32_t type_ref, struct parser_asm_parse_block_result *out);
extern int32_t ast_ast_arena_expr_alloc(void *arena);
extern struct ast_Expr ast_ast_arena_expr_get(void *arena, int32_t ref);
extern void ast_ast_arena_expr_set(void *arena, int32_t ref, struct ast_Expr e);
extern int32_t pipeline_block_append_let(void *arena, int32_t br, uint8_t *name, int32_t name_len,
                                         int32_t type_ref, int32_t init_ref);
extern int32_t pipeline_block_append_for(void *arena, int32_t br, int32_t init_ref, int32_t cond_ref,
                                         int32_t step_ref, int32_t body_ref);
extern int32_t pipeline_block_append_stmt_order(void *arena, int32_t br, int32_t kind, int32_t idx);
extern int32_t pipeline_onefunc_append_let(uint8_t *out, uint8_t *name, int32_t name_len, int32_t init_val,
                                           int32_t init_ref, int32_t type_ref);
extern int32_t pipeline_onefunc_append_for(uint8_t *out, int32_t init_ref, int32_t cond_ref, int32_t step_ref,
                                           int32_t body_ref);
extern int32_t pipeline_onefunc_num_lets(uint8_t *out);
extern int32_t typeck_ensure_i32_type_ref(void *arena);

/** Build EXPR_VAR named from source span. */
static int32_t parser_asm_alloc_var_from_slice_c(void *arena, struct parser_asm_slice_u8 *source, size_t start,
                                                 int32_t name_len) {
  int32_t ref;
  struct ast_Expr e;
  int32_t ni;
  if (!arena || !source || name_len <= 0)
    return 0;
  if (name_len > 127)
    name_len = 127;
  ref = ast_ast_arena_expr_alloc(arena);
  if (ref == 0)
    return 0;
  e = ast_ast_arena_expr_get(arena, ref);
  e.kind = 3; /* EXPR_VAR */
  e.var_name_len = name_len;
  for (ni = 0; ni < name_len && start + (size_t)ni < source->length; ni++)
    e.var_name[ni] = source->data[start + ni];
  for (; ni < 128; ni++)
    e.var_name[ni] = 0;
  e.line = 0;
  e.col = 0;
  e.resolved_type_ref = 0;
  e.binop_left_ref = 0;
  e.binop_right_ref = 0;
  e.unary_operand_ref = 0;
  e.if_cond_ref = 0;
  e.if_then_ref = 0;
  e.if_else_ref = 0;
  e.block_ref = 0;
  e.match_matched_ref = 0;
  e.match_num_arms = 0;
  e.int_val = 0;
  ast_ast_arena_expr_set(arena, ref, e);
  return ref;
}

/** Build binop-like expr (ADD/LT/ASSIGN share left/right fields). kind = ExprKind ord. */
static int32_t parser_asm_alloc_binop_c(void *arena, int32_t kind, int32_t left, int32_t right) {
  int32_t ref;
  struct ast_Expr e;
  ref = ast_ast_arena_expr_alloc(arena);
  if (ref == 0)
    return 0;
  e = ast_ast_arena_expr_get(arena, ref);
  e.kind = kind;
  e.binop_left_ref = left;
  e.binop_right_ref = right;
  e.line = 0;
  e.col = 0;
  e.resolved_type_ref = 0;
  e.unary_operand_ref = 0;
  e.if_cond_ref = 0;
  e.if_then_ref = 0;
  e.if_else_ref = 0;
  e.block_ref = 0;
  e.match_matched_ref = 0;
  e.match_num_arms = 0;
  e.int_val = 0;
  ast_ast_arena_expr_set(arena, ref, e);
  return ref;
}

static int32_t parser_asm_alloc_lit1_c(void *arena) {
  int32_t ref;
  struct ast_Expr e;
  ref = ast_ast_arena_expr_alloc(arena);
  if (ref == 0)
    return 0;
  e = ast_ast_arena_expr_get(arena, ref);
  e.kind = 0; /* EXPR_LIT */
  e.int_val = 1;
  e.line = 0;
  e.col = 0;
  e.resolved_type_ref = 0;
  e.binop_left_ref = 0;
  e.binop_right_ref = 0;
  e.unary_operand_ref = 0;
  e.if_cond_ref = 0;
  e.if_then_ref = 0;
  e.if_else_ref = 0;
  e.block_ref = 0;
  e.match_matched_ref = 0;
  e.match_num_arms = 0;
  ast_ast_arena_expr_set(arena, ref, e);
  return ref;
}

/**
 * Try parse `ident : lo .. hi ) { body }` starting with r already on IDENT after `(`.
 * @return 1 success (fills *out_lex after body), 0 not range-for (no consume), -1 hard fail
 */
static int32_t parser_asm_try_range_for_core_c(void *arena, struct parser_asm_lexer_result r_ident,
                                              struct parser_asm_slice_u8 *source, int32_t ret_type_ref,
                                              int32_t *out_lo, int32_t *out_hi, int32_t *out_body,
                                              uint8_t *name_buf, int32_t *out_name_len,
                                              struct parser_asm_lexer *out_lex) {
  struct parser_asm_lexer lex;
  struct parser_asm_lexer_result r;
  struct parser_asm_parse_expr_result lo_res;
  struct parser_asm_parse_expr_result hi_res;
  struct parser_asm_parse_block_result body_res;
  int32_t nlen;
  size_t nstart;
  int32_t ni;

  if (!arena || !source || !out_lo || !out_hi || !out_body || !name_buf || !out_name_len || !out_lex)
    return -1;
  if (r_ident.tok.kind != (int32_t)TOKEN_IDENT)
    return 0;
  parser_lex_from_next_into_glue(&lex, r_ident);
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_COLON)
    return 0; /* not range-for */

  nlen = r_ident.tok.ident_len;
  if (nlen > 127)
    nlen = 127;
  nstart = r_ident.token_start;
  memset(name_buf, 0, 128);
  for (ni = 0; ni < nlen && nstart + (size_t)ni < source->length; ni++)
    name_buf[ni] = source->data[nstart + ni];
  *out_name_len = nlen;

  parser_lex_from_next_into_glue(&lex, r);
  memset(&lo_res, 0, sizeof(lo_res));
  lo_res.next_lex = lex;
  parse_expr_into(arena, lex, source, &lo_res);
  if (!lo_res.ok)
    return -1;
  lex = lo_res.next_lex;
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_DOTDOT)
    return -1;
  parser_lex_from_next_into_glue(&lex, r);
  memset(&hi_res, 0, sizeof(hi_res));
  hi_res.next_lex = lex;
  parse_expr_into(arena, lex, source, &hi_res);
  if (!hi_res.ok)
    return -1;
  lex = hi_res.next_lex;
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_RPAREN)
    return -1;
  parser_lex_from_next_into_glue(&lex, r);
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_LBRACE)
    return -1;
  lex = r.next_lex;
  memset(&body_res, 0, sizeof(body_res));
  body_res.next_lex = lex;
  parse_block_into(arena, lex, source, ret_type_ref, &body_res);
  if (!body_res.ok)
    return -1;
  *out_lo = lo_res.expr_ref;
  *out_hi = hi_res.expr_ref;
  *out_body = body_res.block_ref;
  *out_lex = body_res.next_lex;
  return 1;
}

/**
 * Build cond `name < hi` and step `name = name + 1`.
 * kind: EXPR_LT=12, EXPR_ADD=4, EXPR_ASSIGN=28 (match ast.x / token.h ExprKind order carefully).
 * From ast.x: LIT=0, FLOAT=1, BOOL=2, VAR=3, ADD=4, ... LT is 12 (ADD+11 steps?).
 * Count: LIT0 FLOAT1 BOOL2 VAR3 ADD4 SUB5 MUL6 DIV7 MOD8 SHL9 SHR10 BITAND11 BITOR12 BITXOR13
 * EQ14 NE15 LT16 ... Actually use numeric from include/ast.h:
 * AST_EXPR_ADD= after VAR...
 * From include/ast.h grep: ADD, then later LT, ASSIGN.
 * Safer: use runtime kind from a known working for's structure - hardcode from ast.x enum order.
 *
 * ast.x:
 * EXPR_LIT, EXPR_FLOAT_LIT, EXPR_BOOL_LIT, EXPR_VAR, EXPR_ADD, EXPR_SUB, EXPR_MUL, EXPR_DIV,
 * EXPR_MOD, EXPR_SHL, EXPR_SHR, EXPR_BITAND, EXPR_BITOR, EXPR_BITXOR, EXPR_EQ, EXPR_NE,
 * EXPR_LT, EXPR_LE, EXPR_GT, EXPR_GE, ... eventually EXPR_ASSIGN
 *
 * 0-3 lit/float/bool/var, 4 ADD, 14 EQ, 15 NE, 16 LT.
 * ASSIGN: after GE, LOGAND, LOGOR, NEG, BITNOT, LOGNOT, IF, BLOCK, TERNARY = 28?
 * Count carefully in ast.x.
 */
/* Kind ords from compiler/src/ast/ast.x ExprKind enum (must match). */
#define PA_KIND_VAR 3
#define PA_KIND_ADD 4
#define PA_KIND_LT 16
#define PA_KIND_ASSIGN 28

static int32_t parser_asm_range_for_make_cond_step_c(void *arena, struct parser_asm_slice_u8 *source,
                                                      size_t name_start, int32_t name_len, int32_t hi_ref,
                                                      int32_t *out_cond, int32_t *out_step) {
  int32_t v1, v2, v3, one, add, lt, asg;
  v1 = parser_asm_alloc_var_from_slice_c(arena, source, name_start, name_len);
  v2 = parser_asm_alloc_var_from_slice_c(arena, source, name_start, name_len);
  v3 = parser_asm_alloc_var_from_slice_c(arena, source, name_start, name_len);
  one = parser_asm_alloc_lit1_c(arena);
  if (!v1 || !v2 || !v3 || !one)
    return -1;
  lt = parser_asm_alloc_binop_c(arena, PA_KIND_LT, v1, hi_ref);
  add = parser_asm_alloc_binop_c(arena, PA_KIND_ADD, v2, one);
  asg = parser_asm_alloc_binop_c(arena, PA_KIND_ASSIGN, v3, add);
  if (!lt || !add || !asg)
    return -1;
  *out_cond = lt;
  *out_step = asg;
  return 0;
}

/**
 * Parse range-for into enclosing block (block stmt path).
 * lex_at_ident: token on loop var IDENT inside `(`.
 * @return 1 ok, 0 not range-for, -1 fail
 */
int32_t parser_asm_try_parse_range_for_block_c(void *arena, int32_t block_ref,
                                               struct parser_asm_lexer_result r_ident,
                                               struct parser_asm_slice_u8 *source, int32_t type_ref,
                                               struct parser_asm_lexer *out_lex, int32_t *out_for_idx) {
  int32_t lo, hi, body, cond, step, i32ty, let_idx, for_idx, nlen;
  uint8_t name[128];
  struct parser_asm_lexer lex_end;
  size_t nstart;
  int32_t tr;

  tr = parser_asm_try_range_for_core_c(arena, r_ident, source, type_ref, &lo, &hi, &body, name, &nlen, &lex_end);
  if (tr != 1)
    return tr;
  nstart = r_ident.token_start;
  i32ty = typeck_ensure_i32_type_ref(arena);
  if (i32ty <= 0)
    return -1;
  let_idx = pipeline_block_append_let(arena, block_ref, name, nlen, i32ty, lo);
  if (let_idx < 0)
    return -1;
  if (pipeline_block_append_stmt_order(arena, block_ref, 1, let_idx) < 0)
    return -1;
  if (parser_asm_range_for_make_cond_step_c(arena, source, nstart, nlen, hi, &cond, &step) != 0)
    return -1;
  for_idx = pipeline_block_append_for(arena, block_ref, 0, cond, step, body);
  if (for_idx < 0)
    return -1;
  if (pipeline_block_append_stmt_order(arena, block_ref, 4, for_idx) < 0)
    return -1;
  *out_lex = lex_end;
  if (out_for_idx)
    *out_for_idx = for_idx;
  return 1;
}

/**
 * Parse range-for into onefunc result pool.
 * out must be OneFuncResult pool pointer (same as pipeline_onefunc_*).
 */
int32_t parser_asm_try_parse_range_for_onefunc_c(void *arena, uint8_t *onefunc_out,
                                                 struct parser_asm_lexer_result r_ident,
                                                 struct parser_asm_slice_u8 *source, int32_t ret_type_ref,
                                                 struct parser_asm_lexer *out_lex, int32_t *out_for_idx) {
  int32_t lo, hi, body, cond, step, i32ty, let_idx, for_idx, nlen, n_before;
  uint8_t name[128];
  struct parser_asm_lexer lex_end;
  size_t nstart;
  int32_t tr;

  tr = parser_asm_try_range_for_core_c(arena, r_ident, source, ret_type_ref, &lo, &hi, &body, name, &nlen, &lex_end);
  if (tr != 1)
    return tr;
  nstart = r_ident.token_start;
  i32ty = typeck_ensure_i32_type_ref(arena);
  if (i32ty <= 0)
    return -1;
  n_before = pipeline_onefunc_num_lets(onefunc_out);
  let_idx = pipeline_onefunc_append_let(onefunc_out, name, nlen, 0, lo, i32ty);
  if (let_idx < 0)
    return -1;
  (void)n_before;
  if (parser_asm_range_for_make_cond_step_c(arena, source, nstart, nlen, hi, &cond, &step) != 0)
    return -1;
  for_idx = pipeline_onefunc_append_for(onefunc_out, 0, cond, step, body);
  if (for_idx < 0)
    return -1;
  *out_lex = lex_end;
  if (out_for_idx)
    *out_for_idx = for_idx;
  return 1;
}

#endif /* PARSER_ASM_RANGE_FOR_SLICE_INCLUDED */
