/**
 * parser_asm_finish_struct_lit_slice.inc — finish_struct_lit_from_type_ident_into C 实现。
 *
 * 由 parser_asm_thin_c.c #include（须在 body_let_slice 之后）；勿单独编译。
 * TypeName { a: e1 , b: e2 } 后缀字段填充；支持 STR-02 字段简写 `{ fd }` => `{ fd: fd }`；
 * 匿名 `{ a: e1 }` 字面量供 `let p: PollFd = { ... }` 使用。
 *
 * Hybrid P4bi: XLANG_PTHIN_EXPR_PRIMARY_BODIES_FROM_X skips
 * parse_struct_lit_fields (body in src/asm/pthin_expr_primary.x).
 * C trampolines hold name[256] (append/shorthand) and bump
 * struct_field_value_depth around parse_expr. P4bj anonymous alloc trampolines when
 * XLANG_PTHIN_EXPR_PRIMARY_ANON_STRUCT_FROM_X. P4bn finish_from_type_ident
 * trampolines when XLANG_PTHIN_EXPR_PRIMARY_FINISH_TYPE_IDENT_FROM_X
 * (C holds name[256]; writer = set_struct_lit_finish). Cold: no define, full twin.
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
extern int32_t ast_ast_arena_expr_alloc(void *arena);
extern int32_t parser_asm_stretch_struct_lit_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_lit_fields_probe_c(void *lex_inout, void *source, int32_t *out_field_count);
extern int32_t parser_asm_stretch_struct_lit_fields_body_audit_c(void *lex_inout, void *source);

/** EXPR_STRUCT_LIT 序值（与 ast.x / ast.h AST_EXPR_STRUCT_LIT 一致，须为 45 勿用源文件行号）。 */
#define PARSER_ASM_FINISH_STRUCT_LIT_KIND 45

/**
 * wave367 / PLATFORM: SHARED — nesting depth of parse_expr under STRUCT_LIT `field: expr`.
 * Shared with primary_slice empty IDENT {} disambiguation (same TU include order:
 * finish_struct_lit_slice.inc then primary_slice.inc).
 * When > 0, empty `Type {}` followed by outer `}` stays a struct lit (last field), not
 * bare if/while prefer-block (wave364). Bare ctrl empty bodies keep depth == 0.
 */
static int32_t parser_asm_struct_field_value_depth = 0;
/** EXPR_VAR 序值（与 ast.x / ast.h AST_EXPR_VAR 一致）。 */
#define PARSER_ASM_EXPR_VAR_KIND 3

/** expr_set_common_zeros：与 parser.x 字段清零顺序一致。 */
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
 * STR-02：为字段简写 `{ fd }` 分配 EXPR_VAR 初值（与字段名同名的变量引用）。
 */
static int32_t parser_asm_alloc_var_expr_from_field_name_c(void *arena, uint8_t *fnbuf, int32_t flen) {
  struct ast_Expr ve;
  int32_t vref;
  int32_t vi;
  /* wave583 Cap residual: field-shorthand VAR name content ≤255 (Expr.var_name[256]). */
  if (!arena || !fnbuf || flen <= 0 || flen > 255)
    return 0;
  vref = ast_ast_arena_expr_alloc(arena);
  if (vref == 0)
    return 0;
  ve = ast_ast_arena_expr_get(arena, vref);
  parser_asm_finish_struct_lit_common_zeros_c(&ve);
  ve.kind = PARSER_ASM_EXPR_VAR_KIND;
  ve.line = 0;
  ve.col = 0;
  ve.int_val = 0;
  ve.float_val = 0.0;
  ve.var_name_len = flen;
  vi = 0;
  while (vi < 128) {
    ve.var_name[vi] = (vi < flen) ? fnbuf[vi] : (uint8_t)0;
    vi = vi + 1;
  }
  ast_ast_arena_expr_set(arena, vref, ve);
  return vref;
}

/**
 * PLATFORM: SHARED — P4bi. C trampoline holds name[256] (language has
 * no local u8[N]) and forwards pipeline_expr_append_struct_lit_field.
 * Not a second wrap authority. Not static: .x lives in a separate TU.
 * ident_len<=0 or >255 fails (C twin; do not clamp 127).
 */
