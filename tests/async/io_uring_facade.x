// STD-049：std.async io_uring 完整路径门面烟测
const async_mod = import("std.async");
const ctx_mod = import("std.context");

function main(): i32 {
  // io_uring 探测（macOS/无 liburing 时为 0，不强制为 1）
  let avail: i32 = async_mod.uring_ok();
  if (avail != 0 && avail != 1) { return 1; }

  // 非法 submit 应失败
  let buf: u8 = 0;
  if (async_mod.read_async_fd(0, &buf, 0) >= 0) { return 2; }

  // 单轮 pump + poll_loop
  async_mod.pump();
  async_mod.scheduler_reset();
  if (async_mod.poll_loop(2) < 0) { return 3; }

  // CPS suspend_io 路径仍可用
  let phase: i32 = 0;
  if (async_mod.cps_suspend_io(&phase, 1) != 0) { return 4; }
  if (phase != 1) { return 5; }

  // Context 版 poll_loop
  let ctx: Context = ctx_mod.background();
  let rt: AsyncRuntime = async_mod.runtime(ctx);
  async_mod.bind_ctx(ctx);
  let pumped: i32 = async_mod.poll_loop_ctx(&rt, 4);
  if (pumped < 0) { return 6; }

  return 0;
}
