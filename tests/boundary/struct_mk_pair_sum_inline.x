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

/** Internal function `add_pair`.
 * Implements `add_pair`.
 * @param p Pair
 * @return i32
 */
function add_pair(p: Pair): i32 {
  return p.a + p.b;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let n: i32 = 5;
  let s: i32 = 0;
  let i: i32 = 0;
  while (i < n) {
    s = s + add_pair(mk(i, 2));
    i = i + 1;
  }
  return s;
}