int32_t parser_asm_struct_lit_append_field_src_c(void *arena, int32_t lit_ref, struct parser_asm_slice_u8 *source,
                                                 size_t start, int32_t nlen, int32_t init_ref) {
  uint8_t name[256];
  int32_t ni;
  if (!arena || !source || lit_ref <= 0)
    return -1;
  if (nlen <= 0 || nlen > 255)
    return -1;
  memset(name, 0, sizeof(name));
  for (ni = 0; ni < nlen && start + (size_t)ni < source->length; ni++)
    name[ni] = source->data[start + ni];
  return pipeline_expr_append_struct_lit_field(arena, lit_ref, name, nlen, init_ref);
}

/**
 * PLATFORM: SHARED — P4bi shorthand `{ fd }` / `{ fd, x: 1 }`. Holds
 * name[256], allocs EXPR_VAR via the historical helper, then appends.
 * Not a second wrap authority.
 */
int32_t parser_asm_struct_lit_append_shorthand_src_c(void *arena, int32_t lit_ref, struct parser_asm_slice_u8 *source,
                                                     size_t start, int32_t nlen) {
  uint8_t name[256];
  int32_t ni;
  int32_t init_ref;
  if (!arena || !source || lit_ref <= 0)
    return -1;
  if (nlen <= 0 || nlen > 255)
    return -1;
  memset(name, 0, sizeof(name));
  for (ni = 0; ni < nlen && start + (size_t)ni < source->length; ni++)
    name[ni] = source->data[start + ni];
  init_ref = parser_asm_alloc_var_expr_from_field_name_c(arena, name, nlen);
  if (init_ref <= 0)
    return -1;
  return pipeline_expr_append_struct_lit_field(arena, lit_ref, name, nlen, init_ref);
}

/**
 * PLATFORM: SHARED — P4bi field-value parse_expr. Bumps
 * parser_asm_struct_field_value_depth around the historical by-value
 * parse_expr_into (wave367 empty Type {} vs prefer-block). Writes the
 * post-expr cursor back through lex_inout.
 */
int32_t parser_asm_struct_lit_parse_field_value_c(void *arena, void *lex_inout, void *source, int32_t *out_ok,
                                                 int32_t *out_expr_ref) {
  struct parser_asm_parse_expr_result res;
  struct parser_asm_lexer lex;
  if (!arena || !lex_inout || !source || !out_ok || !out_expr_ref)
    return 0;
  lex = *(struct parser_asm_lexer *)lex_inout;
  memset(&res, 0, sizeof(res));
  parser_asm_struct_field_value_depth = parser_asm_struct_field_value_depth + 1;
  parse_expr_into(arena, lex, (struct parser_asm_slice_u8 *)source, &res);
  parser_asm_struct_field_value_depth = parser_asm_struct_field_value_depth - 1;
  *out_ok = res.ok;
  *out_expr_ref = res.expr_ref;
  *(struct parser_asm_lexer *)lex_inout = res.next_lex;
  return 1;
}

/**
 * 从 `{` 之后 lexer 解析字段列表写入 lit_ref；成功时写 out->ok/expr_ref/next_lex。
 */
static void parser_asm_parse_struct_lit_fields_c(void *arena, int32_t lit_ref, struct parser_asm_lexer lex_in_brace,
                                                 struct parser_asm_slice_u8 *source,
                                                 struct parser_asm_parse_expr_result *out) {
#ifdef XLANG_PTHIN_EXPR_PRIMARY_BODIES_FROM_X
  /* PLATFORM: SHARED — P4bi trampoline. lex_in_brace sits after `{`
   * (caller already consumed LBRACE). .x peeks from a local copy.
   * On success out->next_lex is parked after `}`. C trampoline keeps
   * AUDIT (product AUDIT_CALL is nop). */
  {
    extern int32_t parser_asm_parse_struct_lit_fields_x_into_c(void *arena, int32_t lit_ref, void *lex_inout,
                                                              void *source, int32_t *out_ok, int32_t *out_expr_ref);
    struct parser_asm_lexer cur;
    int32_t ok;
    int32_t ref;
    if (!arena || !source || !out || lit_ref == 0)
      return;
    out->ok = 0;
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_lit_fields_body_audit_c(&lex_in_brace, source));
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_lit_fields_probe_c(&lex_in_brace, source, 0));
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_lit_deep_audit_c(&lex_in_brace, source));
    cur = lex_in_brace;
    ok = 0;
    ref = 0;
    if (parser_asm_parse_struct_lit_fields_x_into_c(arena, lit_ref, &cur, source, &ok, &ref) == 0 || ok == 0)
      return;
    out->ok = 1;
    out->expr_ref = ref;
    out->next_lex = cur;
    return;
  }
