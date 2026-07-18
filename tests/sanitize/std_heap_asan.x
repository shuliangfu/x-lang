// See implementation.
//
// See implementation.
// See implementation.
const heap = import("std.heap");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let p: *u8 = heap.alloc(32);
  if (p == 0 as *u8) {
    return 1;
  }
  p[0] = 1;
  heap.free(p);

  let z: *u8 = heap.alloc_zero(8);
  if (z == 0 as *u8) {
    return 2;
  }
  heap.free(z);

  let r: *u8 = heap.alloc(4);
  if (r == 0 as *u8) {
    return 3;
  }
  let r2: *u8 = heap.realloc(r, 64);
  if (r2 == 0 as *u8) {
    return 4;
  }
  heap.free(r2);

  let ar: Arena64 = heap.arena64_empty();
  if (heap.arena64_init(&ar, 128) != 0) {
    return 5;
  }
  let ap: *u8 = heap.arena64_alloc(&ar, 16, 8);
  if (ap == 0 as *u8) {
    heap.arena64_deinit(&ar);
    return 6;
  }
  heap.arena64_deinit(&ar);
  return 0;
}
