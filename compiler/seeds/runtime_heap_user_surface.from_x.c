/* seeds/runtime_heap_user_surface.from_x.c
 * G-02f-87 runtime_heap_user R2 DIRECT surface - isomorphic with src/runtime_heap_user.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/runtime_heap_user.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (7 #[no_mangle])
 * Mode: DIRECT - 7 #[no_mangle] (heap_alloc_c + heap_free_c + heap_realloc_c + heap_alloc_zeroed_c
 *   + heap_arena_init_c + heap_arena64_alloc_c + heap_arena64_deinit_c)
 * Cap residual: malloc/free/realloc/calloc/heap_alloc_aligned_c (extern bridges, not #[no_mangle])
 * No doc_anchor (runtime_heap_user.x has none).
 * Note: heap_ prefix not trigger ast_ (confirmed wave545+).
 * Logic: 7 DIRECT functions + struct runtime_heap_user_XlangHeapArena64.
 * Regen: ./xlang-c -E ... runtime_heap_user.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

extern void *malloc(size_t size);
extern void free(void *ptr);
extern void *realloc(void *ptr, size_t new_size);
extern void *calloc(size_t n, size_t size);
extern uint8_t *heap_alloc_aligned_c(size_t align_bytes, size_t size);

struct runtime_heap_user_XlangHeapArena64 {
  uint8_t *chunk;
  size_t cap;
  size_t off;
};

/* === 7 DIRECT functions === */

uint8_t *heap_alloc_c(size_t size) {
  if (size == 0) { return (uint8_t *)0; }
  return (uint8_t *)malloc(size);
}

void heap_free_c(uint8_t *ptr) {
  free(ptr);
}

uint8_t *heap_realloc_c(uint8_t *ptr, size_t new_size) {
  if (new_size == 0) {
    free(ptr);
    return (uint8_t *)0;
  }
  return (uint8_t *)realloc(ptr, new_size);
}

uint8_t *heap_alloc_zeroed_c(size_t size) {
  if (size == 0) { return (uint8_t *)0; }
  return (uint8_t *)calloc(1, size);
}

int32_t heap_arena_init_c(struct runtime_heap_user_XlangHeapArena64 *a, size_t cap) {
  if (a == 0) { return -1; }
  a->chunk = (uint8_t *)0;
  a->cap = 0;
  a->off = 0;
  size_t use_cap = cap;
  if (use_cap == 0) { use_cap = 4096; }
  a->chunk = heap_alloc_aligned_c(64, use_cap);
  if (a->chunk == (uint8_t *)0) { return -1; }
  a->cap = use_cap;
  return 0;
}

uint8_t *heap_arena64_alloc_c(struct runtime_heap_user_XlangHeapArena64 *a, size_t size, size_t align_bytes) {
  if (a == 0) { return (uint8_t *)0; }
  if (a->chunk == (uint8_t *)0) { return (uint8_t *)0; }
  if (size == 0) { return (uint8_t *)0; }
  size_t obj_align = align_bytes;
  if (obj_align == 0) { obj_align = 8; }
  size_t cur = a->off;
  size_t rem = cur % obj_align;
  size_t gap = 0;
  if (rem != 0) { gap = obj_align - rem; }
  size_t next = cur + gap + size;
  if (next > a->cap) { return (uint8_t *)0; }
  uint8_t *out = a->chunk + cur + gap;
  a->off = next;
  return out;
}

void heap_arena64_deinit_c(struct runtime_heap_user_XlangHeapArena64 *a) {
  if (a == 0) { return; }
  heap_free_c(a->chunk);
  a->chunk = (uint8_t *)0;
  a->cap = 0;
  a->off = 0;
}
