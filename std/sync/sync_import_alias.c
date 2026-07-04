/**
 * sync_import_alias.c — import binding `-o` 链接桩
 *
 * asm co-emit 对 `const sync = import("std.sync")` 生成 std_sync_* 符号；
 * sync.o 仅含 sync.x 锚点，mod.x 门面未 co-emit。本 TU 提供 std_sync_* 转发至
 * runtime_sync_os.c / runtime_sync_lock_diag_tls.c 中的 sync_*_c。
 */
#include <stdint.h>

extern void *sync_mutex_new_c(void);
extern int32_t sync_mutex_lock_c(void *m);
extern int32_t sync_mutex_try_lock_c(void *m);
extern int32_t sync_mutex_unlock_c(void *m);
extern void sync_mutex_free_c(void *m);
extern void *sync_rwlock_new_c(void);
extern int32_t sync_rwlock_read_lock_c(void *rw);
extern int32_t sync_rwlock_write_lock_c(void *rw);
extern int32_t sync_rwlock_read_unlock_c(void *rw);
extern int32_t sync_rwlock_write_unlock_c(void *rw);
extern void sync_rwlock_free_c(void *rw);
extern void *sync_condvar_new_c(void);
extern int32_t sync_condvar_wait_c(void *cv, void *mutex);
extern int32_t sync_condvar_signal_c(void *cv);
extern int32_t sync_condvar_broadcast_c(void *cv);
extern void sync_condvar_free_c(void *cv);
extern int32_t sync_rwlock_contention_smoke_c(void);
extern int32_t sync_condvar_contention_smoke_c(void);
extern void sync_lock_diag_set_enabled_c(int32_t on);
extern int32_t sync_lock_diag_is_enabled_c(void);
extern int32_t sync_lock_diag_mutex_set_id_c(void *m, int32_t id);
extern int32_t sync_lock_diag_last_err_c(void);
extern void sync_lock_diag_clear_c(void);
extern int32_t sync_lock_diag_snapshot_c(uint8_t *out, int32_t cap);
extern int32_t sync_lock_diag_smoke_c(void);

/** 创建 Mutex；转发 sync_mutex_new_c。 */
uint8_t *std_sync_mutex_new(void) { return (uint8_t *)sync_mutex_new_c(); }

/** 加锁；转发 sync_mutex_lock_c。 */
int32_t std_sync_mutex_lock(uint8_t *m) { return sync_mutex_lock_c((void *)m); }

/** 尝试加锁；转发 sync_mutex_try_lock_c。 */
int32_t std_sync_mutex_try_lock(uint8_t *m) { return sync_mutex_try_lock_c((void *)m); }

/** 解锁；转发 sync_mutex_unlock_c。 */
int32_t std_sync_mutex_unlock(uint8_t *m) { return sync_mutex_unlock_c((void *)m); }

/** 释放 Mutex；转发 sync_mutex_free_c。 */
void std_sync_mutex_free(uint8_t *m) { sync_mutex_free_c((void *)m); }

/** 创建 RwLock；转发 sync_rwlock_new_c。 */
uint8_t *std_sync_rwlock_new(void) { return (uint8_t *)sync_rwlock_new_c(); }

/** 释放 RwLock；转发 sync_rwlock_free_c。 */
void std_sync_rwlock_free(uint8_t *rw) { sync_rwlock_free_c((void *)rw); }

/** 读锁；转发 sync_rwlock_read_lock_c。 */
int32_t std_sync_rwlock_read_lock(uint8_t *rw) { return sync_rwlock_read_lock_c((void *)rw); }

/** 写锁；转发 sync_rwlock_write_lock_c。 */
int32_t std_sync_rwlock_write_lock(uint8_t *rw) { return sync_rwlock_write_lock_c((void *)rw); }

/** 释放读锁；转发 sync_rwlock_read_unlock_c。 */
int32_t std_sync_rwlock_read_unlock(uint8_t *rw) { return sync_rwlock_read_unlock_c((void *)rw); }

/** 释放写锁；转发 sync_rwlock_write_unlock_c。 */
int32_t std_sync_rwlock_write_unlock(uint8_t *rw) { return sync_rwlock_write_unlock_c((void *)rw); }

/** 创建 Condvar；转发 sync_condvar_new_c。 */
uint8_t *std_sync_condvar_new(void) { return (uint8_t *)sync_condvar_new_c(); }

/** 等待 Condvar；转发 sync_condvar_wait_c。 */
int32_t std_sync_condvar_wait(uint8_t *cv, uint8_t *mutex) {
  return sync_condvar_wait_c((void *)cv, (void *)mutex);
}

/** 唤醒一个等待者；转发 sync_condvar_signal_c。 */
int32_t std_sync_condvar_signal(uint8_t *cv) { return sync_condvar_signal_c((void *)cv); }

/** 唤醒全部等待者；转发 sync_condvar_broadcast_c。 */
int32_t std_sync_condvar_broadcast(uint8_t *cv) { return sync_condvar_broadcast_c((void *)cv); }

/** 释放 Condvar；转发 sync_condvar_free_c。 */
void std_sync_condvar_free(uint8_t *cv) { sync_condvar_free_c((void *)cv); }

/** RwLock 竞争烟测；转发 sync_rwlock_contention_smoke_c。 */
int32_t std_sync_rwlock_contention_smoke(void) { return sync_rwlock_contention_smoke_c(); }

/** Condvar 竞争烟测；转发 sync_condvar_contention_smoke_c。 */
int32_t std_sync_condvar_contention_smoke(void) { return sync_condvar_contention_smoke_c(); }

/** 开启/关闭锁诊断；转发 sync_lock_diag_set_enabled_c。 */
void std_sync_lock_diag_set_enabled(int32_t on) { sync_lock_diag_set_enabled_c(on); }

/** 查询锁诊断是否开启；转发 sync_lock_diag_is_enabled_c。 */
int32_t std_sync_lock_diag_is_enabled(void) { return sync_lock_diag_is_enabled_c(); }

/** 为 mutex 绑定锁序 id；转发 sync_lock_diag_mutex_set_id_c。 */
int32_t std_sync_lock_diag_mutex_set_id(uint8_t *m, int32_t id) {
  return sync_lock_diag_mutex_set_id_c((void *)m, id);
}

/** 最近诊断错误码；转发 sync_lock_diag_last_err_c。 */
int32_t std_sync_lock_diag_last_err(void) { return sync_lock_diag_last_err_c(); }

/** 清空诊断状态；转发 sync_lock_diag_clear_c。 */
void std_sync_lock_diag_clear(void) { sync_lock_diag_clear_c(); }

/** 写入文本快照；转发 sync_lock_diag_snapshot_c。 */
int32_t std_sync_lock_diag_snapshot(uint8_t *out, int32_t cap) {
  return sync_lock_diag_snapshot_c(out, cap);
}

/** 锁诊断烟测；转发 sync_lock_diag_smoke_c。 */
int32_t std_sync_lock_diag_smoke(void) { return sync_lock_diag_smoke_c(); }
