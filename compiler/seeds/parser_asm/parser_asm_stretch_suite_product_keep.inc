/**
 * parser_asm_stretch_suite_product_keep.inc — Class BA
 * Product builds (no XLANG_PARSER_STRETCH_AUDIT): do NOT include the full
 * stretch suite (symbol-string bloat). Keep only live helpers + address-taken
 * Cap stubs. Full suite remains for STRETCH_AUDIT / bootstrap gates.
 */
#ifndef PARSER_ASM_STRETCH_SUITE_PRODUCT_KEEP_INCLUDED
#define PARSER_ASM_STRETCH_SUITE_PRODUCT_KEEP_INCLUDED

int32_t parser_asm_stretch_is_type_start_kind_c(int32_t kind) {
  if (kind == (int32_t)TOKEN_I32 || kind == (int32_t)TOKEN_I64 || kind == (int32_t)TOKEN_BOOL
      || kind == (int32_t)TOKEN_U8 || kind == (int32_t)TOKEN_U32 || kind == (int32_t)TOKEN_U64
      || kind == (int32_t)TOKEN_USIZE || kind == (int32_t)TOKEN_VOID || kind == (int32_t)TOKEN_IDENT)
    return 1;
  return 0;
}

int32_t parser_asm_stretch_skip_balanced_brackets_into_c(void *lex_inout, void *source) {
  struct parser_asm_lexer lex;
  int32_t depth;
  struct parser_asm_lexer_result r;
  if (!lex_inout || !source)
    return 0;
  lex = *(struct parser_asm_lexer *)lex_inout;
  depth = 1;
  while (depth > 0) {
    lexer_next_into(&r, lex, (struct parser_asm_slice_u8 *)source);
    if (r.tok.kind == (int32_t)TOKEN_LBRACKET)
      depth++;
    else if (r.tok.kind == (int32_t)TOKEN_RBRACKET) {
      depth--;
      if (depth == 0) {
        *(struct parser_asm_lexer *)lex_inout = r.next_lex;
        return 1;
      }
    }
    if (r.tok.kind == (int32_t)TOKEN_EOF) {
      *(struct parser_asm_lexer *)lex_inout = lex;
      return 1;
    }
    parser_asm_lex_from_result_val_into(&lex, r);
  }
  *(struct parser_asm_lexer *)lex_inout = lex;
  return 1;
}

int32_t parser_asm_stretch_skip_one_param_type_c(void *lex_inout, void *source) {
  struct parser_asm_lexer lex;
  struct parser_asm_lexer_result r;
  if (!lex_inout || !source)
    return 0;
  lex = *(struct parser_asm_lexer *)lex_inout;
  lexer_next_into(&r, lex, (struct parser_asm_slice_u8 *)source);
  if (r.tok.kind == (int32_t)TOKEN_STAR) {
    lex = r.next_lex;
    parser_asm_stretch_skip_type_suffix_c(&lex, source);
    *(struct parser_asm_lexer *)lex_inout = lex;
    return 1;
  }
  if (!parser_asm_stretch_is_type_start_kind_c(r.tok.kind))
    return 1;
  lex = r.next_lex;
  parser_asm_stretch_skip_type_suffix_c(&lex, source);
  *(struct parser_asm_lexer *)lex_inout = lex;
  return 1;
}

int32_t parser_asm_stretch_skip_type_suffix_c(void *lex_inout, void *source) {
  struct parser_asm_lexer lex;
  struct parser_asm_lexer_result r;
  int32_t guard;
  if (!lex_inout || !source)
    return 0;
  lex = *(struct parser_asm_lexer *)lex_inout;
  guard = 0;
  for (;;) {
    if (guard++ > 64)
      break;
    lexer_next_into(&r, lex, (struct parser_asm_slice_u8 *)source);
    if (r.tok.kind == (int32_t)TOKEN_STAR) {
      lex = r.next_lex;
      continue;
    }
    if (r.tok.kind == (int32_t)TOKEN_LBRACKET) {
      lex = r.next_lex;
      parser_asm_stretch_skip_balanced_brackets_into_c(&lex, source);
      continue;
    }
    break;
  }
  *(struct parser_asm_lexer *)lex_inout = lex;
  return 1;
}

int32_t parser_asm_stretch_collect_imports_preamble_audit_c(int32_t kind, int32_t next_kind,
                                                           int32_t third_kind, void *source) {
  if (!source)
    return 0;
  (void)parser_asm_stretch_classify_toplevel_c(kind, next_kind, third_kind);
  return 1;
}

int32_t parser_asm_stretch_expr_bitand_binop_audit_c(void *lex_inout, void *source) {
  /* Class BA: Cap stretch audit stub (product STRETCH_AUDIT off; address-taken only). */
  (void)lex_inout;
  (void)source;
  return 0;
}

int32_t parser_asm_stretch_expr_bitor_binop_audit_c(void *lex_inout, void *source) {
  /* Class BA: Cap stretch audit stub (product STRETCH_AUDIT off; address-taken only). */
  (void)lex_inout;
  (void)source;
  return 0;
}

int32_t parser_asm_stretch_expr_bitxor_binop_audit_c(void *lex_inout, void *source) {
  /* Class BA: Cap stretch audit stub (product STRETCH_AUDIT off; address-taken only). */
  (void)lex_inout;
  (void)source;
  return 0;
}

int32_t parser_asm_stretch_expr_logand_binop_audit_c(void *lex_inout, void *source) {
  /* Class BA: Cap stretch audit stub (product STRETCH_AUDIT off; address-taken only). */
  (void)lex_inout;
  (void)source;
  return 0;
}

int32_t parser_asm_stretch_expr_logor_binop_audit_c(void *lex_inout, void *source) {
  /* Class BA: Cap stretch audit stub (product STRETCH_AUDIT off; address-taken only). */
  (void)lex_inout;
  (void)source;
  return 0;
}

int labi_pthin_stretch_suite_slice_marker(void) {
  /* Class BA: suite not linked in product keep lane. */
  return 0;
}

#endif /* PARSER_ASM_STRETCH_SUITE_PRODUCT_KEEP_INCLUDED */
