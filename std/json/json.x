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
// See implementation.
//
// See implementation.

/* See implementation. */
export const JSON_VIEW_NEEDS_COPY: i32 = -2;

/* See implementation. */
export const JSON_DECODE_MISSING: i32 = -3;

/* See implementation. */
export struct JsonCursor {
  ptr: *u8;
  len: i32;
  off: i32;
}

/** Exported function `json_f_json_v1_marker_c`.
 * Implements `json_f_json_v1_marker_c`.
 * @return i32
 */
export function json_f_json_v1_marker_c(): i32 {
  return 1;
}

/** Exported function `json_f_json_v2_marker_c`.
 * Implements `json_f_json_v2_marker_c`.
 * @return i32
 */
export function json_f_json_v2_marker_c(): i32 {
  return 1;
}

/** Exported function `json_cursor_copy`.
 * Implements `json_cursor_copy`.
 * @param dst *JsonCursor
 * @param src *JsonCursor
 * @return void
 */
export function json_cursor_copy(dst: *JsonCursor, src: *JsonCursor): void {
  if (dst == 0 || src == 0) { return; }
  dst.ptr = src.ptr;
  dst.len = src.len;
  dst.off = src.off;
}

/** Exported function `json_cursor_write_fields`.
 * Write path helper `json_cursor_write_fields`.
 * @param dst *JsonCursor
 * @param ptr *u8
 * @param len i32
 * @param off i32
 * @return void
 */
export function json_cursor_write_fields(dst: *JsonCursor, ptr: *u8, len: i32, off: i32): void {
  if (dst == 0) { return; }
  dst.ptr = ptr;
  dst.len = len;
  dst.off = off;
}

/** Exported function `json_parse_number_c`.
 * Implements `json_parse_number_c`.
 * @param ptr *u8
 * @param len i32
 * @param out_val *f64
 * @param consumed *i32
 * @return i32
 */
export function json_parse_number_c(ptr: *u8, len: i32, out_val: *f64, consumed: *i32): i32 {
  let i: i32 = 0;
  let neg: i32 = 0;
  let mantissa: u64 = 0;
  let val: f64 = 0.0;
  let frac: f64 = 0.0;
  let div: f64 = 1.0;
  let exp_neg: i32 = 0;
  let exp: i32 = 0;
  let scale: f64 = 1.0;
  if (ptr == 0 || len <= 0 || out_val == 0 || consumed == 0) { return -1; }
  consumed[0] = 0;
  if (ptr[i] == 45) { neg = 1; i = i + 1; }
  else if (ptr[i] == 43) { i = i + 1; }
  if (i >= len || ptr[i] < 48 || ptr[i] > 57) { return -1; }
  while (i < len && ptr[i] >= 48 && ptr[i] <= 57) {
    mantissa = mantissa * 10 + (ptr[i] - 48) as u64;
    i = i + 1;
  }
  val = mantissa as f64;
  if (i < len && ptr[i] == 46) {
    i = i + 1;
    frac = 0.0;
    div = 1.0;
    while (i < len && ptr[i] >= 48 && ptr[i] <= 57) {
      frac = frac * 10.0 + (ptr[i] - 48) as f64;
      div = div * 10.0;
      i = i + 1;
    }
    val = val + frac / div;
  }
  if (i < len && (ptr[i] == 101 || ptr[i] == 69)) {
    i = i + 1;
    exp_neg = 0;
    if (i < len && (ptr[i] == 45 || ptr[i] == 43)) {
      exp_neg = (ptr[i] == 45) ? 1 : 0;
      i = i + 1;
    }
    exp = 0;
    while (i < len && ptr[i] >= 48 && ptr[i] <= 57) {
      exp = exp * 10 + (ptr[i] - 48);
      if (exp > 999) { break; }
      i = i + 1;
    }
    if (exp_neg != 0) { exp = -exp; }
    if (exp > 308) { exp = 308; }
    if (exp < -308) { exp = -308; }
    scale = 1.0;
    while (exp > 0) { scale = scale * 10.0; exp = exp - 1; }
    while (exp < 0) { scale = scale * 0.1; exp = exp + 1; }
    val = val * scale;
  }
  if (neg != 0) { val = -val; }
  out_val[0] = val;
  consumed[0] = i;
  return 0;
}

/** Exported function `json_parse_null_c`.
 * Implements `json_parse_null_c`.
 * @param ptr *u8
 * @param len i32
 * @param consumed *i32
 * @return i32
 */
export function json_parse_null_c(ptr: *u8, len: i32, consumed: *i32): i32 {
  if (ptr == 0 || len < 4 || consumed == 0) { return 0; }
  if (ptr[0] == 110 && ptr[1] == 117 && ptr[2] == 108 && ptr[3] == 108) {
    consumed[0] = 4;
    return 1;
  }
  return 0;
}

/** Exported function `json_parse_bool_c`.
 * Implements `json_parse_bool_c`.
 * @param ptr *u8
 * @param len i32
 * @param out *i32
 * @param consumed *i32
 * @return i32
 */
export function json_parse_bool_c(ptr: *u8, len: i32, out: *i32, consumed: *i32): i32 {
  if (ptr == 0 || len < 4 || out == 0 || consumed == 0) { return 0; }
  if (len >= 4 && ptr[0] == 116 && ptr[1] == 114 && ptr[2] == 117 && ptr[3] == 101) {
    out[0] = 1;
    consumed[0] = 4;
    return 1;
  }
  if (len >= 5 && ptr[0] == 102 && ptr[1] == 97 && ptr[2] == 108 && ptr[3] == 115 && ptr[4] == 101) {
    out[0] = 0;
    consumed[0] = 5;
    return 1;
  }
  return 0;
}

/** Exported function `json_parse_string_c`.
 * Implements `json_parse_string_c`.
 * @param ptr *u8
 * @param len i32
 * @param out *u8
 * @param out_cap i32
 * @param consumed *i32
 * @return i32
 */
export function json_parse_string_c(ptr: *u8, len: i32, out: *u8, out_cap: i32, consumed: *i32): i32 {
  let i: i32 = 1;
  let o: i32 = 0;
  let u: u32 = 0;
  let k: i32 = 0;
  let c: u8 = 0;
  if (ptr == 0 || len < 2 || ptr[0] != 34 || consumed == 0) { return -1; }
  while (i < len && ptr[i] != 34) {
    if (ptr[i] == 92) {
      i = i + 1;
      if (i >= len) { return -1; }
      if (o >= out_cap) { return -1; }
      if (ptr[i] == 34) { out[o] = 34; o = o + 1; }
      else if (ptr[i] == 92) { out[o] = 92; o = o + 1; }
      else if (ptr[i] == 47) { out[o] = 47; o = o + 1; }
      else if (ptr[i] == 98) { out[o] = 8; o = o + 1; }
      else if (ptr[i] == 102) { out[o] = 12; o = o + 1; }
      else if (ptr[i] == 110) { out[o] = 10; o = o + 1; }
      else if (ptr[i] == 114) { out[o] = 13; o = o + 1; }
      else if (ptr[i] == 116) { out[o] = 9; o = o + 1; }
      else if (ptr[i] == 117 && i + 4 < len) {
        u = 0;
        k = 0;
        while (k < 4) {
          c = ptr[i + 1 + k];
          if (c >= 48 && c <= 57) { u = (u << 4) + (c - 48); }
          else if (c >= 97 && c <= 102) { u = (u << 4) + (c - 97 + 10); }
          else if (c >= 65 && c <= 70) { u = (u << 4) + (c - 65 + 10); }
          else { return -1; }
          k = k + 1;
        }
        i = i + 4;
        if (u <= 0x7f) {
          out[o] = u as u8;
          o = o + 1;
        } else if (u <= 0x7ff) {
          if (o + 2 > out_cap) { return -1; }
          out[o] = (0xc0 | (u >> 6)) as u8;
          o = o + 1;
          out[o] = (0x80 | (u & 0x3f)) as u8;
          o = o + 1;
        } else if (u <= 0xffff) {
          if (o + 3 > out_cap) { return -1; }
          out[o] = (0xe0 | (u >> 12)) as u8;
          o = o + 1;
          out[o] = (0x80 | ((u >> 6) & 0x3f)) as u8;
          o = o + 1;
          out[o] = (0x80 | (u & 0x3f)) as u8;
          o = o + 1;
        } else { return -1; }
        i = i + 1;
        continue;
      } else { return -1; }
      i = i + 1;
    } else {
      if (ptr[i] < 0x20) { return -1; }
      if (o >= out_cap) { return -1; }
      out[o] = ptr[i];
      o = o + 1;
      i = i + 1;
    }
  }
  if (i >= len || ptr[i] != 34) { return -1; }
  consumed[0] = i + 1;
  return o;
}

