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

/**
 * Apache Arrow C ABI wrappers.
 *
 * All `arrow_*_c` functions below are thin wrappers over the Apache Arrow
 * C library (libarrow) column / batch manipulation intrinsics. They are
 * implemented in C (see seeds) and exposed to XLANG via `extern "C"`
 * declarations.
 *
 * ABI: C (System V / AAPCS). Calling convention matches the C runtime
 * and libarrow's published C ABI.
 * PLATFORM: SHARED — libarrow is available on all targets
 * (macOS arm64 / Ubuntu x86_64 / Windows MSYS2), with platform-specific
 * SIMD dispatch handled inside the C implementation.
 *
 * Column model: ArrowColumn wraps a typed column handle (i64 opaque).
 * ArrowBatch wraps a batch of columns (i64 opaque). All allocation /
 * deallocation goes through arrow_column_*_destroy_c / arrow_batch_destroy_c.
 *
 * Type tags: ARROW_I32=1, ARROW_F32=2, ARROW_F64=3 (returned by
 * arrow_column_type_c). Alignment: ARROW_ALIGN_BYTES=64 (cache-line).
 *
 * Unsafe contract: callers must wrap `arrow_*_c` calls in `unsafe { }`
 * blocks. P0a semantic downgrade currently allows unwrapped calls; P1
 * typeck enforcement (post-bootstrap) will reject unwrapped calls.
 */
const simd = import("std.simd");

/* See implementation. */
export const ARROW_I32: i32 = 1;
/* See implementation. */
export const ARROW_F32: i32 = 2;
/* See implementation. */
export const ARROW_F64: i32 = 3;

/* See implementation. */
export const ARROW_ALIGN_BYTES: i32 = 64;

/* See implementation. */
export struct ArrowColumn {
  handle: i64;
}

/* See implementation. */
export struct ArrowBatch {
  handle: i64;
}

extern "C" function arrow_column_i32_create_c(capacity: i32): i64;
extern "C" function arrow_column_f32_create_c(capacity: i32): i64;
extern "C" function arrow_column_f64_create_c(capacity: i32): i64;
extern "C" function arrow_column_adopt_f32_c(ptr: *f32, len: i32, capacity: i32): i64;
extern "C" function arrow_column_adopt_i32_c(ptr: *i32, len: i32, capacity: i32): i64;
extern "C" function arrow_column_type_c(handle: i64): i32;
extern "C" function arrow_column_len_c(handle: i64): i32;
extern "C" function arrow_column_capacity_c(handle: i64): i32;
extern "C" function arrow_column_data_owned_c(handle: i64): i32;
extern "C" function arrow_column_null_bitmap_c(handle: i64): *u8;
extern "C" function arrow_column_is_valid_c(handle: i64, index: i32): i32;
extern "C" function arrow_column_i32_data_c(handle: i64): *i32;
extern "C" function arrow_column_f32_data_c(handle: i64): *f32;
extern "C" function arrow_column_f64_data_c(handle: i64): *f64;
extern "C" function arrow_column_i32_append_c(handle: i64, val: i32): i32;
extern "C" function arrow_column_i32_append_null_c(handle: i64, val: i32, is_valid: i32): i32;
extern "C" function arrow_column_f32_append_c(handle: i64, val: f32): i32;
extern "C" function arrow_column_f64_append_c(handle: i64, val: f64): i32;
extern "C" function arrow_column_destroy_c(handle: i64): void;
extern "C" function arrow_batch_create_c(max_cols: i32): i64;
extern "C" function arrow_batch_add_column_c(batch: i64, col: i64): i32;
extern "C" function arrow_batch_column_c(batch: i64, index: i32): i64;
extern "C" function arrow_batch_len_c(batch: i64): i32;
extern "C" function arrow_batch_destroy_c(batch: i64): void;
extern "C" function arrow_column_i32_sum_valid_c(handle: i64, n: i32): i32;
extern "C" function arrow_column_f32_sum_c(handle: i64, n: i32): f32;
extern "C" function arrow_column_f32_sum_valid_c(handle: i64, n: i32): f32;
extern "C" function arrow_column_f32_dot_c(handle_a: i64, handle_b: i64, n: i32): f32;
extern "C" function arrow_smoke_c(): i32;

