/**
 * parser_asm_top_level_let_slice.c — parse_one_top_level_let_into C 实现。
 *
 * 由 parser_asm_thin_c.c #include；勿单独编译。
 * 顶层 let/const「ident : type = expr ;」路径；expr 经 parse_expr_into 回调 SU mega。
 */
#ifndef PARSER_ASM_TOP_LEVEL_LET_SLICE_INCLUDED
#define PARSER_ASM_TOP_LEVEL_LET_SLICE_INCLUDED

/** 与 parser.su TopLevelLetResult（allow(padding)）布局一致。 */
struct parser_asm_top_level_let_result {
  int32_t ok;
  uint8_t _pad[4];
  struct parser_asm_lexer next_lex;
};

/** 与 parser_asm_body_let_slice.c ParseExprResult 布局一致（body_let 已先 include）。 */

extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                            struct parser_asm_slice_u8 *data);
extern void parser_lex_from_lexer_result_ptr_into(struct parser_asm_lexer *out, struct parser_asm_lexer_result *r);
extern void parser_lex_from_next_into_glue(struct parser_asm_lexer *out, struct parser_asm_lexer_result r);
extern void parse_expr_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                            struct parser_asm_parse_expr_result *out);
extern int32_t ast_ast_arena_type_alloc(void *arena);
extern struct ast_Type ast_arena_type_get(void *arena, int32_t ref);
extern void ast_arena_type_set(void *arena, int32_t ref, struct ast_Type t);
extern int32_t pipeline_module_top_level_let_alloc(void *module);
extern void pipeline_module_top_level_let_set(void *module, int32_t idx, uint8_t *name, int32_t name_len,
                                              int32_t type_ref, int32_t init_ref, int32_t is_const);
extern int32_t parser_asm_stretch_top_level_let_probe_c(struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                                        int32_t is_const);
extern int32_t parser_asm_stretch_function_name_audit_c(const uint8_t *name, int32_t name_len);
extern int32_t parser_asm_stretch_type_ref_deep_audit_c(struct parser_asm_lexer lex,
                                                        struct parser_asm_slice_u8 *source);

/** 从 slice 复制 ident 名到 name_buf（最多 64 字节）。 */
static void parser_asm_top_level_let_copy_ident_name_c(struct parser_asm_slice_u8 *source, size_t token_start,
                                                       int32_t name_len, uint8_t *name_buf) {
  if (!name_buf || name_len <= 0)
    return;
  parser_asm_copy_slice_to_name64_slice_c(source, token_start, name_len, name_buf);
}

/**
 * 自 r 当前 token 解析顶层 type（*ident | 标量 | ident），成功返回 types 池 ref 并前进 lex/r；失败 0。
 */
