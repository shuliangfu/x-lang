/**
 * parser_asm_diag_late_slice.inc — after_structs / fail_at_token_kind / buf
 * skip trampolines (G-02f-326).
 *
 * Hybrid P17b: XLANG_PTHIN_DIAG_LATE_BODIES_FROM_X skips the portable
 * after_structs + fail_at_token_kind walks (bodies in
 * src/asm/pthin_diag_late.x + by-value trampolines in the seed TU).
 * P17c G.7: diag_skip_let_const_buf is a trampoline over P18b
 * diag_skip_let_const_into (same pattern as body_skip_buf). The old
 * buf C walk was a dual-authority twin that missed U8/U32/U64/USIZE
 * and the `[]` suffix after a scalar. Contiguous already-T AUDIT
 * prefixes on the remaining buf wrappers are compiled only under
 * XLANG_PARSER_STRETCH_AUDIT. Cold: no BODIES define, this file is
 * the full twin for after_structs/fail; buf skip always trampolines.
 * Do not reuse XLANG_PTHIN_DIAG_LATE_FROM_X for P17b bodies.
 */
#ifndef XLANG_PTHIN_DIAG_LATE_BODIES_FROM_X
/**
 * diag_after_imports_then_structs：peek 首 token 并跳过连续 struct，返回首个非 struct 的 LexerResult。
 * Hybrid P17b: body in src/asm/pthin_diag_late.x; this C twin is cold fallback.
 */
struct parser_asm_lexer_result parser_asm_diag_after_imports_then_structs_slice_c(
    struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer_result r;
  if (!source) {
    memset(&r, 0, sizeof(r));
    r.next_lex = lex;
    r.tok.kind = (int32_t)TOKEN_EOF;
    return r;
  }
  lexer_next_into(&r, lex, source);
  while (r.tok.kind == (int32_t)TOKEN_STRUCT) {
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_header_audit_c(&lex, source));
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_fields_body_audit_c(&lex, source));
    lex = parser_asm_skip_one_struct_slice_c(lex, source);
    lexer_next_into(&r, lex, source);
  }
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_diag_toplevel_after_imports_audit_c(&lex, source));
  return r;
}
#endif /* !XLANG_PTHIN_DIAG_LATE_BODIES_FROM_X after_structs slice */

/**
 * diag_after_imports_then_structs_buf：buf 路径跳过连续 struct 后 peek 首 token。
 */
struct parser_asm_lexer_result parser_asm_diag_after_imports_then_structs_buf_c(struct parser_asm_lexer lex,
                                                                                uint8_t *data, int32_t len) {
  struct parser_asm_slice_u8 source;
  struct parser_asm_lexer_result fail;

  if (!data || len <= 0) {
    memset(&fail, 0, sizeof(fail));
    fail.next_lex = lex;
    fail.tok.kind = (int32_t)TOKEN_EOF;
    return fail;
  }
#ifdef XLANG_PARSER_STRETCH_AUDIT
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_diag_after_imports_then_structs_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_diag_after_imports_structs_deep_buf_audit_c(&lex, data, len));
#endif
  source.data = data;
  source.length = (size_t)len;
  return parser_asm_diag_after_imports_then_structs_slice_c(lex, &source);
}

#ifndef XLANG_PTHIN_DIAG_LATE_BODIES_FROM_X
/**
 * diag_fail_at_token_kind：模拟 parse_one_function 顺序检查，返回首次失败 token kind（成功 -1）。
 * Hybrid P17b: body in src/asm/pthin_diag_late.x; this C twin is cold fallback.
 */
