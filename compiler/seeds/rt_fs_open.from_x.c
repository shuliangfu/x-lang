/* seeds/rt_fs_open.from_x.c — G-02f-308 P2 runtime rest (path open)
 * w1135: pure asm is rt_fs_open.x plus rt_fs_open_call.x. The copy loop
 * and the 512-byte open buffer are separate translation units.
 * Logic source: src/runtime/rt_fs_open.x
 * Hybrid: XLANG_RT_FS_OPEN_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * R2 full（2026-07-14）：driver_fs_open_read_path / driver_fs_open_write
 * 均由 .x 提供；FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体。
 * 🔒 open / fcntl 经 libc。
 */
#include <fcntl.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

#ifndef XLANG_RT_FS_OPEN_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_RT_FS_OPEN_FROM_X removed */
#ifdef O_WRONLY
#ifdef O_CREAT
#ifdef O_TRUNC
#endif
#endif
#endif
#else
int driver_fs_open_read_path(const uint8_t *path, int path_len);
int driver_fs_open_write(const uint8_t *path, int path_len);
#endif

int labi_rt_fs_open_slice_marker(void) {
  return 1;
}
