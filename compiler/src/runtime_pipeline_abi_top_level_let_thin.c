/*
 * Thin pure: wave265 top_level_let Cap domain leave.
 * G.7: bodies match mega runtime_pipeline_abi.x wave265 leave /
 * seeds/runtime_pipeline_abi.from_x.c cold twins (direct C map, not Lxml).
 *
 * Independent C thin (Darwin additive-leaf rule). File-local BSS map —
 * leftover may keep orphan local g_wave265_tl_*; live callers go through
 * these strong faces.
 *
 * Faces (exclude hoist / hoist_target / sum — product pure owns Cap paths):
 *   pipeline_module_top_level_let_storage_reset / storage_release
 *   pipeline_module_top_level_let_alloc / set / set_type_ref / set_is_export
 *   pipeline_module_top_level_let_name_len / name_byte_at
 *   pipeline_module_top_level_let_type_ref / init_ref / is_const / is_export_at
 *   pipeline_module_top_level_name_is_const
 *
 * Layout ≡ TopLevelLetEntry (276B):
 *   name[256]@0 | name_len@256 | type_ref@260 | init_ref@264
 *   | is_const@268 | is_export@272
 * Soft-sync when header num_top_level_lets@12 == 0.
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED freestanding top_level Cap leave.
 */

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define WAVE265_TL_SLOTS 128
#define WAVE265_TL_ENTRY_SZ 276

static void *g_tl_mod[WAVE265_TL_SLOTS];
static int32_t g_tl_n[WAVE265_TL_SLOTS];
static int32_t g_tl_cap[WAVE265_TL_SLOTS];
static uint8_t *g_tl_entries[WAVE265_TL_SLOTS];

/** Read module.num_top_level_lets@12. PLATFORM: SHARED. */
static int32_t tl_header_n(void *module) {
  int32_t n;
  if (!module) {
    return 0;
  }
  memcpy(&n, (uint8_t *)module + 12, 4);
  return n;
}

/** Write module.num_top_level_lets@12. PLATFORM: SHARED. */
static void tl_set_header_n(void *module, int32_t n) {
  if (!module) {
    return;
  }
  memcpy((uint8_t *)module + 12, &n, 4);
}

/** Find map slot for module pointer. PLATFORM: SHARED. */
static int tl_find_slot(void *module) {
  int i;
  if (!module) {
    return -1;
  }
  for (i = 0; i < WAVE265_TL_SLOTS; i++) {
    if (g_tl_mod[i] == module) {
      return i;
    }
  }
  return -1;
}

/**
 * Soft-reset live count when header num_top_level_lets is 0.
 * PLATFORM: SHARED.
 */
static void tl_soft_sync(void *module) {
  int s;
  if (!module || tl_header_n(module) != 0) {
    return;
  }
  s = tl_find_slot(module);
  if (s < 0) {
    return;
  }
  g_tl_n[s] = 0;
}

/** Find or allocate a map slot for module. PLATFORM: SHARED. */
static int tl_find_or_create(void *module) {
  int i;
  int found;
  if (!module) {
    return -1;
  }
  tl_soft_sync(module);
  found = tl_find_slot(module);
  if (found >= 0) {
    return found;
  }
  for (i = 0; i < WAVE265_TL_SLOTS; i++) {
    if (g_tl_mod[i] == NULL) {
      g_tl_mod[i] = module;
      g_tl_n[i] = 0;
      g_tl_cap[i] = 0;
      g_tl_entries[i] = NULL;
      return i;
    }
  }
  return -1;
}

/** Ensure entry table capacity >= need. PLATFORM: SHARED. */
static int tl_ensure(int slot, int32_t need) {
  uint8_t *np;
  uint8_t *old;
  int32_t new_cap;
  if (slot < 0 || slot >= WAVE265_TL_SLOTS) {
    return 0;
  }
  if (need <= 0) {
    return 1;
  }
  if (g_tl_cap[slot] >= need) {
    return 1;
  }
  new_cap = g_tl_cap[slot];
  if (new_cap < 4) {
    new_cap = 4;
  }
  while (new_cap < need) {
    new_cap *= 2;
  }
  np = (uint8_t *)malloc((size_t)new_cap * (size_t)WAVE265_TL_ENTRY_SZ);
  if (!np) {
    return 0;
  }
  memset(np, 0, (size_t)new_cap * (size_t)WAVE265_TL_ENTRY_SZ);
  old = g_tl_entries[slot];
  if (old && g_tl_n[slot] > 0) {
    memcpy(np, old, (size_t)g_tl_n[slot] * (size_t)WAVE265_TL_ENTRY_SZ);
  }
  if (old) {
    free(old);
  }
  g_tl_entries[slot] = np;
  g_tl_cap[slot] = new_cap;
  return 1;
}

