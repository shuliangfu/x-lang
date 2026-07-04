// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// std.metrics — 统一可观测性指标（STD-078）
//
// 【文件职责】
// Counter / Gauge / Histogram 注册与快照；单 label 维度；Prometheus 文本导出；
// 与 std.atomic 协作保证 counter/gauge 并发安全。
//
// 【对标】Prometheus client 最小子集、Go expvar + metrics 组合风格。

const fmt = import("std.fmt");
const atomic = import("std.atomic");
const context = import("std.context");
const encoding = import("std.encoding");
const trace = import("std.trace");

/** 成功。 */
function err_ok(): i32 { return 0; }
/** 注册表已满。 */
function err_full(): i32 { return -1; }
/** 索引或名称无效。 */
function err_not_found(): i32 { return -2; }
/** 输出缓冲不足。 */
function err_buffer(): i32 { return -3; }

/** 指标种类：单调递增计数。 */
function metric_kind_counter(): i32 { return 1; }
/** 指标种类：可增可减瞬时值。 */
function metric_kind_gauge(): i32 { return 2; }
/** 指标种类：分桶分布。 */
function metric_kind_histogram(): i32 { return 3; }

/** 默认直方图桶上界（毫秒等任意单位，最后一档为 +Inf）。 */
function histogram_default_bucket_count(): i32 { return 5; }

/** 单 label 键值对（v1 每指标至多一对）。 */
allow(padding) struct Label {
  key_len: i32;
  val_len: i32;
  key: u8[32];
  val: u8[32];
}

/** 计数器：只增不减。 */
allow(padding) struct Counter {
  name_len: i32;
  name: u8[48];
  label: Label;
  value: i64;
}

/** 仪表盘：可 set/add。 */
allow(padding) struct Gauge {
  name_len: i32;
  name: u8[48];
  label: Label;
  value: i64;
}

/** 直方图：固定 5 桶 + sum/count。 */
allow(padding) struct Histogram {
  name_len: i32;
  name: u8[48];
  label: Label;
  bucket_count: i32;
  bucket_upper: i64[5];
  bucket_counts: i64[5];
  sum: i64;
  count: i64;
}

/** 本地注册表（各类型最多 4 项，供批量导出）。 */
allow(padding) struct Registry {
  counter_n: i32;
  gauge_n: i32;
  hist_n: i32;
  c0: Counter;
  c1: Counter;
  c2: Counter;
  c3: Counter;
  g0: Gauge;
  g1: Gauge;
  g2: Gauge;
  g3: Gauge;
  h0: Histogram;
  h1: Histogram;
  h2: Histogram;
  h3: Histogram;
}

/** 复制字节到固定缓冲；返回写入长度，失败 -1。 */
function copy_bytes(dst: *u8, dst_cap: i32, src: *u8, src_len: i32): i32 {
  let i: i32 = 0;
  if (dst == 0 || src == 0 || dst_cap <= 0) { return -1; }
  if (src_len >= dst_cap) { src_len = dst_cap - 1; }
  while (i < src_len) {
    dst[i] = src[i];
    i = i + 1;
  }
  dst[i] = 0;
  return src_len;
}

/** 初始化空 label。 */
function label_empty(): Label {
  return Label { key_len: 0, val_len: 0, key: [], val: [] };
}

/** 设置 label 键值（长度截断至 31）。 */
function label_set(l: *Label, key: *u8, key_len: i32, val: *u8, val_len: i32): i32 {
  if (l == 0) { return err_not_found(); }
  l.key_len = copy_bytes(&l.key[0], 32, key, key_len);
  l.val_len = copy_bytes(&l.val[0], 32, val, val_len);
  if (l.key_len < 0 || l.val_len < 0) { return err_buffer(); }
  return err_ok();
}

