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
//
// See implementation.

export const DYNLIB_LAST_ERR_CAP: i32 = 256;

/* See implementation. */
let g_dynlib_last_err: u8[256] = [];

extern function dynlib_os_open_c(path: *u8): *u8;
extern function dynlib_os_sym_c(lib: *u8, name: *u8): *u8;
extern function dynlib_os_close_c(lib: *u8): void;
extern function dynlib_os_copy_last_error_c(buf: *u8, cap: i32): i32;
extern function dynlib_os_win_path_smoke_c(): i32;
extern function memcpy(dst: *u8, src: *u8, n: usize): *u8;
extern function memset(s: *u8, c: i32, n: usize): *u8;

/** Exported function `dynlib_f_dynlib_v1_marker_c`.
 * Implements `dynlib_f_dynlib_v1_marker_c`.
 * @return i32
 */
export function dynlib_f_dynlib_v1_marker_c(): i32 {
  return 1;
}

/** Exported function `dynlib_f_dynlib_v2_marker_c`.
 * Implements `dynlib_f_dynlib_v2_marker_c`.
 * @return i32
 */
export function dynlib_f_dynlib_v2_marker_c(): i32 {
  return 1;
}

/** Exported function `dynlib_note_os_error_c`.
 * Implements `dynlib_note_os_error_c`.
 * @return void
 */
export function dynlib_note_os_error_c(): void {
  unsafe { memset(&g_dynlib_last_err[0], 0, DYNLIB_LAST_ERR_CAP); }
  unsafe { dynlib_os_copy_last_error_c(&g_dynlib_last_err[0], DYNLIB_LAST_ERR_CAP); }
}

/** Exported function `dynlib_open_c`.
 * Implements `dynlib_open_c`.
 * @param path *u8
 * @return *u8
 */
export function dynlib_open_c(path: *u8): *u8 {
  let h: *u8 = 0 as *u8;
  if (path == 0 || path[0] == 0) {
    return 0 as *u8;
  }
  unsafe { h = dynlib_os_open_c(path); }
  if (h == 0) {
    dynlib_note_os_error_c();
  }
  return h;
}

/** Exported function `dynlib_sym_c`.
 * Implements `dynlib_sym_c`.
 * @param lib *u8
 * @param name *u8
 * @return *u8
 */
export function dynlib_sym_c(lib: *u8, name: *u8): *u8 {
  let p: *u8 = 0 as *u8;
  if (lib == 0 || name == 0) {
    return 0 as *u8;
  }
  unsafe { p = dynlib_os_sym_c(lib, name); }
  if (p == 0) {
    dynlib_note_os_error_c();
  }
  return p;
}

/** Exported function `dynlib_close_c`.
 * Implements `dynlib_close_c`.
 * @param lib *u8
 * @return void
 */
export function dynlib_close_c(lib: *u8): void {
  if (lib == 0) {
    return;
  }
  unsafe { dynlib_os_close_c(lib); }
}

/** Exported function `dynlib_last_error_copy_c`.
 * Implements `dynlib_last_error_copy_c`.
 * @param buf *u8
 * @param cap i32
 * @return i32
 */
export function dynlib_last_error_copy_c(buf: *u8, cap: i32): i32 {
  let n: i32 = 0;
  let i: i32 = 0;
  if (buf == 0 || cap <= 0) {
    return 0;
  }
  while (i < DYNLIB_LAST_ERR_CAP && g_dynlib_last_err[i] != 0) {
    n = n + 1;
    i = i + 1;
  }
  if (n == 0) {
    return 0;
  }
  if (n >= cap) {
    n = cap - 1;
  }
  unsafe { memcpy(buf, &g_dynlib_last_err[0], n); }
  buf[n] = 0;
  return n;
}

/** Exported function `dynlib_last_error_smoke_c`.
 * Implements `dynlib_last_error_smoke_c`.
 * @return i32
 */
export function dynlib_last_error_smoke_c(): i32 {
  let bad: u8[48] = [
    47, 110, 111, 110, 101, 120, 105, 115, 116, 101, 110, 116, 47, 115, 104, 117, 120, 95, 100, 121,
    110, 108, 105, 98, 95, 109, 105, 115, 115, 105, 110, 103, 46, 115, 111, 0
  ];
  let msg: u8[128] = [];
  let lib: *u8 = 0 as *u8;
  let n: i32 = 0;
  lib = dynlib_open_c(&bad[0]);
  if (lib != 0) {
    dynlib_close_c(lib);
    return -1;
  }
  n = dynlib_last_error_copy_c(&msg[0], 128);
  if (n > 0) {
    return 0;
  }
  return -2;
}

/** Exported function `dynlib_win_path_smoke_c`.
 * Implements `dynlib_win_path_smoke_c`.
 * @return i32
 */
export function dynlib_win_path_smoke_c(): i32 {
  unsafe { return dynlib_os_win_path_smoke_c(); }
  return 0; // unreachable — typeck workaround
}
