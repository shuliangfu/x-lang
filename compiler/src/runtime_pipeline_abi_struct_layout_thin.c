/*
 * Thin pure: wave266 struct_layout Cap domain leave.
 * G.7: bodies match mega runtime_pipeline_abi.x wave266 leave
 * (flag offsets @268+; tp name_len@128). Seed cold twins synced same commit.
 *
 * Independent C thin (Darwin additive-leaf rule). File-local BSS map.
 * Excludes sizing stubs (type_ref_byte_size / next_field_offset*) —
 * product pure owns Cap glue_type path.
 *
 * Layout 296B / Field 272B / TP 260B. Header num_struct_layouts@16.
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED freestanding struct_layout Cap leave.
 */

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define WAVE266_SL_SLOTS 128
#define WAVE266_SL_LAYOUT_SZ 296
#define WAVE266_SL_FIELD_SZ 272
#define WAVE266_SL_TP_SZ 260
static void *g_sl_mod[WAVE266_SL_SLOTS];
static int32_t g_sl_n[WAVE266_SL_SLOTS];
static int32_t g_sl_cap[WAVE266_SL_SLOTS];
static uint8_t *g_sl_layouts[WAVE266_SL_SLOTS];
static int32_t g_sl_fn[WAVE266_SL_SLOTS];
static int32_t g_sl_fcap[WAVE266_SL_SLOTS];
static uint8_t *g_sl_fields[WAVE266_SL_SLOTS];
static int32_t g_sl_tpn[WAVE266_SL_SLOTS];
static int32_t g_sl_tpcap[WAVE266_SL_SLOTS];
static uint8_t *g_sl_tp[WAVE266_SL_SLOTS];

static int32_t sl_header_n(void *module) {
  int32_t n;
  if (!module)
    return 0;
  memcpy(&n, (uint8_t *)module + 16, 4);
  return n;
}

static void sl_set_header_n(void *module, int32_t n) {
  if (!module)
    return;
  memcpy((uint8_t *)module + 16, &n, 4);
}

static int sl_find_slot(void *module) {
  int i;
  if (!module)
    return -1;
  for (i = 0; i < WAVE266_SL_SLOTS; i++) {
    if (g_sl_mod[i] == module)
      return i;
  }
  return -1;
}

/**
 * Soft-reset pure struct_layout live counts for module (keep malloc capacity).
 * Also clears header num_struct_layouts@16.
 * Faithful leftover twin of runtime_pipeline_abi.x wave266 @83445.
 * PLATFORM: WINDOWS leftover PE cannot -E that thin · SHARED lifecycle.
 */
void pipeline_module_struct_layout_storage_reset(void *module) {
  int s;
  if (!module)
    return;
  s = sl_find_slot(module);
  if (s < 0) {
    sl_set_header_n(module, 0);
    return;
  }
  g_sl_n[s] = 0;
  g_sl_fn[s] = 0;
  g_sl_tpn[s] = 0;
  sl_set_header_n(module, 0);
}

/**
 * Free pure struct_layout storage for one module and clear map slot.
 * Faithful leftover twin of runtime_pipeline_abi.x wave266 @83468.
 * PLATFORM: WINDOWS leftover PE cannot -E that thin · SHARED lifecycle.
 */
void pipeline_module_struct_layout_storage_release(void *module) {
  int s;
  if (!module)
    return;
  s = sl_find_slot(module);
  if (s < 0)
    return;
  if (g_sl_layouts[s])
    free(g_sl_layouts[s]);
  if (g_sl_fields[s])
    free(g_sl_fields[s]);
  if (g_sl_tp[s])
    free(g_sl_tp[s]);
  g_sl_mod[s] = NULL;
  g_sl_layouts[s] = NULL;
  g_sl_fields[s] = NULL;
  g_sl_tp[s] = NULL;
  g_sl_n[s] = 0;
  g_sl_cap[s] = 0;
  g_sl_fn[s] = 0;
  g_sl_fcap[s] = 0;
  g_sl_tpn[s] = 0;
  g_sl_tpcap[s] = 0;
  sl_set_header_n(module, 0);
}

static void sl_soft_sync(void *module) {
  int s;
  if (!module || sl_header_n(module) != 0)
    return;
  s = sl_find_slot(module);
  if (s < 0)
    return;
  g_sl_n[s] = 0;
  g_sl_fn[s] = 0;
  g_sl_tpn[s] = 0;
}

