/* seeds/rt_arena_buf_surface.from_x.c — polished -E of src/runtime/rt_arena_buf.x
 * R2 full：2 公共符号 driver_arena_buf / driver_module_buf；
 * Cap residual 槽 API 在 driver_abi（driver_arena_static_slot 等）。
 * 勿手写第二套语义；由 shux -E 产物抛光。
 * Product PREFER_X_O: g05_try_x_to_o(rt_arena_buf.x) + hybrid rest seed
 *   seeds/rt_arena_buf.from_x.c (-DSHUX_RT_ARENA_BUF_FROM_X) ld -r into runtime_driver_no_c
 * Hybrid rest seed: FROM_X 业务 H=0（BSS+marker）；冷启动全 C 体
 */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#ifndef _WIN32
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#endif
extern uint8_t * driver_arena_static_slot(void);
extern uint8_t * driver_module_static_slot(void);
extern size_t driver_arena_static_size(void);
extern size_t driver_module_static_size(void);
extern size_t pipeline_arena_offset_num_types(void);
/* libc memset via string.h (prove/g05 strip -E extern uint8_t * memset) */
uint8_t * driver_arena_buf(void) {
  uint8_t * p = ((uint8_t *)(0));
  size_t sz = ((size_t)(0));
  size_t off = ((size_t)(0));
  {
    (void)((p = driver_arena_static_slot()));
    (void)((sz = driver_arena_static_size()));
  }
  if ((p == ((uint8_t *)(0)))) {
    return ((uint8_t *)(0));
  }
  {
    (void)(memset(p, 0, sz));
    (void)((off = pipeline_arena_offset_num_types()));
  }
  if (((off + ((size_t)(4))) <= sz)) {
    (void)(((p)[off] = 0));
    (void)(((p)[(off + ((size_t)(1)))] = 0));
    (void)(((p)[(off + ((size_t)(2)))] = 0));
    (void)(((p)[(off + ((size_t)(3)))] = 0));
  }
  return p;
}
uint8_t * driver_module_buf(void) {
  uint8_t * p = ((uint8_t *)(0));
  size_t sz = ((size_t)(0));
  {
    (void)((p = driver_module_static_slot()));
    (void)((sz = driver_module_static_size()));
  }
  if ((p == ((uint8_t *)(0)))) {
    return ((uint8_t *)(0));
  }
  {
    (void)(memset(p, 0, sz));
  }
  return p;
}
