/**
 * shux_std_abi/error_abi.h — std.error 与 codegen 生成 C 的 ABI 头文件（F-ZC Z9）
 *
 * 【职责】error_ok 宏转发；canonical 副本供 LANG-005。
 * 【codegen】runtime.c write_fs_path_map_error_abi_inline 内联写入生成 C。
 */
#ifndef SHUX_STD_ABI_ERROR_ABI_H
#define SHUX_STD_ABI_ERROR_ABI_H

#include <stdint.h>

extern int32_t std_error_error_ok(void);
#define error_ok(_a, _b) std_error_error_ok()

#endif /* SHUX_STD_ABI_ERROR_ABI_H */
