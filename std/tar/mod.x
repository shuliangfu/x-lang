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

/* See implementation. */
export const TAR_MAX_NAME: i32 = 100;
/* See implementation. */
export const TAR_MAX_PATH_USTAR: i32 = 256;
/* See implementation. */
export const TAR_TYPE_FILE: i32 = 48;
/* See implementation. */
export const TAR_TYPE_DIR: i32 = 53;
/* See implementation. */
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

/** Exported function `read_header`.
 * Read path helper `read_header`.
 * @param buf *u8
 * @param len i32
 * @param name_out *u8
 * @param name_cap i32
 * @param size_out *i32
 * @return i32
 */
export function read_header(buf: *u8, len: i32, name_out: *u8, name_cap: i32, size_out: *i32): i32 {
  unsafe { return tar_read_header_c(buf, len, name_out, name_cap, size_out); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `write_header`.
 * Write path helper `write_header`.
 * @param buf *u8
 * @param buf_cap i32
 * @param name *u8
 * @param name_len i32
 * @param file_size i32
 * @return i32
 */
export function write_header(buf: *u8, buf_cap: i32, name: *u8, name_len: i32, file_size: i32): i32 {
  unsafe { return tar_write_header_c(buf, buf_cap, name, name_len, file_size); }
  return 0; // unreachable — typeck workaround
}

/* See implementation. */
export function append_entry(buf: *u8, buf_cap: i32, off_io: *i32, name: *u8, name_len: i32, data: *u8,
data_len: i32, is_dir: i32): i32 {
  unsafe { return tar_append_entry_c(buf, buf_cap, off_io, name, name_len, data, data_len, is_dir); }
  return 0; // unreachable — typeck workaround
}

/* See implementation. */
export function next_entry(buf: *u8, buf_len: i32, pos_io: *i32, name_out: *u8, name_cap: i32, size_out: *i32,
type_out: *i32): i32 {
  unsafe { return tar_next_entry_c(buf, buf_len, pos_io, name_out, name_cap, size_out, type_out); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `read_entry_data`.
 * Read path helper `read_entry_data`.
 * @param buf *u8
 * @param buf_len i32
 * @param entry_off i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function read_entry_data(buf: *u8, buf_len: i32, entry_off: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return tar_read_entry_data_c(buf, buf_len, entry_off, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `path_max`.
 * Implements `path_max`.
 * @return i32
 */
export function path_max(): i32 {
  unsafe { return tar_path_max_c(); }
  return 0; // unreachable — typeck workaround
}
