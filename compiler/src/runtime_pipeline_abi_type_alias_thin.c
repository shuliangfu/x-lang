/*
 * Thin pure: wave262 type_alias Cap domain leave.
 * G.7: bodies match mega runtime_pipeline_abi.x wave262 leave /
 * seeds/runtime_pipeline_abi.from_x.c cold twins (direct C map, not Lxml).
 *
 * Independent C thin (Darwin additive-leaf rule). File-local BSS map —
 * leftover may keep orphan local g_pipe_ta_*; live callers go through these
 * strong faces.
 *
 * Faces:
 *   pipeline_module_type_alias_storage_reset / storage_release
 *   pipeline_module_type_alias_alloc / set
 *   pipeline_module_type_alias_name_len / name_byte_at / target_ref
 *   pipeline_module_num_type_aliases_at
 *
 * Layout ≡ TypeAliasEntry: name[256]@0 | name_len@256 | target@260 (264B).
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED freestanding type_alias Cap leave.
 */

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define WAVE262_TA_SLOTS 128
#define WAVE262_TA_ENTRY_SZ 264

static void *g_ta_mod[WAVE262_TA_SLOTS];
static int32_t g_ta_n[WAVE262_TA_SLOTS];
static int32_t g_ta_cap[WAVE262_TA_SLOTS];
static uint8_t *g_ta_entries[WAVE262_TA_SLOTS];

/** Find map slot for module pointer. PLATFORM: SHARED. */
static int ta_find_slot(void *module) {
  int i;
  if (!module) {
    return -1;
  }
  for (i = 0; i < WAVE262_TA_SLOTS; i++) {
    if (g_ta_mod[i] == module) {
      return i;
    }
  }
  return -1;
}

/** Find or allocate a map slot for module. PLATFORM: SHARED. */
static int ta_find_or_create(void *module) {
  int i;
  int found;
  if (!module) {
    return -1;
  }
  found = ta_find_slot(module);
  if (found >= 0) {
    return found;
  }
  for (i = 0; i < WAVE262_TA_SLOTS; i++) {
    if (g_ta_mod[i] == NULL) {
      g_ta_mod[i] = module;
      g_ta_n[i] = 0;
      g_ta_cap[i] = 0;
      g_ta_entries[i] = NULL;
      return i;
    }
  }
  return -1;
}

/** Ensure entry table capacity >= need. PLATFORM: SHARED. */
static int ta_ensure(int slot, int32_t need) {
  int32_t cap;
  int32_t new_cap;
  uint8_t *np;
  uint8_t *old;
  if (slot < 0 || slot >= WAVE262_TA_SLOTS) {
    return 0;
  }
  if (need <= 0) {
    return 1;
  }
  cap = g_ta_cap[slot];
  if (cap >= need) {
    return 1;
  }
  new_cap = cap < 8 ? 8 : cap;
  while (new_cap < need) {
    new_cap *= 2;
  }
  np = (uint8_t *)malloc((size_t)new_cap * (size_t)WAVE262_TA_ENTRY_SZ);
  if (!np) {
    return 0;
  }
  old = g_ta_entries[slot];
  if (old && g_ta_n[slot] > 0) {
    memcpy(np, old, (size_t)g_ta_n[slot] * (size_t)WAVE262_TA_ENTRY_SZ);
  }
  if (old) {
    free(old);
  }
  g_ta_entries[slot] = np;
  g_ta_cap[slot] = new_cap;
  return 1;
}

/** Pointer to TypeAliasEntry at (slot, idx). PLATFORM: SHARED. */
static uint8_t *ta_entry_at(int slot, int32_t idx) {
  if (slot < 0 || slot >= WAVE262_TA_SLOTS) {
    return NULL;
  }
  if (idx < 0 || idx >= g_ta_n[slot]) {
    return NULL;
  }
  if (!g_ta_entries[slot]) {
    return NULL;
  }
  return g_ta_entries[slot] + (size_t)idx * (size_t)WAVE262_TA_ENTRY_SZ;
}