#else
  struct parser_asm_lexer lex;
  struct parser_asm_lexer_result rf;
  int32_t flen;
  /* Cap 4.2.8: struct-lit field name content ≤255; local fill must match name[256]. */
  uint8_t fnbuf[256];
  size_t fs;
  int32_t fq;
  struct parser_asm_parse_expr_result fv;
  int32_t init_ref;
  if (!arena || !source || !out || lit_ref == 0)
    return;
  out->ok = 0;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_lit_fields_body_audit_c(&lex_in_brace, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_lit_fields_probe_c(&lex_in_brace, source, 0));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_lit_deep_audit_c(&lex_in_brace, source));
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
    if (flen <= 0 || flen > 255)
      return;
    fs = rf.token_start;
    fq = 0;
    while (fq < flen && fq < 256) {
      size_t idx_fs;
      idx_fs = fs + (size_t)fq;
      if (idx_fs >= source->length)
        break;
      fnbuf[fq] = source->data[idx_fs];
      fq = fq + 1;
    }
    while (fq < 256) {
      fnbuf[fq] = 0;
      fq = fq + 1;
    }
    parser_lex_from_next_into_glue(&lex, rf);
    lexer_next_into(&rf, lex, source);
    if (rf.tok.kind == (int32_t)TOKEN_COLON) {
      /** 显式 `field: expr` */
      lex = rf.next_lex;
      memset(&fv, 0, sizeof(fv));
      fv.next_lex = lex;
      /* wave367: mark field-value so empty Type {} before outer `}` keeps struct lit. */
      parser_asm_struct_field_value_depth = parser_asm_struct_field_value_depth + 1;
      parse_expr_into(arena, lex, source, &fv);
      parser_asm_struct_field_value_depth = parser_asm_struct_field_value_depth - 1;
      if (!fv.ok || fv.expr_ref <= 0)
        return;
      init_ref = fv.expr_ref;
      lex = fv.next_lex;
    } else if (rf.tok.kind == (int32_t)TOKEN_COMMA || rf.tok.kind == (int32_t)TOKEN_RBRACE) {
      /** STR-02 字段简写：`{ fd }` / `{ fd, x: 1 }` */
      init_ref = parser_asm_alloc_var_expr_from_field_name_c(arena, fnbuf, flen);
      if (init_ref <= 0)
        return;
      if (pipeline_expr_append_struct_lit_field(arena, lit_ref, fnbuf, flen, init_ref) < 0)
        return;
      if (rf.tok.kind == (int32_t)TOKEN_RBRACE) {
        out->ok = 1;
        out->expr_ref = lit_ref;
        out->next_lex = rf.next_lex;
        return;
      }
      lex = rf.next_lex;
      continue;
    } else {
      return;
    }
    if (pipeline_expr_append_struct_lit_field(arena, lit_ref, fnbuf, flen, init_ref) < 0)
      return;
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
#endif /* XLANG_PTHIN_EXPR_PRIMARY_BODIES_FROM_X parse_struct_lit_fields */
}

/**
 * 匿名 struct 字面量 `{ field: expr , ... }`；`lex_in_brace` 位于 `{` 之后。
 */
#ifdef XLANG_PTHIN_EXPR_PRIMARY_ANON_STRUCT_FROM_X
extern int32_t parser_asm_parse_anonymous_struct_lit_x_into_c(void *arena, void *lex_inout, void *source,
                                                             int32_t *out_ok, int32_t *out_expr_ref);
void parser_asm_parse_anonymous_struct_lit_c(void *arena, struct parser_asm_lexer lex_in_brace,
                                             struct parser_asm_slice_u8 *source,
                                             struct parser_asm_parse_expr_result *out) {
  struct parser_asm_lexer cur;
  int32_t ok = 0;
  int32_t ref = 0;
  if (!arena || !source || !out)
    return;
  out->ok = 0;
  out->expr_ref = 0;
  cur = lex_in_brace;
  if (parser_asm_parse_anonymous_struct_lit_x_into_c(arena, &cur, source, &ok, &ref) == 0 || ok == 0) {
    out->ok = 0;
    return;
  }
  out->ok = 1;
  out->expr_ref = ref;
  out->next_lex = cur;
}
#else
void parser_asm_parse_anonymous_struct_lit_c(void *arena, struct parser_asm_lexer lex_in_brace,
                                             struct parser_asm_slice_u8 *source,
                                             struct parser_asm_parse_expr_result *out) {
  struct ast_Expr le;
  int32_t lit_ref;
  int32_t ti;
  if (!arena || !source || !out)
    return;
  out->ok = 0;
  lit_ref = ast_ast_arena_expr_alloc(arena);
  if (lit_ref == 0)
    return;
  le = ast_ast_arena_expr_get(arena, lit_ref);
  parser_asm_finish_struct_lit_common_zeros_c(&le);
  le.kind = PARSER_ASM_FINISH_STRUCT_LIT_KIND;
  le.struct_lit_struct_name_len = 0;
  ti = 0;
  while (ti < 64) {
    le.struct_lit_struct_name[ti] = 0;
    ti = ti + 1;
  }
  le.struct_lit_field_base = 0;
  le.struct_lit_num_fields = 0;
  le.line = 0;
  le.col = 0;
  le.int_val = 0;
  le.float_val = 0.0;
  ast_ast_arena_expr_set(arena, lit_ref, le);
  parser_asm_parse_struct_lit_fields_c(arena, lit_ref, lex_in_brace, source, out);
}
#endif /* XLANG_PTHIN_EXPR_PRIMARY_ANON_STRUCT_FROM_X */

