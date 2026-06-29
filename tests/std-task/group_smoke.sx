// STD-089：std.task TaskGroup + JoinSet + context 取消烟测
const task = import("std.task");
const context = import("std.context");
const async_mod = import("std.async");

function main(): i32 {
  let zero: i64 = 0;
  let tg: TaskGroup = task.new(4);
  let js: JoinSet = task.set_new(2);
  let ctx: Context = context.background();
  let child: Context = context.with_cancel(ctx);
  let echo_fn: *u8 = task.echo_ptr();
  let total: i32 = 0;
  let r: i32 = 0;

  if (tg.handle == zero || js.handle == zero) { return 1; }
  if (echo_fn == 0) { return 2; }

  task.bind(&tg, child);
  async_mod.scheduler_reset();

  if (task.spawn(&tg, echo_fn, 2) != task.err_ok()) { return 3; }
  if (task.spawn(&tg, echo_fn, 3) != task.err_ok()) { return 4; }
  if (task.check_leak(&tg) != task.err_leak()) { return 5; }
  total = task.join(&tg);
  if (total != 50) { return 6; }

  async_mod.scheduler_reset();
  if (task.set_spawn(&js, echo_fn, 4) != task.err_ok()) { return 7; }
  r = task.set_join(&js);
  if (r != 40) { return 8; }

  context.cancel(child);
  async_mod.scheduler_reset();
  if (task.spawn(&tg, echo_fn, 1) != task.err_cancelled()) { return 9; }

  task.free(&tg);
  task.set_free(&js);
  context.free(child);
  return 0;
}