/** 新建空注册表。 */
function registry_new(): Registry {
  return Registry {
    counter_n: 0, gauge_n: 0, hist_n: 0,
    c0: Counter { name_len: 0, name: [], label: label_empty(), value: 0 as i64 },
    c1: Counter { name_len: 0, name: [], label: label_empty(), value: 0 as i64 },
    c2: Counter { name_len: 0, name: [], label: label_empty(), value: 0 as i64 },
    c3: Counter { name_len: 0, name: [], label: label_empty(), value: 0 as i64 },
    g0: Gauge { name_len: 0, name: [], label: label_empty(), value: 0 as i64 },
    g1: Gauge { name_len: 0, name: [], label: label_empty(), value: 0 as i64 },
    g2: Gauge { name_len: 0, name: [], label: label_empty(), value: 0 as i64 },
    g3: Gauge { name_len: 0, name: [], label: label_empty(), value: 0 as i64 },
    h0: Histogram { name_len: 0, name: [], label: label_empty(), bucket_count: 0, bucket_upper: [], bucket_counts: [], sum: 0 as i64, count: 0 as i64 },
    h1: Histogram { name_len: 0, name: [], label: label_empty(), bucket_count: 0, bucket_upper: [], bucket_counts: [], sum: 0 as i64, count: 0 as i64 },
    h2: Histogram { name_len: 0, name: [], label: label_empty(), bucket_count: 0, bucket_upper: [], bucket_counts: [], sum: 0 as i64, count: 0 as i64 },
    h3: Histogram { name_len: 0, name: [], label: label_empty(), bucket_count: 0, bucket_upper: [], bucket_counts: [], sum: 0 as i64, count: 0 as i64 }
  };
}

/** 初始化 Counter 名称与 label。 */
function counter_init(c: *Counter, name: *u8, name_len: i32, lkey: *u8, lk_len: i32, lval: *u8, lv_len: i32): i32 {
  if (c == 0) { return err_not_found(); }
  c.name_len = copy_bytes(&c.name[0], 48, name, name_len);
  c.value = 0 as i64;
  if (c.name_len < 0) { return err_buffer(); }
  return label_set(&c.label, lkey, lk_len, lval, lv_len);
}

/** 递增 Counter（原子 add）。 */
function counter_inc(c: *Counter, delta: i64): i32 {
  if (c == 0) { return err_not_found(); }
  if (delta <= (0 as i64)) { return err_ok(); }
  atomic.fetch_add(&c.value, delta);
  return err_ok();
}

/** 读取 Counter 快照。 */
function counter_snapshot(c: *Counter): i64 {
  if (c == 0) { return 0; }
  return atomic.load(&c.value);
}

/** 初始化 Gauge。 */
function gauge_init(g: *Gauge, name: *u8, name_len: i32, lkey: *u8, lk_len: i32, lval: *u8, lv_len: i32): i32 {
  if (g == 0) { return err_not_found(); }
  g.name_len = copy_bytes(&g.name[0], 48, name, name_len);
  g.value = 0 as i64;
  if (g.name_len < 0) { return err_buffer(); }
  return label_set(&g.label, lkey, lk_len, lval, lv_len);
}

/** 设置 Gauge 值。 */
function gauge_set(g: *Gauge, v: i64): i32 {
  if (g == 0) { return err_not_found(); }
  atomic.store(&g.value, v);
  return err_ok();
}

/** Gauge 加减。 */
function gauge_add(g: *Gauge, delta: i64): i32 {
  if (g == 0) { return err_not_found(); }
  atomic.fetch_add(&g.value, delta);
  return err_ok();
}

/** 读取 Gauge 快照。 */
function gauge_snapshot(g: *Gauge): i64 {
  if (g == 0) { return 0; }
  return atomic.load(&g.value);
}

/** 安装默认直方图桶：1, 5, 10, 50, +Inf。 */
function histogram_init_default_buckets(h: *Histogram): void {
  let inf: i64 = 9223372036854775807;
  if (h == 0) { return; }
  h.bucket_count = histogram_default_bucket_count();
  h.bucket_upper[0] = 1 as i64;
  h.bucket_upper[1] = 5 as i64;
  h.bucket_upper[2] = 10 as i64;
  h.bucket_upper[3] = 50 as i64;
  h.bucket_upper[4] = inf;
  h.bucket_counts[0] = 0 as i64;
  h.bucket_counts[1] = 0 as i64;
  h.bucket_counts[2] = 0 as i64;
  h.bucket_counts[3] = 0 as i64;
  h.bucket_counts[4] = 0 as i64;
  h.sum = 0 as i64;
  h.count = 0 as i64;
}

