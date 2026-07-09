/* d1_int_arith.c — D1 整数运算边界差分测试（与 d1_int_arith.x 同源）
 * 验证：u32 溢出回绕 / 有符号除法向零截断 / 取模符号 / 移位 / 位运算
 * C 侧用 unsigned/int（well-defined 行为），避开有符号溢出 UB。 */
#include <stdint.h>

int main(void) {
    uint32_t acc = 0;

    /* 1. u32 溢出回绕：0xFFFFFFFF + 1 = 0 */
    acc ^= (0xFFFFFFFFu + 1u);

    /* 2. 负数转 u32：-1 → 0xFFFFFFFF */
    acc ^= (uint32_t)(-1);

    /* 3. 有符号除法向零截断：-7 / 2 = -3 */
    acc ^= (uint32_t)(-7 / 2);

    /* 4. 有符号取模符号跟随被除数：-7 % 2 = -1 */
    acc ^= (uint32_t)(-7 % 2);

    /* 5. 无符号除法：0xFFFFFFFF / 2 = 0x7FFFFFFF */
    acc ^= (0xFFFFFFFFu / 2u);

    /* 6. u32 左移：1 << 31 = 0x80000000 */
    acc ^= (1u << 31);

    /* 7. u32 逻辑右移：0x80000000 >> 1 = 0x40000000 */
    acc ^= (0x80000000u >> 1);

    /* 8. 位与：0xF0F0 & 0x0FF0 = 0x0F0 */
    acc ^= (0xF0F0u & 0x0FF0u);

    /* 9. 位或：0xF0F0 | 0x0FF0 = 0xFFF0 */
    acc ^= (0xF0F0u | 0x0FF0u);

    /* 10. 位异或：0xFF00 ^ 0x0FF0 = 0xF0F0 */
    acc ^= (0xFF00u ^ 0x0FF0u);

    /* 11. i64 低 32 位：(1<<40) 低 32 位 = 0 */
    int64_t big = (int64_t)1 << 40;
    acc ^= (uint32_t)big;

    /* 12. i64 乘法低 32 位：(1<<40)*3 低 32 位 = 0 */
    acc ^= (uint32_t)(big * (int64_t)3);

    return (int)(acc & 0xFFu);
}
