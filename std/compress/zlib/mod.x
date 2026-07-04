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

// std.compress.zlib — zlib 块压缩/解压（deflate/inflate）
//
// 【文件职责】RFC 1950 zlib 封装；实现见 libz.x（F-04 v4 去 C）。
// 【依赖】按需 -lz（runtime 扫描 shu_compress_zlib_marker 或 compress2 未定义符号）。
const libz = import("std.compress.zlib.libz");

/** 压缩为 zlib 格式，返回写入字节数，失败 -1。 */
function deflate(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return libz.compress_deflate_c(in, in_len, out, out_cap);
}

/** 解压 zlib 流，返回写入字节数，失败 -1。 */
function inflate(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return libz.compress_inflate_c(in, in_len, out, out_cap);
}
