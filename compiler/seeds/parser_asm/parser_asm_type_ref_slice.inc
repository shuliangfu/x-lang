/**
 * parser_asm_type_ref_slice.inc — parse_type_ref_for_arena_into / alloc_pointee C 实现。
 *
 * 由 parser_asm_thin_c.c #include；勿单独编译。
 */
#ifndef PARSER_ASM_TYPE_REF_SLICE_INCLUDED
#define PARSER_ASM_TYPE_REF_SLICE_INCLUDED

/** 与 ast.x Type 布局一致。 */
struct ast_Type {
  int32_t kind;
  uint8_t name[64];
  int32_t name_len;
  int32_t elem_type_ref;
  int32_t array_size;
  uint8_t region_label[64];
  int32_t region_label_len;
};

/** 与 ast.x TypeKind 序一致。 */
enum {
  PARSER_ASM_TYPE_I32 = 0,
  PARSER_ASM_TYPE_BOOL = 1,
  PARSER_ASM_TYPE_U8 = 2,
  PARSER_ASM_TYPE_U32 = 3,
  PARSER_ASM_TYPE_U64 = 4,
  PARSER_ASM_TYPE_I64 = 5,
  PARSER_ASM_TYPE_USIZE = 6,
  PARSER_ASM_TYPE_ISIZE = 7,
  PARSER_ASM_TYPE_NAMED = 8,
  PARSER_ASM_TYPE_PTR = 9,
  PARSER_ASM_TYPE_ARRAY = 10,
  PARSER_ASM_TYPE_SLICE = 11,
  PARSER_ASM_TYPE_LINEAR = 12,
  PARSER_ASM_TYPE_VECTOR = 13,
  PARSER_ASM_TYPE_F32 = 14,
  PARSER_ASM_TYPE_F64 = 15,
  PARSER_ASM_TYPE_VOID = 16
};