static int sl_find_or_create(void *module) {
  int i;
  int found;
  if (!module)
    return -1;
  sl_soft_sync(module);
  found = sl_find_slot(module);
  if (found >= 0)
    return found;
  for (i = 0; i < WAVE266_SL_SLOTS; i++) {
    if (g_sl_mod[i] == NULL) {
      g_sl_mod[i] = module;
      g_sl_n[i] = 0;
      g_sl_cap[i] = 0;
      g_sl_layouts[i] = NULL;
      g_sl_fn[i] = 0;
      g_sl_fcap[i] = 0;
      g_sl_fields[i] = NULL;
      g_sl_tpn[i] = 0;
      g_sl_tpcap[i] = 0;
      g_sl_tp[i] = NULL;
      return i;
    }
  }
  return -1;
}

static int sl_ensure_layouts(int slot, int32_t need) {
  uint8_t *np;
  uint8_t *old;
  int32_t new_cap;
  if (slot < 0 || slot >= WAVE266_SL_SLOTS)
    return 0;
  if (need <= 0)
    return 1;
  if (g_sl_cap[slot] >= need)
    return 1;
  new_cap = g_sl_cap[slot];
  if (new_cap < 4)
    new_cap = 4;
  while (new_cap < need)
    new_cap *= 2;
  np = (uint8_t *)malloc((size_t)new_cap * (size_t)WAVE266_SL_LAYOUT_SZ);
  if (!np)
    return 0;
  memset(np, 0, (size_t)new_cap * (size_t)WAVE266_SL_LAYOUT_SZ);
  old = g_sl_layouts[slot];
  if (old && g_sl_n[slot] > 0)
    memcpy(np, old, (size_t)g_sl_n[slot] * (size_t)WAVE266_SL_LAYOUT_SZ);
  if (old)
    free(old);
  g_sl_layouts[slot] = np;
  g_sl_cap[slot] = new_cap;
  return 1;
}

static int sl_ensure_fields(int slot, int32_t need) {
  uint8_t *np;
  uint8_t *old;
  int32_t new_cap;
  if (slot < 0 || slot >= WAVE266_SL_SLOTS)
    return 0;
  if (need <= 0)
    return 1;
  if (g_sl_fcap[slot] >= need)
    return 1;
  new_cap = g_sl_fcap[slot];
  if (new_cap < 4)
    new_cap = 4;
  while (new_cap < need)
    new_cap *= 2;
  np = (uint8_t *)malloc((size_t)new_cap * (size_t)WAVE266_SL_FIELD_SZ);
  if (!np)
    return 0;
  memset(np, 0, (size_t)new_cap * (size_t)WAVE266_SL_FIELD_SZ);
  old = g_sl_fields[slot];
  if (old && g_sl_fn[slot] > 0)
    memcpy(np, old, (size_t)g_sl_fn[slot] * (size_t)WAVE266_SL_FIELD_SZ);
  if (old)
    free(old);
  g_sl_fields[slot] = np;
  g_sl_fcap[slot] = new_cap;
  return 1;
}

static int sl_ensure_tp(int slot, int32_t need) {
  uint8_t *np;
  uint8_t *old;
  int32_t new_cap;
  if (slot < 0 || slot >= WAVE266_SL_SLOTS)
    return 0;
  if (need <= 0)
    return 1;
  if (g_sl_tpcap[slot] >= need)
    return 1;
  new_cap = g_sl_tpcap[slot];
  if (new_cap < 4)
    new_cap = 4;
  while (new_cap < need)
    new_cap *= 2;
  np = (uint8_t *)malloc((size_t)new_cap * (size_t)WAVE266_SL_TP_SZ);
  if (!np)
    return 0;
  memset(np, 0, (size_t)new_cap * (size_t)WAVE266_SL_TP_SZ);
  old = g_sl_tp[slot];
  if (old && g_sl_tpn[slot] > 0)
    memcpy(np, old, (size_t)g_sl_tpn[slot] * (size_t)WAVE266_SL_TP_SZ);
  if (old)
    free(old);
  g_sl_tp[slot] = np;
  g_sl_tpcap[slot] = new_cap;
  return 1;
}

