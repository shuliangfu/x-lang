// STD-048：SyncQueue_i32 单线程往返 + C 竞争烟测
const queue = import("std.queue");

function main(): i32 {
  let sq: SyncQueue_i32 = queue.sync_new();
  if (sq.lock == 0 as *u8) {
    return 1;
  }
  if (queue.sync_push(&sq, 10) != 0) {
    queue.sync_deinit(&sq);
    return 2;
  }
  if (queue.sync_push(&sq, 20) != 0) {
    queue.sync_deinit(&sq);
    return 3;
  }
  if (queue.len(sq) != 2) {
    queue.sync_deinit(&sq);
    return 4;
  }
  let v: i32 = 0;
  if (queue.sync_try_pop(&sq, &v) != 0) {
    queue.sync_deinit(&sq);
    return 5;
  }
  if (v != 10) {
    queue.sync_deinit(&sq);
    return 6;
  }
  if (queue.sync_try_pop(&sq, &v) != 0) {
    queue.sync_deinit(&sq);
    return 7;
  }
  if (v != 20) {
    queue.sync_deinit(&sq);
    return 8;
  }
  if (queue.is_empty(sq) != 1) {
    queue.sync_deinit(&sq);
    return 9;
  }
  queue.sync_deinit(&sq);
  return 0;
}