/** Exported function `json_escape_inner`.
 * Implements `json_escape_inner`.
 * @param ptr *u8
 * @param len i32
 * @param buf *u8
 * @param buf_off i32
 * @param buf_cap i32
 * @return i32
 */
export function json_escape_inner(ptr: *u8, len: i32, buf: *u8, buf_off: i32, buf_cap: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let c: u8 = 0;
  if (ptr == 0 || buf == 0 || buf_cap <= 0 || buf_off < 0) { return -1; }
  while (j < len && i < buf_cap) {
    c = ptr[j];
    if (c == 34) {
      if (i + 2 > buf_cap) { return -1; }
      buf[buf_off + i] = 92; i = i + 1;
      buf[buf_off + i] = 34; i = i + 1;
    } else if (c == 92) {
      if (i + 2 > buf_cap) { return -1; }
      buf[buf_off + i] = 92; i = i + 1;
      buf[buf_off + i] = 92; i = i + 1;
    } else if (c == 10) {
      if (i + 2 > buf_cap) { return -1; }
      buf[buf_off + i] = 92; i = i + 1;
      buf[buf_off + i] = 110; i = i + 1;
    } else if (c == 13) {
      if (i + 2 > buf_cap) { return -1; }
      buf[buf_off + i] = 92; i = i + 1;
      buf[buf_off + i] = 114; i = i + 1;
    } else if (c == 9) {
      if (i + 2 > buf_cap) { return -1; }
      buf[buf_off + i] = 92; i = i + 1;
      buf[buf_off + i] = 116; i = i + 1;
    } else if (c == 8) {
      if (i + 2 > buf_cap) { return -1; }
      buf[buf_off + i] = 92; i = i + 1;
      buf[buf_off + i] = 98; i = i + 1;
    } else if (c == 12) {
      if (i + 2 > buf_cap) { return -1; }
      buf[buf_off + i] = 92; i = i + 1;
      buf[buf_off + i] = 102; i = i + 1;
    } else {
      buf[buf_off + i] = c;
      i = i + 1;
    }
    j = j + 1;
  }
  return i;
}

/** Exported function `json_escape_c`.
 * Implements `json_escape_c`.
 * @param ptr *u8
 * @param len i32
 * @param buf *u8
 * @param buf_cap i32
 * @return i32
 */
export function json_escape_c(ptr: *u8, len: i32, buf: *u8, buf_cap: i32): i32 {
  let i: i32 = 0;
  let n: i32 = 0;
  let inner_cap: i32 = 0;
  if (ptr == 0 || buf == 0 || buf_cap < 2) { return -1; }
  buf[i] = 34; i = i + 1;
  inner_cap = buf_cap - i - 1;
  n = json_escape_inner(ptr, len, buf, i, inner_cap);
  if (n < 0) { return -1; }
  i = i + n;
  if (i >= buf_cap) { return -1; }
  buf[i] = 34; i = i + 1;
  return i;
}

/** Exported function `json_append_number_c`.
 * Implements `json_append_number_c`.
 * @param buf *u8
 * @param buf_cap i32
 * @param val f64
 * @return i32
 */
export function json_append_number_c(buf: *u8, buf_cap: i32, val: f64): i32 {
  let i: i32 = 0;
  let u: u64 = 0;
  let t: u64 = 0;
  let nd: i32 = 0;
  let d: u8[20] = [];
  if (buf == 0 || buf_cap <= 0) { return -1; }
  if (val < 0.0) { buf[i] = 45; i = i + 1; val = -val; }
  u = val as u64;
  if (u as f64 != val) {
    if (i + 1 > buf_cap) { return -1; }
    buf[i] = 48; i = i + 1;
    return i;
  }
  t = u;
  nd = 0;
  while (t != 0) {
    d[nd] = (48 + (t % 10)) as u8;
    nd = nd + 1;
    t = t / 10;
  }
  if (nd == 0) { d[0] = 48; nd = 1; }
  if (i + nd > buf_cap) { return -1; }
  while (nd > 0) { nd = nd - 1; buf[i] = d[nd]; i = i + 1; }
  return i;
}

/** Exported function `json_append_null_c`.
 * Implements `json_append_null_c`.
 * @param buf *u8
 * @param buf_cap i32
 * @return i32
 */
export function json_append_null_c(buf: *u8, buf_cap: i32): i32 {
  if (buf == 0 || buf_cap < 4) { return -1; }
  buf[0] = 110; buf[1] = 117; buf[2] = 108; buf[3] = 108;
  return 4;
}

/** Exported function `json_append_bool_c`.
 * Implements `json_append_bool_c`.
 * @param buf *u8
 * @param buf_cap i32
 * @param val i32
 * @return i32
 */
export function json_append_bool_c(buf: *u8, buf_cap: i32, val: i32): i32 {
  if (buf == 0 || buf_cap < 5) { return -1; }
  if (val != 0) {
    buf[0] = 116; buf[1] = 114; buf[2] = 117; buf[3] = 101;
    return 4;
  }
  buf[0] = 102; buf[1] = 97; buf[2] = 108; buf[3] = 115; buf[4] = 101;
  return 5;
}

/** Exported function `json_cursor_skip_ws`.
 * Implements `json_cursor_skip_ws`.
 * @param cur *JsonCursor
 * @return void
 */
export function json_cursor_skip_ws(cur: *JsonCursor): void {
  let c: u8 = 0;
  if (cur == 0) { return; }
  while (cur.off < cur.len) {
    c = cur.ptr[cur.off];
    if (c == 32 || c == 9 || c == 10 || c == 13) { cur.off = cur.off + 1; }
    else { break; }
  }
}

/** Exported function `json_cursor_skip_value_impl`.
 * Implements `json_cursor_skip_value_impl`.
 * @param cur *JsonCursor
 * @return i32
 */
export function json_cursor_skip_value_impl(cur: *JsonCursor): i32 {
  let consumed: i32 = 0;
  let dummy: i32 = 0;
  let dv: f64 = 0.0;
  let p: *u8 = 0;
  let rem: i32 = 0;
  let c: u8 = 0;
  let i: i32 = 0;
  if (cur == 0 || cur.off >= cur.len) { return -1; }
  json_cursor_skip_ws(cur);
  if (cur.off >= cur.len) { return -1; }
  p = &cur.ptr[cur.off];
  rem = cur.len - cur.off;
  c = p[0];
  if (c == 34) {
    i = 1;
    while (i < rem) {
      if (p[i] == 92) { i = i + 2; continue; }
      if (p[i] == 34) { cur.off = cur.off + i + 1; return 0; }
      i = i + 1;
    }
    return -1;
  }
  if (c == 123) {
    cur.off = cur.off + 1;
    json_cursor_skip_ws(cur);
    if (cur.off < cur.len && cur.ptr[cur.off] == 125) { cur.off = cur.off + 1; return 0; }
    loop {
      if (json_cursor_skip_value_impl(cur) != 0) { return -1; }
      json_cursor_skip_ws(cur);
      if (cur.off >= cur.len || cur.ptr[cur.off] != 58) { return -1; }
      cur.off = cur.off + 1;
      if (json_cursor_skip_value_impl(cur) != 0) { return -1; }
      json_cursor_skip_ws(cur);
      if (cur.off >= cur.len) { return -1; }
      c = cur.ptr[cur.off];
      if (c == 125) { cur.off = cur.off + 1; return 0; }
      if (c != 44) { return -1; }
      cur.off = cur.off + 1;
    }
  }
  if (c == 91) {
    cur.off = cur.off + 1;
    json_cursor_skip_ws(cur);
    if (cur.off < cur.len && cur.ptr[cur.off] == 93) { cur.off = cur.off + 1; return 0; }
    loop {
      if (json_cursor_skip_value_impl(cur) != 0) { return -1; }
      json_cursor_skip_ws(cur);
      if (cur.off >= cur.len) { return -1; }
      c = cur.ptr[cur.off];
      if (c == 93) { cur.off = cur.off + 1; return 0; }
      if (c != 44) { return -1; }
      cur.off = cur.off + 1;
    }
  }
  if (c == 110 && json_parse_null_c(p, rem, &consumed) != 0) { cur.off = cur.off + consumed; return 0; }
  if (json_parse_bool_c(p, rem, &dummy, &consumed) != 0) { cur.off = cur.off + consumed; return 0; }
  if (json_parse_number_c(p, rem, &dv, &consumed) == 0) { cur.off = cur.off + consumed; return 0; }
  return -1;
}