/** 初始化 Histogram 名称与 label。 */
function histogram_init(h: *Histogram, name: *u8, name_len: i32, lkey: *u8, lk_len: i32, lval: *u8, lv_len: i32): i32 {
  if (h == 0) { return err_not_found(); }
  h.name_len = copy_bytes(&h.name[0], 48, name, name_len);
  histogram_init_default_buckets(h);
  if (h.name_len < 0) { return err_buffer(); }
  return label_set(&h.label, lkey, lk_len, lval, lv_len);
}

/** 记录一次观测值（写入首个匹配桶并更新 sum/count）。 */
function histogram_observe(h: *Histogram, v: i64): i32 {
  let i: i32 = 0;
  let placed: i32 = 0;
  if (h == 0) { return err_not_found(); }
  if (v < (0 as i64)) { v = 0 as i64; }
  while (i < h.bucket_count) {
    if (placed == 0 && v <= h.bucket_upper[i]) {
      h.bucket_counts[i] = h.bucket_counts[i] + (1 as i64);
      placed = 1;
    }
    i = i + 1;
  }
  h.sum = h.sum + v;
  h.count = h.count + (1 as i64);
  return err_ok();
}

/** 注册 Counter 到 Registry；返回索引或负错误码。 */
function counter(reg: *Registry, name: *u8, name_len: i32, lkey: *u8, lk_len: i32, lval: *u8, lv_len: i32): i32 {
  let idx: i32 = 0;
  if (reg == 0) { return err_not_found(); }
  if (reg.counter_n >= 4) { return err_full(); }
  idx = reg.counter_n;
  if (idx == 0) { counter_init(&reg.c0, name, name_len, lkey, lk_len, lval, lv_len); }
  if (idx == 1) { counter_init(&reg.c1, name, name_len, lkey, lk_len, lval, lv_len); }
  if (idx == 2) { counter_init(&reg.c2, name, name_len, lkey, lk_len, lval, lv_len); }
  if (idx == 3) { counter_init(&reg.c3, name, name_len, lkey, lk_len, lval, lv_len); }
  reg.counter_n = reg.counter_n + 1;
  return idx;
}

/** 注册 Gauge。 */
function gauge(reg: *Registry, name: *u8, name_len: i32, lkey: *u8, lk_len: i32, lval: *u8, lv_len: i32): i32 {
  let idx: i32 = 0;
  if (reg == 0) { return err_not_found(); }
  if (reg.gauge_n >= 4) { return err_full(); }
  idx = reg.gauge_n;
  if (idx == 0) { gauge_init(&reg.g0, name, name_len, lkey, lk_len, lval, lv_len); }
  if (idx == 1) { gauge_init(&reg.g1, name, name_len, lkey, lk_len, lval, lv_len); }
  if (idx == 2) { gauge_init(&reg.g2, name, name_len, lkey, lk_len, lval, lv_len); }
  if (idx == 3) { gauge_init(&reg.g3, name, name_len, lkey, lk_len, lval, lv_len); }
  reg.gauge_n = reg.gauge_n + 1;
  return idx;
}

/** 注册 Histogram。 */
function histogram(reg: *Registry, name: *u8, name_len: i32, lkey: *u8, lk_len: i32, lval: *u8, lv_len: i32): i32 {
  let idx: i32 = 0;
  if (reg == 0) { return err_not_found(); }
  if (reg.hist_n >= 4) { return err_full(); }
  idx = reg.hist_n;
  if (idx == 0) { histogram_init(&reg.h0, name, name_len, lkey, lk_len, lval, lv_len); }
  if (idx == 1) { histogram_init(&reg.h1, name, name_len, lkey, lk_len, lval, lv_len); }
  if (idx == 2) { histogram_init(&reg.h2, name, name_len, lkey, lk_len, lval, lv_len); }
  if (idx == 3) { histogram_init(&reg.h3, name, name_len, lkey, lk_len, lval, lv_len); }
  reg.hist_n = reg.hist_n + 1;
  return idx;
}

