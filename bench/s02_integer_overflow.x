// s02_integer_overflow.x — integer overflow check overhead benchmark
// fallback: xlang overflow check flag not yet available.
// Only the wrapping (no-check) variant is implemented. The with-check
// variant would require runtime overflow detection which xlang does not
// expose as a per-operation flag.
//
// Matches bench/s02_integer_overflow.c / .zig algorithm (without_check portion only).
// N=100000000 iterations, a = i*7919, b = i*6151.

/** Internal function `bench_wrapping`.
 * Performs N wrapping i32 multiplications: a = i*7919, b = i*6151, sum += a*b.
 * All arithmetic wraps in two's complement (xlang i32 default).
 * @param n iteration count
 * @return i32 accumulated wrapping sum
 */
function bench_wrapping(n: i32): i32 {
  let sum: i32 = 0;
  let i: i32 = 0;
  while (i < n) {
    let a: i32 = i * 7919;
    let b: i32 = i * 6151;
    sum = sum + a * b;
    i = i + 1;
  }
  return sum;
}

/** Internal function `main`.
 * Program/test entry point. Calls bench_wrapping and returns the sum.
 * @return i32 accumulated wrapping sum
 */
function main(): i32 {
  let n: i32 = 100000000;
  return bench_wrapping(n);
}
