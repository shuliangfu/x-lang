/*
 * Thin pure: wave264 module_enum Cap domain leave.
 * G.7: bodies match mega runtime_pipeline_abi.x wave264 leave /
 * seeds/runtime_pipeline_abi.from_x.c cold twins (direct C map, not Lxml).
 * variant_tag_for_names includes dep_ctx walk (product .x authority);
 * cold seed is current-module-only — product must keep dep search.
 *
 * Independent C thin (Darwin additive-leaf rule). File-local BSS map —
 * leftover may keep orphan local g_wave264_en_*; live callers go through
 * these strong faces.
 *
 * Faces (exclude try_mark — product pure owns Cap expr mark path):
 *   pipeline_module_enum_storage_reset / storage_release
 *   pipeline_module_enum_alloc / set_name / set_is_export / is_export_at
 *   pipeline_module_enum_append_variant / variant_tag_for_names
 *   pipeline_module_enum_name_len / name_byte_at / num_variants
 *   pipeline_module_enum_variant_name_len / variant_name_byte_at
 *
 * Layout ≡ ModuleEnumEntry (66828B):
 *   name[256]@0 | name_len@256 | num_variants@260
 *   | variant_name[256][256]@264 | variant_name_len[256]@65800
 *   | is_export@66824
 * Soft-sync when header num_module_enums@64 == 0.
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED freestanding module_enum Cap leave.
 */

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define WAVE264_EN_SLOTS 128
#define WAVE264_EN_ENTRY_SZ 66828
#define WAVE264_EN_MAX_VAR 256

static void *g_en_mod[WAVE264_EN_SLOTS];
static int32_t g_en_n[WAVE264_EN_SLOTS];
static int32_t g_en_cap[WAVE264_EN_SLOTS];
static uint8_t *g_en_entries[WAVE264_EN_SLOTS];

/** Dep-ctx faces for variant_tag cross-module walk. PLATFORM: SHARED. */
extern void *pipeline_typeck_get_dep_ctx(void);
extern int32_t pipeline_dep_ctx_ndep(void *dep_ctx);
extern void *pipeline_dep_ctx_module_at(void *dep_ctx, int32_t di);

/** Read module.num_module_enums@64. PLATFORM: SHARED. */
static int32_t en_header_n(void *module) {
  int32_t n;
  if (!module) {
    return 0;
  }
  memcpy(&n, (uint8_t *)module + 64, 4);
  return n;
}

/** Write module.num_module_enums@64. PLATFORM: SHARED. */
static void en_set_header_n(void *module, int32_t n) {
  if (!module) {
    return;
  }
  memcpy((uint8_t *)module + 64, &n, 4);
}

/** Find map slot for module pointer. PLATFORM: SHARED. */
static int en_find_slot(void *module) {
  int i;
  if (!module) {
    return -1;
  }
  for (i = 0; i < WAVE264_EN_SLOTS; i++) {
    if (g_en_mod[i] == module) {
      return i;
    }
  }
  return -1;
}

/**
 * Soft-reset live count when header num_module_enums is 0.
 * PLATFORM: SHARED.
 */
static void en_soft_sync(void *module) {
  int s;
  if (!module || en_header_n(module) != 0) {
    return;
  }
  s = en_find_slot(module);
  if (s < 0) {
    return;
  }
  g_en_n[s] = 0;
}

/** Find or allocate a map slot for module. PLATFORM: SHARED. */
static int en_find_or_create(void *module) {
  int i;
  int found;
  if (!module) {
    return -1;
  }
  en_soft_sync(module);
  found = en_find_slot(module);
  if (found >= 0) {
    return found;
  }
  for (i = 0; i < WAVE264_EN_SLOTS; i++) {
    if (g_en_mod[i] == NULL) {
      g_en_mod[i] = module;
      g_en_n[i] = 0;
      g_en_cap[i] = 0;
      g_en_entries[i] = NULL;
      return i;
    }
  }
  return -1;
}