/** Exported function `new_i32`.
 * Implements `new_i32`.
 * @param capacity i32
 * @return ArrowColumn
 */
export function new_i32(capacity: i32): ArrowColumn {
  let _rc: ArrowColumn = 0;
  unsafe { _rc = ArrowColumn { handle: arrow_column_i32_create_c(capacity) }; }
  return _rc;
}

/** Exported function `new_f32`.
 * Implements `new_f32`.
 * @param capacity i32
 * @return ArrowColumn
 */
export function new_f32(capacity: i32): ArrowColumn {
  let _rc: ArrowColumn = 0;
  unsafe { _rc = ArrowColumn { handle: arrow_column_f32_create_c(capacity) }; }
  return _rc;
}

/** Exported function `new_f64`.
 * Implements `new_f64`.
 * @param capacity i32
 * @return ArrowColumn
 */
export function new_f64(capacity: i32): ArrowColumn {
  let _rc: ArrowColumn = 0;
  unsafe { _rc = ArrowColumn { handle: arrow_column_f64_create_c(capacity) }; }
  return _rc;
}

/**
 * See implementation.
 * See implementation.
 */
export function adopt(ptr: *f32, len: i32, capacity: i32): ArrowColumn {
  let _rc: ArrowColumn = 0;
  unsafe { _rc = ArrowColumn { handle: arrow_column_adopt_f32_c(ptr, len, capacity) }; }
  return _rc;
}

/** Exported function `adopt`.
 * Implements `adopt`.
 * @param ptr *i32
 * @param len i32
 * @param capacity i32
 * @return ArrowColumn
 */
export function adopt(ptr: *i32, len: i32, capacity: i32): ArrowColumn {
  let _rc: ArrowColumn = 0;
  unsafe { _rc = ArrowColumn { handle: arrow_column_adopt_i32_c(ptr, len, capacity) }; }
  return _rc;
}

/** Exported function `len`.
 * Implements `len`.
 * @param col ArrowColumn
 * @return i32
 */
