// async_spawn_v4_smoke.x — spawn + drain_until_idle codegen 烟测（-E grep，不跑 runtime）
extern function shux_async_queue_reset(): void;
extern function shux_async_run_drain_until_idle(): i32;

/** 带 i32 形参 seed 的最小 async（无 await，仅验证 spawn submit emit）。 */
async function echo_i32(x: i32): i32 {
  return x;
}

function main(): i32 {
  shux_async_queue_reset();
  spawn echo_i32(1);
  spawn echo_i32(2);
  return shux_async_run_drain_until_idle();
}
