// See implementation.
// See implementation.
#[repr(C)]
struct Pair { a: i32; b: i32; }

/** Internal function `make_pair`.
 * Implements `make_pair`.
 * @param a i32
 * @param b i32
 * @param c i32
 * @param d i32
 * @return Pair
 */
function make_pair(a: i32, b: i32, c: i32, d: i32): Pair {
  let p: Pair = Pair { a: a + c, b: b + d };
  return p;
}

/** Internal function `sum6`.
 * Implements `sum6`.
 * @param a i32
 * @param b i32
 * @param c i32
 * @param d i32
 * @param e i32
 * @param f i32
 * @return i32
 */
function sum6(a: i32, b: i32, c: i32, d: i32, e: i32, f: i32): i32 {
  return a + b + c + d + e + f;
}

/** Internal function `fib`.
 * Implements `fib`.
 * @param n i32
 * @return i32
 */
function fib(n: i32): i32 {
  if (n < 2) { return n; }
  return fib(n - 1) + fib(n - 2);
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let acc: u32 = 0;

  let p: Pair = make_pair(1, 2, 3, 4);
  acc = acc ^ ((p.a ^ p.b) as u32);

  acc = acc ^ (sum6(10, 20, 30, 40, 50, 60) as u32);

  acc = acc ^ (fib(15) as u32);

  return (acc & 0xFF) as i32;
}