extern int32_t ast_ast_arena_type_alloc(void *arena);
extern struct ast_Type ast_arena_type_get(void *arena, int32_t ref);
extern void ast_arena_type_set(void *arena, int32_t ref, struct ast_Type t);
extern int32_t pipeline_type_ensure_by_kind_ord(void *arena, int32_t kind_ord);
extern int32_t parser_asm_stretch_type_ref_deep_audit_c(struct parser_asm_lexer lex,
                                                        struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_type_ref_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_vector_type_ident_audit_c(struct parser_asm_slice_u8 *source, size_t token_start,
                                                          int32_t nlen);
extern int32_t parser_asm_stretch_linear_type_audit_c(struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_array_type_bracket_audit_c(struct parser_asm_lexer lex,
                                                             struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_slice_type_bracket_audit_c(struct parser_asm_lexer lex,
                                                             struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_builtin_vec_token_audit_c(int32_t kind);

/** 从 r 当前 IDENT 起解析 `a.b.Type` 限定名，写入 out 并设置 *out_len；失败 -1。 */
int32_t parser_asm_consume_qualified_type_ident_name_c(struct parser_asm_slice_u8 *source,
                                                         struct parser_asm_lexer_result *r, uint8_t *out,
                                                         int32_t *out_len) {
  struct parser_asm_lexer saved_next;
  struct parser_asm_token saved_tok;
  size_t saved_start;
  int32_t seg_len;
  int32_t total;
  if (!r || !out || !out_len || !source)
    return -1;
  if (r->tok.kind != (int32_t)TOKEN_IDENT || r->tok.ident_len <= 0)
    return -1;
  seg_len = r->tok.ident_len;
  if (seg_len > 63)
    seg_len = 63;
  parser_asm_copy_slice_to_name64_at_end_slice_c(source, r->next_lex.pos, seg_len, out);
  total = seg_len;
  for (;;) {
    saved_next = r->next_lex;
    saved_tok = r->tok;
    saved_start = r->token_start;
    lexer_next_into(r, r->next_lex, source);
    if (r->tok.kind != (int32_t)TOKEN_DOT) {
      r->next_lex = saved_next;
      r->tok = saved_tok;
      r->token_start = saved_start;
      *out_len = total;
      return 0;
    }
    if (total >= 63)
      return -1;
    out[total] = 46;
    total++;
    lexer_next_into(r, r->next_lex, source);
    if (r->tok.kind != (int32_t)TOKEN_IDENT || r->tok.ident_len <= 0)
      return -1;
    seg_len = r->tok.ident_len;
    if (total + seg_len > 63)
      seg_len = 63 - total;
    if (seg_len <= 0)
      return -1;
    parser_asm_copy_slice_to_name64_at_end_slice_c(source, r->next_lex.pos, seg_len, &out[total]);
    total += seg_len;
  }
}

static int32_t parser_asm_parse_type_ref_impl_c(void *arena, struct parser_asm_lexer lex,
                                                struct parser_asm_slice_u8 *source,
                                                struct parser_asm_lexer *out_lex);

/** 将 lex 写入 out_lex（parse_type_ref 失败/成功路径共用）。 */
static void parser_asm_write_out_lex_c(struct parser_asm_lexer *out_lex, struct parser_asm_lexer lex) {
  if (!out_lex)
    return;
  out_lex->pos = lex.pos;
  out_lex->line = lex.line;
  out_lex->col = lex.col;
}

/** 分配并写入标量 Type 节点，返回 types 池 ref 或 0。 */
static int32_t parser_asm_arena_alloc_scalar_type_c(void *arena, int32_t type_kind) {
  int32_t ref;
  struct ast_Type t;
  ref = ast_ast_arena_type_alloc(arena);
  if (ref == 0)
    return 0;
  t = ast_arena_type_get(arena, ref);
  t.kind = type_kind;
  t.name_len = 0;
  t.elem_type_ref = 0;
  t.array_size = 0;
  t.region_label_len = 0;
  ast_arena_type_set(arena, ref, t);
  return ref;
}

/** 内建标量/void token → arena type ref。 */
static int32_t parser_asm_type_ref_from_builtin_token_c(void *arena, int32_t tok_kind) {
  switch (tok_kind) {
  case TOKEN_I32:
    return parser_asm_arena_alloc_scalar_type_c(arena, PARSER_ASM_TYPE_I32);
  case TOKEN_I64:
    return parser_asm_arena_alloc_scalar_type_c(arena, PARSER_ASM_TYPE_I64);
  case TOKEN_BOOL:
    return parser_asm_arena_alloc_scalar_type_c(arena, PARSER_ASM_TYPE_BOOL);
  case TOKEN_U8:
    return parser_asm_arena_alloc_scalar_type_c(arena, PARSER_ASM_TYPE_U8);
  case TOKEN_U32:
    return parser_asm_arena_alloc_scalar_type_c(arena, PARSER_ASM_TYPE_U32);
  case TOKEN_U64:
    return parser_asm_arena_alloc_scalar_type_c(arena, PARSER_ASM_TYPE_U64);
  case TOKEN_USIZE:
    return parser_asm_arena_alloc_scalar_type_c(arena, PARSER_ASM_TYPE_USIZE);
  case TOKEN_ISIZE:
    return parser_asm_arena_alloc_scalar_type_c(arena, PARSER_ASM_TYPE_ISIZE);
  case TOKEN_VOID:
    return parser_asm_arena_alloc_scalar_type_c(arena, PARSER_ASM_TYPE_VOID);
  case TOKEN_F32:
    return parser_asm_arena_alloc_scalar_type_c(arena, PARSER_ASM_TYPE_F32);
  case TOKEN_F64:
    return parser_asm_arena_alloc_scalar_type_c(arena, PARSER_ASM_TYPE_F64);
  default:
    return 0;
  }
}

/**
 * parser_alloc_vector_type_ref：分配 TYPE_VECTOR 节点（elem_ord 为 TypeKind 序数，lanes 为车道数）。
 */
int32_t parser_asm_alloc_vector_type_ref_c(void *arena, int32_t elem_ord, int32_t lanes) {
  int32_t elem_tr_v;
  int32_t vec_ref;
  struct ast_Type tv;
  elem_tr_v = pipeline_type_ensure_by_kind_ord(arena, elem_ord);
  if (elem_tr_v == 0)
    return 0;
  vec_ref = ast_ast_arena_type_alloc(arena);
  if (vec_ref == 0)
    return 0;
  tv = ast_arena_type_get(arena, vec_ref);
  tv.kind = PARSER_ASM_TYPE_VECTOR;
  tv.elem_type_ref = elem_tr_v;
  tv.array_size = lanes;
  tv.name_len = 0;
  tv.region_label_len = 0;
  ast_arena_type_set(arena, vec_ref, tv);
  return vec_ref;
}

/**
 * parser_vector_type_ref_from_ident_spelling：IDENT 拼写 i32x4 / Vec4f 等时返回 TYPE_VECTOR ref。
 */
int32_t parser_asm_vector_type_ref_from_ident_spelling_c(void *arena, struct parser_asm_slice_u8 *source,
                                                         struct parser_asm_lexer_result r) {
  int32_t nlen;
  uint8_t name_buf[64];
  nlen = r.tok.ident_len;
  if (nlen <= 0 || nlen > 63)
    return 0;
  parser_asm_copy_slice_to_name64_at_end_slice_c(source, r.next_lex.pos, nlen, name_buf);
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vector_type_ident_audit_c(source, r.token_start, nlen));
  if (nlen == 5 && name_buf[0] == 105 && name_buf[1] == 51 && name_buf[2] == 120 && name_buf[3] == 52)
    return parser_asm_alloc_vector_type_ref_c(arena, 0, 4);
  if (nlen == 5 && name_buf[0] == 105 && name_buf[1] == 51 && name_buf[2] == 120 && name_buf[3] == 56)
    return parser_asm_alloc_vector_type_ref_c(arena, 0, 8);
  if (nlen == 6 && name_buf[0] == 105 && name_buf[1] == 51 && name_buf[2] == 120 && name_buf[3] == 49 && name_buf[4] == 54)
    return parser_asm_alloc_vector_type_ref_c(arena, 0, 16);
  if (nlen == 5 && name_buf[0] == 117 && name_buf[1] == 51 && name_buf[2] == 120 && name_buf[3] == 52)
    return parser_asm_alloc_vector_type_ref_c(arena, 3, 4);
  if (nlen == 5 && name_buf[0] == 117 && name_buf[1] == 51 && name_buf[2] == 120 && name_buf[3] == 56)
    return parser_asm_alloc_vector_type_ref_c(arena, 3, 8);
  if (nlen == 6 && name_buf[0] == 117 && name_buf[1] == 51 && name_buf[2] == 120 && name_buf[3] == 49 && name_buf[4] == 54)
    return parser_asm_alloc_vector_type_ref_c(arena, 3, 16);
  if (nlen == 5 && name_buf[0] == 102 && name_buf[1] == 51 && name_buf[2] == 50 && name_buf[3] == 120 && name_buf[4] == 52)
    return parser_asm_alloc_vector_type_ref_c(arena, 13, 4);
  if (nlen == 5 && name_buf[0] == 86 && name_buf[1] == 101 && name_buf[2] == 99 && name_buf[3] == 52 && name_buf[4] == 102)
    return parser_asm_alloc_vector_type_ref_c(arena, 13, 4);
  if (nlen == 5 && name_buf[0] == 86 && name_buf[1] == 101 && name_buf[2] == 99 && name_buf[3] == 56 && name_buf[4] == 105)
    return parser_asm_alloc_vector_type_ref_c(arena, 0, 8);
  return 0;
}

/**
 * alloc_pointee_type_ref_from_tok：在 r 指向「*」后首 token 时写入 arena 元素类型 ref。
 */
int32_t parser_asm_alloc_pointee_type_ref_from_tok_c(void *arena, struct parser_asm_slice_u8 *source,
                                                       struct parser_asm_lexer_result *r) {
  int32_t elem_ref;
  struct ast_Type te;
  int32_t qn_len;
  if (!r || !source)
    return 0;
  if (!parser_asm_is_pointee_type_token_c(r->tok.kind))
    return 0;
  elem_ref = ast_ast_arena_type_alloc(arena);
  if (elem_ref == 0)
    return 0;
  te = ast_arena_type_get(arena, elem_ref);
  te.elem_type_ref = 0;
  te.array_size = 0;
  te.name_len = 0;
  te.region_label_len = 0;
  if (r->tok.kind == (int32_t)TOKEN_IDENT) {
    te.kind = PARSER_ASM_TYPE_NAMED;
    qn_len = 0;
    if (parser_asm_consume_qualified_type_ident_name_c(source, r, te.name, &qn_len) != 0)
      return 0;
    te.name_len = qn_len;
  } else if (r->tok.kind == (int32_t)TOKEN_I32) {
    te.kind = PARSER_ASM_TYPE_I32;
  } else if (r->tok.kind == (int32_t)TOKEN_I64) {
    te.kind = PARSER_ASM_TYPE_I64;
  } else if (r->tok.kind == (int32_t)TOKEN_BOOL) {
    te.kind = PARSER_ASM_TYPE_BOOL;
  } else if (r->tok.kind == (int32_t)TOKEN_U8) {
    te.kind = PARSER_ASM_TYPE_U8;
  } else if (r->tok.kind == (int32_t)TOKEN_U32) {
    te.kind = PARSER_ASM_TYPE_U32;
  } else if (r->tok.kind == (int32_t)TOKEN_U64) {
    te.kind = PARSER_ASM_TYPE_U64;
  } else if (r->tok.kind == (int32_t)TOKEN_USIZE) {
    te.kind = PARSER_ASM_TYPE_USIZE;
  } else if (r->tok.kind == (int32_t)TOKEN_ISIZE) {
    te.kind = PARSER_ASM_TYPE_ISIZE;
  } else if (r->tok.kind == (int32_t)TOKEN_F32) {
    te.kind = PARSER_ASM_TYPE_F32;
  } else if (r->tok.kind == (int32_t)TOKEN_F64) {
    te.kind = PARSER_ASM_TYPE_F64;
  } else {
    te.kind = PARSER_ASM_TYPE_VOID;
  }
  ast_arena_type_set(arena, elem_ref, te);
  return elem_ref;
}

/**
 * 解析 `T[]<label>` 后缀：空 `[]` 为 slice，可选 `<ident>` 域标签（M-3）。
 * lex 须已消费 `[`；若下一 token 不是 `]` 则返回 0。
 */
static int32_t parser_asm_parse_postfix_slice_type_ref_c(void *arena, int32_t elem_tr,
                                                         struct parser_asm_lexer lex,
                                                         struct parser_asm_slice_u8 *source,
                                                         struct parser_asm_lexer *out_lex) {
  struct parser_asm_lexer_result r;
  int32_t slice_ref;
  struct ast_Type ts;
  if (!out_lex || elem_tr == 0)
    return 0;
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_RBRACKET) {
    parser_asm_write_out_lex_c(out_lex, lex);
    return 0;
  }
  parser_asm_lex_from_result_val_into(&lex, r);
  slice_ref = ast_ast_arena_type_alloc(arena);
  if (slice_ref != 0) {
    ts = ast_arena_type_get(arena, slice_ref);
    ts.kind = PARSER_ASM_TYPE_SLICE;
    ts.elem_type_ref = elem_tr;
    ts.array_size = 0;
    ts.name_len = 0;
    ts.region_label_len = 0;
    lexer_next_into(&r, lex, source);
    if (r.tok.kind == (int32_t)TOKEN_LT) {
      parser_asm_lex_from_result_val_into(&lex, r);
      lexer_next_into(&r, lex, source);
      if (r.tok.kind != (int32_t)TOKEN_IDENT || r.tok.ident_len <= 0 || r.tok.ident_len > 63) {
        parser_asm_write_out_lex_c(out_lex, lex);
        return 0;
      }
      parser_asm_copy_slice_to_name64_slice_c(source, r.token_start, r.tok.ident_len, ts.region_label);
      ts.region_label_len = r.tok.ident_len;
      parser_asm_lex_from_result_val_into(&lex, r);
      lexer_next_into(&r, lex, source);
      if (r.tok.kind != (int32_t)TOKEN_GT) {
        parser_asm_write_out_lex_c(out_lex, lex);
        return 0;
      }
      parser_asm_lex_from_result_val_into(&lex, r);
    }
    ast_arena_type_set(arena, slice_ref, ts);
  }
  parser_asm_write_out_lex_c(out_lex, lex);
  return slice_ref;
}

/**
 * 解析内建/已分配元素类型后的后缀：`T[]` / `T[]<label>`（slice）或 `T[N]`（固定数组）。
 * lex 须已消费元素类型 token；若下一 token 不是 `[`，*out_lex 保持不动并返回 elem_tr。
 */
static int32_t parser_asm_parse_postfix_array_type_ref_c(void *arena, int32_t elem_tr,
                                                       struct parser_asm_lexer lex,
                                                       struct parser_asm_slice_u8 *source,
                                                       struct parser_asm_lexer *out_lex) {
  struct parser_asm_lexer_result r;
  int32_t asz;
  int32_t arr_ref;
  struct ast_Type ta;
  if (!out_lex || elem_tr == 0)
    return elem_tr;
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_LBRACKET) {
    parser_asm_write_out_lex_c(out_lex, lex);
    return elem_tr;
  }
  parser_asm_lex_from_result_val_into(&lex, r);
  lexer_next_into(&r, lex, source);
  /** M-3：`i32[]` / `i32[]<ra>` — 空 `[]` 为 slice，非固定数组 `T[N]`。 */
  if (r.tok.kind == (int32_t)TOKEN_RBRACKET) {
    return parser_asm_parse_postfix_slice_type_ref_c(arena, elem_tr, lex, source, out_lex);
  }
  if (r.tok.kind != (int32_t)TOKEN_INT || r.tok.int_val <= 0) {
    parser_asm_write_out_lex_c(out_lex, lex);
    return 0;
  }
  asz = r.tok.int_val;
  parser_asm_lex_from_result_val_into(&lex, r);
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_RBRACKET) {
    parser_asm_write_out_lex_c(out_lex, lex);
    return 0;
  }
  parser_asm_lex_from_result_val_into(&lex, r);
  arr_ref = ast_ast_arena_type_alloc(arena);
  if (arr_ref != 0) {
    ta = ast_arena_type_get(arena, arr_ref);
    ta.kind = PARSER_ASM_TYPE_ARRAY;
    ta.elem_type_ref = elem_tr;
    ta.array_size = asz;
    ta.name_len = 0;
    ta.region_label_len = 0;
    ast_arena_type_set(arena, arr_ref, ta);
  }
  parser_asm_write_out_lex_c(out_lex, lex);
  return arr_ref;
}