/** 追加 slice 到 out；返回新 offset，失败 -1。 */
function extend(out: *u8, cap: i32, off: i32, src: *u8, n: i32): i32 {
  let i: i32 = 0;
  if (out == 0 || src == 0) { return -1; }
  if (off < 0 || off + n >= cap) { return -1; }
  while (i < n) {
    out[off + i] = src[i];
    i = i + 1;
  }
  return off + n;
}

/** 追加单字节；返回新 offset，失败 -1。 */
function append_byte(out: *u8, cap: i32, off: i32, b: u8): i32 {
  let tmp: u8[1] = [0];
  tmp[0] = b;
  return extend(out, cap, off, &tmp[0], 1);
}

/** 追加 label 片段 key="val"（不含花括号）；无 label 时返回原 offset。 */
function append_label_suffix(out: *u8, cap: i32, off: i32, l: *Label): i32 {
  let o: i32 = off;
  if (l == 0 || l.key_len <= 0) { return o; }
  o = extend(out, cap, o, &l.key[0], l.key_len);
  if (o < 0) { return -1; }
  o = append_byte(out, cap, o, 61);
  if (o < 0) { return -1; }
  o = append_byte(out, cap, o, 34);
  if (o < 0) { return -1; }
  o = extend(out, cap, o, &l.val[0], l.val_len);
  if (o < 0) { return -1; }
  o = append_byte(out, cap, o, 34);
  return o;
}

/** 导出单个 Counter 的 Prometheus 行。 */
function export_counter_prometheus(c: *Counter, out: *u8, cap: i32, off: i32): i32 {
  let o: i32 = off;
  let v: i64 = 0;
  if (c == 0) { return off; }
  o = extend(out, cap, o, &c.name[0], c.name_len);
  if (o < 0) { return -1; }
  if (c.label.key_len > 0) {
    o = append_byte(out, cap, o, 123);
    if (o < 0) { return -1; }
    o = append_label_suffix(out, cap, o, &c.label);
    if (o < 0) { return -1; }
    o = append_byte(out, cap, o, 125);
    if (o < 0) { return -1; }
  }
  o = append_byte(out, cap, o, 32);
  if (o < 0) { return -1; }
  v = counter_snapshot(c);
  o = fmt.append_to_buf(out, cap, o, v);
  if (o < 0) { return -1; }
  o = append_byte(out, cap, o, 10);
  return o;
}

/** 导出单个 Gauge 的 Prometheus 行。 */
function export_gauge_prometheus(g: *Gauge, out: *u8, cap: i32, off: i32): i32 {
  let o: i32 = off;
  let v: i64 = 0;
  if (g == 0) { return off; }
  o = extend(out, cap, o, &g.name[0], g.name_len);
  if (o < 0) { return -1; }
  if (g.label.key_len > 0) {
    o = append_byte(out, cap, o, 123);
    if (o < 0) { return -1; }
    o = append_label_suffix(out, cap, o, &g.label);
    if (o < 0) { return -1; }
    o = append_byte(out, cap, o, 125);
    if (o < 0) { return -1; }
  }
  o = append_byte(out, cap, o, 32);
  if (o < 0) { return -1; }
  v = gauge_snapshot(g);
  o = fmt.append_to_buf(out, cap, o, v);
  if (o < 0) { return -1; }
  o = append_byte(out, cap, o, 10);
  return o;
}

