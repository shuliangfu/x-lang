/**
 * ast_pool_struct_layout.c — module StructLayout cold accessors (BC 8.3.2).
 *
 * Same-TU #include from ast_pool.c (itself #include'd into pipeline_glue /
 * pipeline_x). Not a separate .o.
 *
 * Domain:
 * - pipeline_module_struct_layout_* (alloc / name / fields / offsets / align /
 *   packed / soa / repr / export / type params)
 * - pipeline_module_num_struct_layouts_at
 * - static layout_type_param_meta_at (domain-private meta GrowVec helper)
 *
 * Depends on same-TU statics: module_sidecar_get, module_layout_at,
 * module_layout_field_entry, grow_vec_*, ModuleSidecar / StructLayoutFieldEntry /
 * LayoutTypeParam* types (defined earlier in ast_pool.c).
 *
 * PLATFORM: SHARED — host-cc Cap residual; typeck.x / parser.x / emit call these.
 * Wave: 979 · no semantic change · pin stays 77b334842.
 */

int32_t pipeline_module_struct_layout_alloc(struct ast_Module *m) {
  ModuleSidecar *sc;
  int32_t idx;
  struct ast_StructLayout *sl;
  if (!m || !(sc = module_sidecar_get(m, 1)))
    return -1;
  idx = grow_vec_push(&sc->struct_layouts);
  if (idx < 0)
    return -1;
  sl = (struct ast_StructLayout *)grow_vec_at(&sc->struct_layouts, idx);
  memset(sl, 0, sizeof(struct ast_StructLayout));
  /** 与 module_layout_field_entry 约定：-1 = 字段池未挂接（0 是合法 base）。 */
  sl->field_base = -1;
  m->num_struct_layouts = sc->struct_layouts.len;
  return idx;
}

void pipeline_module_struct_layout_reset_slot(struct ast_Module *m, int32_t idx) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  ModuleSidecar *sc;
  LayoutTypeParamMeta *meta;
  if (!sl)
    return;
  memset(sl, 0, sizeof(*sl));
  sl->field_base = -1;
  /* wave467: clear type-param meta for this layout slot (pool entries may leak until module reset). */
  sc = module_sidecar_get(m, 0);
  if (sc && idx >= 0 && (size_t)idx < sc->struct_layout_type_param_meta.len) {
    meta = (LayoutTypeParamMeta *)grow_vec_at(&sc->struct_layout_type_param_meta, idx);
    if (meta) {
      meta->base = -1;
      meta->count = 0;
    }
  }
}

void pipeline_module_struct_layout_set_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len) {
  struct ast_StructLayout *sl;
  if (!bytes || len <= 0 || len > 127)
    return;
  sl = module_layout_at(m, idx);
  if (!sl)
    return;
  sl->name_len = len;
  memset(sl->name, 0, sizeof(sl->name));
  memcpy(sl->name, bytes, (size_t)len);
}

void pipeline_module_struct_layout_set_field(struct ast_Module *m, int32_t li, int32_t j, uint8_t *fname_bytes,
                                             int32_t fname_len, int32_t ftype_ref, int32_t foff) {
  StructLayoutFieldEntry *fe;
  if (fname_len <= 0 || fname_len > 127 || j < 0)
    return;
  fe = module_layout_field_entry(m, li, j, 1);
  if (!fe)
    return;
  fe->name_len = fname_len;
  fe->type_ref = ftype_ref;
  fe->field_offset = foff;
  fe->field_align = 0;
  memset(fe->name, 0, sizeof(fe->name));
  if (fname_bytes)
    memcpy(fe->name, fname_bytes, (size_t)fname_len);
}

int32_t pipeline_module_struct_layout_name_len(struct ast_Module *m, int32_t idx) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  return sl ? (int32_t)sl->name_len : 0;
}

void pipeline_module_struct_layout_name_into(struct ast_Module *m, int32_t idx, uint8_t *out64) {
  struct ast_StructLayout *sl;
  if (!out64)
    return;
  sl = module_layout_at(m, idx);
  if (!sl) {
    memset(out64, 0, 128);
    return;
  }
  memcpy(out64, sl->name, 128); /* wave577 Cap */
}

int32_t pipeline_module_struct_layout_num_fields(struct ast_Module *m, int32_t idx) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  return sl ? sl->num_fields : 0;
}

void pipeline_module_struct_layout_set_num_fields(struct ast_Module *m, int32_t idx, int32_t nf) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  if (sl)
    sl->num_fields = nf;
}

int32_t pipeline_module_struct_layout_field_type_ref(struct ast_Module *m, int32_t li, int32_t j) {
  StructLayoutFieldEntry *fe;
  if (j < 0)
    return 0;
  fe = module_layout_field_entry(m, li, j, 0);
  return fe ? (int32_t)fe->type_ref : 0;
}

int32_t pipeline_module_struct_layout_field_name_len(struct ast_Module *m, int32_t li, int32_t j) {
  StructLayoutFieldEntry *fe;
  int32_t fl;
  if (j < 0)
    return 0;
  fe = module_layout_field_entry(m, li, j, 0);
  if (!fe)
    return 0;
  fl = fe->name_len;
  /* wave583 Cap residual: field name content ≤127 (StructLayoutFieldEntry.name[128]). */
  return (fl > 0 && fl <= 127) ? fl : 0;
}

