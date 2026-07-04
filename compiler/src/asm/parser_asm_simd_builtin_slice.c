/**
 * parser_asm_simd_builtin_slice.c — parse_at_simd_builtin_into C 实现。
 *
 * 由 parser_asm_thin_c.c #include；勿单独编译。
 * 解析 @shuffle(v, mask) / @select(mask, a, b) → CALL simd_shuffle/simd_select。
 */
#ifndef PARSER_ASM_SIMD_BUILTIN_SLICE_INCLUDED
#define PARSER_ASM_SIMD_BUILTIN_SLICE_INCLUDED

extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                            struct parser_asm_slice_u8 *source);
extern void parse_expr_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                            struct parser_asm_parse_expr_result *out);
extern int32_t ast_ast_arena_expr_alloc(void *arena);
extern struct ast_Expr ast_ast_arena_expr_get(void *arena, int32_t ref);
extern void ast_ast_arena_expr_set(void *arena, int32_t ref, struct ast_Expr e);
extern int32_t pipeline_expr_append_call_arg(void *arena, int32_t expr_ref, int32_t arg_ref);
extern int32_t parser_asm_stretch_simd_builtin_deep_from_at_audit_c(struct parser_asm_lexer_result r_at,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_simd_builtin_deep_audit_c(struct parser_asm_lexer lex,
                                                          struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_simd_builtin_audit_c(struct parser_asm_lexer_result r_at,
                                                       struct parser_asm_slice_u8 *source);

/** expr_set_common_zeros：与 parser.x 字段清零顺序一致。 */
static void parser_asm_simd_expr_common_zeros_c(struct ast_Expr *e) {
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

/** 判断 ident 是否为 shuffle / select（与 parser.x 字节比较一致）。 */
static int32_t parser_asm_simd_builtin_kind_c(struct parser_asm_lexer_result *r, struct parser_asm_slice_u8 *source,
                                              int32_t *need_args_out, int32_t *is_shuffle_out) {
  int32_t nlen;
  size_t start;
  if (!r || !source || !need_args_out || !is_shuffle_out)
    return 0;
  nlen = r->tok.ident_len;
  start = r->token_start;
  if (nlen == 7 && start + 6 < source->length && source->data[start] == 115 && source->data[start + 1] == 104
      && source->data[start + 2] == 117 && source->data[start + 3] == 102 && source->data[start + 4] == 102
      && source->data[start + 5] == 108 && source->data[start + 6] == 101) {
    *is_shuffle_out = 1;
    *need_args_out = 2;
    return 1;
  }
  if (nlen == 6 && start + 5 < source->length && source->data[start] == 115 && source->data[start + 1] == 101
      && source->data[start + 2] == 108 && source->data[start + 3] == 101 && source->data[start + 4] == 99
      && source->data[start + 5] == 116) {
    *is_shuffle_out = 0;
    *need_args_out = 3;
    return 1;
  }
  return 0;
}

/**
 * parse_at_simd_builtin_into：r0 为 @ 后 LexerResult；成功写 out.expr_ref / out.next_lex。
 */
void parser_asm_parse_at_simd_builtin_into_c(void *arena, struct parser_asm_lexer_result r0,
                                           struct parser_asm_slice_u8 *source,
                                           struct parser_asm_parse_expr_result *out) {
  struct parser_asm_lexer lex;
  struct parser_asm_lexer_result r;
  int32_t callee_ref;
  int32_t need_args;
  int32_t is_shuffle;
  struct ast_Expr ce;
  int32_t ci;
  int32_t call_ref;
  struct ast_Expr call_e;
  int32_t got;
  struct parser_asm_parse_expr_result arg_res;
  if (!arena || !source || !out)
    return;
  out->ok = 0;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_simd_builtin_audit_c(r0, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_simd_builtin_deep_from_at_audit_c(r0, source));
  lex = r0.next_lex;
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_IDENT)
    return;
  if (!parser_asm_simd_builtin_kind_c(&r, source, &need_args, &is_shuffle))
    return;
  lex = r.next_lex;
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_LPAREN)
    return;
  lex = r.next_lex;
  callee_ref = ast_ast_arena_expr_alloc(arena);
  if (callee_ref == 0)
    return;
  ce = ast_ast_arena_expr_get(arena, callee_ref);
  ce.kind = 3; /* EXPR_VAR */
  parser_asm_simd_expr_common_zeros_c(&ce);
  if (is_shuffle) {
    ce.var_name[0] = 115;
    ce.var_name[1] = 105;
    ce.var_name[2] = 109;
    ce.var_name[3] = 100;
    ce.var_name[4] = 95;
    ce.var_name[5] = 115;
    ce.var_name[6] = 104;
    ce.var_name[7] = 117;
    ce.var_name[8] = 102;
    ce.var_name[9] = 102;
    ce.var_name[10] = 108;
    ce.var_name[11] = 101;
    ce.var_name_len = 12;
  } else {
    ce.var_name[0] = 115;
    ce.var_name[1] = 105;
    ce.var_name[2] = 109;
    ce.var_name[3] = 100;
    ce.var_name[4] = 95;
    ce.var_name[5] = 115;
    ce.var_name[6] = 101;
    ce.var_name[7] = 108;
    ce.var_name[8] = 101;
    ce.var_name[9] = 99;
    ce.var_name[10] = 116;
    ce.var_name_len = 11;
  }
  for (ci = ce.var_name_len; ci < 64; ci++)
    ce.var_name[ci] = 0;
  ast_ast_arena_expr_set(arena, callee_ref, ce);
  call_ref = ast_ast_arena_expr_alloc(arena);
  if (call_ref == 0)
    return;
  call_e = ast_ast_arena_expr_get(arena, call_ref);
  call_e.kind = 48; /* EXPR_CALL，与 ast.x ExprKind 序一致（勿用旧 +32 误值 80） */
  parser_asm_simd_expr_common_zeros_c(&call_e);
  call_e.call_callee_ref = callee_ref;
  ast_ast_arena_expr_set(arena, call_ref, call_e);
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_RPAREN) {
    got = 0;
    for (;;) {
      memset(&arg_res, 0, sizeof(arg_res));
      arg_res.next_lex = lex;
      parse_expr_into(arena, lex, source, &arg_res);
      if (!arg_res.ok)
        return;
      if (pipeline_expr_append_call_arg(arena, call_ref, arg_res.expr_ref) < 0)
        return;
      got = got + 1;
      lex = arg_res.next_lex;
      lexer_next_into(&r, lex, source);
      if (r.tok.kind == (int32_t)TOKEN_COMMA) {
        lex = r.next_lex;
        continue;
      }
      if (r.tok.kind == (int32_t)TOKEN_RPAREN) {
        lex = r.next_lex;
        break;
      }
      return;
    }
    if (got != need_args)
      return;
  } else {
    lex = r.next_lex;
    if (need_args != 0)
      return;
  }
  out->ok = 1;
  out->expr_ref = call_ref;
  out->next_lex = lex;
}

#endif /* PARSER_ASM_SIMD_BUILTIN_SLICE_INCLUDED */
