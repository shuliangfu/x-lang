/*
 * Thin pure: wave267 asm_locals Cap domain leave.
 * G.7: bodies match mega runtime_pipeline_abi.x wave267 leave /
 * seeds/runtime_pipeline_abi.from_x.c cold twins (direct C map, not Lxml).
 *
 * Independent C thin (Darwin additive-leaf rule). File-local BSS map —
 * leftover may keep orphan local g_wave267_al_*; live callers go through
 * these strong faces.
 *
 * Faces:
 *   asm_ctx_local_reset / count / append / name_len / name_byte_at /
 *     name_copy64 / offset_at / find_offset
 *   pipeline_asm_local_offset_c
 *   asm_ctx_block_slot_reset / set / get
 *
 * Layout ≡ AsmLocalSlotEntry (264B): name[256]@0 | name_len@256 | offset@260
 * Block tables: parallel i32 block_ref / slot_base.
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED freestanding asm_locals Cap leave.
 */

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define WAVE267_AL_SLOTS 64
#define WAVE267_AL_ENTRY_SZ 264
static void *g_al_ctx[WAVE267_AL_SLOTS];
static int g_al_used[WAVE267_AL_SLOTS];
static int32_t g_al_n[WAVE267_AL_SLOTS];
static int32_t g_al_cap[WAVE267_AL_SLOTS];
static uint8_t *g_al_slots[WAVE267_AL_SLOTS];
static int32_t g_al_bn[WAVE267_AL_SLOTS];
static int32_t g_al_bcap[WAVE267_AL_SLOTS];
static uint8_t *g_al_brefs[WAVE267_AL_SLOTS];
static uint8_t *g_al_bbases[WAVE267_AL_SLOTS];

static int al_find(void *ctx, int create) {
  int i;
  if (!ctx)
    return -1;
  for (i = 0; i < WAVE267_AL_SLOTS; i++) {
    if (g_al_used[i] && g_al_ctx[i] == ctx)
      return i;
  }
  if (!create)
    return -1;
  for (i = 0; i < WAVE267_AL_SLOTS; i++) {
    if (!g_al_used[i]) {
      g_al_used[i] = 1;
      g_al_ctx[i] = ctx;
      g_al_n[i] = 0;
      g_al_cap[i] = 0;
      g_al_slots[i] = NULL;
      g_al_bn[i] = 0;
      g_al_bcap[i] = 0;
      g_al_brefs[i] = NULL;
      g_al_bbases[i] = NULL;
      return i;
    }
  }
  return -1;
}

static int al_ensure_slots(int slot, int32_t need) {
  uint8_t *np, *old;
  int32_t new_cap;
  if (slot < 0 || slot >= WAVE267_AL_SLOTS)
    return 0;
  if (need <= 0)
    return 1;
  if (g_al_cap[slot] >= need)
    return 1;
  new_cap = g_al_cap[slot];
  if (new_cap < 4)
    new_cap = 4;
  while (new_cap < need)
    new_cap *= 2;
  np = (uint8_t *)malloc((size_t)new_cap * (size_t)WAVE267_AL_ENTRY_SZ);
  if (!np)
    return 0;
  memset(np, 0, (size_t)new_cap * (size_t)WAVE267_AL_ENTRY_SZ);
  old = g_al_slots[slot];
  if (old && g_al_n[slot] > 0)
    memcpy(np, old, (size_t)g_al_n[slot] * (size_t)WAVE267_AL_ENTRY_SZ);
  if (old)
    free(old);
  g_al_slots[slot] = np;
  g_al_cap[slot] = new_cap;
  return 1;
}

static int al_ensure_blocks(int slot, int32_t need) {
  uint8_t *nr, *nb, *old_r, *old_b;
  int32_t new_cap;
  if (slot < 0 || slot >= WAVE267_AL_SLOTS)
    return 0;
  if (need <= 0)
    return 1;
  if (g_al_bcap[slot] >= need)
    return 1;
  new_cap = g_al_bcap[slot];
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
  old_r = g_al_brefs[slot];
  old_b = g_al_bbases[slot];
  if (g_al_bn[slot] > 0) {
    if (old_r)
      memcpy(nr, old_r, (size_t)g_al_bn[slot] * 4u);
    if (old_b)
      memcpy(nb, old_b, (size_t)g_al_bn[slot] * 4u);
  }
  free(old_r);
  free(old_b);
  g_al_brefs[slot] = nr;
  g_al_bbases[slot] = nb;
  g_al_bcap[slot] = new_cap;
  return 1;
}

