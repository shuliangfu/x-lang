/**
 * Cookbook QUEUE-01：Queue_u8 push/pop（STD-163）。
 */
const queue = import("std.queue");

function main(): i32 {
  let q: Queue_u8 = queue.new();
  if (queue.push_back(&q, 7 as u8) != 0) { return 1; }
  if (queue.pop_front(&q) != 7 as u8) { return 2; }
  queue.deinit(&q);
  return 0;
}
