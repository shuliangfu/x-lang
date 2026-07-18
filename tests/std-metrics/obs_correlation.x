// See implementation.
const metrics = import("std.metrics");
const trace = import("std.trace");
const context = import("std.context");

/** Internal function `buf_prefix_eq`.
 * Implements `buf_prefix_eq`.
 * @param buf *u8
 * @param buf_len i32
 * @param expect *u8
 * @param expect_len i32
 * @return i32
 */
function buf_prefix_eq(buf: *u8, buf_len: i32, expect: *u8, expect_len: i32): i32 {
  let i: i32 = 0;
  if (buf_len < expect_len) { return 0; }
  while (i < expect_len) {
    if (buf[i] != expect[i]) { return 0; }
    i = i + 1;
  }
  return 1;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let tr: Trace = trace.new();
  let sp: Span = Span { id: 0 };
  let obs: ObservabilityCtx = metrics.obs_ctx_empty();
  let obs2: ObservabilityCtx = metrics.obs_ctx_empty();
  let ctx: Context = context.background();
  let kv: u8[128] = [];
  let kv_len: i32 = 0;
  let lbl: Label = metrics.label_empty();
  let reg: Registry = metrics.registry_new();
  let out: u8[256] = [];
  let n: i32 = 0;
  let req: u8[14] = [114, 101, 113, 117, 101, 115, 116, 115, 95, 116, 111, 116, 97, 108];
  let meth: u8[6] = [109, 101, 116, 104, 111, 100];
  let get: u8[3] = [71, 69, 84];
  let span_name: u8[4] = [114, 111, 111, 116];
  let kv_pre: u8[9] = [116, 114, 97, 99, 101, 95, 105, 100, 61];

  sp = trace.start(&tr, 0, &span_name[0], 4);
  if (sp.id == 0) { return 1; }

  obs = metrics.obs_ctx_from_trace(&tr, sp);
  if (obs.trace_id_len != 32) { return 2; }
  if (obs.span_id_len <= 0) { return 3; }

  kv_len = metrics.obs_ctx_format_log_kv(&obs, &kv[0], 128);
  if (kv_len <= 0) { return 4; }
  if (buf_prefix_eq(&kv[0], kv_len, &kv_pre[0], 9) == 0) { return 5; }

  if (metrics.obs_ctx_attach_context(ctx, obs) != 0) { return 6; }
  obs2 = metrics.obs_ctx_from_context(ctx, &tr);
  if (obs2.span_id != obs.span_id) { return 7; }
  if (obs2.trace_id_len != 32) { return 8; }

  if (metrics.obs_ctx_apply_trace_label(&obs, &lbl) != 0) { return 9; }
  if (metrics.counter(&reg, &req[0], 14, &lbl.key[0], lbl.key_len, &lbl.val[0], lbl.val_len) != 0) {
    return 10;
  }
  metrics.counter_inc(&reg.c0, 1);
  n = metrics.export_prometheus(&reg, &out[0], 256);
  if (n <= 0) { return 11; }

  if (trace.end(&tr, sp) != 0) { return 12; }
  trace.free(&tr);
  return 0;
}
