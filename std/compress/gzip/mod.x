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

// std.compress.gzip — gzip 块压缩/解压与流式 API（STD-039 / STD-122）
//
// 【文件职责】.gz 块 API、gzip_stream_*、StreamCompress 统一门面。
// 【依赖】libz（F-04 v5 libz.x）；runtime 按需 -lz。
const libz = import("std.compress.gzip.libz");

/** 压缩为 gzip 格式（.gz），返回写入字节数，失败 -1。 */
export function gzip_compress(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return libz.compress_gzip_compress_c(in, in_len, out, out_cap);
}

/** 解压 gzip 流，返回写入字节数，失败 -1。 */
export function gzip_decompress(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return libz.compress_gzip_decompress_c(in, in_len, out, out_cap);
}

/** gzip 流状态缓冲最小字节数（STD-039）。 */
export function gzip_stream_state_bytes(): i32 {
  return libz.compress_gzip_stream_state_bytes_c();
}

/** 初始化 gzip 压缩流；成功 0，未链 libz 时 -1。 */
export function gzip_stream_init_compress(state: *u8, state_cap: i32): i32 {
  return libz.compress_gzip_stream_init_compress_c(state, state_cap);
}

/** 初始化 gzip 解压流；成功 0，未链 libz 时 -1。 */
export function gzip_stream_init_decompress(state: *u8, state_cap: i32): i32 {
  return libz.compress_gzip_stream_init_decompress_c(state, state_cap);
}

/** 分块 gzip 压缩；is_last≠0 时对末块 Z_FINISH。 */
export function gzip_stream_compress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32,
  is_last: i32, in_consumed: *i32): i32 {
  return libz.compress_gzip_stream_compress_c(state, state_cap, inp, in_len, out, out_cap, is_last, in_consumed);
}

/** 分块 gzip 解压。 */
export function gzip_stream_decompress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32,
  in_consumed: *i32): i32 {
  return libz.compress_gzip_stream_decompress_c(state, state_cap, inp, in_len, out, out_cap, in_consumed);
}

/** 释放 gzip 流底层 z_stream。 */
export function gzip_stream_end(state: *u8, state_cap: i32): i32 {
  return libz.compress_gzip_stream_end_c(state, state_cap);
}
