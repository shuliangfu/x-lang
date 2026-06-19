/**
 * core/builtin/builtin_abi.h — core.builtin 位运算 C ABI 声明
 *
 * 生成 .c 经 codegen 调用 shux_builtin_* 时，链接阶段由 invoke_cc
 * 以 -include 本头注入声明；实现见 core/builtin/builtin.c。
 */
#ifndef SHUX_BUILTIN_ABI_H
#define SHUX_BUILTIN_ABI_H

#include <stdint.h>

int32_t shux_builtin_clz_u32(uint32_t x);
int32_t shux_builtin_ctz_u32(uint32_t x);
int32_t shux_builtin_popcount_u32(uint32_t x);
uint32_t shux_builtin_bswap_u32(uint32_t x);
uint32_t shux_builtin_rotl_u32(uint32_t x, uint32_t count);
uint32_t shux_builtin_rotr_u32(uint32_t x, uint32_t count);

#endif
