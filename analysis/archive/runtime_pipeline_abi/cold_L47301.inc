/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X /* reopen wave178 FROM_X after leftover-PE enum storage unique */

/*
 * wave264 cold twins: ast_pool_module_enum Cap residual pure leave.
 * enum unique extracted above with the real seed body; leftover rest
 * does not compile remaining alloc/set/getters (not unique). Hybrid
 * product links pure. Cold full seed compiles BSS in the OR then these
 * helpers in the same TU.
 * Layout ≡ C ModuleEnumEntry LE:
 *   name[256]@0 | name_len@256 | num_variants@260 | variant_name[256][256]@264
 *   | variant_name_len[256]@65800 | is_export@66824
 * Soft-sync when header num_module_enums@64 == 0.
 * Mark helpers: freestanding no-ops (need Cap expr faces); product pure owns mark.
 * PLATFORM: SHARED freestanding module_enum Cap leave.
 */
#define WAVE264_EN_MAX_VAR 256

static void wave264_en_soft_sync(void *module) {
  int s;
  if (!module || wave264_en_header_n(module) != 0)
    return;
  s = wave264_en_find_slot(module);
  if (s < 0)
    return;
  g_wave264_en_n[s] = 0;
}

static int wave264_en_find_or_create(void *module) {
  int i;
  int found;
  if (!module)
    return -1;
  wave264_en_soft_sync(module);
  found = wave264_en_find_slot(module);
  if (found >= 0)
    return found;
  for (i = 0; i < WAVE264_EN_SLOTS; i++) {
    if (g_wave264_en_mod[i] == NULL) {
      g_wave264_en_mod[i] = module;
      g_wave264_en_n[i] = 0;
      g_wave264_en_cap[i] = 0;
      g_wave264_en_entries[i] = NULL;
      return i;
    }
  }
  return -1;
}

static int wave264_en_ensure(int slot, int32_t need) {
  uint8_t *np;
  uint8_t *old;
  int32_t new_cap;
  if (slot < 0 || slot >= WAVE264_EN_SLOTS)
    return 0;
  if (need <= 0)
    return 1;
  if (g_wave264_en_cap[slot] >= need)
    return 1;
  new_cap = g_wave264_en_cap[slot];
  if (new_cap < 4)
    new_cap = 4;
  while (new_cap < need)
    new_cap *= 2;
  np = (uint8_t *)malloc((size_t)new_cap * (size_t)WAVE264_EN_ENTRY_SZ);
  if (!np)
    return 0;
  memset(np, 0, (size_t)new_cap * (size_t)WAVE264_EN_ENTRY_SZ);
  old = g_wave264_en_entries[slot];
  if (old && g_wave264_en_n[slot] > 0)
    memcpy(np, old, (size_t)g_wave264_en_n[slot] * (size_t)WAVE264_EN_ENTRY_SZ);
  if (old)
    free(old);
  g_wave264_en_entries[slot] = np;
  g_wave264_en_cap[slot] = new_cap;
  return 1;
}

static uint8_t *wave264_en_at(int slot, int32_t idx) {
  if (slot < 0 || slot >= WAVE264_EN_SLOTS)
    return NULL;
  if (idx < 0 || idx >= g_wave264_en_n[slot])
    return NULL;
  if (!g_wave264_en_entries[slot])
    return NULL;
  return g_wave264_en_entries[slot] + (size_t)idx * (size_t)WAVE264_EN_ENTRY_SZ;
}

int32_t pipeline_module_enum_alloc(void *module) {
  int s;
  int32_t n;
  uint8_t *base;
  if (!module)
    return -1;
  s = wave264_en_find_or_create(module);
  if (s < 0)
    return -1;
  n = g_wave264_en_n[s];
  if (!wave264_en_ensure(s, n + 1))
    return -1;
  base = g_wave264_en_entries[s];
  if (!base)
    return -1;
  memset(base + (size_t)n * (size_t)WAVE264_EN_ENTRY_SZ, 0, (size_t)WAVE264_EN_ENTRY_SZ);
  g_wave264_en_n[s] = n + 1;
  wave264_en_set_header_n(module, n + 1);
  return n;
}

