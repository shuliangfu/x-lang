// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.

/* See implementation. */
export struct ShuxSliceI32 {
  data: *i32;
  length: usize;
}

/* See implementation. */
export struct ShuxSliceU8 {
  data: *u8;
  length: usize;
}

/* See implementation. */
export struct ShuxSliceU64 {
  data: *u64;
  length: usize;
}

/** Exported function `runtime_slice_glue_x_doc_anchor`.
 * Implements `runtime_slice_glue_x_doc_anchor`.
 * @return i32
 */
export function runtime_slice_glue_x_doc_anchor(): i32 {
  return 0;
}

// See implementation.

/** Exported function `core_slice_i32_from_ptr_c`.
 * Implements `core_slice_i32_from_ptr_c`.
 * @param data *i32
 * @param length usize
 * @return ShuxSliceI32
 */
#[no_mangle]
export function core_slice_i32_from_ptr_c(data: *i32, length: usize): ShuxSliceI32 {
  let s: ShuxSliceI32 = ShuxSliceI32 { data: data, length: length };
  return s;
}

/** Exported function `core_slice_u8_from_ptr_c`.
 * Implements `core_slice_u8_from_ptr_c`.
 * @param data *u8
 * @param length usize
 * @return ShuxSliceU8
 */
#[no_mangle]
export function core_slice_u8_from_ptr_c(data: *u8, length: usize): ShuxSliceU8 {
  let s: ShuxSliceU8 = ShuxSliceU8 { data: data, length: length };
  return s;
}

/** Exported function `core_slice_u64_from_ptr_c`.
 * Implements `core_slice_u64_from_ptr_c`.
 * @param data *u64
 * @param length usize
 * @return ShuxSliceU64
 */
#[no_mangle]
export function core_slice_u64_from_ptr_c(data: *u64, length: usize): ShuxSliceU64 {
  let s: ShuxSliceU64 = ShuxSliceU64 { data: data, length: length };
  return s;
}

/** Exported function `core_subslice_i32_c`.
 * Implements `core_subslice_i32_c`.
 * @param data *i32
 * @param total_len usize
 * @param start usize
 * @param len usize
 * @return ShuxSliceI32
 */
#[no_mangle]
export function core_subslice_i32_c(data: *i32, total_len: usize, start: usize, len: usize): ShuxSliceI32 {
  if (start >= total_len) {
    let s: ShuxSliceI32 = ShuxSliceI32 { data: data, length: 0 };
    return s;
  }
  let avail: usize = total_len - start;
  let actual_len: usize = len;
  if (len > avail) {
    actual_len = avail;
  }
  let s: ShuxSliceI32 = ShuxSliceI32 { data: data + start, length: actual_len };
  return s;
}

/** Exported function `core_subslice_u8_c`.
 * Implements `core_subslice_u8_c`.
 * @param data *u8
 * @param total_len usize
 * @param start usize
 * @param len usize
 * @return ShuxSliceU8
 */
#[no_mangle]
export function core_subslice_u8_c(data: *u8, total_len: usize, start: usize, len: usize): ShuxSliceU8 {
  if (start >= total_len) {
    let s: ShuxSliceU8 = ShuxSliceU8 { data: data, length: 0 };
    return s;
  }
  let avail: usize = total_len - start;
  let actual_len: usize = len;
  if (len > avail) {
    actual_len = avail;
  }
  let s: ShuxSliceU8 = ShuxSliceU8 { data: data + start, length: actual_len };
  return s;
}

/** Exported function `core_subslice_u64_c`.
 * Implements `core_subslice_u64_c`.
 * @param data *u64
 * @param total_len usize
 * @param start usize
 * @param len usize
 * @return ShuxSliceU64
 */
#[no_mangle]
export function core_subslice_u64_c(data: *u64, total_len: usize, start: usize, len: usize): ShuxSliceU64 {
  if (start >= total_len) {
    let s: ShuxSliceU64 = ShuxSliceU64 { data: data, length: 0 };
    return s;
  }
  let avail: usize = total_len - start;
  let actual_len: usize = len;
  if (len > avail) {
    actual_len = avail;
  }
  let s: ShuxSliceU64 = ShuxSliceU64 { data: data + start, length: actual_len };
  return s;
}
