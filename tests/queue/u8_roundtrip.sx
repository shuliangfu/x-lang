// STD-163：Queue_u8 烟测
const queue = import("std.queue");

function main(): i32 {
  let q: Queue_u8 = queue.new();
  if (queue.push_back(&q, 1) != 0) { return 1; }
  if (queue.push_back(&q, 2) != 0) { return 2; }
  if (queue.len(q) != 2) { return 3; }
  if (queue.pop_front(&q) != 1) { return 4; }
  if (queue.pop_front(&q) != 2) { return 5; }
  queue.deinit(&q);
  return 0;
}
