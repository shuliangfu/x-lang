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

// std.compress.zlib.libz — F-04 v4：zlib 块压缩/解压（libz FFI）
//
// 【文件职责】
// 从 zlib/zlib.c 迁出的 RFC 1950 zlib 封装：compress2 / uncompress 薄封装。
//
// 【依赖】
// - libz：compress2、uncompress（hosted 路径由链接器解析 -lz）
// - runtime_link_abi：shu_compress_zlib_marker 触发按需 -lz

/** zlib 成功码。 */
const Z_OK: i32 = 0;

/** compress2 默认压缩级别。 */
const Z_DEFAULT_COMPRESSION: i32 = -1;

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
function compress_deflate_c(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  if (in == 0 || out == 0 || in_len < 0 || out_cap <= 0) {
    return -1;
  }
  let dest_len: u64 = out_cap as u64;
  let ret: i32 = 0;
  unsafe { ret = compress2(out, &dest_len, in, in_len as u64, Z_DEFAULT_COMPRESSION); }
  if (ret == Z_OK) {
    return dest_len as i32;
  }
  return -1;
}

/**
 * 解压：从 in 读 zlib 流，写入 out，返回写入字节数，失败返回 -1。
 * 参数：in 输入；in_len 输入长度；out 输出缓冲；out_cap 输出容量。
 */
function compress_inflate_c(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  if (in == 0 || out == 0 || in_len < 0 || out_cap <= 0) {
    return -1;
  }
  let dest_len: u64 = out_cap as u64;
  let ret: i32 = 0;
  unsafe { ret = uncompress(out, &dest_len, in, in_len as u64); }
  if (ret == Z_OK) {
    return dest_len as i32;
  }
  return -1;
}
