/* d5_bit_ops.c — D5 位运算/移位差分测试（与 d5_bit_ops.x 同源）
 * 验证：负数右移（算术 vs 逻辑）/ 大数移位 / 位域提取 / 位设置清除 */
#include <stdint.h>

int main(void) {
    uint32_t acc = 0;

    /* 1. 负数右移（GCC/Clang 算术右移）：-1 >> 1 = 0xFFFFFFFF */
    int32_t neg = -1;
    acc ^= (uint32_t)(neg >> 1);

    /* 2. 无符号右移：0x80000000 >> 4 = 0x08000000 */
    acc ^= (0x80000000u >> 4);

    /* 3. 大数左移：1 << 30 = 0x40000000 */
    acc ^= (0x1u << 30);

    /* 4. 取反：~0x0F0F = 0xFFFFF0F0 */
    acc ^= ~0x0F0Fu;

    /* 5. 位与：0xAA55 & 0x0FF0 = 0x0A50 */
    acc ^= (0xAA55u & 0x0FF0u);

    /* 6-9. 位域提取 */
    uint32_t v = 0xDEADBEEF;
    acc ^= (v >> 24) & 0xFFu;   /* 0xDE */
    acc ^= (v >> 16) & 0xFFu;   /* 0xAD */
    acc ^= (v >> 8) & 0xFFu;    /* 0xBE */
    acc ^= v & 0xFFu;           /* 0xEF */

    /* 10-11. 位设置 + 清除 */
    uint32_t x = 0;
    x |= (1u << 7);             /* 设置 bit 7 */
    x &= ~(1u << 7);            /* 清除 bit 7 */
    acc ^= x;                    /* 0 */

    /* 12. 位移组合：(0xFF << 16) | 0xFF = 0x00FF00FF */
    acc ^= ((0xFFu << 16) | 0xFFu);

    return (int)(acc & 0xFFu);
}
