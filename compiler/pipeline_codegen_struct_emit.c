/* ============================================================================
 * pipeline_codegen_struct_emit.c — C co-emit struct tag + outbuf + field emit
 *
 * wave1250 BC 8.3.2 G.7 same-TU domain fold from ast_pool.c:
 *   c_file_prologue_done get/set/reset + struct_tag_try_claim
 *   codegen_outbuf append (bytes/byte/format_int) + emit_struct_field_type_inner
 *   emit_struct_field_type + emit_struct_field_decl
 *
 * Single-file C co-emit guard: header + dep types + forward emit once.
 * Included from ast_pool.c (replaces former inline body). Not a separate .o.
 *
 * PLATFORM: SHARED.
 * ============================================================================ */
/**
 * 单文件 C co-emit：header + 全 dep 类型 + forward 只允许 emit 一次。
 * pipeline 对每个 dep 与 entry 各调 codegen_x_ast；无此标志会中途再 #include、enum redefinition。
 */
static int g_codegen_c_file_prologue_done;

/** 单文件内已完整 emit 的 struct tag（prefix+name）；防 co-emit 对同一 tag 二次 struct { }。 */
#define PIPELINE_CODEGEN_STRUCT_TAG_MAX 256
#define PIPELINE_CODEGEN_STRUCT_TAG_CAP 128
static char g_codegen_struct_tags[PIPELINE_CODEGEN_STRUCT_TAG_MAX][PIPELINE_CODEGEN_STRUCT_TAG_CAP];
static int g_codegen_struct_tag_n;

int32_t pipeline_codegen_c_file_prologue_done_get(void) {
  return g_codegen_c_file_prologue_done;
}

void pipeline_codegen_c_file_prologue_done_set(int32_t v) {
  g_codegen_c_file_prologue_done = v != 0 ? 1 : 0;
}

void pipeline_codegen_c_file_prologue_done_reset(void) {
  g_codegen_c_file_prologue_done = 0;
  g_codegen_struct_tag_n = 0;
}

/**
 * 尝试声明本单元首次完整 emit 该 C struct tag。
 * 返回 1：首次，调用方应 emit 定义；0：已 emit，应跳过；-1：参数非法。
 * tag = (prefix_len>0 ? prefix : "") + name。
 */
int32_t pipeline_codegen_struct_tag_try_claim(const uint8_t *prefix, int32_t prefix_len, const uint8_t *name,
                                             int32_t name_len) {
  char tag[PIPELINE_CODEGEN_STRUCT_TAG_CAP];
  int32_t i;
  int32_t tlen;
  if (!name || name_len <= 0)
    return -1;
  if (prefix_len < 0)
    prefix_len = 0;
  if (!prefix)
    prefix_len = 0;
  tlen = prefix_len + name_len;
  if (tlen <= 0 || tlen >= PIPELINE_CODEGEN_STRUCT_TAG_CAP)
    return -1;
  if (prefix_len > 0)
    memcpy(tag, prefix, (size_t)prefix_len);
  memcpy(tag + prefix_len, name, (size_t)name_len);
  tag[tlen] = '\0';
  for (i = 0; i < g_codegen_struct_tag_n; i++) {
    if (strcmp(g_codegen_struct_tags[i], tag) == 0)
      return 0;
  }
  if (g_codegen_struct_tag_n >= PIPELINE_CODEGEN_STRUCT_TAG_MAX)
    return 0; /* 表满：保守跳过再 emit，避免 redefinition */
  memcpy(g_codegen_struct_tags[g_codegen_struct_tag_n], tag, (size_t)tlen + 1);
  g_codegen_struct_tag_n++;
  return 1;
}

/** 前向声明：CodegenOutBuf 追加（layout 与 codegen.x 一致）。 */
struct codegen_CodegenOutBuf;

