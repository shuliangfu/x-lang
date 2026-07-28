/* seeds/runtime_string_fast_surface.from_x.c
 * G-02f-151 runtime_string_fast R2 DIRECT surface — isomorphic with src/asm/runtime_string_fast.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o (no rest; seed fully guarded)
 * Prove: full.x vs this surface → nm IDENTICAL (8 #[no_mangle] + 1 doc_anchor)
 * Mode: DIRECT — .x provides all 8 xlang_string_*_c functions (pure computation + libc bridges);
 *   seed has #ifndef XLANG_RUNTIME_STRING_FAST_FROM_X guard (8 skipped when PREFER_X_O)
 * Cap residual: none (DIRECT mode, libc memcmp/memcpy declared as extern in .x)
 * Note: doc_anchor ast_runtime_string_fast_x_doc_anchor (non-no_mangle, xlang-c auto-prepends
 *   ast_ prefix; same pattern as runtime_path_fast/net_sock_fast/net_addr_fast).
 * Logic: 8 functions = memrchr + memchr + portable_memmem + memmem + ptr_at + memcmp + memcmp_at + copy.
 *   Pure helpers + libc memcmp/memcpy bridges.
 * Regen: ./xlang-c -E ... runtime_string_fast.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

extern int memcmp(const void *a, const void *b, size_t n);
extern void *memcpy(void *dst, const void *src, size_t n);

int32_t ast_runtime_string_fast_x_doc_anchor(void) {
  return 0;
}

int32_t xlang_string_memrchr_c(uint8_t *ptr, uint8_t c, int32_t n) {
  int32_t i;
  if (ptr == 0) { return 0 - 1; }
  if (n <= 0) { return 0 - 1; }
  i = n - 1;
  while (i >= 0) {
    if (ptr[i] == c) { return i; }
    i = i - 1;
  }
  return 0 - 1;
}

int32_t xlang_string_memchr_c(uint8_t *ptr, uint8_t c, int32_t n) {
  int32_t i;
  if (ptr == 0) { return 0 - 1; }
  if (n <= 0) { return 0 - 1; }
  i = 0;
  while (i < n) {
    if (ptr[i] == c) { return i; }
    i = i + 1;
  }
  return 0 - 1;
}

int32_t xlang_string_portable_memmem_c(uint8_t *hay, int32_t hay_len, uint8_t *needle, int32_t needle_len) {
  int32_t i;
  int32_t lim;
  if (needle == 0) { return 0 - 1; }
  if (needle_len <= 0) { return 0; }
  if (hay == 0) { return 0 - 1; }
  if (hay_len < needle_len) { return 0 - 1; }
  if (needle_len == 1) {
    return xlang_string_memchr_c(hay, needle[0], hay_len);
  }
  i = 0;
  lim = hay_len - needle_len;
  while (i <= lim) {
    int32_t j = 0;
    while (j < needle_len) {
      if (hay[i + j] != needle[j]) { break; }
      j = j + 1;
    }
    if (j == needle_len) { return i; }
    i = i + 1;
  }
  return 0 - 1;
}

int32_t xlang_string_memmem_c(uint8_t *hay, int32_t hay_len, uint8_t *needle, int32_t needle_len) {
  if (needle_len <= 0) { return 0; }
  if (hay_len < needle_len) { return 0 - 1; }
  if (needle_len == 1) {
    if (needle == 0) { return 0 - 1; }
    return xlang_string_memchr_c(hay, needle[0], hay_len);
  }
  return xlang_string_portable_memmem_c(hay, hay_len, needle, needle_len);
}

uint8_t *xlang_string_ptr_at_c(uint8_t *ptr, int32_t off) {
  if (ptr == 0) { return 0; }
  return ptr + off;
}

int32_t xlang_string_memcmp_c(uint8_t *a, uint8_t *b, int32_t n) {
  int32_t r;
  if (n <= 0) { return 0; }
  r = (int32_t)memcmp(a, b, (size_t)n);
  if (r < 0) { return 0 - 1; }
  if (r > 0) { return 1; }
  return 0;
}

int32_t xlang_string_memcmp_at_c(uint8_t *a, int32_t off, uint8_t *b, int32_t n) {
  if (n <= 0) { return 0; }
  return (int32_t)memcmp(a + off, b, (size_t)n);
}

void xlang_string_copy_c(uint8_t *dst, uint8_t *src, int32_t n) {
  if (n <= 0) { return; }
  memcpy(dst, src, (size_t)n);
}
