/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X /* reopen wave178 FROM_X after leftover-PE struct_layout storage unique */

/*
 * wave266 cold twins: StructLayout multi-module map + struct_layout Cap leave faces.
 * struct_layout unique extracted above with the real seed body; leftover rest
 * does not compile remaining alloc/set/getters (not unique). Hybrid
 * product links pure. Cold full seed compiles BSS in the OR then these
 * helpers in the same TU.
 * Layout entry pure 168B LE:
 *   name[256]@0 | name_len@256 | field_base@260 | num_fields@264
 *   | allow_padding@140 | soa@144 | packed@148 | repr_compatible@152
 *   | is_export@156 | tp_base@160 | tp_count@164
 * Field 268B: name[256]|name_len|offset|type_ref|align
 * TP 260B: name[256]|name_len
 * Soft-sync when header num_struct_layouts@16 == 0.
 * next_field_offset / type_ref_byte_size: freestanding minimal (need pure glue_type);
 * product pure owns full sizing path.
 * PLATFORM: SHARED freestanding struct_layout Cap leave.
 */
static void wave266_sl_soft_sync(void *module) {
  int s;
  if (!module || wave266_sl_header_n(module) != 0)
    return;
  s = wave266_sl_find_slot(module);
  if (s < 0)
    return;
  g_wave266_sl_n[s] = 0;
  g_wave266_sl_fn[s] = 0;
  g_wave266_sl_tpn[s] = 0;
}

static int wave266_sl_find_or_create(void *module) {
  int i;
  int found;
  if (!module)
    return -1;
  wave266_sl_soft_sync(module);
  found = wave266_sl_find_slot(module);
  if (found >= 0)
    return found;
  for (i = 0; i < WAVE266_SL_SLOTS; i++) {
    if (g_wave266_sl_mod[i] == NULL) {
      g_wave266_sl_mod[i] = module;
      g_wave266_sl_n[i] = 0;
      g_wave266_sl_cap[i] = 0;
      g_wave266_sl_layouts[i] = NULL;
      g_wave266_sl_fn[i] = 0;
      g_wave266_sl_fcap[i] = 0;
      g_wave266_sl_fields[i] = NULL;
      g_wave266_sl_tpn[i] = 0;
      g_wave266_sl_tpcap[i] = 0;
      g_wave266_sl_tp[i] = NULL;
      return i;
    }
  }
  return -1;
}

static int wave266_sl_ensure_layouts(int slot, int32_t need) {
  uint8_t *np;
  uint8_t *old;
  int32_t new_cap;
  if (slot < 0 || slot >= WAVE266_SL_SLOTS)
    return 0;
  if (need <= 0)
    return 1;
  if (g_wave266_sl_cap[slot] >= need)
    return 1;
  new_cap = g_wave266_sl_cap[slot];
  if (new_cap < 4)
    new_cap = 4;
  while (new_cap < need)
    new_cap *= 2;
  np = (uint8_t *)malloc((size_t)new_cap * (size_t)WAVE266_SL_LAYOUT_SZ);
  if (!np)
    return 0;
  memset(np, 0, (size_t)new_cap * (size_t)WAVE266_SL_LAYOUT_SZ);
  old = g_wave266_sl_layouts[slot];
  if (old && g_wave266_sl_n[slot] > 0)
    memcpy(np, old, (size_t)g_wave266_sl_n[slot] * (size_t)WAVE266_SL_LAYOUT_SZ);
  if (old)
    free(old);
  g_wave266_sl_layouts[slot] = np;
  g_wave266_sl_cap[slot] = new_cap;
  return 1;
}

static int wave266_sl_ensure_fields(int slot, int32_t need) {
  uint8_t *np;
  uint8_t *old;
  int32_t new_cap;
  if (slot < 0 || slot >= WAVE266_SL_SLOTS)
    return 0;
  if (need <= 0)
    return 1;
  if (g_wave266_sl_fcap[slot] >= need)
    return 1;
  new_cap = g_wave266_sl_fcap[slot];
  if (new_cap < 4)
    new_cap = 4;
  while (new_cap < need)
    new_cap *= 2;
  np = (uint8_t *)malloc((size_t)new_cap * (size_t)WAVE266_SL_FIELD_SZ);
  if (!np)
    return 0;
  memset(np, 0, (size_t)new_cap * (size_t)WAVE266_SL_FIELD_SZ);
  old = g_wave266_sl_fields[slot];
  if (old && g_wave266_sl_fn[slot] > 0)
    memcpy(np, old, (size_t)g_wave266_sl_fn[slot] * (size_t)WAVE266_SL_FIELD_SZ);
  if (old)
    free(old);
  g_wave266_sl_fields[slot] = np;
  g_wave266_sl_fcap[slot] = new_cap;
  return 1;
}

static int wave266_sl_ensure_tp(int slot, int32_t need) {
  uint8_t *np;
  uint8_t *old;
  int32_t new_cap;
  if (slot < 0 || slot >= WAVE266_SL_SLOTS)
    return 0;
  if (need <= 0)
    return 1;
  if (g_wave266_sl_tpcap[slot] >= need)
    return 1;
  new_cap = g_wave266_sl_tpcap[slot];
  if (new_cap < 4)
    new_cap = 4;
  while (new_cap < need)
    new_cap *= 2;
  np = (uint8_t *)malloc((size_t)new_cap * (size_t)WAVE266_SL_TP_SZ);
  if (!np)
    return 0;
  memset(np, 0, (size_t)new_cap * (size_t)WAVE266_SL_TP_SZ);
  old = g_wave266_sl_tp[slot];
  if (old && g_wave266_sl_tpn[slot] > 0)
    memcpy(np, old, (size_t)g_wave266_sl_tpn[slot] * (size_t)WAVE266_SL_TP_SZ);
  if (old)
    free(old);
  g_wave266_sl_tp[slot] = np;
  g_wave266_sl_tpcap[slot] = new_cap;
  return 1;
}

static uint8_t *wave266_sl_layout_at(int slot, int32_t idx) {
  if (slot < 0 || slot >= WAVE266_SL_SLOTS)
    return NULL;
  if (idx < 0 || idx >= g_wave266_sl_n[slot])
    return NULL;
  if (!g_wave266_sl_layouts[slot])
    return NULL;
  return g_wave266_sl_layouts[slot] + (size_t)idx * (size_t)WAVE266_SL_LAYOUT_SZ;
}

static uint8_t *wave266_sl_field_abs(int slot, int32_t abs) {
  if (slot < 0 || slot >= WAVE266_SL_SLOTS)
    return NULL;
  if (abs < 0 || abs >= g_wave266_sl_fn[slot])
    return NULL;
  if (!g_wave266_sl_fields[slot])
    return NULL;
  return g_wave266_sl_fields[slot] + (size_t)abs * (size_t)WAVE266_SL_FIELD_SZ;
}

static uint8_t *wave266_sl_field_entry(void *module, int32_t li, int32_t j, int create) {
  int s;
  uint8_t *sl;
  int32_t fb, nf, abs;
  if (!module || li < 0 || j < 0)
    return NULL;
  wave266_sl_soft_sync(module);
  s = wave266_sl_find_slot(module);
  if (s < 0)
    return NULL;
  sl = wave266_sl_layout_at(s, li);
  if (!sl)
    return NULL;
  memcpy(&fb, sl + 260, 4);
  memcpy(&nf, sl + 264, 4);
  if (!create) {
    if (j >= nf || fb < 0)
      return NULL;
    return wave266_sl_field_abs(s, fb + j);
  }
  if (fb < 0) {
    fb = g_wave266_sl_fn[s];
    memcpy(sl + 260, &fb, 4);
  }
  abs = fb + j;
  while (g_wave266_sl_fn[s] <= abs) {
    int32_t cur = g_wave266_sl_fn[s];
    if (!wave266_sl_ensure_fields(s, cur + 1))
      return NULL;
    memset(g_wave266_sl_fields[s] + (size_t)cur * (size_t)WAVE266_SL_FIELD_SZ, 0, WAVE266_SL_FIELD_SZ);
    g_wave266_sl_fn[s] = cur + 1;
  }
  if (j + 1 > nf) {
    nf = j + 1;
    memcpy(sl + 264, &nf, 4);
  }
  return wave266_sl_field_abs(s, abs);
}

