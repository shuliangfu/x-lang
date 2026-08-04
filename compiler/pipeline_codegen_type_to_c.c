/* ============================================================================
 * pipeline_codegen_type_to_c.c — TypeKind/VECTOR → C type name repr
 *
 * wave1248 BC 8.3.2 G.7 same-TU domain fold from ast_pool.c:
 *   type_kind_cstr/copy + vector_type_cstr/copy + type_kind_append
 *   type_to_c_repr_inner (recursive core) + type_to_c_repr (entry)
 *
 * Authority for type_to_c_repr / TYPE_SLICE tags (struct xlang_slice_<elemC>).
 * F32/F64/VOID ordinals match ast.x TypeKind (wave618 Cap residual fix).
 * Included from ast_pool.c (replaces former inline body). Not a separate .o.
 *
 * PLATFORM: SHARED.
 * ============================================================================ */
/**
 * codegen.x: TypeKind builtin → C type name; length, *out_ptr to static string; 0 if unsupported.
 * PLATFORM: SHARED — authority for type_to_c_repr / TYPE_SLICE tags (struct xlang_slice_<elemC>).
 *
 * wave618 Cap residual pure: F32/F64/VOID ordinals must match ast.x TypeKind:
 *   0=I32 … 7=ISIZE, 8=NAMED, 9=PTR, 10=ARRAY, 11=SLICE, 12=LINEAR, 13=VECTOR,
 *   14=F32, 15=F64, 16=VOID.
 * Prior switch used 11/12/13 for float/double/void (pre-LINEAR/VECTOR enum drift).
 * TYPE_F32 (14) then fell through default → type_to_c_repr fallback int32_t →
 * `let a: f32[] = [10.0, 32.0]` emitted `struct xlang_slice_int32_t` while payload
 * was `static float[]`. host-cc -O2 UB (int loads of float bits + integer add) →
 * mac host-C run wrong (e.g. 0x41200000+0x42000000). G.7: fix this table only.
 */
int32_t pipeline_codegen_type_kind_cstr(int32_t kind, uint8_t **out_ptr) {
  static const char *k_i32 = "int32_t";
  static const char *k_i64 = "int64_t";
  static const char *k_bool = "int";
  static const char *k_u8 = "uint8_t";
  static const char *k_u32 = "uint32_t";
  static const char *k_u64 = "uint64_t";
  static const char *k_f32 = "float";
  static const char *k_f64 = "double";
  static const char *k_void = "void";
  static const char *k_usize = "size_t";
  static const char *k_isize = "ssize_t";
  if (!out_ptr)
    return 0;
  *out_ptr = NULL;
  switch (kind) {
  case 0: /* TYPE_I32 */
    *out_ptr = (uint8_t *)k_i32;
    return 7;
  case 1: /* TYPE_BOOL */
    *out_ptr = (uint8_t *)k_bool;
    return 3;
  case 2: /* TYPE_U8 */
    *out_ptr = (uint8_t *)k_u8;
    return 7;
  case 3: /* TYPE_U32 */
    *out_ptr = (uint8_t *)k_u32;
    return 8;
  case 4: /* TYPE_U64 */
    *out_ptr = (uint8_t *)k_u64;
    return 8;
  case 5: /* TYPE_I64 */
    *out_ptr = (uint8_t *)k_i64;
    return 7;
  case 6: /* TYPE_USIZE */
    *out_ptr = (uint8_t *)k_usize;
    return 6;
  case 7: /* TYPE_ISIZE */
    *out_ptr = (uint8_t *)k_isize;
    return 7;
  /* 8..13: NAMED/PTR/ARRAY/SLICE/LINEAR/VECTOR — handled in type_to_c_repr_inner */
  case 14: /* TYPE_F32 — wave618: was wrongly case 11 (TYPE_SLICE) */
    *out_ptr = (uint8_t *)k_f32;
    return 5;
  case 15: /* TYPE_F64 — wave618: was wrongly case 12 (TYPE_LINEAR) */
    *out_ptr = (uint8_t *)k_f64;
    return 6;
  case 16: /* TYPE_VOID — wave618: was wrongly case 13 (TYPE_VECTOR) */
    *out_ptr = (uint8_t *)k_void;
    return 4;
  default:
    return 0;
  }
}

