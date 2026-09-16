/*
 * Thin pure: wave271 GrowVec Cap domain leave.
 * G.7: bodies match mega runtime_pipeline_abi.x wave271 leave /
 * seeds/runtime_pipeline_abi.from_x.c cold twins (direct C map, not Lxml).
 *
 * Independent C thin (Darwin additive-leaf rule).
 * GrowVec LE sizeof 32: data*@0 cap@8 len@12 elem_sz@16 mmap@24
 * Faces: grow_vec_init / free / ensure / at / push / copy_append
 * Growth: INIT_CAP=256, GROW=4096, MMAP_THRESH=1MiB (POSIX mmap).
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED freestanding GrowVec Cap leave · POSIX mmap ·
 * WINDOWS falls back to calloc/realloc (no mmap).
 */

#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#if defined(__APPLE__) || defined(__linux__)
#include <sys/mman.h>
#endif

#ifndef AST_POOL_GROW
#define AST_POOL_GROW 4096
#endif
#ifndef AST_POOL_INIT_CAP
#define AST_POOL_INIT_CAP 256
#endif
#ifndef GROW_VEC_MMAP_THRESH
#define GROW_VEC_MMAP_THRESH ((size_t)(1024 * 1024))
#endif

typedef struct {
  uint8_t *data;
  int32_t cap;
  int32_t len;
  size_t elem_sz;
  int32_t mmap_backed;
} GrowVec;
static void *gv_alloc_bytes(size_t nbytes, int32_t *out_mmap) {
  if (out_mmap)
    *out_mmap = 0;
  if (nbytes == 0)
    return NULL;
#if defined(__APPLE__) || defined(__linux__)
  if (nbytes >= GROW_VEC_MMAP_THRESH) {
    void *p = mmap(NULL, nbytes, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANON, -1, 0);
    if (p != MAP_FAILED) {
      if (out_mmap)
        *out_mmap = 1;
      return p;
    }
  }
#endif
  return calloc(1, nbytes);
}

static void gv_dealloc_bytes(void *p, size_t nbytes, int32_t mmap_backed) {
  if (!p)
    return;
#if defined(__APPLE__) || defined(__linux__)
  if (mmap_backed) {
    if (nbytes > 0)
      (void)munmap(p, nbytes);
    return;
  }
#else
  (void)nbytes;
  (void)mmap_backed;
#endif
  free(p);
}

int grow_vec_init(GrowVec *v, size_t elem_sz, int32_t initial_cap) {
  size_t nbytes;
  int32_t mm = 0;
  if (!v || elem_sz == 0)
    return 0;
  v->data = NULL;
  v->cap = 0;
  v->len = 0;
  v->elem_sz = elem_sz;
  v->mmap_backed = 0;
  if (initial_cap <= 0)
    initial_cap = AST_POOL_INIT_CAP;
  nbytes = (size_t)initial_cap * elem_sz;
  v->data = (uint8_t *)gv_alloc_bytes(nbytes, &mm);
  if (!v->data)
    return 0;
  v->mmap_backed = mm;
  v->cap = initial_cap;
  return 1;
}

void grow_vec_free(GrowVec *v) {
  if (v && v->data) {
    size_t nbytes = (size_t)v->cap * v->elem_sz;
    gv_dealloc_bytes(v->data, nbytes, v->mmap_backed);
    v->data = NULL;
  }
  if (v) {
    v->cap = 0;
    v->len = 0;
    v->mmap_backed = 0;
  }
}

int grow_vec_ensure(GrowVec *v) {
  int32_t need;
  int32_t nc;
  int32_t old_cap;
  int32_t mm = 0;
  size_t old_bytes;
  size_t new_bytes;
  uint8_t *p;
  if (!v)
    return 0;
  need = v->len + 1;
  if (need <= v->cap)
    return 1;
  old_cap = v->cap;
  nc = v->cap > 0 ? v->cap : AST_POOL_GROW;
  if (v->mmap_backed ||
      (size_t)need * v->elem_sz >= GROW_VEC_MMAP_THRESH ||
      (size_t)nc * v->elem_sz >= GROW_VEC_MMAP_THRESH) {
    while (nc < need) {
      if (nc > 1073741823) {
        nc = need;
        break;
      }
      nc = nc * 2;
    }
    if (nc < need)
      nc = need;
  } else {
    while (nc < need)
      nc += AST_POOL_GROW;
  }
  old_bytes = (size_t)old_cap * v->elem_sz;
  new_bytes = (size_t)nc * v->elem_sz;
  if (v->mmap_backed || new_bytes >= GROW_VEC_MMAP_THRESH) {
    p = (uint8_t *)gv_alloc_bytes(new_bytes, &mm);
    if (!p)
      return 0;
    if (v->data && old_bytes > 0)
      memcpy(p, v->data, old_bytes);
    gv_dealloc_bytes(v->data, old_bytes, v->mmap_backed);
    v->data = p;
    v->mmap_backed = mm;
    v->cap = nc;
    return 1;
  }
  p = (uint8_t *)realloc(v->data, new_bytes);
  if (!p)
    return 0;
  memset(p + old_bytes, 0, new_bytes - old_bytes);
  v->data = p;
  v->mmap_backed = 0;
  v->cap = nc;
  return 1;
}

void *grow_vec_at(GrowVec *v, int32_t idx) {
  if (!v || !v->data || idx < 0 || idx >= v->len)
    return NULL;
  return v->data + (size_t)idx * v->elem_sz;
}

int32_t grow_vec_push(GrowVec *v) {
  int32_t idx;
  if (!grow_vec_ensure(v))
    return -1;
  idx = v->len;
  memset(v->data + (size_t)idx * v->elem_sz, 0, v->elem_sz);
  v->len++;
  return idx;
}

void grow_vec_copy_append(GrowVec *dst, GrowVec *src) {
  int32_t i;
  if (!dst || !src)
    return;
  for (i = 0; i < src->len; i++) {
    void *ps = grow_vec_at(src, i);
    void *pd;
    if (grow_vec_push(dst) < 0)
      return;
    pd = grow_vec_at(dst, dst->len - 1);
    if (ps && pd)
      memcpy(pd, ps, src->elem_sz);
  }
}