static uint8_t *sl_layout_at(int slot, int32_t idx) {
  if (slot < 0 || slot >= WAVE266_SL_SLOTS)
    return NULL;
  if (idx < 0 || idx >= g_sl_n[slot])
    return NULL;
  if (!g_sl_layouts[slot])
    return NULL;
  return g_sl_layouts[slot] + (size_t)idx * (size_t)WAVE266_SL_LAYOUT_SZ;
}

static uint8_t *sl_field_abs(int slot, int32_t abs) {
  if (slot < 0 || slot >= WAVE266_SL_SLOTS)
    return NULL;
  if (abs < 0 || abs >= g_sl_fn[slot])
    return NULL;
  if (!g_sl_fields[slot])
    return NULL;
  return g_sl_fields[slot] + (size_t)abs * (size_t)WAVE266_SL_FIELD_SZ;
}

static uint8_t *sl_field_entry(void *module, int32_t li, int32_t j, int create) {
  int s;
  uint8_t *sl;
  int32_t fb, nf, abs;
  if (!module || li < 0 || j < 0)
    return NULL;
  sl_soft_sync(module);
  s = sl_find_slot(module);
  if (s < 0)
    return NULL;
  sl = sl_layout_at(s, li);
  if (!sl)
    return NULL;
  memcpy(&fb, sl + 260, 4);
  memcpy(&nf, sl + 264, 4);
  if (!create) {
    if (j >= nf || fb < 0)
      return NULL;
    return sl_field_abs(s, fb + j);
  }
  if (fb < 0) {
    fb = g_sl_fn[s];
    memcpy(sl + 260, &fb, 4);
  }
  abs = fb + j;
  while (g_sl_fn[s] <= abs) {
    int32_t cur = g_sl_fn[s];
    if (!sl_ensure_fields(s, cur + 1))
      return NULL;
    memset(g_sl_fields[s] + (size_t)cur * (size_t)WAVE266_SL_FIELD_SZ, 0, WAVE266_SL_FIELD_SZ);
    g_sl_fn[s] = cur + 1;
  }
  if (j + 1 > nf) {
    nf = j + 1;
    memcpy(sl + 264, &nf, 4);
  }
  return sl_field_abs(s, abs);
}

int32_t pipeline_module_struct_layout_alloc(void *module) {
  int s;
  int32_t n;
  uint8_t *sl;
  int32_t m1 = -1;
  if (!module)
    return -1;
  s = sl_find_or_create(module);
  if (s < 0)
    return -1;
  n = g_sl_n[s];
  if (!sl_ensure_layouts(s, n + 1))
    return -1;
  sl = g_sl_layouts[s] + (size_t)n * (size_t)WAVE266_SL_LAYOUT_SZ;
  memset(sl, 0, WAVE266_SL_LAYOUT_SZ);
  memcpy(sl + 260, &m1, 4);
  memcpy(sl + 288, &m1, 4);
  g_sl_n[s] = n + 1;
  sl_set_header_n(module, n + 1);
  return n;
}

void pipeline_module_struct_layout_reset_slot(void *module, int32_t idx) {
  int s;
  uint8_t *sl;
  int32_t m1 = -1;
  if (!module)
    return;
  sl_soft_sync(module);
  s = sl_find_slot(module);
  if (s < 0)
    return;
  sl = sl_layout_at(s, idx);
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
  sl_soft_sync(module);
  s = sl_find_slot(module);
  if (s < 0)
    return;
  sl = sl_layout_at(s, idx);
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
  fe = sl_field_entry(module, li, j, 1);
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
  sl_soft_sync(module);
  s = sl_find_slot(module);
  if (s < 0)
    return 0;
  sl = sl_layout_at(s, idx);
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
  sl_soft_sync(module);
  s = sl_find_slot(module);
  if (s < 0) {
    memset(out64, 0, 256);
    return;
  }
  sl = sl_layout_at(s, idx);
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
  sl_soft_sync(module);
  s = sl_find_slot(module);
  if (s < 0)
    return 0;
  sl = sl_layout_at(s, idx);
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
  sl_soft_sync(module);
  s = sl_find_slot(module);
  if (s < 0)
    return 0;
  sl = sl_layout_at(s, idx);
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
  sl_soft_sync(module);
  s = sl_find_slot(module);
  if (s < 0)
    return;
  sl = sl_layout_at(s, idx);
  if (!sl)
    return;
  memcpy(sl + 264, &nf, 4);
}

