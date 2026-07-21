/* seeds/rt_preamble_surface.from_x.c — polished -E of src/runtime/rt_preamble.x
 * R2 full：2 公共符号 write_io_net_abi_inline / write_fs_path_map_error_abi_inline；
 * Cap residual：line_at/count + fputs 在 driver_abi；表数据在 rest seed。
 * 勿手写第二套语义；由 shux -E 产物抛光。
 * Product PREFER_X_O: g05_try_x_to_o(rt_preamble.x) + hybrid rest seed
 *   seeds/rt_preamble.from_x.c (-DSHUX_RT_PREAMBLE_FROM_X) ld -r into runtime_driver_no_c
 * Hybrid rest seed: FROM_X 业务 H=0（表+marker）；冷启动全 C 体
 * wave29: WEAK_IO_BATCH skip i=178..181 (match .x + cold seed); io_net n via line_count pure 224.
 */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
/* PLATFORM: SHARED — include/unistd.h shim provides POSIX wrappers on MinGW
 *            (read/write/close/lseek/open/pread/pwrite/setenv/unsetenv).
 *            include/poll.h and include/sys/uio.h shims also available.
 *            macOS/Linux delegate to system headers via #include_next.
 *            Historical #ifndef _WIN32 guard removed for safe includes. */
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
extern int32_t write_io_net_abi_inline(uint8_t * cf);
extern int32_t write_fs_path_map_error_abi_inline(uint8_t * cf);
extern int32_t codegen_get_preamble_skip_mask(void);
extern uint8_t * driver_preamble_io_net_line_at(int32_t i);
extern int32_t driver_preamble_io_net_line_count(void);
extern uint8_t * driver_preamble_fs_path_line_at(int32_t i);
extern int32_t driver_preamble_fs_path_line_count(void);
extern int32_t driver_preamble_fputs(uint8_t * s, uint8_t * stream);
int32_t write_io_net_abi_inline(uint8_t * cf) {
  int32_t skip = 0;
  int32_t n = 0;
  int32_t i = 0;
  {
    (void)((skip = codegen_get_preamble_skip_mask()));
    (void)((n = driver_preamble_io_net_line_count()));
  }
  while ((i < n)) {
    int32_t skip_line = 0;
    if (((skip & 2) !=0)) {
      if ((i >=60)) {
        if ((i < 64)) {
          (void)((skip_line = 1));
        }
      }
    }
    if (((skip & 1) !=0)) {
      if ((i >=64)) {
        if ((i < 82)) {
          (void)((skip_line = 1));
        }
      }
    }
    if (((skip & 4) !=0)) {
      if ((i >=105)) {
        if ((i < 119)) {
          (void)((skip_line = 1));
        }
      }
    }
    /* wave29: WEAK_IO_BATCH = rows 178..181 (stdio guard + weak batch) */
    if (((skip & 8) !=0)) {
      if ((i >=178)) {
        if ((i <=181)) {
          (void)((skip_line = 1));
        }
      }
    }
    if ((skip_line ==0)) {
      uint8_t * line = ((uint8_t *)(0));
      int32_t rc = 0;
      {
        (void)((line = driver_preamble_io_net_line_at(i)));
        (void)((rc = driver_preamble_fputs(line, cf)));
      }
      if ((rc < 0)) {
        return 1;
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t write_fs_path_map_error_abi_inline(uint8_t * cf) {
  int32_t n = 0;
  int32_t i = 0;
  {
    (void)((n = driver_preamble_fs_path_line_count()));
  }
  while ((i < n)) {
    uint8_t * line = ((uint8_t *)(0));
    int32_t rc = 0;
    {
      (void)((line = driver_preamble_fs_path_line_at(i)));
      (void)((rc = driver_preamble_fputs(line, cf)));
    }
    if ((rc < 0)) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
