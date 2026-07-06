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

/** 从 buf[off..off+width] 解析八进制（遇 NUL/空格止）。 */
function tar_read_octal(buf: *u8, off: i32, width: i32): i32 {
  let v: i32 = 0;
  let i: i32 = 0;
  while (i < width) {
    let c: u8 = buf[off + i];
    if (c < 48 || c > 55) { return v; }
    v = (v << 3) + ((c - 48) as i32);
    i = i + 1;
  }
  return v;
}

/** 解析 UStar 头；name 拷贝到 name_out（NUL 结尾，不超过 name_cap），size 写入 *size_out。
 * 返回 0 成功，-1 参数错。 */
function tar_read_header_c(buf: *u8, len: i32, name_out: *u8, name_cap: i32, size_out: *i32): i32 {
  if (buf == 0 || len < 512 || name_out == 0 || name_cap <= 0 || size_out == 0) {
    return -1;
  }
  let i: i32 = 0;
  while (i < name_cap - 1 && i < 100 && buf[i] != 0) {
    name_out[i] = buf[i];
    i = i + 1;
  }
  name_out[i] = 0;
  size_out[0] = tar_read_octal(buf, 124, 12);
  return 0;
}

/** 把 v 以八进制写入 buf[off..off+width]：前导 0 填充，末尾 NUL（width 含 NUL 位）。 */
function tar_write_octal(buf: *u8, off: i32, width: i32, v: i32): void {
  let w: i32 = width - 1;
  let n: i32 = v;
  if (n < 0) { n = 0; }
  let i: i32 = off + w - 1;
  while (i > off) {
    buf[i] = (48 + (n & 7)) as u8;
    n = n >> 3;
    i = i - 1;
  }
  buf[off] = 48;
  buf[off + width - 1] = 0;
}

/** 计算 512 字节 UStar 头校验和（chksum 字段视为空格）。 */
function tar_header_chksum(buf: *u8): i32 {
  let sum: i32 = 0;
  let i: i32 = 0;
  while (i < 512) {
    let c: i32 = buf[i] as i32;
    if (i >= 148 && i < 156) { c = 32; }
    sum = sum + c;
    i = i + 1;
  }
  return sum;
}

/** 写入 UStar 头到 buf[0..512]；name_len 为不含 NUL 的名字字节数，file_size 为文件字节数。
 * 返回 0 成功，-1 参数错或 buf_cap < 512。 */
function tar_write_header_c(buf: *u8, buf_cap: i32, name: *u8, name_len: i32, file_size: i32): i32 {
  if (buf == 0 || buf_cap < 512 || name == 0 || name_len < 0 || name_len > 100) {
    return -1;
  }
  let i: i32 = 0;
  while (i < 512) { buf[i] = 0; i = i + 1; }
  i = 0;
  while (i < name_len) { buf[i] = name[i]; i = i + 1; }
  tar_write_octal(buf, 100, 8, 420);    /* mode 0644 */
  tar_write_octal(buf, 108, 8, 0);      /* uid */
  tar_write_octal(buf, 116, 8, 0);     /* gid */
  tar_write_octal(buf, 124, 12, file_size);
  tar_write_octal(buf, 136, 12, 0);     /* mtime */
  i = 148;
  while (i < 156) { buf[i] = 32; i = i + 1; }   /* chksum 占位为空格 */
  buf[156] = 48;                          /* typeflag '0' = 普通文件 */
  buf[257] = 117; buf[258] = 115; buf[259] = 116; buf[260] = 97; buf[261] = 114;  /* "ustar" */
  buf[262] = 0;
  buf[263] = 48; buf[264] = 48;           /* version "00" */
  let chk: i32 = tar_header_chksum(buf);
  tar_write_octal(buf, 148, 7, chk);       /* 6 位八进制 + NUL */
  buf[155] = 32;                           /* chksum 末位空格 */
  return 0;
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
