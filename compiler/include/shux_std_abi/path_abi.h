/**
 * shux_std_abi/path_abi.h — std.path 与 codegen 生成 C 的 ABI 头文件（F-ZC Z9）
 *
 * 【职责】empty_len 宏转发；canonical 副本供 LANG-005。
 * 【codegen】runtime.c write_fs_path_map_error_abi_inline 内联写入生成 C。
 */
#ifndef SHUX_STD_ABI_PATH_ABI_H
#define SHUX_STD_ABI_PATH_ABI_H

#include <stdint.h>

extern int32_t std_path_empty_len(void);
#define empty_len() std_path_empty_len()

#endif /* SHUX_STD_ABI_PATH_ABI_H */
