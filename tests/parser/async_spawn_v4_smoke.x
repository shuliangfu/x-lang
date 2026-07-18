// See implementation.
extern function shux_async_queue_reset(): void;
extern function shux_async_run_drain_until_idle(): i32;

/* See implementation. */
async function echo_i32(x: i32): i32 {
  return x;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  unsafe { shux_async_queue_reset(); }
  spawn echo_i32(1);
  spawn echo_i32(2);
  return unsafe { shux_async_run_drain_until_idle() };
}
