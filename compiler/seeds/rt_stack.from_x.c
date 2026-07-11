/* seeds/rt_stack.from_x.c — G-02f-317 P2 runtime R8-lite (stack esc pthread gate)
 * Logic source: src/runtime/rt_stack.x
 * Hybrid: SHUX_RT_STACK_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * Scope: driver_stack_esc_gate_thread_fn / driver_stack_esc_gate_large_stack
 * 🔒 driver_run_thread_on_large_stack（pthread 在 driver_abi）。
 * smoke lex dump 仍 !X_DRIVER 在 mega（需 C lexer 头）。
 */
#include <stddef.h>
#include <stdint.h>

/** shux check 后 X 栈逃逸 gate 大栈线程参数。 */
typedef struct {
  uint8_t *src;
  int32_t src_len;
  int32_t result;
} DriverStackEscGateArgs;

extern int32_t pipeline_typeck_x_stack_escape_gate_from_src_c(uint8_t *src, int32_t src_len);
extern void driver_run_thread_on_large_stack(void *(*fn)(void *), void *arg);

/* G-02f-449：thin+rest PREFER_X_O
 *   thin .x provides 1 #[no_mangle] wrapper (calls *_impl in rest).
 *   rest seed C (compiled with -DSHUX_RT_STACK_FROM_X):
 *     - driver_stack_esc_gate_large_stack renamed to *_impl via macro.
 *   driver_stack_esc_gate_thread_fn stays in rest (internal helper, no .x counterpart).
 *   No #ifndef guard needed (no real .x implementation; .x is thin-only). */
#ifdef SHUX_RT_STACK_FROM_X
#define driver_stack_esc_gate_large_stack    driver_stack_esc_gate_large_stack_impl
#endif

/** pthread 入口：WPO-S3 post-scan gate。 */
void *driver_stack_esc_gate_thread_fn(void *arg) {
  DriverStackEscGateArgs *a = (DriverStackEscGateArgs *)arg;
  a->result = pipeline_typeck_x_stack_escape_gate_from_src_c(a->src, a->src_len);
  return NULL;
}

/**
 * 在 256MiB 栈 pthread 上跑 X struct 栈逃逸 gate（check 路径；勿在主线程 parse）。
 */
int32_t driver_stack_esc_gate_large_stack(uint8_t *src, int32_t src_len) {
  DriverStackEscGateArgs args;
  args.src = src;
  args.src_len = src_len;
  args.result = -99;
  driver_run_thread_on_large_stack(driver_stack_esc_gate_thread_fn, &args);
  if (args.result == -99)
    return pipeline_typeck_x_stack_escape_gate_from_src_c(src, src_len);
  return args.result;
}

int labi_rt_stack_slice_marker(void) {
  return 1;
}