static int32_t parser_asm_top_level_let_parse_type_c(void *arena, struct parser_asm_lexer *lex,
                                                     struct parser_asm_lexer_result *r,
                                                     struct parser_asm_slice_u8 *source) {
  int32_t type_ref;
  int32_t elem_ref;
  struct ast_Type t;
  struct ast_Type te;
  if (!arena || !lex || !r || !source)
    return 0;
  if (r->tok.kind == (int32_t)TOKEN_STAR) {
    parser_lex_from_lexer_result_ptr_into(lex, r);
    lexer_next_into(r, *lex, source);
    if (r->tok.kind != (int32_t)TOKEN_IDENT)
      return 0;
    elem_ref = ast_ast_arena_type_alloc(arena);
    if (elem_ref == 0)
      return 0;
    te = ast_arena_type_get(arena, elem_ref);
    te.kind = PARSER_ASM_TYPE_NAMED;
    te.name_len = r->tok.ident_len;
    if (te.name_len > 63)
      te.name_len = 63;
    parser_asm_top_level_let_copy_ident_name_c(source, r->token_start, te.name_len, te.name);
    te.elem_type_ref = 0;
    te.array_size = 0;
    te.region_label_len = 0;
    ast_arena_type_set(arena, elem_ref, te);
    type_ref = ast_ast_arena_type_alloc(arena);
    if (type_ref == 0)
      return 0;
    t = ast_arena_type_get(arena, type_ref);
    t.kind = PARSER_ASM_TYPE_PTR;
    t.elem_type_ref = elem_ref;
    t.name_len = 0;
    t.array_size = 0;
    t.region_label_len = 0;
    ast_arena_type_set(arena, type_ref, t);
    parser_lex_from_lexer_result_ptr_into(lex, r);
    lexer_next_into(r, *lex, source);
    return type_ref;
  }
  if (r->tok.kind == (int32_t)TOKEN_I32 || r->tok.kind == (int32_t)TOKEN_I64 || r->tok.kind == (int32_t)TOKEN_BOOL
      || r->tok.kind == (int32_t)TOKEN_U8 || r->tok.kind == (int32_t)TOKEN_U32 || r->tok.kind == (int32_t)TOKEN_U64
      || r->tok.kind == (int32_t)TOKEN_USIZE || r->tok.kind == (int32_t)TOKEN_ISIZE || r->tok.kind == (int32_t)TOKEN_VOID
      || r->tok.kind == (int32_t)TOKEN_IDENT) {
    type_ref = ast_ast_arena_type_alloc(arena);
    if (type_ref == 0)
      return 0;
    t = ast_arena_type_get(arena, type_ref);
    if (r->tok.kind == (int32_t)TOKEN_I32)
      t.kind = PARSER_ASM_TYPE_I32;
    else if (r->tok.kind == (int32_t)TOKEN_I64)
      t.kind = PARSER_ASM_TYPE_I64;
    else if (r->tok.kind == (int32_t)TOKEN_BOOL)
      t.kind = PARSER_ASM_TYPE_BOOL;
    else if (r->tok.kind == (int32_t)TOKEN_U8)
      t.kind = PARSER_ASM_TYPE_U8;
    else if (r->tok.kind == (int32_t)TOKEN_U32)
      t.kind = PARSER_ASM_TYPE_U32;
    else if (r->tok.kind == (int32_t)TOKEN_U64)
      t.kind = PARSER_ASM_TYPE_U64;
    else if (r->tok.kind == (int32_t)TOKEN_USIZE)
      t.kind = PARSER_ASM_TYPE_USIZE;
    else if (r->tok.kind == (int32_t)TOKEN_ISIZE)
      t.kind = PARSER_ASM_TYPE_ISIZE;
    else if (r->tok.kind == (int32_t)TOKEN_VOID)
      t.kind = PARSER_ASM_TYPE_VOID;
    else {
      t.kind = PARSER_ASM_TYPE_NAMED;
      t.name_len = r->tok.ident_len;
      if (t.name_len > 63)
        t.name_len = 63;
      parser_asm_top_level_let_copy_ident_name_c(source, r->token_start, t.name_len, t.name);
    }
    t.elem_type_ref = 0;
    t.array_size = 0;
    t.region_label_len = 0;
    ast_arena_type_set(arena, type_ref, t);
    parser_lex_from_lexer_result_ptr_into(lex, r);
    lexer_next_into(r, *lex, source);
    return type_ref;
  }
  return 0;
}

/**
 * parse_one_top_level_let_into：解析单条顶层 let/const，写入 module 侧车与 out。
 */
void parser_asm_parse_one_top_level_let_into_slice_c(void *arena, void *module, struct parser_asm_lexer lex,
                                                     struct parser_asm_slice_u8 *source, int32_t is_const,
                                                     struct parser_asm_top_level_let_result *out) {
  struct parser_asm_lexer_result r;
  struct parser_asm_parse_expr_result expr_res;
  uint8_t name_buf[64];
  int32_t name_len;
  int32_t type_ref;
  int32_t tl_ix;
  int32_t ic;
  if (!out)
    return;
  out->ok = 0;
  if (!arena || !module || !source)
    return;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_top_level_let_probe_c(lex, source, is_const));
  memset(&r, 0, sizeof(r));
  memset(&expr_res, 0, sizeof(expr_res));
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_IDENT)
    return;
  name_len = r.tok.ident_len;
  if (name_len <= 0 || name_len > 63)
    return;
  parser_asm_top_level_let_copy_ident_name_c(source, r.token_start, name_len, name_buf);
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_function_name_audit_c(name_buf, name_len));
  parser_lex_from_lexer_result_ptr_into(&lex, &r);
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_COLON)
    return;
  parser_lex_from_lexer_result_ptr_into(&lex, &r);
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_type_ref_deep_audit_c(lex, source));
  lexer_next_into(&r, lex, source);
  type_ref = parser_asm_top_level_let_parse_type_c(arena, &lex, &r, source);
  if (type_ref == 0)
    return;
  if (r.tok.kind != (int32_t)TOKEN_ASSIGN)
    return;
  parser_lex_from_lexer_result_ptr_into(&lex, &r);
  expr_res.ok = 0;
  expr_res.expr_ref = 0;
  expr_res.next_lex = lex;
  parse_expr_into(arena, lex, source, &expr_res);
  if (!expr_res.ok)
    return;
  lex = expr_res.next_lex;
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_SEMICOLON)
    return;
  tl_ix = pipeline_module_top_level_let_alloc(module);
  if (tl_ix < 0)
    return;
  ic = is_const != 0 ? 1 : 0;
  pipeline_module_top_level_let_set(module, tl_ix, name_buf, name_len, type_ref, expr_res.expr_ref, ic);
  parser_lex_from_next_into_glue(&out->next_lex, r);
  out->ok = 1;
}

#endif /* PARSER_ASM_TOP_LEVEL_LET_SLICE_INCLUDED */
