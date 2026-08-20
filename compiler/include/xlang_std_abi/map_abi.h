/**
 * xlang_std_abi/map_abi.h — std.map / std.heap 与 codegen 生成 C 的 ABI 头文件（F-ZC Z9）
 *
 * 【职责】map 查找与 empty_size 宏；canonical 副本供 LANG-005。
 * 【codegen】runtime.c write_fs_path_map_error_abi_inline 内联写入生成 C。
 * map_i32_i32_find_c 实现在 std/heap/ops.x（F-03 v1）。
 */
#ifndef XLANG_STD_ABI_MAP_ABI_H
#define XLANG_STD_ABI_MAP_ABI_H

#include <stdint.h>

/* PLATFORM: SHARED — signature must match std/heap/ops.x codegen (`*i32`/`*u8` →
 * non-const pointers). const qualifiers here redefinition-conflict when the
 * defining TU is co-emitted with this prototype in product -E (host-cc).
 * G.7: single authority = ops.x emit; consumers may still pass const data. */
extern int32_t map_i32_i32_find_c(int32_t *keys, uint8_t *occupied, int32_t cap, int32_t key);
extern int32_t std_map_empty_size(void);
#define empty_size(_a, _b) std_map_empty_size()

#endif /* XLANG_STD_ABI_MAP_ABI_H */