/** Exported function `json_cursor_init_c`.
 * Implements `json_cursor_init_c`.
 * @param cur *JsonCursor
 * @param ptr *u8
 * @param len i32
 * @return void
 */
export function json_cursor_init_c(cur: *JsonCursor, ptr: *u8, len: i32): void {
  if (cur == 0) { return; }
  cur.ptr = ptr;
  cur.len = len;
  cur.off = 0;
}

/** Internal function `json_cursor_enter_object_c`.
 * Implements `json_cursor_enter_object_c`.
 * @param cur *JsonCursor
 * @return i32
 */
function json_cursor_enter_object_c(cur: *JsonCursor): i32 {
  if (cur == 0) { return -1; }
  json_cursor_skip_ws(cur);
  if (cur.off >= cur.len || cur.ptr[cur.off] != 123) { return -1; }
  cur.off = cur.off + 1;
  json_cursor_skip_ws(cur);
  return 0;
}

/* See implementation. */
let g_json_object_keybuf: u8[64] = [];
/* See implementation. */
let g_json_object_key_len: i32 = 0;
/* See implementation. */
let g_json_decode_consumed: i32 = 0;
/** Internal function `json_cursor_load_into_c`.
 * Implements `json_cursor_load_into_c`.
 * @param dst *JsonCursor
 * @param src *JsonCursor
 * @return void
 */
function json_cursor_load_into_c(dst: *JsonCursor, src: *JsonCursor): void {
  let p: *u8 = 0 as *u8;
  let ln: i32 = 0;
  let of: i32 = 0;
  if (dst == 0 || src == 0) { return; }
  p = src.ptr;
  ln = src.len;
  of = src.off;
  json_cursor_write_fields(dst, p, ln, of);
}

/** Internal function `json_decode_consumed_ptr_c`.
 * Implements `json_decode_consumed_ptr_c`.
 * @return *i32
 */
function json_decode_consumed_ptr_c(): *i32 {
  return &g_json_decode_consumed;
}

/** Internal function `json_object_keybuf_ptr_c`.
 * Implements `json_object_keybuf_ptr_c`.
 * @return *u8
 */
function json_object_keybuf_ptr_c(): *u8 {
  return &g_json_object_keybuf[0];
}

/** Internal function `json_object_key_len_ptr_c`.
 * Implements `json_object_key_len_ptr_c`.
 * @return *i32
 */
function json_object_key_len_ptr_c(): *i32 {
  return &g_json_object_key_len;
}

/** Internal function `json_cursor_value_ptr_at_c`.
 * Implements `json_cursor_value_ptr_at_c`.
 * @param c *JsonCursor
 * @return *u8
 */
function json_cursor_value_ptr_at_c(c: *JsonCursor): *u8 {
  if (c == 0) { return 0 as *u8; }
  return &c.ptr[c.off];
}

/** Internal function `json_cursor_value_len_at_c`.
 * Implements `json_cursor_value_len_at_c`.
 * @param c *JsonCursor
 * @return i32
 */
function json_cursor_value_len_at_c(c: *JsonCursor): i32 {
  if (c == 0) { return 0; }
  return c.len - c.off;
}

/* See implementation. */
function json_cursor_object_next_c(cur: *JsonCursor, key_buf: *u8, key_cap: i32,
  key_len: *i32): i32 {
  let consumed: i32 = 0;
  let kl: i32 = 0;
  if (cur == 0 || key_buf == 0 || key_cap <= 0) { return -1; }
  json_cursor_skip_ws(cur);
  if (cur.off >= cur.len) { return -1; }
  if (cur.ptr[cur.off] == 125) { cur.off = cur.off + 1; return 0; }
  if (cur.off > 0 && cur.ptr[cur.off] == 44) { cur.off = cur.off + 1; }
  json_cursor_skip_ws(cur);
  if (cur.off >= cur.len || cur.ptr[cur.off] != 34) { return -1; }
  kl = json_parse_string_c(&cur.ptr[cur.off], cur.len - cur.off, key_buf, key_cap, &consumed);
  if (kl < 0) { return -1; }
  key_buf[kl] = 0;
  if (key_len != 0) { key_len[0] = kl; }
  cur.off = cur.off + consumed;
  json_cursor_skip_ws(cur);
  if (cur.off >= cur.len || cur.ptr[cur.off] != 58) { return -1; }
  cur.off = cur.off + 1;
  json_cursor_skip_ws(cur);
  return 1;
}

/** Internal function `json_cursor_skip_value_c`.
 * Implements `json_cursor_skip_value_c`.
 * @param cur *JsonCursor
 * @return i32
 */
function json_cursor_skip_value_c(cur: *JsonCursor): i32 {
  return json_cursor_skip_value_impl(cur);
}

/** Internal function `json_skip_value_c`.
 * Implements `json_skip_value_c`.
 * @param ptr *u8
 * @param len i32
 * @param consumed *i32
 * @return i32
 */
function json_skip_value_c(ptr: *u8, len: i32, consumed: *i32): i32 {
  let cur: JsonCursor;
  if (ptr == 0 || len < 0 || consumed == 0) { return -1; }
  json_cursor_init_c(&cur, ptr, len);
  if (json_cursor_skip_value_c(&cur) != 0) { return -1; }
  consumed[0] = cur.off;
  return 0;
}

/** Internal function `json_parse_string_view_c`.
 * Implements `json_parse_string_view_c`.
 * @param ptr *u8
 * @param len i32
 * @param out_len *i32
 * @param consumed *i32
 * @return *u8
 */
function json_parse_string_view_c(ptr: *u8, len: i32, out_len: *i32, consumed: *i32): *u8 {
  let i: i32 = 0;
  if (ptr == 0 || len < 2 || ptr[0] != 34 || out_len == 0 || consumed == 0) { return 0 as *u8; }
  i = 1;
  while (i < len) {
    if (ptr[i] == 92) {
      out_len[0] = JSON_VIEW_NEEDS_COPY;
      consumed[0] = 0;
      return 0 as *u8;
    }
    if (ptr[i] == 34) {
      out_len[0] = i - 1;
      consumed[0] = i + 1;
      return &ptr[1];
    }
    i = i + 1;
  }
  return 0 as *u8;
}

/** Internal function `json_cursor_enter_array_c`.
 * Implements `json_cursor_enter_array_c`.
 * @param cur *JsonCursor
 * @return i32
 */
function json_cursor_enter_array_c(cur: *JsonCursor): i32 {
  if (cur == 0) { return -1; }
  json_cursor_skip_ws(cur);
  if (cur.off >= cur.len || cur.ptr[cur.off] != 91) { return -1; }
  cur.off = cur.off + 1;
  json_cursor_skip_ws(cur);
  return 0;
}

/** Internal function `json_cursor_array_has_elem_c`.
 * Implements `json_cursor_array_has_elem_c`.
 * @param cur *JsonCursor
 * @return i32
 */