/**
 * wave467: ensure layout type-param meta cell for layout idx.
 * PLATFORM: SHARED.
 */
static LayoutTypeParamMeta *layout_type_param_meta_at(struct ast_Module *m, int32_t idx, int create) {
  ModuleSidecar *sc;
  LayoutTypeParamMeta *meta;
  if (!m || idx < 0)
    return NULL;
  sc = module_sidecar_get(m, create ? 1 : 0);
  if (!sc)
    return NULL;
  if (!create && (size_t)idx >= sc->struct_layout_type_param_meta.len)
    return NULL;
  while ((size_t)idx >= sc->struct_layout_type_param_meta.len) {
    int32_t pi = grow_vec_push(&sc->struct_layout_type_param_meta);
    if (pi < 0)
      return NULL;
    meta = (LayoutTypeParamMeta *)grow_vec_at(&sc->struct_layout_type_param_meta, pi);
    if (!meta)
      return NULL;
    meta->base = -1;
    meta->count = 0;
  }
  return (LayoutTypeParamMeta *)grow_vec_at(&sc->struct_layout_type_param_meta, idx);
}

/**
 * wave467: append type-param name for `struct Name<T, U>`.
 * @return 0 success, -1 failure. PLATFORM: SHARED
 */
int32_t pipeline_module_struct_layout_append_type_param(struct ast_Module *m, int32_t li, uint8_t *name,
                                                       int32_t name_len) {
  ModuleSidecar *sc;
  LayoutTypeParamMeta *meta;
  LayoutTypeParamEntry *ent;
  int32_t abs;
  if (!m || li < 0 || !name || name_len <= 0 || name_len > 127)
    return -1;
  sc = module_sidecar_get(m, 1);
  if (!sc)
    return -1;
  meta = layout_type_param_meta_at(m, li, 1);
  if (!meta)
    return -1;
  if (meta->base < 0) {
    meta->base = (int32_t)sc->struct_layout_type_params.len;
    meta->count = 0;
  }
  abs = meta->base + meta->count;
  while (sc->struct_layout_type_params.len <= (size_t)abs) {
    int32_t pi = grow_vec_push(&sc->struct_layout_type_params);
    if (pi < 0)
      return -1;
    ent = (LayoutTypeParamEntry *)grow_vec_at(&sc->struct_layout_type_params, pi);
    if (ent) {
      memset(ent, 0, sizeof(*ent));
    }
  }
  ent = (LayoutTypeParamEntry *)grow_vec_at(&sc->struct_layout_type_params, abs);
  if (!ent)
    return -1;
  memset(ent, 0, sizeof(*ent));
  ent->name_len = name_len;
  memcpy(ent->name, name, (size_t)name_len);
  meta->count = meta->count + 1;
  return 0;
}

/** wave467: number of type params on layout, or 0. PLATFORM: SHARED */
int32_t pipeline_module_struct_layout_num_type_params_at(struct ast_Module *m, int32_t li) {
  LayoutTypeParamMeta *meta = layout_type_param_meta_at(m, li, 0);
  return meta ? meta->count : 0;
}

/** wave467: type-param name length at index. PLATFORM: SHARED */
int32_t pipeline_module_struct_layout_type_param_name_len(struct ast_Module *m, int32_t li, int32_t j) {
  ModuleSidecar *sc;
  LayoutTypeParamMeta *meta;
  LayoutTypeParamEntry *ent;
  int32_t abs;
  if (!m || li < 0 || j < 0)
    return 0;
  sc = module_sidecar_get(m, 0);
  meta = layout_type_param_meta_at(m, li, 0);
  if (!sc || !meta || j >= meta->count || meta->base < 0)
    return 0;
  abs = meta->base + j;
  if (abs < 0 || (size_t)abs >= sc->struct_layout_type_params.len)
    return 0;
  ent = (LayoutTypeParamEntry *)grow_vec_at(&sc->struct_layout_type_params, abs);
  if (!ent)
    return 0;
  /* wave583 Cap residual: type-param name content ≤127 (LayoutTypeParamEntry.name[128]). */
  return (ent->name_len > 0 && ent->name_len <= 127) ? ent->name_len : 0;
}

/** wave467: copy type-param name into out (128-byte row). PLATFORM: SHARED */
void pipeline_module_struct_layout_type_param_name_into(struct ast_Module *m, int32_t li, int32_t j,
                                                       uint8_t *out64) {
  ModuleSidecar *sc;
  LayoutTypeParamMeta *meta;
  LayoutTypeParamEntry *ent;
  int32_t abs;
  if (!out64)
    return;
  memset(out64, 0, 128);
  if (!m || li < 0 || j < 0)
    return;
  sc = module_sidecar_get(m, 0);
  meta = layout_type_param_meta_at(m, li, 0);
  if (!sc || !meta || j >= meta->count || meta->base < 0)
    return;
  abs = meta->base + j;
  if (abs < 0 || (size_t)abs >= sc->struct_layout_type_params.len)
    return;
  ent = (LayoutTypeParamEntry *)grow_vec_at(&sc->struct_layout_type_params, abs);
  if (!ent || ent->name_len <= 0)
    return;
  /* wave583: full 128-byte row (match name_into for layout/field). */
  memcpy(out64, ent->name, 128);
}

