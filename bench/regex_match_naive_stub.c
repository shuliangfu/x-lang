/* regex_match_naive_stub.c — STD-062 桩基线：无快路径的通用回溯（每位置全扫描） */
#include <stdint.h>
#include <stdio.h>
#include <string.h>

/** 消费一个 atom（与 regex.x 同语义，无优化） */
static int stub_consume_atom(const char **pat, const char *pat_end) {
  const char *p = *pat;
  if (p >= pat_end) return 0;
  if (*p == '\\') {
    if (p + 1 >= pat_end) return 0;
    *pat = p + 2;
    return 1;
  }
  if (*p == '*' || *p == '?') return 0;
  *pat = p + 1;
  return 1;
}

/** 匹配 atom 一字节 */
static int stub_match_atom_char(const char *atom_start, const char *atom_end,
                                const char **str, const char *str_end) {
  if (*str >= str_end || atom_start >= atom_end) return 0;
  char ch = **str;
  if (*atom_start == '\\') {
    if (atom_start + 1 >= atom_end) return 0;
    if (ch != atom_start[1]) return 0;
  } else if (ch != *atom_start) {
    return 0;
  }
  (*str)++;
  return 1;
}

/** 通用回溯（无首字节跳跃） */
static int stub_match_here(const char **pat, const char *pat_end,
                           const char **str, const char *str_end) {
  while (*pat < pat_end) {
    const char *atom_start = *pat;
    if (!stub_consume_atom(pat, pat_end)) return 0;
    const char *atom_end = *pat;
    if (*pat < pat_end && **pat == '*') {
      (*pat)++;
      for (;;) {
        if (stub_match_here(pat, pat_end, str, str_end)) return 1;
        const char *s2 = *str;
        if (!stub_match_atom_char(atom_start, atom_end, &s2, str_end)) break;
        *str = s2;
      }
      return 0;
    }
    if (!stub_match_atom_char(atom_start, atom_end, str, str_end)) return 0;
  }
  return 1;
}

/** 桩搜索：每偏移都走通用回溯（无 literal_only / first_lit） */
static int32_t stub_search_slow(const char *pat, int pat_len,
                                const uint8_t *str, int32_t len) {
  int32_t i;
  const char *pat_end = pat + pat_len;
  for (i = 0; i <= len; i++) {
    const char *s = (const char *)str + i;
    const char *s_end = (const char *)str + len;
    const char *p = pat;
    if (stub_match_here(&p, pat_end, &s, s_end)) return 0;
  }
  return -1;
}

int main(void) {
  enum { loops = 500000 };
  int32_t acc = 0;
  int i;
  const char pat_lit[] = "needle";
  uint8_t hay_lit[256];
  memset(hay_lit, (uint8_t)'x', sizeof(hay_lit));
  memcpy(hay_lit + 249, "needle", 6);
  for (i = 0; i < loops; i++) {
    acc += stub_search_slow(pat_lit, 6, hay_lit, 256);
  }

  const char pat_star[] = "a*b";
  uint8_t hay_star[65];
  memset(hay_star, (uint8_t)'a', 64);
  hay_star[64] = 'b';
  for (i = 0; i < loops; i++) {
    acc += stub_search_slow(pat_star, 3, hay_star, 65);
  }

  printf("%d\n", (int)acc);
  return 0;
}
