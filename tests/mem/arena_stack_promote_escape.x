// See implementation.
const heap = import("std.heap");

/* See implementation. */
struct Pair {
  a: i32
  b: i32
}

/** Internal function `make_pair_arena`.
 * Implements `make_pair_arena`.
 * @param al Allocator
 * @param x i32
 * @param y i32
 * @return *Pair
 */
function make_pair_arena(al: Allocator, x: i32, y: i32): *Pair {
  let raw: *u8 = heap.alloc(al, 8 as usize);
  let p: *Pair = raw as *Pair;
  p.a = x;
  p.b = y;
  return p;
}

/** Internal function `sum_pair_ptr`.
 * Implements `sum_pair_ptr`.
 * @param p *Pair
 * @return i32
 */
function sum_pair_ptr(p: *Pair): i32 {
  return p.a + p.b;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let escaped: *Pair = 0 as *Pair;
  with_arena(4096) {
    let p: *Pair = make_pair_arena(heap.scope_alloc(), 3, 4);
    escaped = p;
  }
  return sum_pair_ptr(escaped);
}
