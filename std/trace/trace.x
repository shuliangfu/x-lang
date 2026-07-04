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

// std/trace/trace.x — F-trace v2：span 栈、trace_id、text 导出（纯 .x；替代 trace_span_glue.c）
//
// 【文件职责】
// 追踪会话创建/释放；span 嵌套栈；trace_id 生成；text 导出；
// STD-088 / STD-118 C 烟测。单调时钟与随机字节经 extern time/random。
//
// 【对标】OpenTelemetry 最小子集、Go opentelemetry trace 简化版。

const TRACE_OK: i32 = 0;
const TRACE_ERR_NULL: i32 = -1;
const TRACE_ERR_NOT_FOUND: i32 = -2;
const TRACE_ERR_FULL: i32 = -3;
const TRACE_ERR_INVALID: i32 = -4;

/** C 字符串常量（解析器不支持 "..." as *u8）。 */
const TRA_LIT_END: u8[6] = [32, 101, 110, 100, 61, 0];
const TRA_LIT_NAME: u8[7] = [32, 110, 97, 109, 101, 61, 0];
const TRA_LIT_PARENT: u8[9] = [32, 112, 97, 114, 101, 110, 116, 61, 0];
const TRA_LIT_START: u8[8] = [32, 115, 116, 97, 114, 116, 61, 0];
const TRA_LIT_NAME_CHILD: u8[11] = [110, 97, 109, 101, 61, 99, 104, 105, 108, 100, 0];
const TRA_LIT_NAME_ROOT: u8[10] = [110, 97, 109, 101, 61, 114, 111, 111, 116, 0];
const TRA_LIT_SPAN_ID: u8[9] = [115, 112, 97, 110, 32, 105, 100, 61, 0];
const TRA_LIT_TRACE_ID: u8[10] = [116, 114, 97, 99, 101, 95, 105, 100, 61, 0];

const TRACE_MAX_SPANS: i32 = 32;
const TRACE_MAX_NAME: i32 = 64;
const TRACE_STACK_MAX: i32 = 16;

const SPAN_NODE_SIZE: usize = 128;
const TRACE_STATE_SIZE: usize = 4196;

/** Span 节点：id、parent、名称与时间戳。 */
allow(padding) struct SpanNode {
  span_id: u64;
  parent_id: u64;
  name: u8[64];
  start_ns: i64;
  end_ns: i64;
  active: i32;
  used: i32;
}

/** 追踪会话堆对象（句柄 cast 为此结构）。 */
allow(padding) struct TraceState {
  trace_id: u8[16];
  spans: SpanNode[32];
  span_count: i32;
  next_span_id: u64;
  stack: i32[16];
  stack_depth: i32;
}

extern function time_now_monotonic_ns_c(): i64;
extern function random_fill_bytes_c(buf: *u8, len: i32): i32;
extern function calloc(nmemb: usize, size: usize): *u8;
extern function free(ptr: *u8): void;
extern function memcpy(dst: *u8, src: *u8, n: usize): *u8;
extern function memset(s: *u8, c: i32, n: usize): *u8;

/** F-trace v1 版本标记；供聚合 gate 校验 trace.x 已参与构建。 */
function trace_f_trace_v1_marker_c(): i32 {
  return 1;
}

/** F-trace v2 逻辑全量 .x 标记（span/export 无 glue）。 */
function trace_f_trace_v2_marker_c(): i32 {
  return 1;
}

/** 句柄转 TraceState 指针；非法 0。 */
function trace_from_handle(h: i64): *TraceState {
  if (h == 0) { return 0; }
  return h as *TraceState;
}

/** 生成 128-bit trace_id；random 失败时用单调时钟填充。 */
function trace_gen_trace_id(out16: *u8): void {
  let t: i64 = 0;
  let i: i32 = 0;
  if (out16 == 0) { return; }
  unsafe { if (random_fill_bytes_c(out16, 16) == 16) { return; } }
  unsafe { t = time_now_monotonic_ns_c(); }
  i = 0;
  while (i < 8) {
    out16[i] = ((t >> (i * 8)) & 255) as u8;
    out16[i + 8] = out16[i];
    i = i + 1;
  }
}

/** 查找 span 索引；不存在 -1。 */
function trace_find_span(t: *TraceState, span_id: u64): i32 {
  let i: i32 = 0;
  if (t == 0 || span_id == 0) { return -1; }
  while (i < TRACE_MAX_SPANS) {
    if (t.spans[i].used != 0 && t.spans[i].span_id == span_id) { return i; }
    i = i + 1;
  }
  return -1;
}

