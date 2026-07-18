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

/** Internal function `sum_pair`.
 * Implements `sum_pair`.
 * @param p Pair
 * @return i32
 */
function sum_pair(p: Pair): i32 {
  return p.a + p.b;
}

/** Internal function `read_pair_ptr`.
 * Read path helper `read_pair_ptr`.
 * @param p *Pair
 * @return i32
 */
function read_pair_ptr(p: *Pair): i32 {
  return p.a + p.b;
}
