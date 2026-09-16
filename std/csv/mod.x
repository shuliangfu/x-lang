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

// PLATFORM: SHARED — import("std.csv") method surface is this file.
// Leaf algorithms live in csv.x as csv_*_c (--bare-impl naked symbols).
// parse_row / write_row are thin wrappers over csv_parse_row_c / csv_write_row_c
// (STD-036). Do not copy those bodies here.

/**
 * See implementation.
 * See implementation.
 */
export function next_field(ptr: *u8, len: i32, offset: i32, out_start: *i32, out_len: *i32): i32 {
  let start: i32 = 0;
  let pos: i32 = 0;
  if (ptr == 0 || len < 0 || offset < 0 || out_start == 0 || out_len == 0) {
    if (offset >= 0 && offset <= len) { return offset; }
    return len;
  }
  if (offset >= len) {
    out_start[0] = len;
    out_len[0] = 0;
    return len;
  }
  if (ptr[offset] == 34) {
    start = offset + 1;
    pos = start;
    while (pos < len) {
      if (ptr[pos] == 34) {
        if (pos + 1 < len && ptr[pos + 1] == 34) {
          pos = pos + 2;
        } else {
          break;
        }
      }
      pos = pos + 1;
    }
    out_start[0] = start;
    out_len[0] = pos - start;
    offset = pos + 1;
    if (offset < len && (ptr[offset] == 44 || ptr[offset] == 10 || ptr[offset] == 13)) {
      if (ptr[offset] == 44) {
        offset = offset + 1;
      } else if (ptr[offset] == 13) {
        offset = offset + 1;
        if (offset < len && ptr[offset] == 10) { offset = offset + 1; }
      } else {
        offset = offset + 1;
      }
    }
    return offset;
  }
  out_start[0] = offset;
  while (offset < len && ptr[offset] != 44 && ptr[offset] != 10 && ptr[offset] != 13) {
    offset = offset + 1;
  }
  out_len[0] = offset - out_start[0];
  if (offset < len) {
    if (ptr[offset] == 44) {
      offset = offset + 1;
    } else if (ptr[offset] == 13) {
      offset = offset + 1;
      if (offset < len && ptr[offset] == 10) { offset = offset + 1; }
    } else if (ptr[offset] == 10) {
      offset = offset + 1;
    }
  }
  return offset;
}
/** Exported function `unescape`.
 * Implements `unescape`.
 * @param ptr *u8
 * @param len i32
 * @param buf *u8
 * @param buf_cap i32
 * @return i32
 */
export function unescape(ptr: *u8, len: i32, buf: *u8, buf_cap: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  if (ptr == 0 || buf == 0 || buf_cap < 0) { return -1; }
  while (j < len) {
    if (ptr[j] == 34 && j + 1 < len && ptr[j + 1] == 34) {
      if (i >= buf_cap) { return -1; }
      buf[i] = 34;
      i = i + 1;
      j = j + 2;
    } else {
      if (i >= buf_cap) { return -1; }
      buf[i] = ptr[j];
      i = i + 1;
      j = j + 1;
    }
  }
  return i;
}
/* See implementation. */

/** Exported function `escape`.
 * Implements `escape`.
 * @param ptr *u8
 * @param len i32
 * @param buf *u8
 * @param buf_cap i32
 * @return i32
 */
export function escape(ptr: *u8, len: i32, buf: *u8, buf_cap: i32): i32 {
  if (buf_cap < 2) {
    return -1;
  }
  let i: i32 = 0;
  buf[i] = 34;
  i = i + 1;
  let j: i32 = 0;
  if (i + len + 1 >= buf_cap) {
    return -1;
  }
  while (j < len) {
    buf[i] = ptr[j];
    i = i + 1;
    j = j + 1;
  }
  if (i >= buf_cap - 1) {
    return -1;
  }
  buf[i] = 34;
  i = i + 1;
  return i;
}

extern function csv_parse_row_c(ptr: *u8, len: i32, offset: i32, field_starts: *i32, field_lens: *i32,
  max_fields: i32, out_count: *i32): i32;
extern function csv_write_row_c(blob: *u8, starts: *i32, lens: *i32, count: i32, out: *u8, out_cap: i32): i32;

/**
 * Parse one CSV record starting at offset into starts/lens tables (STD-036).
 * Stops at LF, CRLF, or end of buffer. Does not copy field bytes.
 * @param ptr *u8 — record bytes; null rejected by csv_parse_row_c
 * @param len i32 — byte count of ptr
 * @param offset i32 — start index into ptr
 * @param field_starts *i32 — output start index per field; caller-owned
 * @param field_lens *i32 — output length per field; caller-owned
 * @param max_fields i32 — capacity of the output tables
 * @param out_count *i32 — written field count
 * @return i32 — next offset after the record, or -1 on error
 * PLATFORM: SHARED — facade over csv_parse_row_c in csv.x
 */
export function parse_row(ptr: *u8, len: i32, offset: i32, field_starts: *i32, field_lens: *i32,
  max_fields: i32, out_count: *i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = csv_parse_row_c(ptr, len, offset, field_starts, field_lens, max_fields, out_count); }
  return _rc;
}

