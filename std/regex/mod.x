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
// See implementation.
//
// See implementation.
// See implementation.
extern function regex_compile_c(pat: *u8, pat_len: i32): *u8;
extern function regex_match_c(re: *u8, str: *u8, len: i32): i32;
extern function regex_free_c(re: *u8): void;
extern function regex_group_count_c(re: *u8): i32;
extern function regex_group_offset_c(re: *u8, group: i32): i32;
extern function regex_group_length_c(re: *u8, group: i32): i32;

/** Exported function `compile`.
 * Implements `compile`.
 * @param pat *u8
 * @param pat_len i32
 * @return *u8
 */
export function compile(pat: *u8, pat_len: i32): *u8 {
  let _rc: *u8 = 0;
  unsafe { _rc = regex_compile_c(pat, pat_len); }
  return _rc;
}

/** Exported function `match`.
 * Implements `match`.
 * @param re *u8
 * @param str *u8
 * @param len i32
 * @return i32
 */
export function match(re: *u8, str: *u8, len: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = regex_match_c(re, str, len); }
  return _rc;
}

/** Exported function `free`.
 * Memory management helper `free`.
 * @param re *u8
 * @return void
 */
export function free(re: *u8): void {
  unsafe {
    regex_free_c(re);
  }
}

/** Exported function `group_count`.
 * Implements `group_count`.
 * @param re *u8
 * @return i32
 */
export function group_count(re: *u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = regex_group_count_c(re); }
  return _rc;
}

/** Exported function `group_offset`.
 * Implements `group_offset`.
 * @param re *u8
 * @param group i32
 * @return i32
 */
export function group_offset(re: *u8, group: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = regex_group_offset_c(re, group); }
  return _rc;
}

/** Exported function `group_length`.
 * Implements `group_length`.
 * @param re *u8
 * @param group i32
 * @return i32
 */
export function group_length(re: *u8, group: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = regex_group_length_c(re, group); }
  return _rc;
}