int32_t pipeline_module_struct_layout_field_type_ref(void *module, int32_t li, int32_t j) {
  uint8_t *fe;
  int32_t v;
  if (j < 0)
    return 0;
  fe = sl_field_entry(module, li, j, 0);
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
  fe = sl_field_entry(module, li, j, 0);
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
  fe = sl_field_entry(module, li, j, 0);
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
  fe = sl_field_entry(module, li, j, 0);
  if (fe)
    memcpy(fe + 260, &foff, 4);
}

int32_t pipeline_module_struct_layout_field_offset_at(void *module, int32_t li, int32_t j) {
  uint8_t *fe;
  int32_t v;
  if (j < 0)
    return 0;
  fe = sl_field_entry(module, li, j, 0);
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
  fe = sl_field_entry(module, li, j, 0);
  if (!fe)
    return 0;
  memcpy(&v, fe + 268, 4);
  return v;
}

void pipeline_module_struct_layout_set_field_align(void *module, int32_t li, int32_t j, int32_t al) {
  uint8_t *fe;
  if (j < 0 || al < 0)
    return;
  fe = sl_field_entry(module, li, j, 0);
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
  sl_soft_sync(module);
  s = sl_find_or_create(module);
  if (s < 0)
    return -1;
  sl = sl_layout_at(s, li);
  if (!sl)
    return -1;
  memcpy(&tp_base, sl + 288, 4);
  memcpy(&tp_count, sl + 292, 4);
  if (tp_base < 0) {
    tp_base = g_sl_tpn[s];
    tp_count = 0;
    memcpy(sl + 288, &tp_base, 4);
    memcpy(sl + 292, &tp_count, 4);
  }
  abs = tp_base + tp_count;
  while (g_sl_tpn[s] <= abs) {
    int32_t cur = g_sl_tpn[s];
    if (!sl_ensure_tp(s, cur + 1))
      return -1;
    memset(g_sl_tp[s] + (size_t)cur * (size_t)WAVE266_SL_TP_SZ, 0, WAVE266_SL_TP_SZ);
    g_sl_tpn[s] = cur + 1;
  }
  ent = g_sl_tp[s] + (size_t)abs * (size_t)WAVE266_SL_TP_SZ;
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
  sl_soft_sync(module);
  s = sl_find_slot(module);
  if (s < 0)
    return 0;
  sl = sl_layout_at(s, li);
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
  sl_soft_sync(module);
  s = sl_find_slot(module);
  if (s < 0)
    return 0;
  sl = sl_layout_at(s, li);
  if (!sl)
    return 0;
  memcpy(&tp_base, sl + 288, 4);
  memcpy(&tp_count, sl + 292, 4);
  if (tp_base < 0 || j >= tp_count)
    return 0;
  abs = tp_base + j;
  if (abs < 0 || abs >= g_sl_tpn[s] || !g_sl_tp[s])
    return 0;
  ent = g_sl_tp[s] + (size_t)abs * (size_t)WAVE266_SL_TP_SZ;
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
  sl_soft_sync(module);
  s = sl_find_slot(module);
  if (s < 0)
    return;
  sl = sl_layout_at(s, li);
  if (!sl)
    return;
  memcpy(&tp_base, sl + 288, 4);
  memcpy(&tp_count, sl + 292, 4);
  if (tp_base < 0 || j >= tp_count)
    return;
  abs = tp_base + j;
  if (abs < 0 || abs >= g_sl_tpn[s] || !g_sl_tp[s])
    return;
  ent = g_sl_tp[s] + (size_t)abs * (size_t)WAVE266_SL_TP_SZ;
  memcpy(&nl, ent + 128, 4);
  if (nl <= 0)
    return;
  memcpy(out64, ent, 256);
}

#define WAVE266_SL_FLAG_SET(off) \
  do { \
    int s; uint8_t *sl; \
    if (!module) return; \
    sl_soft_sync(module); \
    s = sl_find_slot(module); \
    if (s < 0) return; \
    sl = sl_layout_at(s, idx); \
    if (!sl) return; \
    memcpy(sl + (off), &v, 4); \
  } while (0)

#define WAVE266_SL_FLAG_GET(off) \
  do { \
    int s; uint8_t *sl; int32_t v; \
    if (!module) return 0; \
    sl_soft_sync(module); \
    s = sl_find_slot(module); \
    if (s < 0) return 0; \
    sl = sl_layout_at(s, idx); \
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
  sl_soft_sync(module);
  return sl_header_n(module);
}
