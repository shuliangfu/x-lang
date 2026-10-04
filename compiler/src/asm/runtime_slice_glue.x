// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_slice_glue.x — 16-byte slice values for core.slice.
//
// Darwin arm64 product body for ../core/slice/slice.o. Each constructor
// writes { data, length } through an out pointer. The installed product
// cannot asm-emit a struct return or a usize return, and a 16-byte
// struct uses rax and rdx, so an i64 return would not be the same ABI.
// Link names stay the same. Linux and Windows keep the C seed, which
// writes the same out pointer.
// PLATFORM: SHARED layout; MACOS|DARWIN arm64 prefers this .x.

/* Two-word slice: pointer then element count. */
export struct XlangSliceI32 {
  data: *i32;
  length: usize;
}

/* Two-word slice: pointer then element count. */
export struct XlangSliceU8 {
  data: *u8;
  length: usize;
}

/* Two-word slice: pointer then element count. */
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

/** Build an i32 slice from a pointer and a length. No bounds check.
 * @param out receives { data, length }; must not be null
 * @param data element pointer, may be null when len is 0
 * @param len element count
 * PLATFORM: SHARED — struct return is not asm-emitted by the product.
 */
#[no_mangle]
export function core_slice_i32_from_ptr_c(out: *XlangSliceI32, data: *i32, len: usize): void {
  let s: XlangSliceI32 = { data: data, length: len };
  unsafe { *out = s; }
}

/** Build a u8 slice from a pointer and a length. No bounds check.
 * @param out receives { data, length }; must not be null
 * @param data byte pointer, may be null when len is 0
 * @param len byte count
 * PLATFORM: SHARED — struct return is not asm-emitted by the product.
 */
#[no_mangle]
export function core_slice_u8_from_ptr_c(out: *XlangSliceU8, data: *u8, len: usize): void {
  let s: XlangSliceU8 = { data: data, length: len };
  unsafe { *out = s; }
}

/** Build a u64 slice from a pointer and a length. No bounds check.
 * @param out receives { data, length }; must not be null
 * @param data element pointer, may be null when len is 0
 * @param len element count
 * PLATFORM: SHARED — struct return is not asm-emitted by the product.
 */
#[no_mangle]
export function core_slice_u64_from_ptr_c(out: *XlangSliceU64, data: *u64, len: usize): void {
  let s: XlangSliceU64 = { data: data, length: len };
  unsafe { *out = s; }
}

/** How many elements of a subslice fit in [start, total).
 * A start at or past total returns 0. A len past the end is cut
 * to total - start. The caller still owns the pointer adjustment.
 * @param total_len element count of the source
 * @param start first element to keep
 * @param len requested count
 * @return the clamped count in rax; low 64 bits, never negative
 * PLATFORM: SHARED — the product cannot asm-emit a usize return.
 */
#[no_mangle]
function slice_glue_clamp_len(total_len: usize, start: usize, len: usize): i64 {
  let avail: usize = 0;
  if (start >= total_len) { return 0; }
  avail = total_len - start;
  if (len > avail) { return avail as i64; }
  return len as i64;
}

/** Build an i32 subslice. A start past the end keeps data and length 0.
 * A request past the end is cut to the elements that remain.
 * @param out receives { data, length }; must not be null
 * @param data base element pointer
 * @param total_len element count of the source
 * @param start first element to keep
 * @param len requested count
 * PLATFORM: SHARED — struct return is not asm-emitted by the product.
 */
#[no_mangle]
export function core_subslice_i32_c(out: *XlangSliceI32, data: *i32, total_len: usize, start: usize, len: usize): void {
  // Clamp in an i64 function. The product cannot emit a usize return.
  let n: usize = slice_glue_clamp_len(total_len, start, len) as usize;
  let off: usize = start;
  if (start >= total_len) { off = 0; }
  let s: XlangSliceI32 = { data: data + off, length: n };
  unsafe { *out = s; }
}

/** Build a u8 subslice. Pointer add scales by one byte.
 * @param out receives { data, length }; must not be null
 * @param data base byte pointer
 * @param total_len byte count of the source
 * @param start first byte to keep
 * @param len requested count
 * PLATFORM: SHARED — struct return is not asm-emitted by the product.
 */
#[no_mangle]
export function core_subslice_u8_c(out: *XlangSliceU8, data: *u8, total_len: usize, start: usize, len: usize): void {
  let n: usize = slice_glue_clamp_len(total_len, start, len) as usize;
  let off: usize = start;
  if (start >= total_len) { off = 0; }
  let s: XlangSliceU8 = { data: data + off, length: n };
  unsafe { *out = s; }
}

/** Build a u64 subslice. Pointer add scales by eight bytes.
 * @param out receives { data, length }; must not be null
 * @param data base element pointer
 * @param total_len element count of the source
 * @param start first element to keep
 * @param len requested count
 * PLATFORM: SHARED — struct return is not asm-emitted by the product.
 */
#[no_mangle]
export function core_subslice_u64_c(out: *XlangSliceU64, data: *u64, total_len: usize, start: usize, len: usize): void {
  let n: usize = slice_glue_clamp_len(total_len, start, len) as usize;
  let off: usize = start;
  if (start >= total_len) { off = 0; }
  let s: XlangSliceU64 = { data: data + off, length: n };
  unsafe { *out = s; }
}
