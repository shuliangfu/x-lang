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

// std.compress.brotli — Brotli（.br）块压缩/解压与流式 API
//
// 【文件职责】BrotliEncoder/Decoder 封装；实现见 lib.x（F-04 v6 去 C）。
// 【依赖】libbrotli（-lbrotlienc -lbrotlidec）；runtime 按需链入。
const lib = import("std.compress.brotli.lib");

/** 压缩为 Brotli 格式（.br），返回写入字节数，失败 -1。 */
function brotli_compress(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return lib.compress_brotli_compress_c(in, in_len, out, out_cap);
}

/** 解压 Brotli 流，返回写入字节数，失败 -1。 */
function brotli_decompress(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return lib.compress_brotli_decompress_c(in, in_len, out, out_cap);
}

/** 探测 Brotli 是否已在编译期启用；1=可用，0=占位 stub。 */
function brotli_available(): i32 {
  return lib.compress_brotli_available_c();
}

/** Brotli 往返烟测；未启用时返回 0（skip）。 */
function brotli_smoke(): i32 {
  return lib.compress_brotli_smoke_c();
}

/** brotli 流状态缓冲最小字节数。 */
function brotli_stream_state_bytes(): i32 {
  return lib.compress_brotli_stream_state_bytes_c();
}

/** 初始化 brotli 压缩流；成功 0。 */
function brotli_stream_init_compress(state: *u8, state_cap: i32): i32 {
  return lib.compress_brotli_stream_init_compress_c(state, state_cap);
}

/** 初始化 brotli 解压流；成功 0。 */
function brotli_stream_init_decompress(state: *u8, state_cap: i32): i32 {
  return lib.compress_brotli_stream_init_decompress_c(state, state_cap);
}

/** 分块 brotli 压缩；is_last≠0 时 FINISH。 */
function brotli_stream_compress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32,
  is_last: i32, in_consumed: *i32): i32 {
  return lib.compress_brotli_stream_compress_c(state, state_cap, inp, in_len, out, out_cap, is_last, in_consumed);
}

/** 分块 brotli 解压。 */
function brotli_stream_decompress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32,
  in_consumed: *i32): i32 {
  return lib.compress_brotli_stream_decompress_c(state, state_cap, inp, in_len, out, out_cap, in_consumed);
}

/** 释放 brotli 流。 */
function brotli_stream_end(state: *u8, state_cap: i32): i32 {
  return lib.compress_brotli_stream_end_c(state, state_cap);
}