int32_t parser_asm_diag_fail_at_token_kind_slice_c(struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer lex;
  struct parser_asm_lexer_result r;

  if (!source)
    return (int32_t)TOKEN_EOF;
  lex = parser_asm_diag_lex_after_imports_slice_c(source);
  r = parser_asm_diag_after_imports_then_structs_slice_c(lex, source);
  if (r.tok.kind != (int32_t)TOKEN_FUNCTION)
    return r.tok.kind;
  parser_asm_lex_from_result_val_into(&lex, r);
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_diag_fn_header_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_diag_fn_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_diag_fn_mega_full_deep_audit_c(&lex, source));
  parser_asm_lex_from_result_val_into(&lex, r);
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_IDENT)
    return r.tok.kind;
  if (r.tok.ident_len <= 0 || r.tok.ident_len > 63)
    return r.tok.kind;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_bind_name_validate_c(source->data + r.token_start, r.tok.ident_len));
  parser_asm_lex_from_result_val_into(&lex, r);
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_LPAREN)
    return r.tok.kind;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_diag_fn_param_sig_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_diag_fn_deep_audit_c(&lex, source));
  parser_asm_lex_from_result_val_into(&lex, r);
  lexer_next_into(&r, lex, source);
  if (r.tok.kind == (int32_t)TOKEN_RPAREN) {
    parser_asm_lex_from_result_val_into(&lex, r);
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_diag_fn_return_type_audit_c(&lex, source));
    lexer_next_into(&r, lex, source);
  } else {
    while (r.tok.kind == (int32_t)TOKEN_IDENT) {
      parser_asm_lex_from_result_val_into(&lex, r);
      lexer_next_into(&r, lex, source);
      if (r.tok.kind != (int32_t)TOKEN_COLON)
        return r.tok.kind;
      parser_asm_lex_from_result_val_into(&lex, r);
      lexer_next_into(&r, lex, source);
      if (parser_asm_is_fn_sig_scalar_type_token_c(r.tok.kind)) {
        parser_asm_lex_from_result_val_into(&lex, r);
        lexer_next_into(&r, lex, source);
      } else if (r.tok.kind == (int32_t)TOKEN_STAR) {
        parser_asm_lex_from_result_val_into(&lex, r);
        lexer_next_into(&r, lex, source);
        if (!parser_asm_is_pointee_type_token_c(r.tok.kind))
          return r.tok.kind;
        parser_asm_lex_from_result_val_into(&lex, r);
        lexer_next_into(&r, lex, source);
      } else if (r.tok.kind == (int32_t)TOKEN_LBRACKET) {
        PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_array_type_bracket_audit_c(&lex, source));
        parser_asm_lex_from_result_val_into(&lex, r);
        lexer_next_into(&r, lex, source);
        if (r.tok.kind != (int32_t)TOKEN_INT)
          return r.tok.kind;
        parser_asm_lex_from_result_val_into(&lex, r);
        lexer_next_into(&r, lex, source);
        if (r.tok.kind != (int32_t)TOKEN_RBRACKET)
          return r.tok.kind;
        parser_asm_lex_from_result_val_into(&lex, r);
        lexer_next_into(&r, lex, source);
        if (r.tok.kind != (int32_t)TOKEN_U8)
          return r.tok.kind;
        parser_asm_lex_from_result_val_into(&lex, r);
        lexer_next_into(&r, lex, source);
      } else {
        return r.tok.kind;
      }
      if (r.tok.kind == (int32_t)TOKEN_COMMA) {
        parser_asm_lex_from_result_val_into(&lex, r);
        lexer_next_into(&r, lex, source);
      }
    }
    if (r.tok.kind != (int32_t)TOKEN_RPAREN)
      return r.tok.kind;
    parser_asm_lex_from_result_val_into(&lex, r);
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_diag_fn_return_type_audit_c(&lex, source));
    lexer_next_into(&r, lex, source);
  }
  if (r.tok.kind != (int32_t)TOKEN_COLON)
    return r.tok.kind;
  parser_asm_lex_from_result_val_into(&lex, r);
  lexer_next_into(&r, lex, source);
  if (parser_asm_is_fn_sig_scalar_type_token_c(r.tok.kind)) {
    parser_asm_lex_from_result_val_into(&lex, r);
    lexer_next_into(&r, lex, source);
  } else if (r.tok.kind == (int32_t)TOKEN_STAR) {
    parser_asm_lex_from_result_val_into(&lex, r);
    lexer_next_into(&r, lex, source);
    if (!parser_asm_is_pointee_type_token_c(r.tok.kind))
      return r.tok.kind;
    parser_asm_lex_from_result_val_into(&lex, r);
    lexer_next_into(&r, lex, source);
  } else {
    return r.tok.kind;
  }
  if (r.tok.kind != (int32_t)TOKEN_LBRACE)
    return r.tok.kind;
  parser_asm_lex_from_result_val_into(&lex, r);
  parser_asm_body_skip_let_const_then_if_into_slice_c(&r, lex, source);
  if (r.tok.kind == (int32_t)TOKEN_INT) {
    parser_asm_lex_from_result_val_into(&lex, r);
    lexer_next_into(&r, lex, source);
    if (r.tok.kind != (int32_t)TOKEN_RBRACE)
      return r.tok.kind;
    return -1;
  }
  if (r.tok.kind == (int32_t)TOKEN_RETURN) {
    parser_asm_lex_from_result_val_into(&lex, r);
    lexer_next_into(&r, lex, source);
    if (r.tok.kind != (int32_t)TOKEN_INT)
      return r.tok.kind;
    parser_asm_lex_from_result_val_into(&lex, r);
    lexer_next_into(&r, lex, source);
    if (r.tok.kind != (int32_t)TOKEN_RBRACE && r.tok.kind != (int32_t)TOKEN_SEMICOLON)
      return r.tok.kind;
    if (r.tok.kind == (int32_t)TOKEN_SEMICOLON) {
      parser_asm_lex_from_result_val_into(&lex, r);
      lexer_next_into(&r, lex, source);
      if (r.tok.kind != (int32_t)TOKEN_RBRACE)
        return r.tok.kind;
    }
    return -1;
  }
  return r.tok.kind;
}
#endif /* !XLANG_PTHIN_DIAG_LATE_BODIES_FROM_X fail_at_token_kind slice */