int32_t pipeline_module_struct_layout_alloc(void *module) {
  int s;
  int32_t n;
  uint8_t *sl;
  int32_t m1 = -1;
  if (!module)
    return -1;
  s = wave266_sl_find_or_create(module);
  if (s < 0)
    return -1;
  n = g_wave266_sl_n[s];
  if (!wave266_sl_ensure_layouts(s, n + 1))
    return -1;
  sl = g_wave266_sl_layouts[s] + (size_t)n * (size_t)WAVE266_SL_LAYOUT_SZ;
  memset(sl, 0, WAVE266_SL_LAYOUT_SZ);
  memcpy(sl + 260, &m1, 4);
  memcpy(sl + 288, &m1, 4);
  g_wave266_sl_n[s] = n + 1;
  wave266_sl_set_header_n(module, n + 1);
  return n;
}

void pipeline_module_struct_layout_reset_slot(void *module, int32_t idx) {
  int s;
  uint8_t *sl;
  int32_t m1 = -1;
  if (!module)
    return;
  wave266_sl_soft_sync(module);
  s = wave266_sl_find_slot(module);
  if (s < 0)
    return;
  sl = wave266_sl_layout_at(s, idx);
  if (!sl)
    return;
  memset(sl, 0, WAVE266_SL_LAYOUT_SZ);
  memcpy(sl + 260, &m1, 4);
  memcpy(sl + 288, &m1, 4);
}

void pipeline_module_struct_layout_set_name(void *module, int32_t idx, uint8_t *bytes, int32_t len) {
  int s;
  uint8_t *sl;
  int32_t i;
  if (!module || !bytes || len <= 0 || len > 255)
    return;
  wave266_sl_soft_sync(module);
  s = wave266_sl_find_slot(module);
  if (s < 0)
    return;
  sl = wave266_sl_layout_at(s, idx);
  if (!sl)
    return;
  memcpy(sl + 256, &len, 4);
  memset(sl, 0, 256);
  for (i = 0; i < len; i++)
    sl[i] = bytes[i];
}

void pipeline_module_struct_layout_set_field(void *module, int32_t li, int32_t j, uint8_t *fname_bytes,
                                            int32_t fname_len, int32_t ftype_ref, int32_t foff) {
  uint8_t *fe;
  int32_t i;
  int32_t zero = 0;
  if (fname_len <= 0 || fname_len > 255 || j < 0)
    return;
  fe = wave266_sl_field_entry(module, li, j, 1);
  if (!fe)
    return;
  memset(fe, 0, 256);
  if (fname_bytes) {
    for (i = 0; i < fname_len; i++)
      fe[i] = fname_bytes[i];
  }
  memcpy(fe + 256, &fname_len, 4);
  memcpy(fe + 260, &foff, 4);
  memcpy(fe + 264, &ftype_ref, 4);
  memcpy(fe + 268, &zero, 4);
}

int32_t pipeline_module_struct_layout_name_len(void *module, int32_t idx) {
  int s;
  uint8_t *sl;
  int32_t nlen;
  if (!module)
    return 0;
  wave266_sl_soft_sync(module);
  s = wave266_sl_find_slot(module);
  if (s < 0)
    return 0;
  sl = wave266_sl_layout_at(s, idx);
  if (!sl)
    return 0;
  memcpy(&nlen, sl + 256, 4);
  return nlen;
}

void pipeline_module_struct_layout_name_into(void *module, int32_t idx, uint8_t *out64) {
  int s;
  uint8_t *sl;
  if (!out64)
    return;
  if (!module) {
    memset(out64, 0, 256);
    return;
  }
  wave266_sl_soft_sync(module);
  s = wave266_sl_find_slot(module);
  if (s < 0) {
    memset(out64, 0, 256);
    return;
  }
  sl = wave266_sl_layout_at(s, idx);
  if (!sl) {
    memset(out64, 0, 256);
    return;
  }
  memcpy(out64, sl, 256);
}

uint8_t pipeline_module_struct_layout_name_byte_at(void *module, int32_t idx, int32_t off) {
  int s;
  uint8_t *sl;
  int32_t nlen;
  if (!module || off < 0 || off >= 256)
    return 0;
  wave266_sl_soft_sync(module);
  s = wave266_sl_find_slot(module);
  if (s < 0)
    return 0;
  sl = wave266_sl_layout_at(s, idx);
  if (!sl)
    return 0;
  memcpy(&nlen, sl + 256, 4);
  if (off >= nlen)
    return 0;
  return sl[off];
}

int32_t pipeline_module_struct_layout_num_fields(void *module, int32_t idx) {
  int s;
  uint8_t *sl;
  int32_t nf;
  if (!module)
    return 0;
  wave266_sl_soft_sync(module);
  s = wave266_sl_find_slot(module);
  if (s < 0)
    return 0;
  sl = wave266_sl_layout_at(s, idx);
  if (!sl)
    return 0;
  memcpy(&nf, sl + 264, 4);
  return nf;
}

void pipeline_module_struct_layout_set_num_fields(void *module, int32_t idx, int32_t nf) {
  int s;
  uint8_t *sl;
  if (!module)
    return;
  wave266_sl_soft_sync(module);
  s = wave266_sl_find_slot(module);
  if (s < 0)
    return;
  sl = wave266_sl_layout_at(s, idx);
  if (!sl)
    return;
  memcpy(sl + 264, &nf, 4);
}

int32_t pipeline_module_struct_layout_field_type_ref(void *module, int32_t li, int32_t j) {
  uint8_t *fe;
  int32_t v;
  if (j < 0)
    return 0;
  fe = wave266_sl_field_entry(module, li, j, 0);
  if (!fe)
    return 0;
  memcpy(&v, fe + 264, 4);
  return v;
}

int32_t pipeline_module_struct_layout_field_name_len(void *module, int32_t li, int32_t j) {
  uint8_t *fe;
  int32_t fl;
  if (j < 0)
    return 0;
  fe = wave266_sl_field_entry(module, li, j, 0);
  if (!fe)
    return 0;
  memcpy(&fl, fe + 256, 4);
  return (fl > 0 && fl <= 255) ? fl : 0;
}

void pipeline_module_struct_layout_field_name_into(void *module, int32_t li, int32_t j, uint8_t *out64) {
  uint8_t *fe;
  if (!out64)
    return;
  if (j < 0) {
    memset(out64, 0, 256);
    return;
  }
  fe = wave266_sl_field_entry(module, li, j, 0);
  if (!fe) {
    memset(out64, 0, 256);
    return;
  }
  memcpy(out64, fe, 256);
}

void pipeline_module_struct_layout_set_field_offset(void *module, int32_t li, int32_t j, int32_t foff) {
  uint8_t *fe;
  if (j < 0)
    return;
  fe = wave266_sl_field_entry(module, li, j, 0);
  if (fe)
    memcpy(fe + 260, &foff, 4);
}

int32_t pipeline_module_struct_layout_field_offset_at(void *module, int32_t li, int32_t j) {
  uint8_t *fe;
  int32_t v;
  if (j < 0)
    return 0;
  fe = wave266_sl_field_entry(module, li, j, 0);
  if (!fe)
    return 0;
  memcpy(&v, fe + 260, 4);
  return v;
}

int32_t pipeline_module_struct_layout_field_align_at(void *module, int32_t li, int32_t j) {
  uint8_t *fe;
  int32_t v;
  if (j < 0)
    return 0;
  fe = wave266_sl_field_entry(module, li, j, 0);
  if (!fe)
    return 0;
  memcpy(&v, fe + 268, 4);
  return v;
}

void pipeline_module_struct_layout_set_field_align(void *module, int32_t li, int32_t j, int32_t al) {
  uint8_t *fe;
  if (j < 0 || al < 0)
    return;
  fe = wave266_sl_field_entry(module, li, j, 0);
  if (fe)
    memcpy(fe + 268, &al, 4);
}

