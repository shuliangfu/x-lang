/* m01_no_alloc.c — 纯栈上计算 sum of squares 1..N, N=100000000
 * 与 bench/m01_no_alloc.x / .zig 三语言同算法同 N。
 * 无 malloc / 无 I/O，纯寄存器/栈上整数循环。
 * 防常量折叠：__asm__ volatile 阻止 gcc/clang -O2 把 sum-of-squares
 * 折叠为 N(N+1)(2N+1)/6 单条公式（否则 C 端只测进程启动开销，
 * 与 xlang 端真跑 1e8 次循环不对称）。规范 v1 §4 反作弊防御。 */
#include <stdint.h>

int main(void) {
  int32_t n = 100000000;
  int32_t sum = 0;
  int32_t i = 1;
  while (i <= n) {
    sum = sum + i * i;
    i = i + 1;
    /* B-CMP：阻止 gcc/clang -O2 整循环常量折叠。 */
    __asm__ volatile("" : "+r"(i), "+r"(sum) : : "memory");
  }
  return (int)(sum & 0xFFFF);
}
