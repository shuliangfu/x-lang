// STD-118：std.trace io/net/async 关键路径挂钩烟测
const trace = import("std.trace");
const context = import("std.context");
const async_mod = import("std.async");
const io = import("std.io");

function main(): i32 {
  let zero: i64 = 0;
  let tr: Trace = trace.new();
  let ctx: Context = context.background();
  let ctx_bare: Context = context.background();
  let root: Span = Span { id: zero };
  let rt: AsyncRuntime = async_mod.runtime(ctx);
  let msg: u8[1] = [88];
  let cnt_before: i32 = 0;
  let cnt_after: i32 = 0;
  let n_root: u8[4] = [114, 111, 111, 116];

  if (tr.handle == zero) { return 1; }
  if (trace.attach(ctx, tr) != 0) { return 2; }
  root = trace.start(&tr, zero, &n_root[0], 4);
  if (root.id == zero) { return 3; }

  cnt_before = trace.count(&tr);
  if (trace.io_write(ctx, io.stderr(), &msg[0], 1) < 0) { return 4; }
  async_mod.runtime_reset(&rt);
  if (trace.async_drain(ctx, &rt) < 0) { return 5; }
  cnt_after = trace.count(&tr);
  if (cnt_after <= cnt_before) { return 6; }

  if (trace.io_write(ctx_bare, io.stderr(), &msg[0], 1) < 0) { return 7; }
  if (trace.hooks_smoke() != 0) { return 8; }

  if (trace.end(&tr, root) != trace.err_ok()) { return 9; }
  trace.free(&tr);
  context.free(ctx);
  context.free(ctx_bare);
  return 0;
}
