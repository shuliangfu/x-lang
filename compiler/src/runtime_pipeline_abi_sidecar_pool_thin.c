/*
 * Thin pure: wave275 Arena/Module/OneFunc sidecar pool Cap domain leave.
 * G.7: bodies match mega runtime_pipeline_abi.x wave275 leave /
 * seeds/runtime_pipeline_abi.from_x.c cold twins (direct C map, not Lxml).
 *
 * Independent C thin (Darwin additive-leaf rule). File-local BSS blobs:
 *   arena 512×816 / module 512×432 / onefunc 1024×944 + MRU caches.
 * Faces: arena|module|onefunc_sidecar_{get,free}.
 * GrowVec via wave271 thin (grow_vec_init/free).
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED freestanding sidecar Cap leave.
 */

#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <stdlib.h>

typedef struct {
  uint8_t *data;
  int32_t cap;
  int32_t len;
  size_t elem_sz;
  int32_t mmap_backed;
} GrowVec;

extern int grow_vec_init(GrowVec *v, size_t elem_sz, int32_t initial_cap);
extern void grow_vec_free(GrowVec *v);

#define W275_ARENA_SC_SIZE 816
#define W275_ARENA_SC_MAX 512
#define W275_MODULE_SC_SIZE 432
#define W275_MODULE_SC_MAX 512
#define W275_ONEFUNC_SC_SIZE 944
#define W275_ONEFUNC_SC_MAX 1024
#define W275_GV_INIT_CAP 256

static uint8_t g_w275_arena_sc_blob[W275_ARENA_SC_MAX * W275_ARENA_SC_SIZE];
static uint8_t g_w275_module_sc_blob[W275_MODULE_SC_MAX * W275_MODULE_SC_SIZE];
static uint8_t g_w275_onefunc_sc_blob[W275_ONEFUNC_SC_MAX * W275_ONEFUNC_SC_SIZE];
/* Arena/module: 2-slot MRU. Onefunc: 16-slot ring + used_hi. */
static void *g_w275_arena_last_key0;
static uint8_t *g_w275_arena_last_sc0;
static void *g_w275_arena_last_key1;
static uint8_t *g_w275_arena_last_sc1;
static void *g_w275_module_last_key0;
static uint8_t *g_w275_module_last_sc0;
static void *g_w275_module_last_key1;
static uint8_t *g_w275_module_last_sc1;
#define W275_ONEFUNC_MRU_N 16
static void *g_w275_onefunc_mru_key[W275_ONEFUNC_MRU_N];
static uint8_t *g_w275_onefunc_mru_sc[W275_ONEFUNC_MRU_N];
static int g_w275_onefunc_mru_clock;
static int g_w275_onefunc_used_hi;

static uint8_t *w275_arena_sc_at(int i) {
  if (i < 0 || i >= W275_ARENA_SC_MAX) return NULL;
  return g_w275_arena_sc_blob + (size_t)i * W275_ARENA_SC_SIZE;
}
static uint8_t *w275_module_sc_at(int i) {
  if (i < 0 || i >= W275_MODULE_SC_MAX) return NULL;
  return g_w275_module_sc_blob + (size_t)i * W275_MODULE_SC_SIZE;
}
static uint8_t *w275_onefunc_sc_at(int i) {
  if (i < 0 || i >= W275_ONEFUNC_SC_MAX) return NULL;
  return g_w275_onefunc_sc_blob + (size_t)i * W275_ONEFUNC_SC_SIZE;
}

static int32_t w275_load_i32(uint8_t *b, int off) {
  int32_t v;
  memcpy(&v, b + off, 4);
  return v;
}
static void w275_store_i32(uint8_t *b, int off, int32_t v) {
  memcpy(b + off, &v, 4);
}
static void *w275_load_ptr(uint8_t *b, int off) {
  void *p;
  memcpy(&p, b + off, sizeof(void *));
  return p;
}
static void w275_store_ptr(uint8_t *b, int off, void *p) {
  memcpy(b + off, &p, sizeof(void *));
}

static int w275_sidecar_slot_ok(uint8_t *sc, void *key) {
  return sc && w275_load_i32(sc, 8) && w275_load_ptr(sc, 0) == key;
}

static uint8_t *w275_sidecar_recall(void *k0, uint8_t *s0, void *k1, uint8_t *s1, void *key) {
  if (k0 == key && w275_sidecar_slot_ok(s0, key))
    return s0;
  if (k1 == key && w275_sidecar_slot_ok(s1, key))
    return s1;
  return NULL;
}