/** 向 CodegenOutBuf 追加字节；0 成功，-1 溢出。 */
static int32_t pipeline_codegen_out_append_bytes(struct codegen_CodegenOutBuf *out, const uint8_t *p, int32_t n) {
  int32_t len;
  uint8_t *data;
  int32_t i;
  if (!out || !p || n < 0)
    return -1;
  len = codegen_out_buf_len(out);
  if (len + n > (int32_t)PIPELINE_CODEGEN_OUTBUF_CAP)
    return -1;
  data = (uint8_t *)out;
  for (i = 0; i < n; i++)
    data[len + i] = p[i];
  codegen_out_buf_set_len(out, len + n);
  return 0;
}

/** 向 CodegenOutBuf 追加单字节。 */
static int32_t pipeline_codegen_out_append_byte(struct codegen_CodegenOutBuf *out, uint8_t b) {
  return pipeline_codegen_out_append_bytes(out, &b, 1);
}

/** 向 CodegenOutBuf 追加十进制整数。 */
static int32_t pipeline_codegen_out_format_int(struct codegen_CodegenOutBuf *out, int32_t val) {
  char buf[16];
  int n;
  if (!out)
    return -1;
  n = snprintf(buf, sizeof(buf), "%d", (int)val);
  if (n <= 0 || n >= (int)sizeof(buf))
    return -1;
  return pipeline_codegen_out_append_bytes(out, (const uint8_t *)buf, n);
}

/** emit_struct_field_type_via_pipeline 递归核心（ord 与 ast.x TypeKind 一致）。 */
static int32_t pipeline_codegen_emit_struct_field_type_inner(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                                             int32_t type_ref, uint8_t *struct_prefix,
                                                             int32_t struct_prefix_len) {
  static uint8_t scratch[256];
  int32_t ord;
  int32_t inner;
  int32_t asz;
  int32_t ik;
  int32_t lanes_v;
  int32_t nl;
  int32_t sn;
  uint8_t nm[128];

  ord = pipeline_type_kind_ord_at(arena, type_ref);
  if (!arena || type_ref <= 0 || ord < 0) {
    static const uint8_t k_i32[7] = {'i', 'n', 't', '3', '2', '_', 't'};
    return pipeline_codegen_out_append_bytes(out, k_i32, 7);
  }
  if (ord == 9) {
    inner = pipeline_type_elem_ref_at(arena, type_ref);
    if (pipeline_codegen_emit_struct_field_type_inner(arena, out, inner, struct_prefix, struct_prefix_len) != 0)
      return -1;
    if (pipeline_codegen_out_append_byte(out, (uint8_t)' ') != 0)
      return -1;
    return pipeline_codegen_out_append_byte(out, (uint8_t)'*');
  }
  if (ord == 10) {
    inner = pipeline_type_elem_ref_at(arena, type_ref);
    asz = pipeline_type_array_size_at(arena, type_ref);
    if (pipeline_codegen_emit_struct_field_type_inner(arena, out, inner, struct_prefix, struct_prefix_len) != 0)
      return -1;
    if (pipeline_codegen_out_append_byte(out, (uint8_t)'[') != 0)
      return -1;
    if (pipeline_codegen_out_format_int(out, asz) != 0)
      return -1;
    return pipeline_codegen_out_append_byte(out, (uint8_t)']');
  }
  if (ord == 8) {
    static const uint8_t hdr[7] = {'s', 't', 'r', 'u', 'c', 't', ' '};
    nl = pipeline_type_named_name_into(arena, type_ref, nm);
    if (nl <= 0) {
      static const uint8_t k_i32[7] = {'i', 'n', 't', '3', '2', '_', 't'};
      return pipeline_codegen_out_append_bytes(out, k_i32, 7);
    }
    if (pipeline_codegen_out_append_bytes(out, hdr, 7) != 0)
      return -1;
    if (struct_prefix && struct_prefix_len > 0) {
      if (pipeline_codegen_out_append_bytes(out, struct_prefix, struct_prefix_len) != 0)
        return -1;
    }
    /* wave624: empty prefix → bare name (entry); match type_to_c_repr_inner. */
    return pipeline_codegen_out_append_bytes(out, nm, nl);
  }
  if (ord == 11) {
    nl = pipeline_codegen_type_to_c_repr_inner(arena, scratch, 256, type_ref, struct_prefix, struct_prefix_len);
    if (nl <= 0)
      return -1;
    return pipeline_codegen_out_append_bytes(out, scratch, nl);
  }
  if (ord == 12) {
    inner = pipeline_type_elem_ref_at(arena, type_ref);
    return pipeline_codegen_emit_struct_field_type_inner(arena, out, inner, struct_prefix, struct_prefix_len);
  }
  if (ord == 13) {
    lanes_v = pipeline_type_array_size_at(arena, type_ref);
    inner = pipeline_type_elem_ref_at(arena, type_ref);
    ik = pipeline_type_kind_ord_at(arena, inner);
    sn = pipeline_codegen_vector_type_copy(scratch, 256, ik, lanes_v);
    if (sn > 0)
      return pipeline_codegen_out_append_bytes(out, scratch, sn);
    sn = pipeline_codegen_type_kind_copy(scratch, 256, 0);
    if (sn > 0)
      return pipeline_codegen_out_append_bytes(out, scratch, sn);
    return -1;
  }
  sn = pipeline_codegen_type_kind_copy(scratch, 256, ord);
  if (sn > 0)
    return pipeline_codegen_out_append_bytes(out, scratch, sn);
  sn = pipeline_codegen_type_kind_copy(scratch, 256, 0);
  if (sn > 0)
    return pipeline_codegen_out_append_bytes(out, scratch, sn);
  return -1;
}

