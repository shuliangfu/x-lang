/**
 * parser_asm_simd_builtin_slice.inc — parse_at_simd_builtin_into C 实现。
 *
 * 由 parser_asm_thin_c.c #include；勿单独编译。
 * 解析 @shuffle(v, mask) / @select(mask, a, b) → CALL simd_shuffle/simd_select。
 *
 * Hybrid P7b/P7c: XLANG_PTHIN_SIMD_BODIES_FROM_X skips the portable ident pack /
 * callee-name fill region and the callee VAR + CALL wrap soup (bodies in
 * src/asm/pthin_simd.x + slice trampoline in this .inc / the seed TU).
 * Parse dest-buffer is P7d (pthin_simd.x); C trampoline under BODIES
 * starts from r0.next_lex (IDENT after `@`) and publishes next_lex.
 * Cold: no define, full twin. PLATFORM: SHARED
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
extern int32_t parser_asm_stretch_simd_builtin_deep_from_at_audit_c(int32_t at_kind, int32_t ident_kind,
                                                                  struct parser_asm_slice_u8 *source,
                                                                  size_t ident_start, int32_t ident_len,
                                                                  void *lex_after_ident);
extern int32_t parser_asm_stretch_simd_builtin_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_simd_builtin_audit_c(int32_t at_kind, int32_t ident_kind,
                                                       struct parser_asm_slice_u8 *source,
                                                       size_t ident_start, int32_t ident_len);

#ifndef XLANG_PTHIN_SIMD_BODIES_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_PTHIN_SIMD_BODIES_FROM_X removed */
#endif /* !XLANG_PTHIN_SIMD_BODIES_FROM_X */

#ifdef XLANG_PTHIN_SIMD_BODIES_FROM_X
extern int32_t parser_asm_simd_callee_name_fill_c(int32_t is_shuffle, uint8_t *out);
extern int32_t parser_asm_simd_call_wrap_into_c(void *arena, uint8_t *name, int32_t nlen);

/* PLATFORM: SHARED — 7.2.1 P7c B-minus. C trampoline holds name[256]
 * (language has no local u8[N]), reuses callee_name_fill (G.7), and
 * forwards to dest-buffer wrap. P7d parse calls this (not static: .x
 * lives in a separate TU). Not a second wrap authority. */
int32_t parser_asm_simd_call_wrap_c(void *arena, int32_t is_shuffle) {
  uint8_t name[256];
  int32_t nlen;
  if (!arena)
    return 0;
  memset(name, 0, sizeof(name));
  nlen = parser_asm_simd_callee_name_fill_c(is_shuffle, name);
  return parser_asm_simd_call_wrap_into_c(arena, name, nlen);
}
#endif

/**
 * parse_at_simd_builtin_into：r0 为 @ 后 LexerResult；成功写 out.expr_ref / out.next_lex。
 */
void parser_asm_parse_at_simd_builtin_into_c(void *arena, struct parser_asm_lexer_result r0,
                                           struct parser_asm_slice_u8 *source,
                                           struct parser_asm_parse_expr_result *out) {
#ifdef XLANG_PTHIN_SIMD_BODIES_FROM_X
  /* PLATFORM: SHARED — P7d trampoline. AUDIT stays on the cold twin
   * (product AUDIT_CALL is nop). .x starts at IDENT = r0.next_lex.
   * Publish next_lex from the live cursor. */
  {
    extern int32_t parser_asm_parse_at_simd_builtin_x_into_c(void *arena, void *lex_inout, void *source,
                                                            int32_t *out_ok, int32_t *out_expr_ref);
    struct parser_asm_lexer cur;
    int32_t ok;
    int32_t ref;
    if (!arena || !source || !out)
      return;
    out->ok = 0;
    cur = r0.next_lex;
    ok = 0;
    ref = 0;
    if (parser_asm_parse_at_simd_builtin_x_into_c(arena, &cur, source, &ok, &ref) == 0 || ok == 0) {
      out->ok = 0;
      return;
    }
    out->ok = 1;
    out->expr_ref = ref;
    out->next_lex = cur;
    return;
  }
#else
  struct parser_asm_lexer lex;
  struct parser_asm_lexer_result r;
  int32_t need_args;
  int32_t is_shuffle;
  int32_t call_ref;
  int32_t callee_ref;
  struct ast_Expr ce;
  struct ast_Expr call_e;
  int32_t got;
  struct parser_asm_parse_expr_result arg_res;
  if (!arena || !source || !out)
    return;
  out->ok = 0;
  lex = r0.next_lex;
  lexer_next_into(&r, lex, source);
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_simd_builtin_audit_c((int32_t)r0.tok.kind, (int32_t)r.tok.kind,
                                                                       source, r.token_start, r.tok.ident_len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_simd_builtin_deep_from_at_audit_c((int32_t)r0.tok.kind, (int32_t)r.tok.kind,
                                                                       source, r.token_start, r.tok.ident_len, &r.next_lex));
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
  ce.var_name_len = parser_asm_simd_callee_name_fill_c(is_shuffle, ce.var_name);
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
#endif /* XLANG_PTHIN_SIMD_BODIES_FROM_X parse_at_simd_builtin */
}

#endif /* PARSER_ASM_SIMD_BUILTIN_SLICE_INCLUDED */
