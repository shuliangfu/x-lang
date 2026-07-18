// pick: see function docblock below.
/** Internal function `pick`.
 * Implements `pick`.
 * @param v i32
 * @return i32
 */
function pick(v: i32): i32 {
  let acc: i32 = 0;
  defer { acc = acc + 1; }
  if (v == 1) {
    return 10;
  }
  if (v == 2) {
    return 20;
  }
  return acc;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: i32 = pick(1);
  let b: i32 = pick(2);
  return a + b;
}