/** 导出 Histogram（累积桶 + sum + count）。 */
function export_histogram_prometheus(h: *Histogram, out: *u8, cap: i32, off: i32): i32 {
  let o: i32 = off;
  let i: i32 = 0;
  let cum: i64 = 0;
  let suffix: u8[7] = [95, 98, 117, 99, 107, 101, 116];
  let lek: u8[3] = [108, 101, 61];
  let inf: u8[4] = [43, 73, 110, 102];
  let sum_s: u8[4] = [95, 115, 117, 109];
  let cnt_s: u8[6] = [95, 99, 111, 117, 110, 116];
  if (h == 0) { return off; }
  while (i < h.bucket_count) {
    cum = cum + h.bucket_counts[i];
    o = extend(out, cap, o, &h.name[0], h.name_len);
    if (o < 0) { return -1; }
    o = extend(out, cap, o, &suffix[0], 7);
    if (o < 0) { return -1; }
    o = append_byte(out, cap, o, 123);
    if (o < 0) { return -1; }
    o = append_label_suffix(out, cap, o, &h.label);
    if (o < 0) { return -1; }
    if (h.label.key_len > 0) {
      o = append_byte(out, cap, o, 44);
      if (o < 0) { return -1; }
    }
    o = extend(out, cap, o, &lek[0], 3);
    if (o < 0) { return -1; }
    o = append_byte(out, cap, o, 34);
    if (o < 0) { return -1; }
    if (i + 1 == h.bucket_count) {
      o = extend(out, cap, o, &inf[0], 4);
    } else {
      o = fmt.append_to_buf(out, cap, o, h.bucket_upper[i]);
    }
    if (o < 0) { return -1; }
    o = append_byte(out, cap, o, 34);
    if (o < 0) { return -1; }
    o = append_byte(out, cap, o, 125);
    if (o < 0) { return -1; }
    o = append_byte(out, cap, o, 32);
    if (o < 0) { return -1; }
    o = fmt.append_to_buf(out, cap, o, cum);
    if (o < 0) { return -1; }
    o = append_byte(out, cap, o, 10);
    if (o < 0) { return -1; }
    i = i + 1;
  }
  o = extend(out, cap, o, &h.name[0], h.name_len);
  if (o < 0) { return -1; }
  o = extend(out, cap, o, &sum_s[0], 4);
  if (o < 0) { return -1; }
  o = append_byte(out, cap, o, 32);
  if (o < 0) { return -1; }
  o = fmt.append_to_buf(out, cap, o, h.sum);
  if (o < 0) { return -1; }
  o = append_byte(out, cap, o, 10);
  if (o < 0) { return -1; }
  o = extend(out, cap, o, &h.name[0], h.name_len);
  if (o < 0) { return -1; }
  o = extend(out, cap, o, &cnt_s[0], 6);
  if (o < 0) { return -1; }
  o = append_byte(out, cap, o, 32);
  if (o < 0) { return -1; }
  o = fmt.append_to_buf(out, cap, o, h.count);
  if (o < 0) { return -1; }
  o = append_byte(out, cap, o, 10);
  return o;
}

/** 导出 Registry 内全部指标为 Prometheus 文本；返回总长度。 */
function export_prometheus(reg: *Registry, out: *u8, cap: i32): i32 {
  let o: i32 = 0;
  let i: i32 = 0;
  if (reg == 0 || out == 0 || cap <= 0) { return err_buffer(); }
  while (i < reg.counter_n) {
    if (i == 0) { o = export_counter_prometheus(&reg.c0, out, cap, o); }
    if (i == 1) { o = export_counter_prometheus(&reg.c1, out, cap, o); }
    if (i == 2) { o = export_counter_prometheus(&reg.c2, out, cap, o); }
    if (i == 3) { o = export_counter_prometheus(&reg.c3, out, cap, o); }
    if (o < 0) { return err_buffer(); }
    i = i + 1;
  }
  i = 0;
  while (i < reg.gauge_n) {
    if (i == 0) { o = export_gauge_prometheus(&reg.g0, out, cap, o); }
    if (i == 1) { o = export_gauge_prometheus(&reg.g1, out, cap, o); }
    if (i == 2) { o = export_gauge_prometheus(&reg.g2, out, cap, o); }
    if (i == 3) { o = export_gauge_prometheus(&reg.g3, out, cap, o); }
    if (o < 0) { return err_buffer(); }
    i = i + 1;
  }
  i = 0;
  while (i < reg.hist_n) {
    if (i == 0) { o = export_histogram_prometheus(&reg.h0, out, cap, o); }
    if (i == 1) { o = export_histogram_prometheus(&reg.h1, out, cap, o); }
    if (i == 2) { o = export_histogram_prometheus(&reg.h2, out, cap, o); }
    if (i == 3) { o = export_histogram_prometheus(&reg.h3, out, cap, o); }
    if (o < 0) { return err_buffer(); }
    i = i + 1;
  }
  return o;
}

