// cc04_parallel_reduce.x — 并发基准：多线程分治规约（xlang 对照）
// single-thread fallback: xlang thread API not yet available.
// Algorithm is identical: 4 slices of 10000000 elements each, each slice
// reduced to a sum-of-squares, then the 4 partials merged. Here the 4 slices
// run sequentially in one thread instead of 4 parallel threads.

/** Internal function `main`.
 * Single-thread fallback for the parallel-reduce benchmark.
 *
 * Partitions [0, N_TOTAL) into N_THREADS=4 contiguous slices of SLICE=
 * 10000000 each. For each slice computes the sum of squares of the element
 * value (i & mask, mask=1023); the mask keeps values in [0,1023] so the total
 * stays within i64 (raw i*i over 4e7 elements would overflow i64). The 4
 * partial sums are accumulated into a single total. The C/Zig version
 * assigns each slice to a thread; here slices run serially.
 *
 * @return i32 — low byte of total (cast), anti-constant-folding sink
 */
function main(): i32 {
  let n_threads: i32 = 4;
  let slice: i64 = 10000000;
  let mask: i64 = 1023;
  let total: i64 = 0;
  let t: i32 = 0;
  while (t < n_threads) {
    let start: i64 = (t as i64) * slice;
    let end: i64 = start + slice;
    let sum: i64 = 0;
    let i: i64 = start;
    while (i < end) {
      let v: i64 = i & mask;
      let vv: i64 = v * v;
      sum = sum + vv;
      i = i + 1;
    }
    total = total + sum;
    t = t + 1;
  }
  return (total & 255) as i32;
}
