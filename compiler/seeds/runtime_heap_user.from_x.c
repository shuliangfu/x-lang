/* Generated from src/runtime_heap_user.x (G-02f-27 true .x + C tail).
 * Regen: ./xlang-c -E -L .. src/runtime_heap_user.x > /tmp/rhu.c
 *         then re-apply C tail (aligned alloc + Arena64).
 * .x covers: heap_alloc_c / free_c / realloc_c / alloc_zeroed_c.
 */
#ifndef XLANG_RUNTIME_HEAP_USER_INC
#define XLANG_RUNTIME_HEAP_USER_INC

#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#if defined(__unix__) || defined(__APPLE__)
#include <stdlib.h>
#endif

/* thin+rest 切割：thin 部分（heap_alloc/free/realloc/zeroed_c）由 .x 提供，
 * rest 模式下跳过编译避免重复定义。rest 部分（aligned_c + Arena64）始终编译。
 * 宏边界：XLANG_RUNTIME_HEAP_USER_FROM_X */
#ifndef XLANG_RUNTIME_HEAP_USER_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_RUNTIME_HEAP_USER_FROM_X removed */
#else
/* rest 模式：thin 函数由 .x 提供，extern 声明供 rest 部分调用 */
extern uint8_t * heap_alloc_c(size_t size);
extern void heap_free_c(uint8_t * ptr);
extern uint8_t * heap_realloc_c(uint8_t * ptr, size_t new_size);
extern uint8_t * heap_alloc_zeroed_c(size_t size);
#endif /* XLANG_RUNTIME_HEAP_USER_FROM_X */

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

/* G-02f-rest：rest→.x 迁移：Arena64 struct + 3 函数真迁 .x，seed 进入 DIRECT 模式 */
#ifndef XLANG_RUNTIME_HEAP_USER_FROM_X
#endif /* XLANG_RUNTIME_HEAP_USER_FROM_X */

#endif /* XLANG_RUNTIME_HEAP_USER_INC */
