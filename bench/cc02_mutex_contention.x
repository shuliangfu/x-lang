// cc02_mutex_contention.x — 并发基准：互斥锁争用（xlang 对照）
// single-thread fallback: xlang thread API not yet available.
// Because there is only one thread, no lock is needed — the shared counter
// is updated M*N times without contention, which is the arithmetic lower
// bound of the C/Zig mutex-protected version.

/** Internal function `main`.
 * Single-thread fallback for the mutex-contention benchmark.
 *
 * The C/Zig version spawns M=4 threads that each, under a shared mutex,
 * increment a counter N_ITERS=10000000 times (final = M*N = 40000000).
 * With no threading available in xlang, this runs the same M*N increments
 * inline with no lock (single thread => no contention => no mutex needed).
 * The arithmetic outcome equals the serial lower bound of the contended
 * version, so cross-language comparison of the pure-add cost is meaningful.
 *
 * @return i32 — low byte of counter (cast), anti-constant-folding sink
 */
function main(): i32 {
  let m: i32 = 4;
  let n_iters: i64 = 10000000;
  let counter: i64 = 0;
  let t: i32 = 0;
  while (t < m) {
    let i: i64 = 0;
    while (i < n_iters) {
      counter = counter + 1;
      i = i + 1;
    }
    t = t + 1;
  }
  return (counter & 255) as i32;
}
