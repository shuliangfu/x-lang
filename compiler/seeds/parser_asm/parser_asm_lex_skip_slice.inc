/**
 * parser_asm_lex_skip_slice.inc — P1 lex/skip pure helpers (G-02f-281).
 * Included by parser_asm_thin_c.from_x.c or pthin_lex_skip.from_x.c.
 */
#ifndef PARSER_ASM_LEX_SKIP_SLICE_INCLUDED
#define PARSER_ASM_LEX_SKIP_SLICE_INCLUDED

/* extracted lines 3873-3963 */
void parser_asm_lex_from_result_val_into(struct parser_asm_lexer *out, struct parser_asm_lexer_result r) {
  if (!out)
    return;
  out->pos = r.next_lex.pos;
  out->line = r.next_lex.line;
  out->col = r.next_lex.col;
}

/** 从 buf 复制 [start, start+nlen) 到 out（等价 parser.x copy_slice_to_name64_buf）。 */
void parser_asm_copy_slice_to_name64_buf_c(uint8_t *source, int32_t source_len, size_t start, int32_t nlen,
                                            uint8_t *out) {
  int32_t i;
  if (!source || !out || nlen <= 0)
    return;
  for (i = 0; i < nlen; i++) {
    if (start + (size_t)i < (size_t)source_len)
      out[i] = source[start + (size_t)i];
  }
}

/** copy_slice_to_name64（u8[] slice 路径）。 */
void parser_asm_copy_slice_to_name64_slice_c(struct parser_asm_slice_u8 *source, size_t start, int32_t nlen,
                                             uint8_t *out) {
  int32_t i;
  if (!source || !source->data || !out || nlen <= 0)
    return;
  for (i = 0; i < nlen; i++) {
    if (start + (size_t)i < source->length)
      out[i] = source->data[start + (size_t)i];
  }
}

/** copy_slice_to_name64_at_end（slice 路径）。 */
void parser_asm_copy_slice_to_name64_at_end_slice_c(struct parser_asm_slice_u8 *source, size_t end_pos,
                                                    int32_t nlen, uint8_t *out) {
  if (!source || !out || nlen <= 0)
    return;
  parser_asm_copy_slice_to_name64_slice_c(source, end_pos - (size_t)nlen, nlen, out);
}

/** copy_slice_to_name64_at_end_buf（buf 路径）。 */
void parser_asm_copy_slice_to_name64_at_end_buf_c(uint8_t *source, int32_t source_len, size_t end_pos, int32_t nlen,
                                                  uint8_t *out) {
  if (!source || !out || nlen <= 0)
    return;
  parser_asm_copy_slice_to_name64_buf_c(source, source_len, end_pos - (size_t)nlen, nlen, out);
}

/** copy_slice_to_param32（slice 路径，固定 32 字节槽）。 */
void parser_asm_copy_slice_to_param32_slice_c(struct parser_asm_slice_u8 *source, size_t start, int32_t nlen,
                                              uint8_t *out) {
  int32_t i;
  if (!out)
    return;
  for (i = 0; i < 32; i++) {
    if (i < nlen && source && source->data && start + (size_t)i < source->length)
      out[i] = source->data[start + (size_t)i];
    else
      out[i] = 0;
  }
}

/** copy_slice_to_param32_buf（buf 路径，固定 32 字节槽并 zero-pad）。 */
void parser_asm_copy_slice_to_param32_buf_c(uint8_t *source, int32_t source_len, size_t start, int32_t nlen,
                                            uint8_t *out) {
  int32_t i;
  if (!out)
    return;
  for (i = 0; i < 32; i++) {
    if (i < nlen && source && start + (size_t)i < (size_t)source_len)
      out[i] = source[start + (size_t)i];
    else
      out[i] = 0;
  }
}

/** copy_slice_to_param32_at_end（slice 路径）。 */
void parser_asm_copy_slice_to_param32_at_end_slice_c(struct parser_asm_slice_u8 *source, size_t end_pos,
                                                     int32_t nlen, uint8_t *out) {
  if (!out)
    return;
  parser_asm_copy_slice_to_param32_slice_c(source, end_pos - (size_t)nlen, nlen, out);
}

