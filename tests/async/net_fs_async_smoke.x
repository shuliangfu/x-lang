// STD-049 / #79：std.async net/fs fd 异步读写 + poll_loop_ctx 烟测
const async_mod = import("std.async");
const ctx_mod = import("std.context");

function main(): i32 {
  if (async_mod.net_fs_async_smoke() != 0) { return 1; }

  let ctx: Context = ctx_mod.background();
  let rt: AsyncRuntime = async_mod.runtime(ctx);
  async_mod.bind_ctx(ctx);

  let buf: u8 = 0;
  if (async_mod.await_read_fd(&rt, -1, &buf, 1, 4) >= 0) { return 2; }
  if (async_mod.net_read_async(&rt, -1, &buf, 1, 4) >= 0) { return 3; }
  if (async_mod.fs_read_async(&rt, -1, &buf, 1, 4) >= 0) { return 4; }

  let pumped: i32 = async_mod.poll_loop_ctx(&rt, 2);
  if (pumped < 0) { return 5; }

  return 0;
}
