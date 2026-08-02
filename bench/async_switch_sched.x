// async_switch_sched.x — B-ASYNC：scheduler.c computed-goto ping-pong（A2）
// See implementation.
extern function xlang_async_coop_pingpong_jmp(rounds: i64): i64;

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let rounds: i64 = 1000000;
  let total: i64 = unsafe { xlang_async_coop_pingpong_jmp(rounds) };
  if (total != 2000000) { return 1; }
  return 0;
}
