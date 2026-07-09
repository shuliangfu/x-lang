/* call_boundary.c — 与 tests/bench/call_boundary.x 对齐
 * 反作弊：__asm__ volatile 阻止 gcc/clang -O2 把可求和等差数列循环
 * 常量折叠为单条 mov $const,%eax;ret（否则 C 端 5ms 只是进程启动开销，
 * 与 SHUX 端真跑 2 亿次循环不对称）。规范 v1 §4 反作弊防御。 */
#include <stdint.h>

static int32_t f0(int32_t x) { return x + 1; }
static int32_t f1(int32_t x) { return f0(x) + 1; }
static int32_t f2(int32_t x) { return f1(x) + 1; }
static int32_t f3(int32_t x) { return f2(x) + 1; }
static int32_t f4(int32_t x) { return f3(x) + 1; }

int main(void) {
  int32_t n = 200000000;
  int32_t s = 0;
  int32_t i = 0;
  while (i < n) {
    s = s + f4(i);
    i = i + 1;
    __asm__ volatile("" : "+r"(i), "+r"(s) : : "memory");
  }
  return (int)s;
}
