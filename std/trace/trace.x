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

export const TRACE_OK: i32 = 0;
export const TRACE_ERR_NULL: i32 = -1;
export const TRACE_ERR_NOT_FOUND: i32 = -2;
export const TRACE_ERR_FULL: i32 = -3;
export const TRACE_ERR_INVALID: i32 = -4;

/* See implementation. */
export const TRA_LIT_END: u8[6] = [32, 101, 110, 100, 61, 0];
export const TRA_LIT_NAME: u8[7] = [32, 110, 97, 109, 101, 61, 0];
export const TRA_LIT_PARENT: u8[9] = [32, 112, 97, 114, 101, 110, 116, 61, 0];
export const TRA_LIT_START: u8[8] = [32, 115, 116, 97, 114, 116, 61, 0];
export const TRA_LIT_NAME_CHILD: u8[11] = [110, 97, 109, 101, 61, 99, 104, 105, 108, 100, 0];
export const TRA_LIT_NAME_ROOT: u8[10] = [110, 97, 109, 101, 61, 114, 111, 111, 116, 0];
export const TRA_LIT_SPAN_ID: u8[9] = [115, 112, 97, 110, 32, 105, 100, 61, 0];
export const TRA_LIT_TRACE_ID: u8[10] = [116, 114, 97, 99, 101, 95, 105, 100, 61, 0];

export const TRACE_MAX_SPANS: i32 = 32;
export const TRACE_MAX_NAME: i32 = 64;
export const TRACE_STACK_MAX: i32 = 16;

export const SPAN_NODE_SIZE: usize = 128;
export const TRACE_STATE_SIZE: usize = 4196;

/* See implementation. */
allow(padding) struct SpanNode {
  span_id: u64;
  parent_id: u64;
  name: u8[64];
  start_ns: i64;
  end_ns: i64;
  active: i32;
  used: i32;
}

/* See implementation. */
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
extern "C" function calloc(nmemb: usize, size: usize): *u8;
extern "C" function free(ptr: *u8): void;
extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
extern "C" function memset(s: *u8, c: i32, n: usize): *u8;

/** Exported function `trace_f_trace_v1_marker_c`.
 * Implements `trace_f_trace_v1_marker_c`.
 * @return i32
 */
export function trace_f_trace_v1_marker_c(): i32 {
  return 1;
}

/** Exported function `trace_f_trace_v2_marker_c`.
 * Implements `trace_f_trace_v2_marker_c`.
 * @return i32
 */
export function trace_f_trace_v2_marker_c(): i32 {
  return 1;
}

/** Exported function `trace_from_handle`.
 * Implements `trace_from_handle`.
 * @param h i64
 * @return *TraceState
 */
export function trace_from_handle(h: i64): *TraceState {
  if (h == 0) { return 0 as *TraceState; }
  return h as *TraceState;
}

/** Exported function `trace_gen_trace_id`.
 * Implements `trace_gen_trace_id`.
 * @param out16 *u8
 * @return void
 */
