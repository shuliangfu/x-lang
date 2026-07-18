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

extern function dynlib_open_c(path: *u8): *u8;
extern function dynlib_sym_c(lib: *u8, name: *u8): *u8;
extern function dynlib_close_c(lib: *u8): void;
extern function dynlib_last_error_copy_c(buf: *u8, cap: i32): i32;

/** Exported function `open`.
 * Implements `open`.
 * @param path *u8
 * @return *u8
 */
export function open(path: *u8): *u8 {
  let _rc: *u8 = 0;
  unsafe { _rc = dynlib_open_c(path); }
  return _rc;
}

/** Exported function `sym`.
 * Implements `sym`.
 * @param lib *u8
 * @param name *u8
 * @return *u8
 */
export function sym(lib: *u8, name: *u8): *u8 {
  let _rc: *u8 = 0;
  unsafe { _rc = dynlib_sym_c(lib, name); }
  return _rc;
}

/** Exported function `close`.
 * Implements `close`.
 * @param lib *u8
 * @return void
 */
export function close(lib: *u8): void {
  unsafe {
    dynlib_close_c(lib);
  }
}

/** Exported function `last_os_error`.
 * Implements `last_os_error`.
 * @param buf *u8
 * @param cap i32
 * @return i32
 */
export function last_os_error(buf: *u8, cap: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = dynlib_last_error_copy_c(buf, cap); }
  return _rc;
}