/** 向 out 追加单字节；满则 TRACE_ERR_FULL。 */
function trace_append_byte(out: *u8, out_cap: i32, pos: *i32, b: u8): i32 {
  if (out == 0 || pos == 0) { return TRACE_ERR_NULL; }
  if (*pos < 0 || *pos >= out_cap) { return TRACE_ERR_FULL; }
  out[*pos] = b;
  *pos = *pos + 1;
  return TRACE_OK;
}

/** 向 out 追加 n 字节。 */
function trace_append_bytes(out: *u8, out_cap: i32, pos: *i32, s: *u8, n: i32): i32 {
  let i: i32 = 0;
  while (i < n) {
    if (trace_append_byte(out, out_cap, pos, s[i]) != TRACE_OK) { return TRACE_ERR_FULL; }
    i = i + 1;
  }
  return TRACE_OK;
}

/** 单字节转两位小写十六进制写入 out[0..1]。 */
function u8_to_hex2(b: u8, out: *u8): void {
  let hi: u8 = (b >> 4) & 0x0f;
  let lo: u8 = b & 0x0f;
  if (out == 0) { return; }
  out[0] = (hi < 10) ? ((48 + hi) as u8) : ((87 + hi) as u8);
  out[1] = (lo < 10) ? ((48 + lo) as u8) : ((87 + lo) as u8);
}

/** 追加 u64 十进制表示。 */
function append_u64_dec(out: *u8, out_cap: i32, pos: *i32, v: u64): i32 {
  let tmp: u8[21] = [];
  let n: i32 = 0;
  let i: i32 = 0;
  let vv: u64 = v;
  if (out == 0 || pos == 0) { return TRACE_ERR_NULL; }
  if (vv == 0) { tmp[0] = 48; n = 1; }
  else {
    while (vv > 0 && n < 21) {
      tmp[n] = (48 + (vv % 10)) as u8;
      n = n + 1;
      vv = vv / 10;
    }
    i = 0;
    while (i < n / 2) {
      let tb: u8 = tmp[i];
      tmp[i] = tmp[(n - 1 - i)];
      tmp[(n - 1 - i)] = tb;
      i = i + 1;
    }
  }
  return trace_append_bytes(out, out_cap, pos, &tmp[0], n);
}

/** 追加 i64 十进制表示（含负号）。 */
function append_i64_dec(out: *u8, out_cap: i32, pos: *i32, v: i64): i32 {
  let neg: u64 = 0;
  if (v < 0) {
    if (trace_append_byte(out, out_cap, pos, 45) != TRACE_OK) { return TRACE_ERR_FULL; }
    neg = (-v) as u64;
    return append_u64_dec(out, out_cap, pos, neg);
  }
  return append_u64_dec(out, out_cap, pos, v as u64);
}

/** 创建追踪会话；失败 0。 */
function trace_create_c(): i64 {
  let t: *TraceState = 0;
  unsafe { t = calloc(1, TRACE_STATE_SIZE) as *TraceState; }
  if (t == 0) { return 0; }
  trace_gen_trace_id(&t.trace_id[0]);
  t.next_span_id = 1;
  return t as i64;
}

/** 释放追踪会话。 */
function trace_free_c(handle: i64): void {
  let t: *TraceState = trace_from_handle(handle);
  if (t != 0) { unsafe { free(t as *u8); } }
}

/** 读取 trace_id 16 字节。 */
function trace_trace_id_c(handle: i64, out16: *u8): void {
  let t: *TraceState = trace_from_handle(handle);
  if (t == 0 || out16 == 0) { return; }
  unsafe { memcpy(out16, &t.trace_id[0], 16); }
}

/** 当前栈顶 span_id；无则 0。 */
function trace_current_span_c(handle: i64): i64 {
  let t: *TraceState = trace_from_handle(handle);
  if (t == 0 || t.stack_depth <= 0) { return 0; }
  return t.stack[(t.stack_depth - 1)] as i64;
}

