/**
 * core/builtin/builtin.c — CORE-009 位运算热路径（clz/ctz/popcount）
 *
 * 供 core.builtin 模块 extern 调用；内部使用编译器 __builtin_* 单指令/库调用。
 * x==0 时 clz/ctz 返回 32（与 core/builtin/mod.su 语义一致）。
 */
#include <stdint.h>

/** 前导零个数；x==0 返回 32。 */
int32_t shulang_builtin_clz_u32(uint32_t x) {
    if (x == 0u) {
        return 32;
    }
    return (int32_t)__builtin_clz(x);
}

/** 尾随零个数；x==0 返回 32。 */
int32_t shulang_builtin_ctz_u32(uint32_t x) {
    if (x == 0u) {
        return 32;
    }
    return (int32_t)__builtin_ctz(x);
}

/** 二进制中 1 的个数。 */
int32_t shulang_builtin_popcount_u32(uint32_t x) {
    return (int32_t)__builtin_popcount(x);
}

/** 32 位字节序交换（CORE-018）。 */
uint32_t shulang_builtin_bswap_u32(uint32_t x) {
    return ((x & 0x000000FFu) << 24) | ((x & 0x0000FF00u) << 8)
         | ((x & 0x00FF0000u) >> 8) | ((x & 0xFF000000u) >> 24);
}

/** 32 位循环左移；count 取模 32（CORE-018）。 */
uint32_t shulang_builtin_rotl_u32(uint32_t x, uint32_t count) {
    count &= 31u;
    if (count == 0u) return x;
    return (x << count) | (x >> (32u - count));
}

/** 32 位循环右移；count 取模 32（CORE-018）。 */
uint32_t shulang_builtin_rotr_u32(uint32_t x, uint32_t count) {
    count &= 31u;
    if (count == 0u) return x;
    return (x >> count) | (x << (32u - count));
}
