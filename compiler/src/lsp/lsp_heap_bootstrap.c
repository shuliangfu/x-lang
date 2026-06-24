/**
 * lsp_heap_bootstrap.c — bootstrap 链接 heap_alloc_c 等符号（转调 libc）
 *
 * lsp_diag_gen / lsp_io_std_heap_gen 经 -E-extern 引用 heap_*_c；
 * 冷启动无 std/heap.o 时由本 TU 提供。
 */
#include <stdint.h>
#include <stdlib.h>

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

/** 清零分配：转调 calloc。 */
uint8_t *heap_alloc_zeroed_c(size_t size) {
    if (size == 0)
        return (uint8_t *)0;
    return (uint8_t *)calloc(1, size);
}
