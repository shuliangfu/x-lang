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

// std.compress.zlib — zlib 块压缩/解压（deflate/inflate）
//
// 【文件职责】RFC 1950 zlib 封装；实现见 libz.x（F-04 v4 去 C）。
// 【依赖】按需 -lz（runtime 扫描 shu_compress_zlib_marker 或 compress2 未定义符号）。
const libz = import("std.compress.zlib.libz");

/** 压缩为 zlib 格式，返回写入字节数，失败 -1。 */
export function deflate(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return libz.compress_deflate_c(in, in_len, out, out_cap);
}

/** 解压 zlib 流，返回写入字节数，失败 -1。 */
export function inflate(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return libz.compress_inflate_c(in, in_len, out, out_cap);
}
