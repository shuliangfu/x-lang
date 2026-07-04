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

// std.compress.gzip — gzip 块压缩/解压与流式 API（STD-039 / STD-122）
//
// 【文件职责】.gz 块 API、gzip_stream_*、StreamCompress 统一门面。
// 【依赖】libz（F-04 v5 libz.x）；runtime 按需 -lz。
const libz = import("std.compress.gzip.libz");

/** 压缩为 gzip 格式（.gz），返回写入字节数，失败 -1。 */
function gzip_compress(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return libz.compress_gzip_compress_c(in, in_len, out, out_cap);
}

/** 解压 gzip 流，返回写入字节数，失败 -1。 */
function gzip_decompress(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return libz.compress_gzip_decompress_c(in, in_len, out, out_cap);
}

/** gzip 流状态缓冲最小字节数（STD-039）。 */
function gzip_stream_state_bytes(): i32 {
  return libz.compress_gzip_stream_state_bytes_c();
}

/** 初始化 gzip 压缩流；成功 0，未链 libz 时 -1。 */
function gzip_stream_init_compress(state: *u8, state_cap: i32): i32 {
  return libz.compress_gzip_stream_init_compress_c(state, state_cap);
}

/** 初始化 gzip 解压流；成功 0，未链 libz 时 -1。 */
function gzip_stream_init_decompress(state: *u8, state_cap: i32): i32 {
  return libz.compress_gzip_stream_init_decompress_c(state, state_cap);
}

/** 分块 gzip 压缩；is_last≠0 时对末块 Z_FINISH。 */
function gzip_stream_compress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32,
  is_last: i32, in_consumed: *i32): i32 {
  return libz.compress_gzip_stream_compress_c(state, state_cap, inp, in_len, out, out_cap, is_last, in_consumed);
}

/** 分块 gzip 解压。 */
function gzip_stream_decompress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32,
  in_consumed: *i32): i32 {
  return libz.compress_gzip_stream_decompress_c(state, state_cap, inp, in_len, out, out_cap, in_consumed);
}

/** 释放 gzip 流底层 z_stream。 */
function gzip_stream_end(state: *u8, state_cap: i32): i32 {
  return libz.compress_gzip_stream_end_c(state, state_cap);
}