function json_cursor_array_has_elem_c(cur: *JsonCursor): i32 {
  if (cur == 0) { return -1; }
  json_cursor_skip_ws(cur);
  if (cur.off >= cur.len) { return -1; }
  if (cur.ptr[cur.off] == 93) {
    cur.off = cur.off + 1;
    return 0;
  }
  if (cur.ptr[cur.off] == 44) {
    cur.off = cur.off + 1;
    json_cursor_skip_ws(cur);
    if (cur.off >= cur.len) { return -1; }
    if (cur.ptr[cur.off] == 93) {
      cur.off = cur.off + 1;
      return 0;
    }
  }
  return 1;
}

/** Internal function `json_cursor_value_type_c`.
 * Implements `json_cursor_value_type_c`.
 * @param cur *JsonCursor
 * @return i32
 */
function json_cursor_value_type_c(cur: *JsonCursor): i32 {
  let c: u8 = 0;
  if (cur == 0 || cur.off >= cur.len) { return 0; }
  json_cursor_skip_ws(cur);
  if (cur.off >= cur.len) { return 0; }
  c = cur.ptr[cur.off];
  if (c == 34) { return 1; }
  if (c == 123) { return 3; }
  if (c == 91) { return 4; }
  if (c == 110) { return 5; }
  if (c == 116 || c == 102) { return 6; }
  if (c == 45 || (c >= 48 && c <= 57)) { return 2; }
  return 0;
}

/** Internal function `json_decode_i32_at_c`.
 * Implements `json_decode_i32_at_c`.
 * @param ptr *u8
 * @param len i32
 * @param consumed *i32
 * @param out *i32
 * @return i32
 */
function json_decode_i32_at_c(ptr: *u8, len: i32, consumed: *i32, out: *i32): i32 {
  let dv: f64 = 0.0;
  let con: i32 = 0;
  if (ptr == 0 || consumed == 0 || out == 0) { return -1; }
  if (json_parse_number_c(ptr, len, &dv, &con) != 0) { return -1; }
  consumed[0] = con;
  out[0] = dv as i32;
  return 0;
}

/** Internal function `json_decode_f64_at_c`.
 * Implements `json_decode_f64_at_c`.
 * @param ptr *u8
 * @param len i32
 * @param consumed *i32
 * @param out *f64
 * @return i32
 */
function json_decode_f64_at_c(ptr: *u8, len: i32, consumed: *i32, out: *f64): i32 {
  let dv: f64 = 0.0;
  let con: i32 = 0;
  if (ptr == 0 || consumed == 0 || out == 0) { return -1; }
  if (json_parse_number_c(ptr, len, &dv, &con) != 0) { return -1; }
  consumed[0] = con;
  out[0] = dv;
  return 0;
}

/** Internal function `json_decode_bool_at_c`.
 * Implements `json_decode_bool_at_c`.
 * @param ptr *u8
 * @param len i32
 * @param consumed *i32
 * @param out *i32
 * @return i32
 */
function json_decode_bool_at_c(ptr: *u8, len: i32, consumed: *i32, out: *i32): i32 {
  let con: i32 = 0;
  if (ptr == 0 || consumed == 0 || out == 0) { return -1; }
  if (json_parse_bool_c(ptr, len, out, &con) == 0) { return -1; }
  consumed[0] = con;
  return 0;
}

/* See implementation. */
function json_decode_string_at_c(ptr: *u8, len: i32, out: *u8, out_cap: i32,
  out_len: *i32, consumed: *i32): i32 {
  let con: i32 = 0;
  let n: i32 = 0;
  if (ptr == 0 || out == 0 || out_len == 0 || consumed == 0) { return -1; }
  n = json_parse_string_c(ptr, len, out, out_cap, &con);
  if (n < 0) { return -1; }
  out_len[0] = n;
  consumed[0] = con;
  return 0;
}

/** Internal function `json_key_eq`.
 * Implements `json_key_eq`.
 * @param key_buf *u8
 * @param key_len i32
 * @param key *u8
 * @param want_len i32
 * @return i32
 */
function json_key_eq(key_buf: *u8, key_len: i32, key: *u8, want_len: i32): i32 {
  let i: i32 = 0;
  if (key_len != want_len) { return 0; }
  if (want_len <= 0) { return 1; }
  while (i < want_len) {
    if (key_buf[i] != key[i]) { return 0; }
    i = i + 1;
  }
  return 1;
}

/** Internal function `json_key_eq_path`.
 * Implements `json_key_eq_path`.
 * @param key_buf *u8
 * @param key_len i32
 * @param path *u8
 * @param path_off i32
 * @param want_len i32
 * @return i32
 */
function json_key_eq_path(key_buf: *u8, key_len: i32, path: *u8, path_off: i32, want_len: i32): i32 {
  let i: i32 = 0;
  if (key_len != want_len) { return 0; }
  if (want_len <= 0) { return 1; }
  while (i < want_len) {
    if (key_buf[i] != path[path_off + i]) { return 0; }
    i = i + 1;
  }
  return 1;
}

/** Internal function `json_decode_i32_at_cursor_c`.
 * Implements `json_decode_i32_at_cursor_c`.
 * @param cur *JsonCursor
 * @param consumed *i32
 * @param out *i32
 * @return i32
 */
function json_decode_i32_at_cursor_c(cur: *JsonCursor, consumed: *i32, out: *i32): i32 {
  return json_decode_i32_at_c(json_cursor_value_ptr_at_c(cur), json_cursor_value_len_at_c(cur),
    consumed, out);
}

/** Internal function `json_decode_bool_at_cursor_c`.
 * Implements `json_decode_bool_at_cursor_c`.
 * @param cur *JsonCursor
 * @param consumed *i32
 * @param out *i32
 * @return i32
 */
function json_decode_bool_at_cursor_c(cur: *JsonCursor, consumed: *i32, out: *i32): i32 {
  return json_decode_bool_at_c(json_cursor_value_ptr_at_c(cur), json_cursor_value_len_at_c(cur),
    consumed, out);
}

/* See implementation. */
function json_decode_string_at_cursor_c(cur: *JsonCursor, out: *u8, out_cap: i32, out_len: *i32,
  consumed: *i32): i32 {
  return json_decode_string_at_c(json_cursor_value_ptr_at_c(cur), json_cursor_value_len_at_c(cur),
    out, out_cap, out_len, consumed);
}

/** Internal function `json_decode_f64_at_cursor_c`.
 * Implements `json_decode_f64_at_cursor_c`.
 * @param cur *JsonCursor
 * @param consumed *i32
 * @param out *f64
 * @return i32
 */
function json_decode_f64_at_cursor_c(cur: *JsonCursor, consumed: *i32, out: *f64): i32 {
  return json_decode_f64_at_c(json_cursor_value_ptr_at_c(cur), json_cursor_value_len_at_c(cur),
    consumed, out);
}

/** Internal function `json_object_decode_i32_c`.
 * Implements `json_object_decode_i32_c`.
 * @param cur *JsonCursor
 * @param key *u8
 * @param key_len i32
 * @param out *i32
 * @return i32
 */
function json_object_decode_i32_c(cur: *JsonCursor, key: *u8, key_len: i32, out: *i32): i32 {
  let scan: JsonCursor;
  let nr: i32 = 0;
  let val_ptr: *u8 = 0 as *u8;
  let val_len: i32 = 0;
  let saved_ptr: *u8 = 0 as *u8;
  let saved_len: i32 = 0;
  let saved_off: i32 = 0;
  let rc: i32 = 0;
  if (cur == 0 || key == 0 || out == 0) { return -1; }
  saved_ptr = cur.ptr;
  saved_len = cur.len;
  saved_off = cur.off;
  scan.ptr = saved_ptr;
  scan.len = saved_len;
  scan.off = saved_off;
  if (json_cursor_enter_object_c(&scan) != 0) { return -1; }
  loop {
    nr = json_cursor_object_next_c(&scan, json_object_keybuf_ptr_c(), 64, json_object_key_len_ptr_c());
    if (nr != 1) { break; }
    if (json_key_eq(json_object_keybuf_ptr_c(), g_json_object_key_len, key, key_len) != 0) {
      val_ptr = &scan.ptr[scan.off];
      val_len = scan.len - scan.off;
      rc = json_decode_i32_at_c(val_ptr, val_len, json_decode_consumed_ptr_c(), out);
      json_cursor_write_fields(cur, saved_ptr, saved_len, saved_off);
      return rc;
    }
    if (json_cursor_skip_value_c(&scan) != 0) {
      json_cursor_write_fields(cur, saved_ptr, saved_len, saved_off);
      return -1;
    }
  }
  json_cursor_write_fields(cur, saved_ptr, saved_len, saved_off);
  if (nr < 0) { return -1; }
  return JSON_DECODE_MISSING;
}

