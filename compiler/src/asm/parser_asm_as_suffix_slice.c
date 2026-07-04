/**
 * parser_asm_as_suffix_slice.c — parse_as_suffix_into C 实现。
 *
 * 由 parser_asm_thin_c.c #include；勿单独编译。
 * 与 parser.x parse_as_suffix_into 一致：`as type` 后缀链，支持 *T 与标量/命名类型。
 */
#ifndef PARSER_ASM_AS_SUFFIX_SLICE_INCLUDED
#define PARSER_ASM_AS_SUFFIX_SLICE_INCLUDED

/** 与 ast.x ExprKind 序一致（含 EXPR_BINOP；TRY_PROPAGATE 在 EXPR_SPAWN 之后）。 */
enum {
  PARSER_ASM_EXPR_AS = 54
};
#ifndef PARSER_ASM_EXPR_TRY_PROPAGATE
#define PARSER_ASM_EXPR_TRY_PROPAGATE 58
#endif

extern int32_t ast_ast_arena_expr_alloc(void *arena);
extern int32_t ast_ast_arena_type_alloc(void *arena);
extern struct ast_Type ast_arena_type_get(void *arena, int32_t ref);
extern void ast_arena_type_set(void *arena, int32_t ref, struct ast_Type t);

/** parser_asm_thin_c.c 在 #include 前定义（同 TU）。 */
struct parser_asm_ast_expr parser_asm_arena_expr_get_c(void *arena, int32_t ref);
static void parser_asm_arena_expr_set_c(void *arena, int32_t ref, struct parser_asm_ast_expr ae);
static void parser_asm_expr_set_common_zeros_c(struct parser_asm_ast_expr *e);
static void parser_asm_lex_from_result_val_into(struct parser_asm_lexer *out, struct parser_asm_lexer_result r);
extern int32_t parser_asm_stretch_as_suffix_chain_audit_c(struct parser_asm_lexer lex,
                                                          struct parser_asm_slice_u8 *source);

/** as 后缀目标类型：标量 token → type ref；IDENT → TYPE_NAMED。 */
static int32_t parser_asm_as_suffix_type_from_token_c(void *arena, struct parser_asm_slice_u8 *source,
                                                      struct parser_asm_lexer_result *r) {
  int32_t type_ref;
  struct ast_Type t;
  int32_t nlen;
  int32_t si;
  if (!arena || !r)
    return 0;
  if (r->tok.kind == (int32_t)TOKEN_I32 || r->tok.kind == (int32_t)TOKEN_I64 || r->tok.kind == (int32_t)TOKEN_BOOL
      || r->tok.kind == (int32_t)TOKEN_U8 || r->tok.kind == (int32_t)TOKEN_U32 || r->tok.kind == (int32_t)TOKEN_U64
      || r->tok.kind == (int32_t)TOKEN_USIZE || r->tok.kind == (int32_t)TOKEN_ISIZE || r->tok.kind == (int32_t)TOKEN_VOID
      || r->tok.kind == (int32_t)TOKEN_F32 || r->tok.kind == (int32_t)TOKEN_F64) {
    type_ref = ast_ast_arena_type_alloc(arena);
    if (type_ref == 0)
      return 0;
    t = ast_arena_type_get(arena, type_ref);
    t.name_len = 0;
    t.elem_type_ref = 0;
    t.array_size = 0;
    t.region_label_len = 0;
    switch (r->tok.kind) {
    case TOKEN_I32:
      t.kind = PARSER_ASM_TYPE_I32;
      break;
    case TOKEN_I64:
      t.kind = PARSER_ASM_TYPE_I64;
      break;
    case TOKEN_BOOL:
      t.kind = PARSER_ASM_TYPE_BOOL;
      break;
    case TOKEN_U8:
      t.kind = PARSER_ASM_TYPE_U8;
      break;
    case TOKEN_U32:
      t.kind = PARSER_ASM_TYPE_U32;
      break;
    case TOKEN_U64:
      t.kind = PARSER_ASM_TYPE_U64;
      break;
    case TOKEN_USIZE:
      t.kind = PARSER_ASM_TYPE_USIZE;
      break;
    case TOKEN_ISIZE:
      t.kind = PARSER_ASM_TYPE_ISIZE;
      break;
    case TOKEN_VOID:
      t.kind = PARSER_ASM_TYPE_VOID;
      break;
    case TOKEN_F32:
      t.kind = PARSER_ASM_TYPE_F32;
      break;
    case TOKEN_F64:
      t.kind = PARSER_ASM_TYPE_F64;
      break;
    default:
      return 0;
    }
    ast_arena_type_set(arena, type_ref, t);
    return type_ref;
  }
  if (r->tok.kind == (int32_t)TOKEN_IDENT) {
    type_ref = ast_ast_arena_type_alloc(arena);
    if (type_ref == 0)
      return 0;
    t = ast_arena_type_get(arena, type_ref);
    t.kind = PARSER_ASM_TYPE_NAMED;
    nlen = r->tok.ident_len;
    if (nlen > 63)
      nlen = 63;
    t.name_len = nlen;
    for (si = 0; si < nlen && source && r->token_start + (size_t)si < source->length; si++)
      t.name[si] = source->data[r->token_start + (size_t)si];
    t.elem_type_ref = 0;
    t.array_size = 0;
    t.region_label_len = 0;
    ast_arena_type_set(arena, type_ref, t);
    return type_ref;
  }
  return 0;
}

