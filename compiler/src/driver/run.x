// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
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

// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

/** See implementation for details. */
export extern function driver_exec_compiled(argc: i32, argv: *u8): i32;
/* See implementation. */
export extern function main_run_compiler_x_path_impl(argc: i32, argv: *u8): i32;

/** Exported function `run_eq_word`.
 * Implements `run_eq_word`.
 * @param buf *u8
 * @param len i32
 * @param word_ptr *u8
 * @param word_len i32
 * @return i32
 */
export function run_eq_word(buf: *u8, len: i32, word_ptr: *u8, word_len: i32): i32 {
  if (len != word_len) {
    return 0;
  }
  let i: i32 = 0;
  while (i < len) {
    if (buf[i] != word_ptr[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/** Exported function `cmd_run`.
 * Implements `cmd_run`.
 * @param argc i32
 * @param argv *u8
 * @return i32
 */
export function cmd_run(argc: i32, argv: *u8): i32 {
  unsafe {
    if (argc < 2) {
      return 1;
    }
    let rc: i32 = main_run_compiler_x_path_impl(argc, argv);
    if (rc == 0) {
      return driver_exec_compiled(argc, argv);
    }
    return rc;
  }
  return 0;
}