/** Internal function `json_object_decode_bool_c`.
 * Implements `json_object_decode_bool_c`.
 * @param cur *JsonCursor
 * @param key *u8
 * @param key_len i32
 * @param out *i32
 * @return i32
 */
function json_object_decode_bool_c(cur: *JsonCursor, key: *u8, key_len: i32, out: *i32): i32 {
  let scan: JsonCursor;
  let nr: i32 = 0;
  let val_ptr: *u8 = 0 as *u8;
  let val_len: i32 = 0;
  let saved_ptr: *u8 = 0 as *u8;
  let saved_len: i32 = 0;
  let saved_off: i32 = 0;
  let rc: i32 = 0;
  if (cur == 0 || key == 0 || out == 0) { return -1; }
  saved_ptr = cur.ptr;
  saved_len = cur.len;
  saved_off = cur.off;
  scan.ptr = saved_ptr;
  scan.len = saved_len;
  scan.off = saved_off;
  if (json_cursor_enter_object_c(&scan) != 0) { return -1; }
  loop {
    nr = json_cursor_object_next_c(&scan, json_object_keybuf_ptr_c(), 64, json_object_key_len_ptr_c());
    if (nr != 1) { break; }
    if (json_key_eq(json_object_keybuf_ptr_c(), g_json_object_key_len, key, key_len) != 0) {
      val_ptr = &scan.ptr[scan.off];
      val_len = scan.len - scan.off;
      rc = json_decode_bool_at_c(val_ptr, val_len, json_decode_consumed_ptr_c(), out);
      json_cursor_write_fields(cur, saved_ptr, saved_len, saved_off);
      return rc;
    }
    if (json_cursor_skip_value_c(&scan) != 0) {
      json_cursor_write_fields(cur, saved_ptr, saved_len, saved_off);
      return -1;
    }
  }
  json_cursor_write_fields(cur, saved_ptr, saved_len, saved_off);
  if (nr < 0) { return -1; }
  return JSON_DECODE_MISSING;
}

/* See implementation. */
function json_object_decode_string_c(cur: *JsonCursor, key: *u8, key_len: i32, out: *u8,
  out_cap: i32, out_len: *i32): i32 {
  let scan: JsonCursor;
  let nr: i32 = 0;
  let val_ptr: *u8 = 0 as *u8;
  let val_len: i32 = 0;
  let saved_ptr: *u8 = 0 as *u8;
  let saved_len: i32 = 0;
  let saved_off: i32 = 0;
  if (cur == 0 || key == 0 || out == 0 || out_len == 0) { return -1; }
  saved_ptr = cur.ptr;
  saved_len = cur.len;
  saved_off = cur.off;
  scan.ptr = saved_ptr;
  scan.len = saved_len;
  scan.off = saved_off;
  if (json_cursor_enter_object_c(&scan) != 0) { return -1; }
  loop {
    nr = json_cursor_object_next_c(&scan, json_object_keybuf_ptr_c(), 64, json_object_key_len_ptr_c());
    if (nr != 1) { break; }
    if (json_key_eq(json_object_keybuf_ptr_c(), g_json_object_key_len, key, key_len) != 0) {
      val_ptr = &scan.ptr[scan.off];
      val_len = scan.len - scan.off;
      if (json_decode_string_at_c(val_ptr, val_len, out, out_cap, out_len,
        json_decode_consumed_ptr_c()) != 0) {
        json_cursor_write_fields(cur, saved_ptr, saved_len, saved_off);
        return -1;
      }
      json_cursor_write_fields(cur, saved_ptr, saved_len, saved_off);
      return 0;
    }
    if (json_cursor_skip_value_c(&scan) != 0) {
      json_cursor_write_fields(cur, saved_ptr, saved_len, saved_off);
      return -1;
    }
  }
  json_cursor_write_fields(cur, saved_ptr, saved_len, saved_off);
  if (nr < 0) { return -1; }
  return JSON_DECODE_MISSING;
}

/** Internal function `json_cursor_find_key_slice_inplace`.
 * Implements `json_cursor_find_key_slice_inplace`.
 * @param c *JsonCursor
 * @param path *u8
 * @param path_off i32
 * @param key_len i32
 * @return i32
 */
function json_cursor_find_key_slice_inplace(c: *JsonCursor, path: *u8, path_off: i32, key_len: i32): i32 {
  let scan: JsonCursor;
  let nr: i32 = 0;
  if (c == 0 || path == 0 || path_off < 0) { return -1; }
  scan.ptr = c.ptr;
  scan.len = c.len;
  scan.off = c.off;
  loop {
    nr = json_cursor_object_next_c(&scan, json_object_keybuf_ptr_c(), 64, json_object_key_len_ptr_c());
    if (nr != 1) { break; }
    if (json_key_eq_path(json_object_keybuf_ptr_c(), g_json_object_key_len, path, path_off, key_len) != 0) {
      json_cursor_write_fields(c, scan.ptr, scan.len, scan.off);
      return 0;
    }
    if (json_cursor_skip_value_c(&scan) != 0) { return -1; }
  }
  if (nr < 0) { return -1; }
  return JSON_DECODE_MISSING;
}

/** Internal function `json_cursor_find_key_inplace`.
 * Implements `json_cursor_find_key_inplace`.
 * @param c *JsonCursor
 * @param key *u8
 * @param key_len i32
 * @return i32
 */
function json_cursor_find_key_inplace(c: *JsonCursor, key: *u8, key_len: i32): i32 {
  let scan: JsonCursor;
  let nr: i32 = 0;
  if (c == 0 || key == 0) { return -1; }
  scan.ptr = c.ptr;
  scan.len = c.len;
  scan.off = c.off;
  loop {
    nr = json_cursor_object_next_c(&scan, json_object_keybuf_ptr_c(), 64, json_object_key_len_ptr_c());
    if (nr != 1) { break; }
    if (json_key_eq(json_object_keybuf_ptr_c(), g_json_object_key_len, key, key_len) != 0) {
      json_cursor_write_fields(c, scan.ptr, scan.len, scan.off);
      return 0;
    }
    if (json_cursor_skip_value_c(&scan) != 0) { return -1; }
  }
  if (nr < 0) { return -1; }
  return JSON_DECODE_MISSING;
}

/** Internal function `json_cursor_find_array_index_inplace`.
 * Implements `json_cursor_find_array_index_inplace`.
 * @param c *JsonCursor
 * @param index i32
 * @return i32
 */
function json_cursor_find_array_index_inplace(c: *JsonCursor, index: i32): i32 {
  let i: i32 = 0;
  let has: i32 = 0;
  if (c == 0 || index < 0) { return -1; }
  if (json_cursor_enter_array_c(c) != 0) { return -1; }
  loop {
    has = json_cursor_array_has_elem_c(c);
    if (has < 0) { return -1; }
    if (has == 0) { return JSON_DECODE_MISSING; }
    if (i == index) {
      return 0;
    }
    if (json_cursor_skip_value_c(c) != 0) { return -1; }
    i = i + 1;
  }
  return -1;
}

/** Internal function `json_cursor_find_key`.
 * Implements `json_cursor_find_key`.
 * @param cur *JsonCursor
 * @param key *u8
 * @param key_len i32
 * @param out_at *JsonCursor
 * @return i32
 */
function json_cursor_find_key(cur: *JsonCursor, key: *u8, key_len: i32, out_at: *JsonCursor): i32 {
  let src_ptr: *u8 = 0 as *u8;
  let src_len: i32 = 0;
  let src_off: i32 = 0;
  if (cur == 0 || key == 0 || out_at == 0) { return -1; }
  src_ptr = cur.ptr;
  src_len = cur.len;
  src_off = cur.off;
  json_cursor_write_fields(out_at, src_ptr, src_len, src_off);
  return json_cursor_find_key_inplace(out_at, key, key_len);
}