/** Pointer to TopLevelLetEntry at (slot, idx). PLATFORM: SHARED. */
static uint8_t *tl_at(int slot, int32_t idx) {
  if (slot < 0 || slot >= WAVE265_TL_SLOTS) {
    return NULL;
  }
  if (idx < 0 || idx >= g_tl_n[slot]) {
    return NULL;
  }
  if (!g_tl_entries[slot]) {
    return NULL;
  }
  return g_tl_entries[slot] + (size_t)idx * (size_t)WAVE265_TL_ENTRY_SZ;
}

/**
 * Soft-reset pure top-level-let count (keep malloc capacity).
 * Also clears header num_top_level_lets@12. PLATFORM: SHARED.
 */
void pipeline_module_top_level_let_storage_reset(void *module) {
  int s;
  if (!module) {
    return;
  }
  s = tl_find_slot(module);
  if (s < 0) {
    tl_set_header_n(module, 0);
    return;
  }
  g_tl_n[s] = 0;
  tl_set_header_n(module, 0);
}

/** Free tables and clear map slot. PLATFORM: SHARED. */
void pipeline_module_top_level_let_storage_release(void *module) {
  int s;
  if (!module) {
    return;
  }
  s = tl_find_slot(module);
  if (s < 0) {
    return;
  }
  if (g_tl_entries[s]) {
    free(g_tl_entries[s]);
  }
  g_tl_mod[s] = NULL;
  g_tl_entries[s] = NULL;
  g_tl_n[s] = 0;
  g_tl_cap[s] = 0;
  tl_set_header_n(module, 0);
}

/** Allocate one TopLevelLetEntry; return index or -1. PLATFORM: SHARED. */
int32_t pipeline_module_top_level_let_alloc(void *module) {
  int s;
  int32_t n;
  uint8_t *base;
  if (!module) {
    return -1;
  }
  s = tl_find_or_create(module);
  if (s < 0) {
    return -1;
  }
  n = g_tl_n[s];
  if (!tl_ensure(s, n + 1)) {
    return -1;
  }
  base = g_tl_entries[s];
  if (!base) {
    return -1;
  }
  memset(base + (size_t)n * (size_t)WAVE265_TL_ENTRY_SZ, 0, (size_t)WAVE265_TL_ENTRY_SZ);
  g_tl_n[s] = n + 1;
  tl_set_header_n(module, n + 1);
  return n;
}

/** Write name + type_ref + init_ref + is_const. PLATFORM: SHARED. */
void pipeline_module_top_level_let_set(void *module, int32_t idx, uint8_t *name, int32_t name_len,
                                       int32_t type_ref, int32_t init_ref, int32_t is_const) {
  int s;
  uint8_t *e;
  int32_t i;
  int32_t n;
  if (!module || !name || name_len <= 0 || name_len > 255) {
    return;
  }
  tl_soft_sync(module);
  s = tl_find_slot(module);
  if (s < 0) {
    return;
  }
  e = tl_at(s, idx);
  if (!e) {
    return;
  }
  n = name_len;
  memset(e, 0, 256);
  for (i = 0; i < n; i++) {
    e[i] = name[i];
  }
  memcpy(e + 256, &n, 4);
  memcpy(e + 260, &type_ref, 4);
  memcpy(e + 264, &init_ref, 4);
  memcpy(e + 268, &is_const, 4);
}

/** Write type_ref@260. PLATFORM: SHARED. */
void pipeline_module_top_level_let_set_type_ref(void *module, int32_t idx, int32_t type_ref) {
  int s;
  uint8_t *e;
  if (!module) {
    return;
  }
  tl_soft_sync(module);
  s = tl_find_slot(module);
  if (s < 0) {
    return;
  }
  e = tl_at(s, idx);
  if (!e) {
    return;
  }
  memcpy(e + 260, &type_ref, 4);
}

