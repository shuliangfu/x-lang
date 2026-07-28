/* seeds/runtime_channel_glue_surface.from_x.c
 * G-02f-21 runtime_channel_glue R2 thin+rest surface - isomorphic with src/asm/runtime_channel_glue.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/runtime_channel_glue.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (17 #[no_mangle] + 1 doc_anchor)
 * Mode: thin+rest - 17 public API forwards to _impl extern C bridges;
 *   rest keeps OS-specific logic (pthread_mutex_t/pthread_cond_t / CRITICAL_SECTION/CONDITION_VARIABLE)
 * Cap residual: 17 _impl - channel_sync_init/destroy/lock/unlock/signal_not_empty/signal_not_full/
 *   broadcast_not_empty/broadcast_not_full (8) + wait_not_empty/wait_not_full/timedwait_not_empty/
 *   timedwait_not_full/unbounded_grow/select_recv_case_live/select_send_case_live/
 *   select_wait_recv_one/select_wait_send_one (9)
 * Note: doc_anchor runtime_channel_glue_x_doc_anchor (no ast_; channel_ prefix not trigger).
 * Logic: 17 functions = 8 sync + 4 wait + 1 grow + 4 select thin+rest forwards.
 * Regen: ./xlang-c -E ... runtime_channel_glue.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

extern int32_t channel_sync_init_impl(uint8_t *c);
extern void channel_sync_destroy_impl(uint8_t *c);
extern void channel_lock_impl(uint8_t *c);
extern void channel_unlock_impl(uint8_t *c);
extern void channel_signal_not_empty_impl(uint8_t *c);
extern void channel_signal_not_full_impl(uint8_t *c);
extern void channel_broadcast_not_empty_impl(uint8_t *c);
extern void channel_broadcast_not_full_impl(uint8_t *c);

extern void channel_wait_not_empty_impl(uint8_t *c);
extern void channel_wait_not_full_impl(uint8_t *c);
extern void channel_timedwait_not_empty_impl(uint8_t *c, int32_t ms);
extern void channel_timedwait_not_full_impl(uint8_t *c, int32_t ms);
extern int32_t channel_unbounded_grow_impl(uint8_t *c);
extern int32_t channel_select_recv_case_live_impl(uint8_t *c);
extern int32_t channel_select_send_case_live_impl(uint8_t *c);
extern void channel_select_wait_recv_one_impl(uint8_t *c);
extern void channel_select_wait_send_one_impl(uint8_t *c);

int32_t runtime_channel_glue_x_doc_anchor(void) {
  return 0;
}

int32_t channel_sync_init(uint8_t *c) {
  return channel_sync_init_impl(c);
}

void channel_sync_destroy(uint8_t *c) {
  channel_sync_destroy_impl(c);
}

void channel_lock(uint8_t *c) {
  channel_lock_impl(c);
}

void channel_unlock(uint8_t *c) {
  channel_unlock_impl(c);
}

void channel_signal_not_empty(uint8_t *c) {
  channel_signal_not_empty_impl(c);
}

void channel_signal_not_full(uint8_t *c) {
  channel_signal_not_full_impl(c);
}

void channel_broadcast_not_empty(uint8_t *c) {
  channel_broadcast_not_empty_impl(c);
}

void channel_broadcast_not_full(uint8_t *c) {
  channel_broadcast_not_full_impl(c);
}

void channel_wait_not_empty(uint8_t *c) {
  channel_wait_not_empty_impl(c);
}

void channel_wait_not_full(uint8_t *c) {
  channel_wait_not_full_impl(c);
}

void channel_timedwait_not_empty(uint8_t *c, int32_t ms) {
  channel_timedwait_not_empty_impl(c, ms);
}

void channel_timedwait_not_full(uint8_t *c, int32_t ms) {
  channel_timedwait_not_full_impl(c, ms);
}

int32_t channel_unbounded_grow(uint8_t *c) {
  return channel_unbounded_grow_impl(c);
}

int32_t channel_select_recv_case_live(uint8_t *c) {
  return channel_select_recv_case_live_impl(c);
}

int32_t channel_select_send_case_live(uint8_t *c) {
  return channel_select_send_case_live_impl(c);
}

void channel_select_wait_recv_one(uint8_t *c) {
  channel_select_wait_recv_one_impl(c);
}

void channel_select_wait_send_one(uint8_t *c) {
  channel_select_wait_send_one_impl(c);
}
