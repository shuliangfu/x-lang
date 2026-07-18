// See implementation.
struct Pair {
  a: i32
  b: i32
}

/** Internal function `get_a`.
 * Query helper `get_a`.
 * @param p Pair
 * @return i32
 */
function get_a(p: Pair): i32 {
  return p.a;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let n: i32 = 5;
  let s: i32 = 0;
  let i: i32 = 0;
  let p: Pair = Pair { a: 0, b: 2 };
  while (i < n) {
    p.a = i;
    s = s + get_a(p);
    i = i + 1;
  }
  return s;
}
