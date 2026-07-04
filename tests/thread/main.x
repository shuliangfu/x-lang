// 测试 std.thread：thread.id、thread.create(dummy_entry)、thread.join
const thread = import("std.thread");

function main(): i32 {
  let main_id: i64 = thread.id();
  if (main_id == 0) { return 1; }
  let tid: i64 = thread.create(thread.dummy_entry_ptr(), 0);
  if (tid == 0) { return 2; }
  if (thread.join(tid) != 0) { return 3; }
  return 0;
}
