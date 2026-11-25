/* seeds/rt_util.from_x.c — G-02f-262 P2 R0 util 切片
 * Logic source: src/runtime/rt_util.x
 * Hybrid: XLANG_RT_UTIL_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * R2（2026-07-14）：driver_unlink_failed_output + driver_argv0_basename_is
 * 均由 .x 提供；FROM_X 下本文件仅前向声明（产品 rest 业务符号 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体。
 */
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <unistd.h>

#ifndef XLANG_RT_UTIL_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_RT_UTIL_FROM_X removed */
#if defined(_WIN32)
#endif
#else
void driver_unlink_failed_output(const char *out_path);
int driver_argv0_basename_is(const char *argv0, const char *base);
#endif
