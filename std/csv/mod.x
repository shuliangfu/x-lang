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

// std.csv — CSV 解析与写回（RFC 4180）
//
// next_field / unescape / parse_row / write_row / stream：csv.x（F-csv v1）。
// escape（mod 内简化版）仍可用；write_row 经 csv.x 的 csv_escape_c（含引号双写）。

extern function next_field(ptr: *u8, len: i32, offset: i32, out_start: *i32, out_len: *i32): i32;
extern function unescape(ptr: *u8, len: i32, buf: *u8, buf_cap: i32): i32;
extern function csv_test_quoted_first(out_start: *i32, out_len: *i32): i32;
extern function csv_test_quoted_second(offset: i32, out_start: *i32, out_len: *i32): i32;
extern function csv_test_unescape_ok(buf: *u8, buf_cap: i32): i32;
extern function csv_test_unescape_fail(): i32;
extern function parse_row(ptr: *u8, len: i32, offset: i32, field_starts: *i32, field_lens: *i32, max_fields: i32, out_count: *i32): i32;
extern function write_row(blob: *u8, starts: *i32, lens: *i32, count: i32, out: *u8, out_cap: i32): i32;
extern function csv_stream_smoke_c(): i32;
extern function csv_stream_writer_append_row_c(out: *u8, out_cap: i32, out_len: *i32, blob: *u8, starts: *i32, lens: *i32, count: i32): i32;

/** 将字段转义为带引号的 CSV 单元写入 buf；返回写入长度，失败 -1。 */
function escape(ptr: *u8, len: i32, buf: *u8, buf_cap: i32): i32 {
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

/** C 层引号字段探针（第一字段）；测试专用。 */
function test_quoted_first(out_start: *i32, out_len: *i32): i32 {
  unsafe {
    return csv_test_quoted_first(out_start, out_len);
  }
}

/** C 层引号字段探针（第二字段）；测试专用。 */
function test_quoted_second(offset: i32, out_start: *i32, out_len: *i32): i32 {
  unsafe {
    return csv_test_quoted_second(offset, out_start, out_len);
  }
}

/** C 层 unescape 正例探针；测试专用。 */
function test_unescape_ok(buf: *u8, buf_cap: i32): i32 {
  unsafe {
    return csv_test_unescape_ok(buf, buf_cap);
  }
}

/** C 层 unescape 缓冲不足探针；测试专用。 */
function test_unescape_fail(): i32 {
  unsafe {
    return csv_test_unescape_fail();
  }
}

/* --- STD-128：流式 reader/writer（单缓冲区内 offset 迭代） --- */

/** 流式读：在 ptr[0..len) 上顺序 parse_row。 */
allow(padding) struct StreamCsvReader {
  ptr: *u8;
  len: i32;
  offset: i32;
}

/** 流式写：多行 write_row 追加到同一 out 缓冲。 */
allow(padding) struct StreamCsvWriter {
  out: *u8;
  out_cap: i32;
  out_len: i32;
}

/**
 * 构造读游标（原 stream_reader_init；与 writer 参数不同，无法合并为单一 init）。
 * 绑定读缓冲；offset 置 0。
 */
function reader(ptr: *u8, len: i32): StreamCsvReader {
  return StreamCsvReader { ptr: ptr, len: len, offset: 0 };
}

/**
 * 读下一行；0=成功，1=EOF，<0=错误。
 * field_starts/lens 为行内字段在 ptr 上的绝对偏移（与 parse_row 一致）。
 */
function next_row(r: *StreamCsvReader, field_starts: *i32, field_lens: *i32, max_fields: i32, out_count: *i32): i32 {
  let next: i32 = 0;
  let nfields: i32 = 0;
  if (r == 0 || out_count == 0) { return -1; }
  if (r.offset >= r.len) { return 1; }
  unsafe {
    next = parse_row(r.ptr, r.len, r.offset, field_starts, field_lens, max_fields, out_count);
    nfields = *out_count;
  }
  if (next < 0) { return -1; }
  if (nfields <= 0 && next >= r.len) { return 1; }
  r.offset = next;
  return 0;
}

/** 是否已读完（offset >= len）。 */
function eof(r: StreamCsvReader): i32 {
  if (r.offset >= r.len) { return 1; }
  return 0;
}

/**
 * 构造写游标（原 stream_writer_init）。
 * 绑定写缓冲；out_len 置 0。
 */
function writer(out: *u8, out_cap: i32): StreamCsvWriter {
  return StreamCsvWriter { out: out, out_cap: out_cap, out_len: 0 };
}

/**
 * 追加一行 CSV（字段来自 blob + starts/lens）；行末自动加 '\\n'。
 * 0 成功；-1 缓冲不足或 write_row 失败。
 */
function append_row(w: *StreamCsvWriter, blob: *u8, starts: *i32, lens: *i32, count: i32): i32 {
  if (w == 0) { return -1; }
  unsafe {
    return csv_stream_writer_append_row_c(w.out, w.out_cap, &w.out_len, blob, starts, lens, count);
  }
}

/** 当前已写入字节数（含行尾换行）。 */
function len(w: StreamCsvWriter): i32 {
  return w.out_len;
}

/** STD-128：C 层多行流式烟测；0 通过。 */
function smoke(): i32 {
  unsafe {
    return csv_stream_smoke_c();
  }
}
