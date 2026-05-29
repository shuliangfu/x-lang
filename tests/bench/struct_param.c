/* struct_param.c — 与 tests/bench/struct_param.su 对齐 */
#include <stdint.h>

typedef struct {
  int32_t a;
  int32_t b;
} Pair;

static int32_t add_pair(Pair p) {
  return p.a + p.b;
}

int main(void) {
  int32_t n = 100000000;
  int32_t s = 0;
  int32_t i = 0;
  Pair p = {1, 2};
  while (i < n) {
    s = s + add_pair(p);
    i = i + 1;
  }
  return (int)s;
}
