/**
 * runtime_heap_user.c — 用户 asm 程序链接 heap_*_c 符号（转调 libc）
 *
 * co-emit std.heap 薄模块仅含 allocator_* 时，call redirect 指向本 TU；
 * 与 lsp_heap_bootstrap.c 语义一致，独立编译供 runtime_link_abi 按需链入。
 */
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

/** std.heap Arena64 布局（chunk/cap/off 各 8B）。 */
typedef struct ShuxHeapArena64 {
    uint8_t *chunk;
    size_t cap;
    size_t off;
} ShuxHeapArena64;

/** 堆分配：转调 malloc。 */
uint8_t *heap_alloc_c(size_t size) {
    if (size == 0)
        return (uint8_t *)0;
    return (uint8_t *)malloc(size);
}

/** 堆释放：转调 free。 */
void heap_free_c(uint8_t *ptr) {
    free((void *)ptr);
}

/** 堆调整：转调 realloc。 */
uint8_t *heap_realloc_c(uint8_t *ptr, size_t new_size) {
    if (new_size == 0) {
        free((void *)ptr);
        return (uint8_t *)0;
    }
    return (uint8_t *)realloc((void *)ptr, new_size);
}

/** 清零分配：转调 calloc。 */
uint8_t *heap_alloc_zeroed_c(size_t size) {
    if (size == 0)
        return (uint8_t *)0;
    return (uint8_t *)calloc(1, size);
}

/** posix_memalign 薄封装；失败返回 null。 */
uint8_t *heap_alloc_aligned_c(size_t align_bytes, size_t size) {
    void *p = NULL;
    if (size == 0 || align_bytes == 0)
        return (uint8_t *)0;
    if (posix_memalign(&p, align_bytes, size) != 0)
        return (uint8_t *)0;
    return (uint8_t *)p;
}

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
