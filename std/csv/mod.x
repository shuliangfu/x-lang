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

/**
 * next_field / unescape 体在本文件（库 -o 时 entry_module_only 不 co-emit csv.x）。
 * 符号 std_csv_next_field / std_csv_unescape 与调用端 mangle 一致。
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
/* 库 -o 不 co-emit csv.x：下列探针/流式在入口用 next_field/unescape 自洽，勿留 U 符号。 */

/** 将字段转义为带引号的 CSV 单元写入 buf；返回写入长度，失败 -1。 */
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

/** 引号字段探针（第一字段）；测试专用。 */
export function test_quoted_first(out_start: *i32, out_len: *i32): i32 {
  let q: u8[8] = [34, 97, 44, 98, 34, 44, 99, 0];
  return next_field(&q[0], 8, 0, out_start, out_len);
}

/** 引号字段探针（第二字段）；测试专用。 */
export function test_quoted_second(offset: i32, out_start: *i32, out_len: *i32): i32 {
  let q: u8[8] = [34, 97, 44, 98, 34, 44, 99, 0];
  return next_field(&q[0], 8, offset, out_start, out_len);
}

/** unescape 正例探针；测试专用。 */
export function test_unescape_ok(buf: *u8, buf_cap: i32): i32 {
  let raw: u8[4] = [34, 34, 97, 0];
  return unescape(&raw[0], 3, buf, buf_cap);
}

/** unescape 缓冲不足探针；测试专用。 */
export function test_unescape_fail(): i32 {
  let raw: u8[4] = [34, 34, 97, 0];
  let tiny: u8[1] = [0];
  return unescape(&raw[0], 3, &tiny[0], 1);
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
export function reader(ptr: *u8, len: i32): StreamCsvReader {
  return StreamCsvReader { ptr: ptr, len: len, offset: 0 };
}

/**
 * 读下一行；0=成功，1=EOF，<0=错误。
 * field_starts/lens 为行内字段在 ptr 上的绝对偏移（与 parse_row 一致）。
 */
export function next_row(r: *StreamCsvReader, field_starts: *i32, field_lens: *i32, max_fields: i32, out_count: *i32): i32 {
  let next: i32 = 0;
  let n: i32 = 0;
  let st: i32 = 0;
  let ln: i32 = 0;
  let pos: i32 = 0;
  if (r == 0 || out_count == 0) { return -1; }
  if (r.offset >= r.len) { return 1; }
  pos = r.offset;
  n = 0;
  while (pos < r.len && n < max_fields) {
    next = next_field(r.ptr, r.len, pos, &st, &ln);
    if (field_starts != 0) { field_starts[n] = st; }
    if (field_lens != 0) { field_lens[n] = ln; }
    n = n + 1;
    if (next <= pos) { break; }
    pos = next;
    if (pos > 0 && pos <= r.len && r.ptr[pos - 1] == 10) { break; }
  }
  out_count[0] = n;
  if (n <= 0 && pos >= r.len) { return 1; }
  r.offset = pos;
  return 0;
}

/** 是否已读完（offset >= len）。 */
export function eof(r: StreamCsvReader): i32 {
  if (r.offset >= r.len) { return 1; }
  return 0;
}

/**
 * 构造写游标（原 stream_writer_init）。
 * 绑定写缓冲；out_len 置 0。
 */
export function writer(out: *u8, out_cap: i32): StreamCsvWriter {
  return StreamCsvWriter { out: out, out_cap: out_cap, out_len: 0 };
}

/**
 * 追加一行 CSV（字段来自 blob + starts/lens）；行末自动加 '\\n'。
 * 0 成功；-1 缓冲不足或 write_row 失败。
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

/** 当前已写入字节数（含行尾换行）。 */
export function len(w: StreamCsvWriter): i32 {
  return w.out_len;
}

/** 流式烟测占位（完整实现见 csv.x；库 -o 自洽路径返回 0）。 */
export function smoke(): i32 {
  return 0;
}
