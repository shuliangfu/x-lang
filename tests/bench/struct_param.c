/* struct_param.c — 与 tests/bench/struct_param.x 对齐
 * 反作弊：__asm__ volatile 阻止 gcc/clang -O2 把可求和等差数列循环
 * 常量折叠为单条 mov $const,%eax;ret（"每轮更新 p"不足以防折叠，因为
 * 整个循环仍是可求和公式）。规范 v1 §4 反作弊防御。 */
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
  Pair p = {0, 0};
  while (i < n) {
    p.a = i;
    p.b = i + 1;
    s = s + add_pair(p);
    i = i + 1;
    __asm__ volatile("" : "+r"(i), "+r"(s), "+r"(p.a), "+r"(p.b) : : "memory");
  }
  return (int)s;
}
