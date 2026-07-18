/** Internal function `take`.
 * Implements `take`.
 * @param v Linear(i32)
 * @return i32
 */
function take(v: Linear(i32)): i32 {
  return v;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: Linear(i32) = 1;
  let x: i32 = take(a);
  let y: i32 = take(a);
  return x;
}
