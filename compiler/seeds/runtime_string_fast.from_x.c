/* seeds/runtime_string_fast.from_x.c — G-02f-21 product TU
 * G-02f-99 portable memmem gate.
 * G-02f-rest：rest→.x 迁移完成；seed 中 8 个函数均由 .x 提供。
 *   PREFER_X_O 路径下 seed 整体跳过，进入 DIRECT 模式（无 ld -r）。
 *   冷启动路径下（xlang-c 不可用）seed 完整编译，保持语义同源。
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>

/* G-02f-rest：rest→.x 迁移 — 8 个函数全部包入 #ifndef，由 .x 提供权威实现 */
#ifndef XLANG_RUNTIME_STRING_FAST_FROM_X
/* 完整模式（未定义 FROM_X 宏）：8 个函数由 seed 提供（冷启动路径） */

uint8_t *xlang_string_ptr_at_c(uint8_t *ptr, int32_t off) {
    if (!ptr)
        return 0;
    return ptr + off;
}

int32_t xlang_string_memcmp_c(uint8_t *a, uint8_t *b, int32_t n) {
    int r;
    if (n <= 0)
        return 0;
    r = memcmp(a, b, (size_t)n);
    if (r < 0)
        return -1;
    if (r > 0)
        return 1;
    return 0;
}

int32_t xlang_string_memcmp_at_c(uint8_t *a, int32_t off, uint8_t *b, int32_t n) {
    if (n <= 0)
        return 0;
    return memcmp(a + off, b, (size_t)n);
}

void xlang_string_copy_c(uint8_t *dst, uint8_t *src, int32_t n) {
    if (n <= 0)
        return;
    memcpy(dst, src, (size_t)n);
}

/* G-02f-20 thin+rest：thin（src/asm/runtime_string_fast.x）提供 4 个 pure helpers */
/* 完整模式（未定义 thin 宏）：thin 函数由 seed 提供 */

int32_t xlang_string_memchr_c(uint8_t *ptr, uint8_t c, int32_t n) {
    uint8_t *p;
    if (n <= 0)
        return -1;
    p = (uint8_t *)memchr(ptr, (int)c, (size_t)n);
    if (!p)
        return -1;
    return (int32_t)(p - ptr);
}

int32_t xlang_string_memrchr_c(uint8_t *ptr, uint8_t c, int32_t n) {
    int32_t i;
    if (n <= 0)
        return -1;
    for (i = n - 1; i >= 0; i--) {
        if (ptr[i] == c)
            return i;
    }
    return -1;
}

/* G-02f-151：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
int32_t xlang_string_portable_memmem_c(uint8_t *hay, int32_t hay_len, uint8_t *needle, int32_t needle_len) {
    int32_t i;
    int32_t j;
    if (needle_len <= 0)
        return 0;
    if (hay_len < needle_len)
        return -1;
    if (needle_len == 1)
        return xlang_string_memchr_c(hay, needle[0], hay_len);
    for (i = 0; i <= hay_len - needle_len; i++) {
        for (j = 0; j < needle_len; j++) {
            if (hay[i + j] != needle[j])
                break;
        }
        if (j == needle_len)
            return i;
    }
    return -1;
}

int32_t xlang_string_memmem_c(uint8_t *hay, int32_t hay_len, uint8_t *needle, int32_t needle_len) {
    if (needle_len <= 0)
        return 0;
    if (hay_len < needle_len)
        return -1;
    if (needle_len == 1)
        return xlang_string_memchr_c(hay, needle[0], hay_len);
    return xlang_string_portable_memmem_c(hay, hay_len, needle, needle_len);
}

#endif /* XLANG_RUNTIME_STRING_FAST_FROM_X */