static void w275_sidecar_remember(void **k0, uint8_t **s0, void **k1, uint8_t **s1, void *key, uint8_t *sc) {
  if (*k0 == key) {
    *s0 = sc;
    return;
  }
  *k1 = *k0;
  *s1 = *s0;
  *k0 = key;
  *s0 = sc;
}

static void w275_sidecar_drop(void **k0, uint8_t **s0, void **k1, uint8_t **s1, uint8_t *sc) {
  if (*s0 == sc) {
    *k0 = NULL;
    *s0 = NULL;
  }
  if (*s1 == sc) {
    *k1 = NULL;
    *s1 = NULL;
  }
}

static uint8_t *w275_onefunc_mru_recall(void *key) {
  int i;
  for (i = 0; i < W275_ONEFUNC_MRU_N; i++) {
    if (g_w275_onefunc_mru_key[i] == key &&
        w275_sidecar_slot_ok(g_w275_onefunc_mru_sc[i], key))
      return g_w275_onefunc_mru_sc[i];
  }
  return NULL;
}

static void w275_onefunc_mru_remember(void *key, uint8_t *sc) {
  int i;
  int slot;
  for (i = 0; i < W275_ONEFUNC_MRU_N; i++) {
    if (g_w275_onefunc_mru_key[i] == key) {
      g_w275_onefunc_mru_sc[i] = sc;
      return;
    }
  }
  slot = g_w275_onefunc_mru_clock;
  if (slot < 0 || slot >= W275_ONEFUNC_MRU_N)
    slot = 0;
  g_w275_onefunc_mru_key[slot] = key;
  g_w275_onefunc_mru_sc[slot] = sc;
  slot++;
  if (slot >= W275_ONEFUNC_MRU_N)
    slot = 0;
  g_w275_onefunc_mru_clock = slot;
}

static void w275_onefunc_mru_drop(uint8_t *sc) {
  int i;
  for (i = 0; i < W275_ONEFUNC_MRU_N; i++) {
    if (g_w275_onefunc_mru_sc[i] == sc) {
      g_w275_onefunc_mru_key[i] = NULL;
      g_w275_onefunc_mru_sc[i] = NULL;
    }
  }
}

static void w275_onefunc_shrink_hi(void) {
  while (g_w275_onefunc_used_hi > 0) {
    uint8_t *last = w275_onefunc_sc_at(g_w275_onefunc_used_hi - 1);
    if (w275_load_i32(last, 8) != 0)
      return;
    g_w275_onefunc_used_hi--;
  }
}