int32_t pipeline_module_struct_layout_append_type_param(void *module, int32_t li, uint8_t *name, int32_t name_len) {
  int s;
  uint8_t *sl;
  int32_t tp_base, tp_count, abs, i;
  uint8_t *ent;
  if (!module || li < 0 || !name || name_len <= 0 || name_len > 255)
    return -1;
  wave266_sl_soft_sync(module);
  s = wave266_sl_find_or_create(module);
  if (s < 0)
    return -1;
  sl = wave266_sl_layout_at(s, li);
  if (!sl)
    return -1;
  memcpy(&tp_base, sl + 288, 4);
  memcpy(&tp_count, sl + 292, 4);
  if (tp_base < 0) {
    tp_base = g_wave266_sl_tpn[s];
    tp_count = 0;
    memcpy(sl + 288, &tp_base, 4);
    memcpy(sl + 292, &tp_count, 4);
  }
  abs = tp_base + tp_count;
  while (g_wave266_sl_tpn[s] <= abs) {
    int32_t cur = g_wave266_sl_tpn[s];
    if (!wave266_sl_ensure_tp(s, cur + 1))
      return -1;
    memset(g_wave266_sl_tp[s] + (size_t)cur * (size_t)WAVE266_SL_TP_SZ, 0, WAVE266_SL_TP_SZ);
    g_wave266_sl_tpn[s] = cur + 1;
  }
  ent = g_wave266_sl_tp[s] + (size_t)abs * (size_t)WAVE266_SL_TP_SZ;
  memset(ent, 0, WAVE266_SL_TP_SZ);
  /* name_len@128 matches product .x / Cap 128-era tp row (TP_SZ 260). */
  memcpy(ent + 128, &name_len, 4);
  for (i = 0; i < name_len; i++)
    ent[i] = name[i];
  tp_count = tp_count + 1;
  memcpy(sl + 292, &tp_count, 4);
  return 0;
}

int32_t pipeline_module_struct_layout_num_type_params_at(void *module, int32_t li) {
  int s;
  uint8_t *sl;
  int32_t c;
  if (!module)
    return 0;
  wave266_sl_soft_sync(module);
  s = wave266_sl_find_slot(module);
  if (s < 0)
    return 0;
  sl = wave266_sl_layout_at(s, li);
  if (!sl)
    return 0;
  memcpy(&c, sl + 292, 4);
  return c;
}

int32_t pipeline_module_struct_layout_type_param_name_len(void *module, int32_t li, int32_t j) {
  int s;
  uint8_t *sl, *ent;
  int32_t tp_base, tp_count, abs, nl;
  if (!module || li < 0 || j < 0)
    return 0;
  wave266_sl_soft_sync(module);
  s = wave266_sl_find_slot(module);
  if (s < 0)
    return 0;
  sl = wave266_sl_layout_at(s, li);
  if (!sl)
    return 0;
  memcpy(&tp_base, sl + 288, 4);
  memcpy(&tp_count, sl + 292, 4);
  if (tp_base < 0 || j >= tp_count)
    return 0;
  abs = tp_base + j;
  if (abs < 0 || abs >= g_wave266_sl_tpn[s] || !g_wave266_sl_tp[s])
    return 0;
  ent = g_wave266_sl_tp[s] + (size_t)abs * (size_t)WAVE266_SL_TP_SZ;
  memcpy(&nl, ent + 128, 4);
  return (nl > 0 && nl <= 255) ? nl : 0;
}

void pipeline_module_struct_layout_type_param_name_into(void *module, int32_t li, int32_t j, uint8_t *out64) {
  int s;
  uint8_t *sl, *ent;
  int32_t tp_base, tp_count, abs, nl;
  if (!out64)
    return;
  memset(out64, 0, 256);
  if (!module || li < 0 || j < 0)
    return;
  wave266_sl_soft_sync(module);
  s = wave266_sl_find_slot(module);
  if (s < 0)
    return;
  sl = wave266_sl_layout_at(s, li);
  if (!sl)
    return;
  memcpy(&tp_base, sl + 288, 4);
  memcpy(&tp_count, sl + 292, 4);
  if (tp_base < 0 || j >= tp_count)
    return;
  abs = tp_base + j;
  if (abs < 0 || abs >= g_wave266_sl_tpn[s] || !g_wave266_sl_tp[s])
    return;
  ent = g_wave266_sl_tp[s] + (size_t)abs * (size_t)WAVE266_SL_TP_SZ;
  memcpy(&nl, ent + 128, 4);
  if (nl <= 0)
    return;
  memcpy(out64, ent, 256);
}

#define WAVE266_SL_FLAG_SET(off) \
  do { \
    int s; uint8_t *sl; \
    if (!module) return; \
    wave266_sl_soft_sync(module); \
    s = wave266_sl_find_slot(module); \
    if (s < 0) return; \
    sl = wave266_sl_layout_at(s, idx); \
    if (!sl) return; \
    memcpy(sl + (off), &v, 4); \
  } while (0)

#define WAVE266_SL_FLAG_GET(off) \
  do { \
    int s; uint8_t *sl; int32_t v; \
    if (!module) return 0; \
    wave266_sl_soft_sync(module); \
    s = wave266_sl_find_slot(module); \
    if (s < 0) return 0; \
    sl = wave266_sl_layout_at(s, idx); \
    if (!sl) return 0; \
    memcpy(&v, sl + (off), 4); \
    return v; \
  } while (0)

void pipeline_module_struct_layout_set_allow_padding(void *module, int32_t idx, int32_t v) {
  WAVE266_SL_FLAG_SET(268);
}
int32_t pipeline_module_struct_layout_allow_padding_at(void *module, int32_t idx) {
  WAVE266_SL_FLAG_GET(268);
}
void pipeline_module_struct_layout_set_soa(void *module, int32_t idx, int32_t v) {
  WAVE266_SL_FLAG_SET(272);
}
int32_t pipeline_module_struct_layout_soa_at(void *module, int32_t idx) {
  WAVE266_SL_FLAG_GET(272);
}
void pipeline_module_struct_layout_set_packed(void *module, int32_t idx, int32_t v) {
  WAVE266_SL_FLAG_SET(276);
}
int32_t pipeline_module_struct_layout_packed_at(void *module, int32_t idx) {
  WAVE266_SL_FLAG_GET(276);
}
void pipeline_module_struct_layout_set_repr_compatible(void *module, int32_t idx, int32_t v) {
  WAVE266_SL_FLAG_SET(280);
}
int32_t pipeline_module_struct_layout_repr_compatible_at(void *module, int32_t idx) {
  WAVE266_SL_FLAG_GET(280);
}
void pipeline_module_struct_layout_set_is_export(void *module, int32_t idx, int32_t v) {
  WAVE266_SL_FLAG_SET(284);
}
int32_t pipeline_module_struct_layout_is_export_at(void *module, int32_t idx) {
  WAVE266_SL_FLAG_GET(284);
}

int32_t pipeline_module_num_struct_layouts_at(void *module) {
  if (!module)
    return 0;
  wave266_sl_soft_sync(module);
  return wave266_sl_header_n(module);
}
/* XLANG_PABI_STRUCT_LAYOUT_THIN_END */

/* Cold freestanding: sizing needs pure glue_type_*; product pure owns full path. */
int32_t pipeline_asm_type_ref_byte_size_c(void *arena, int32_t ty_ref) {
  (void)arena;
  (void)ty_ref;
  return 0;
}

int32_t pipeline_struct_layout_next_field_offset_ex(void *m, void *a, int32_t layout_idx,
                                                   int32_t new_field_type_ref, int32_t field_align_req) {
  (void)m;
  (void)a;
  (void)layout_idx;
  (void)new_field_type_ref;
  (void)field_align_req;
  return 0;
}

int32_t pipeline_struct_layout_next_field_offset(void *m, void *a, int32_t layout_idx,
                                                int32_t new_field_type_ref) {
  (void)m;
  (void)a;
  (void)layout_idx;
  (void)new_field_type_ref;
  return 0;
}



