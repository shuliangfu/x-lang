// See implementation.
const atomic = import("std.atomic");
const debug = import("core.debug");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let data: i32 = 0;
  let ready: i32 = 0;
  atomic.store(&data, 42);
  atomic.fence_release();
  atomic.store(&ready, 1);
  atomic.fence_seq_cst();
  if (atomic.load(&ready) != 1) {
    return 1;
  }
  atomic.fence_acquire();
  debug.assert_eq_i32(atomic.load(&data), 42);
  return 0;
}
