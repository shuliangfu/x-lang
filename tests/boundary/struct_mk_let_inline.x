// See implementation.
struct Pair {
  a: i32
  b: i32
}

/** Internal function `mk`.
 * Implements `mk`.
 * @param a i32
 * @param b i32
 * @return Pair
 */
function mk(a: i32, b: i32): Pair {
  return Pair { a: a, b: b };
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: Pair = mk(1, 2);
  let b: Pair = mk(3, 4);
  return a.a + a.b + b.a + b.b;
}
