// s01_bounds_check.x — bounds check overhead benchmark
// fallback: xlang always inserts bounds check; cannot test no-check path.
// Only the "with check" variant is implemented. The without-check variant
// would require unsafe/raw pointer access which xlang does not support.
//
// Matches bench/s01_bounds_check.c / .zig algorithm (with_check portion only).
// N=10000000 elements, R=10 rounds.

/** Internal function `bench_with_check`.
 * Reads arr[idx[i]] with explicit bounds check on each access.
 * Loops R rounds over N indices, accumulating sum of arr[idx[i]].
 * @param arr pointer to the data array base
 * @param idx pointer to the random index array base
 * @param n number of elements / indices
 * @param rounds number of passes over the data
 * @return i32 accumulated sum
 */
function bench_with_check(arr: *i32, idx: *i32, n: i32, rounds: i32): i32 {
  let sum: i32 = 0;
  let r: i32 = 0;
  while (r < rounds) {
    let i: i32 = 0;
    while (i < n) {
      let ii: i32 = idx[i];
      if (ii >= 0 && ii < n) {
        sum = sum + arr[ii];
      }
      i = i + 1;
    }
    r = r + 1;
  }
  return sum;
}

/** Internal function `main`.
 * Program/test entry point. Initialises arr and idx with a pseudo-random
 * index pattern, then runs bench_with_check and returns the accumulated sum.
 * @return i32 accumulated sum from bench_with_check
 */
function main(): i32 {
  let n: i32 = 10000000;
  let rounds: i32 = 10;
  let arr: i32[10000000] = [];
  let idx: i32[10000000] = [];
  let i: i32 = 0;
  while (i < n) {
    arr[i] = i;
    // LCG-based pseudo-random index; compute in i64 to avoid i32 overflow.
    let v: i64 = (i as i64) * 1103515245 + 12345;
    idx[i] = (v % (n as i64)) as i32;
    i = i + 1;
  }
  return bench_with_check(&arr[0], &idx[0], n, rounds);
}
