/* seeds/runtime_scheduler_glue_surface.from_x.c
 * G-02f-21 runtime_scheduler_glue R2 mixed (thin+rest + DIRECT) surface - isomorphic with src/asm/runtime_scheduler_glue.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/runtime_scheduler_glue.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (17 #[no_mangle] + 1 doc_anchor)
 * Mode: mixed - 10 thin+rest forwards (xlang_async_ star / coop_frame_step_ star) + 7 DIRECT env gate
 *   (xlang_async_q_occupancy pure compute + 6 env gate using link_abi_getenv)
 * Cap residual: 10 _impl - async_runtime_trace_enabled/trace_now_us/bound_ctx_cancelled/
 *   take_suspend_io_flag/coop_frame_step_jmp/coop_frame_step_switch/init_workers/io_wait_push/
 *   maybe_bind_worker/drain_queue/spawn_ctx_echo_task (11) + link_abi_getenv (env bridge)
 * Note: env_parse_u32_default is export function WITHOUT #[no_mangle]; called by env gate functions;
 *   surface defines it as runtime_scheduler_glue_env_parse_u32_default to match .x export symbol.
 * doc_anchor runtime_scheduler_glue_x_doc_anchor (no ast_; xlang_ prefix not trigger).
 * Logic: 17 functions = 10 thin+rest + xlang_async_q_occupancy (pure compute) + 6 env gate DIRECT.
 * Regen: ./xlang-c -E ... runtime_scheduler_glue.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

extern int32_t xlang_async_runtime_trace_enabled_impl(void);
extern uint64_t xlang_async_trace_now_us_impl(void);
extern uint8_t *link_abi_getenv(uint8_t *name);
extern int32_t xlang_async_bound_ctx_cancelled_impl(void);
extern int32_t xlang_async_take_suspend_io_flag_impl(void);
extern int32_t xlang_coop_frame_step_jmp_impl(uint8_t *frame);
extern int32_t xlang_coop_frame_step_switch_impl(uint8_t *frame);
extern void xlang_async_init_workers_impl(void);
extern int32_t xlang_async_io_wait_push_impl(uint8_t *fn);
extern void xlang_async_maybe_bind_worker_impl(uint32_t wid);
extern int32_t xlang_async_drain_queue_impl(uint8_t *q, uint32_t wid, int32_t *acc);
extern int32_t xlang_async_spawn_ctx_echo_task_impl(void);

int32_t runtime_scheduler_glue_x_doc_anchor(void) {
  return 0;
}

uint64_t xlang_async_trace_now_us(void) {
  return xlang_async_trace_now_us_impl();
}

int32_t xlang_async_bound_ctx_cancelled(void) {
  return xlang_async_bound_ctx_cancelled_impl();
}

int32_t xlang_async_take_suspend_io_flag(void) {
  return xlang_async_take_suspend_io_flag_impl();
}

int32_t xlang_coop_frame_step_jmp(uint8_t *frame) {
  return xlang_coop_frame_step_jmp_impl(frame);
}

int32_t xlang_coop_frame_step_switch(uint8_t *frame) {
  return xlang_coop_frame_step_switch_impl(frame);
}

void xlang_async_init_workers(void) {
  xlang_async_init_workers_impl();
}

int32_t xlang_async_io_wait_push(uint8_t *fn) {
  return xlang_async_io_wait_push_impl(fn);
}

void xlang_async_maybe_bind_worker(uint32_t wid) {
  xlang_async_maybe_bind_worker_impl(wid);
}

int32_t xlang_async_drain_queue(uint8_t *q, uint32_t wid, int32_t *acc) {
  return xlang_async_drain_queue_impl(q, wid, acc);
}

int32_t xlang_async_spawn_ctx_echo_task(void) {
  return xlang_async_spawn_ctx_echo_task_impl();
}

uint32_t xlang_async_q_occupancy(uint32_t head, uint32_t tail) {
  return tail - head;
}

int32_t xlang_async_runtime_trace_enabled(void) {
  uint8_t *e = link_abi_getenv((uint8_t *)"XLANG_ASYNC_RUNTIME_TRACE");
  if (e == 0) { return 0; }
  if (e[0] == 0) { return 0; }
  if (e[0] == 48) {
    if (e[1] == 0) { return 0; }
  }
  return 1;
}

int32_t xlang_async_io_wait_enabled(void) {
  uint8_t *e = link_abi_getenv((uint8_t *)"XLANG_ASYNC_IO_WAIT");
  if (e == 0) { return 0; }
  if (e[0] == 49) {
    if (e[1] == 0) { return 1; }
  }
  return 0;
}

int32_t xlang_async_affinity_enabled(void) {
  uint8_t *e = link_abi_getenv((uint8_t *)"XLANG_ASYNC_AFFINITY");
  if (e == 0) { return 0; }
  if (e[0] == 49) {
    if (e[1] == 0) { return 1; }
  }
  return 0;
}

uint32_t runtime_scheduler_glue_env_parse_u32_default(uint8_t *e, uint32_t defv) {
  if (e == 0) { return defv; }
  if (e[0] == 0) { return defv; }
  uint32_t v = 0;
  int32_t i = 0;
  while (i < 16) {
    uint8_t c = e[i];
    if (c < 48) { break; }
    if (c > 57) { break; }
    v = v * 10 + (c - 48);
    i = i + 1;
  }
  if (i == 0) { return defv; }
  return v;
}

uint32_t xlang_async_trace_topn(void) {
  uint8_t *e = link_abi_getenv((uint8_t *)"XLANG_ASYNC_RUNTIME_TRACE_TOPN");
  uint32_t v = runtime_scheduler_glue_env_parse_u32_default(e, 20);
  if (v < 1) { return 1; }
  if (v > 64) { return 64; }
  return v;
}

uint32_t xlang_async_trace_sample_rate(void) {
  uint8_t *e = link_abi_getenv((uint8_t *)"XLANG_ASYNC_RUNTIME_TRACE_SAMPLE");
  uint32_t v = runtime_scheduler_glue_env_parse_u32_default(e, 1);
  if (v < 1) { return 1; }
  return v;
}

uint64_t xlang_async_trace_slow_us(void) {
  uint8_t *e = link_abi_getenv((uint8_t *)"XLANG_ASYNC_RUNTIME_TRACE_SLOW_US");
  uint32_t v = runtime_scheduler_glue_env_parse_u32_default(e, 500);
  return v;
}
