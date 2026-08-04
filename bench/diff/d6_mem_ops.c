/* d6_mem_ops.c — D6 内存操作差分测试（与 d6_mem_ops.x 同源）
 * 同源手写内存操作（不依赖 libc），验证数组下标访问 / 循环填充 / 拷贝正确性 */
#include <stdint.h>

int main(void) {
    uint32_t acc = 0;

    /* memset 手写：填充 16 字节 */
    uint8_t buf[16] = {0};
    for (int i = 0; i < 16; i++) buf[i] = 0xAB;
    for (int i = 0; i < 16; i++) acc ^= buf[i];

    /* memcpy 手写：拷贝 8 字节 */
    uint8_t src[8] = {1, 2, 3, 4, 5, 6, 7, 8};
    uint8_t dst[8] = {0};
    for (int i = 0; i < 8; i++) dst[i] = src[i];
    for (int i = 0; i < 8; i++) acc ^= dst[i];

    /* 边界：空循环不访问 */
    uint8_t z[4] = {0};
    for (int i = 0; i < 0; i++) z[i] = 0xFF;
    for (int i = 0; i < 4; i++) acc ^= z[i];

    return (int)(acc & 0xFFu);
}