/** Ensure entry table capacity >= need. PLATFORM: SHARED. */
static int en_ensure(int slot, int32_t need) {
  uint8_t *np;
  uint8_t *old;
  int32_t new_cap;
  if (slot < 0 || slot >= WAVE264_EN_SLOTS) {
    return 0;
  }
  if (need <= 0) {
    return 1;
  }
  if (g_en_cap[slot] >= need) {
    return 1;
  }
  new_cap = g_en_cap[slot];
  if (new_cap < 4) {
    new_cap = 4;
  }
  while (new_cap < need) {
    new_cap *= 2;
  }
  np = (uint8_t *)malloc((size_t)new_cap * (size_t)WAVE264_EN_ENTRY_SZ);
  if (!np) {
    return 0;
  }
  memset(np, 0, (size_t)new_cap * (size_t)WAVE264_EN_ENTRY_SZ);
  old = g_en_entries[slot];
  if (old && g_en_n[slot] > 0) {
    memcpy(np, old, (size_t)g_en_n[slot] * (size_t)WAVE264_EN_ENTRY_SZ);
  }
  if (old) {
    free(old);
  }
  g_en_entries[slot] = np;
  g_en_cap[slot] = new_cap;
  return 1;
}

/** Pointer to ModuleEnumEntry at (slot, idx). PLATFORM: SHARED. */
static uint8_t *en_at(int slot, int32_t idx) {
  if (slot < 0 || slot >= WAVE264_EN_SLOTS) {
    return NULL;
  }
  if (idx < 0 || idx >= g_en_n[slot]) {
    return NULL;
  }
  if (!g_en_entries[slot]) {
    return NULL;
  }
  return g_en_entries[slot] + (size_t)idx * (size_t)WAVE264_EN_ENTRY_SZ;
}

/**
 * Soft-reset pure module-enum count (keep malloc capacity).
 * Also clears header num_module_enums@64. PLATFORM: SHARED.
 */
void pipeline_module_enum_storage_reset(void *module) {
  int s;
  if (!module) {
    return;
  }
  s = en_find_slot(module);
  if (s < 0) {
    en_set_header_n(module, 0);
    return;
  }
  g_en_n[s] = 0;
  en_set_header_n(module, 0);
}

/** Free tables and clear map slot. PLATFORM: SHARED. */
void pipeline_module_enum_storage_release(void *module) {
  int s;
  if (!module) {
    return;
  }
  s = en_find_slot(module);
  if (s < 0) {
    return;
  }
  if (g_en_entries[s]) {
    free(g_en_entries[s]);
  }
  g_en_mod[s] = NULL;
  g_en_entries[s] = NULL;
  g_en_n[s] = 0;
  g_en_cap[s] = 0;
  en_set_header_n(module, 0);
}

/** Allocate one ModuleEnumEntry; return index or -1. PLATFORM: SHARED. */
int32_t pipeline_module_enum_alloc(void *module) {
  int s;
  int32_t n;
  uint8_t *base;
  if (!module) {
    return -1;
  }
  s = en_find_or_create(module);
  if (s < 0) {
    return -1;
  }
  n = g_en_n[s];
  if (!en_ensure(s, n + 1)) {
    return -1;
  }
  base = g_en_entries[s];
  if (!base) {
    return -1;
  }
  memset(base + (size_t)n * (size_t)WAVE264_EN_ENTRY_SZ, 0, (size_t)WAVE264_EN_ENTRY_SZ);
  g_en_n[s] = n + 1;
  en_set_header_n(module, n + 1);
  return n;
}

/** Write enum type name + clear num_variants / is_export. PLATFORM: SHARED. */
void pipeline_module_enum_set_name(void *module, int32_t idx, uint8_t *bytes, int32_t len) {
  int s;
  uint8_t *e;
  int32_t i;
  int32_t z;
  if (!module || !bytes || len <= 0 || len > 255) {
    return;
  }
  en_soft_sync(module);
  s = en_find_slot(module);
  if (s < 0) {
    return;
  }
  e = en_at(s, idx);
  if (!e) {
    return;
  }
  memset(e, 0, 256);
  for (i = 0; i < len; i++) {
    e[i] = bytes[i];
  }
  memcpy(e + 256, &len, 4);
  z = 0;
  memcpy(e + 260, &z, 4);
  memcpy(e + 66824, &z, 4);
}

