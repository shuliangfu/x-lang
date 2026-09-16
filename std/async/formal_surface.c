/* PLATFORM: SHARED — pure-asm formal vehicle for std.async leftover unique UNDEF.
 *
 * Why C face: std/async/mod.x is ~50 unique wrappers over xlang_async_* C ABI.
 * Host-cc of the whole monofile would UNDEF that C ABI on Ubuntu gold unless
 * every companion is always linked. Cookbook leftover unique names (G.7 complete):
 *   std_async_placeholder          — module import/smoke marker; returns 0 (≡ mod.x)
 *   std_async_drain_idle           — calls xlang_async_run_drain_until_idle (scheduler glue)
 *   std_async_scheduler_reset      — calls xlang_async_queue_reset (≡ mod.x scheduler_reset)
 *   std_async_net_fs_async_smoke   — calls xlang_async_net_fs_smoke_c (async_net_fs in glue)
 * Product body stays in std/async/mod.x. G.7: catalog leaf (no async.o existed);
 * do not dump unique names into labi_od_async_scheduler_sym_* (that table is C ABI
 * for scheduler.o skip-missing, never unique import METHOD std_async_*).
 * formal_mod kind=c_face.
 */
#include <stdint.h>

int32_t std_async_placeholder(void) {
  return 0;
}

/* Defined in compiler/runtime_scheduler_glue.o (seeds/runtime_scheduler_glue.from_x.c).
 * PLATFORM: SHARED — consume path ensures glue after unique needles fire.
 * async_net_fs.from_x.c is #included into the same glue TU. */
extern int32_t xlang_async_run_drain_until_idle(void);
extern void xlang_async_queue_reset(void);
extern int32_t xlang_async_net_fs_smoke_c(void);

int32_t std_async_drain_idle(void) {
  return xlang_async_run_drain_until_idle();
}

/* import("std.async").scheduler_reset() → mangled std_async_scheduler_reset.
 * Thin face ≡ mod.x scheduler_reset; body lives in scheduler glue. */
void std_async_scheduler_reset(void) {
  xlang_async_queue_reset();
}

/* import("std.async").net_fs_async_smoke() → mangled std_async_net_fs_async_smoke.
 * Thin face ≡ mod.x net_fs_async_smoke; body lives in scheduler glue (async_net_fs). */
int32_t std_async_net_fs_async_smoke(void) {
  return xlang_async_net_fs_smoke_c();
}