/** Soft-reset live count (keep capacity). PLATFORM: SHARED. */
void pipeline_module_type_alias_storage_reset(void *module) {
  int s = ta_find_slot(module);
  if (s < 0) {
    return;
  }
  g_ta_n[s] = 0;
}

/** Free tables and clear map slot. PLATFORM: SHARED. */
void pipeline_module_type_alias_storage_release(void *module) {
  int s = ta_find_slot(module);
  if (s < 0) {
    return;
  }
  if (g_ta_entries[s]) {
    free(g_ta_entries[s]);
  }
  g_ta_mod[s] = NULL;
  g_ta_entries[s] = NULL;
  g_ta_n[s] = 0;
  g_ta_cap[s] = 0;
}

/** Allocate one TypeAliasEntry; return index or -1. PLATFORM: SHARED. */
int32_t pipeline_module_type_alias_alloc(void *module) {
  int s;
  int32_t n;
  uint8_t *base;
  if (!module) {
    return -1;
  }
  s = ta_find_or_create(module);
  if (s < 0) {
    return -1;
  }
  n = g_ta_n[s];
  if (!ta_ensure(s, n + 1)) {
    return -1;
  }
  base = g_ta_entries[s];
  if (!base) {
    return -1;
  }
  memset(base + (size_t)n * (size_t)WAVE262_TA_ENTRY_SZ, 0, (size_t)WAVE262_TA_ENTRY_SZ);
  g_ta_n[s] = n + 1;
  return n;
}

/** Write name + target into entry. PLATFORM: SHARED. */
void pipeline_module_type_alias_set(void *module, int32_t idx, uint8_t *name, int32_t name_len,
                                    int32_t target_type_ref) {
  int s;
  uint8_t *e;
  int32_t i;
  if (!module || !name || name_len <= 0 || name_len > 255) {
    return;
  }
  s = ta_find_slot(module);
  if (s < 0) {
    return;
  }
  e = ta_entry_at(s, idx);
  if (!e) {
    return;
  }
  for (i = 0; i < name_len; i++) {
    e[i] = name[i];
  }
  for (i = name_len; i < 128; i++) {
    e[i] = 0;
  }
  memcpy(e + 256, &name_len, 4);
  memcpy(e + 260, &target_type_ref, 4);
}

/** Read name_len. PLATFORM: SHARED. */
int32_t pipeline_module_type_alias_name_len(void *module, int32_t idx) {
  int s;
  uint8_t *e;
  int32_t n;
  s = ta_find_slot(module);
  if (s < 0) {
    return 0;
  }
  e = ta_entry_at(s, idx);
  if (!e) {
    return 0;
  }
  memcpy(&n, e + 256, 4);
  return n;
}

/** Read name byte at off. PLATFORM: SHARED. */
uint8_t pipeline_module_type_alias_name_byte_at(void *module, int32_t idx, int32_t off) {
  int s;
  uint8_t *e;
  if (off < 0 || off >= 256) {
    return 0;
  }
  s = ta_find_slot(module);
  if (s < 0) {
    return 0;
  }
  e = ta_entry_at(s, idx);
  if (!e) {
    return 0;
  }
  return e[off];
}

/** Read target_type_ref. PLATFORM: SHARED. */
int32_t pipeline_module_type_alias_target_ref(void *module, int32_t idx) {
  int s;
  uint8_t *e;
  int32_t t;
  s = ta_find_slot(module);
  if (s < 0) {
    return 0;
  }
  e = ta_entry_at(s, idx);
  if (!e) {
    return 0;
  }
  memcpy(&t, e + 260, 4);
  return t;
}

/** Live alias count for module. PLATFORM: SHARED. */
int32_t pipeline_module_num_type_aliases_at(void *module) {
  int s = ta_find_slot(module);
  if (s < 0) {
    return 0;
  }
  return g_ta_n[s];
}