void pipeline_module_enum_set_name(void *module, int32_t idx, uint8_t *bytes, int32_t len) {
  int s;
  uint8_t *e;
  int32_t i;
  if (!module || !bytes || len <= 0 || len > 255)
    return;
  wave264_en_soft_sync(module);
  s = wave264_en_find_slot(module);
  if (s < 0)
    return;
  e = wave264_en_at(s, idx);
  if (!e)
    return;
  memset(e, 0, 256);
  for (i = 0; i < len; i++)
    e[i] = bytes[i];
  memcpy(e + 256, &len, 4);
  {
    int32_t z = 0;
    memcpy(e + 260, &z, 4);
    memcpy(e + 66824, &z, 4);
  }
}

void pipeline_module_enum_set_is_export(void *module, int32_t idx, int32_t v) {
  int s;
  uint8_t *e;
  if (!module)
    return;
  wave264_en_soft_sync(module);
  s = wave264_en_find_slot(module);
  if (s < 0)
    return;
  e = wave264_en_at(s, idx);
  if (!e)
    return;
  memcpy(e + 66824, &v, 4);
}

int32_t pipeline_module_enum_is_export_at(void *module, int32_t idx) {
  int s;
  uint8_t *e;
  int32_t v;
  if (!module)
    return 0;
  wave264_en_soft_sync(module);
  s = wave264_en_find_slot(module);
  if (s < 0)
    return 0;
  e = wave264_en_at(s, idx);
  if (!e)
    return 0;
  memcpy(&v, e + 66824, 4);
  return v;
}

int32_t pipeline_module_enum_append_variant(void *module, int32_t idx, uint8_t *bytes, int32_t len) {
  int s;
  uint8_t *e;
  int32_t nv;
  int32_t i;
  if (!module || !bytes || len <= 0 || len > 255)
    return -1;
  wave264_en_soft_sync(module);
  s = wave264_en_find_slot(module);
  if (s < 0)
    return -1;
  e = wave264_en_at(s, idx);
  if (!e)
    return -1;
  memcpy(&nv, e + 260, 4);
  if (nv >= WAVE264_EN_MAX_VAR)
    return -1;
  memset(e + 264 + nv * 256, 0, 256);
  for (i = 0; i < len; i++)
    e[264 + nv * 256 + i] = bytes[i];
  memcpy(e + 65800 + nv * 4, &len, 4);
  {
    int32_t nn = nv + 1;
    memcpy(e + 260, &nn, 4);
  }
  return nv;
}

static int32_t wave264_en_tag_in_module(void *module, uint8_t *enum_name, int32_t enum_len,
                                        uint8_t *variant_name, int32_t variant_len) {
  int s;
  int32_t ei, n, nlen, nv, vi, vlen, j;
  uint8_t *e;
  if (!module || !enum_name || enum_len <= 0 || !variant_name || variant_len <= 0)
    return -1;
  wave264_en_soft_sync(module);
  s = wave264_en_find_slot(module);
  if (s < 0)
    return -1;
  n = g_wave264_en_n[s];
  for (ei = 0; ei < n; ei++) {
    e = wave264_en_at(s, ei);
    if (!e)
      continue;
    memcpy(&nlen, e + 256, 4);
    if (nlen != enum_len)
      continue;
    {
      int match = 1;
      for (j = 0; j < enum_len; j++) {
        if (e[j] != enum_name[j]) {
          match = 0;
          break;
        }
      }
      if (!match)
        continue;
    }
    memcpy(&nv, e + 260, 4);
    for (vi = 0; vi < nv; vi++) {
      memcpy(&vlen, e + 65800 + vi * 4, 4);
      if (vlen != variant_len)
        continue;
      {
        int match = 1;
        for (j = 0; j < variant_len; j++) {
          if (e[264 + vi * 256 + j] != variant_name[j]) {
            match = 0;
            break;
          }
        }
        if (match)
          return vi;
      }
    }
    return -1;
  }
  return -1;
}