/** copy_slice_to_param32_at_end_buf（buf 路径）。 */
void parser_asm_copy_slice_to_param32_at_end_buf_c(uint8_t *source, int32_t source_len, size_t end_pos, int32_t nlen,
                                                   uint8_t *out) {
  if (!out)
    return;
  parser_asm_copy_slice_to_param32_buf_c(source, source_len, end_pos - (size_t)nlen, nlen, out);
}

/* extracted lines 4320-4447 */
/**
 * skip_balanced_parens_buf：从已消费 '(' 的 lex 起跳过匹配括号，返回 ')' 之后的 lex。
 */
struct parser_asm_lexer parser_asm_skip_balanced_parens_buf_c(struct parser_asm_lexer lex, uint8_t *data, int32_t len) {
  int32_t depth = 1;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_balanced_parens_depth_probe_buf_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_balanced_delim_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_balanced_delim_mega_full_deep_buf_audit_c(lex, data, len));
  while (depth > 0) {
    struct parser_asm_lexer_result r = lexer_next_buf(lex, data, len);
    if (r.tok.kind == (int32_t)TOKEN_LPAREN)
      depth++;
    else if (r.tok.kind == (int32_t)TOKEN_RPAREN) {
      depth--;
      if (depth == 0)
        return r.next_lex;
    }
    if (r.tok.kind == (int32_t)TOKEN_EOF)
      return lex;
    parser_asm_lex_from_result_val_into(&lex, r);
  }
  return lex;
}

/**
 * skip_balanced_parens_into_buf：结果写入 *out，避免 Lexer 按值返回 ABI 问题。
 */
void parser_asm_skip_balanced_parens_into_buf_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex, uint8_t *data,
                                                int32_t len) {
  struct parser_asm_lexer rlex;
  if (!out) {
    (void)parser_asm_skip_balanced_parens_buf_c(lex, data, len);
    return;
  }
  rlex = parser_asm_skip_balanced_parens_buf_c(lex, data, len);
  out->pos = rlex.pos;
  out->line = rlex.line;
  out->col = rlex.col;
}

/**
 * skip_balanced_parens_into（u8[] slice 路径）：结果写入 *out。
 * X u8[] 经 C 生成器以 xlang_slice_uint8_t* 传递（与 parser_gen lexer_next_into 一致）。
 */
void parser_asm_skip_balanced_parens_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                                  struct parser_asm_slice_u8 *source) {
  int32_t depth = 1;
  struct parser_asm_lexer_result r;
  if (!out || !source)
    return;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_balanced_parens_depth_probe_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_balanced_delim_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_balanced_delim_mega_full_deep_audit_c(lex, source));
  while (depth > 0) {
    lexer_next_into(&r, lex, source);
    if (r.tok.kind == (int32_t)TOKEN_LPAREN)
      depth++;
    else if (r.tok.kind == (int32_t)TOKEN_RPAREN) {
      depth--;
      if (depth == 0) {
        out->pos = r.next_lex.pos;
        out->line = r.next_lex.line;
        out->col = r.next_lex.col;
        return;
      }
    }
    if (r.tok.kind == (int32_t)TOKEN_EOF) {
      out->pos = lex.pos;
      out->line = lex.line;
      out->col = lex.col;
      return;
    }
    parser_asm_lex_from_result_val_into(&lex, r);
  }
  out->pos = lex.pos;
  out->line = lex.line;
  out->col = lex.col;
}

/**
 * skip_balanced_parens（u8[] slice 路径）：返回 ')' 之后的 lex（16B struct 按值返回）。
 */
struct parser_asm_lexer parser_asm_skip_balanced_parens_slice_c(struct parser_asm_lexer lex,
                                                                struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer out;
  parser_asm_skip_balanced_parens_into_slice_c(&out, lex, source);
  return out;
}

/**
 * skip_balanced_braces_buf：从已消费 '{' 的 lex 起跳过匹配大括号，返回 '}' 之后的 lex。
 */
struct parser_asm_lexer parser_asm_skip_balanced_braces_buf_c(struct parser_asm_lexer lex, uint8_t *data, int32_t len) {
  int32_t depth = 1;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_balanced_braces_depth_probe_buf_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_balanced_delim_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_balanced_delim_mega_full_deep_buf_audit_c(lex, data, len));
  while (depth > 0) {
    struct parser_asm_lexer_result r = lexer_next_buf(lex, data, len);
    if (r.tok.kind == (int32_t)TOKEN_LBRACE)
      depth++;
    else if (r.tok.kind == (int32_t)TOKEN_RBRACE) {
      depth--;
      if (depth == 0)
        return r.next_lex;
    }
    if (r.tok.kind == (int32_t)TOKEN_EOF)
      return lex;
    parser_asm_lex_from_result_val_into(&lex, r);
  }
  return lex;
}

