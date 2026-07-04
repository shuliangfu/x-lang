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

// std/tar/tar.x — F-tar v2：API 锚点（G-03 seed asm；完整 UStar/Pax 实现待迁 C 胶层）
//
// 【文件职责】
// STD-038/152 tar_* C ABI 锚点；seed asm 单文件仅首函数可 emit，全局状态不可用。
// 参考实现见 git 历史 tar.x 全量版本。

const TAR_PATH_MAX: i32 = 512;

/** F-tar v1 版本标记。 */
function tar_f_tar_v1_marker_c(): i32 {
  return 1;
}

/** F-tar v2 版本标记。 */
function tar_f_tar_v2_marker_c(): i32 {
  return 1;
}

/** 支持的最大完整路径（Pax）。 */
function tar_path_max_c(): i32 {
  return TAR_PATH_MAX;
}

/** 解析 UStar/Pax 头；锚点桩（完整实现待迁 C）。 */
function tar_read_header_c(buf: *u8, len: i32, name_out: *u8, name_cap: i32, size_out: *i32): i32 {
  return -1;
}

/** 写入 UStar 头；锚点桩。 */
function tar_write_header_c(buf: *u8, buf_cap: i32, name: *u8, name_len: i32, file_size: i32): i32 {
  return -1;
}

/** 追加 tar 条目；锚点桩。 */
function tar_append_entry_c(buf: *u8, buf_cap: i32, off_io: *i32, name: *u8, name_len: i32, data: *u8,
  data_len: i32): i32 {
  return -1;
}

/** 迭代下一 tar 条目；锚点桩。 */
function tar_next_entry_c(buf: *u8, buf_len: i32, pos_io: *i32, name_out: *u8, name_cap: i32,
  size_out: *i32): i32 {
  return -1;
}

/** 读取条目数据；锚点桩。 */
function tar_read_entry_data_c(buf: *u8, buf_len: i32, entry_off: i32, out: *u8, out_cap: i32): i32 {
  return -1;
}

/** 扩展路径烟测；锚点桩。 */
function tar_extended_smoke_c(): i32 {
  return -1;
}