/** 开始 span；parent_id=0 表示根。返回 span_id，失败 0。 */
function trace_start_span_c(handle: i64, parent_id: i64, name: *u8, name_len: i32): i64 {
  let t: *TraceState = trace_from_handle(handle);
  let i: i32 = 0;
  let sid: u64 = 0;
  let copy_len: i32 = 0;
  if (t == 0 || name == 0 || name_len <= 0) { return 0; }
  if (parent_id != 0 && trace_find_span(t, parent_id as u64) < 0) { return 0; }
  if (t.stack_depth >= TRACE_STACK_MAX) { return 0; }
  while (i < TRACE_MAX_SPANS) {
    if (t.spans[i].used == 0) { break; }
    i = i + 1;
  }
  if (i >= TRACE_MAX_SPANS) { return 0; }
  sid = t.next_span_id;
  t.next_span_id = t.next_span_id + 1;
  t.spans[i].span_id = sid;
  t.spans[i].parent_id = parent_id as u64;
  copy_len = name_len;
  if (copy_len >= TRACE_MAX_NAME) { copy_len = TRACE_MAX_NAME - 1; }
  unsafe { memcpy(&t.spans[i].name[0], name, copy_len); }
  t.spans[i].name[copy_len] = 0;
  unsafe { t.spans[i].start_ns = time_now_monotonic_ns_c(); }
  t.spans[i].end_ns = 0;
  t.spans[i].active = 1;
  t.spans[i].used = 1;
  t.stack[t.stack_depth] = sid as i32;
  t.stack_depth = t.stack_depth + 1;
  t.span_count = t.span_count + 1;
  return sid as i64;
}

/** 结束 span；须为栈顶。0 成功。 */
function trace_end_span_c(handle: i64, span_id: i64): i32 {
  let t: *TraceState = trace_from_handle(handle);
  let idx: i32 = 0;
  if (t == 0 || span_id == 0) { return TRACE_ERR_NULL; }
  if (t.stack_depth <= 0 || t.stack[(t.stack_depth - 1)] as i64 != span_id) {
    return TRACE_ERR_INVALID;
  }
  idx = trace_find_span(t, span_id as u64);
  if (idx < 0) { return TRACE_ERR_NOT_FOUND; }
  unsafe { t.spans[idx].end_ns = time_now_monotonic_ns_c(); }
  t.spans[idx].active = 0;
  t.stack_depth = t.stack_depth - 1;
  return TRACE_OK;
}

/** 以当前栈顶为 parent 开始子 span。 */
function trace_start_child_c(handle: i64, name: *u8, name_len: i32): i64 {
  let t: *TraceState = trace_from_handle(handle);
  let parent: i64 = 0;
  if (t == 0) { return 0; }
  parent = trace_current_span_c(handle);
  if (parent == 0) { return trace_start_span_c(handle, 0, name, name_len); }
  return trace_start_span_c(handle, parent, name, name_len);
}

/** 已完成 span 数量。 */
function trace_span_count_c(handle: i64): i32 {
  let t: *TraceState = trace_from_handle(handle);
  if (t == 0) { return TRACE_ERR_NULL; }
  return t.span_count;
}

/** 导出 text 格式（OTLP 风格简化行）；返回写入长度，失败负值。 */
function trace_export_text_c(handle: i64, out: *u8, out_cap: i32): i32 {
  let t: *TraceState = trace_from_handle(handle);
  let pos: i32 = 0;
  let i: i32 = 0;
  let j: i32 = 0;
  let hx: u8[2] = [];
  if (t == 0 || out == 0 || out_cap <= 0) { return TRACE_ERR_NULL; }
  if (trace_append_bytes(out, out_cap, &pos, &TRA_LIT_TRACE_ID[0], 9) != TRACE_OK) { return TRACE_ERR_INVALID; }
  i = 0;
  while (i < 16) {
    u8_to_hex2(t.trace_id[i], &hx[0]);
    if (trace_append_byte(out, out_cap, &pos, hx[0]) != TRACE_OK) { return TRACE_ERR_INVALID; }
    if (trace_append_byte(out, out_cap, &pos, hx[1]) != TRACE_OK) { return TRACE_ERR_INVALID; }
    i = i + 1;
  }
  if (trace_append_byte(out, out_cap, &pos, 10) != TRACE_OK) { return TRACE_ERR_FULL; }
  i = 0;
  while (i < TRACE_MAX_SPANS) {
    if (t.spans[i].used == 0) { i = i + 1; continue; }
    if (trace_append_bytes(out, out_cap, &pos, &TRA_LIT_SPAN_ID[0], 8) != TRACE_OK) { return TRACE_ERR_INVALID; }
    if (append_u64_dec(out, out_cap, &pos, t.spans[i].span_id) != TRACE_OK) { return TRACE_ERR_INVALID; }
    if (trace_append_bytes(out, out_cap, &pos, &TRA_LIT_PARENT[0], 8) != TRACE_OK) { return TRACE_ERR_INVALID; }
    if (append_u64_dec(out, out_cap, &pos, t.spans[i].parent_id) != TRACE_OK) { return TRACE_ERR_INVALID; }
    if (trace_append_bytes(out, out_cap, &pos, &TRA_LIT_NAME[0], 6) != TRACE_OK) { return TRACE_ERR_INVALID; }
    j = 0;
    while (j < TRACE_MAX_NAME && t.spans[i].name[j] != 0) {
      if (trace_append_byte(out, out_cap, &pos, t.spans[i].name[j]) != TRACE_OK) {
        return TRACE_ERR_FULL;
      }
      j = j + 1;
    }
    if (trace_append_bytes(out, out_cap, &pos, &TRA_LIT_START[0], 7) != TRACE_OK) { return TRACE_ERR_INVALID; }
    if (append_i64_dec(out, out_cap, &pos, t.spans[i].start_ns) != TRACE_OK) { return TRACE_ERR_INVALID; }
    if (trace_append_bytes(out, out_cap, &pos, &TRA_LIT_END[0], 5) != TRACE_OK) { return TRACE_ERR_INVALID; }
    if (append_i64_dec(out, out_cap, &pos, t.spans[i].end_ns) != TRACE_OK) { return TRACE_ERR_INVALID; }
    if (trace_append_byte(out, out_cap, &pos, 10) != TRACE_OK) { return TRACE_ERR_FULL; }
    i = i + 1;
  }
  return pos;
}

