// f_i64: see function docblock below.
/** Internal function `f_i64`.
 * Implements `f_i64`.
 * @param n i64
 * @return i64
 */
function f_i64(n: i64): i64 {
  return n >= 0 ? n : -1;
}

// f_i32: see function docblock below.
/** Internal function `f_i32`.
 * Implements `f_i32`.
 * @param n i32
 * @return i64
 */
function f_i32(n: i32): i64 {
  return n >= 0 ? n : -1;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: i64 = f_i64(1);
  let b: i64 = f_i32(1);
  if (a < 0 || b < 0) {
    return 1;
  }
  return 0;
}
