/* seeds/rt_stack_surface.from_x.c
 * G-02f rt_stack R2 full surface — isomorphic with src/runtime/rt_stack.x
 * Product PREFER_X_O: g05_try_x_to_o(rt_stack.x) + hybrid rest seed
 *   seeds/rt_stack.from_x.c (-DSHUX_RT_STACK_FROM_X) ld -r into runtime_driver_no_c
 * Hybrid rest seed: FROM_X 仅前向 + marker（业务 H=0）
 * Cap-fn-ptr residual: driver_run_stack_esc_gate_on_large_stack in driver_abi
 * Prove: full.x vs this seed → nm IDENTICAL (public surface)
 * Regen: ./shux -E ... src/runtime/rt_stack.x | filter DBG + polish externs
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
struct DriverStackEscGateArgs {
  uint8_t * src;
  int32_t src_len;
  int32_t result;
};

extern uint8_t * driver_stack_esc_gate_thread_fn(uint8_t * arg);
extern int32_t driver_stack_esc_gate_large_stack(uint8_t * src, int32_t src_len);
extern int32_t pipeline_typeck_x_stack_escape_gate_from_src_c(uint8_t * src, int32_t src_len);
extern void driver_run_stack_esc_gate_on_large_stack(uint8_t * arg);
uint8_t * driver_stack_esc_gate_thread_fn(uint8_t * arg) {
  struct DriverStackEscGateArgs * a = ((struct DriverStackEscGateArgs *)(arg));
  if ((a ==((struct DriverStackEscGateArgs *)(0)))) {
    return ((uint8_t *)(0));
  }
  int32_t r = 0;
  {
    (void)((r = pipeline_typeck_x_stack_escape_gate_from_src_c((a->src), (a->src_len))));
  }
  (void)(((a->result) = r));
  return ((uint8_t *)(0));
}
int32_t driver_stack_esc_gate_large_stack(uint8_t * src, int32_t src_len) {
  struct DriverStackEscGateArgs args = (struct DriverStackEscGateArgs){ .src = src, .src_len = src_len, .result = -(99) };
  {
    (void)(driver_run_stack_esc_gate_on_large_stack(((uint8_t *)(&(args)))));
  }
  if (((args.result) ==-(99))) {
    int32_t r2 = 0;
    {
      (void)((r2 = pipeline_typeck_x_stack_escape_gate_from_src_c(src, src_len)));
    }
    return r2;
  }
  return (args.result);
}
