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

// std.compress.zlib.libz — F-04 v4：zlib 块压缩/解压（libz FFI）
//
// 【文件职责】
// 从 zlib/zlib.c 迁出的 RFC 1950 zlib 封装：compress2 / uncompress 薄封装。
//
// 【依赖】
// - libz：compress2、uncompress（hosted 路径由链接器解析 -lz）
// - runtime_link_abi：shu_compress_zlib_marker 触发按需 -lz

/* 勿 export 裸 Z_OK / Z_DEFAULT_COMPRESSION：与 gzip/libz.x 同名 static const 同 TU 会 redefinition。
 * 字面量与 libz 头一致：Z_OK=0，Z_DEFAULT_COMPRESSION=-1。 */

/** libz：压缩为 zlib 格式。 */
extern function compress2(dest: *u8, destLen: *u64, source: *u8, sourceLen: u64, level: i32): i32;

/** libz：解压 zlib 流。 */
extern function uncompress(dest: *u8, destLen: *u64, source: *u8, sourceLen: u64): i32;

/** 链接 marker：runtime 据此追加 -lz（F-04 v4 自 compress.o 迁至 .x）。 */
let shu_compress_zlib_marker: u8 = 1;

/**
 * 压缩：zlib 格式写入 out，返回写入字节数，失败返回 -1。
 * 参数：in 输入；in_len 输入长度；out 输出缓冲；out_cap 输出容量。
 */
export function compress_deflate_c(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  if (in == 0 || out == 0 || in_len < 0 || out_cap <= 0) {
    return -1;
  }
  let dest_len: u64 = out_cap as u64;
  let ret: i32 = 0;
  unsafe { ret = compress2(out, &dest_len, in, in_len as u64, -1); }
  if (ret == 0) {
    return dest_len as i32;
  }
  return -1;
}

/**
 * 解压：从 in 读 zlib 流，写入 out，返回写入字节数，失败返回 -1。
 * 参数：in 输入；in_len 输入长度；out 输出缓冲；out_cap 输出容量。
 */
export function compress_inflate_c(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  if (in == 0 || out == 0 || in_len < 0 || out_cap <= 0) {
    return -1;
  }
  let dest_len: u64 = out_cap as u64;
  let ret: i32 = 0;
  unsafe { ret = uncompress(out, &dest_len, in, in_len as u64); }
  if (ret == 0) {
    return dest_len as i32;
  }
  return -1;
}