/** codegen.x：将 TypeKind C 名写入 dst，返回字节数；-1 缓冲不足或不支持。 */
int32_t pipeline_codegen_type_kind_copy(uint8_t *dst, int32_t cap, int32_t kind) {
  uint8_t *s;
  int32_t n;
  int32_t i;
  n = pipeline_codegen_type_kind_cstr(kind, &s);
  if (n <= 0 || !s || !dst || cap < n)
    return n <= 0 ? -1 : -1;
  for (i = 0; i < n; i++)
    dst[i] = s[i];
  return n;
}

/** codegen.x：VECTOR 类型 C 名（elem_kind=ord_i32/u32/f32，lanes=4/8/16）；无匹配 0。
 * PLATFORM: SHARED — used by both C and asm backends via type_to_c_repr_inner.
 * elem_kind is the ord value returned by pipeline_type_kind_ord_at:
 *   0=I32, 3=U32, 14=F32 (see typeck.x ord_i32/ord_u32/ord_f32). */
int32_t pipeline_codegen_vector_type_cstr(int32_t elem_kind, int32_t lanes, uint8_t **out_ptr) {
  if (!out_ptr)
    return 0;
  *out_ptr = NULL;
  if (elem_kind == 0) {
    if (lanes == 4) {
      *out_ptr = (uint8_t *)"i32x4_t";
      return 7;
    }
    if (lanes == 8) {
      *out_ptr = (uint8_t *)"i32x8_t";
      return 7;
    }
    if (lanes == 16) {
      *out_ptr = (uint8_t *)"i32x16_t";
      return 8;
    }
  }
  if (elem_kind == 3) {
    if (lanes == 4) {
      *out_ptr = (uint8_t *)"u32x4_t";
      return 7;
    }
    if (lanes == 8) {
      *out_ptr = (uint8_t *)"u32x8_t";
      return 7;
    }
    if (lanes == 16) {
      *out_ptr = (uint8_t *)"u32x16_t";
      return 8;
    }
  }
  /* F32 vector (Vec4f / f32x4 / f32x8 / f32x16). elem_kind=14 == ord_f32.
   * Without this branch, Vec4f falls back to int32_t and collides with
   * Vec8i (i32x8_t) when both overload `add`/`sub`/`mul` etc. */
  if (elem_kind == 14) {
    if (lanes == 4) {
      *out_ptr = (uint8_t *)"f32x4_t";
      return 7;
    }
    if (lanes == 8) {
      *out_ptr = (uint8_t *)"f32x8_t";
      return 7;
    }
    if (lanes == 16) {
      *out_ptr = (uint8_t *)"f32x16_t";
      return 8;
    }
  }
  return 0;
}

/** codegen.x：VECTOR 类型 C 名写入 dst；无匹配 -1。 */
int32_t pipeline_codegen_vector_type_copy(uint8_t *dst, int32_t cap, int32_t elem_kind, int32_t lanes) {
  uint8_t *s;
  int32_t n;
  int32_t i;
  n = pipeline_codegen_vector_type_cstr(elem_kind, lanes, &s);
  if (n <= 0 || !s || !dst || cap < n)
    return -1;
  for (i = 0; i < n; i++)
    dst[i] = s[i];
  return n;
}

/** codegen.x：将 TypeKind C 名追加到 scratch[w..)，返回下一写位置；-1 溢出或不支持。 */
int32_t pipeline_codegen_type_kind_append(uint8_t *scratch, int32_t cap, int32_t w, int32_t kind) {
  uint8_t *s;
  int32_t n;
  int32_t i;
  n = pipeline_codegen_type_kind_cstr(kind, &s);
  if (n <= 0 || !s)
    return -1;
  for (i = 0; i < n; i++) {
    if (w >= cap - 1)
      return -1;
    scratch[w++] = s[i];
  }
  return w;
}

/** 前向声明：TYPE_NAMED 名写入 out64。 */
extern int32_t pipeline_type_named_name_into(struct ast_ASTArena *arena, int32_t ref, uint8_t *out64);