/** Write is_export@66824. PLATFORM: SHARED. */
void pipeline_module_enum_set_is_export(void *module, int32_t idx, int32_t v) {
  int s;
  uint8_t *e;
  if (!module) {
    return;
  }
  en_soft_sync(module);
  s = en_find_slot(module);
  if (s < 0) {
    return;
  }
  e = en_at(s, idx);
  if (!e) {
    return;
  }
  memcpy(e + 66824, &v, 4);
}

/** Read is_export@66824. PLATFORM: SHARED. */
int32_t pipeline_module_enum_is_export_at(void *module, int32_t idx) {
  int s;
  uint8_t *e;
  int32_t v;
  if (!module) {
    return 0;
  }
  en_soft_sync(module);
  s = en_find_slot(module);
  if (s < 0) {
    return 0;
  }
  e = en_at(s, idx);
  if (!e) {
    return 0;
  }
  memcpy(&v, e + 66824, 4);
  return v;
}

/** Append one variant name; return variant index or -1. PLATFORM: SHARED. */
int32_t pipeline_module_enum_append_variant(void *module, int32_t idx, uint8_t *bytes, int32_t len) {
  int s;
  uint8_t *e;
  int32_t nv;
  int32_t i;
  int32_t nn;
  if (!module || !bytes || len <= 0 || len > 255) {
    return -1;
  }
  en_soft_sync(module);
  s = en_find_slot(module);
  if (s < 0) {
    return -1;
  }
  e = en_at(s, idx);
  if (!e) {
    return -1;
  }
  memcpy(&nv, e + 260, 4);
  if (nv >= WAVE264_EN_MAX_VAR) {
    return -1;
  }
  memset(e + 264 + nv * 256, 0, 256);
  for (i = 0; i < len; i++) {
    e[264 + nv * 256 + i] = bytes[i];
  }
  memcpy(e + 65800 + nv * 4, &len, 4);
  nn = nv + 1;
  memcpy(e + 260, &nn, 4);
  return nv;
}

/**
 * Look up variant tag inside one module's enum map.
 * Returns tag 0..n-1 or -1. PLATFORM: SHARED.
 */
static int32_t en_tag_in_module(void *module, uint8_t *enum_name, int32_t enum_len,
                                uint8_t *variant_name, int32_t variant_len) {
  int s;
  int32_t ei;
  int32_t n;
  int32_t nlen;
  int32_t nv;
  int32_t vi;
  int32_t vlen;
  int32_t j;
  uint8_t *e;
  if (!module || !enum_name || enum_len <= 0 || !variant_name || variant_len <= 0) {
    return -1;
  }
  en_soft_sync(module);
  s = en_find_slot(module);
  if (s < 0) {
    return -1;
  }
  n = g_en_n[s];
  for (ei = 0; ei < n; ei++) {
    e = en_at(s, ei);
    if (!e) {
      continue;
    }
    memcpy(&nlen, e + 256, 4);
    if (nlen != enum_len) {
      continue;
    }
    {
      int match = 1;
      for (j = 0; j < enum_len; j++) {
        if (e[j] != enum_name[j]) {
          match = 0;
          break;
        }
      }
      if (!match) {
        continue;
      }
    }
    memcpy(&nv, e + 260, 4);
    for (vi = 0; vi < nv; vi++) {
      memcpy(&vlen, e + 65800 + vi * 4, 4);
      if (vlen != variant_len) {
        continue;
      }
      {
        int match = 1;
        for (j = 0; j < variant_len; j++) {
          if (e[264 + vi * 256 + j] != variant_name[j]) {
            match = 0;
            break;
          }
        }
        if (match) {
          return vi;
        }
      }
    }
    return -1;
  }
  return -1;
}

/**
 * Look up enum variant tag (current module, then dep_ctx modules).
 * Matches product .x authority. PLATFORM: SHARED.
 */
