/* a02_indirect_call.c — 间接调用/函数指针密集，N=100000000 次
 * 与 bench/a02_indirect_call.x / .zig 三语言同算法。
 * 4 个函数 op_add/op_sub/op_mul/op_xor 放入函数指针表，
 * 循环 N 次按 i&3 选择函数，累加结果。
 * 防常量折叠：__asm__ volatile + 返回累加值。 */
#include <stdint.h>

static int32_t op_add(int32_t a, int32_t b) { return a + b; }
static int32_t op_sub(int32_t a, int32_t b) { return a - b; }
static int32_t op_mul(int32_t a, int32_t b) { return a * b; }
static int32_t op_xor(int32_t a, int32_t b) { return a ^ b; }

int main(void) {
  int32_t (*ops[4])(int32_t, int32_t) = { op_add, op_sub, op_mul, op_xor };
  int32_t n = 100000000;
  int32_t acc = 0;
  int32_t i = 0;
  while (i < n) {
    acc = ops[i & 3](acc, i);
    i = i + 1;
    /* B-CMP：阻止 gcc/clang -O2 把间接调用去虚拟化为直调或常量折叠。 */
    __asm__ volatile("" : "+r"(i), "+r"(acc) : : "memory");
  }
  return (int)(acc & 0xFFFF);
}
