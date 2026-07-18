// sum_range: see function docblock below.

/** Internal function `sum_range`.
 * Implements `sum_range`.
 * @param n i32
 * @return i32
 */
function sum_range(n: i32): i32 {
  let total: i32 = 0;
  for (i : 0 .. n) {
    total = total + i;
  }
  return total;
}

/** Internal function `nested_sum`.
 * Implements `nested_sum`.
 * @return i32
 */
function nested_sum(): i32 {
  let acc: i32 = 0;
  for (outer : 1 .. 4) {
    for (inner : 0 .. outer) {
      acc = acc + 1;
    }
  }
  return acc;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (sum_range(5) != 10) {
    return 1;
  }
  if (nested_sum() != 6) {
    return 2;
  }
  return 0;
}
