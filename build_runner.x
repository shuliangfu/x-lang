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
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.

/* See implementation. */
extern function driver_get_argv_i(argc: i32, argv: *u8, i: i32, buf: *u8, max: i32): i32;
/* See implementation. */
extern function build_run_step(step_id: i32, shu_path: *u8): i32;
/* See implementation. */
extern function build_run_asm_build(shu_path: *u8): i32;
/* See implementation. */
extern function build_get_step_count(): i32;
extern function build_get_step_at(i: i32): i32;
/* See implementation. */
extern function build_use_asm_only(): i32;
/* See implementation. */
extern function build_copy_xlang_asm(): i32;

/** Internal function `build_run_legacy_steps`.
 * Implements `build_run_legacy_steps`.
 * @param shu_path *u8
 * @return i32
 */
function build_run_legacy_steps(shu_path: *u8): i32 {
  let n: i32 = build_get_step_count();
  let i: i32 = 0;
  while (i < n) {
    let step_id: i32 = build_get_step_at(i);
    if (step_id < 0) {
      return 1;
    }
    if (build_run_step(step_id, shu_path) != 0) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

/** Internal function `build_argv2_is_asm`.
 * Implements `build_argv2_is_asm`.
 * @param arg2 *u8
 * @param l2 i32
 * @return i32
 */
function build_argv2_is_asm(arg2: *u8, l2: i32): i32 {
  if (l2 == 3 && arg2[0] == 97 && arg2[1] == 115 && arg2[2] == 109) {
    return 1;
  }
  return 0;
}

/** Internal function `build_argv2_is_legacy`.
 * Implements `build_argv2_is_legacy`.
 * @param arg2 *u8
 * @param l2 i32
 * @return i32
 */
function build_argv2_is_legacy(arg2: *u8, l2: i32): i32 {
  if (l2 == 6 && arg2[0] == 108 && arg2[1] == 101 && arg2[2] == 103
    && arg2[3] == 97 && arg2[4] == 99 && arg2[5] == 121) {
    return 1;
  }
  return 0;
}

/** Internal function `entry`.
 * Implements `entry`.
 * @param argc i32
 * @param argv *u8
 * @return i32
 */
function entry(argc: i32, argv: *u8): i32 {
  let shu_buf: u8[256] = [];
  let len: i32 = driver_get_argv_i(argc, argv, 1, shu_buf, 256);
  if (len < 0) {
    shu_buf[0] = 46;
    shu_buf[1] = 47;
    shu_buf[2] = 115;
    shu_buf[3] = 104;
    shu_buf[4] = 117;
    len = 5;
  }
  if (len < 256) {
    shu_buf[len] = 0;
  }
  let arg2: u8[8] = [];
  let l2: i32 = driver_get_argv_i(argc, argv, 2, arg2, 8);
  if (build_argv2_is_asm(arg2, l2) != 0) {
    if (build_run_asm_build(shu_buf) != 0) {
      return 1;
    }
    return 0;
  }
  if (build_argv2_is_legacy(arg2, l2) != 0) {
    if (build_run_legacy_steps(shu_buf) != 0) {
      return 1;
    }
    return 0;
  }
  if (build_use_asm_only() != 0) {
    if (build_run_asm_build(shu_buf) == 0) {
      if (build_copy_xlang_asm() != 0) {
        return 1;
      }
      return 0;
    }
  }
  if (build_run_legacy_steps(shu_buf) != 0) {
    return 1;
  }
  return 0;
}
