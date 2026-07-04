// async_switch_sched.x — B-ASYNC：scheduler.c computed-goto ping-pong（A2）
// 不 import("std.async")（避免 wait_completion→io 链）；由 run-perf-async.sh 链 scheduler.o。
extern function shux_async_coop_pingpong_jmp(rounds: i64): i64;

function main(): i32 {
  let rounds: i64 = 1000000;
  let total: i64 = shux_async_coop_pingpong_jmp(rounds);
  if (total != 2000000) { return 1; }
  return 0;
}
