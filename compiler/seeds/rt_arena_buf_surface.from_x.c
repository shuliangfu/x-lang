/* seeds/rt_arena_buf_surface.from_x.c
 * G-02f rt_arena_buf L2 thin surface — isomorphic with src/runtime/rt_arena_buf.x
 * Product PREFER_X_O: g05_try_x_to_o(rt_arena_buf.x) + hybrid rest seed
 *   seeds/rt_arena_buf.from_x.c (-DSHUX_RT_ARENA_BUF_FROM_X) ld -r into runtime_driver_no_c
 * Hybrid rest seed unchanged: static BSS body (macro→_impl) + marker
 * Prove: thin.x vs this seed → nm IDENTICAL (public surface; _impl is U)
 * Regen: ./shux -E ... src/runtime/rt_arena_buf.x | filter DBG + polish externs
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
extern uint8_t * driver_arena_buf_impl(void);
uint8_t * driver_arena_buf(void) {
  {
    return driver_arena_buf_impl();
  }
  return ((uint8_t *)(0));
}
extern uint8_t * driver_module_buf_impl(void);
uint8_t * driver_module_buf(void) {
  {
    return driver_module_buf_impl();
  }
  return ((uint8_t *)(0));
}
