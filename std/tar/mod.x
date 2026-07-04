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

// std.tar — tar 归档读/写（STD-038/152）
//
// 【文件职责】UStar read/write/append/iterate；长路径 prefix + Pax。
// 【依赖】std.fs、std.io；与 std/tar/tar.x 同属一模块（F-tar v2 纯 .x）。

/** UStar name 字段最大长度。 */
const TAR_MAX_NAME: i32 = 100;
/** UStar prefix+name 最大路径。 */
const TAR_MAX_PATH_USTAR: i32 = 256;
/** 普通文件 typeflag。 */
const TAR_TYPE_FILE: i32 = 48;
/** 目录 typeflag。 */
const TAR_TYPE_DIR: i32 = 53;
/** Pax 扩展头 typeflag。 */
const TAR_TYPE_PAX: i32 = 120;

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

function read_header(buf: *u8, len: i32, name_out: *u8, name_cap: i32, size_out: *i32): i32 {
  unsafe { return tar_read_header_c(buf, len, name_out, name_cap, size_out); }
}
function write_header(buf: *u8, buf_cap: i32, name: *u8, name_len: i32, file_size: i32): i32 {
  unsafe { return tar_write_header_c(buf, buf_cap, name, name_len, file_size); }
}

/** 向内存归档追加 UStar 条目；is_dir=1 为目录。 */
function append_entry(buf: *u8, buf_cap: i32, off_io: *i32, name: *u8, name_len: i32, data: *u8,
data_len: i32, is_dir: i32): i32 {
  unsafe { return tar_append_entry_c(buf, buf_cap, off_io, name, name_len, data, data_len, is_dir); }
}

/** 遍历下一条；返回 0 成功，1 结束，-1 错误。 */
function next_entry(buf: *u8, buf_len: i32, pos_io: *i32, name_out: *u8, name_cap: i32, size_out: *i32,
type_out: *i32): i32 {
  unsafe { return tar_next_entry_c(buf, buf_len, pos_io, name_out, name_cap, size_out, type_out); }
}

/** 从 entry_off 读取文件内容。 */
function read_entry_data(buf: *u8, buf_len: i32, entry_off: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return tar_read_entry_data_c(buf, buf_len, entry_off, out, out_cap); }
}

/** 支持的最大完整路径字节数（含 Pax）。 */
function path_max(): i32 {
  unsafe { return tar_path_max_c(); }
}
