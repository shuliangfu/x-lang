// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_slice_glue.x — 16-byte slice values for core.slice.
//
// Darwin arm64 product body for ../core/slice/slice.o. Each returned
// value is { data, length }. A start past the end keeps the original
// pointer and length 0. A request that runs past the end is cut to the
// bytes or elements that remain. Linux and Windows keep the C seed.
// PLATFORM: SHARED layout; MACOS|DARWIN arm64 prefers this .x.

/* See implementation. */
export struct XlangSliceI32 {
  data: *i32;
  length: usize;
}

/* See implementation. */
export struct XlangSliceU8 {
  data: *u8;
  length: usize;
}

/* See implementation. */
export struct XlangSliceU64 {
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
 * @return XlangSliceI32
 */
#[no_mangle]
export function core_slice_i32_from_ptr_c(data: *i32, len: usize): XlangSliceI32 {
  // A live pad pulls the 16-byte return slot inside this frame.
  // Without it the slot sits on the frame edge, past the safe room.
  let pad: u8[64] = [];
  pad[0] = 0;
  let s: XlangSliceI32 = { data: data, length: len };
  return s;
}

/** Exported function `core_slice_u8_from_ptr_c`.
 * Implements `core_slice_u8_from_ptr_c`.
 * @param data *u8
 * @param length usize
 * @return XlangSliceU8
 */
#[no_mangle]
export function core_slice_u8_from_ptr_c(data: *u8, len: usize): XlangSliceU8 {
  // A live pad pulls the 16-byte return slot inside this frame.
  // Without it the slot sits on the frame edge, past the safe room.
  let pad: u8[64] = [];
  pad[0] = 0;
  let s: XlangSliceU8 = { data: data, length: len };
  return s;
}

/** Exported function `core_slice_u64_from_ptr_c`.
 * Implements `core_slice_u64_from_ptr_c`.
 * @param data *u64
 * @param length usize
 * @return XlangSliceU64
 */
#[no_mangle]
export function core_slice_u64_from_ptr_c(data: *u64, len: usize): XlangSliceU64 {
  // A live pad pulls the 16-byte return slot inside this frame.
  // Without it the slot sits on the frame edge, past the safe room.
  let pad: u8[64] = [];
  pad[0] = 0;
  let s: XlangSliceU64 = { data: data, length: len };
  return s;
}

/** How many elements of a subslice fit in [start, total).
 * A start at or past total returns 0. A len past the end is cut
 * to total - start. The caller still owns the pointer adjustment.
 * @param total_len element count of the source
 * @param start first element to keep
 * @param len requested count
 * @return the clamped count
 * PLATFORM: SHARED
 */
function slice_glue_clamp_len(total_len: usize, start: usize, len: usize): usize {
  let avail: usize = 0;
  if (start >= total_len) { return 0; }
  avail = total_len - start;
  if (len > avail) { return avail; }
  return len;
}

/** Exported function `core_subslice_i32_c`.
 * Implements `core_subslice_i32_c`.
 * @param data *i32
 * @param total_len usize
 * @param start usize
 * @param len usize
 * @return XlangSliceI32
 */
#[no_mangle]
export function core_subslice_i32_c(data: *i32, total_len: usize, start: usize, len: usize): XlangSliceI32 {
  // A live pad pulls the 16-byte return slot inside this frame.
  // Without it the slot sits on the frame edge, past the safe room.
  let pad: u8[64] = [];
  pad[0] = 0;
  // Clamp in a usize function. Two slice literals in this function drop the call.
  let n: usize = slice_glue_clamp_len(total_len, start, len);
  let off: usize = start;
  if (start >= total_len) { off = 0; }
  let s: XlangSliceI32 = { data: data + off, length: n };
  return s;
}

/** Exported function `core_subslice_u8_c`.
 * Implements `core_subslice_u8_c`.
 * @param data *u8
 * @param total_len usize
 * @param start usize
 * @param len usize
 * @return XlangSliceU8
 */
#[no_mangle]
export function core_subslice_u8_c(data: *u8, total_len: usize, start: usize, len: usize): XlangSliceU8 {
  // A live pad pulls the 16-byte return slot inside this frame.
  // Without it the slot sits on the frame edge, past the safe room.
  let pad: u8[64] = [];
  pad[0] = 0;
  // Same split as the i32 subslice. Pointer add scales by one byte.
  let n: usize = slice_glue_clamp_len(total_len, start, len);
  let off: usize = start;
  if (start >= total_len) { off = 0; }
  let s: XlangSliceU8 = { data: data + off, length: n };
  return s;
}

/** Exported function `core_subslice_u64_c`.
 * Implements `core_subslice_u64_c`.
 * @param data *u64
 * @param total_len usize
 * @param start usize
 * @param len usize
 * @return XlangSliceU64
 */
#[no_mangle]
export function core_subslice_u64_c(data: *u64, total_len: usize, start: usize, len: usize): XlangSliceU64 {
  // A live pad pulls the 16-byte return slot inside this frame.
  // Without it the slot sits on the frame edge, past the safe room.
  let pad: u8[64] = [];
  pad[0] = 0;
  // Same split as the i32 subslice. Pointer add scales by eight bytes.
  let n: usize = slice_glue_clamp_len(total_len, start, len);
  let off: usize = start;
  if (start >= total_len) { off = 0; }
  let s: XlangSliceU64 = { data: data + off, length: n };
  return s;
}
