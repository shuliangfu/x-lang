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

// std.tar — tar 归档读/写（STD-038/152）
//
// 【文件职责】UStar read/write/append/iterate；长路径 prefix + Pax。
// 【依赖】std.fs、std.io；与 std/tar/tar.x 同属一模块（F-tar v2 纯 .x）。

/** UStar name 字段最大长度。 */
export const TAR_MAX_NAME: i32 = 100;
/** UStar prefix+name 最大路径。 */
export const TAR_MAX_PATH_USTAR: i32 = 256;
/** 普通文件 typeflag。 */
export const TAR_TYPE_FILE: i32 = 48;
/** 目录 typeflag。 */
export const TAR_TYPE_DIR: i32 = 53;
/** Pax 扩展头 typeflag。 */
export const TAR_TYPE_PAX: i32 = 120;

extern function tar_path_max_c(): i32;
extern function tar_read_header_c(buf: *u8, len: i32, name_out: *u8, name_cap: i32, size_out:
*i32): i32;
extern function tar_write_header_c(buf: *u8, buf_cap: i32, name: *u8, name_len: i32, file_size:
i32): i32;
extern function tar_append_entry_c(buf: *u8, buf_cap: i32, off_io: *i32, name: *u8, name_len: i32,
data: *u8, data_len: i32, is_dir: i32): i32;
extern function tar_next_entry_c(buf: *u8, buf_len: i32, pos_io: *i32, name_out: *u8, name_cap: i32,
size_out: *i32, type_out: *i32): i32;
extern function tar_read_entry_data_c(buf: *u8, buf_len: i32, entry_off: i32, out: *u8, out_cap: i32): i32;

export function read_header(buf: *u8, len: i32, name_out: *u8, name_cap: i32, size_out: *i32): i32 {
  unsafe { return tar_read_header_c(buf, len, name_out, name_cap, size_out); }
  return 0; // unreachable — typeck workaround
}
export function write_header(buf: *u8, buf_cap: i32, name: *u8, name_len: i32, file_size: i32): i32 {
  unsafe { return tar_write_header_c(buf, buf_cap, name, name_len, file_size); }
  return 0; // unreachable — typeck workaround
}

/** 向内存归档追加 UStar 条目；is_dir=1 为目录。 */
export function append_entry(buf: *u8, buf_cap: i32, off_io: *i32, name: *u8, name_len: i32, data: *u8,
data_len: i32, is_dir: i32): i32 {
  unsafe { return tar_append_entry_c(buf, buf_cap, off_io, name, name_len, data, data_len, is_dir); }
  return 0; // unreachable — typeck workaround
}

/** 遍历下一条；返回 0 成功，1 结束，-1 错误。 */
export function next_entry(buf: *u8, buf_len: i32, pos_io: *i32, name_out: *u8, name_cap: i32, size_out: *i32,
type_out: *i32): i32 {
  unsafe { return tar_next_entry_c(buf, buf_len, pos_io, name_out, name_cap, size_out, type_out); }
  return 0; // unreachable — typeck workaround
}

/** 从 entry_off 读取文件内容。 */
export function read_entry_data(buf: *u8, buf_len: i32, entry_off: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return tar_read_entry_data_c(buf, buf_len, entry_off, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** 支持的最大完整路径字节数（含 Pax）。 */
export function path_max(): i32 {
  unsafe { return tar_path_max_c(); }
  return 0; // unreachable — typeck workaround
}
