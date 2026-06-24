/**
 * shux_std_abi/map_abi.h — std.map / std.heap 与 codegen 生成 C 的 ABI 头文件（F-ZC Z9）
 *
 * 【职责】map 查找与 map_empty_size 宏；canonical 副本供 LANG-005。
 * 【codegen】runtime.c write_fs_path_map_error_abi_inline 内联写入生成 C。
 * map_i32_i32_find_c 实现在 std/heap/heap_ops.sx（F-03 v1）。
 */
#ifndef SHUX_STD_ABI_MAP_ABI_H
#define SHUX_STD_ABI_MAP_ABI_H

#include <stdint.h>

extern int32_t map_i32_i32_find_c(const int32_t *keys, const uint8_t *occupied, int32_t cap, int32_t key);
extern int32_t std_map_map_empty_size(void);
#define map_empty_size(_a, _b) std_map_map_empty_size()

#endif /* SHUX_STD_ABI_MAP_ABI_H */
