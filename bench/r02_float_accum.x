// r02_float_accum.x — FP accumulation benchmark (matches r02_float_accum.c / .zig)
// Tests: f64 accumulation and multiply-add throughput.

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let n: i32 = 100000000;
  let sum: f64 = 0.0;
  let half: f64 = 0.5;
  let i: i32 = 0;
  while (i < n) {
    sum = sum + (i as f64) * half;
    i = i + 1;
  }
  return (sum as i32);
}
