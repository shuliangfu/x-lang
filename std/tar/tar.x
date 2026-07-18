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

// See implementation.
//
// See implementation.
// See implementation.
// See implementation.

export const TAR_PATH_MAX: i32 = 512;

/** Exported function `tar_f_tar_v1_marker_c`.
 * Implements `tar_f_tar_v1_marker_c`.
 * @return i32
 */
export function tar_f_tar_v1_marker_c(): i32 {
  return 1;
}

/** Exported function `tar_f_tar_v2_marker_c`.
 * Implements `tar_f_tar_v2_marker_c`.
 * @return i32
 */
export function tar_f_tar_v2_marker_c(): i32 {
  return 1;
}

/** Exported function `tar_path_max_c`.
 * Implements `tar_path_max_c`.
 * @return i32
 */
export function tar_path_max_c(): i32 {
  return TAR_PATH_MAX;
}

/** Exported function `tar_read_octal`.
 * Read path helper `tar_read_octal`.
 * @param buf *u8
 * @param off i32
 * @param width i32
 * @return i32
 */
export function tar_read_octal(buf: *u8, off: i32, width: i32): i32 {
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

/** Exported function `tar_read_header_c`.
 * Read path helper `tar_read_header_c`.
 * @param buf *u8
 * @param len i32
 * @param name_out *u8
 * @param name_cap i32
 * @param size_out *i32
 * @return i32
 */
export function tar_read_header_c(buf: *u8, len: i32, name_out: *u8, name_cap: i32, size_out: *i32): i32 {
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

/** Exported function `tar_write_octal`.
 * Write path helper `tar_write_octal`.
 * @param buf *u8
 * @param off i32
 * @param width i32
 * @param v i32
 * @return void
 */
export function tar_write_octal(buf: *u8, off: i32, width: i32, v: i32): void {
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

/** Exported function `tar_header_chksum`.
 * Implements `tar_header_chksum`.
 * @param buf *u8
 * @return i32
 */
export function tar_header_chksum(buf: *u8): i32 {
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

/** Exported function `tar_write_header_c`.
 * Write path helper `tar_write_header_c`.
 * @param buf *u8
 * @param buf_cap i32
 * @param name *u8
 * @param name_len i32
 * @param file_size i32
 * @return i32
 */
export function tar_write_header_c(buf: *u8, buf_cap: i32, name: *u8, name_len: i32, file_size: i32): i32 {
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
  // Chksum field placeholder spaces (ustar layout bytes 148..155).
  while (i < 156) { buf[i] = 32; i = i + 1; }
  buf[156] = 48;                          /* typeflag '0' = regular file */
  buf[257] = 117; buf[258] = 115; buf[259] = 116; buf[260] = 97; buf[261] = 114;  /* "ustar" */
  buf[262] = 0;
  buf[263] = 48; buf[264] = 48;           /* version "00" */
  let chk: i32 = tar_header_chksum(buf);
  tar_write_octal(buf, 148, 7, chk);       /* 6-digit octal + NUL */
  buf[155] = 32;                           /* chksum trailing space */
  return 0;
}

/* See implementation. */
export function tar_append_entry_c(buf: *u8, buf_cap: i32, off_io: *i32, name: *u8, name_len: i32, data: *u8,
  data_len: i32): i32 {
  return -1;
}

/* See implementation. */
export function tar_next_entry_c(buf: *u8, buf_len: i32, pos_io: *i32, name_out: *u8, name_cap: i32,
  size_out: *i32): i32 {
  return -1;
}

/** Exported function `tar_read_entry_data_c`.
 * Read path helper `tar_read_entry_data_c`.
 * @param buf *u8
 * @param buf_len i32
 * @param entry_off i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function tar_read_entry_data_c(buf: *u8, buf_len: i32, entry_off: i32, out: *u8, out_cap: i32): i32 {
  return -1;
}

/** Exported function `tar_extended_smoke_c`.
 * Implements `tar_extended_smoke_c`.
 * @return i32
 */
export function tar_extended_smoke_c(): i32 {
  return -1;
}
