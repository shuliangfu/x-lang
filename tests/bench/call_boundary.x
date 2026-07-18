// f0: see function docblock below.
/** Internal function `f0`.
 * Implements `f0`.
 * @param x i32
 * @return i32
 */
function f0(x: i32): i32 {
  return x + 1;
}
/** Internal function `f1`.
 * Implements `f1`.
 * @param x i32
 * @return i32
 */
function f1(x: i32): i32 {
  return f0(x) + 1;
}
/** Internal function `f2`.
 * Implements `f2`.
 * @param x i32
 * @return i32
 */
function f2(x: i32): i32 {
  return f1(x) + 1;
}
/** Internal function `f3`.
 * Implements `f3`.
 * @param x i32
 * @return i32
 */
function f3(x: i32): i32 {
  return f2(x) + 1;
}
/** Internal function `f4`.
 * Implements `f4`.
 * @param x i32
 * @return i32
 */
function f4(x: i32): i32 {
  return f3(x) + 1;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let n: i32 = 200000000;
  let s: i32 = 0;
  let i: i32 = 0;
  while (i < n) {
    s = s + f4(i);
    i = i + 1;
  }
  return s;
}
