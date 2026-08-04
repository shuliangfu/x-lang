// cc05_thread_affinity.x — thread affinity / CPU pinning variance benchmark (xlang)
// single-thread fallback: xlang thread API not yet available.
//
// Algorithm: run the same N=100000000 LCG accumulation as the C/Zig
// versions, R=5 rounds. No thread spawn, no CPU pinning, no timing —
// the arithmetic workload is preserved for cross-language comparison.
// Returns XOR of per-round accumulators, low byte.

/** Internal function `main`.
 * Single-thread fallback for the thread-affinity variance benchmark.
 *
 * Iterates r over [0, ROUNDS). For each r, computes the same N-step LCG
 * accumulation as the C/Zig worker (s ^= i*1103515245+12345 for i in
 * [0, N)), then XORs the per-round result into a sink.
 *
 * Rationale: xlang has no pthread/std.Thread binding or CPU-affinity API
 * yet, so genuine thread spawn + pinning is not expressible. The
 * arithmetic workload is preserved exactly to keep the cross-language
 * comparison meaningful.
 *
 * @return i32 — low byte of the XOR sink (anti-constant-folding return)
 */
function main(): i32 {
  let n: i32 = 100000000;
  let rounds: i32 = 5;
  let sink: i32 = 0;
  let r: i32 = 0;
  while (r < rounds) {
    let s: i32 = 0;
    let i: i32 = 0;
    while (i < n) {
      let t: i32 = i * 1103515245 + 12345;
      s = s ^ t;
      i = i + 1;
    }
    sink = sink ^ s;
    r = r + 1;
  }
  return (sink & 255) as i32;
}
