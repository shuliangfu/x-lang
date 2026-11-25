/**
 * 10.37: i64 vs i32 expr compare (neg lit, 0-10000, i32 var).
 * Expect compile OK and main returns 0.
 * PLATFORM: SHARED
 */
function main(): i32 {
  let x: i64 = 5;
  let a: i32 = 3;
  let n: i64 = 3;
  if (x > -1) {
  } else {
    return 11;
  }
  if (x > (0 - 10000)) {
  } else {
    return 12;
  }
  if (a == n) {
  } else {
    return 13;
  }
  if ((0 - 10000) < x) {
  } else {
    return 14;
  }
  return 0;
}