/** 缓冲是否含子串 needle（NUL 结尾）。 */
function trace_contains(hay: *u8, hay_len: i32, needle: *u8): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  if (hay == 0 || needle == 0) { return 0; }
  while (i < hay_len) {
    j = 0;
    while (needle[j] != 0 && (i + j) < hay_len && hay[(i + j)] == needle[j]) {
      j = j + 1;
    }
    if (needle[j] == 0) { return 1; }
    i = i + 1;
  }
  return 0;
}

/** C 烟测：嵌套 span + text 导出。 */
function trace_smoke_c(): i32 {
  let tr: i64 = 0;
  let root: i64 = 0;
  let child: i64 = 0;
  let buf: u8[512];
  let n: i32 = 0;
  let n_root: u8[4] = [114, 111, 111, 116];
  let n_child: u8[5] = [99, 104, 105, 108, 100];
  tr = trace_create_c();
  if (tr == 0) { return 1; }
  root = trace_start_span_c(tr, 0, &n_root[0], 4);
  if (root == 0) { return 2; }
  child = trace_start_child_c(tr, &n_child[0], 5);
  if (child == 0 || child == root) { return 3; }
  if (trace_end_span_c(tr, child) != TRACE_OK) { return 4; }
  if (trace_end_span_c(tr, root) != TRACE_OK) { return 5; }
  if (trace_span_count_c(tr) != 2) { return 6; }
  n = trace_export_text_c(tr, &buf[0], 512);
  if (n <= 0) { return 7; }
  if (trace_contains(&buf[0], n, &TRA_LIT_TRACE_ID[0]) == 0) { return 8; }
  if (trace_contains(&buf[0], n, &TRA_LIT_NAME_ROOT[0]) == 0) { return 9; }
  if (trace_contains(&buf[0], n, &TRA_LIT_NAME_CHILD[0]) == 0) { return 10; }
  trace_free_c(tr);
  return 0;
}

/** STD-118：关键路径 hook span 烟测。 */
function trace_hooks_smoke_c(): i32 {
  let tr: i64 = 0;
  let root: i64 = 0;
  let sp_io: i64 = 0;
  let sp_net: i64 = 0;
  let sp_async: i64 = 0;
  let n_root: u8[4] = [114, 111, 111, 116];
  let n_io: u8[7] = [105, 111, 46, 114, 101, 97, 100];
  let n_net: u8[11] = [110, 101, 116, 46, 99, 111, 110, 110, 101, 99, 116];
  let n_async: u8[11] = [97, 115, 121, 110, 99, 46, 100, 114, 97, 105, 110];
  tr = trace_create_c();
  if (tr == 0) { return 1; }
  root = trace_start_span_c(tr, 0, &n_root[0], 4);
  if (root == 0) { return 2; }
  sp_io = trace_start_child_c(tr, &n_io[0], 7);
  if (sp_io == 0) { return 3; }
  if (trace_end_span_c(tr, sp_io) != TRACE_OK) { return 4; }
  sp_net = trace_start_child_c(tr, &n_net[0], 11);
  if (sp_net == 0) { return 5; }
  if (trace_end_span_c(tr, sp_net) != TRACE_OK) { return 6; }
  sp_async = trace_start_child_c(tr, &n_async[0], 11);
  if (sp_async == 0) { return 7; }
  if (trace_end_span_c(tr, sp_async) != TRACE_OK) { return 8; }
  if (trace_end_span_c(tr, root) != TRACE_OK) { return 9; }
  if (trace_span_count_c(tr) != 4) { return 10; }
  trace_free_c(tr);
  return 0;
}
