// STD-111：std.sync 调试锁诊断烟测（锁序 + 递归 + 快照）
const sync = import("std.sync");

function main(): i32 {
  let m1: *u8 = sync.new_mutex();
  let m2: *u8 = sync.new_mutex();
  let snap: u8[96] = [];
  if (m1 == 0 as *u8 || m2 == 0 as *u8) {
    sync.free_mutex(m1);
    sync.free_mutex(m2);
    return 1;
  }
  lock_diag_clear();
  lock_diag_set_enabled(1);
  if (lock_diag_mutex_set_id(m1, 1) != 0 || lock_diag_mutex_set_id(m2, 2) != 0) {
    lock_diag_set_enabled(0);
    sync.free_mutex(m1);
    sync.free_mutex(m2);
    return 2;
  }
  if (sync.lock(m1) != 0 || sync.lock(m2) != 0) {
    lock_diag_set_enabled(0);
    sync.free_mutex(m1);
    sync.free_mutex(m2);
    return 3;
  }
  if (sync.unlock(m2) != 0 || sync.unlock(m1) != 0) {
    lock_diag_set_enabled(0);
    sync.free_mutex(m1);
    sync.free_mutex(m2);
    return 4;
  }
  if (sync.lock(m2) != 0) {
    lock_diag_set_enabled(0);
    sync.free_mutex(m1);
    sync.free_mutex(m2);
    return 5;
  }
  if (sync.lock(m1) != -1 || lock_diag_last_err() != lock_diag_err_order()) {
    sync.unlock(m2);
    lock_diag_set_enabled(0);
    sync.free_mutex(m1);
    sync.free_mutex(m2);
    return 6;
  }
  sync.unlock(m2);
  if (sync.lock(m1) != 0) {
    lock_diag_set_enabled(0);
    sync.free_mutex(m1);
    sync.free_mutex(m2);
    return 7;
  }
  if (sync.lock(m1) != -1 || lock_diag_last_err() != lock_diag_err_recursive()) {
    sync.unlock(m1);
    lock_diag_set_enabled(0);
    sync.free_mutex(m1);
    sync.free_mutex(m2);
    return 8;
  }
  sync.unlock(m1);
  if (lock_diag_snapshot(&snap[0], 96) <= 0) {
    lock_diag_set_enabled(0);
    sync.free_mutex(m1);
    sync.free_mutex(m2);
    return 9;
  }
  lock_diag_set_enabled(0);
  if (sync.lock(m1) != 0 || sync.unlock(m1) != 0) {
    sync.free_mutex(m1);
    sync.free_mutex(m2);
    return 10;
  }
  sync.free_mutex(m1);
  sync.free_mutex(m2);
  if (lock_diag_smoke() != 0) {
    return 11;
  }
  return 0;
}
