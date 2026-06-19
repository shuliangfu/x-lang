/**
 * parser_asm_finish_struct_lit_slice.c — finish_struct_lit_from_type_ident_into C 实现。
 *
 * 由 parser_asm_thin_c.c #include（须在 body_let_slice 之后）；勿单独编译。
 * TypeName { a: e1 , b: e2 } 后缀字段填充；回调 parse_expr_into SU mega。
 */
#ifndef PARSER_ASM_FINISH_STRUCT_LIT_SLICE_INCLUDED
#define PARSER_ASM_FINISH_STRUCT_LIT_SLICE_INCLUDED

extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                            struct parser_asm_slice_u8 *source);
extern void parser_lex_from_next_into_glue(struct parser_asm_lexer *out, struct parser_asm_lexer_result r);
extern void parse_expr_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                            struct parser_asm_parse_expr_result *out);
extern int32_t pipeline_expr_append_struct_lit_field(void *arena, int32_t expr_ref, uint8_t *name_bytes,
                                                     int32_t name_len, int32_t init_ref);
extern struct ast_Expr ast_ast_arena_expr_get(void *arena, int32_t ref);
extern void ast_ast_arena_expr_set(void *arena, int32_t ref, struct ast_Expr e);
extern int32_t parser_asm_stretch_struct_lit_deep_audit_c(struct parser_asm_lexer lex,
                                                          struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_struct_lit_fields_probe_c(struct parser_asm_lexer lex,
                                                             struct parser_asm_slice_u8 *source,
                                                             int32_t *out_field_count);
extern int32_t parser_asm_stretch_struct_lit_fields_body_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);

/** EXPR_STRUCT_LIT 序值（与 ast.sx ExprKind 一致）。 */
#define PARSER_ASM_FINISH_STRUCT_LIT_KIND 77

/** expr_set_common_zeros：与 parser.sx 字段清零顺序一致。 */
static void parser_asm_finish_struct_lit_common_zeros_c(struct ast_Expr *e) {
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

/**
 * finish_struct_lit_from_type_ident_into：lit_ref 为 IDENT 占位；lex_in_brace 为 `{` 后 lexer。
 * 成功写 out.expr_ref 为 EXPR_STRUCT_LIT。
 */
void parser_asm_finish_struct_lit_from_type_ident_into_c(void *arena, int32_t lit_ref,
                                                         struct parser_asm_lexer lex_in_brace,
                                                         struct parser_asm_slice_u8 *source,
                                                         struct parser_asm_parse_expr_result *out) {
  struct ast_Expr le;
  int32_t tlen;
  uint8_t tnm[64];
  int32_t ti;
  int32_t tj;
  struct parser_asm_lexer lex;
  struct parser_asm_lexer_result rf;
  int32_t flen;
  uint8_t fnbuf[64];
  size_t fs;
  int32_t fq;
  struct parser_asm_parse_expr_result fv;
  if (!arena || !source || !out)
    return;
  out->ok = 0;
  if (lit_ref == 0)
    return;
  le = ast_ast_arena_expr_get(arena, lit_ref);
  tlen = le.var_name_len;
  if (tlen <= 0 || tlen > 63)
    return;
  ti = 0;
  while (ti < 64) {
    tnm[ti] = le.var_name[ti];
    ti = ti + 1;
  }
  parser_asm_finish_struct_lit_common_zeros_c(&le);
  le.kind = PARSER_ASM_FINISH_STRUCT_LIT_KIND;
  le.struct_lit_struct_name_len = tlen;
  tj = 0;
  while (tj < 64) {
    le.struct_lit_struct_name[tj] = tnm[tj];
    tj = tj + 1;
  }
  le.struct_lit_field_base = 0;
  le.struct_lit_num_fields = 0;
  le.line = 0;
  le.col = 0;
  le.int_val = 0;
  le.float_val = 0.0;
  ast_ast_arena_expr_set(arena, lit_ref, le);
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_lit_fields_body_audit_c(lex_in_brace, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_lit_fields_probe_c(lex_in_brace, source, 0));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_lit_deep_audit_c(lex_in_brace, source));
  lex = lex_in_brace;
  for (;;) {
    memset(&rf, 0, sizeof(rf));
    rf.next_lex = lex;
    lexer_next_into(&rf, lex, source);
    if (rf.tok.kind == (int32_t)TOKEN_RBRACE) {
      out->ok = 1;
      out->expr_ref = lit_ref;
      out->next_lex = rf.next_lex;
      return;
    }
    if (rf.tok.kind != (int32_t)TOKEN_IDENT)
      return;
    flen = rf.tok.ident_len;
    if (flen <= 0 || flen > 63)
      return;
    fs = rf.token_start;
    fq = 0;
    while (fq < flen && fq < 64) {
      size_t idx_fs;
      idx_fs = fs + (size_t)fq;
      if (idx_fs >= source->length)
        break;
      fnbuf[fq] = source->data[idx_fs];
      fq = fq + 1;
    }
    while (fq < 64) {
      fnbuf[fq] = 0;
      fq = fq + 1;
    }
    parser_lex_from_next_into_glue(&lex, rf);
    lexer_next_into(&rf, lex, source);
    if (rf.tok.kind != (int32_t)TOKEN_COLON)
      return;
    lex = rf.next_lex;
    memset(&fv, 0, sizeof(fv));
    fv.next_lex = lex;
    parse_expr_into(arena, lex, source, &fv);
    if (!fv.ok || fv.expr_ref <= 0)
      return;
    if (pipeline_expr_append_struct_lit_field(arena, lit_ref, fnbuf, flen, fv.expr_ref) < 0)
      return;
    lex = fv.next_lex;
    lexer_next_into(&rf, lex, source);
    if (rf.tok.kind == (int32_t)TOKEN_COMMA) {
      lex = rf.next_lex;
      continue;
    }
    if (rf.tok.kind == (int32_t)TOKEN_RBRACE) {
      out->ok = 1;
      out->expr_ref = lit_ref;
      out->next_lex = rf.next_lex;
      return;
    }
    return;
  }
}

#endif /* PARSER_ASM_FINISH_STRUCT_LIT_SLICE_INCLUDED */
