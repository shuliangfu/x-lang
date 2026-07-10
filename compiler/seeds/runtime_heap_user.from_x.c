/* Generated from src/runtime_heap_user.x (G-02f-27 true .x + C tail).
 * Regen: ./shux-c -E -L .. src/runtime_heap_user.x > /tmp/rhu.c
 *         then re-apply C tail (aligned alloc + Arena64).
 * .x covers: heap_alloc_c / free_c / realloc_c / alloc_zeroed_c.
 */
#ifndef SHUX_RUNTIME_HEAP_USER_INC
#define SHUX_RUNTIME_HEAP_USER_INC

#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#if defined(__unix__) || defined(__APPLE__)
#include <stdlib.h>
#endif

uint8_t * heap_alloc_c(size_t size) {
  if ((size ==0)) {
    return ((uint8_t *)(0));
  }
  (void)(({   {
    uint8_t * r = malloc(size);
    return r;
  }
 }));
  return ((uint8_t *)(0));
}
void heap_free_c(uint8_t * ptr) {
  (void)(({   {
    (void)(free(ptr));
  }
 }));
}
uint8_t * heap_realloc_c(uint8_t * ptr, size_t new_size) {
  if ((new_size ==0)) {
    {
      (void)(free(ptr));
    }
    return ((uint8_t *)(0));
  }
  (void)(({   {
    uint8_t * r = realloc(ptr, new_size);
    return r;
  }
 }));
  return ((uint8_t *)(0));
}
uint8_t * heap_alloc_zeroed_c(size_t size) {
  if ((size ==0)) {
    return ((uint8_t *)(0));
  }
  (void)(({   {
    uint8_t * r = calloc(1, size);
    return r;
  }
 }));
  return ((uint8_t *)(0));
}

/** posix_memalign 薄封装；失败返回 null。 */
uint8_t *heap_alloc_aligned_c(size_t align_bytes, size_t size) {
    void *p = NULL;
    if (size == 0 || align_bytes == 0)
        return (uint8_t *)0;
#if defined(_WIN32) || defined(_WIN64)
    p = _aligned_malloc(size, align_bytes);
    if (!p)
        return (uint8_t *)0;
    return (uint8_t *)p;
#else
    if (posix_memalign(&p, align_bytes, size) != 0)
        return (uint8_t *)0;
    return (uint8_t *)p;
#endif
}

/** std.heap Arena64 布局（chunk/cap/off 各 8B）。 */
typedef struct ShuxHeapArena64 {
    uint8_t *chunk;
    size_t cap;
    size_t off;
} ShuxHeapArena64;

/** 初始化 Arena64；cap==0 时用 4096 默认 chunk。 */
int32_t heap_arena_init_c(ShuxHeapArena64 *a, size_t cap) {
    size_t use_cap;
    if (!a)
        return -1;
    a->chunk = (uint8_t *)0;
    a->cap = 0;
    a->off = 0;
    use_cap = cap;
    if (use_cap == 0)
        use_cap = 4096;
    a->chunk = heap_alloc_aligned_c(64, use_cap);
    if (!a->chunk)
        return -1;
    a->cap = use_cap;
    return 0;
}

/** 从 arena bump 分配 size 字节；align 为对象对齐（0 视为 8）。 */
uint8_t *heap_arena64_alloc_c(ShuxHeapArena64 *a, size_t size, size_t align_bytes) {
    size_t obj_align;
    size_t cur;
    size_t rem;
    size_t gap;
    size_t next;
    if (!a || !a->chunk || size == 0)
        return (uint8_t *)0;
    obj_align = align_bytes;
    if (obj_align == 0)
        obj_align = 8;
    cur = a->off;
    rem = cur % obj_align;
    gap = 0;
    if (rem != 0)
        gap = obj_align - rem;
    next = cur + gap + size;
    if (next > a->cap)
        return (uint8_t *)0;
    {
        uint8_t *out = a->chunk + cur + gap;
        a->off = next;
        return out;
    }
}

/** 释放 arena chunk 并重置。 */
void heap_arena64_deinit_c(ShuxHeapArena64 *a) {
    if (!a)
        return;
    heap_free_c(a->chunk);
    a->chunk = (uint8_t *)0;
    a->cap = 0;
    a->off = 0;
}

#endif /* SHUX_RUNTIME_HEAP_USER_INC */
