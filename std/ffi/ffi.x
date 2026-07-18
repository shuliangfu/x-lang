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

extern "C" function malloc(n: usize): *u8;
extern "C" function free(p: *u8): void;
extern "C" function strlen(s: *u8): usize;
extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;

/* See implementation. */
export const FFI_CB_HANDLE_DOUBLE_I32: usize = 1;

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

/** Exported function `ffi_f_zero_c_marker_c`.
 * Implements `ffi_f_zero_c_marker_c`.
 * @return i32
 */
export function ffi_f_zero_c_marker_c(): i32 {
  return 1;
}

/** Exported function `ffi_cb_double_i32_impl`.
 * Implements `ffi_cb_double_i32_impl`.
 * @param arg i32
 * @return i32
 */
export function ffi_cb_double_i32_impl(arg: i32): i32 {
  return arg * 2;
}

/** Exported function `ffi_cb_double_i32_fn_c`.
 * Implements `ffi_cb_double_i32_fn_c`.
 * @return usize
 */
export function ffi_cb_double_i32_fn_c(): usize {
  return FFI_CB_HANDLE_DOUBLE_I32;
}

/**
 * See implementation.
 * See implementation.
 */
export function ffi_invoke_i32_cb_c(cb: usize, arg: i32): i32 {
  if (cb == 0) { return -1; }
  if (cb == FFI_CB_HANDLE_DOUBLE_I32) { return ffi_cb_double_i32_impl(arg); }
  return -1;
}

/** Exported function `ffi_cstr_len_c`.
 * Implements `ffi_cstr_len_c`.
 * @param ptr *u8
 * @return i32
 */
export function ffi_cstr_len_c(ptr: *u8): i32 {
  let n: usize = 0;
  if (ptr == 0) { return -1; }
  unsafe {
    n = strlen(ptr);
  }
  if (n > 0x7fffffff) { return 0x7fffffff; }
  return n as i32;
}

/** Exported function `ffi_cstring_new_c`.
 * Implements `ffi_cstring_new_c`.
 * @param ptr *u8
 * @param len i32
 * @return *u8
 */
export function ffi_cstring_new_c(ptr: *u8, len: i32): *u8 {
  let p: *u8 = 0 as *u8;
  let n: usize = 0;
  if (len < 0) { return 0 as *u8; }
  n = (len as usize) + 1;
  unsafe {
    p = malloc(n);
  }
  if (p == 0) { return 0 as *u8; }
  if (ptr != 0 && len > 0) {
    unsafe {
      memcpy(p, ptr, len);
    }
  }
  p[len] = 0;
  return p;
}

/** Exported function `ffi_cstring_free_c`.
 * Memory management helper `ffi_cstring_free_c`.
 * @param ptr *u8
 * @return void
 */
export function ffi_cstring_free_c(ptr: *u8): void {
  if (ptr != 0) {
    unsafe {
      free(ptr);
    }
  }
}

/** Exported function `ffi_cstring_try_new_c`.
 * Implements `ffi_cstring_try_new_c`.
 * @param ptr *u8
 * @param len i32
 * @param out *usize
 * @return i32
 */
export function ffi_cstring_try_new_c(ptr: *u8, len: i32, out: *usize): i32 {
  let p: *u8 = 0 as *u8;
  if (out == 0) { return FFI_ERR_NULL; }
  if (len < 0) {
    out[0] = 0;
    return FFI_ERR_INVALID_LEN;
  }
  p = ffi_cstring_new_c(ptr, len);
  if (p == 0) {
    out[0] = 0;
    return FFI_ERR_OOM;
  }
  out[0] = p as usize;
  return FFI_OK;
}

/** Exported function `ffi_cstring_lifecycle_smoke_c`.
 * Implements `ffi_cstring_lifecycle_smoke_c`.
 * @return i32
 */
export function ffi_cstring_lifecycle_smoke_c(): i32 {
  let src: u8[3] = [97, 98, 99];
  let owned: usize = 0;
  if (ffi_cstring_try_new_c(&src[0], 3, &owned) != FFI_OK) { return 1; }
  if (owned == 0) { return 2; }
  if (ffi_cstr_len_c(owned as *u8) != 3) { return 3; }
  ffi_cstring_free_c(owned as *u8);
  owned = 99;
  if (ffi_cstring_try_new_c(&src[0], 0 - 1, &owned) != FFI_ERR_INVALID_LEN) { return 4; }
  if (owned != 0) { return 5; }
  return 0;
}

/** Exported function `ffi_point_pack_c`.
 * Implements `ffi_point_pack_c`.
 * @param buf *u8
 * @param cap i32
 * @param x i32
 * @param y i32
 * @return i32
 */
export function ffi_point_pack_c(buf: *u8, cap: i32, x: i32, y: i32): i32 {
  if (buf == 0) { return -1; }
  if (cap < 8) { return FFI_ERR_TOO_SMALL; }
  buf[0] = (x & 255) as u8;
  buf[1] = ((x >> 8) & 255) as u8;
  buf[2] = ((x >> 16) & 255) as u8;
  buf[3] = ((x >> 24) & 255) as u8;
  buf[4] = (y & 255) as u8;
  buf[5] = ((y >> 8) & 255) as u8;
  buf[6] = ((y >> 16) & 255) as u8;
  buf[7] = ((y >> 24) & 255) as u8;
  return 0;
}

/** Exported function `ffi_point_unpack_c`.
 * Implements `ffi_point_unpack_c`.
 * @param buf *u8
 * @param cap i32
 * @param out *FfiPoint
 * @return i32
 */
export function ffi_point_unpack_c(buf: *u8, cap: i32, out: *FfiPoint): i32 {
  let ux: u32 = 0;
  let uy: u32 = 0;
  if (buf == 0 || out == 0) { return -1; }
  if (cap < 8) { return FFI_ERR_TOO_SMALL; }
  ux = (buf[0] as u32) | ((buf[1] as u32) << 8) | ((buf[2] as u32) << 16) | ((buf[3] as u32) << 24);
  uy = (buf[4] as u32) | ((buf[5] as u32) << 8) | ((buf[6] as u32) << 16) | ((buf[7] as u32) << 24);
  out.x = ux as i32;
  out.y = uy as i32;
  return 0;
}

/** Exported function `ffi_struct_callback_smoke_c`.
 * Implements `ffi_struct_callback_smoke_c`.
 * @return i32
 */
export function ffi_struct_callback_smoke_c(): i32 {
  let buf: u8[8];
  let pt: FfiPoint;
  let cb: usize = 0;
  if (ffi_point_pack_c(&buf[0], 8, 3, 4) != 0) { return 1; }
  if (ffi_point_unpack_c(&buf[0], 8, &pt) != 0) { return 2; }
  if (pt.x != 3 || pt.y != 4) { return 3; }
  if (ffi_point_pack_c(&buf[0], 4, 0, 0) != FFI_ERR_TOO_SMALL) { return 4; }
  if (ffi_invoke_i32_cb_c(0, 1) != -1) { return 5; }
  cb = ffi_cb_double_i32_fn_c();
  if (ffi_invoke_i32_cb_c(cb, 5) != 10) { return 6; }
  return 0;
}