/**
 * codegen.x type_to_c_repr 递归核心：经 pipeline_* 读类型池，写入 scratch（无 NUL）。
 * 对齐 codegen.x / codegen.c c_type_to_buf 的简化子集；返回字节数，-1 缓冲不足。
 */
static int32_t pipeline_codegen_type_to_c_repr_inner(struct ast_ASTArena *arena, uint8_t *scratch, int32_t cap,
                                                     int32_t type_ref, uint8_t *struct_prefix,
                                                     int32_t struct_prefix_len) {
  /*
   * wave691 Cap residual pure: recursive TYPE_SLICE/TYPE_PTR must use stack
   * scratch for the elem walk. Prior static inner/eb re-entered when building
   * [][]T: outer called with scratch=eb, inner TYPE_SLICE wrote hdr into the
   * same buffer while still reading elem C name → tag became
   * `struct xlang_slice_xlang_slice_struct` (incomplete) instead of
   * `struct xlang_slice_xlang_slice_int32_t`. G.7: single type_to_c_repr authority.
   * PLATFORM: SHARED host-C.
   */
  uint8_t inner[256];
  uint8_t eb[256];
  int32_t tk;
  int32_t elem_ref;
  int32_t arr_sz;
  int32_t elem_kind;
  int32_t n;
  int32_t j;
  int32_t sp;
  int32_t plen;
  int32_t pi;
  int32_t hi;
  int32_t w;
  int32_t h;
  int32_t name_len;
  uint8_t nm[128];
  int32_t sn;

  if (cap < 16)
    return -1;
  if (!arena || type_ref <= 0 || type_ref > arena->num_types) {
    static const uint8_t k_i32[7] = {'i', 'n', 't', '3', '2', '_', 't'};
    if (cap < 7)
      return -1;
    for (j = 0; j < 7; j++)
      scratch[j] = k_i32[j];
    return 7;
  }
  tk = pipeline_type_kind_ord_at(arena, type_ref);
  elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
  arr_sz = pipeline_type_array_size_at(arena, type_ref);
  if (tk == 9 && elem_ref > 0) {
    n = pipeline_codegen_type_to_c_repr_inner(arena, inner, 256, elem_ref, struct_prefix, struct_prefix_len);
    if (n < 0 || n + 2 >= cap)
      return -1;
    for (j = 0; j < n; j++)
      scratch[j] = inner[j];
    scratch[n] = (uint8_t)' ';
    scratch[n + 1] = (uint8_t)'*';
    return n + 2;
  }
  if (tk == 10 && elem_ref > 0)
    return pipeline_codegen_type_to_c_repr_inner(arena, scratch, cap, elem_ref, struct_prefix, struct_prefix_len);
  if (tk == 13 && elem_ref > 0) {
    elem_kind = pipeline_type_kind_ord_at(arena, elem_ref);
    n = pipeline_codegen_vector_type_copy(scratch, cap, elem_kind, arr_sz);
    if (n >= 0)
      return n;
    return pipeline_codegen_type_kind_copy(scratch, cap, 0);
  }
  if (tk == 12 && elem_ref > 0)
    return pipeline_codegen_type_to_c_repr_inner(arena, scratch, cap, elem_ref, struct_prefix, struct_prefix_len);
  if (tk == 11 && elem_ref > 0) {
    n = pipeline_codegen_type_to_c_repr_inner(arena, eb, 256, elem_ref, struct_prefix, struct_prefix_len);
    if (n < 0 || n >= 256)
      return -1;
    sp = 0;
    if (n >= 7 && eb[0] == 's' && eb[1] == 't' && eb[2] == 'r' && eb[3] == 'u' && eb[4] == 'c' && eb[5] == 't'
        && eb[6] == ' ') {
      sp = 7;
      while (sp < n && eb[sp] == ' ')
        sp++;
    }
    plen = n - sp;
    if (plen <= 0 || 19 + plen >= cap)
      return -1;
    {
      /* ABI 与 runtime_slice_glue / seeds 一致：struct xlang_slice_<elemC> */
      /* "struct xlang_slice_" = 19 bytes */
      static const uint8_t hdr[19] = {'s', 't', 'r', 'u', 'c', 't', ' ', 'x', 'l', 'a', 'n', 'g', '_', 's', 'l', 'i', 'c', 'e', '_'};
      if (19 + plen >= cap)
        return -1;
      for (hi = 0; hi < 19; hi++)
        scratch[hi] = hdr[hi];
    }
    for (pi = 0; pi < plen; pi++)
      scratch[19 + pi] = eb[sp + pi];
    return 19 + plen;
  }
  name_len = pipeline_type_named_name_into(arena, type_ref, nm);
  if (tk == 8 && name_len > 0) {
    /* wave619 Cap residual pure: NAMED short ints have no TypeKind (wave313 i8/i16/u16).
     * Map to stdint C names so TYPE_SLICE tags are xlang_slice_int16_t etc., matching
     * scalar host-C emit (int16_t x) and static int16_t[] array-lit payloads.
     * Prior path always emitted struct ast_<name> → incomplete xlang_slice_ast_i16.
     * PLATFORM: SHARED host-C type_to_c_repr authority (G.7 single table). */
    if (name_len == 2 && nm[0] == 'i' && nm[1] == '8') {
      static const uint8_t k_i8[6] = {'i', 'n', 't', '8', '_', 't'};
      if (cap < 6)
        return -1;
      for (j = 0; j < 6; j++)
        scratch[j] = k_i8[j];
      return 6;
    }
    if (name_len == 3 && nm[0] == 'i' && nm[1] == '1' && nm[2] == '6') {
      static const uint8_t k_i16[7] = {'i', 'n', 't', '1', '6', '_', 't'};
      if (cap < 7)
        return -1;
      for (j = 0; j < 7; j++)
        scratch[j] = k_i16[j];
      return 7;
    }
    if (name_len == 3 && nm[0] == 'u' && nm[1] == '1' && nm[2] == '6') {
      static const uint8_t k_u16[8] = {'u', 'i', 'n', 't', '1', '6', '_', 't'};
      if (cap < 8)
        return -1;
      for (j = 0; j < 8; j++)
        scratch[j] = k_u16[j];
      return 8;
    }
    static const uint8_t hdr2[7] = {'s', 't', 'r', 'u', 'c', 't', ' '};
    w = 0;
    for (h = 0; h < 7; h++) {
      if (w >= cap - 1)
        return -1;
      scratch[w++] = hdr2[h];
    }
    if (struct_prefix && struct_prefix_len > 0) {
      for (pi = 0; pi < struct_prefix_len; pi++) {
        if (w >= cap - 1)
          return -1;
        scratch[w++] = struct_prefix[pi];
      }
    }
    /*
     * wave624 Cap residual pure: empty prefix → bare name (entry module).
     * Prior always injected `ast_` → `struct xlang_slice_ast_Pt` incomplete while
     * codegen_emit_module_struct_definitions emitted bare `struct Pt`.
     * Dep modules always pass a real struct_prefix; emit_type resolves ctx tags.
     * PLATFORM: SHARED host-C type_to_c_repr authority (G.7).
     */
    for (pi = 0; pi < name_len && pi < 64; pi++) {
      if (w >= cap - 1)
        return -1;
      scratch[w++] = nm[pi];
    }
    return w;
  }
  sn = pipeline_codegen_type_kind_copy(scratch, cap, tk);
  if (sn > 0)
    return sn;
  return pipeline_codegen_type_kind_copy(scratch, cap, 0);
}

/**
 * codegen.x type_to_c_repr 的 C glue：dep prerun 全量 typeck 时避免 X 大函数 check_block 失败。
 */
int32_t pipeline_codegen_type_to_c_repr(struct ast_ASTArena *arena, uint8_t *scratch, int32_t cap, int32_t type_ref,
                                        uint8_t *struct_prefix, int32_t struct_prefix_len) {
  return pipeline_codegen_type_to_c_repr_inner(arena, scratch, cap, type_ref, struct_prefix, struct_prefix_len);
}
