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
extern function ffi_cstr_len_c(ptr: *u8): i32;
extern function ffi_cstring_new_c(ptr: *u8, len: i32): *u8;
extern function ffi_cstring_free_c(ptr: *u8): void;
extern function ffi_cstring_try_new_c(ptr: *u8, len: i32, out: *usize): i32;
extern function ffi_point_pack_c(buf: *u8, cap: i32, x: i32, y: i32): i32;
extern function ffi_point_unpack_c(buf: *u8, cap: i32, out: *FfiPoint): i32;
extern function ffi_cb_double_i32_fn_c(): usize;
extern function ffi_invoke_i32_cb_c(cb: usize, arg: i32): i32;

/* See implementation. */
export const FFI_OK: i32 = 0;
/* See implementation. */
export const FFI_ERR_NULL: i32 = -1;
/** len < 0。 */
export const FFI_ERR_INVALID_LEN: i32 = -2;
/* See implementation. */
export const FFI_ERR_OOM: i32 = -3;
/* See implementation. */
export const FFI_ERR_TOO_SMALL: i32 = -4;

/* See implementation. */
export struct FfiPoint {
  x: i32
  y: i32
}

/** Exported function `cstr_len`.
 * Query helper `cstr_len`.
 * @param ptr *u8
 * @return i32
 */
export function cstr_len(ptr: *u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = ffi_cstr_len_c(ptr); }
  return _rc;
}

/** Exported function `cstring_new`.
 * Implements `cstring_new`.
 * @param ptr *u8
 * @param len i32
 * @return *u8
 */
export function cstring_new(ptr: *u8, len: i32): *u8 {
  let _rc: *u8 = 0;
  unsafe { _rc = ffi_cstring_new_c(ptr, len); }
  return _rc;
}

/** Exported function `cstring_try_new`.
 * Implements `cstring_try_new`.
 * @param ptr *u8
 * @param len i32
 * @param out *usize
 * @return i32
 */
export function cstring_try_new(ptr: *u8, len: i32, out: *usize): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = ffi_cstring_try_new_c(ptr, len, out); }
  return _rc;
}

/** Exported function `cstring_free`.
 * Memory management helper `cstring_free`.
 * @param ptr *u8
 * @return void
 */
export function cstring_free(ptr: *u8): void {
  unsafe {
    ffi_cstring_free_c(ptr);
  }
}

/** Exported function `cstring_destroy`.
 * Implements `cstring_destroy`.
 * @param ptr *u8
 * @return void
 */
export function cstring_destroy(ptr: *u8): void {
  unsafe {
    ffi_cstring_free_c(ptr);
  }
}

/** Exported function `point_pack`.
 * Implements `point_pack`.
 * @param buf *u8
 * @param cap i32
 * @param x i32
 * @param y i32
 * @return i32
 */
export function point_pack(buf: *u8, cap: i32, x: i32, y: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = ffi_point_pack_c(buf, cap, x, y); }
  return _rc;
}

/** Exported function `point_unpack`.
 * Implements `point_unpack`.
 * @param buf *u8
 * @param cap i32
 * @param out *FfiPoint
 * @return i32
 */
export function point_unpack(buf: *u8, cap: i32, out: *FfiPoint): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = ffi_point_unpack_c(buf, cap, out); }
  return _rc;
}

/** Exported function `cb_double_fn`.
 * Implements `cb_double_fn`.
 * @return usize
 */
export function cb_double_fn(): usize {
  let _rc: usize = 0;
  unsafe { _rc = ffi_cb_double_i32_fn_c(); }
  return _rc;
}

/** Exported function `invoke_cb`.
 * Implements `invoke_cb`.
 * @param cb usize
 * @param arg i32
 * @return i32
 */
export function invoke_cb(cb: usize, arg: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = ffi_invoke_i32_cb_c(cb, arg); }
  return _rc;
}
