#include <stddef.h>
#include <stdint.h>
#include <string.h>

uint8_t *shux_string_ptr_at_c(uint8_t *ptr, int32_t off) {
    if (!ptr)
        return 0;
    return ptr + off;
}

int32_t shux_string_memcmp_c(uint8_t *a, uint8_t *b, int32_t n) {
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

int32_t shux_string_memcmp_at_c(uint8_t *a, int32_t off, uint8_t *b, int32_t n) {
    if (n <= 0)
        return 0;
    return memcmp(a + off, b, (size_t)n);
}

void shux_string_copy_c(uint8_t *dst, uint8_t *src, int32_t n) {
    if (n <= 0)
        return;
    memcpy(dst, src, (size_t)n);
}

int32_t shux_string_memchr_c(uint8_t *ptr, uint8_t c, int32_t n) {
    uint8_t *p;
    if (n <= 0)
        return -1;
    p = (uint8_t *)memchr(ptr, (int)c, (size_t)n);
    if (!p)
        return -1;
    return (int32_t)(p - ptr);
}

int32_t shux_string_memrchr_c(uint8_t *ptr, uint8_t c, int32_t n) {
    int32_t i;
    if (n <= 0)
        return -1;
    for (i = n - 1; i >= 0; i--) {
        if (ptr[i] == c)
            return i;
    }
    return -1;
}

static int32_t shux_string_portable_memmem_c(uint8_t *hay, int32_t hay_len, uint8_t *needle, int32_t needle_len) {
    int32_t i;
    int32_t j;
    if (needle_len <= 0)
        return 0;
    if (hay_len < needle_len)
        return -1;
    if (needle_len == 1)
        return shux_string_memchr_c(hay, needle[0], hay_len);
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

int32_t shux_string_memmem_c(uint8_t *hay, int32_t hay_len, uint8_t *needle, int32_t needle_len) {
    if (needle_len <= 0)
        return 0;
    if (hay_len < needle_len)
        return -1;
    if (needle_len == 1)
        return shux_string_memchr_c(hay, needle[0], hay_len);
    return shux_string_portable_memmem_c(hay, hay_len, needle, needle_len);
}
