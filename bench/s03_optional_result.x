// s03_optional_result.x — Optional/Result hot-path overhead benchmark
// fallback: xlang Optional/Result type not yet available.
// Only the "direct return" variant is implemented. The optional variant
// would require a first-class Optional/Result type which xlang does not
// yet support.
//
// Matches bench/s03_optional_result.c / .zig algorithm (direct portion only).
// N=100000000 calls. compute(x) = x * 42 + 7.

/** Internal function `compute_direct`.
 * Pure arithmetic: returns x * 42 + 7.
 * @param x input value
 * @return i32 x * 42 + 7
 */
function compute_direct(x: i32): i32 {
  return x * 42 + 7;
}

/** Internal function `bench_direct`.
 * Calls compute_direct N times, accumulating the results.
 * @param n iteration count
 * @return i32 accumulated sum
 */
function bench_direct(n: i32): i32 {
  let sum: i32 = 0;
  let i: i32 = 0;
  while (i < n) {
    sum = sum + compute_direct(i);
    i = i + 1;
  }
  return sum;
}

/** Internal function `main`.
 * Program/test entry point. Calls bench_direct and returns the sum.
 * @return i32 accumulated sum
 */
function main(): i32 {
  let n: i32 = 100000000;
  return bench_direct(n);
}
