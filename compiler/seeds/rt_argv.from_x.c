/* seeds/rt_argv.from_x.c — G-02f-263 P2 R1 argv 令牌比较切片
 * Logic source: src/runtime/rt_argv.x
 * Hybrid: XLANG_RT_ARGV_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * R2（2026-07-14）：15 公共符号（drv_eq_* / path_ends_x / target_has_arm）
 * 均由 .x 提供；FROM_X 下本文件仅前向声明 + marker（产品 rest 业务 T=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体。
 */
#include <stdint.h>
#include <stddef.h>
#include <string.h>

#ifndef XLANG_RT_ARGV_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_RT_ARGV_FROM_X removed */
#else
int drv_eq_minus_o(const char *buf, int len);
int drv_eq_minus_L(const char *buf, int len);
int drv_eq_minus_O(const char *buf, int len);
int drv_eq_flto(const char *buf, int len);
int drv_eq_minus_freestanding(const char *buf, int len);
int drv_eq_legacy_f32_abi(const char *buf, int len);
int drv_eq_fsanitize_address(const char *buf, int len);
int drv_eq_minus_backend(const char *buf, int len);
int drv_eq_minus_target(const char *buf, int len);
int drv_eq_minus_target_cpu(const char *buf, int len);
int drv_eq_print_target_cpu(const char *buf, int len);
int drv_eq_asm_word(const char *buf, int len);
int drv_eq_c_word(const char *buf, int len);
int drv_path_ends_x(const char *buf, int len);
int drv_target_has_arm(const char *buf, int len);

int labi_rt_argv_slice_marker(void) {
  return 1;
}
#endif /* !XLANG_RT_ARGV_FROM_X */