int32_t pipeline_module_enum_variant_tag_for_names(void *m, uint8_t *enum_name, int32_t enum_len,
                                                   uint8_t *variant_name, int32_t variant_len) {
  /* Cold seed: current module only (no dep_ctx without Cap faces). */
  return wave264_en_tag_in_module(m, enum_name, enum_len, variant_name, variant_len);
}

int32_t pipeline_module_enum_name_len(void *module, int32_t idx) {
  int s;
  uint8_t *e;
  int32_t nlen;
  if (!module)
    return 0;
  wave264_en_soft_sync(module);
  s = wave264_en_find_slot(module);
  if (s < 0)
    return 0;
  e = wave264_en_at(s, idx);
  if (!e)
    return 0;
  memcpy(&nlen, e + 256, 4);
  return nlen;
}

uint8_t pipeline_module_enum_name_byte_at(void *module, int32_t idx, int32_t off) {
  int s;
  uint8_t *e;
  int32_t nlen;
  if (!module || off < 0 || off >= 256)
    return 0;
  wave264_en_soft_sync(module);
  s = wave264_en_find_slot(module);
  if (s < 0)
    return 0;
  e = wave264_en_at(s, idx);
  if (!e)
    return 0;
  memcpy(&nlen, e + 256, 4);
  if (off >= nlen)
    return 0;
  return e[off];
}

int32_t pipeline_module_enum_num_variants(void *module, int32_t idx) {
  int s;
  uint8_t *e;
  int32_t nv;
  if (!module)
    return 0;
  wave264_en_soft_sync(module);
  s = wave264_en_find_slot(module);
  if (s < 0)
    return 0;
  e = wave264_en_at(s, idx);
  if (!e)
    return 0;
  memcpy(&nv, e + 260, 4);
  return nv;
}

int32_t pipeline_module_enum_variant_name_len(void *module, int32_t idx, int32_t variant_idx) {
  int s;
  uint8_t *e;
  int32_t nv, vlen;
  if (!module || variant_idx < 0)
    return 0;
  wave264_en_soft_sync(module);
  s = wave264_en_find_slot(module);
  if (s < 0)
    return 0;
  e = wave264_en_at(s, idx);
  if (!e)
    return 0;
  memcpy(&nv, e + 260, 4);
  if (variant_idx >= nv)
    return 0;
  memcpy(&vlen, e + 65800 + variant_idx * 4, 4);
  return vlen;
}

uint8_t pipeline_module_enum_variant_name_byte_at(void *module, int32_t idx, int32_t variant_idx,
                                                  int32_t off) {
  int s;
  uint8_t *e;
  int32_t nv, vlen;
  if (!module || variant_idx < 0 || off < 0 || off >= 256)
    return 0;
  wave264_en_soft_sync(module);
  s = wave264_en_find_slot(module);
  if (s < 0)
    return 0;
  e = wave264_en_at(s, idx);
  if (!e)
    return 0;
  memcpy(&nv, e + 260, 4);
  if (variant_idx >= nv)
    return 0;
  memcpy(&vlen, e + 65800 + variant_idx * 4, 4);
  if (off >= vlen)
    return 0;
  return e[264 + variant_idx * 256 + off];
}
/* XLANG_PABI_MODULE_ENUM_THIN_END */

/* Cold freestanding: mark helpers no-op (product pure owns full mark path). */
void pipeline_expr_try_mark_enum_field_access(void *m, void *a, int32_t expr_ref) {
  (void)m;
  (void)a;
  (void)expr_ref;
}

void pipeline_codegen_try_mark_enum_field_access(void *m, void *a, int32_t expr_ref, void *dep_ctx) {
  (void)m;
  (void)a;
  (void)expr_ref;
  (void)dep_ctx;
}

#endif /* close wave178 FROM_X for leftover-PE top_level_let storage unique */