static uint8_t *al_at(int slot, int32_t idx) {
  if (slot < 0 || slot >= WAVE267_AL_SLOTS)
    return NULL;
  if (idx < 0 || idx >= g_al_n[slot] || !g_al_slots[slot])
    return NULL;
  return g_al_slots[slot] + (size_t)idx * (size_t)WAVE267_AL_ENTRY_SZ;
}

void asm_ctx_block_slot_reset(uint8_t *ctx) {
  int s = al_find(ctx, 0);
  if (s < 0)
    return;
  g_al_bn[s] = 0;
}

void asm_ctx_local_reset(uint8_t *ctx) {
  int s = al_find(ctx, 0);
  if (s < 0)
    return;
  g_al_n[s] = 0;
  g_al_bn[s] = 0;
}

int32_t asm_ctx_local_count(uint8_t *ctx) {
  int s = al_find(ctx, 0);
  return s < 0 ? 0 : g_al_n[s];
}

int32_t asm_ctx_local_append(uint8_t *ctx, uint8_t *name, int32_t name_len, int32_t offset) {
  int s;
  int32_t idx, n, k;
  uint8_t *ent;
  if (!ctx || !name || name_len <= 0)
    return -1;
  s = al_find(ctx, 1);
  if (s < 0)
    return -1;
  idx = g_al_n[s];
  if (!al_ensure_slots(s, idx + 1))
    return -1;
  ent = g_al_slots[s] + (size_t)idx * (size_t)WAVE267_AL_ENTRY_SZ;
  if (!ent)
    return -1;
  memset(ent, 0, WAVE267_AL_ENTRY_SZ);
  n = name_len > 255 ? 255 : name_len;
  for (k = 0; k < n; k++)
    ent[k] = name[k];
  memcpy(ent + 256, &name_len, 4);
  /* Cap 4.2.8 sync: entry is name[256] -> offset@260 (was 132 on [128]). */
  memcpy(ent + 260, &offset, 4);
  g_al_n[s] = idx + 1;
  return idx;
}

int32_t asm_ctx_local_name_len(uint8_t *ctx, int32_t idx) {
  int s = al_find(ctx, 0);
  uint8_t *ent;
  int32_t n;
  if (s < 0)
    return 0;
  ent = al_at(s, idx);
  if (!ent)
    return 0;
  memcpy(&n, ent + 256, 4);
  return n;
}

uint8_t asm_ctx_local_name_byte_at(uint8_t *ctx, int32_t idx, int32_t off) {
  int s = al_find(ctx, 0);
  uint8_t *ent;
  int32_t nlen;
  if (off < 0 || s < 0)
    return 0;
  ent = al_at(s, idx);
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
  s = al_find(ctx, 0);
  if (s < 0)
    return;
  ent = al_at(s, idx);
  if (!ent)
    return;
  memcpy(&nlen, ent + 256, 4);
  n = nlen > 255 ? 255 : nlen;
  for (k = 0; k < n; k++)
    dst[k] = ent[k];
}

int32_t asm_ctx_local_offset_at(uint8_t *ctx, int32_t idx) {
  int s = al_find(ctx, 0);
  uint8_t *ent;
  int32_t off;
  if (s < 0)
    return 0;
  ent = al_at(s, idx);
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
  s = al_find(ctx, 0);
  if (s < 0)
    return -1;
  for (i = g_al_n[s] - 1; i >= 0; i--) {
    ent = al_at(s, i);
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
  s = al_find(ctx, 1);
  if (s < 0)
    return;
  idx = g_al_bn[s];
  if (!al_ensure_blocks(s, idx + 1))
    return;
  memcpy(g_al_brefs[s] + (size_t)idx * 4u, &block_ref, 4);
  memcpy(g_al_bbases[s] + (size_t)idx * 4u, &slot_base, 4);
  g_al_bn[s] = idx + 1;
}

int32_t asm_ctx_block_slot_get(uint8_t *ctx, int32_t block_ref) {
  int s;
  int32_t i, br, sb;
  if (!ctx || block_ref <= 0)
    return -1;
  s = al_find(ctx, 0);
  if (s < 0 || !g_al_brefs[s] || !g_al_bbases[s])
    return -1;
  for (i = g_al_bn[s] - 1; i >= 0; i--) {
    memcpy(&br, g_al_brefs[s] + (size_t)i * 4u, 4);
    if (br == block_ref) {
      memcpy(&sb, g_al_bbases[s] + (size_t)i * 4u, 4);
      return sb;
    }
  }
  return -1;
}
