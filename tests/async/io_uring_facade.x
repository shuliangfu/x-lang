// See implementation.
const async_mod = import("std.async");
const ctx_mod = import("std.context");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  // See implementation.
  let avail: i32 = async_mod.uring_ok();
  if (avail != 0 && avail != 1) { return 1; }

  // See implementation.
  let buf: u8 = 0;
  if (async_mod.read_async_fd(0, &buf, 0) >= 0) { return 2; }

  // See implementation.
  async_mod.pump();
  async_mod.scheduler_reset();
  if (async_mod.poll_loop(2) < 0) { return 3; }

  // See implementation.
  let phase: i32 = 0;
  if (async_mod.cps_suspend_io(&phase, 1) != 0) { return 4; }
  if (phase != 1) { return 5; }

  // See implementation.
  let ctx: Context = ctx_mod.background();
  let rt: AsyncRuntime = async_mod.runtime(ctx);
  async_mod.bind_ctx(ctx);
  let pumped: i32 = async_mod.poll_loop_ctx(&rt, 4);
  if (pumped < 0) { return 6; }

  return 0;
}