int32_t pipeline_module_enum_variant_tag_for_names(void *m, uint8_t *enum_name, int32_t enum_len,
                                                   uint8_t *variant_name, int32_t variant_len) {
  int32_t tag;
  void *dep_ctx;
  int32_t ndep;
  int32_t di;
  void *dep_mod;
  if (!m || !enum_name || enum_len <= 0 || !variant_name || variant_len <= 0) {
    return -1;
  }
  tag = en_tag_in_module(m, enum_name, enum_len, variant_name, variant_len);
  if (tag >= 0) {
    return tag;
  }
  dep_ctx = pipeline_typeck_get_dep_ctx();
  if (!dep_ctx) {
    return -1;
  }
  ndep = pipeline_dep_ctx_ndep(dep_ctx);
  for (di = 0; di < ndep; di++) {
    dep_mod = pipeline_dep_ctx_module_at(dep_ctx, di);
    if (dep_mod && dep_mod != m) {
      tag = en_tag_in_module(dep_mod, enum_name, enum_len, variant_name, variant_len);
      if (tag >= 0) {
        return tag;
      }
    }
  }
  return -1;
}

/** Read enum type name_len. PLATFORM: SHARED. */
int32_t pipeline_module_enum_name_len(void *module, int32_t idx) {
  int s;
  uint8_t *e;
  int32_t nlen;
  if (!module) {
    return 0;
  }
  en_soft_sync(module);
  s = en_find_slot(module);
  if (s < 0) {
    return 0;
  }
  e = en_at(s, idx);
  if (!e) {
    return 0;
  }
  memcpy(&nlen, e + 256, 4);
  return nlen;
}

/** Read one enum name byte at off. PLATFORM: SHARED. */
uint8_t pipeline_module_enum_name_byte_at(void *module, int32_t idx, int32_t off) {
  int s;
  uint8_t *e;
  int32_t nlen;
  if (!module || off < 0 || off >= 256) {
    return 0;
  }
  en_soft_sync(module);
  s = en_find_slot(module);
  if (s < 0) {
    return 0;
  }
  e = en_at(s, idx);
  if (!e) {
    return 0;
  }
  memcpy(&nlen, e + 256, 4);
  if (off >= nlen) {
    return 0;
  }
  return e[off];
}

/** Read num_variants@260. PLATFORM: SHARED. */
int32_t pipeline_module_enum_num_variants(void *module, int32_t idx) {
  int s;
  uint8_t *e;
  int32_t nv;
  if (!module) {
    return 0;
  }
  en_soft_sync(module);
  s = en_find_slot(module);
  if (s < 0) {
    return 0;
  }
  e = en_at(s, idx);
  if (!e) {
    return 0;
  }
  memcpy(&nv, e + 260, 4);
  return nv;
}

/** Read variant name length. PLATFORM: SHARED. */
int32_t pipeline_module_enum_variant_name_len(void *module, int32_t idx, int32_t variant_idx) {
  int s;
  uint8_t *e;
  int32_t nv;
  int32_t vlen;
  if (!module || variant_idx < 0) {
    return 0;
  }
  en_soft_sync(module);
  s = en_find_slot(module);
  if (s < 0) {
    return 0;
  }
  e = en_at(s, idx);
  if (!e) {
    return 0;
  }
  memcpy(&nv, e + 260, 4);
  if (variant_idx >= nv) {
    return 0;
  }
  memcpy(&vlen, e + 65800 + variant_idx * 4, 4);
  return vlen;
}

/** Read one variant-name byte at (variant_idx, off). PLATFORM: SHARED. */
uint8_t pipeline_module_enum_variant_name_byte_at(void *module, int32_t idx, int32_t variant_idx,
                                                  int32_t off) {
  int s;
  uint8_t *e;
  int32_t nv;
  int32_t vlen;
  if (!module || variant_idx < 0 || off < 0 || off >= 256) {
    return 0;
  }
  en_soft_sync(module);
  s = en_find_slot(module);
  if (s < 0) {
    return 0;
  }
  e = en_at(s, idx);
  if (!e) {
    return 0;
  }
  memcpy(&nv, e + 260, 4);
  if (variant_idx >= nv) {
    return 0;
  }
  memcpy(&vlen, e + 65800 + variant_idx * 4, 4);
  if (off >= vlen) {
    return 0;
  }
  return e[264 + variant_idx * 256 + off];
}