export function trace_gen_trace_id(out16: *u8): void {
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

/** Exported function `trace_find_span`.
 * Implements `trace_find_span`.
 * @param t *TraceState
 * @param span_id u64
 * @return i32
 */
export function trace_find_span(t: *TraceState, span_id: u64): i32 {
  let i: i32 = 0;
  if (t == 0 || span_id == 0) { return -1; }
  while (i < TRACE_MAX_SPANS) {
    if (t.spans[i].used != 0 && t.spans[i].span_id == span_id) { return i; }
    i = i + 1;
  }
  return -1;
}

/** Exported function `trace_append_byte`.
 * Implements `trace_append_byte`.
 * @param out *u8
 * @param out_cap i32
 * @param pos *i32
 * @param b u8
 * @return i32
 */
export function trace_append_byte(out: *u8, out_cap: i32, pos: *i32, b: u8): i32 {
  if (out == 0 || pos == 0) { return TRACE_ERR_NULL; }
  unsafe {
    if (*pos < 0 || *pos >= out_cap) { return TRACE_ERR_FULL; }
    out[*pos] = b;
    *pos = *pos + 1;
  }
  return TRACE_OK;
}

/** Exported function `trace_append_bytes`.
 * Implements `trace_append_bytes`.
 * @param out *u8
 * @param out_cap i32
 * @param pos *i32
 * @param s *u8
 * @param n i32
 * @return i32
 */
export function trace_append_bytes(out: *u8, out_cap: i32, pos: *i32, s: *u8, n: i32): i32 {
  let i: i32 = 0;
  while (i < n) {
    if (trace_append_byte(out, out_cap, pos, s[i]) != TRACE_OK) { return TRACE_ERR_FULL; }
    i = i + 1;
  }
  return TRACE_OK;
}

/** Exported function `u8_to_hex2`.
 * Implements `u8_to_hex2`.
 * @param b u8
 * @param out *u8
 * @return void
 */
export function u8_to_hex2(b: u8, out: *u8): void {
  let hi: u8 = (b >> 4) & 0x0f;
  let lo: u8 = b & 0x0f;
  if (out == 0) { return; }
  unsafe {
    out[0] = (hi < 10) ? ((48 + hi) as u8) : ((87 + hi) as u8);
    out[1] = (lo < 10) ? ((48 + lo) as u8) : ((87 + lo) as u8);
  }
}

/** Exported function `append_u64_dec`.
 * Implements `append_u64_dec`.
 * @param out *u8
 * @param out_cap i32
 * @param pos *i32
 * @param v u64
 * @return i32
 */
export function append_u64_dec(out: *u8, out_cap: i32, pos: *i32, v: u64): i32 {
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

/** Exported function `append_i64_dec`.
 * Implements `append_i64_dec`.
 * @param out *u8
 * @param out_cap i32
 * @param pos *i32
 * @param v i64
 * @return i32
 */
export function append_i64_dec(out: *u8, out_cap: i32, pos: *i32, v: i64): i32 {
  let neg: u64 = 0;
  if (v < 0) {
    if (trace_append_byte(out, out_cap, pos, 45) != TRACE_OK) { return TRACE_ERR_FULL; }
    neg = (-v) as u64;
    return append_u64_dec(out, out_cap, pos, neg);
  }
  return append_u64_dec(out, out_cap, pos, v as u64);
}

/** Exported function `trace_create_c`.
 * Implements `trace_create_c`.
 * @return i64
 */
export function trace_create_c(): i64 {
  let t: *TraceState = 0;
  unsafe { t = calloc(1, TRACE_STATE_SIZE) as *TraceState; }
  if (t == 0) { return 0; }
  trace_gen_trace_id(&t.trace_id[0]);
  t.next_span_id = 1;
  return t as i64;
}

/** Exported function `trace_free_c`.
 * Memory management helper `trace_free_c`.
 * @param handle i64
 * @return void
 */
export function trace_free_c(handle: i64): void {
  let t: *TraceState = trace_from_handle(handle);
  if (t != 0) { unsafe { free(t as *u8); } }
}

/** Exported function `trace_trace_id_c`.
 * Implements `trace_trace_id_c`.
 * @param handle i64
 * @param out16 *u8
 * @return void
 */
export function trace_trace_id_c(handle: i64, out16: *u8): void {
  let t: *TraceState = trace_from_handle(handle);
  if (t == 0 || out16 == 0) { return; }
  unsafe { memcpy(out16, &t.trace_id[0], 16); }
}

/** Exported function `trace_current_span_c`.
 * Implements `trace_current_span_c`.
 * @param handle i64
 * @return i64
 */
export function trace_current_span_c(handle: i64): i64 {
  let t: *TraceState = trace_from_handle(handle);
  if (t == 0 || t.stack_depth <= 0) { return 0; }
  return t.stack[(t.stack_depth - 1)] as i64;
}

/** Exported function `trace_start_span_c`.
 * Implements `trace_start_span_c`.
 * @param handle i64
 * @param parent_id i64
 * @param name *u8
 * @param name_len i32
 * @return i64
 */
export function trace_start_span_c(handle: i64, parent_id: i64, name: *u8, name_len: i32): i64 {
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

/** Exported function `trace_end_span_c`.
 * Implements `trace_end_span_c`.
 * @param handle i64
 * @param span_id i64
 * @return i32
 */
export function trace_end_span_c(handle: i64, span_id: i64): i32 {
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

/** Exported function `trace_start_child_c`.
 * Implements `trace_start_child_c`.
 * @param handle i64
 * @param name *u8
 * @param name_len i32
 * @return i64
 */
export function trace_start_child_c(handle: i64, name: *u8, name_len: i32): i64 {
  let t: *TraceState = trace_from_handle(handle);
  let parent: i64 = 0;
  if (t == 0) { return 0; }
  parent = trace_current_span_c(handle);
  if (parent == 0) { return trace_start_span_c(handle, 0, name, name_len); }
  return trace_start_span_c(handle, parent, name, name_len);
}

/** Exported function `trace_span_count_c`.
 * Implements `trace_span_count_c`.
 * @param handle i64
 * @return i32
 */
export function trace_span_count_c(handle: i64): i32 {
  let t: *TraceState = trace_from_handle(handle);
  if (t == 0) { return TRACE_ERR_NULL; }
  return t.span_count;
}

/** Exported function `trace_export_text_c`.
 * Implements `trace_export_text_c`.
 * @param handle i64
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function trace_export_text_c(handle: i64, out: *u8, out_cap: i32): i32 {
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

/** Exported function `trace_contains`.
 * Implements `trace_contains`.
 * @param hay *u8
 * @param hay_len i32
 * @param needle *u8
 * @return i32
 */
export function trace_contains(hay: *u8, hay_len: i32, needle: *u8): i32 {
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

/** Exported function `trace_smoke_c`.
 * Implements `trace_smoke_c`.
 * @return i32
 */
export function trace_smoke_c(): i32 {
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

/** Exported function `trace_hooks_smoke_c`.
 * Implements `trace_hooks_smoke_c`.
 * @return i32
 */
export function trace_hooks_smoke_c(): i32 {
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