/**
 * parse_as_suffix_into：解析零个或多个 postfix 后缀（`?` Result 传播、`as type`；假定 out 已由 primary 填充）。
 */
void parser_asm_parse_as_suffix_into_slice_c(void *arena, struct parser_asm_slice_u8 *source,
                                             struct parser_asm_parse_expr_result *out) {
  struct parser_asm_lexer lex_cur;
  struct parser_asm_lexer_result r;
  int32_t type_ref;
  int32_t inner_ref;
  int32_t as_ref;
  int32_t try_ref;
  struct parser_asm_ast_expr ae;
  struct ast_Type tptr;
  int32_t elem_ref;
  if (!out || !out->ok || !source)
    return;
  lex_cur = out->next_lex;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_as_suffix_chain_audit_c(lex_cur, source));
  for (;;) {
    lexer_next_into(&r, lex_cur, source);
    if (r.tok.kind == (int32_t)TOKEN_QUESTION) {
      struct parser_asm_lexer_result rpeek;
      struct parser_asm_lexer lex_after_q;
      /** 三元 `cond ? then : else` 的 `?` 须留给 ternary 层；仅 `?` 后紧跟 `;` `)` 等为 ERR-01 传播。 */
      parser_asm_lex_from_result_val_into(&lex_after_q, r);
      lexer_next_into(&rpeek, lex_after_q, source);
      if (rpeek.tok.kind != (int32_t)TOKEN_SEMICOLON && rpeek.tok.kind != (int32_t)TOKEN_RPAREN &&
          rpeek.tok.kind != (int32_t)TOKEN_RBRACE && rpeek.tok.kind != (int32_t)TOKEN_COMMA &&
          rpeek.tok.kind != (int32_t)TOKEN_RBRACKET) {
        out->next_lex = lex_cur;
        return;
      }
      inner_ref = out->expr_ref;
      try_ref = ast_ast_arena_expr_alloc(arena);
      if (try_ref == 0) {
        out->ok = 0;
        return;
      }
      ae = parser_asm_arena_expr_get_c(arena, try_ref);
      ae.kind = PARSER_ASM_EXPR_TRY_PROPAGATE;
      ae.line = 0;
      ae.col = 0;
      parser_asm_expr_set_common_zeros_c(&ae);
      ae.unary_operand_ref = inner_ref;
      parser_asm_arena_expr_set_c(arena, try_ref, ae);
      out->expr_ref = try_ref;
      out->next_lex = rpeek.next_lex;
      return;
    }
    if (r.tok.kind != (int32_t)TOKEN_AS) {
      out->next_lex = lex_cur;
      return;
    }
    parser_asm_lex_from_result_val_into(&lex_cur, r);
    lexer_next_into(&r, lex_cur, source);
    type_ref = 0;
    if (r.tok.kind == (int32_t)TOKEN_STAR) {
      parser_lex_from_lexer_result_ptr_into(&lex_cur, &r);
      lexer_next_into(&r, lex_cur, source);
      elem_ref = parser_asm_alloc_pointee_type_ref_from_tok_c(arena, source, &r);
      if (elem_ref == 0) {
        out->ok = 0;
        return;
      }
      type_ref = ast_ast_arena_type_alloc(arena);
      if (type_ref != 0) {
        tptr = ast_arena_type_get(arena, type_ref);
        tptr.kind = PARSER_ASM_TYPE_PTR;
        tptr.elem_type_ref = elem_ref;
        tptr.name_len = 0;
        tptr.array_size = 0;
        tptr.region_label_len = 0;
        ast_arena_type_set(arena, type_ref, tptr);
      }
      parser_lex_from_lexer_result_ptr_into(&lex_cur, &r);
      lex_cur = r.next_lex;
    } else {
      type_ref = parser_asm_as_suffix_type_from_token_c(arena, source, &r);
      if (type_ref == 0) {
        out->ok = 0;
        return;
      }
      parser_lex_from_lexer_result_ptr_into(&lex_cur, &r);
      lex_cur = r.next_lex;
    }
    if (type_ref == 0) {
      out->ok = 0;
      return;
    }
    inner_ref = out->expr_ref;
    as_ref = ast_ast_arena_expr_alloc(arena);
    if (as_ref == 0) {
      out->ok = 0;
      return;
    }
    ae = parser_asm_arena_expr_get_c(arena, as_ref);
    ae.kind = PARSER_ASM_EXPR_AS;
    ae.line = 0;
    ae.col = 0;
    parser_asm_expr_set_common_zeros_c(&ae);
    ae.as_operand_ref = inner_ref;
    ae.as_target_type_ref = type_ref;
    parser_asm_arena_expr_set_c(arena, as_ref, ae);
    out->expr_ref = as_ref;
    lex_cur = r.next_lex;
  }
}

#endif /* PARSER_ASM_AS_SUFFIX_SLICE_INCLUDED */
