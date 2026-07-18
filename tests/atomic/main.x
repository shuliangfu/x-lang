// tests/atomic/main.x — std.atomic
// See implementation.
// See implementation.
// See implementation.

const atomic = import("std.atomic");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  // i32
  let x: i32 = 0;
  if (atomic.load(&x) != 0) { return 1; }
  atomic.store(&x, 10);
  if (atomic.load(&x) != 10) { return 2; }
  atomic.fetch_add(&x, 5);
  if (atomic.load(&x) != 15) { return 3; }
  atomic.fetch_sub(&x, 3);
  if (atomic.load(&x) != 12) { return 4; }
  let exp: i32 = 12;
  atomic.compare_exchange(&x, &exp, 100);
  if (atomic.load(&x) != 100) { return 5; }
  let exp2: i32 = 99;
  atomic.compare_exchange(&x, &exp2, 0);
  if (atomic.load(&x) != 100) { return 6; }
  if (exp2 != 100) { return 7; }

  // u32
  let u: u32 = 0;
  atomic.store(&u, 42);
  if (atomic.load(&u) != 42) { return 8; }
  atomic.fetch_add(&u, 8);
  if (atomic.load(&u) != 50) { return 9; }

  // i64
  let y: i64 = 0;
  atomic.store(&y, 1000);
  if (atomic.load(&y) != 1000) { return 10; }
  atomic.fetch_add(&y, 500);
  if (atomic.load(&y) != 1500) { return 11; }

  return 0;
}
