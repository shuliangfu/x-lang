/* seeds/runtime_sync_os_surface.from_x.c
 * G-02f-21 runtime_sync_os R2 thin+rest surface - isomorphic with src/asm/runtime_sync_os.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/runtime_sync_os.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (16 #[no_mangle] + 1 doc_anchor)
 * Mode: thin+rest - 16 public API forwards to _impl extern C bridges;
 *   rest keeps OS-specific logic (pthread_mutex_t/pthread_rwlock_t/pthread_cond_t /
 *   CRITICAL_SECTION/SRWLOCK/CONDITION_VARIABLE)
 * Cap residual: 16 _impl - sync_mutex_new/lock/try_lock/unlock/free (5) +
 *   sync_rwlock_new/read_lock/write_lock/read_unlock/write_unlock/free (6) +
 *   sync_condvar_new/wait/signal/broadcast/free (5)
 * Note: doc_anchor runtime_sync_os_x_doc_anchor (no ast_; sync_ prefix not trigger).
 * Logic: 16 functions = 5 mutex + 6 rwlock + 5 condvar thin+rest forwards.
 * Regen: ./xlang-c -E ... runtime_sync_os.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

extern uint8_t *sync_mutex_new_impl(void);
extern int32_t sync_mutex_lock_impl(uint8_t *m);
extern int32_t sync_mutex_try_lock_impl(uint8_t *m);
extern int32_t sync_mutex_unlock_impl(uint8_t *m);
extern void sync_mutex_free_impl(uint8_t *m);

extern uint8_t *sync_rwlock_new_impl(void);
extern int32_t sync_rwlock_read_lock_impl(uint8_t *rw);
extern int32_t sync_rwlock_write_lock_impl(uint8_t *rw);
extern int32_t sync_rwlock_read_unlock_impl(uint8_t *rw);
extern int32_t sync_rwlock_write_unlock_impl(uint8_t *rw);
extern void sync_rwlock_free_impl(uint8_t *rw);

extern uint8_t *sync_condvar_new_impl(void);
extern int32_t sync_condvar_wait_impl(uint8_t *cv, uint8_t *mutex);
extern int32_t sync_condvar_signal_impl(uint8_t *cv);
extern int32_t sync_condvar_broadcast_impl(uint8_t *cv);
extern void sync_condvar_free_impl(uint8_t *cv);

int32_t runtime_sync_os_x_doc_anchor(void) {
  return 0;
}

uint8_t *sync_mutex_new_c(void) {
  return sync_mutex_new_impl();
}

int32_t sync_mutex_lock_c(uint8_t *m) {
  return sync_mutex_lock_impl(m);
}

int32_t sync_mutex_try_lock_c(uint8_t *m) {
  return sync_mutex_try_lock_impl(m);
}

int32_t sync_mutex_unlock_c(uint8_t *m) {
  return sync_mutex_unlock_impl(m);
}

void sync_mutex_free_c(uint8_t *m) {
  sync_mutex_free_impl(m);
}

uint8_t *sync_rwlock_new_c(void) {
  return sync_rwlock_new_impl();
}

int32_t sync_rwlock_read_lock_c(uint8_t *rw) {
  return sync_rwlock_read_lock_impl(rw);
}

int32_t sync_rwlock_write_lock_c(uint8_t *rw) {
  return sync_rwlock_write_lock_impl(rw);
}

int32_t sync_rwlock_read_unlock_c(uint8_t *rw) {
  return sync_rwlock_read_unlock_impl(rw);
}

int32_t sync_rwlock_write_unlock_c(uint8_t *rw) {
  return sync_rwlock_write_unlock_impl(rw);
}

void sync_rwlock_free_c(uint8_t *rw) {
  sync_rwlock_free_impl(rw);
}

uint8_t *sync_condvar_new_c(void) {
  return sync_condvar_new_impl();
}

int32_t sync_condvar_wait_c(uint8_t *cv, uint8_t *mutex) {
  return sync_condvar_wait_impl(cv, mutex);
}

int32_t sync_condvar_signal_c(uint8_t *cv) {
  return sync_condvar_signal_impl(cv);
}

int32_t sync_condvar_broadcast_c(uint8_t *cv) {
  return sync_condvar_broadcast_impl(cv);
}

void sync_condvar_free_c(uint8_t *cv) {
  sync_condvar_free_impl(cv);
}
