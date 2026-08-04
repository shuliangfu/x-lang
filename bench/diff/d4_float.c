/* d4_float.c — D4 浮点运算差分测试（P2，占位）
 * 验证：IEEE 754 基本运算 / 浮点比较
 * 时机：P2，ASM 后端浮点支持完善后激活 */
#include <stdint.h>

int main(void) {
    double x = 1.5;
    double y = 2.5;
    double z = x * y;  /* 3.75 */
    if (z > 3.0) return 1;
    return 0;
}