/**
 * finish_struct_lit_from_type_ident_into：lit_ref 为 IDENT 占位；lex_in_brace 为 `{` 后 lexer。
 * 成功写 out.expr_ref 为 EXPR_STRUCT_LIT。
 * P4bn: XLANG_PTHIN_EXPR_PRIMARY_FINISH_TYPE_IDENT_FROM_X trampolines to
 * dest-buffer (.x copies var_name via the 256-byte Cap face, then
 * set_struct_lit_finish). C holds name[256]. Cold: no define, this twin.
 * PLATFORM: SHARED — product Type { } finish.
 */
#ifdef XLANG_PTHIN_EXPR_PRIMARY_FINISH_TYPE_IDENT_FROM_X
extern int32_t parser_asm_finish_struct_lit_from_type_ident_x_into_c(void *arena, int32_t lit_ref,
                                                                    void *lex_inout, void *source,
                                                                    uint8_t *name_buf, int32_t *out_ok,
                                                                    int32_t *out_expr_ref);
void parser_asm_finish_struct_lit_from_type_ident_into_c(void *arena, int32_t lit_ref,
                                                         struct parser_asm_lexer lex_in_brace,
                                                         struct parser_asm_slice_u8 *source,
                                                         struct parser_asm_parse_expr_result *out) {
  struct parser_asm_lexer cur;
  int32_t ok = 0;
  int32_t ref = 0;
  uint8_t name_buf[256];
  int32_t ni;
  if (!arena || !source || !out)
    return;
  out->ok = 0;
  out->expr_ref = 0;
  if (lit_ref == 0)
    return;
  ni = 0;
  while (ni < 256) {
    name_buf[ni] = 0;
    ni = ni + 1;
  }
  cur = lex_in_brace;
  if (parser_asm_finish_struct_lit_from_type_ident_x_into_c(arena, lit_ref, &cur, source, name_buf, &ok,
                                                           &ref) == 0 ||
      ok == 0) {
    out->ok = 0;
    return;
  }
  out->ok = 1;
  out->expr_ref = ref;
  out->next_lex = cur;
}
#else
void parser_asm_finish_struct_lit_from_type_ident_into_c(void *arena, int32_t lit_ref,
                                                         struct parser_asm_lexer lex_in_brace,
                                                         struct parser_asm_slice_u8 *source,
                                                         struct parser_asm_parse_expr_result *out) {
  struct ast_Expr le;
  int32_t tlen;
  /* wave583 Cap residual: struct-lit type name content ≤255 (struct_lit_struct_name[256]). */
  uint8_t tnm[128];
  int32_t ti;
  int32_t tj;
  if (!arena || !source || !out)
    return;
  out->ok = 0;
  if (lit_ref == 0)
    return;
  le = ast_ast_arena_expr_get(arena, lit_ref);
  tlen = le.var_name_len;
  if (tlen <= 0 || tlen > 255)
    return;
  ti = 0;
  while (ti < 128) {
    tnm[ti] = le.var_name[ti];
    ti = ti + 1;
  }
  parser_asm_finish_struct_lit_common_zeros_c(&le);
  le.kind = PARSER_ASM_FINISH_STRUCT_LIT_KIND;
  le.struct_lit_struct_name_len = tlen;
  tj = 0;
  while (tj < 128) {
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
  parser_asm_parse_struct_lit_fields_c(arena, lit_ref, lex_in_brace, source, out);
}
#endif /* XLANG_PTHIN_EXPR_PRIMARY_FINISH_TYPE_IDENT_FROM_X */

#endif /* PARSER_ASM_FINISH_STRUCT_LIT_SLICE_INCLUDED */
