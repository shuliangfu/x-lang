/* seeds/rt_stack_surface.from_x.c
 * G-02f rt_stack L2 thin surface — isomorphic with src/runtime/rt_stack.x
 * Product PREFER_X_O: g05_try_x_to_o(rt_stack.x) + hybrid rest seed
 *   seeds/rt_stack.from_x.c (-DSHUX_RT_STACK_FROM_X) ld -r into runtime_driver_no_c
 * Hybrid rest seed unchanged: pthread gate body (macro→_impl) + marker + thread_fn
 * Prove: thin.x vs this seed → nm IDENTICAL (public surface; _impl is U)
 * Regen: ./shux -E ... src/runtime/rt_stack.x | filter DBG + polish externs
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
extern int32_t driver_stack_esc_gate_large_stack_impl(uint8_t * src, int32_t src_len);
int32_t driver_stack_esc_gate_large_stack(uint8_t * src, int32_t src_len) {
  {
    return driver_stack_esc_gate_large_stack_impl(src, src_len);
  }
  return 0;
}
