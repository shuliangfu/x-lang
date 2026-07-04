// STD-090：std.async bind_ctx + cancel 传播烟测
const async_mod = import("std.async");
const context = import("std.context");
const task = import("std.task");

function main(): i32 {
  let bg: Context = context.background();
  let child: Context = context.with_cancel(bg);
  let live: Context = context.with_cancel(bg);
  let echo_fn: *u8 = task.echo_ptr();
  let zero: i64 = 0;

  if (echo_fn == 0) { return 1; }

  async_mod.bind_ctx(child);
  context.cancel(child);
  async_mod.scheduler_reset();
  if (async_mod.submit(echo_fn, 1) != -2) { return 2; }

  async_mod.scheduler_reset();
  async_mod.bind_ctx(live);
  if (async_mod.submit(echo_fn, 2) != 0) { return 3; }
  if (async_mod.submit(echo_fn, 3) != 0) { return 4; }
  context.cancel(live);
  if (async_mod.drain_idle() != async_mod.err_ctx_abort()) { return 5; }

  async_mod.scheduler_reset();
  async_mod.unbind_ctx();
  context.free(child);
  context.free(live);
  return 0;
}
