/* seeds/rt_lib_root.from_x.c — G-02f-305 P2 runtime rest (lib root helpers)
 * w1134: src/runtime/rt_lib_root.x pure-asms. One while copies the default root.
 * from_key is recursive. This seed stays the cold fallback and the marker rest.
 * Logic source: src/runtime/rt_lib_root.x
 * Hybrid: XLANG_RT_LIB_ROOT_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * R2（2026-07-14）：ptr_usable + default + roots_from_key 均由 .x 提供；
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务符号 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体。
 */
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#ifndef X_FULL_MAX_LIB_ROOTS
#define X_FULL_MAX_LIB_ROOTS 16
#endif

extern int32_t driver_emit_lib_root_count(uint8_t *state);
extern int32_t driver_emit_lib_root_len(uint8_t *state, int32_t i);
extern void driver_emit_lib_root_copy(uint8_t *state, int32_t i, uint8_t *dst, int32_t cap);
/* wave227 G.7: env via public pure thin link_abi_getenv (wave222 → _impl host getenv). */
extern char *link_abi_getenv(const char *name);

#ifndef XLANG_RT_LIB_ROOT_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_RT_LIB_ROOT_FROM_X removed */
#else
int driver_lib_root_ptr_usable(const char *p);
void driver_lib_root_default(char root_buf[512]);
int driver_lib_roots_from_key(uint8_t *lib_key, const char **out_arr, char bufs[X_FULL_MAX_LIB_ROOTS][512]);
#endif

int labi_rt_lib_root_slice_marker(void) {
  return 1;
}