static void arena_sidecar_free_inner(uint8_t *sc) {
  if (!sc) return;
  w275_sidecar_drop(&g_w275_arena_last_key0, &g_w275_arena_last_sc0,
                    &g_w275_arena_last_key1, &g_w275_arena_last_sc1, sc);
  grow_vec_free((GrowVec *)(sc + 16));
  grow_vec_free((GrowVec *)(sc + 48));
  grow_vec_free((GrowVec *)(sc + 80));
  grow_vec_free((GrowVec *)(sc + 112));
  grow_vec_free((GrowVec *)(sc + 144));
  grow_vec_free((GrowVec *)(sc + 176));
  grow_vec_free((GrowVec *)(sc + 208));
  grow_vec_free((GrowVec *)(sc + 240));
  grow_vec_free((GrowVec *)(sc + 272));
  grow_vec_free((GrowVec *)(sc + 304));
  grow_vec_free((GrowVec *)(sc + 336));
  grow_vec_free((GrowVec *)(sc + 368));
  grow_vec_free((GrowVec *)(sc + 400));
  grow_vec_free((GrowVec *)(sc + 432));
  grow_vec_free((GrowVec *)(sc + 464));
  grow_vec_free((GrowVec *)(sc + 496));
  grow_vec_free((GrowVec *)(sc + 528));
  grow_vec_free((GrowVec *)(sc + 560));
  grow_vec_free((GrowVec *)(sc + 592));
  grow_vec_free((GrowVec *)(sc + 624));
  grow_vec_free((GrowVec *)(sc + 656));
  grow_vec_free((GrowVec *)(sc + 688));
  grow_vec_free((GrowVec *)(sc + 720));
  grow_vec_free((GrowVec *)(sc + 752));
  grow_vec_free((GrowVec *)(sc + 784));
  memset(sc, 0, W275_ARENA_SC_SIZE);
}
void arena_sidecar_free(void *sc) { arena_sidecar_free_inner((uint8_t *)sc); }
static void module_sidecar_free_inner(uint8_t *sc) {
  if (!sc) return;
  w275_sidecar_drop(&g_w275_module_last_key0, &g_w275_module_last_sc0,
                    &g_w275_module_last_key1, &g_w275_module_last_sc1, sc);
  grow_vec_free((GrowVec *)(sc + 16));
  grow_vec_free((GrowVec *)(sc + 48));
  grow_vec_free((GrowVec *)(sc + 80));
  grow_vec_free((GrowVec *)(sc + 112));
  grow_vec_free((GrowVec *)(sc + 144));
  grow_vec_free((GrowVec *)(sc + 176));
  grow_vec_free((GrowVec *)(sc + 208));
  grow_vec_free((GrowVec *)(sc + 240));
  grow_vec_free((GrowVec *)(sc + 272));
  grow_vec_free((GrowVec *)(sc + 304));
  grow_vec_free((GrowVec *)(sc + 336));
  grow_vec_free((GrowVec *)(sc + 368));
  grow_vec_free((GrowVec *)(sc + 400));
  memset(sc, 0, W275_MODULE_SC_SIZE);
}
void module_sidecar_free(void *sc) { module_sidecar_free_inner((uint8_t *)sc); }
static void onefunc_sidecar_free_inner(uint8_t *sc) {
  if (!sc) return;
  w275_onefunc_mru_drop(sc);
  grow_vec_free((GrowVec *)(sc + 16));
  grow_vec_free((GrowVec *)(sc + 48));
  grow_vec_free((GrowVec *)(sc + 80));
  grow_vec_free((GrowVec *)(sc + 112));
  grow_vec_free((GrowVec *)(sc + 144));
  grow_vec_free((GrowVec *)(sc + 176));
  grow_vec_free((GrowVec *)(sc + 208));
  grow_vec_free((GrowVec *)(sc + 240));
  grow_vec_free((GrowVec *)(sc + 272));
  grow_vec_free((GrowVec *)(sc + 304));
  grow_vec_free((GrowVec *)(sc + 336));
  grow_vec_free((GrowVec *)(sc + 368));
  grow_vec_free((GrowVec *)(sc + 400));
  grow_vec_free((GrowVec *)(sc + 432));
  grow_vec_free((GrowVec *)(sc + 464));
  grow_vec_free((GrowVec *)(sc + 496));
  grow_vec_free((GrowVec *)(sc + 528));
  grow_vec_free((GrowVec *)(sc + 560));
  grow_vec_free((GrowVec *)(sc + 592));
  grow_vec_free((GrowVec *)(sc + 624));
  grow_vec_free((GrowVec *)(sc + 656));
  grow_vec_free((GrowVec *)(sc + 688));
  grow_vec_free((GrowVec *)(sc + 720));
  grow_vec_free((GrowVec *)(sc + 752));
  grow_vec_free((GrowVec *)(sc + 784));
  grow_vec_free((GrowVec *)(sc + 816));
  grow_vec_free((GrowVec *)(sc + 848));
  grow_vec_free((GrowVec *)(sc + 880));
  grow_vec_free((GrowVec *)(sc + 912));
  memset(sc, 0, W275_ONEFUNC_SC_SIZE);
  w275_onefunc_shrink_hi();
}
void onefunc_sidecar_free(void *sc) { onefunc_sidecar_free_inner((uint8_t *)sc); }
void *arena_sidecar_get(void *key, int create) {
  int i;
  uint8_t *hit;
  if (!key) return NULL;
  hit = w275_sidecar_recall(g_w275_arena_last_key0, g_w275_arena_last_sc0,
                            g_w275_arena_last_key1, g_w275_arena_last_sc1, key);
  if (hit)
    return hit;
  for (i = 0; i < W275_ARENA_SC_MAX; i++) {
    uint8_t *sc = w275_arena_sc_at(i);
    if (w275_load_i32(sc, 8) && w275_load_ptr(sc, 0) == key) {
      w275_sidecar_remember(&g_w275_arena_last_key0, &g_w275_arena_last_sc0,
                            &g_w275_arena_last_key1, &g_w275_arena_last_sc1, key, sc);
      return sc;
    }
  }
  if (!create) return NULL;
  for (i = 0; i < W275_ARENA_SC_MAX; i++) {
    uint8_t *sc = w275_arena_sc_at(i);
    if (w275_load_i32(sc, 8) == 0) {
      w275_store_ptr(sc, 0, key);
      w275_store_i32(sc, 8, 1);
      if (!grow_vec_init((GrowVec *)(sc + 16), (size_t)532, W275_GV_INIT_CAP)) {
        arena_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 48), (size_t)1224, W275_GV_INIT_CAP)) {
        arena_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 80), (size_t)92, W275_GV_INIT_CAP)) {
        arena_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 112), (size_t)324, W275_GV_INIT_CAP)) {
        arena_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 144), (size_t)268, W275_GV_INIT_CAP)) {
        arena_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 176), (size_t)268, W275_GV_INIT_CAP)) {
        arena_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 208), (size_t)12, W275_GV_INIT_CAP)) {
        arena_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 240), (size_t)268, W275_GV_INIT_CAP)) {
        arena_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 272), (size_t)8, W275_GV_INIT_CAP)) {
        arena_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 304), (size_t)16, W275_GV_INIT_CAP)) {
        arena_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 336), (size_t)4, W275_GV_INIT_CAP)) {
        arena_sidecar_free_inner(sc); return NULL;
      }
      /* Cap 4.2.8 sync: W277_LabeledStmt is 528 (was 272 on 128-era names). */
      if (!grow_vec_init((GrowVec *)(sc + 368), (size_t)528, W275_GV_INIT_CAP)) {
        arena_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 400), (size_t)4, W275_GV_INIT_CAP)) {
        arena_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 432), (size_t)8, W275_GV_INIT_CAP)) {
        arena_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 464), (size_t)4, W275_GV_INIT_CAP)) {
        arena_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 496), (size_t)4, W275_GV_INIT_CAP)) {
        arena_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 528), (size_t)4, W275_GV_INIT_CAP)) {
        arena_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 560), (size_t)4, W275_GV_INIT_CAP)) {
        arena_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 592), (size_t)4, W275_GV_INIT_CAP)) {
        arena_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 624), (size_t)4, W275_GV_INIT_CAP)) {
        arena_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 656), (size_t)4, W275_GV_INIT_CAP)) {
        arena_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 688), (size_t)24, W275_GV_INIT_CAP)) {
        arena_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 720), (size_t)264, W275_GV_INIT_CAP)) {
        arena_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 752), (size_t)4, W275_GV_INIT_CAP)) {
        arena_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 784), (size_t)264, W275_GV_INIT_CAP)) {
        arena_sidecar_free_inner(sc); return NULL;
      }
      w275_sidecar_remember(&g_w275_arena_last_key0, &g_w275_arena_last_sc0,
                            &g_w275_arena_last_key1, &g_w275_arena_last_sc1, key, sc);
      return sc;
    }
  }
  return NULL;
}
void *module_sidecar_get(void *key, int create) {
  int i;
  uint8_t *hit;
  if (!key) return NULL;
  hit = w275_sidecar_recall(g_w275_module_last_key0, g_w275_module_last_sc0,
                            g_w275_module_last_key1, g_w275_module_last_sc1, key);
  if (hit)
    return hit;
  for (i = 0; i < W275_MODULE_SC_MAX; i++) {
    uint8_t *sc = w275_module_sc_at(i);
    if (w275_load_i32(sc, 8) && w275_load_ptr(sc, 0) == key) {
      w275_sidecar_remember(&g_w275_module_last_key0, &g_w275_module_last_sc0,
                            &g_w275_module_last_key1, &g_w275_module_last_sc1, key, sc);
      return sc;
    }
  }
  if (!create) return NULL;
  for (i = 0; i < W275_MODULE_SC_MAX; i++) {
    uint8_t *sc = w275_module_sc_at(i);
    if (w275_load_i32(sc, 8) == 0) {
      w275_store_ptr(sc, 0, key);
      w275_store_i32(sc, 8, 1);
      if (!grow_vec_init((GrowVec *)(sc + 16), (size_t)324, W275_GV_INIT_CAP)) {
        module_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 48), (size_t)4, W275_GV_INIT_CAP)) {
        module_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 80), (size_t)532, W275_GV_INIT_CAP)) {
        module_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 112), (size_t)288, W275_GV_INIT_CAP)) {
        module_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 144), (size_t)276, W275_GV_INIT_CAP)) {
        module_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 176), (size_t)264, W275_GV_INIT_CAP)) {
        module_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 208), (size_t)66828, W275_GV_INIT_CAP)) {
        module_sidecar_free_inner(sc); return NULL;
      }
      /* Cap 4.2.8 sync: import_select_name_rows name[256] -> 256 (was 128;
       * matches .x thin init; pool is vestigial — live select names use the
       * wave263 legacy sidecar / g_pipe_imp_sel_rows tables). */
      if (!grow_vec_init((GrowVec *)(sc + 240), (size_t)256, W275_GV_INIT_CAP)) {
        module_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 272), (size_t)4, W275_GV_INIT_CAP)) {
        module_sidecar_free_inner(sc); return NULL;
      }
      /* Cap 4.2.8 sync: struct_layout_fields name[256] -> 264 (was 136). */
      if (!grow_vec_init((GrowVec *)(sc + 304), (size_t)264, W275_GV_INIT_CAP)) {
        module_sidecar_free_inner(sc); return NULL;
      }
      /* Cap 4.2.8 sync: struct_layout_type_params name[256]+meta -> 272 (was 144). */
      if (!grow_vec_init((GrowVec *)(sc + 336), (size_t)272, W275_GV_INIT_CAP)) {
        module_sidecar_free_inner(sc); return NULL;
      }
      /* Cap 4.2.8 sync: struct_layout_type_param_meta name[256]+len -> 260 (was 132). */
      if (!grow_vec_init((GrowVec *)(sc + 368), (size_t)260, W275_GV_INIT_CAP)) {
        module_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 400), (size_t)8, W275_GV_INIT_CAP)) {
        module_sidecar_free_inner(sc); return NULL;
      }
      w275_sidecar_remember(&g_w275_module_last_key0, &g_w275_module_last_sc0,
                            &g_w275_module_last_key1, &g_w275_module_last_sc1, key, sc);
      return sc;
    }
  }
  return NULL;
}
void *onefunc_sidecar_get(void *key, int create) {
  int i;
  int lim;
  uint8_t *hit;
  if (!key) return NULL;
  hit = w275_onefunc_mru_recall(key);
  if (hit)
    return hit;
  lim = g_w275_onefunc_used_hi;
  if (lim < 0)
    lim = 0;
  if (lim > W275_ONEFUNC_SC_MAX)
    lim = W275_ONEFUNC_SC_MAX;
  for (i = 0; i < lim; i++) {
    uint8_t *sc = w275_onefunc_sc_at(i);
    if (w275_load_i32(sc, 8) && w275_load_ptr(sc, 0) == key) {
      w275_onefunc_mru_remember(key, sc);
      return sc;
    }
  }
  if (!create) return NULL;
  for (i = 0; i < W275_ONEFUNC_SC_MAX; i++) {
    uint8_t *sc = w275_onefunc_sc_at(i);
    if (w275_load_i32(sc, 8) == 0) {
      w275_store_ptr(sc, 0, key);
      w275_store_i32(sc, 8, 1);
      if (i + 1 > g_w275_onefunc_used_hi)
        g_w275_onefunc_used_hi = i + 1;
      if (!grow_vec_init((GrowVec *)(sc + 16), (size_t)4, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 48), (size_t)4, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 80), (size_t)4, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      /* Cap 4.2.8: name rows 128→256 (content ≤255; was [128]). */
      if (!grow_vec_init((GrowVec *)(sc + 112), (size_t)256, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 144), (size_t)4, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 176), (size_t)4, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 208), (size_t)4, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 240), (size_t)4, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 272), (size_t)256, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 304), (size_t)4, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 336), (size_t)4, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 368), (size_t)4, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 400), (size_t)4, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 432), (size_t)1, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 464), (size_t)4, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 496), (size_t)4, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 528), (size_t)4, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 560), (size_t)4, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 592), (size_t)4, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 624), (size_t)4, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 656), (size_t)4, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 688), (size_t)4, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 720), (size_t)256, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 752), (size_t)4, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 784), (size_t)4, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 816), (size_t)4, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      /* Cap 4.2.8 missed mirror: W281_RegionEntry is 268 (label[256]); the
       * stale 140 stride made entry N+1's 268-byte write overlap entry N's
       * tail — body_ref/with_arena_cap_ref (offsets 260/264) were smashed by
       * label bytes, so consecutive unsafe/region statements lost all but
       * the last (2026-09-13 L4 m5/m6/m9 forensics). */
      if (!grow_vec_init((GrowVec *)(sc + 848), (size_t)268, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      if (!grow_vec_init((GrowVec *)(sc + 880), (size_t)4, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      /* Cap 4.2.8: W281_LabeledEntry 272→528 (label[256] + goto_target[256]). */
      if (!grow_vec_init((GrowVec *)(sc + 912), (size_t)528, W275_GV_INIT_CAP)) {
        onefunc_sidecar_free_inner(sc); return NULL;
      }
      w275_onefunc_mru_remember(key, sc);
      return sc;
    }
  }
  return NULL;
}