void pipeline_module_struct_layout_field_name_into(struct ast_Module *m, int32_t li, int32_t j, uint8_t *out64) {
  StructLayoutFieldEntry *fe;
  if (!out64 || j < 0) {
    if (out64)
      memset(out64, 0, 128);
    return;
  }
  fe = module_layout_field_entry(m, li, j, 0);
  if (!fe) {
    memset(out64, 0, 128);
    return;
  }
  memcpy(out64, fe->name, 128); /* wave577 Cap */
}

/** 读 struct_layout 槽名字节；越界返回 0。 */
uint8_t pipeline_module_struct_layout_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  struct ast_StructLayout *sl;
  if (off < 0 || off >= 128)
    return 0;
  sl = module_layout_at(m, idx);
  if (!sl || off >= sl->name_len)
    return 0;
  return sl->name[off];
}

/** 写字段 offset（set_field 已写；单独更新用）。 */
void pipeline_module_struct_layout_set_field_offset(struct ast_Module *m, int32_t li, int32_t j, int32_t foff) {
  StructLayoutFieldEntry *fe;
  if (j < 0)
    return;
  fe = module_layout_field_entry(m, li, j, 0);
  if (fe)
    fe->field_offset = foff;
}

int32_t pipeline_module_struct_layout_field_offset_at(struct ast_Module *m, int32_t li, int32_t j) {
  StructLayoutFieldEntry *fe;
  if (j < 0)
    return 0;
  fe = module_layout_field_entry(m, li, j, 0);
  return fe ? fe->field_offset : 0;
}

/** DOD-CL：读 struct 字段 align(N) 要求；0 表示未指定。 */
int32_t pipeline_module_struct_layout_field_align_at(struct ast_Module *m, int32_t li, int32_t j) {
  StructLayoutFieldEntry *fe;
  if (j < 0)
    return 0;
  fe = module_layout_field_entry(m, li, j, 0);
  return fe ? fe->field_align : 0;
}

/** DOD-CL：写 struct 字段 align(N) 要求（parser 在 set_field 之后调用）。 */
void pipeline_module_struct_layout_set_field_align(struct ast_Module *m, int32_t li, int32_t j, int32_t al) {
  StructLayoutFieldEntry *fe;
  if (j < 0 || al < 0)
    return;
  fe = module_layout_field_entry(m, li, j, 0);
  if (fe)
    fe->field_align = al;
}

void pipeline_module_struct_layout_set_allow_padding(struct ast_Module *m, int32_t idx, int32_t v) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  if (sl)
    sl->allow_padding = v;
}

int32_t pipeline_module_struct_layout_allow_padding_at(struct ast_Module *m, int32_t idx) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  return sl ? sl->allow_padding : 0;
}

/** DOD-S1：写 struct layout 的 soa 标记（parser `struct Name soa {`）。 */
void pipeline_module_struct_layout_set_soa(struct ast_Module *m, int32_t idx, int32_t v) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  if (sl)
    sl->soa = v;
}

/** DOD-S1：读 struct layout 是否为 SoA 布局。 */
int32_t pipeline_module_struct_layout_soa_at(struct ast_Module *m, int32_t idx) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  return sl ? sl->soa : 0;
}

/** 写 struct layout 的 packed 标记（parser `struct Name packed {`）。 */
void pipeline_module_struct_layout_set_packed(struct ast_Module *m, int32_t idx, int32_t v) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  if (sl)
    sl->packed = v;
}

/** 读 struct layout 是否为 packed 布局。 */
int32_t pipeline_module_struct_layout_packed_at(struct ast_Module *m, int32_t idx) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  return sl ? sl->packed : 0;
}

/** MOD-02：写 struct layout 的 #[repr(compatible)] 标记。 */
void pipeline_module_struct_layout_set_repr_compatible(struct ast_Module *m, int32_t idx, int32_t v) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  if (sl)
    sl->repr_compatible = v;
}

/** MOD-02：读 struct layout 是否 #[repr(compatible)]。 */
int32_t pipeline_module_struct_layout_repr_compatible_at(struct ast_Module *m, int32_t idx) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  return sl ? sl->repr_compatible : 0;
}

/** 模块导出：写 / 读 struct layout 的 is_export（`export struct`）。 */
void pipeline_module_struct_layout_set_is_export(struct ast_Module *m, int32_t idx, int32_t v) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  if (sl)
    sl->is_export = v;
}
int32_t pipeline_module_struct_layout_is_export_at(struct ast_Module *m, int32_t idx) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  return sl ? sl->is_export : 0;
}

/** typeck.x：读 module.num_struct_layouts；勿 X 内 Module 字段访问（check_block 失败）。 */
int32_t pipeline_module_num_struct_layouts_at(struct ast_Module *m) {
  return m ? m->num_struct_layouts : 0;
}
