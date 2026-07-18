// classify: see function docblock below.
/** Internal function `classify`.
 * Implements `classify`.
 * @param n i32
 * @return i32
 */
function classify(n: i32): i32 {
  return match n {
    _ if n > 0 => 1;
    _ if n < 0 => -1;
    _ => 0;
  };
}

/** Internal function `pick`.
 * Implements `pick`.
 * @param v i32
 * @return i32
 */
function pick(v: i32): i32 {
  return match v {
    1 | 2 if v == 2 => 20;
    1 | 2 => 10;
    _ => 0;
  };
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (classify(5) != 1) {
    return 1;
  }
  if (classify(-3) != -1) {
    return 2;
  }
  if (classify(0) != 0) {
    return 3;
  }
  if (pick(2) != 20) {
    return 4;
  }
  if (pick(1) != 10) {
    return 5;
  }
  return 0;
}
