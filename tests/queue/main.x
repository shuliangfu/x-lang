// 测试 std.queue：push_back、push_front、pop_back、pop_front、get、len、deinit
const queue = import("std.queue");

function main(): i32 {
  let q: Queue_i32 = queue.new();
  if (queue.push_back(&q, 1) != 0) { return 1; }
  if (queue.push_back(&q, 2) != 0) { return 2; }
  if (queue.push_front(&q, 0) != 0) { return 3; }
  if (queue.len(q) != 3) { return 4; }
  if (queue.get(q, 0) != 0) { return 5; }
  if (queue.get(q, 1) != 1) { return 6; }
  if (queue.get(q, 2) != 2) { return 7; }
  if (queue.pop_front(&q) != 0) { return 8; }
  if (queue.pop_back(&q) != 2) { return 9; }
  if (queue.len(q) != 1) { return 10; }
  if (queue.pop_back(&q) != 1) { return 11; }
  if (queue.is_empty(q) != 1) { return 12; }
  queue.deinit(&q);
  return 0;
}
