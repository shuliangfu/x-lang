/* d3_call_conv.c — D3 函数调用约定差分测试（与 d3_call_conv.x 同源）
 * 验证：多参数传递（>6 寄存器参数溢出栈）/ struct 返回值 / 递归调用 */
#include <stdint.h>

struct Pair { int32_t a; int32_t b; };

struct Pair make_pair(int32_t a, int32_t b, int32_t c, int32_t d) {
    struct Pair p;
    p.a = a + c;
    p.b = b + d;
    return p;
}

int32_t sum6(int32_t a, int32_t b, int32_t c, int32_t d, int32_t e, int32_t f) {
    return a + b + c + d + e + f;
}

int32_t fib(int32_t n) {
    if (n < 2) return n;
    return fib(n - 1) + fib(n - 2);
}

int main(void) {
    uint32_t acc = 0;

    struct Pair p = make_pair(1, 2, 3, 4);
    acc ^= (uint32_t)(p.a ^ p.b);

    acc ^= (uint32_t)sum6(10, 20, 30, 40, 50, 60);

    acc ^= (uint32_t)fib(15);

    return (int)(acc & 0xFFu);
}