/** Internal function `json_path_seg_is_index`.
 * Implements `json_path_seg_is_index`.
 * @param path *u8
 * @param off i32
 * @param seg_len i32
 * @param out_idx *i32
 * @return i32
 */
function json_path_seg_is_index(path: *u8, off: i32, seg_len: i32, out_idx: *i32): i32 {
  let i: i32 = 0;
  let v: i32 = 0;
  if (path == 0 || seg_len <= 0 || out_idx == 0 || off < 0) { return 0; }
  while (i < seg_len) {
    if (path[off + i] < 48 || path[off + i] > 57) { return 0; }
    v = v * 10 + (path[off + i] - 48);
    i = i + 1;
  }
  out_idx[0] = v;
  return 1;
}

/** Internal function `json_cursor_find_array_index`.
 * Implements `json_cursor_find_array_index`.
 * @param cur *JsonCursor
 * @param index i32
 * @param out_at *JsonCursor
 * @return i32
 */
function json_cursor_find_array_index(cur: *JsonCursor, index: i32, out_at: *JsonCursor): i32 {
  let src_ptr: *u8 = 0 as *u8;
  let src_len: i32 = 0;
  let src_off: i32 = 0;
  if (cur == 0 || out_at == 0 || index < 0) { return -1; }
  src_ptr = cur.ptr;
  src_len = cur.len;
  src_off = cur.off;
  json_cursor_write_fields(out_at, src_ptr, src_len, src_off);
  return json_cursor_find_array_index_inplace(out_at, index);
}

/** Internal function `json_cursor_follow_path_seg_inplace`.
 * Implements `json_cursor_follow_path_seg_inplace`.
 * @param c *JsonCursor
 * @param path *u8
 * @param seg_off i32
 * @param seg_len i32
 * @return i32
 */
function json_cursor_follow_path_seg_inplace(c: *JsonCursor, path: *u8, seg_off: i32, seg_len: i32): i32 {
  let idx: i32 = 0;
  if (c == 0 || path == 0 || seg_len <= 0 || seg_off < 0) { return -1; }
  if (json_path_seg_is_index(path, seg_off, seg_len, &idx) != 0) {
    return json_cursor_find_array_index_inplace(c, idx);
  }
  return json_cursor_find_key_slice_inplace(c, path, seg_off, seg_len);
}

/* See implementation. */
function json_cursor_follow_path_seg(cur: *JsonCursor, seg: *u8, seg_len: i32,
  out_at: *JsonCursor): i32 {
  let src_ptr: *u8 = 0 as *u8;
  let src_len: i32 = 0;
  let src_off: i32 = 0;
  if (cur == 0 || seg == 0 || out_at == 0 || seg_len <= 0) { return -1; }
  src_ptr = cur.ptr;
  src_len = cur.len;
  src_off = cur.off;
  json_cursor_write_fields(out_at, src_ptr, src_len, src_off);
  return json_cursor_follow_path_seg_inplace(out_at, seg, 0, seg_len);
}

/** Internal function `json_cursor_descend_for_next`.
 * Implements `json_cursor_descend_for_next`.
 * @param at *JsonCursor
 * @param path *u8
 * @param next_i i32
 * @param path_len i32
 * @return i32
 */
function json_cursor_descend_for_next(at: *JsonCursor, path: *u8, next_i: i32, path_len: i32): i32 {
  let j: i32 = next_i;
  let idx: i32 = 0;
  if (at == 0 || next_i >= path_len) { return -1; }
  while (j < path_len && path[j] != 46) { j = j + 1; }
  if (json_path_seg_is_index(path, next_i, j - next_i, &idx) != 0) {
    if (json_cursor_value_type_c(at) != 4) { return -1; }
    return 0;
  }
  if (json_cursor_value_type_c(at) != 3) { return -1; }
  return json_cursor_enter_object_c(at);
}

/** Internal function `json_object_decode_dotted_inplace`.
 * Implements `json_object_decode_dotted_inplace`.
 * @param c *JsonCursor
 * @param path *u8
 * @param path_len i32
 * @return i32
 */
function json_object_decode_dotted_inplace(c: *JsonCursor, path: *u8, path_len: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  let rc: i32 = 0;
  if (c == 0 || path == 0 || path_len <= 0) { return -1; }
  if (json_cursor_enter_object_c(c) != 0) { return -1; }
  while (i < path_len) {
    j = i;
    while (j < path_len && path[j] != 46) { j = j + 1; }
    if (j <= i) { return -1; }
    rc = json_cursor_follow_path_seg_inplace(c, path, i, j - i);
    if (rc != 0) { return rc; }
    if (j >= path_len) {
      return 0;
    }
    rc = json_cursor_descend_for_next(c, path, j + 1, path_len);
    if (rc != 0) { return rc; }
    i = j + 1;
  }
  return -1;
}

/* See implementation. */
function json_object_decode_dotted_at(cur: *JsonCursor, path: *u8, path_len: i32,
  out_at: *JsonCursor): i32 {
  let src_ptr: *u8 = 0 as *u8;
  let src_len: i32 = 0;
  let src_off: i32 = 0;
  if (cur == 0 || path == 0 || out_at == 0 || path_len <= 0) { return -1; }
  src_ptr = cur.ptr;
  src_len = cur.len;
  src_off = cur.off;
  json_cursor_write_fields(out_at, src_ptr, src_len, src_off);
  return json_object_decode_dotted_inplace(out_at, path, path_len);
}

/** Internal function `json_object_decode_dotted_i32_c`.
 * Implements `json_object_decode_dotted_i32_c`.
 * @param cur *JsonCursor
 * @param path *u8
 * @param path_len i32
 * @param out *i32
 * @return i32
 */
function json_object_decode_dotted_i32_c(cur: *JsonCursor, path: *u8, path_len: i32, out: *i32): i32 {
  let val_ptr: *u8 = 0 as *u8;
  let val_len: i32 = 0;
  let saved_ptr: *u8 = 0 as *u8;
  let saved_len: i32 = 0;
  let saved_off: i32 = 0;
  let rc: i32 = 0;
  if (cur == 0 || path == 0 || out == 0 || path_len <= 0) { return -1; }
  saved_ptr = cur.ptr;
  saved_len = cur.len;
  saved_off = cur.off;
  rc = json_object_decode_dotted_inplace(cur, path, path_len);
  if (rc != 0) {
    json_cursor_write_fields(cur, saved_ptr, saved_len, saved_off);
    return rc;
  }
  val_ptr = json_cursor_value_ptr_at_c(cur);
  val_len = json_cursor_value_len_at_c(cur);
  rc = json_decode_i32_at_c(val_ptr, val_len, json_decode_consumed_ptr_c(), out);
  json_cursor_write_fields(cur, saved_ptr, saved_len, saved_off);
  return rc;
}

/* See implementation. */
function json_object_decode_dotted_string_c(cur: *JsonCursor, path: *u8, path_len: i32, out: *u8,
  out_cap: i32, out_len: *i32): i32 {
  let val_ptr: *u8 = 0 as *u8;
  let val_len: i32 = 0;
  let saved_ptr: *u8 = 0 as *u8;
  let saved_len: i32 = 0;
  let saved_off: i32 = 0;
  let rc: i32 = 0;
  if (cur == 0 || path == 0 || out == 0 || out_len == 0 || path_len <= 0) { return -1; }
  saved_ptr = cur.ptr;
  saved_len = cur.len;
  saved_off = cur.off;
  rc = json_object_decode_dotted_inplace(cur, path, path_len);
  if (rc != 0) {
    json_cursor_write_fields(cur, saved_ptr, saved_len, saved_off);
    return rc;
  }
  val_ptr = json_cursor_value_ptr_at_c(cur);
  val_len = json_cursor_value_len_at_c(cur);
  rc = json_decode_string_at_c(val_ptr, val_len, out, out_cap, out_len, json_decode_consumed_ptr_c());
  json_cursor_write_fields(cur, saved_ptr, saved_len, saved_off);
  return rc;
}