/**
 * skip_balanced_braces_into_buf：结果写入 *out，避免 Lexer 按值返回 ABI 问题。
 */
void parser_asm_skip_balanced_braces_into_buf_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex, uint8_t *data,
                                                int32_t len) {
  struct parser_asm_lexer rlex;
  if (!out) {
    (void)parser_asm_skip_balanced_braces_buf_c(lex, data, len);
    return;
  }
  rlex = parser_asm_skip_balanced_braces_buf_c(lex, data, len);
  out->pos = rlex.pos;
  out->line = rlex.line;
  out->col = rlex.col;
}

/* extracted lines 4504-4625 */
/**
 * 跳过 `<T>` / `<T,E,...>` 泛型实参/形参列表（含嵌套 `<>`）；失败时 out 保持 lex。
 */
void parser_asm_skip_generic_angle_list_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                                     struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer_result r;
  int32_t depth;
  if (!out || !source)
    return;
  depth = 0;
  for (;;) {
    lexer_next_into(&r, lex, source);
    if (r.tok.kind == (int32_t)TOKEN_LT)
      depth++;
    else if (r.tok.kind == (int32_t)TOKEN_GT) {
      depth--;
      if (depth <= 0) {
        out->pos = r.next_lex.pos;
        out->line = r.next_lex.line;
        out->col = r.next_lex.col;
        return;
      }
    } else if (r.tok.kind == (int32_t)TOKEN_EOF) {
      out->pos = lex.pos;
      out->line = lex.line;
      out->col = lex.col;
      return;
    }
    lex = r.next_lex;
  }
}

void parser_asm_skip_generic_angle_list_count_into_slice_c(struct parser_asm_lexer *out, int32_t *count,
                                                           struct parser_asm_lexer lex,
                                                           struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer_result r;
  int32_t depth;
  int32_t top_count;
  int32_t saw_any;
  if (!out || !count || !source)
    return;
  depth = 0;
  top_count = 0;
  saw_any = 0;
  for (;;) {
    lexer_next_into(&r, lex, source);
    if (r.tok.kind == (int32_t)TOKEN_LT) {
      depth++;
    } else if (r.tok.kind == (int32_t)TOKEN_GT) {
      depth--;
      if (depth <= 0) {
        out->pos = r.next_lex.pos;
        out->line = r.next_lex.line;
        out->col = r.next_lex.col;
        *count = saw_any ? (top_count + 1) : 0;
        return;
      }
    } else if (r.tok.kind == (int32_t)TOKEN_COMMA) {
      if (depth == 1)
        top_count++;
    } else if (r.tok.kind == (int32_t)TOKEN_EOF) {
      out->pos = lex.pos;
      out->line = lex.line;
      out->col = lex.col;
      return;
    } else {
      if (depth == 1)
        saw_any = 1;
    }
    lex = r.next_lex;
  }
}

/** buf 路径：跳过 `<...>` 泛型列表。 */
void parser_skip_generic_angle_list_into_buf_glue(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                                  uint8_t *data, int32_t len) {
  struct parser_asm_slice_u8 source;
  if (!out || !data)
    return;
  source.data = data;
  source.length = len >= 0 ? (size_t)len : 0;
  parser_asm_skip_generic_angle_list_into_slice_c(out, lex, &source);
}

void parser_skip_generic_angle_list_count_into_glue(struct lexer_Lexer *out, int32_t *count, struct lexer_Lexer lex,
                                                    struct xlang_slice_uint8_t *source) {
  struct parser_asm_lexer aout;
  struct parser_asm_lexer alex;
  struct parser_asm_slice_u8 asrc;
  int32_t c = 0;
  if (!out || !count || !source)
    return;
  alex.pos = lex.pos;
  alex.line = lex.line;
  alex.col = lex.col;
  asrc.data = source->data;
  asrc.length = source->length;
  parser_asm_skip_generic_angle_list_count_into_slice_c(&aout, &c, alex, &asrc);
  out->pos = aout.pos;
  out->line = aout.line;
  out->col = aout.col;
  *count = c;
}

