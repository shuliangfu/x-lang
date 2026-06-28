// STD-041：Future/Poll 手动运行时烟测
const async_mod = import("std.async");

function main(): i32 {
  let fut: Future = async_mod.future_new();
  let pr: i32 = async_mod.future_poll(&fut);
  if (pr != async_mod.POLL_PENDING) { return 1; }
  async_mod.future_complete(&fut, 99);
  pr = async_mod.future_poll(&fut);
  if (pr != async_mod.POLL_READY) { return 2; }
  let st: i32 = async_mod.future_wait(&fut, 4);
  if (st != async_mod.POLL_READY) { return 3; }
  let _drain: i32 = async_mod.poll_loop(2);
  let out: i32 = 0;
  if (async_mod.future_take(&fut, &out) != 0) { return 4; }
  if (out != 99) { return 5; }
  return async_mod.future_smoke();
}