/**
 * Write count CSV fields from blob[starts[i]..+lens[i]] into out (STD-036).
 * Quotes a field that contains comma, quote, CR, or LF via csv_escape_c.
 * Does not append a trailing newline (stream append_row does).
 * @param blob *u8 — field bytes; indices from starts/lens
 * @param starts *i32 — start index of each field in blob
 * @param lens *i32 — length of each field
 * @param count i32 — number of fields; count < 0 is error
 * @param out *u8 — destination buffer; caller-owned
 * @param out_cap i32 — capacity of out
 * @return i32 — bytes written, or -1 on error / overflow
 * PLATFORM: SHARED — facade over csv_write_row_c in csv.x
 */
export function write_row(blob: *u8, starts: *i32, lens: *i32, count: i32, out: *u8, out_cap: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = csv_write_row_c(blob, starts, lens, count, out, out_cap); }
  return _rc;
}

/** Exported function `test_quoted_first`.
 * Implements `test_quoted_first`.
 * @param out_start *i32
 * @param out_len *i32
 * @return i32
 */
export function test_quoted_first(out_start: *i32, out_len: *i32): i32 {
  let q: u8[8] = [34, 97, 44, 98, 34, 44, 99, 0];
  return next_field(&q[0], 8, 0, out_start, out_len);
}

/** Exported function `test_quoted_second`.
 * Implements `test_quoted_second`.
 * @param offset i32
 * @param out_start *i32
 * @param out_len *i32
 * @return i32
 */
export function test_quoted_second(offset: i32, out_start: *i32, out_len: *i32): i32 {
  let q: u8[8] = [34, 97, 44, 98, 34, 44, 99, 0];
  return next_field(&q[0], 8, offset, out_start, out_len);
}

/** Exported function `test_unescape_ok`.
 * Implements `test_unescape_ok`.
 * @param buf *u8
 * @param buf_cap i32
 * @return i32
 */
export function test_unescape_ok(buf: *u8, buf_cap: i32): i32 {
  let raw: u8[4] = [34, 34, 97, 0];
  return unescape(&raw[0], 3, buf, buf_cap);
}

/** Exported function `test_unescape_fail`.
 * Implements `test_unescape_fail`.
 * @return i32
 */
export function test_unescape_fail(): i32 {
  let raw: u8[4] = [34, 34, 97, 0];
  let tiny: u8[1] = [0];
  return unescape(&raw[0], 3, &tiny[0], 1);
}

/* See implementation. */

/* See implementation. */
allow(padding) struct StreamCsvReader {
  ptr: *u8;
  length: i32;
  offset: i32;
}

/* See implementation. */
allow(padding) struct StreamCsvWriter {
  out: *u8;
  out_cap: i32;
  out_len: i32;
}

/**
 * See implementation.
 * See implementation.
 */
export function reader(ptr: *u8, len: i32): StreamCsvReader {
  return { ptr: ptr, length: len, offset: 0 };
}

/**
 * See implementation.
 * See implementation.
 */
export function next_row(r: *StreamCsvReader, field_starts: *i32, field_lens: *i32, max_fields: i32, out_count: *i32): i32 {
  let next: i32 = 0;
  let n: i32 = 0;
  let st: i32 = 0;
  let ln: i32 = 0;
  let pos: i32 = 0;
  if (r == 0 || out_count == 0) { return -1; }
  if (r.offset >= r.length) { return 1; }
  pos = r.offset;
  n = 0;
  while (pos < r.length && n < max_fields) {
    next = next_field(r.ptr, r.length, pos, &st, &ln);
    if (field_starts != 0) { field_starts[n] = st; }
    if (field_lens != 0) { field_lens[n] = ln; }
    n = n + 1;
    if (next <= pos) { break; }
    pos = next;
    if (pos > 0 && pos <= r.length && r.ptr[pos - 1] == 10) { break; }
  }
  out_count[0] = n;
  if (n <= 0 && pos >= r.length) { return 1; }
  r.offset = pos;
  return 0;
}

/** Exported function `eof`.
 * Implements `eof`.
 * @param r StreamCsvReader
 * @return i32
 */
export function eof(r: StreamCsvReader): i32 {
  if (r.offset >= r.length) { return 1; }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function writer(out: *u8, out_cap: i32): StreamCsvWriter {
  return { out: out, out_cap: out_cap, out_len: 0 };
}

/**
 * See implementation.
 * See implementation.
 */
export function append_row(w: *StreamCsvWriter, blob: *u8, starts: *i32, lens: *i32, count: i32): i32 {
  let k: i32 = 0;
  let n: i32 = 0;
  if (w == 0 || w.out == 0) { return -1; }
  while (k < count) {
    if (k > 0) {
      if (w.out_len >= w.out_cap) { return -1; }
      w.out[w.out_len] = 44;
      w.out_len = w.out_len + 1;
    }
    n = escape(blob + starts[k], lens[k], w.out + w.out_len, w.out_cap - w.out_len);
    if (n < 0) { return -1; }
    w.out_len = w.out_len + n;
    k = k + 1;
  }
  if (w.out_len >= w.out_cap) { return -1; }
  w.out[w.out_len] = 10;
  w.out_len = w.out_len + 1;
  return 0;
}

/** Exported function `len`.
 * Implements `len`.
 * @param w StreamCsvWriter
 * @return i32
 */
export function length(w: StreamCsvWriter): i32 {
  return w.out_len;
}

/** Exported function `smoke`.
 * Implements `smoke`.
 * @return i32
 */
export function smoke(): i32 {
  return 0;
}
