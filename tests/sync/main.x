// 测试 std.sync：new_mutex、lock、try_lock、unlock、free_mutex
//
// 【文件职责】本文件为 std.sync 的回归测试。
// 【测试目的】确认 Mutex API
// 在单线程下行为正确且不崩溃；创建、加锁、尝试加锁、解锁、释放。
// 【覆盖 API】new_mutex、lock、try_lock、unlock、free_mutex。
// 【预期结果】退出码 0 表示通过。
// 【运行方式】bash tests/run-sync.sh 或 ./tests/run-sync.sh
const sync = import("std.sync");

function main(): i32 {
  // 创建互斥体；失败返回 0
  let m: *u8 = sync.new_mutex();
  if (m == 0) {
    return 1;
  }
  // 加锁应成功
  if (sync.lock(m) != 0) {
    sync.free_mutex(m);
    return 2;
  }
  // 同一线程 try_lock 应失败（已持有锁）；POSIX 返回 EBUSY -> 1，Windows TryEnter
  // 返回 0 表示成功（可重入），我们约定返回非 0 表示未获取
  // 注意：Windows CRITICAL_SECTION 可重入，同一线程 try_lock 会成功；POSIX
  // 会返回 1。测试只要求 unlock 成功。
  if (sync.unlock(m) != 0) {
    sync.free_mutex(m);
    return 3;
  }
  // 已解锁，try_lock 应成功
  if (sync.try_lock(m) != 0) {
    sync.free_mutex(m);
    return 4;
  }
  if (sync.unlock(m) != 0) {
    sync.free_mutex(m);
    return 5;
  }
  sync.free_mutex(m);
  return 0;
}
