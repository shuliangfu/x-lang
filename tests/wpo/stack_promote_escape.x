// See implementation.
// See implementation.

/* See implementation. */
struct Pair {
  a: i32
  b: i32
}

/** Internal function `make_pair`.
 * Implements `make_pair`.
 * @param x i32
 * @param y i32
 * @return Pair
 */
function make_pair(x: i32, y: i32): Pair {
  return Pair { a: x, b: y };
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let p: Pair = make_pair(3, 4);
  let addr: *Pair = &p;
  /* See implementation. */
  let a: i32 = addr.a;
  let b: i32 = addr.b;
  return a + b;
}
