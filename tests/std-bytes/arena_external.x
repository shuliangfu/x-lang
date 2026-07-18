// See implementation.
//
// See implementation.
const bytes = import("std.bytes");
const heap = import("std.heap");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let arena: Arena64 = heap.arena64_empty();
  if (heap.arena64_init(&arena, 256 as usize) != 0) {
    return 1;
  }

  let slab: *u8 = heap.arena64_alloc(&arena, 64 as usize, 8 as usize);
  if (slab == 0) {
    heap.arena64_deinit(&arena);
    return 2;
  }

  let b: Bytes = bytes.from_external(slab, 0, 64);
  if (bytes.is_owned(b) != 0) {
    heap.arena64_deinit(&arena);
    return 3;
  }
  if (bytes.recommend_bytes_alloc_arena() != 0) {
    heap.arena64_deinit(&arena);
    return 4;
  }

  let data: u8[3] = [1, 2, 3];
  if (bytes.extend(&b, &data[0], 3) != 0) {
    heap.arena64_deinit(&arena);
    return 5;
  }
  if (bytes.len(b) != 3) {
    heap.arena64_deinit(&arena);
    return 6;
  }

  /* See implementation. */
  bytes.deinit(&b);
  let slab2: *u8 = heap.arena64_alloc(&arena, 8 as usize, 8 as usize);
  if (slab2 == 0) {
    heap.arena64_deinit(&arena);
    return 7;
  }

  heap.arena64_deinit(&arena);
  return 0;
}