/**
 * parse_type_ref_for_arena_into：从 lex 解析类型写入 arena，成功返回 type ref。
 */
static int32_t parser_asm_parse_type_ref_impl_c(void *arena, struct parser_asm_lexer lex,
                                                                struct parser_asm_slice_u8 *source,
                                                                struct parser_asm_lexer *out_lex) {
  struct parser_asm_lexer_result r;
  int32_t ptr_depth;
  int32_t elem_ref;
  int32_t type_ref_param;
  struct ast_Type t;
  int32_t slice_elem_tr;
  int32_t slice_ref;
  struct ast_Type ts;
  int32_t asz;
  int32_t elem_tr;
  int32_t arr_ref;
  struct ast_Type ta;
  int32_t elem_ord;
  int32_t lanes;
  int32_t vec_ref;
  int32_t type_ref_scalar;
  uint8_t linear_spell[6];
  uint8_t linear_buf[64];
  int32_t li;
  int32_t linear_match;
  int32_t inner_linear_tr;
  int32_t linear_ref;
  struct ast_Type tl;
  int32_t vec_ident_ref;
  int32_t qn_len_tr;
  if (!source || !out_lex)
    return 0;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_type_ref_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_type_ref_mega_full_deep_audit_c(lex, source));
  lexer_next_into(&r, lex, source);
  if (r.tok.kind == (int32_t)TOKEN_STAR) {
    ptr_depth = 0;
    while (r.tok.kind == (int32_t)TOKEN_STAR) {
      ++ptr_depth;
      parser_asm_lex_from_result_val_into(&lex, r);
      lexer_next_into(&r, lex, source);
    }
    elem_ref = parser_asm_alloc_pointee_type_ref_from_tok_c(arena, source, &r);
    if (elem_ref == 0) {
      parser_asm_write_out_lex_c(out_lex, lex);
      return 0;
    }
    parser_asm_lex_from_result_val_into(&lex, r);
    while (ptr_depth > 0) {
      type_ref_param = ast_ast_arena_type_alloc(arena);
      if (type_ref_param == 0) {
        parser_asm_write_out_lex_c(out_lex, lex);
        return 0;
      }
      t = ast_arena_type_get(arena, type_ref_param);
      t.kind = PARSER_ASM_TYPE_PTR;
      t.elem_type_ref = elem_ref;
      t.name_len = 0;
      t.array_size = 0;
      t.region_label_len = 0;
      ast_arena_type_set(arena, type_ref_param, t);
      elem_ref = type_ref_param;
      --ptr_depth;
    }
    /** C 风格后缀：*T[N] 为 N 个 T 指针的固定数组（如 *u8[2]）。 */
    return parser_asm_parse_postfix_array_type_ref_c(arena, elem_ref, lex, source, out_lex);
  }
  if (r.tok.kind == (int32_t)TOKEN_LBRACKET) {
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_slice_type_bracket_audit_c(lex, source));
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_array_type_bracket_audit_c(lex, source));
    parser_asm_lex_from_result_val_into(&lex, r);
    lexer_next_into(&r, lex, source);
    if (r.tok.kind == (int32_t)TOKEN_RBRACKET) {
      parser_asm_lex_from_result_val_into(&lex, r);
      slice_elem_tr = parser_asm_parse_type_ref_impl_c(arena, lex, source, &lex);
      if (slice_elem_tr == 0) {
        parser_asm_write_out_lex_c(out_lex, lex);
        return 0;
      }
      slice_ref = ast_ast_arena_type_alloc(arena);
      if (slice_ref != 0) {
        ts = ast_arena_type_get(arena, slice_ref);
        ts.kind = PARSER_ASM_TYPE_SLICE;
        ts.elem_type_ref = slice_elem_tr;
        ts.array_size = 0;
        ts.name_len = 0;
        ts.region_label_len = 0;
        lexer_next_into(&r, lex, source);
        if (r.tok.kind == (int32_t)TOKEN_LT) {
          parser_asm_lex_from_result_val_into(&lex, r);
          lexer_next_into(&r, lex, source);
          if (r.tok.kind != (int32_t)TOKEN_IDENT || r.tok.ident_len <= 0 || r.tok.ident_len > 63) {
            parser_asm_write_out_lex_c(out_lex, lex);
            return 0;
          }
          parser_asm_copy_slice_to_name64_slice_c(source, r.token_start, r.tok.ident_len, ts.region_label);
          ts.region_label_len = r.tok.ident_len;
          parser_asm_lex_from_result_val_into(&lex, r);
          lexer_next_into(&r, lex, source);
          if (r.tok.kind != (int32_t)TOKEN_GT) {
            parser_asm_write_out_lex_c(out_lex, lex);
            return 0;
          }
          parser_asm_lex_from_result_val_into(&lex, r);
        }
        ast_arena_type_set(arena, slice_ref, ts);
      }
      parser_asm_write_out_lex_c(out_lex, lex);
      return slice_ref;
    }
    if (r.tok.kind != (int32_t)TOKEN_INT) {
      parser_asm_write_out_lex_c(out_lex, lex);
      return 0;
    }
    asz = r.tok.int_val;
    parser_asm_lex_from_result_val_into(&lex, r);
    lexer_next_into(&r, lex, source);
    if (r.tok.kind != (int32_t)TOKEN_RBRACKET) {
      parser_asm_write_out_lex_c(out_lex, lex);
      return 0;
    }
    parser_asm_lex_from_result_val_into(&lex, r);
    elem_tr = parser_asm_parse_type_ref_impl_c(arena, lex, source, &lex);
    if (elem_tr == 0) {
      parser_asm_write_out_lex_c(out_lex, lex);
      return 0;
    }
    arr_ref = ast_ast_arena_type_alloc(arena);
    if (arr_ref != 0) {
      ta = ast_arena_type_get(arena, arr_ref);
      ta.kind = PARSER_ASM_TYPE_ARRAY;
      ta.elem_type_ref = elem_tr;
      ta.array_size = asz;
      ta.name_len = 0;
      ta.region_label_len = 0;
      ast_arena_type_set(arena, arr_ref, ta);
    }
    parser_asm_write_out_lex_c(out_lex, lex);
    return arr_ref;
  }
  if (r.tok.kind == (int32_t)TOKEN_I32X4 || r.tok.kind == (int32_t)TOKEN_I32X8 || r.tok.kind == (int32_t)TOKEN_I32X16
      || r.tok.kind == (int32_t)TOKEN_U32X4 || r.tok.kind == (int32_t)TOKEN_U32X8 || r.tok.kind == (int32_t)TOKEN_U32X16
      || r.tok.kind == (int32_t)TOKEN_F32X4) {
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_builtin_vec_token_audit_c(r.tok.kind));
    elem_ord = 0;
    lanes = 4;
    if (r.tok.kind == (int32_t)TOKEN_U32X4 || r.tok.kind == (int32_t)TOKEN_U32X8
        || r.tok.kind == (int32_t)TOKEN_U32X16)
      elem_ord = 3;
    if (r.tok.kind == (int32_t)TOKEN_F32X4)
      elem_ord = 13;
    if (r.tok.kind == (int32_t)TOKEN_I32X8 || r.tok.kind == (int32_t)TOKEN_U32X8)
      lanes = 8;
    if (r.tok.kind == (int32_t)TOKEN_I32X16 || r.tok.kind == (int32_t)TOKEN_U32X16)
      lanes = 16;
    vec_ref = parser_asm_alloc_vector_type_ref_c(arena, elem_ord, lanes);
    parser_asm_lex_from_result_val_into(&lex, r);
    parser_asm_write_out_lex_c(out_lex, lex);
    return vec_ref;
  }
  if (r.tok.kind == (int32_t)TOKEN_I32 || r.tok.kind == (int32_t)TOKEN_BOOL || r.tok.kind == (int32_t)TOKEN_I64
      || r.tok.kind == (int32_t)TOKEN_U8 || r.tok.kind == (int32_t)TOKEN_U32 || r.tok.kind == (int32_t)TOKEN_U64
      || r.tok.kind == (int32_t)TOKEN_USIZE || r.tok.kind == (int32_t)TOKEN_ISIZE || r.tok.kind == (int32_t)TOKEN_VOID
      || r.tok.kind == (int32_t)TOKEN_F32 || r.tok.kind == (int32_t)TOKEN_F64) {
    type_ref_scalar = parser_asm_type_ref_from_builtin_token_c(arena, r.tok.kind);
    parser_asm_lex_from_result_val_into(&lex, r);
    return parser_asm_parse_postfix_array_type_ref_c(arena, type_ref_scalar, lex, source, out_lex);
  }
  if (r.tok.kind == (int32_t)TOKEN_IDENT) {
    if (r.tok.ident_len == 6) {
      linear_spell[0] = 76;
      linear_spell[1] = 105;
      linear_spell[2] = 110;
      linear_spell[3] = 101;
      linear_spell[4] = 97;
      linear_spell[5] = 114;
      parser_asm_copy_slice_to_name64_slice_c(source, r.token_start, 6, linear_buf);
      linear_match = 1;
      for (li = 0; li < 6; li++) {
        if (linear_buf[li] != linear_spell[li])
          linear_match = 0;
      }
      if (linear_match) {
        PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_linear_type_audit_c(lex, source));
        parser_asm_lex_from_result_val_into(&lex, r);
        lexer_next_into(&r, lex, source);
        if (r.tok.kind != (int32_t)TOKEN_LPAREN) {
          parser_asm_write_out_lex_c(out_lex, lex);
          return 0;
        }
        parser_asm_lex_from_result_val_into(&lex, r);
        inner_linear_tr = parser_asm_parse_type_ref_impl_c(arena, lex, source, &lex);
        if (inner_linear_tr == 0) {
          parser_asm_write_out_lex_c(out_lex, lex);
          return 0;
        }
        lexer_next_into(&r, lex, source);
        if (r.tok.kind != (int32_t)TOKEN_RPAREN) {
          parser_asm_write_out_lex_c(out_lex, lex);
          return 0;
        }
        parser_asm_lex_from_result_val_into(&lex, r);
        linear_ref = ast_ast_arena_type_alloc(arena);
        if (linear_ref != 0) {
          tl = ast_arena_type_get(arena, linear_ref);
          tl.kind = PARSER_ASM_TYPE_LINEAR;
          tl.elem_type_ref = inner_linear_tr;
          tl.array_size = 0;
          tl.name_len = 0;
          tl.region_label_len = 0;
          ast_arena_type_set(arena, linear_ref, tl);
        }
        parser_asm_write_out_lex_c(out_lex, lex);
        return linear_ref;
      }
    }
    vec_ident_ref = parser_asm_vector_type_ref_from_ident_spelling_c(arena, source, r);
    if (vec_ident_ref == 0 && r.tok.kind == (int32_t)TOKEN_IDENT && r.tok.ident_len > 0)
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vector_type_ident_audit_c(source, r.token_start, r.tok.ident_len));
    if (vec_ident_ref != 0) {
      parser_asm_lex_from_result_val_into(&lex, r);
      parser_asm_write_out_lex_c(out_lex, lex);
      return vec_ident_ref;
    }
    type_ref_param = ast_ast_arena_type_alloc(arena);
    if (type_ref_param != 0) {
      t = ast_arena_type_get(arena, type_ref_param);
      t.kind = PARSER_ASM_TYPE_NAMED;
      qn_len_tr = 0;
      if (parser_asm_consume_qualified_type_ident_name_c(source, &r, t.name, &qn_len_tr) != 0) {
        parser_asm_write_out_lex_c(out_lex, lex);
        return 0;
      }
      t.name_len = qn_len_tr;
      t.elem_type_ref = 0;
      t.array_size = 0;
      t.region_label_len = 0;
      ast_arena_type_set(arena, type_ref_param, t);
    }
    parser_asm_lex_from_result_val_into(&lex, r);
    return parser_asm_parse_postfix_array_type_ref_c(arena, type_ref_param, lex, source, out_lex);
  }
  parser_asm_write_out_lex_c(out_lex, lex);
  return 0;
}

/** parse_type_ref_for_arena_into slice 路径公开入口。 */
int32_t parser_asm_parse_type_ref_for_arena_into_slice_c(void *arena, struct parser_asm_lexer lex,
                                                         struct parser_asm_slice_u8 *source,
                                                         struct parser_asm_lexer *out_lex) {
  return parser_asm_parse_type_ref_impl_c(arena, lex, source, out_lex);
}

#endif /* PARSER_ASM_TYPE_REF_SLICE_INCLUDED */
