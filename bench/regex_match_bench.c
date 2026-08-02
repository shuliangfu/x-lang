/* regex_match_bench.c — STD-062：纯引擎 match 热循环 bench（链接 regex.o） */
#include <stdint.h>
#include <stdio.h>
#include <string.h>

extern void *regex_compile_c(const uint8_t *pat, int32_t pat_len);
extern int32_t regex_match_c(void *re, const uint8_t *str, int32_t len);
extern void regex_free_c(void *re);

int main(void) {
  enum { loops = 500000 };
  int32_t acc = 0;
  int i;
  /* 字面量：needle 在 256B haystack 末尾 */
  uint8_t pat_lit[] = { 'n', 'e', 'e', 'd', 'l', 'e' };
  uint8_t hay_lit[256];
  memset(hay_lit, (uint8_t)'x', sizeof(hay_lit));
  memcpy(hay_lit + 249, "needle", 6);
  void *re_lit = regex_compile_c(pat_lit, 6);
  if (!re_lit) return 1;
  for (i = 0; i < loops; i++) {
    acc += regex_match_c(re_lit, hay_lit, 256);
  }
  regex_free_c(re_lit);

  /* 星号：a*b 在 64×a + b */
  uint8_t pat_star[] = { 'a', '*', 'b' };
  uint8_t hay_star[65];
  memset(hay_star, (uint8_t)'a', 64);
  hay_star[64] = 'b';
  void *re_star = regex_compile_c(pat_star, 3);
  if (!re_star) return 2;
  for (i = 0; i < loops; i++) {
    acc += regex_match_c(re_star, hay_star, 65);
  }
  regex_free_c(re_star);

  printf("%d\n", (int)acc);
  return 0;
}
