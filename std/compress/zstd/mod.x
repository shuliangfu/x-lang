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

// std.compress.zstd — zstd 块压缩/解压与流式 API
//
// 【文件职责】ZSTD 封装；实现见 lib.x（F-04 v7 去 C）。
// 【依赖】libzstd（-lzstd）；runtime 按需链入。
const lib = import("std.compress.zstd.lib");

/** 压缩为 zstd 帧，返回写入字节数，失败 -1。 */
export function zstd_compress(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return lib.compress_zstd_compress_c(in, in_len, out, out_cap);
}

/** 解压 zstd 帧，返回写入字节数，失败 -1。 */
export function zstd_decompress(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return lib.compress_zstd_decompress_c(in, in_len, out, out_cap);
}

/** 探测 zstd 是否已在编译期启用；1=可用，0=占位 stub。 */
export function zstd_available(): i32 {
  return lib.compress_zstd_available_c();
}

/** zstd 块 + 流往返烟测；未启用时返回 0（skip）。 */
export function zstd_smoke(): i32 {
  return lib.compress_zstd_smoke_c();
}

/** zstd 流状态缓冲最小字节数。 */
export function zstd_stream_state_bytes(): i32 {
  return lib.compress_zstd_stream_state_bytes_c();
}

/** 初始化 zstd 压缩流；成功 0。 */
export function zstd_stream_init_compress(state: *u8, state_cap: i32): i32 {
  return lib.compress_zstd_stream_init_compress_c(state, state_cap);
}

/** 初始化 zstd 解压流；成功 0。 */
export function zstd_stream_init_decompress(state: *u8, state_cap: i32): i32 {
  return lib.compress_zstd_stream_init_decompress_c(state, state_cap);
}

/** 分块 zstd 压缩；is_last≠0 时 ZSTD_e_end。 */
export function zstd_stream_compress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32,
  is_last: i32, in_consumed: *i32): i32 {
  return lib.compress_zstd_stream_compress_c(state, state_cap, inp, in_len, out, out_cap, is_last, in_consumed);
}

/** 分块 zstd 解压。 */
export function zstd_stream_decompress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32,
  in_consumed: *i32): i32 {
  return lib.compress_zstd_stream_decompress_c(state, state_cap, inp, in_len, out, out_cap, in_consumed);
}

/** 释放 zstd 流。 */
export function zstd_stream_end(state: *u8, state_cap: i32): i32 {
  return lib.compress_zstd_stream_end_c(state, state_cap);
}
