/**
 * ZC-4 bench：N 轮 string_view_concat_arena 链式拼接（仅 Arena64 bump，无 heap_alloc）。
 * 正确性：最终 len==N 且每字节为 'x'；exit code = N（默认 128）。
 */
const string = import("std.string");
const heap = import("std.heap");

function main(): i32 {
  let n: i32 = 128;
  let arena: Arena64 = heap.arena64_empty();
  if (heap.arena64_init(&arena, 65536) != 0) {
    return 1;
  }
  let one: u8[1] = [120];
  let unit: StrView = string.view(&one[0], 1);
  let scratch: u8[1] = [0];
  let cur0: StrView = string.view(&scratch[0], 0);
  let i: i32 = 0;
  let cur: StrView = cur0;
  while (i < n) {
    cur = string.string_view_concat_arena(&arena, cur, unit);
    i = i + 1;
  }
  if (string.len(cur) != n) {
    heap.arena64_deinit(&arena);
    return 2;
  }
  let j: i32 = 0;
  while (j < n) {
    if (string.string_view_get(cur, j) != 120) {
      heap.arena64_deinit(&arena);
      return 3;
    }
    j = j + 1;
  }
  heap.arena64_deinit(&arena);
  return n;
}
