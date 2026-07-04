// sync_import_alias.x — import binding -o 链接桩（从 .c 转换）

extern function sync_mutex_lock_c(m: *u8): i32;
extern function sync_mutex_try_lock_c(m: *u8): i32;
extern function sync_mutex_unlock_c(m: *u8): i32;
extern function sync_mutex_free_c(m: *u8): void;
extern function sync_rwlock_read_lock_c(rw: *u8): i32;
extern function sync_rwlock_write_lock_c(rw: *u8): i32;
extern function sync_rwlock_read_unlock_c(rw: *u8): i32;
extern function sync_rwlock_write_unlock_c(rw: *u8): i32;
extern function sync_rwlock_free_c(rw: *u8): void;
extern function sync_condvar_wait_c(cv: *u8, mutex: *u8): i32;
extern function sync_condvar_signal_c(cv: *u8): i32;
extern function sync_condvar_broadcast_c(cv: *u8): i32;
extern function sync_condvar_free_c(cv: *u8): void;
extern function sync_rwlock_contention_smoke_c(): i32;
extern function sync_condvar_contention_smoke_c(): i32;
extern function sync_lock_diag_set_enabled_c(on: i32): void;
extern function sync_lock_diag_is_enabled_c(): i32;
extern function sync_lock_diag_mutex_set_id_c(m: *u8, id: i32): i32;
extern function sync_lock_diag_last_err_c(): i32;
extern function sync_lock_diag_clear_c(): void;
extern function sync_lock_diag_snapshot_c(out: *u8, cap: i32): i32;
extern function sync_lock_diag_smoke_c(): i32;

function std_sync_mutex_lock(m: *u8): i32 { return sync_mutex_lock_c(m); }
function std_sync_mutex_try_lock(m: *u8): i32 { return sync_mutex_try_lock_c(m); }
function std_sync_mutex_unlock(m: *u8): i32 { return sync_mutex_unlock_c(m); }
function std_sync_mutex_free(m: *u8): void { sync_mutex_free_c(m); }
function std_sync_rwlock_free(rw: *u8): void { sync_rwlock_free_c(rw); }
function std_sync_rwlock_read_lock(rw: *u8): i32 { return sync_rwlock_read_lock_c(rw); }
function std_sync_rwlock_write_lock(rw: *u8): i32 { return sync_rwlock_write_lock_c(rw); }
function std_sync_rwlock_read_unlock(rw: *u8): i32 { return sync_rwlock_read_unlock_c(rw); }
function std_sync_rwlock_write_unlock(rw: *u8): i32 { return sync_rwlock_write_unlock_c(rw); }
function std_sync_condvar_wait(cv: *u8, mutex: *u8): i32 { return sync_condvar_wait_c(cv, mutex); }
function std_sync_condvar_signal(cv: *u8): i32 { return sync_condvar_signal_c(cv); }
function std_sync_condvar_broadcast(cv: *u8): i32 { return sync_condvar_broadcast_c(cv); }
function std_sync_condvar_free(cv: *u8): void { sync_condvar_free_c(cv); }
function std_sync_rwlock_contention_smoke(): i32 { return sync_rwlock_contention_smoke_c(); }
function std_sync_condvar_contention_smoke(): i32 { return sync_condvar_contention_smoke_c(); }
function std_sync_lock_diag_set_enabled(on: i32): void { sync_lock_diag_set_enabled_c(on); }
function std_sync_lock_diag_is_enabled(): i32 { return sync_lock_diag_is_enabled_c(); }
function std_sync_lock_diag_mutex_set_id(m: *u8, id: i32): i32 { return sync_lock_diag_mutex_set_id_c(m, id); }
function std_sync_lock_diag_last_err(): i32 { return sync_lock_diag_last_err_c(); }
function std_sync_lock_diag_clear(): void { sync_lock_diag_clear_c(); }
function std_sync_lock_diag_snapshot(out: *u8, cap: i32): i32 { return sync_lock_diag_snapshot_c(out, cap); }
function std_sync_lock_diag_smoke(): i32 { return sync_lock_diag_smoke_c(); }
