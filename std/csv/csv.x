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

// std/csv/csv.x — CSV 按行解析与写回（F-csv v1；替代 csv.c）
//
// 【文件职责】
// RFC 4180 next_field / escape / unescape / parse_row / write_row / 流式 smoke。
// mod.x 中 escape 为简化版；本文件 csv_escape_c 含引号双写，供 write_row 使用。

/** 从 offset 起找下一字段（RFC 4180 引号字段与普通字段）。 */
function csv_next_field_c(ptr: *u8, len: i32, offset: i32, out_start: *i32, out_len: *i32): i32 {
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
  /* 引号字段 */
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

/** codegen 链接名 std_csv_next_field。 */
function std_csv_next_field(ptr: *u8, len: i32, offset: i32, out_start: *i32, out_len: *i32): i32 {
  return csv_next_field_c(ptr, len, offset, out_start, out_len);
}

/** tests/csv 引号字段探针（第一字段）。 */
function std_csv_csv_test_quoted_first(out_start: *i32, out_len: *i32): i32 {
  let q: u8[8];
  q[0] = 34; q[1] = 97; q[2] = 44; q[3] = 98; q[4] = 34; q[5] = 44; q[6] = 99; q[7] = 0;
  return csv_next_field_c(&q[0], 8, 0, out_start, out_len);
}

/** tests/csv 引号字段探针（第二字段）。 */
function std_csv_csv_test_quoted_second(offset: i32, out_start: *i32, out_len: *i32): i32 {
  let q: u8[8];
  q[0] = 34; q[1] = 97; q[2] = 44; q[3] = 98; q[4] = 34; q[5] = 44; q[6] = 99; q[7] = 0;
  return csv_next_field_c(&q[0], 8, offset, out_start, out_len);
}

/** RFC 4180 引号转义写入 buf；返回写入长度，不足 -1。 */
function csv_escape_c(ptr: *u8, len: i32, buf: *u8, buf_cap: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  if (ptr == 0 || buf == 0 || buf_cap < 2) { return -1; }
  buf[i] = 34;
  i = i + 1;
  while (j < len && i < buf_cap - 1) {
    if (ptr[j] == 34) {
      if (i + 2 > buf_cap) { return -1; }
      buf[i] = 34;
      i = i + 1;
      buf[i] = 34;
      i = i + 1;
    } else {
      buf[i] = ptr[j];
      i = i + 1;
    }
    j = j + 1;
  }
  if (i >= buf_cap - 1) { return -1; }
  buf[i] = 34;
  i = i + 1;
  return i;
}

/** 引号字段 raw 内容 unescape（"" → "）。 */
function std_csv_unescape(ptr: *u8, len: i32, buf: *u8, buf_cap: i32): i32 {
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

/** tests/csv unescape 正例。 */
function std_csv_csv_test_unescape_ok(buf: *u8, buf_cap: i32): i32 {
  let raw: u8[4];
  raw[0] = 34; raw[1] = 34; raw[2] = 97; raw[3] = 0;
  return std_csv_unescape(&raw[0], 3, buf, buf_cap);
}

/** tests/csv unescape 缓冲不足应 -1。 */
function std_csv_csv_test_unescape_fail(): i32 {
  let tiny: u8[1];
  let raw: u8[4];
  raw[0] = 34; raw[1] = 34; raw[2] = 97; raw[3] = 0;
  return std_csv_unescape(&raw[0], 3, &tiny[0], 1);
}

/** import std.csv 裸名 next_field。#[no_mangle] 让跨模块调用与定义符号一致。 */
#[no_mangle]
function next_field(ptr: *u8, len: i32, offset: i32, out_start: *i32, out_len: *i32): i32 {
  return std_csv_next_field(ptr, len, offset, out_start, out_len);
}

function csv_test_quoted_first(out_start: *i32, out_len: *i32): i32 {
  return std_csv_csv_test_quoted_first(out_start, out_len);
}

function csv_test_quoted_second(offset: i32, out_start: *i32, out_len: *i32): i32 {
  return std_csv_csv_test_quoted_second(offset, out_start, out_len);
}

function csv_test_unescape_ok(buf: *u8, buf_cap: i32): i32 {
  return std_csv_csv_test_unescape_ok(buf, buf_cap);
}

function csv_test_unescape_fail(): i32 {
  return std_csv_csv_test_unescape_fail();
}

/** 判断字段是否须 RFC 4180 引号包裹。 */
function csv_field_needs_quote(ptr: *u8, len: i32): i32 {
  let j: i32 = 0;
  if (ptr == 0) { return 0; }
  while (j < len) {
    let c: u8 = ptr[j];
    if (c == 44 || c == 34 || c == 10 || c == 13) { return 1; }
    j = j + 1;
  }
  return 0;
}

/** 解析一行 CSV；field_starts/lens 为绝对偏移。 */
function csv_parse_row_c(ptr: *u8, len: i32, offset: i32, field_starts: *i32, field_lens: *i32,
                         max_fields: i32, out_count: *i32): i32 {
  let pos: i32 = 0;
  let start: i32 = 0;
  let flen: i32 = 0;
  let next: i32 = 0;
  if (ptr == 0 || field_starts == 0 || field_lens == 0 || out_count == 0 || max_fields <= 0) {
    return -1;
  }
  out_count[0] = 0;
  if (offset < 0 || offset > len) { return -1; }
  if (offset == len) { return len; }
  pos = offset;
  while (out_count[0] < max_fields && pos <= len) {
    start = 0;
    flen = 0;
    next = csv_next_field_c(ptr, len, pos, &start, &flen);
    field_starts[out_count[0]] = start;
    field_lens[out_count[0]] = flen;
    out_count[0] = out_count[0] + 1;
    if (next >= len) { return len; }
    if (next > 0 && ptr[next - 1] == 10) { return next; }
    if (next > 1 && ptr[next - 2] == 13 && ptr[next - 1] == 10) { return next; }
    pos = next;
  }
  return pos;
}

/** 将多列字段写入一行 CSV（无尾随换行）。 */
function csv_write_row_c(blob: *u8, starts: *i32, lens: *i32, count: i32, out: *u8, out_cap: i32): i32 {
  let o: i32 = 0;
  let i: i32 = 0;
  let fp: *u8 = 0 as *u8;
  let fl: i32 = 0;
  let ew: i32 = 0;
  let k: i32 = 0;
  if (blob == 0 || starts == 0 || lens == 0 || out == 0 || count < 0) { return -1; }
  while (i < count) {
    fp = blob + starts[i];
    fl = lens[i];
    if (i > 0) {
      if (o >= out_cap) { return -1; }
      out[o] = 44;
      o = o + 1;
    }
    if (csv_field_needs_quote(fp, fl) != 0) {
      ew = csv_escape_c(fp, fl, out + o, out_cap - o);
      if (ew < 0) { return -1; }
      o = o + ew;
    } else {
      if (o + fl > out_cap) { return -1; }
      k = 0;
      while (k < fl) {
        out[o] = fp[k];
        o = o + 1;
        k = k + 1;
      }
    }
    i = i + 1;
  }
  return o;
}

/** 裸名 parse_row / write_row 链接别名。 */
function parse_row(ptr: *u8, len: i32, offset: i32, field_starts: *i32, field_lens: *i32,
                   max_fields: i32, out_count: *i32): i32 {
  return csv_parse_row_c(ptr, len, offset, field_starts, field_lens, max_fields, out_count);
}

function write_row(blob: *u8, starts: *i32, lens: *i32, count: i32, out: *u8, out_cap: i32): i32 {
  return csv_write_row_c(blob, starts, lens, count, out, out_cap);
}

/** STD-128：向 out 缓冲追加一行 CSV 与换行。 */
function csv_stream_writer_append_row_c(out: *u8, out_cap: i32, out_len: *i32, blob: *u8,
                                      starts: *i32, lens: *i32, count: i32): i32 {
  let n: i32 = 0;
  let left: i32 = 0;
  if (out == 0 || out_len == 0 || blob == 0 || starts == 0 || lens == 0) { return -1; }
  if (out_len[0] < 0 || out_len[0] > out_cap) { return -1; }
  left = out_cap - out_len[0];
  if (left <= 1) { return -1; }
  n = csv_write_row_c(blob, starts, lens, count, out + out_len[0], left - 1);
  if (n < 0) { return -1; }
  out_len[0] = out_len[0] + n;
  out[out_len[0]] = 10;
  out_len[0] = out_len[0] + 1;
  return 0;
}

/** STD-128 多行 reader/writer 往返烟测；0 通过。 */
function csv_stream_smoke_c(): i32 {
  let blob: u8[16];
  let starts1: i32[3];
  let lens1: i32[3];
  let starts2: i32[3];
  let lens2: i32[3];
  let out: u8[128];
  let out_len: i32 = 0;
  let field_starts: i32[4];
  let field_lens: i32[4];
  let cnt: i32 = 0;
  let off: i32 = 0;
  let rc: i32 = 0;
  blob[0] = 97; blob[1] = 108; blob[2] = 105; blob[3] = 99; blob[4] = 101;
  blob[5] = 98; blob[6] = 111; blob[7] = 98; blob[8] = 49; blob[9] = 50;
  blob[10] = 51;
  starts1[0] = 0; starts1[1] = 5; starts1[2] = 8;
  lens1[0] = 5; lens1[1] = 3; lens1[2] = 3;
  starts2[0] = 10; starts2[1] = 11; starts2[2] = 12;
  lens2[0] = 1; lens2[1] = 0; lens2[2] = 1;
  if (csv_stream_writer_append_row_c(&out[0], 128, &out_len, &blob[0], &starts1[0], &lens1[0], 3) != 0) {
    return 1;
  }
  if (csv_stream_writer_append_row_c(&out[0], 128, &out_len, &blob[0], &starts2[0], &lens2[0], 3) != 0) {
    return 2;
  }
  if (out_len <= 0) { return 3; }
  rc = csv_parse_row_c(&out[0], out_len, 0, &field_starts[0], &field_lens[0], 4, &cnt);
  if (rc < 0 || cnt != 3 || field_lens[0] != 5 || field_lens[1] != 3 || field_lens[2] != 3) {
    return 4;
  }
  off = rc;
  cnt = 0;
  rc = csv_parse_row_c(&out[0], out_len, off, &field_starts[0], &field_lens[0], 4, &cnt);
  if (rc < 0 || cnt != 3 || field_lens[1] != 0) { return 5; }
  off = rc;
  cnt = 0;
  rc = csv_parse_row_c(&out[0], out_len, off, &field_starts[0], &field_lens[0], 4, &cnt);
  if (rc < out_len || cnt != 0) { return 6; }
  return 0;
}

/** mod.x extern unescape 链接名。#[no_mangle] 让跨模块调用与定义符号一致。 */
#[no_mangle]
function unescape(ptr: *u8, len: i32, buf: *u8, buf_cap: i32): i32 {
  return std_csv_unescape(ptr, len, buf, buf_cap);
}