/* ============================================================================
 * WAVE267: pipeline_asm_locals pure-owned leave cold twins
 * AsmLocalSlot (264B name[256]) + AsmBlockSlot parallel i32 tables, 64 ctx slots.
 * Product pure owns full path under FROM_X; freestanding cold keeps twins.
 * PLATFORM: SHARED freestanding asm_locals Cap leave.
 * ============================================================================ */
/* XLANG_PABI_ASM_LOCALS_THIN_BEGIN */
#define WAVE267_AL_SLOTS 64
#define WAVE267_AL_ENTRY_SZ 264
static void *g_wave267_al_ctx[WAVE267_AL_SLOTS];
static int g_wave267_al_used[WAVE267_AL_SLOTS];
static int32_t g_wave267_al_n[WAVE267_AL_SLOTS];
static int32_t g_wave267_al_cap[WAVE267_AL_SLOTS];
static uint8_t *g_wave267_al_slots[WAVE267_AL_SLOTS];
static int32_t g_wave267_al_bn[WAVE267_AL_SLOTS];
static int32_t g_wave267_al_bcap[WAVE267_AL_SLOTS];
static uint8_t *g_wave267_al_brefs[WAVE267_AL_SLOTS];
static uint8_t *g_wave267_al_bbases[WAVE267_AL_SLOTS];

static int wave267_al_find(void *ctx, int create) {
  int i;
  if (!ctx)
    return -1;
  for (i = 0; i < WAVE267_AL_SLOTS; i++) {
    if (g_wave267_al_used[i] && g_wave267_al_ctx[i] == ctx)
      return i;
  }
  if (!create)
    return -1;
  for (i = 0; i < WAVE267_AL_SLOTS; i++) {
    if (!g_wave267_al_used[i]) {
      g_wave267_al_used[i] = 1;
      g_wave267_al_ctx[i] = ctx;
      g_wave267_al_n[i] = 0;
      g_wave267_al_cap[i] = 0;
      g_wave267_al_slots[i] = NULL;
      g_wave267_al_bn[i] = 0;
      g_wave267_al_bcap[i] = 0;
      g_wave267_al_brefs[i] = NULL;
      g_wave267_al_bbases[i] = NULL;
      return i;
    }
  }
  return -1;
}

static int wave267_al_ensure_slots(int slot, int32_t need) {
  uint8_t *np, *old;
  int32_t new_cap;
  if (slot < 0 || slot >= WAVE267_AL_SLOTS)
    return 0;
  if (need <= 0)
    return 1;
  if (g_wave267_al_cap[slot] >= need)
    return 1;
  new_cap = g_wave267_al_cap[slot];
  if (new_cap < 4)
    new_cap = 4;
  while (new_cap < need)
    new_cap *= 2;
  np = (uint8_t *)malloc((size_t)new_cap * (size_t)WAVE267_AL_ENTRY_SZ);
  if (!np)
    return 0;
  memset(np, 0, (size_t)new_cap * (size_t)WAVE267_AL_ENTRY_SZ);
  old = g_wave267_al_slots[slot];
  if (old && g_wave267_al_n[slot] > 0)
    memcpy(np, old, (size_t)g_wave267_al_n[slot] * (size_t)WAVE267_AL_ENTRY_SZ);
  if (old)
    free(old);
  g_wave267_al_slots[slot] = np;
  g_wave267_al_cap[slot] = new_cap;
  return 1;
}

static int wave267_al_ensure_blocks(int slot, int32_t need) {
  uint8_t *nr, *nb, *old_r, *old_b;
  int32_t new_cap;
  if (slot < 0 || slot >= WAVE267_AL_SLOTS)
    return 0;
  if (need <= 0)
    return 1;
  if (g_wave267_al_bcap[slot] >= need)
    return 1;
  new_cap = g_wave267_al_bcap[slot];
  if (new_cap < 4)
    new_cap = 4;
  while (new_cap < need)
    new_cap *= 2;
  nr = (uint8_t *)malloc((size_t)new_cap * 4u);
  nb = (uint8_t *)malloc((size_t)new_cap * 4u);
  if (!nr || !nb) {
    free(nr);
    free(nb);
    return 0;
  }
  memset(nr, 0, (size_t)new_cap * 4u);
  memset(nb, 0, (size_t)new_cap * 4u);
  old_r = g_wave267_al_brefs[slot];
  old_b = g_wave267_al_bbases[slot];
  if (g_wave267_al_bn[slot] > 0) {
    if (old_r)
      memcpy(nr, old_r, (size_t)g_wave267_al_bn[slot] * 4u);
    if (old_b)
      memcpy(nb, old_b, (size_t)g_wave267_al_bn[slot] * 4u);
  }
  free(old_r);
  free(old_b);
  g_wave267_al_brefs[slot] = nr;
  g_wave267_al_bbases[slot] = nb;
  g_wave267_al_bcap[slot] = new_cap;
  return 1;
}

static uint8_t *wave267_al_at(int slot, int32_t idx) {
  if (slot < 0 || slot >= WAVE267_AL_SLOTS)
    return NULL;
  if (idx < 0 || idx >= g_wave267_al_n[slot] || !g_wave267_al_slots[slot])
    return NULL;
  return g_wave267_al_slots[slot] + (size_t)idx * (size_t)WAVE267_AL_ENTRY_SZ;
}

void asm_ctx_block_slot_reset(uint8_t *ctx) {
  int s = wave267_al_find(ctx, 0);
  if (s < 0)
    return;
  g_wave267_al_bn[s] = 0;
}

void asm_ctx_local_reset(uint8_t *ctx) {
  int s = wave267_al_find(ctx, 0);
  if (s < 0)
    return;
  g_wave267_al_n[s] = 0;
  g_wave267_al_bn[s] = 0;
}

int32_t asm_ctx_local_count(uint8_t *ctx) {
  int s = wave267_al_find(ctx, 0);
  return s < 0 ? 0 : g_wave267_al_n[s];
}

int32_t asm_ctx_local_append(uint8_t *ctx, uint8_t *name, int32_t name_len, int32_t offset) {
  int s;
  int32_t idx, n, k;
  uint8_t *ent;
  if (!ctx || !name || name_len <= 0)
    return -1;
  s = wave267_al_find(ctx, 1);
  if (s < 0)
    return -1;
  idx = g_wave267_al_n[s];
  if (!wave267_al_ensure_slots(s, idx + 1))
    return -1;
  ent = g_wave267_al_slots[s] + (size_t)idx * (size_t)WAVE267_AL_ENTRY_SZ;
  if (!ent)
    return -1;
  memset(ent, 0, WAVE267_AL_ENTRY_SZ);
  n = name_len > 255 ? 255 : name_len;
  for (k = 0; k < n; k++)
    ent[k] = name[k];
  memcpy(ent + 256, &name_len, 4);
  /* Cap 4.2.8 sync: entry is name[256] -> offset@260 (was 132 on [128]). */
  memcpy(ent + 260, &offset, 4);
  g_wave267_al_n[s] = idx + 1;
  return idx;
}

int32_t asm_ctx_local_name_len(uint8_t *ctx, int32_t idx) {
  int s = wave267_al_find(ctx, 0);
  uint8_t *ent;
  int32_t n;
  if (s < 0)
    return 0;
  ent = wave267_al_at(s, idx);
  if (!ent)
    return 0;
  memcpy(&n, ent + 256, 4);
  return n;
}

uint8_t asm_ctx_local_name_byte_at(uint8_t *ctx, int32_t idx, int32_t off) {
  int s = wave267_al_find(ctx, 0);
  uint8_t *ent;
  int32_t nlen;
  if (off < 0 || s < 0)
    return 0;
  ent = wave267_al_at(s, idx);
  if (!ent)
    return 0;
  memcpy(&nlen, ent + 256, 4);
  if (off >= nlen || off >= 255)
    return 0;
  return ent[off];
}

void asm_ctx_local_name_copy64(uint8_t *ctx, int32_t idx, uint8_t *dst) {
  int s;
  uint8_t *ent;
  int32_t nlen, n, k;
  if (!dst)
    return;
  memset(dst, 0, 256);
  s = wave267_al_find(ctx, 0);
  if (s < 0)
    return;
  ent = wave267_al_at(s, idx);
  if (!ent)
    return;
  memcpy(&nlen, ent + 256, 4);
  n = nlen > 255 ? 255 : nlen;
  for (k = 0; k < n; k++)
    dst[k] = ent[k];
}

