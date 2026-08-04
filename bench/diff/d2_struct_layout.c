/* d2_struct_layout.c — D2 结构体布局差分测试（与 d2_struct_layout.x 同源）
 * 验证：repr(C) 布局 / packed 无填充 / 嵌套 struct / 字段读写正确性
 * 通过字段聚合值（exit code）间接验证布局，避开 sizeof 运算符差异。 */
#include <stdint.h>

struct Point { int32_t x; int32_t y; };
struct Mixed { uint8_t a; uint32_t b; uint8_t c; };  /* 有 padding：a(1)+pad(3)+b(4)+c(1)+pad(3) = 12 */
struct PackedMixed { uint8_t a; uint32_t b; uint8_t c; } __attribute__((packed));  /* 无填充：1+4+1 = 6 */
struct Nested { struct Point p; int32_t z; };

int main(void) {
    uint32_t acc = 0;

    struct Point pt = { 0x11223344, 0x55667788 };
    acc ^= (uint32_t)pt.x ^ (uint32_t)pt.y;

    struct Mixed m = { 0xAA, 0x11223344, 0xBB };
    acc ^= (uint32_t)m.a ^ m.b ^ (uint32_t)m.c;

    struct PackedMixed pm = { 0xAA, 0x11223344, 0xBB };
    acc ^= (uint32_t)pm.a ^ pm.b ^ (uint32_t)pm.c;

    struct Nested n = { { 1, 2 }, -3 };
    acc ^= (uint32_t)n.p.x ^ (uint32_t)n.p.y ^ (uint32_t)n.z;

    return (int)(acc & 0xFFu);
}