/** parser_gen / parser.x 用 lexer_Lexer ABI 跳过 `<...>` 泛型列表。 */
void parser_skip_generic_angle_list_into_glue(struct lexer_Lexer *out, struct lexer_Lexer lex,
                                            struct xlang_slice_uint8_t *source) {
  struct parser_asm_lexer aout;
  struct parser_asm_lexer alex;
  struct parser_asm_slice_u8 asrc;
  if (!out || !source)
    return;
  alex.pos = lex.pos;
  alex.line = lex.line;
  alex.col = lex.col;
  asrc.data = source->data;
  asrc.length = source->length;
  parser_asm_skip_generic_angle_list_into_slice_c(&aout, alex, &asrc);
  out->pos = aout.pos;
  out->line = aout.line;
  out->col = aout.col;
}

/* extracted lines 4627-4673 */
/**
 * skip_balanced_braces_into（u8[] slice 路径）：结果写入 *out。
 */
void parser_asm_skip_balanced_braces_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                                  struct parser_asm_slice_u8 *source) {
  int32_t depth = 1;
  struct parser_asm_lexer_result r;
  if (!out || !source)
    return;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_balanced_braces_depth_probe_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_balanced_delim_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_balanced_delim_mega_full_deep_audit_c(lex, source));
  while (depth > 0) {
    lexer_next_into(&r, lex, source);
    if (r.tok.kind == (int32_t)TOKEN_LBRACE)
      depth++;
    else if (r.tok.kind == (int32_t)TOKEN_RBRACE) {
      depth--;
      if (depth == 0) {
        out->pos = r.next_lex.pos;
        out->line = r.next_lex.line;
        out->col = r.next_lex.col;
        return;
      }
    }
    if (r.tok.kind == (int32_t)TOKEN_EOF) {
      out->pos = lex.pos;
      out->line = lex.line;
      out->col = lex.col;
      return;
    }
    parser_asm_lex_from_result_val_into(&lex, r);
  }
  out->pos = lex.pos;
  out->line = lex.line;
  out->col = lex.col;
}

/**
 * skip_balanced_braces（u8[] slice 路径）：返回 '}' 之后的 lex（16B struct 按值返回）。
 */
struct parser_asm_lexer parser_asm_skip_balanced_braces_slice_c(struct parser_asm_lexer lex,
                                                                struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer out;
  parser_asm_skip_balanced_braces_into_slice_c(&out, lex, source);
  return out;
}

/* extracted lines 6373-6399 */

/**
 * is_compound_assign_token：判断是否为 += … >>= 等复合赋值 token。
 */
int32_t parser_asm_is_compound_assign_token_c(int32_t kind) {
  return kind == (int32_t)TOKEN_PLUS_EQ || kind == (int32_t)TOKEN_MINUS_EQ || kind == (int32_t)TOKEN_STAR_EQ
      || kind == (int32_t)TOKEN_SLASH_EQ || kind == (int32_t)TOKEN_PERCENT_EQ || kind == (int32_t)TOKEN_AMP_EQ
      || kind == (int32_t)TOKEN_PIPE_EQ || kind == (int32_t)TOKEN_CARET_EQ || kind == (int32_t)TOKEN_LSHIFT_EQ
      || kind == (int32_t)TOKEN_RSHIFT_EQ;
}

/**
 * is_pointee_type_token：判断 token 是否可作为「*」后的指向目标类型。
 */
int32_t parser_asm_is_pointee_type_token_c(int32_t kind) {
  if (kind == (int32_t)TOKEN_IDENT)
    return 1;
  if (kind == (int32_t)TOKEN_I32 || kind == (int32_t)TOKEN_I64 || kind == (int32_t)TOKEN_BOOL)
    return 1;
  if (kind == (int32_t)TOKEN_U8 || kind == (int32_t)TOKEN_U32 || kind == (int32_t)TOKEN_U64)
    return 1;
  if (kind == (int32_t)TOKEN_USIZE || kind == (int32_t)TOKEN_ISIZE || kind == (int32_t)TOKEN_VOID)
    return 1;
  if (kind == (int32_t)TOKEN_F32 || kind == (int32_t)TOKEN_F64)
    return 1;
  return 0;
}

#endif /* PARSER_ASM_LEX_SKIP_SLICE_INCLUDED */