/**
 * diag_fail_at_token_kind_buf：buf 路径模拟 parse_one_function 顺序检查。
 */
int32_t parser_asm_diag_fail_at_token_kind_buf_c(uint8_t *data, int32_t len) {
  struct parser_asm_slice_u8 source;

  if (!data || len <= 0)
    return (int32_t)TOKEN_EOF;
#ifdef XLANG_PARSER_STRETCH_AUDIT
  {
  struct parser_asm_lexer lex_init = parser_asm_lexer_init_c();
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_diag_fail_at_token_kind_buf_audit_c(&lex_init, data, len));
}
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_diag_fn_deep_buf_audit_c(parser_asm_lexer_init_c(), data, len));
#endif
  source.data = data;
  source.length = (size_t)len;
  return parser_asm_diag_fail_at_token_kind_slice_c(&source);
}

/**
 * diag_skip_let_const_buf：buf 路径跳过 let/const。P17c G.7 trampoline over
 * P18b diag_skip_let_const_into (same pattern as body_skip_buf). The old
 * C walk was a dual-authority twin: it omitted U8/U32/U64/USIZE and the
 * `[]` suffix after a scalar that into already skips.
 * PLATFORM: SHARED — do not reimplement the skip walk here.
 */
struct parser_asm_lexer_result parser_asm_diag_skip_let_const_buf_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                   int32_t len) {
  struct parser_asm_slice_u8 source;
  struct parser_asm_lexer_result r;
  struct parser_asm_lexer_result fail;

  if (!data || len <= 0) {
    memset(&fail, 0, sizeof(fail));
    fail.next_lex = lex;
    fail.tok.kind = (int32_t)TOKEN_EOF;
    return fail;
  }
#ifdef XLANG_PARSER_STRETCH_AUDIT
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_diag_skip_let_const_type_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_diag_skip_let_const_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_diag_skip_let_full_deep_buf_audit_c(&lex, data, len));
#endif
  source.data = data;
  source.length = (size_t)len;
  parser_asm_diag_skip_let_const_into_slice_c(&r, lex, &source);
  return r;
}

/**
 * body_skip_let_const_then_if_buf：parse_into_buf 诊断路径跳过 let/const + if。
 * 委托 slice 实现；旧版仅 stretch audit 且未初始化 r，导致 buf 路径 parse 恒失败。
 */
struct parser_asm_lexer_result parser_asm_body_skip_let_const_then_if_buf_c(struct parser_asm_lexer lex,
                                                                          uint8_t *data, int32_t len) {
  struct parser_asm_slice_u8 source;
  struct parser_asm_lexer_result r;
  struct parser_asm_lexer_result fail;

  if (!data || len <= 0) {
    memset(&fail, 0, sizeof(fail));
    fail.next_lex = lex;
    fail.tok.kind = (int32_t)TOKEN_EOF;
    return fail;
  }
  source.data = data;
  source.length = (size_t)len;
  parser_asm_body_skip_let_const_then_if_into_slice_c(&r, lex, &source);
  return r;
}
