// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// Full text: LICENSE.Apache-2.0

// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.

const fmt = import("std.fmt");
const atomic = import("std.atomic");
const context = import("std.context");
const encoding = import("std.encoding");
const trace = import("std.trace");

/** Exported function `err_ok`.
 * Implements `err_ok`.
 * @return i32
 */
export function err_ok(): i32 { return 0; }
/** Exported function `err_full`.
 * Implements `err_full`.
 * @return i32
 */
export function err_full(): i32 { return -1; }
/** Exported function `err_not_found`.
 * Implements `err_not_found`.
 * @return i32
 */
export function err_not_found(): i32 { return -2; }
/** Exported function `err_buffer`.
 * Implements `err_buffer`.
 * @return i32
 */
export function err_buffer(): i32 { return -3; }

/** Exported function `metric_kind_counter`.
 * Implements `metric_kind_counter`.
 * @return i32
 */
export function metric_kind_counter(): i32 { return 1; }
/** Exported function `metric_kind_gauge`.
 * Implements `metric_kind_gauge`.
 * @return i32
 */
export function metric_kind_gauge(): i32 { return 2; }
/** Exported function `metric_kind_histogram`.
 * Implements `metric_kind_histogram`.
 * @return i32
 */
export function metric_kind_histogram(): i32 { return 3; }

/** Exported function `histogram_default_bucket_count`.
 * Implements `histogram_default_bucket_count`.
 * @return i32
 */
export function histogram_default_bucket_count(): i32 { return 5; }

/* See implementation. */
allow(padding) struct Label {
  key_len: i32;
  val_len: i32;
  key: u8[32];
  val: u8[32];
}

/* See implementation. */
allow(padding) struct Counter {
  name_len: i32;
  name: u8[48];
  label: Label;
  value: i64;
}

/* See implementation. */
allow(padding) struct Gauge {
  name_len: i32;
  name: u8[48];
  label: Label;
  value: i64;
}

/* See implementation. */
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

/* See implementation. */
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

/** Exported function `copy_bytes`.
 * Implements `copy_bytes`.
 * @param dst *u8
 * @param dst_cap i32
 * @param src *u8
 * @param src_len i32
 * @return i32
 */