/**
 * codegen.x emit_struct_field_type_via_pipeline 的 C glue：dep prerun 全量 typeck 时避免 X 大函数失败。
 */
int32_t pipeline_codegen_emit_struct_field_type(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                              int32_t type_ref, uint8_t *struct_prefix, int32_t struct_prefix_len) {
  return pipeline_codegen_emit_struct_field_type_inner(arena, out, type_ref, struct_prefix, struct_prefix_len);
}

/**
 * 结构体字段声明发射：
 * - 普通字段：`type name`
 * - 数组字段：`type name[n][m]`
 * 仅剥离最外层数组链，保留内层类型（如指针）由原 type emitter 输出。
 */
int32_t pipeline_codegen_emit_struct_field_decl(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                                int32_t type_ref, uint8_t *field_name, int32_t field_name_len,
                                                uint8_t *struct_prefix, int32_t struct_prefix_len) {
  int32_t base_type_ref;
  int32_t dims[8];
  int32_t ndim;
  int32_t i;

  if (!arena || !out || type_ref <= 0 || !field_name || field_name_len <= 0)
    return -1;

  base_type_ref = type_ref;
  ndim = 0;
  while (base_type_ref > 0 && pipeline_type_kind_ord_at(arena, base_type_ref) == 10 && ndim < 8) {
    dims[ndim] = pipeline_type_array_size_at(arena, base_type_ref);
    base_type_ref = pipeline_type_elem_ref_at(arena, base_type_ref);
    ndim++;
  }

  if (pipeline_codegen_emit_struct_field_type_inner(arena, out, base_type_ref, struct_prefix, struct_prefix_len) != 0)
    return -1;
  if (pipeline_codegen_out_append_byte(out, (uint8_t)' ') != 0)
    return -1;
  if (pipeline_codegen_out_append_bytes(out, field_name, field_name_len) != 0)
    return -1;
  for (i = 0; i < ndim; i++) {
    if (pipeline_codegen_out_append_byte(out, (uint8_t)'[') != 0)
      return -1;
    if (pipeline_codegen_out_format_int(out, dims[i]) != 0)
      return -1;
    if (pipeline_codegen_out_append_byte(out, (uint8_t)']') != 0)
      return -1;
  }
  return 0;
}