export function len(col: ArrowColumn): i32 {
  unsafe { return arrow_column_len_c(col.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `owned`.
 * Implements `owned`.
 * @param col ArrowColumn
 * @return i32
 */
export function owned(col: ArrowColumn): i32 {
  unsafe { return arrow_column_data_owned_c(col.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `null_bitmap`.
 * Implements `null_bitmap`.
 * @param col ArrowColumn
 * @return *u8
 */
export function null_bitmap(col: ArrowColumn): *u8 {
  unsafe { return arrow_column_null_bitmap_c(col.handle); }
  return 0 as *u8; // unreachable — typeck workaround
}

/** Exported function `valid`.
 * Implements `valid`.
 * @param col ArrowColumn
 * @param index i32
 * @return i32
 */
export function valid(col: ArrowColumn, index: i32): i32 {
  unsafe { return arrow_column_is_valid_c(col.handle, index); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `data_i32`.
 * Implements `data_i32`.
 * @param col ArrowColumn
 * @return *i32
 */
export function data_i32(col: ArrowColumn): *i32 {
  unsafe { return arrow_column_i32_data_c(col.handle); }
  return 0 as *i32; // unreachable — typeck workaround
}

/** Exported function `data_f32`.
 * Implements `data_f32`.
 * @param col ArrowColumn
 * @return *f32
 */
export function data_f32(col: ArrowColumn): *f32 {
  unsafe { return arrow_column_f32_data_c(col.handle); }
  return 0 as *f32; // unreachable — typeck workaround
}

/** Exported function `data_f64`.
 * Implements `data_f64`.
 * @param col ArrowColumn
 * @return *f64
 */
export function data_f64(col: ArrowColumn): *f64 {
  unsafe { return arrow_column_f64_data_c(col.handle); }
  return 0 as *f64; // unreachable — typeck workaround
}

/** Exported function `append`.
 * Implements `append`.
 * @param col ArrowColumn
 * @param val i32
 * @return i32
 */
export function append(col: ArrowColumn, val: i32): i32 {
  unsafe { return arrow_column_i32_append_c(col.handle, val); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `append_null`.
 * Implements `append_null`.
 * @param col ArrowColumn
 * @param val i32
 * @param is_valid i32
 * @return i32
 */
export function append_null(col: ArrowColumn, val: i32, is_valid: i32): i32 {
  unsafe { return arrow_column_i32_append_null_c(col.handle, val, is_valid); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `append`.
 * Implements `append`.
 * @param col ArrowColumn
 * @param val f32
 * @return i32
 */
export function append(col: ArrowColumn, val: f32): i32 {
  unsafe { return arrow_column_f32_append_c(col.handle, val); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `append`.
 * Implements `append`.
 * @param col ArrowColumn
 * @param val f64
 * @return i32
 */
export function append(col: ArrowColumn, val: f64): i32 {
  unsafe { return arrow_column_f64_append_c(col.handle, val); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `free`.
 * Memory management helper `free`.
 * @param col ArrowColumn
 * @return void
 */
export function free(col: ArrowColumn): void {
  unsafe { arrow_column_destroy_c(col.handle); }
}

/** Exported function `batch`.
 * Implements `batch`.
 * @param max_cols i32
 * @return ArrowBatch
 */
export function batch(max_cols: i32): ArrowBatch {
  let _rc: ArrowBatch = 0;
  unsafe { _rc = ArrowBatch { handle: arrow_batch_create_c(max_cols) }; }
  return _rc;
}

/** Exported function `add`.
 * Implements `add`.
 * @param batch ArrowBatch
 * @param col ArrowColumn
 * @return i32
 */
export function add(batch: ArrowBatch, col: ArrowColumn): i32 {
  unsafe { return arrow_batch_add_column_c(batch.handle, col.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `get`.
 * Implements `get`.
 * @param batch ArrowBatch
 * @param index i32
 * @return ArrowColumn
 */
export function get(batch: ArrowBatch, index: i32): ArrowColumn {
  let _rc: ArrowColumn = 0;
  unsafe { _rc = ArrowColumn { handle: arrow_batch_column_c(batch.handle, index) }; }
  return _rc;
}

/** Exported function `len`.
 * Implements `len`.
 * @param batch ArrowBatch
 * @return i32
 */
export function len(batch: ArrowBatch): i32 {
  unsafe { return arrow_batch_len_c(batch.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `free`.
 * Memory management helper `free`.
 * @param batch ArrowBatch
 * @return void
 */
export function free(batch: ArrowBatch): void {
  unsafe { arrow_batch_destroy_c(batch.handle); }
}

/**
 * See implementation.
 */
export function sum_valid_i32(col: ArrowColumn, n: i32): i32 {
  unsafe { return arrow_column_i32_sum_valid_c(col.handle, n); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `sum`.
 * Implements `sum`.
 * @param col ArrowColumn
 * @param n i32
 * @return f32
 */
export function sum(col: ArrowColumn, n: i32): f32 {
  unsafe { return arrow_column_f32_sum_c(col.handle, n); }
  return 0 as f32; // unreachable — typeck workaround
}

/** Exported function `sum_valid_f32`.
 * Implements `sum_valid_f32`.
 * @param col ArrowColumn
 * @param n i32
 * @return f32
 */
export function sum_valid_f32(col: ArrowColumn, n: i32): f32 {
  unsafe { return arrow_column_f32_sum_valid_c(col.handle, n); }
  return 0 as f32; // unreachable — typeck workaround
}

/** Exported function `dot`.
 * Implements `dot`.
 * @param a ArrowColumn
 * @param b ArrowColumn
 * @param n i32
 * @return f32
 */
export function dot(a: ArrowColumn, b: ArrowColumn, n: i32): f32 {
  unsafe { return arrow_column_f32_dot_c(a.handle, b.handle, n); }
  return 0 as f32; // unreachable — typeck workaround
}

/** Exported function `simd_hw_available`.
 * Implements `simd_hw_available`.
 * @return i32
 */
export function simd_hw_available(): i32 {
  return simd.hw_available();
}
