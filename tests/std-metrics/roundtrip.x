// STD-078：std.metrics Counter/Gauge/Histogram + Prometheus 导出烟测
const metrics = import("std.metrics");

/** 检查 out 前缀是否包含 expect 子串；1 包含。 */
function buf_has_prefix(out: *u8, out_len: i32, expect: *u8, expect_len: i32): i32 {
  let i: i32 = 0;
  if (out_len < expect_len) { return 0; }
  while (i < expect_len) {
    if (out[i] != expect[i]) { return 0; }
    i = i + 1;
  }
  return 1;
}

function main(): i32 {
  let reg: Registry = metrics.registry_new();
  let out: u8[512] = [];
  let n: i32 = 0;
  let req: u8[14] = [114, 101, 113, 117, 101, 115, 116, 115, 95, 116, 111, 116, 97, 108];
  let mem: u8[12] = [109, 101, 109, 95, 98, 121, 116, 101, 115];
  let lat: u8[11] = [108, 97, 116, 101, 110, 99, 121, 95, 109, 115];
  let meth: u8[6] = [109, 101, 116, 104, 111, 100];
  let get: u8[3] = [71, 69, 84];
  let empty: u8[1] = [0];

  if (metrics.counter(&reg, &req[0], 14, &meth[0], 6, &get[0], 3) != 0) { return 1; }
  if (metrics.gauge(&reg, &mem[0], 12, &empty[0], 0, &empty[0], 0) != 0) { return 2; }
  if (metrics.histogram(&reg, &lat[0], 11, &empty[0], 0, &empty[0], 0) != 0) { return 3; }

  metrics.counter_inc(&reg.c0, 3);
  if (metrics.counter_snapshot(&reg.c0) != 3) { return 4; }

  metrics.gauge_set(&reg.g0, 100);
  if (metrics.gauge_snapshot(&reg.g0) != 100) { return 5; }

  metrics.histogram_observe(&reg.h0, 7);
  if (reg.h0.count != 1) { return 6; }

  n = metrics.export_prometheus(&reg, &out[0], 512);
  if (n <= 0) { return 7; }
  if (buf_has_prefix(&out[0], n, &req[0], 14) == 0) { return 8; }

  return 0;
}