/** Internal function `json_object_decode_dotted_bool_c`.
 * Implements `json_object_decode_dotted_bool_c`.
 * @param cur *JsonCursor
 * @param path *u8
 * @param path_len i32
 * @param out *i32
 * @return i32
 */
function json_object_decode_dotted_bool_c(cur: *JsonCursor, path: *u8, path_len: i32, out: *i32): i32 {
  let val_ptr: *u8 = 0 as *u8;
  let val_len: i32 = 0;
  let saved_ptr: *u8 = 0 as *u8;
  let saved_len: i32 = 0;
  let saved_off: i32 = 0;
  let rc: i32 = 0;
  if (cur == 0 || path == 0 || out == 0 || path_len <= 0) { return -1; }
  saved_ptr = cur.ptr;
  saved_len = cur.len;
  saved_off = cur.off;
  rc = json_object_decode_dotted_inplace(cur, path, path_len);
  if (rc != 0) {
    json_cursor_write_fields(cur, saved_ptr, saved_len, saved_off);
    return rc;
  }
  val_ptr = json_cursor_value_ptr_at_c(cur);
  val_len = json_cursor_value_len_at_c(cur);
  rc = json_decode_bool_at_c(val_ptr, val_len, json_decode_consumed_ptr_c(), out);
  json_cursor_write_fields(cur, saved_ptr, saved_len, saved_off);
  return rc;
}

/** Internal function `json_object_decode_dotted_f64_c`.
 * Implements `json_object_decode_dotted_f64_c`.
 * @param cur *JsonCursor
 * @param path *u8
 * @param path_len i32
 * @param out *f64
 * @return i32
 */
function json_object_decode_dotted_f64_c(cur: *JsonCursor, path: *u8, path_len: i32, out: *f64): i32 {
  let val_ptr: *u8 = 0 as *u8;
  let val_len: i32 = 0;
  let saved_ptr: *u8 = 0 as *u8;
  let saved_len: i32 = 0;
  let saved_off: i32 = 0;
  let rc: i32 = 0;
  if (cur == 0 || path == 0 || out == 0 || path_len <= 0) { return -1; }
  saved_ptr = cur.ptr;
  saved_len = cur.len;
  saved_off = cur.off;
  rc = json_object_decode_dotted_inplace(cur, path, path_len);
  if (rc != 0) {
    json_cursor_write_fields(cur, saved_ptr, saved_len, saved_off);
    return rc;
  }
  val_ptr = json_cursor_value_ptr_at_c(cur);
  val_len = json_cursor_value_len_at_c(cur);
  rc = json_decode_f64_at_c(val_ptr, val_len, json_decode_consumed_ptr_c(), out);
  json_cursor_write_fields(cur, saved_ptr, saved_len, saved_off);
  return rc;
}

/** Internal function `json_smoke_decode_i32_c`.
 * Implements `json_smoke_decode_i32_c`.
 * @param doc *u8
 * @param doc_len i32
 * @param key *u8
 * @param key_len i32
 * @param out *i32
 * @return i32
 */
function json_smoke_decode_i32_c(doc: *u8, doc_len: i32, key: *u8, key_len: i32, out: *i32): i32 {
  let cur: JsonCursor;
  cur.ptr = doc;
  cur.len = doc_len;
  cur.off = 0;
  return json_object_decode_i32_c(&cur, key, key_len, out);
}

/** Internal function `json_smoke_decode_bool_c`.
 * Implements `json_smoke_decode_bool_c`.
 * @param doc *u8
 * @param doc_len i32
 * @param key *u8
 * @param key_len i32
 * @param out *i32
 * @return i32
 */
function json_smoke_decode_bool_c(doc: *u8, doc_len: i32, key: *u8, key_len: i32, out: *i32): i32 {
  let cur: JsonCursor;
  cur.ptr = doc;
  cur.len = doc_len;
  cur.off = 0;
  return json_object_decode_bool_c(&cur, key, key_len, out);
}

/* See implementation. */
function json_smoke_decode_string_c(doc: *u8, doc_len: i32, key: *u8, key_len: i32, out: *u8,
  out_cap: i32, out_len: *i32): i32 {
  let cur: JsonCursor;
  cur.ptr = doc;
  cur.len = doc_len;
  cur.off = 0;
  return json_object_decode_string_c(&cur, key, key_len, out, out_cap, out_len);
}

/* See implementation. */
function json_smoke_decode_dotted_i32_c(doc: *u8, doc_len: i32, path: *u8, path_len: i32,
  out: *i32): i32 {
  let cur: JsonCursor;
  cur.ptr = doc;
  cur.len = doc_len;
  cur.off = 0;
  return json_object_decode_dotted_i32_c(&cur, path, path_len, out);
}

/* See implementation. */
function json_smoke_decode_dotted_string_c(doc: *u8, doc_len: i32, path: *u8, path_len: i32,
  out: *u8, out_cap: i32, out_len: *i32): i32 {
  let cur: JsonCursor;
  cur.ptr = doc;
  cur.len = doc_len;
  cur.off = 0;
  return json_object_decode_dotted_string_c(&cur, path, path_len, out, out_cap, out_len);
}

/* See implementation. */
function json_smoke_decode_dotted_bool_c(doc: *u8, doc_len: i32, path: *u8, path_len: i32,
  out: *i32): i32 {
  let cur: JsonCursor;
  cur.ptr = doc;
  cur.len = doc_len;
  cur.off = 0;
  return json_object_decode_dotted_bool_c(&cur, path, path_len, out);
}

/* See implementation. */
function json_smoke_decode_dotted_f64_c(doc: *u8, doc_len: i32, path: *u8, path_len: i32,
  out: *f64): i32 {
  let cur: JsonCursor;
  cur.ptr = doc;
  cur.len = doc_len;
  cur.off = 0;
  return json_object_decode_dotted_f64_c(&cur, path, path_len, out);
}

/** Internal function `json_typed_decode_smoke_c`.
 * Implements `json_typed_decode_smoke_c`.
 * @return i32
 */
