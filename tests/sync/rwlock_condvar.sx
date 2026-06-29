// STD-045：RwLock/Condvar 单线程 + C 层竞争烟测
const sync = import("std.sync");

function main(): i32 {
  let rw: *u8 = sync.new_rwlock();
  if (rw == 0 as *u8) {
    return 1;
  }
  if (sync.write_lock(rw) != 0) {
    sync.free_rwlock(rw);
    return 2;
  }
  if (sync.write_unlock(rw) != 0) {
    sync.free_rwlock(rw);
    return 3;
  }
  if (sync.read_lock(rw) != 0) {
    sync.free_rwlock(rw);
    return 4;
  }
  if (sync.read_unlock(rw) != 0) {
    sync.free_rwlock(rw);
    return 5;
  }
  sync.free_rwlock(rw);
  let cv: *u8 = sync.new_condvar();
  let mu: *u8 = sync.new_mutex();
  if (cv == 0 as *u8 || mu == 0 as *u8) {
    sync.free_condvar(cv);
    sync.free_mutex(mu);
    return 6;
  }
  if (sync.lock(mu) != 0) {
    sync.free_condvar(cv);
    sync.free_mutex(mu);
    return 7;
  }
  if (sync.unlock(mu) != 0) {
    sync.free_condvar(cv);
    sync.free_mutex(mu);
    return 8;
  }
  sync.free_condvar(cv);
  sync.free_mutex(mu);
  if (rwlock_contention_smoke() != 0) {
    return 9;
  }
  if (condvar_contention_smoke() != 0) {
    return 10;
  }
  return 0;
}