int32_t asm_ctx_local_offset_at(uint8_t *ctx, int32_t idx) {
  int s = wave267_al_find(ctx, 0);
  uint8_t *ent;
  int32_t off;
  if (s < 0)
    return 0;
  ent = wave267_al_at(s, idx);
  if (!ent)
    return 0;
  memcpy(&off, ent + 260, 4);
  return off;
}

int32_t asm_ctx_local_find_offset(uint8_t *ctx, uint8_t *name, int32_t name_len) {
  int s;
  int32_t i, k, elen;
  uint8_t *ent;
  if (!ctx || !name || name_len <= 0)
    return -1;
  s = wave267_al_find(ctx, 0);
  if (s < 0)
    return -1;
  for (i = g_wave267_al_n[s] - 1; i >= 0; i--) {
    ent = wave267_al_at(s, i);
    if (!ent)
      continue;
    memcpy(&elen, ent + 256, 4);
    if (elen != name_len)
      continue;
    for (k = 0; k < name_len; k++) {
      uint8_t eb = (k < 255) ? ent[k] : 0;
      if (eb != name[k])
        break;
    }
    if (k == name_len) {
      int32_t off;
      memcpy(&off, ent + 260, 4);
      return off;
    }
  }
  return -1;
}

int32_t pipeline_asm_local_offset_c(void *ctx, uint8_t *name, int32_t name_len) {
  int32_t nloc, i, j, k, eq, all_zero;
  uint8_t *key;
  if (!ctx || !name || name_len <= 0)
    return -1;
  key = (uint8_t *)ctx;
  nloc = asm_ctx_local_count(key);
  for (i = 0; i < nloc; i++) {
    if (asm_ctx_local_name_len(key, i) == name_len) {
      eq = 1;
      for (k = 0; k < name_len && eq; k++) {
        if (name[k] != asm_ctx_local_name_byte_at(key, i, k))
          eq = 0;
      }
      if (eq)
        return asm_ctx_local_offset_at(key, i);
    }
  }
  if (name_len > 0 && name_len <= 32) {
    for (j = 0; j < nloc; j++) {
      if (asm_ctx_local_name_len(key, j) == name_len) {
        all_zero = 1;
        for (k = 0; k < name_len && all_zero; k++) {
          if (asm_ctx_local_name_byte_at(key, j, k) != 0)
            all_zero = 0;
        }
        if (all_zero)
          return asm_ctx_local_offset_at(key, j);
      }
    }
  }
  return -1;
}

void asm_ctx_block_slot_set(uint8_t *ctx, int32_t block_ref, int32_t slot_base) {
  int s;
  int32_t idx;
  if (!ctx || block_ref <= 0)
    return;
  s = wave267_al_find(ctx, 1);
  if (s < 0)
    return;
  idx = g_wave267_al_bn[s];
  if (!wave267_al_ensure_blocks(s, idx + 1))
    return;
  memcpy(g_wave267_al_brefs[s] + (size_t)idx * 4u, &block_ref, 4);
  memcpy(g_wave267_al_bbases[s] + (size_t)idx * 4u, &slot_base, 4);
  g_wave267_al_bn[s] = idx + 1;
}

int32_t asm_ctx_block_slot_get(uint8_t *ctx, int32_t block_ref) {
  int s;
  int32_t i, br, sb;
  if (!ctx || block_ref <= 0)
    return -1;
  s = wave267_al_find(ctx, 0);
  if (s < 0 || !g_wave267_al_brefs[s] || !g_wave267_al_bbases[s])
    return -1;
  for (i = g_wave267_al_bn[s] - 1; i >= 0; i--) {
    memcpy(&br, g_wave267_al_brefs[s] + (size_t)i * 4u, 4);
    if (br == block_ref) {
      memcpy(&sb, g_wave267_al_bbases[s] + (size_t)i * 4u, 4);
      return sb;
    }
  }
  return -1;
}
/* XLANG_PABI_ASM_LOCALS_THIN_END */
/* end wave267 asm_locals cold twins */

/*
 * WAVE268: pipeline_asm_slot_bytes pure-owned leave
 * (asm_local_slot_bytes + asm_ctx_ensure_block_locals + named/array/mod helpers).
 * NL-04 (2026-08-24): ALWAYS compile under FROM_X too. Product hybrid merges
 * WEAK .x prefer thin first-wins and can keep a stale pipe_local_slot_bytes_mod
 * (metrics 16 for import PageMmapHeap) while lit stores write 24B. Seed body
 * carries dep-max sizing and must stay on the LD argv as a strong face.
 * PLATFORM: SHARED freestanding stack layout Cap leave · LINUX gold.
 */
#if 1 /* was: #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X — NL-04 always-on */
/* Cap residual faces still host-cc elsewhere when pure not present. */
extern int32_t typeck_typeck_struct_layout_metrics(void *module, void *arena, int32_t li, int32_t depth,
                                                   int32_t check_pad, int32_t *out_sz, int32_t *out_al);
extern int32_t typeck_soa_array_storage_size_glue(void *module, void *arena, int32_t elem_type_ref,
                                                  int32_t array_len, int32_t depth);