/* --- STD-117：与 std.log / std.trace 统一观测上下文 --- */

/** 统一观测上下文：trace_id + span_id 十六进制（供 log KV / metrics label）。 */
allow(padding) struct ObservabilityCtx {
  trace_handle: i64;
  span_id: i64;
  trace_id_len: i32;
  span_id_len: i32;
  trace_id_hex: u8[33];
  span_id_hex: u8[17];
}

/** Context value bag 键 "trace"（与 std.trace.attach_to_context 一致）。 */
function obs_ctx_key_trace_len(): i32 { return 5; }

/** Context value bag 键 "span"（span_id i64）。 */
function obs_ctx_key_span_len(): i32 { return 4; }

/** 写入 trace 键到 buf；返回写入长度。 */
function obs_ctx_write_key_trace(buf: *u8, cap: i32): i32 {
  let k: u8[6] = [116, 114, 97, 99, 101, 0];
  return copy_bytes(buf, cap, &k[0], 5);
}

/** 写入 span 键到 buf；返回写入长度。 */
function obs_ctx_write_key_span(buf: *u8, cap: i32): i32 {
  let k: u8[5] = [115, 112, 97, 110, 0];
  return copy_bytes(buf, cap, &k[0], 4);
}

/** 空观测上下文。 */
function obs_ctx_empty(): ObservabilityCtx {
  let zero: i64 = 0;
  return ObservabilityCtx {
    trace_handle: zero,
    span_id: zero,
    trace_id_len: 0,
    span_id_len: 0,
    trace_id_hex: [],
    span_id_hex: [],
  };
}

/** 将 trace_id 16 字节编码为 32 字符 hex 写入 obs.trace_id_hex；返回长度。 */
function obs_encode_trace_id_hex(obs: *ObservabilityCtx, tid: *TraceId): i32 {
  let n: i32 = 0;
  if (obs == 0 || tid == 0) { return -1; }
  n = encoding.hex_encode(&tid.bytes[0], 16, &obs.trace_id_hex[0], 33);
  if (n != 32) { return -1; }
  obs.trace_id_hex[32] = 0;
  obs.trace_id_len = 32;
  return 32;
}

/** 将 span_id 编码为 hex 写入 obs.span_id_hex；返回长度。 */
function obs_encode_span_id_hex(obs: *ObservabilityCtx, span_id: i64): i32 {
  let n: i32 = 0;
  if (obs == 0) { return -1; }
  n = fmt.hex_to_buf(&obs.span_id_hex[0], 17, span_id as u64);
  if (n <= 0) { return -1; }
  obs.span_id_hex[n] = 0;
  obs.span_id_len = n;
  return n;
}

/** 从 Trace + Span 构建观测上下文。 */
function obs_ctx_from_trace(tr: *Trace, span: Span): ObservabilityCtx {
  let zero: i64 = 0;
  let obs: ObservabilityCtx = obs_ctx_empty();
  let tid: TraceId = TraceId { bytes: [] };
  if (tr == 0 || tr.handle == zero || span.id == zero) { return obs; }
  obs.trace_handle = tr.handle;
  obs.span_id = span.id;
  trace.id(tr, &tid);
  if (obs_encode_trace_id_hex(&obs, &tid) < 0) {
    return obs_ctx_empty();
  }
  if (obs_encode_span_id_hex(&obs, span.id) < 0) {
    return obs_ctx_empty();
  }
  return obs;
}

