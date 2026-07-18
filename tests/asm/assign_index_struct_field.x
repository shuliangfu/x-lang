struct WithArr {
  arr: i32[3]
}
/** Internal function `set_in`.
 * Implements `set_in`.
 * @param p WithArr
 * @param i i32
 * @param v i32
 * @return i32
 */
function set_in(p: WithArr, i: i32, v: i32): i32 {
  p.arr[i] = v;
  return p.arr[i];
}
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let w: WithArr = WithArr { arr: [5, 10, 15] };
  return set_in(w, 1, 99);
}