extern int32_t typeck_x_type_size_from_layout_glue(void *module, void *arena, int32_t li, int32_t depth);
extern int32_t pipeline_type_named_name_into(void *arena, int32_t ref, uint8_t *out64);
extern int32_t pipeline_module_num_struct_layouts_at(void *mod);
extern int32_t pipeline_module_struct_layout_name_len(void *mod, int32_t idx);
extern int32_t pipeline_module_struct_layout_name_byte_at(void *mod, int32_t idx, int32_t off);
extern int32_t pipeline_module_struct_layout_num_fields(void *mod, int32_t idx);
extern int32_t pipeline_module_struct_layout_field_offset_at(void *mod, int32_t li, int32_t j);
extern int32_t pipeline_module_struct_layout_field_type_ref(void *mod, int32_t li, int32_t j);
extern int32_t pipeline_arena_num_types(void *arena);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t ref);
extern int32_t pipeline_type_array_size_at(void *arena, int32_t ref);
extern int32_t pipeline_type_elem_ref_at(void *arena, int32_t ref);
extern void *pipeline_asm_glue_emit_module_ref(void);
extern void *pipeline_asm_emit_dep_pipe_c(void);
extern int32_t pipeline_dep_ctx_ndep(void *ctx);
extern void *pipeline_dep_ctx_module_at(void *ctx, int32_t idx);
extern int32_t asm_type_is_simd_vector_spelling(void *arena, int32_t type_ref);
extern int32_t asm_local_slot_reg_offset(void *arena, int32_t type_ref, int32_t off, int32_t *inout_off);
extern int32_t pipeline_asm_let_init_stack_reserve_bytes(void *arena, int32_t type_ref, int32_t init_ref);
extern int32_t asm_ctx_block_slot_get(uint8_t *ctx, int32_t block_ref);
extern void asm_ctx_block_slot_set(uint8_t *ctx, int32_t block_ref, int32_t slot_base);
extern int32_t asm_ctx_local_count(uint8_t *ctx);
extern int32_t asm_ctx_local_append(uint8_t *ctx, const uint8_t *name, int32_t nlen, int32_t offset);
extern int32_t ast_ast_block_num_consts(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_lets(void *arena, int32_t block_ref);
extern int32_t ast_pipeline_block_const_name_len(void *arena, int32_t block_ref, int32_t i);
extern void ast_pipeline_block_const_name_copy64(void *arena, int32_t block_ref, int32_t i, uint8_t *dst);
extern int32_t pipeline_block_const_type_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t ast_pipeline_block_const_init_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t ast_pipeline_block_let_name_len(void *arena, int32_t block_ref, int32_t i);
extern void ast_pipeline_block_let_name_copy64(void *arena, int32_t block_ref, int32_t i, uint8_t *dst);
extern int32_t pipeline_block_let_type_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t ast_pipeline_block_let_init_ref(void *arena, int32_t block_ref, int32_t i);

static int32_t wave268_local_slot_bytes_mod(void *arena, int32_t type_ref, void *mod);

static int32_t wave268_slot_bytes_named_in_mod(void *arena, int32_t type_ref, void *mod) {
  uint8_t name[256];
  int32_t nlen, k, nlayouts, ln, j, eq, b, sz, al, mrc, nf, last, foff, fty, fsz, dot, base_off, base_len;
  if (!arena || type_ref <= 0 || !mod)
    return 0;
  nlen = pipeline_type_named_name_into(arena, type_ref, name);
  if (nlen <= 0 || nlen > 255)
    return 0;
  dot = -1;
  for (j = 0; j < nlen; j++) {
    if (name[j] == '.')
      dot = j;
  }
  if (dot >= 0) {
    base_off = dot + 1;
    base_len = nlen - base_off;
    if (base_len <= 0)
      return 0;
    for (j = 0; j < base_len; j++)
      name[j] = name[base_off + j];
    nlen = base_len;
  }
  nlayouts = pipeline_module_num_struct_layouts_at(mod);
  for (k = 0; k < nlayouts; k++) {
    ln = pipeline_module_struct_layout_name_len(mod, k);
    if (ln != nlen)
      continue;
    eq = 1;
    for (j = 0; j < nlen; j++) {
      b = pipeline_module_struct_layout_name_byte_at(mod, k, j);
      if (b != (int32_t)name[j]) {
        eq = 0;
        break;
      }
    }
    if (!eq)
      continue;
    sz = 0;
    al = 1;
    mrc = typeck_typeck_struct_layout_metrics(mod, arena, k, 0, 0, &sz, &al);
    /* NL-04: raise metrics sz to stored-offset extent — import STRUCT_LIT
     * may keep thin field types while offsets are wide AoS (PageMmapHeap). */
    nf = pipeline_module_struct_layout_num_fields(mod, k);
    if (mrc == 0) {
      if (sz <= 0)
        return 0;
      for (j = 0; j < nf; j++) {
        foff = pipeline_module_struct_layout_field_offset_at(mod, k, j);
        fty = pipeline_module_struct_layout_field_type_ref(mod, k, j);
        fsz = wave268_local_slot_bytes_mod(arena, fty, mod);
        if (fsz <= 0)
          fsz = 8;
        if ((foff + fsz) > sz)
          sz = foff + fsz;
      }
      if (sz % 8 != 0)
        sz += 8 - (sz % 8);
      return sz;
    }
    if (nf > 0) {
      last = nf - 1;
      foff = pipeline_module_struct_layout_field_offset_at(mod, k, last);
      fty = pipeline_module_struct_layout_field_type_ref(mod, k, last);
      fsz = wave268_local_slot_bytes_mod(arena, fty, mod);
      if (fsz <= 0)
        fsz = 4;
      sz = foff + fsz;
    } else {
      return 0;
    }
    if (sz > 0) {
      if (sz % 8 != 0)
        sz += 8 - (sz % 8);
      return sz;
    }
  }
  return 0;
}

int32_t asm_fixed_array_total_bytes_mod(void *arena, int32_t type_ref, void *mod) {
  int32_t nt, asz, elem_ref, ek, soa_sz, elen, nlayouts, lk, ln, j, eq, b, es;
  uint8_t ename[256];
  if (!arena || type_ref <= 0)
    return 0;
  nt = pipeline_arena_num_types(arena);
  if (type_ref > nt)
    return 0;
  if (pipeline_type_kind_ord_at(arena, type_ref) != 10)
    return 0;
  asz = pipeline_type_array_size_at(arena, type_ref);
  elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
  if (asz <= 0 || elem_ref <= 0)
    return 0;
  if (!mod)
    mod = pipeline_asm_glue_emit_module_ref();
  if (!mod)
    return 0;
  ek = pipeline_type_kind_ord_at(arena, elem_ref);
  if (ek != 8)
    return 0;
  soa_sz = typeck_soa_array_storage_size_glue(mod, arena, elem_ref, asz, 0);
  if (soa_sz > 0)
    return soa_sz;
  elen = pipeline_type_named_name_into(arena, elem_ref, ename);
  if (elen <= 0 || elen > 63)
    return 0;
  nlayouts = pipeline_module_num_struct_layouts_at(mod);
  for (lk = 0; lk < nlayouts; lk++) {
    ln = pipeline_module_struct_layout_name_len(mod, lk);
    if (ln != elen)
      continue;
    eq = 1;
    for (j = 0; j < elen; j++) {
      b = pipeline_module_struct_layout_name_byte_at(mod, lk, j);
      if (b != (int32_t)ename[j]) {
        eq = 0;
        break;
      }
    }
    if (!eq)
      continue;
    es = typeck_x_type_size_from_layout_glue(mod, arena, lk, 0);
    if (es > 0)
      return asz * es;
  }
  return 0;
}

static int32_t wave268_local_slot_bytes_mod(void *arena, int32_t type_ref, void *mod) {
  int32_t nt, ko, sz, nd, di, elem_ref, arr_sz, asz, esz, ek, bytes, lanes, nlen;
  int32_t cur, prod, d, leaf_esz, cn, ce, lek, ssz, simd;
  void *dep, *dm;
  uint8_t name[256];
  if (!arena || type_ref <= 0)
    return 8;
  nt = pipeline_arena_num_types(arena);
  if (type_ref > nt)
    return 8;
  ko = pipeline_type_kind_ord_at(arena, type_ref);
  /* F7: TYPE_DYN (17) fat {data, vtable} is 16 bytes. */
  if (ko == 17)
    return 16;
  if (ko == 8) {
    /* NL-04: take max(emit, dep) — import STRUCT_LIT thin layout must not
     * win over defining-module authoritative size (PageMmapHeap 16 vs 24). */
    void *da;
    int32_t nlayouts2, k2, ln2, j2, eq2, b2, sz2, dot2, bo, bl, ji;
    if (!mod)
      mod = pipeline_asm_glue_emit_module_ref();
    sz = wave268_slot_bytes_named_in_mod(arena, type_ref, mod);
    dep = pipeline_asm_emit_dep_pipe_c();
    if (dep) {
      nd = pipeline_dep_ctx_ndep(dep);
      nlen = pipeline_type_named_name_into(arena, type_ref, name);
      if (nlen > 0 && nlen <= 255) {
        dot2 = -1;
        for (ji = 0; ji < nlen; ji++) {
          if (name[ji] == '.')
            dot2 = ji;
        }
        if (dot2 >= 0) {
          bo = dot2 + 1;
          bl = nlen - bo;
          if (bl > 0) {
            for (ji = 0; ji < bl; ji++)
              name[ji] = name[bo + ji];
            nlen = bl;
          }
        }
      }
      for (di = 0; di < nd; di++) {
        dm = pipeline_dep_ctx_module_at(dep, di);
        da = pipeline_dep_ctx_arena_at(dep, di);
        if (!dm || !da || dm == mod || nlen <= 0)
          continue;
        nlayouts2 = pipeline_module_num_struct_layouts_at(dm);
        for (k2 = 0; k2 < nlayouts2; k2++) {
          ln2 = pipeline_module_struct_layout_name_len(dm, k2);
          if (ln2 != nlen)
            continue;
          eq2 = 1;
          for (j2 = 0; j2 < nlen; j2++) {
            b2 = pipeline_module_struct_layout_name_byte_at(dm, k2, j2);
            if (b2 != (int32_t)name[j2]) {
              eq2 = 0;
              break;
            }
          }
          if (!eq2)
            continue;
          sz2 = typeck_x_type_size_from_layout_glue(dm, da, k2, 0);
          if (sz2 > sz)
            sz = sz2;
        }
      }
    }
    if (sz > 0) {
      if (sz % 8 != 0)
        sz += 8 - (sz % 8);
      return sz;
    }
  }
  if (ko == 10) {
    asz = pipeline_type_array_size_at(arena, type_ref);
    elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
    if (asz > 0) {
      arr_sz = asm_fixed_array_total_bytes_mod(arena, type_ref, mod);
      if (arr_sz > 0) {
        if (arr_sz % 8 != 0)
          arr_sz += 8 - (arr_sz % 8);
        return arr_sz;
      }
      if (elem_ref > 0 && elem_ref <= nt && pipeline_type_kind_ord_at(arena, elem_ref) == 10) {
        cur = type_ref;
        prod = 1;
        leaf_esz = 4;
        for (d = 0; d < 8; d++) {
          if (pipeline_type_kind_ord_at(arena, cur) != 10)
            break;
          cn = pipeline_type_array_size_at(arena, cur);
          ce = pipeline_type_elem_ref_at(arena, cur);
          if (cn <= 0 || ce <= 0)
            break;
          prod *= cn;
          lek = pipeline_type_kind_ord_at(arena, ce);
          if (lek != 10) {
            if (lek == 2 || lek == 1)
              leaf_esz = 1;
            else if (lek == 15 || lek == 4 || lek == 5 || lek == 6 || lek == 7 || lek == 9)
              leaf_esz = 8;
            else if (lek == 8) {
              ssz = wave268_slot_bytes_named_in_mod(arena, ce, mod);
              leaf_esz = ssz > 0 ? ssz : 8;
            } else
              leaf_esz = 4;
            bytes = prod * leaf_esz;
            if (bytes < 8)
              bytes = 8;
            if (bytes % 8 != 0)
              bytes += 8 - (bytes % 8);
            return bytes;
          }
          cur = ce;
        }
      }
      esz = 4;
      if (elem_ref > 0 && elem_ref <= nt) {
        ek = pipeline_type_kind_ord_at(arena, elem_ref);
        if (ek == 2 || ek == 1)
          esz = 1;
        else if (ek == 14 || ek == 0 || ek == 3 || ek == 13)
          esz = 4;
        else if (ek == 8 || ek == 4 || ek == 5 || ek == 6 || ek == 7 || ek == 15 || ek == 9)
          esz = 8;
      }
      bytes = asz * esz;
      if (bytes < 8)
        bytes = 8;
      if (bytes % 8 != 0)
        bytes += 8 - (bytes % 8);
      return bytes;
    }
  }
  if (ko == 11)
    return 16;
  simd = asm_type_is_simd_vector_spelling(arena, type_ref);
  if (!simd && ko != 13)
    return 8;
  if (ko != 13) {
    lanes = 4;
    nlen = pipeline_type_named_name_into(arena, type_ref, name);
    if (nlen == 5 && name[4] == 56)
      lanes = 8;
    if (nlen == 6 && name[4] == 49 && name[5] == 54)
      lanes = 16;
    if (nlen == 5 && name[0] == 'V' && name[1] == 'e' && name[2] == 'c' && name[3] == '8' && name[4] == 'i')
      lanes = 8;
    esz = 4;
    bytes = lanes * esz;
    if (bytes < 8)
      bytes = 8;
    if (bytes % 8 != 0)
      bytes += 8 - (bytes % 8);
    return bytes;
  }
  asz = pipeline_type_array_size_at(arena, type_ref);
  elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
  lanes = asz > 0 ? asz : 4;
  esz = 4;
  if (elem_ref > 0 && elem_ref <= nt) {
    ek = pipeline_type_kind_ord_at(arena, elem_ref);
    if (ek == 2)
      esz = 1;
    else if (ek == 14)
      esz = 4;
    else if (ek == 8 || ek == 4 || ek == 5 || ek == 6)
      esz = 8;
  }
  bytes = lanes * esz;
  if (bytes < 8)
    bytes = 8;
  if (bytes % 8 != 0)
    bytes += 8 - (bytes % 8);
  return bytes;
}

int32_t asm_local_slot_bytes(void *arena, int32_t type_ref) {
  return wave268_local_slot_bytes_mod(arena, type_ref, NULL);
}

void asm_ctx_ensure_block_locals(uint8_t *ctx, void *arena, int32_t block_ref, int32_t *inout_next_offset,
                                 int32_t *inout_num_locals) {
  int32_t i, off, base, nlen, type_ref, init_ref, nconst, nlet, prev, slot_off, ap;
  uint8_t name_buf[256];
  if (!ctx || !arena || !inout_next_offset || !inout_num_locals || block_ref <= 0)
    return;
  prev = asm_ctx_block_slot_get(ctx, block_ref);
  if (prev >= 0)
    return;
  base = asm_ctx_local_count(ctx);
  asm_ctx_block_slot_set(ctx, block_ref, base);
  off = *inout_next_offset;
  nconst = ast_ast_block_num_consts(arena, block_ref);
  for (i = 0; i < nconst; i++) {
    nlen = ast_pipeline_block_const_name_len(arena, block_ref, i);
    if (nlen <= 0)
      continue;
    ast_pipeline_block_const_name_copy64(arena, block_ref, i, name_buf);
    type_ref = pipeline_block_const_type_ref(arena, block_ref, i);
    {
      int32_t off_slot = off;
      slot_off = asm_local_slot_reg_offset(arena, type_ref, off, &off_slot);
      off = off_slot;
      ap = asm_ctx_local_append(ctx, name_buf, nlen, slot_off);
      if (ap < 0)
        return;
    }
    init_ref = ast_pipeline_block_const_init_ref(arena, block_ref, i);
    off += pipeline_asm_let_init_stack_reserve_bytes(arena, type_ref, init_ref);
  }
  nlet = ast_ast_block_num_lets(arena, block_ref);
  for (i = 0; i < nlet; i++) {
    nlen = ast_pipeline_block_let_name_len(arena, block_ref, i);
    if (nlen <= 0)
      continue;
    ast_pipeline_block_let_name_copy64(arena, block_ref, i, name_buf);
    type_ref = pipeline_block_let_type_ref(arena, block_ref, i);
    {
      int32_t off_slot = off;
      slot_off = asm_local_slot_reg_offset(arena, type_ref, off, &off_slot);
      off = off_slot;
      ap = asm_ctx_local_append(ctx, name_buf, nlen, slot_off);
      if (ap < 0)
        return;
    }
    init_ref = ast_pipeline_block_let_init_ref(arena, block_ref, i);
    off += pipeline_asm_let_init_stack_reserve_bytes(arena, type_ref, init_ref);
  }
  *inout_next_offset = off;
  *inout_num_locals = asm_ctx_local_count(ctx);
}
/* end wave268 slot_bytes (NL-04 always-on under FROM_X) */
#endif /* NL-04 always-on wave268 slot_bytes */

/*
 * WAVE269: pipeline_asm_block_tree pure-owned leave cold twins
 * (asm_sum_block_local_slot_bytes / asm_count_block_stack_slots /
 *  asm_sum_block_array_temp_bytes / asm_sum_block_wa_temp_bytes /
 *  asm_ctx_fill_locals_block_tree + fixed-array temp helper).
 * Only compiled when product pure is NOT linked (-U FROM_X cold path).
 * Fixed i32[256] walk stack (matches pure; no GrowVec).
 * PLATFORM: SHARED freestanding frame layout Cap leave.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
/* XLANG_PABI_BLOCK_TREE_THIN_BEGIN */
extern int32_t asm_local_slot_bytes(void *arena, int32_t type_ref);
extern int32_t asm_fixed_array_total_bytes_mod(void *arena, int32_t type_ref, void *mod);
extern void asm_ctx_ensure_block_locals(uint8_t *ctx, void *arena, int32_t block_ref, int32_t *inout_next_offset,
                                        int32_t *inout_num_locals);
extern int32_t pipeline_arena_num_types(void *arena);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t ref);
extern int32_t pipeline_type_array_size_at(void *arena, int32_t ref);
extern int32_t pipeline_type_elem_ref_at(void *arena, int32_t ref);
extern int32_t ast_ast_block_num_consts(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_lets(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_loops(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_for_loops(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_if_stmts(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_regions(void *arena, int32_t block_ref);
extern int32_t pipeline_block_while_body_ref(void *arena, int32_t block_ref, int32_t wi);
extern int32_t pipeline_block_for_body_ref(void *arena, int32_t block_ref, int32_t fi);
extern int32_t ast_pipeline_block_if_then_body_ref(void *arena, int32_t block_ref, int32_t if_idx);
extern int32_t ast_pipeline_block_if_else_body_ref(void *arena, int32_t block_ref, int32_t if_idx);
extern int32_t pipeline_block_region_body_ref(void *arena, int32_t block_ref, int32_t ri);
extern int32_t pipeline_block_region_with_arena_cap_ref(void *arena, int32_t block_ref, int32_t ri);
extern int32_t pipeline_block_const_type_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t pipeline_block_let_type_ref(void *arena, int32_t block_ref, int32_t i);

static int32_t g_w269_block_tree_stack[256];

static int32_t wave269_block_tree_push(int32_t sp, int32_t block_ref) {
  if (block_ref <= 0 || sp < 0 || sp >= 256)
    return sp;
  g_w269_block_tree_stack[sp] = block_ref;
  return sp + 1;
}

static int32_t wave269_block_tree_push_children(void *arena, int32_t sp, int32_t cur) {
  int32_t i, n, ch;
  if (!arena || cur <= 0)
    return sp;
  n = ast_ast_block_num_loops(arena, cur);
  for (i = 0; i < n; i++) {
    ch = pipeline_block_while_body_ref(arena, cur, i);
    sp = wave269_block_tree_push(sp, ch);
  }
  n = ast_ast_block_num_for_loops(arena, cur);
  for (i = 0; i < n; i++) {
    ch = pipeline_block_for_body_ref(arena, cur, i);
    sp = wave269_block_tree_push(sp, ch);
  }
  n = ast_ast_block_num_if_stmts(arena, cur);
  for (i = 0; i < n; i++) {
    ch = ast_pipeline_block_if_then_body_ref(arena, cur, i);
    sp = wave269_block_tree_push(sp, ch);
    ch = ast_pipeline_block_if_else_body_ref(arena, cur, i);
    sp = wave269_block_tree_push(sp, ch);
  }
  return sp;
}

static int32_t wave269_block_tree_push_region_children(void *arena, int32_t sp, int32_t cur) {
  int32_t i, n, ch;
  if (!arena || cur <= 0)
    return sp;
  n = ast_ast_block_num_regions(arena, cur);
  for (i = 0; i < n; i++) {
    ch = pipeline_block_region_body_ref(arena, cur, i);
    sp = wave269_block_tree_push(sp, ch);
  }
  return sp;
}

static int32_t wave269_fixed_array_temp_bytes(void *arena, int32_t type_ref) {
  int32_t nt, ko, asz, elem_ref, esz, bytes, ek;
  if (!arena || type_ref <= 0)
    return 0;
  nt = pipeline_arena_num_types(arena);
  if (type_ref > nt)
    return 0;
  ko = pipeline_type_kind_ord_at(arena, type_ref);
  asz = pipeline_type_array_size_at(arena, type_ref);
  elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
  if (ko != 10 || asz <= 0)
    return 0;
  bytes = asm_fixed_array_total_bytes_mod(arena, type_ref, NULL);
  if (bytes > 0)
    return bytes;
  esz = 4;
  if (elem_ref > 0 && elem_ref <= nt) {
    ek = pipeline_type_kind_ord_at(arena, elem_ref);
    if (ek == 2)
      esz = 1;
    else if (ek == 14)
      esz = 4;
    else if (ek == 8 || ek == 4 || ek == 5 || ek == 6)
      esz = 8;
  }
  bytes = asz * esz;
  return bytes > 0 ? bytes : 0;
}

int32_t asm_sum_block_local_slot_bytes(void *arena, int32_t block_ref) {
  int32_t total = 0, sp = 0, visits = 0, cur, i, n, tref;
  if (!arena || block_ref <= 0)
    return 0;
  sp = wave269_block_tree_push(0, block_ref);
  while (sp > 0) {
    sp--;
    cur = g_w269_block_tree_stack[sp];
    if (cur <= 0)
      continue;
    visits++;
    if (visits > 8192)
      break;
    n = ast_ast_block_num_consts(arena, cur);
    for (i = 0; i < n; i++) {
      tref = pipeline_block_const_type_ref(arena, cur, i);
      total += asm_local_slot_bytes(arena, tref);
    }
    n = ast_ast_block_num_lets(arena, cur);
    for (i = 0; i < n; i++) {
      tref = pipeline_block_let_type_ref(arena, cur, i);
      total += asm_local_slot_bytes(arena, tref);
    }
    sp = wave269_block_tree_push_children(arena, sp, cur);
    sp = wave269_block_tree_push_region_children(arena, sp, cur);
  }
  return total;
}

int32_t asm_count_block_stack_slots(void *arena, int32_t block_ref) {
  int32_t total = 0, sp = 0, visits = 0, cur, nc, nl;
  if (!arena || block_ref <= 0)
    return 0;
  sp = wave269_block_tree_push(0, block_ref);
  while (sp > 0) {
    sp--;
    cur = g_w269_block_tree_stack[sp];
    if (cur <= 0)
      continue;
    visits++;
    if (visits > 8192)
      break;
    nc = ast_ast_block_num_consts(arena, cur);
    nl = ast_ast_block_num_lets(arena, cur);
    total += nc + nl;
    sp = wave269_block_tree_push_children(arena, sp, cur);
    sp = wave269_block_tree_push_region_children(arena, sp, cur);
  }
  return total;
}

int32_t asm_sum_block_array_temp_bytes(void *arena, int32_t block_ref) {
  int32_t total = 0, sp = 0, visits = 0, cur, i, n, tref;
  if (!arena || block_ref <= 0)
    return 0;
  sp = wave269_block_tree_push(0, block_ref);
  while (sp > 0) {
    sp--;
    cur = g_w269_block_tree_stack[sp];
    if (cur <= 0)
      continue;
    visits++;
    if (visits > 8192)
      break;
    n = ast_ast_block_num_lets(arena, cur);
    for (i = 0; i < n; i++) {
      tref = pipeline_block_let_type_ref(arena, cur, i);
      total += wave269_fixed_array_temp_bytes(arena, tref);
    }
    sp = wave269_block_tree_push_children(arena, sp, cur);
  }
  return total;
}

int32_t asm_sum_block_wa_temp_bytes(void *arena, int32_t block_ref) {
  int32_t total = 0, sp = 0, visits = 0, cur, i, n, cap_ref;
  if (!arena || block_ref <= 0)
    return 0;
  sp = wave269_block_tree_push(0, block_ref);
  while (sp > 0) {
    sp--;
    cur = g_w269_block_tree_stack[sp];
    if (cur <= 0)
      continue;
    visits++;
    if (visits > 8192)
      break;
    n = ast_ast_block_num_regions(arena, cur);
    for (i = 0; i < n; i++) {
      cap_ref = pipeline_block_region_with_arena_cap_ref(arena, cur, i);
      if (cap_ref > 0)
        total += 24;
    }
    sp = wave269_block_tree_push_children(arena, sp, cur);
    sp = wave269_block_tree_push_region_children(arena, sp, cur);
  }
  if (total > 0 && total % 8 != 0)
    total += 8 - (total % 8);
  return total;
}

void asm_ctx_fill_locals_block_tree(uint8_t *ctx, void *arena, int32_t block_ref, int32_t *inout_next_offset,
                                    int32_t *inout_num_locals) {
  int32_t sp = 0, visits = 0, cur;
  if (!ctx || !arena || !inout_next_offset || !inout_num_locals || block_ref <= 0)
    return;
  sp = wave269_block_tree_push(0, block_ref);
  while (sp > 0) {
    sp--;
    cur = g_w269_block_tree_stack[sp];
    if (cur <= 0)
      continue;
    visits++;
    if (visits > 8192)
      break;
    asm_ctx_ensure_block_locals(ctx, arena, cur, inout_next_offset, inout_num_locals);
    sp = wave269_block_tree_push_children(arena, sp, cur);
    sp = wave269_block_tree_push_region_children(arena, sp, cur);
  }
}
/* XLANG_PABI_BLOCK_TREE_THIN_END */
/* end wave269 block_tree cold twins */
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X — wave269 cold twins */
#endif /* close wave178 FROM_X for leftover-PE find_or_alloc_ptr unique */