function json_typed_decode_smoke_c(): i32 {
  let age: i32 = 0;
  let ok: i32 = 0;
  let name_len: i32 = 0;
  let name: u8[16] = [];
  let dv: f64 = 0.0;
  let doc: u8[35] = [123, 34, 97, 103, 101, 34, 58, 51, 48, 44, 34, 111, 107, 34, 58, 116, 114, 117, 101, 44, 34, 110, 97, 109, 101, 34, 58, 34, 97, 108, 105, 99, 101, 34, 125];
  let nested: u8[34] = [123, 34, 117, 115, 101, 114, 34, 58, 123, 34, 110, 97, 109, 101, 34, 58, 34, 99, 97, 114, 111, 108, 34, 44, 34, 97, 103, 101, 34, 58, 52, 50, 125, 125];
  let arr_doc: u8[20] = [123, 34, 105, 116, 101, 109, 115, 34, 58, 91, 49, 48, 44, 50, 48, 44, 51, 48, 93, 125];
  let obj_arr: u8[37] = [123, 34, 117, 115, 101, 114, 115, 34, 58, 91, 123, 34, 110, 97, 109, 101, 34, 58, 34, 97, 34, 125, 44, 123, 34, 110, 97, 109, 101, 34, 58, 34, 98, 34, 125, 93, 125];
  let bool_arr: u8[27] = [123, 34, 102, 108, 97, 103, 115, 34, 58, 91, 116, 114, 117, 101, 44, 102, 97, 108, 115, 101, 44, 116, 114, 117, 101, 93, 125];
  let f64_doc: u8[43] = [123, 34, 109, 101, 116, 114, 105, 99, 115, 34, 58, 123, 34, 99, 112, 117, 34, 58, 48, 46, 55, 53, 125, 44, 34, 118, 97, 108, 117, 101, 115, 34, 58, 91, 49, 46, 53, 44, 50, 46, 53, 93, 125];
  let key_age: u8[3] = [97, 103, 101];
  let key_ok: u8[2] = [111, 107];
  let key_name: u8[4] = [110, 97, 109, 101];
  let key_miss: u8[3] = [120, 120, 120];
  let path_user_age: u8[8] = [117, 115, 101, 114, 46, 97, 103, 101];
  let path_user_name: u8[9] = [117, 115, 101, 114, 46, 110, 97, 109, 101];
  let path_items0: u8[7] = [105, 116, 101, 109, 115, 46, 48];
  let path_items2: u8[7] = [105, 116, 101, 109, 115, 46, 50];
  let path_users0name: u8[12] = [117, 115, 101, 114, 115, 46, 48, 46, 110, 97, 109, 101];
  let path_users1name: u8[12] = [117, 115, 101, 114, 115, 46, 49, 46, 110, 97, 109, 101];
  let path_flags0: u8[7] = [102, 108, 97, 103, 115, 46, 48];
  let path_flags1: u8[7] = [102, 108, 97, 103, 115, 46, 49];
  let path_metrics_cpu: u8[11] = [109, 101, 116, 114, 105, 99, 115, 46, 99, 112, 117];
  let path_values1: u8[8] = [118, 97, 108, 117, 101, 115, 46, 49];
  if (json_smoke_decode_i32_c(&doc[0], 35, &key_age[0], 3, &age) != 0 || age != 30) { return -1; }
  if (json_smoke_decode_bool_c(&doc[0], 35, &key_ok[0], 2, &ok) != 0 || ok != 1) { return -1; }
  if (json_smoke_decode_string_c(&doc[0], 35, &key_name[0], 4, &name[0], 16, &name_len) != 0 ||
    name_len != 5) { return -1; }
  if (json_smoke_decode_i32_c(&doc[0], 35, &key_miss[0], 3, &age) != JSON_DECODE_MISSING) { return -1; }
  if (json_smoke_decode_dotted_i32_c(&nested[0], 34, &path_user_age[0], 8, &age) != 0 || age != 42) { return -1; }
  if (json_smoke_decode_dotted_string_c(&nested[0], 34, &path_user_name[0], 9, &name[0], 16, &name_len) != 0 ||
    name_len != 5) { return -1; }
  if (json_smoke_decode_dotted_i32_c(&arr_doc[0], 20, &path_items0[0], 7, &age) != 0 || age != 10) { return -1; }
  if (json_smoke_decode_dotted_i32_c(&arr_doc[0], 20, &path_items2[0], 7, &age) != 0 || age != 30) { return -1; }
  if (json_smoke_decode_dotted_string_c(&obj_arr[0], 37, &path_users0name[0], 12, &name[0], 16, &name_len) != 0 ||
    name_len != 1) { return -1; }
  if (json_smoke_decode_dotted_string_c(&obj_arr[0], 37, &path_users1name[0], 12, &name[0], 16, &name_len) != 0 ||
    name_len != 1) { return -1; }
  ok = 0;
  if (json_smoke_decode_dotted_bool_c(&bool_arr[0], 27, &path_flags0[0], 7, &ok) != 0 || ok != 1) { return -1; }
  if (json_smoke_decode_dotted_bool_c(&bool_arr[0], 27, &path_flags1[0], 7, &ok) != 0 || ok != 0) { return -1; }
  dv = 0.0;
  if (json_smoke_decode_dotted_f64_c(&f64_doc[0], 43, &path_metrics_cpu[0], 11, &dv) != 0 ||
    dv < 0.74 || dv > 0.76) { return -1; }
  if (json_smoke_decode_dotted_f64_c(&f64_doc[0], 43, &path_values1[0], 8, &dv) != 0 ||
    dv < 2.49 || dv > 2.51) { return -1; }
  return 0;
}

/** Internal function `json_append_object_c`.
 * Implements `json_append_object_c`.
 * @param buf *u8
 * @param cap i32
 * @param off i32
 * @return i32
 */
function json_append_object_c(buf: *u8, cap: i32, off: i32): i32 {
  if (buf == 0 || off < 0 || off >= cap) { return -1; }
  buf[off] = 123;
  return 1;
}

/** Internal function `json_append_object_end_c`.
 * Implements `json_append_object_end_c`.
 * @param buf *u8
 * @param cap i32
 * @param off i32
 * @return i32
 */
function json_append_object_end_c(buf: *u8, cap: i32, off: i32): i32 {
  if (buf == 0 || off < 0 || off >= cap) { return -1; }
  buf[off] = 125;
  return 1;
}

/** Internal function `json_append_array_c`.
 * Implements `json_append_array_c`.
 * @param buf *u8
 * @param cap i32
 * @param off i32
 * @return i32
 */
function json_append_array_c(buf: *u8, cap: i32, off: i32): i32 {
  if (buf == 0 || off < 0 || off >= cap) { return -1; }
  buf[off] = 91;
  return 1;
}

/** Internal function `json_append_array_end_c`.
 * Implements `json_append_array_end_c`.
 * @param buf *u8
 * @param cap i32
 * @param off i32
 * @return i32
 */
function json_append_array_end_c(buf: *u8, cap: i32, off: i32): i32 {
  if (buf == 0 || off < 0 || off >= cap) { return -1; }
  buf[off] = 93;
  return 1;
}

/** Internal function `json_append_comma_c`.
 * Implements `json_append_comma_c`.
 * @param buf *u8
 * @param cap i32
 * @param off i32
 * @return i32
 */
function json_append_comma_c(buf: *u8, cap: i32, off: i32): i32 {
  if (buf == 0 || off < 0 || off >= cap) { return -1; }
  buf[off] = 44;
  return 1;
}

/** Internal function `json_append_key_c`.
 * Implements `json_append_key_c`.
 * @param buf *u8
 * @param cap i32
 * @param off i32
 * @param key *u8
 * @param key_len i32
 * @return i32
 */
function json_append_key_c(buf: *u8, cap: i32, off: i32, key: *u8, key_len: i32): i32 {
  let i: i32 = off;
  let n: i32 = 0;
  if (buf == 0 || key == 0 || key_len < 0 || off < 0) { return -1; }
  if (i >= cap) { return -1; }
  buf[i] = 34; i = i + 1;
  n = json_escape_inner(key, key_len, buf, i, cap - i);
  if (n < 0) { return -1; }
  i = i + n;
  if (i + 1 >= cap) { return -1; }
  buf[i] = 34; i = i + 1;
  buf[i] = 58; i = i + 1;
  return i - off;
}

/** Internal function `json_append_string_value_c`.
 * Implements `json_append_string_value_c`.
 * @param buf *u8
 * @param cap i32
 * @param off i32
 * @param val *u8
 * @param val_len i32
 * @return i32
 */
function json_append_string_value_c(buf: *u8, cap: i32, off: i32, val: *u8, val_len: i32): i32 {
  let i: i32 = off;
  let n: i32 = 0;
  if (buf == 0 || val == 0 || val_len < 0 || off < 0) { return -1; }
  if (i >= cap) { return -1; }
  buf[i] = 34; i = i + 1;
  n = json_escape_inner(val, val_len, buf, i, cap - i);
  if (n < 0) { return -1; }
  i = i + n;
  if (i >= cap) { return -1; }
  buf[i] = 34; i = i + 1;
  return i - off;
}

/** Internal function `json_append_number_at_c`.
 * Implements `json_append_number_at_c`.
 * @param buf *u8
 * @param cap i32
 * @param off i32
 * @param val f64
 * @return i32
 */
function json_append_number_at_c(buf: *u8, cap: i32, off: i32, val: f64): i32 {
  let tmp: u8[32] = [];
  let n: i32 = 0;
  let i: i32 = 0;
  if (buf == 0 || off < 0 || off >= cap) { return -1; }
  n = json_append_number_c(&tmp[0], 32, val);
  if (n < 0 || off + n > cap) { return -1; }
  while (i < n) {
    buf[off + i] = tmp[i];
    i = i + 1;
  }
  return n;
}

/** Internal function `json_module_anchor`.
 * Implements `json_module_anchor`.
 * @return i32
 */
function json_module_anchor(): i32 { return 0; }