/** 将观测上下文写入 Context value bag（trace 句柄 + span_id）。 */
function obs_ctx_attach_context(ctx: Context, obs: ObservabilityCtx): i32 {
  let zero: i64 = 0;
  let ktrace: u8[8] = [];
  let kspan: u8[8] = [];
  if (obs.trace_handle == zero) { return err_not_found(); }
  if (obs_ctx_write_key_trace(&ktrace[0], 8) < 0) { return err_buffer(); }
  if (obs_ctx_write_key_span(&kspan[0], 8) < 0) { return err_buffer(); }
  if (context.set_value(ctx, &ktrace[0], obs.trace_handle) != 0) { return err_ok(); }
  if (context.set_value(ctx, &kspan[0], obs.span_id) != 0) { return err_ok(); }
  return err_ok();
}

/** 从 Context 恢复观测上下文；tr 用于读取 trace_id hex。 */
function obs_ctx_from_context(ctx: Context, tr: *Trace): ObservabilityCtx {
  let zero: i64 = 0;
  let obs: ObservabilityCtx = obs_ctx_empty();
  let h: i64 = zero;
  let sid: i64 = zero;
  let tid: TraceId = TraceId { bytes: [] };
  let ktrace: u8[8] = [];
  let kspan: u8[8] = [];
  if (obs_ctx_write_key_trace(&ktrace[0], 8) < 0) { return obs; }
  if (obs_ctx_write_key_span(&kspan[0], 8) < 0) { return obs; }
  if (context.get_value(ctx, &ktrace[0], &h) == 0) { return obs; }
  if (context.get_value(ctx, &kspan[0], &sid) == 0) { return obs; }
  obs.trace_handle = h;
  obs.span_id = sid;
  if (tr != 0 && tr.handle == h) {
    trace.id(tr, &tid);
    if (obs_encode_trace_id_hex(&obs, &tid) < 0) { return obs_ctx_empty(); }
  }
  if (obs_encode_span_id_hex(&obs, sid) < 0) { return obs_ctx_empty(); }
  return obs;
}

/**
 * 格式化为 log structured KV：`trace_id=<hex> span_id=<hex>`。
 * 可直接传入 std.log.structured_kv 的 kv 参数。
 */
function obs_ctx_format_log_kv(obs: *ObservabilityCtx, out: *u8, out_cap: i32): i32 {
  let tk: u8[9] = [116, 114, 97, 99, 101, 95, 105, 100, 61];
  let sk: u8[9] = [115, 112, 97, 110, 95, 105, 100, 61];
  let sp: u8[1] = [32];
  let o: i32 = 0;
  if (obs == 0 || out == 0 || out_cap <= 0) { return err_buffer(); }
  if (obs.trace_id_len <= 0 || obs.span_id_len <= 0) { return err_not_found(); }
  o = extend(out, out_cap, o, &tk[0], 9);
  if (o < 0) { return err_buffer(); }
  o = extend(out, out_cap, o, &obs.trace_id_hex[0], obs.trace_id_len);
  if (o < 0) { return err_buffer(); }
  o = extend(out, out_cap, o, &sp[0], 1);
  if (o < 0) { return err_buffer(); }
  o = extend(out, out_cap, o, &sk[0], 9);
  if (o < 0) { return err_buffer(); }
  o = extend(out, out_cap, o, &obs.span_id_hex[0], obs.span_id_len);
  if (o < 0) { return err_buffer(); }
  if (o >= out_cap) { return err_buffer(); }
  out[o] = 0;
  return o;
}

/**
 * 将 trace_id 写入 Label（键 trace_id）；值截断至 31 字节。
 * 高基数场景慎用；v1 用于 log/metrics/trace 字段对齐演示。
 */
function obs_ctx_apply_trace_label(obs: *ObservabilityCtx, lbl: *Label): i32 {
  let k: u8[9] = [116, 114, 97, 99, 101, 95, 105, 100, 0];
  let vlen: i32 = 0;
  if (obs == 0 || lbl == 0 || obs.trace_id_len <= 0) { return err_not_found(); }
  vlen = obs.trace_id_len;
  if (vlen > 31) { vlen = 31; }
  return label_set(lbl, &k[0], 8, &obs.trace_id_hex[0], vlen);
}