/** Read name_len@256. PLATFORM: SHARED. */
int32_t pipeline_module_top_level_let_name_len(void *module, int32_t idx) {
  int s;
  uint8_t *e;
  int32_t nlen;
  if (!module) {
    return 0;
  }
  tl_soft_sync(module);
  s = tl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  e = tl_at(s, idx);
  if (!e) {
    return 0;
  }
  memcpy(&nlen, e + 256, 4);
  return nlen;
}

/** Read one name byte at off. PLATFORM: SHARED. */
uint8_t pipeline_module_top_level_let_name_byte_at(void *module, int32_t idx, int32_t off) {
  int s;
  uint8_t *e;
  int32_t nlen;
  if (!module || off < 0 || off >= 255) {
    return 0;
  }
  tl_soft_sync(module);
  s = tl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  e = tl_at(s, idx);
  if (!e) {
    return 0;
  }
  memcpy(&nlen, e + 256, 4);
  if (off >= nlen) {
    return 0;
  }
  return e[off];
}

/** Read type_ref@260. PLATFORM: SHARED. */
int32_t pipeline_module_top_level_let_type_ref(void *module, int32_t idx) {
  int s;
  uint8_t *e;
  int32_t v;
  if (!module) {
    return 0;
  }
  tl_soft_sync(module);
  s = tl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  e = tl_at(s, idx);
  if (!e) {
    return 0;
  }
  memcpy(&v, e + 260, 4);
  return v;
}

/** Read init_ref@264. PLATFORM: SHARED. */
int32_t pipeline_module_top_level_let_init_ref(void *module, int32_t idx) {
  int s;
  uint8_t *e;
  int32_t v;
  if (!module) {
    return 0;
  }
  tl_soft_sync(module);
  s = tl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  e = tl_at(s, idx);
  if (!e) {
    return 0;
  }
  memcpy(&v, e + 264, 4);
  return v;
}

/** Read is_const@268. PLATFORM: SHARED. */
int32_t pipeline_module_top_level_let_is_const(void *module, int32_t idx) {
  int s;
  uint8_t *e;
  int32_t v;
  if (!module) {
    return 0;
  }
  tl_soft_sync(module);
  s = tl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  e = tl_at(s, idx);
  if (!e) {
    return 0;
  }
  memcpy(&v, e + 268, 4);
  return v;
}

/** Write is_export@272. PLATFORM: SHARED. */
void pipeline_module_top_level_let_set_is_export(void *module, int32_t idx, int32_t is_export) {
  int s;
  uint8_t *e;
  if (!module) {
    return;
  }
  tl_soft_sync(module);
  s = tl_find_slot(module);
  if (s < 0) {
    return;
  }
  e = tl_at(s, idx);
  if (!e) {
    return;
  }
  memcpy(e + 272, &is_export, 4);
}

/** Read is_export@272. PLATFORM: SHARED. */
int32_t pipeline_module_top_level_let_is_export_at(void *module, int32_t idx) {
  int s;
  uint8_t *e;
  int32_t v;
  if (!module) {
    return 0;
  }
  tl_soft_sync(module);
  s = tl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  e = tl_at(s, idx);
  if (!e) {
    return 0;
  }
  memcpy(&v, e + 272, 4);
  return v;
}

/**
 * Lookup is_const by name bytes (1 if const, else 0).
 * PLATFORM: SHARED.
 */
int32_t pipeline_module_top_level_name_is_const(void *module, uint8_t *vname, int32_t vlen) {
  int s;
  int32_t i;
  int32_t n;
  int32_t nl;
  int32_t k;
  uint8_t *e;
  if (!module || !vname || vlen <= 0) {
    return 0;
  }
  tl_soft_sync(module);
  s = tl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  n = g_tl_n[s];
  for (i = 0; i < n; i++) {
    e = tl_at(s, i);
    if (!e) {
      continue;
    }
    memcpy(&nl, e + 256, 4);
    if (nl != vlen) {
      continue;
    }
    for (k = 0; k < vlen; k++) {
      if (e[k] != vname[k]) {
        break;
      }
    }
    if (k == vlen) {
      int32_t is_c;
      memcpy(&is_c, e + 268, 4);
      return is_c != 0 ? 1 : 0;
    }
  }
  return 0;
}
