// See implementation.
const test = import("std.test");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  // See implementation.
  let st: u32 = test.fuzz_seed();
  let a: u32 = test.fuzz_next(&st);
  let b: u32 = test.fuzz_next(&st);
  if (a == 0 || b == 0) { return 1; }
  let st2: u32 = test.fuzz_seed();
  if (test.fuzz_next(&st2) != a) { return 2; }
  if (test.fuzz_next(&st2) != b) { return 3; }
  // See implementation.
  let ns: i64 = test.bench_run_noop(64);
  if (ns < 0) { return 4; }
  let name: u8[4] = [108, 111, 111, 112];
  if (test.bench_report(&name[0], 4, ns) != 0) { return 5; }
  // See implementation.
  if (test.fuzz_run_noop(32) != 0) { return 6; }
  return 0;
}