export function copy_bytes(dst: *u8, dst_cap: i32, src: *u8, src_len: i32): i32 {
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

/** Exported function `label_empty`.
 * Implements `label_empty`.
 * @return Label
 */
export function label_empty(): Label {
  return Label { key_len: 0, val_len: 0, key: [], val: [] };
}

/** Exported function `label_set`.
 * Implements `label_set`.
 * @param l *Label
 * @param key *u8
 * @param key_len i32
 * @param val *u8
 * @param val_len i32
 * @return i32
 */
export function label_set(l: *Label, key: *u8, key_len: i32, val: *u8, val_len: i32): i32 {
  if (l == 0) { return err_not_found(); }
  l.key_len = copy_bytes(&l.key[0], 32, key, key_len);
  l.val_len = copy_bytes(&l.val[0], 32, val, val_len);
  if (l.key_len < 0 || l.val_len < 0) { return err_buffer(); }
  return err_ok();
}

/** Exported function `registry_new`.
 * Implements `registry_new`.
 * @return Registry
 */
export function registry_new(): Registry {
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

/** Exported function `counter_init`.
 * Implements `counter_init`.
 * @param c *Counter
 * @param name *u8
 * @param name_len i32
 * @param lkey *u8
 * @param lk_len i32
 * @param lval *u8
 * @param lv_len i32
 * @return i32
 */
export function counter_init(c: *Counter, name: *u8, name_len: i32, lkey: *u8, lk_len: i32, lval: *u8, lv_len: i32): i32 {
  if (c == 0) { return err_not_found(); }
  c.name_len = copy_bytes(&c.name[0], 48, name, name_len);
  c.value = 0 as i64;
  if (c.name_len < 0) { return err_buffer(); }
  return label_set(&c.label, lkey, lk_len, lval, lv_len);
}

/** Exported function `counter_inc`.
 * Implements `counter_inc`.
 * @param c *Counter
 * @param delta i64
 * @return i32
 */
export function counter_inc(c: *Counter, delta: i64): i32 {
  if (c == 0) { return err_not_found(); }
  if (delta <= (0 as i64)) { return err_ok(); }
  atomic.fetch_add(&c.value, delta);
  return err_ok();
}

/** Exported function `counter_snapshot`.
 * Implements `counter_snapshot`.
 * @param c *Counter
 * @return i64
 */
export function counter_snapshot(c: *Counter): i64 {
  if (c == 0) { return 0; }
  return atomic.load(&c.value);
}

/** Exported function `gauge_init`.
 * Implements `gauge_init`.
 * @param g *Gauge
 * @param name *u8
 * @param name_len i32
 * @param lkey *u8
 * @param lk_len i32
 * @param lval *u8
 * @param lv_len i32
 * @return i32
 */
export function gauge_init(g: *Gauge, name: *u8, name_len: i32, lkey: *u8, lk_len: i32, lval: *u8, lv_len: i32): i32 {
  if (g == 0) { return err_not_found(); }
  g.name_len = copy_bytes(&g.name[0], 48, name, name_len);
  g.value = 0 as i64;
  if (g.name_len < 0) { return err_buffer(); }
  return label_set(&g.label, lkey, lk_len, lval, lv_len);
}

/** Exported function `gauge_set`.
 * Implements `gauge_set`.
 * @param g *Gauge
 * @param v i64
 * @return i32
 */
export function gauge_set(g: *Gauge, v: i64): i32 {
  if (g == 0) { return err_not_found(); }
  atomic.store(&g.value, v);
  return err_ok();
}

/** Exported function `gauge_add`.
 * Implements `gauge_add`.
 * @param g *Gauge
 * @param delta i64
 * @return i32
 */
export function gauge_add(g: *Gauge, delta: i64): i32 {
  if (g == 0) { return err_not_found(); }
  atomic.fetch_add(&g.value, delta);
  return err_ok();
}

/** Exported function `gauge_snapshot`.
 * Implements `gauge_snapshot`.
 * @param g *Gauge
 * @return i64
 */
export function gauge_snapshot(g: *Gauge): i64 {
  if (g == 0) { return 0; }
  return atomic.load(&g.value);
}

/** Exported function `histogram_init_default_buckets`.
 * Implements `histogram_init_default_buckets`.
 * @param h *Histogram
 * @return void
 */
export function histogram_init_default_buckets(h: *Histogram): void {
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

/** Exported function `histogram_init`.
 * Implements `histogram_init`.
 * @param h *Histogram
 * @param name *u8
 * @param name_len i32
 * @param lkey *u8
 * @param lk_len i32
 * @param lval *u8
 * @param lv_len i32
 * @return i32
 */
export function histogram_init(h: *Histogram, name: *u8, name_len: i32, lkey: *u8, lk_len: i32, lval: *u8, lv_len: i32): i32 {
  if (h == 0) { return err_not_found(); }
  h.name_len = copy_bytes(&h.name[0], 48, name, name_len);
  histogram_init_default_buckets(h);
  if (h.name_len < 0) { return err_buffer(); }
  return label_set(&h.label, lkey, lk_len, lval, lv_len);
}

/** Exported function `histogram_observe`.
 * Implements `histogram_observe`.
 * @param h *Histogram
 * @param v i64
 * @return i32
 */
export function histogram_observe(h: *Histogram, v: i64): i32 {
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

/** Exported function `counter`.
 * Implements `counter`.
 * @param reg *Registry
 * @param name *u8
 * @param name_len i32
 * @param lkey *u8
 * @param lk_len i32
 * @param lval *u8
 * @param lv_len i32
 * @return i32
 */
export function counter(reg: *Registry, name: *u8, name_len: i32, lkey: *u8, lk_len: i32, lval: *u8, lv_len: i32): i32 {
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

/** Exported function `gauge`.
 * Implements `gauge`.
 * @param reg *Registry
 * @param name *u8
 * @param name_len i32
 * @param lkey *u8
 * @param lk_len i32
 * @param lval *u8
 * @param lv_len i32
 * @return i32
 */
export function gauge(reg: *Registry, name: *u8, name_len: i32, lkey: *u8, lk_len: i32, lval: *u8, lv_len: i32): i32 {
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

/** Exported function `histogram`.
 * Implements `histogram`.
 * @param reg *Registry
 * @param name *u8
 * @param name_len i32
 * @param lkey *u8
 * @param lk_len i32
 * @param lval *u8
 * @param lv_len i32
 * @return i32
 */
export function histogram(reg: *Registry, name: *u8, name_len: i32, lkey: *u8, lk_len: i32, lval: *u8, lv_len: i32): i32 {
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

/** Exported function `extend`.
 * Implements `extend`.
 * @param out *u8
 * @param cap i32
 * @param off i32
 * @param src *u8
 * @param n i32
 * @return i32
 */
export function extend(out: *u8, cap: i32, off: i32, src: *u8, n: i32): i32 {
  let i: i32 = 0;
  if (out == 0 || src == 0) { return -1; }
  if (off < 0 || off + n >= cap) { return -1; }
  while (i < n) {
    out[off + i] = src[i];
    i = i + 1;
  }
  return off + n;
}

/** Exported function `append_byte`.
 * Implements `append_byte`.
 * @param out *u8
 * @param cap i32
 * @param off i32
 * @param b u8
 * @return i32
 */
export function append_byte(out: *u8, cap: i32, off: i32, b: u8): i32 {
  let tmp: u8[1] = [0];
  tmp[0] = b;
  return extend(out, cap, off, &tmp[0], 1);
}

/** Exported function `append_label_suffix`.
 * Implements `append_label_suffix`.
 * @param out *u8
 * @param cap i32
 * @param off i32
 * @param l *Label
 * @return i32
 */
export function append_label_suffix(out: *u8, cap: i32, off: i32, l: *Label): i32 {
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

/** Exported function `export_counter_prometheus`.
 * Implements `export_counter_prometheus`.
 * @param c *Counter
 * @param out *u8
 * @param cap i32
 * @param off i32
 * @return i32
 */
export function export_counter_prometheus(c: *Counter, out: *u8, cap: i32, off: i32): i32 {
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

/** Exported function `export_gauge_prometheus`.
 * Implements `export_gauge_prometheus`.
 * @param g *Gauge
 * @param out *u8
 * @param cap i32
 * @param off i32
 * @return i32
 */
export function export_gauge_prometheus(g: *Gauge, out: *u8, cap: i32, off: i32): i32 {
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

/** Exported function `export_histogram_prometheus`.
 * Implements `export_histogram_prometheus`.
 * @param h *Histogram
 * @param out *u8
 * @param cap i32
 * @param off i32
 * @return i32
 */
export function export_histogram_prometheus(h: *Histogram, out: *u8, cap: i32, off: i32): i32 {
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

/** Exported function `export_prometheus`.
 * Implements `export_prometheus`.
 * @param reg *Registry
 * @param out *u8
 * @param cap i32
 * @return i32
 */
export function export_prometheus(reg: *Registry, out: *u8, cap: i32): i32 {
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

/* See implementation. */

/* See implementation. */
allow(padding) struct ObservabilityCtx {
  trace_handle: i64;
  span_id: i64;
  trace_id_len: i32;
  span_id_len: i32;
  trace_id_hex: u8[33];
  span_id_hex: u8[17];
}

/** Exported function `obs_ctx_key_trace_len`.
 * Query helper `obs_ctx_key_trace_len`.
 * @return i32
 */
export function obs_ctx_key_trace_len(): i32 { return 5; }

/** Exported function `obs_ctx_key_span_len`.
 * Query helper `obs_ctx_key_span_len`.
 * @return i32
 */
export function obs_ctx_key_span_len(): i32 { return 4; }

/** Exported function `obs_ctx_write_key_trace`.
 * Write path helper `obs_ctx_write_key_trace`.
 * @param buf *u8
 * @param cap i32
 * @return i32
 */
export function obs_ctx_write_key_trace(buf: *u8, cap: i32): i32 {
  let k: u8[6] = [116, 114, 97, 99, 101, 0];
  return copy_bytes(buf, cap, &k[0], 5);
}

/** Exported function `obs_ctx_write_key_span`.
 * Write path helper `obs_ctx_write_key_span`.
 * @param buf *u8
 * @param cap i32
 * @return i32
 */
export function obs_ctx_write_key_span(buf: *u8, cap: i32): i32 {
  let k: u8[5] = [115, 112, 97, 110, 0];
  return copy_bytes(buf, cap, &k[0], 4);
}

/** Exported function `obs_ctx_empty`.
 * Implements `obs_ctx_empty`.
 * @return ObservabilityCtx
 */
export function obs_ctx_empty(): ObservabilityCtx {
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

/** Exported function `obs_encode_trace_id_hex`.
 * Implements `obs_encode_trace_id_hex`.
 * @param obs *ObservabilityCtx
 * @param tid *TraceId
 * @return i32
 */
export function obs_encode_trace_id_hex(obs: *ObservabilityCtx, tid: *TraceId): i32 {
  let n: i32 = 0;
  if (obs == 0 || tid == 0) { return -1; }
  n = encoding.hex_encode(&tid.bytes[0], 16, &obs.trace_id_hex[0], 33);
  if (n != 32) { return -1; }
  obs.trace_id_hex[32] = 0;
  obs.trace_id_len = 32;
  return 32;
}

/** Exported function `obs_encode_span_id_hex`.
 * Implements `obs_encode_span_id_hex`.
 * @param obs *ObservabilityCtx
 * @param span_id i64
 * @return i32
 */
export function obs_encode_span_id_hex(obs: *ObservabilityCtx, span_id: i64): i32 {
  let n: i32 = 0;
  if (obs == 0) { return -1; }
  n = fmt.hex_to_buf(&obs.span_id_hex[0], 17, span_id as u64);
  if (n <= 0) { return -1; }
  obs.span_id_hex[n] = 0;
  obs.span_id_len = n;
  return n;
}

/** Exported function `obs_ctx_from_trace`.
 * Implements `obs_ctx_from_trace`.
 * @param tr *Trace
 * @param span Span
 * @return ObservabilityCtx
 */
export function obs_ctx_from_trace(tr: *Trace, span: Span): ObservabilityCtx {
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

/** Exported function `obs_ctx_attach_context`.
 * Implements `obs_ctx_attach_context`.
 * @param ctx Context
 * @param obs ObservabilityCtx
 * @return i32
 */
export function obs_ctx_attach_context(ctx: Context, obs: ObservabilityCtx): i32 {
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

/** Exported function `obs_ctx_from_context`.
 * Implements `obs_ctx_from_context`.
 * @param ctx Context
 * @param tr *Trace
 * @return ObservabilityCtx
 */
export function obs_ctx_from_context(ctx: Context, tr: *Trace): ObservabilityCtx {
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
 * See implementation.
 * See implementation.
 */
export function obs_ctx_format_log_kv(obs: *ObservabilityCtx, out: *u8, out_cap: i32): i32 {
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
 * See implementation.
 * See implementation.
 */
export function obs_ctx_apply_trace_label(obs: *ObservabilityCtx, lbl: *Label): i32 {
  let k: u8[9] = [116, 114, 97, 99, 101, 95, 105, 100, 0];
  let vlen: i32 = 0;
  if (obs == 0 || lbl == 0 || obs.trace_id_len <= 0) { return err_not_found(); }
  vlen = obs.trace_id_len;
  if (vlen > 31) { vlen = 31; }
  return label_set(lbl, &k[0], 8, &obs.trace_id_hex[0], vlen);
}
