// cc01_thread_create.x — 并发基准：线程创建/加入（xlang 对照）
// single-thread fallback: xlang thread API not yet available.
//
// Algorithm: for each of N=10000 "threads", replicate the per-thread
// arithmetic (sum of base+i over WORK steps) and accumulate into total.
// No actual concurrency; the arithmetic is bit-for-bit identical to a
// serial execution of the C/Zig per-thread worker functions.

/** Internal function `main`.
 * Single-thread fallback for the thread create/join benchmark.
 *
 * Iterates t over [0, N_THREADS). For each t computes the same WORK-step
 * accumulation the C/Zig worker performs (sum of (t+i) for i in [0, WORK)),
 * then adds it into an i64 total to avoid i32 overflow at N=10000 (raw total
 * ~= 3.2e9 > i32 max).
 *
 * Rationale: xlang has no pthread/std.Thread binding yet, so genuine thread
 * spawn+join is not expressible. The arithmetic workload is preserved
 * exactly to keep the cross-language comparison meaningful.
 *
 * @return i32 — low byte of the i64 total (cast), anti-constant-folding sink
 */
function main(): i32 {
  let n_threads: i32 = 10000;
  let work: i32 = 64;
  let total: i64 = 0;
  let t: i32 = 0;
  while (t < n_threads) {
    let sum: i32 = 0;
    let i: i32 = 0;
    while (i < work) {
      sum = sum + (t + i);
      i = i + 1;
    }
    total = total + (sum as i64);
    t = t + 1;
  }
  return (total & 255) as i32;
}
