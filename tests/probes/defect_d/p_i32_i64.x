/**
 * 10.37: i32 vs i64 compare uses usual-arith (stamp to i64); equal → 0.
 * PLATFORM: SHARED
 */
function main(): i32 {
  let a: i32 = 3;
  let n: i64 = 3;
  if (a == n) {
    return 0;
  }
  return 1;
}
