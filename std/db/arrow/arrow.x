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
//
// See implementation.

export const ARROW_ALIGN: usize = 64;
export const ARROW_TYPE_I32: i32 = 1;
export const ARROW_TYPE_F32: i32 = 2;
export const ARROW_TYPE_F64: i32 = 3;

/* See implementation. */
allow(padding) struct ArrowColumnMem {
  type_id: i32;
  length: i32;
  capacity: i32;
  data: *u8;
  null_bitmap: *u8;
  data_owned: i32;
}

/* See implementation. */
allow(padding) struct ArrowBatchMem {
  n_cols: i32;
  cap_cols: i32;
  cols: *u64;
}

extern "C" function calloc(nmemb: usize, size: usize): *u8;
extern "C" function free(ptr: *u8): void;
extern "C" function memset(s: *u8, c: i32, n: usize): *u8;
extern "C" function posix_memalign(memptr: * *void, alignment: usize, size: usize): i32;

extern function arrow_column_i32_sum_valid_c(handle: i64, n: i32): i32;
extern function arrow_column_f32_sum_c(handle: i64, n: i32): f32;
extern function arrow_column_f32_sum_valid_c(handle: i64, n: i32): f32;
extern function arrow_column_f32_dot_c(handle_a: i64, handle_b: i64, n: i32): f32;

/**
 * See implementation.
 */
export function arrow_alloc_aligned(size: usize): *u8 {
  let out: *u8 = 0 as *u8;
  unsafe { if (posix_memalign(&out, ARROW_ALIGN, size) != 0) {
    return 0 as *u8;
  } }
  return out;
}

/**
 * See implementation.
 */
export function arrow_null_bitmap_alloc(capacity: i32): *u8 {
  let n: usize = 0;
  let bm: *u8 = 0 as *u8;
  if (capacity <= 0) {
    return 0 as *u8;
  }
  n = ((capacity as usize + 7) / 8);
  unsafe { bm = calloc(n, 1); }
  if (bm == 0) {
    return 0 as *u8;
  }
  unsafe { memset(bm, 0xff, n); }
  return bm;
}

/**
 * See implementation.
 */
export function arrow_null_bitmap_set(col: *ArrowColumnMem, index: i32, is_valid: i32): void {
  let byte_i: usize = 0;
  let mask: u8 = 0;
  if (col == 0 || col.null_bitmap == 0) {
    return;
  }
  if (index < 0 || index >= col.capacity) {
    return;
  }
  byte_i = (index as usize) / 8;
  mask = (1 as u8) << (index % 8);
  if (is_valid != 0) {
    col.null_bitmap[byte_i] = col.null_bitmap[byte_i] | mask;
  } else {
    col.null_bitmap[byte_i] = col.null_bitmap[byte_i] & ((255 as u8) ^ mask);
  }
}

/**
 * See implementation.
 */
export function arrow_column_create_typed(type_id: i32, capacity: i32, elem_size: usize): *ArrowColumnMem {
  let c: *ArrowColumnMem = 0 as *ArrowColumnMem;
  if (capacity <= 0) {
    return 0 as *ArrowColumnMem;
  }
  unsafe { c = calloc(1, 32) as *ArrowColumnMem; }
  if (c == 0) {
    return 0 as *ArrowColumnMem;
  }
  c.type_id = type_id;
  c.capacity = capacity;
  c.data_owned = 1;
  c.null_bitmap = arrow_null_bitmap_alloc(capacity);
  if (c.null_bitmap == 0) {
    unsafe { free(c as *u8); }
    return 0 as *ArrowColumnMem;
  }
  c.data = arrow_alloc_aligned((capacity as usize) * elem_size);
  if (c.data == 0) {
    unsafe { free(c.null_bitmap); }
    unsafe { free(c as *u8); }
    return 0 as *ArrowColumnMem;
  }
  return c;
}

/** Exported function `arrow_column_i32_create_c`.
 * Implements `arrow_column_i32_create_c`.
 * @param capacity i32
 * @return i64
 */
export function arrow_column_i32_create_c(capacity: i32): i64 {
  let c: *ArrowColumnMem = arrow_column_create_typed(ARROW_TYPE_I32, capacity, 4);
  if (c == 0) {
    return 0 as i64;
  }
  return c as i64;
}

/** Exported function `arrow_column_f32_create_c`.
 * Implements `arrow_column_f32_create_c`.
 * @param capacity i32
 * @return i64
 */
export function arrow_column_f32_create_c(capacity: i32): i64 {
  let c: *ArrowColumnMem = arrow_column_create_typed(ARROW_TYPE_F32, capacity, 4);
  if (c == 0) {
    return 0 as i64;
  }
  return c as i64;
}

/** Exported function `arrow_column_f64_create_c`.
 * Implements `arrow_column_f64_create_c`.
 * @param capacity i32
 * @return i64
 */
export function arrow_column_f64_create_c(capacity: i32): i64 {
  let c: *ArrowColumnMem = arrow_column_create_typed(ARROW_TYPE_F64, capacity, 8);
  if (c == 0) {
    return 0 as i64;
  }
  return c as i64;
}

/** Exported function `arrow_column_adopt_f32_c`.
 * Implements `arrow_column_adopt_f32_c`.
 * @param ptr *f32
 * @param len i32
 * @param capacity i32
 * @return i64
 */
export function arrow_column_adopt_f32_c(ptr: *f32, len: i32, capacity: i32): i64 {
  let c: *ArrowColumnMem = 0 as *ArrowColumnMem;
  if (ptr == 0 || len < 0 || capacity <= 0 || len > capacity) {
    return 0 as i64;
  }
  unsafe { c = calloc(1, 32) as *ArrowColumnMem; }
  if (c == 0) {
    return 0 as i64;
  }
  c.type_id = ARROW_TYPE_F32;
  c.length = len;
  c.capacity = capacity;
  c.data = ptr as *u8;
  c.data_owned = 0;
  c.null_bitmap = arrow_null_bitmap_alloc(capacity);
  if (c.null_bitmap == 0) {
    unsafe { free(c as *u8); }
    return 0 as i64;
  }
  return c as i64;
}

/** Exported function `arrow_column_adopt_i32_c`.
 * Implements `arrow_column_adopt_i32_c`.
 * @param ptr *i32
 * @param len i32
 * @param capacity i32
 * @return i64
 */
export function arrow_column_adopt_i32_c(ptr: *i32, len: i32, capacity: i32): i64 {
  let c: *ArrowColumnMem = 0 as *ArrowColumnMem;
  if (ptr == 0 || len < 0 || capacity <= 0 || len > capacity) {
    return 0 as i64;
  }
  unsafe { c = calloc(1, 32) as *ArrowColumnMem; }
  if (c == 0) {
    return 0 as i64;
  }
  c.type_id = ARROW_TYPE_I32;
  c.length = len;
  c.capacity = capacity;
  c.data = ptr as *u8;
  c.data_owned = 0;
  c.null_bitmap = arrow_null_bitmap_alloc(capacity);
  if (c.null_bitmap == 0) {
    unsafe { free(c as *u8); }
    return 0 as i64;
  }
  return c as i64;
}

/** Exported function `arrow_column_type_c`.
 * Implements `arrow_column_type_c`.
 * @param handle i64
 * @return i32
 */
export function arrow_column_type_c(handle: i64): i32 {
  let c: *ArrowColumnMem = handle as *ArrowColumnMem;
  if (c == 0) {
    return 0;
  }
  return c.type_id;
}

/** Exported function `arrow_column_len_c`.
 * Implements `arrow_column_len_c`.
 * @param handle i64
 * @return i32
 */
export function arrow_column_len_c(handle: i64): i32 {
  let c: *ArrowColumnMem = handle as *ArrowColumnMem;
  if (c == 0) {
    return 0;
  }
  return c.length;
}

/** Exported function `arrow_column_capacity_c`.
 * Implements `arrow_column_capacity_c`.
 * @param handle i64
 * @return i32
 */
export function arrow_column_capacity_c(handle: i64): i32 {
  let c: *ArrowColumnMem = handle as *ArrowColumnMem;
  if (c == 0) {
    return 0;
  }
  return c.capacity;
}

/** Exported function `arrow_column_data_owned_c`.
 * Implements `arrow_column_data_owned_c`.
 * @param handle i64
 * @return i32
 */
export function arrow_column_data_owned_c(handle: i64): i32 {
  let c: *ArrowColumnMem = handle as *ArrowColumnMem;
  if (c == 0) {
    return 0;
  }
  return c.data_owned;
}

/** Exported function `arrow_column_null_bitmap_c`.
 * Implements `arrow_column_null_bitmap_c`.
 * @param handle i64
 * @return *u8
 */
export function arrow_column_null_bitmap_c(handle: i64): *u8 {
  let c: *ArrowColumnMem = handle as *ArrowColumnMem;
  if (c == 0) {
    return 0 as *u8;
  }
  return c.null_bitmap;
}

/** Exported function `arrow_column_is_valid_c`.
 * Implements `arrow_column_is_valid_c`.
 * @param handle i64
 * @param index i32
 * @return i32
 */
export function arrow_column_is_valid_c(handle: i64, index: i32): i32 {
  let c: *ArrowColumnMem = handle as *ArrowColumnMem;
  let byte_i: usize = 0;
  if (c == 0 || c.null_bitmap == 0) {
    return 0;
  }
  if (index < 0 || index >= c.length) {
    return 0;
  }
  byte_i = (index as usize) / 8;
  return ((c.null_bitmap[byte_i] >> (index % 8)) & 1) as i32;
}

/** Exported function `arrow_column_i32_data_c`.
 * Implements `arrow_column_i32_data_c`.
 * @param handle i64
 * @return *i32
 */
export function arrow_column_i32_data_c(handle: i64): *i32 {
  let c: *ArrowColumnMem = handle as *ArrowColumnMem;
  if (c == 0 || c.type_id != ARROW_TYPE_I32) {
    return 0 as *i32;
  }
  return c.data as *i32;
}

/** Exported function `arrow_column_f32_data_c`.
 * Implements `arrow_column_f32_data_c`.
 * @param handle i64
 * @return *f32
 */
export function arrow_column_f32_data_c(handle: i64): *f32 {
  let c: *ArrowColumnMem = handle as *ArrowColumnMem;
  if (c == 0 || c.type_id != ARROW_TYPE_F32) {
    return 0 as *f32;
  }
  return c.data as *f32;
}

/** Exported function `arrow_column_f64_data_c`.
 * Implements `arrow_column_f64_data_c`.
 * @param handle i64
 * @return *f64
 */
export function arrow_column_f64_data_c(handle: i64): *f64 {
  let c: *ArrowColumnMem = handle as *ArrowColumnMem;
  if (c == 0 || c.type_id != ARROW_TYPE_F64) {
    return 0 as *f64;
  }
  return c.data as *f64;
}

/** Exported function `arrow_column_i32_append_c`.
 * Implements `arrow_column_i32_append_c`.
 * @param handle i64
 * @param val i32
 * @return i32
 */
export function arrow_column_i32_append_c(handle: i64, val: i32): i32 {
  let c: *ArrowColumnMem = handle as *ArrowColumnMem;
  let d: *i32 = 0 as *i32;
  if (c == 0 || c.type_id != ARROW_TYPE_I32 || c.length >= c.capacity) {
    return -1;
  }
  d = c.data as *i32;
  d[c.length] = val;
  arrow_null_bitmap_set(c, c.length, 1);
  c.length = c.length + 1;
  return 0;
}

/** Exported function `arrow_column_i32_append_null_c`.
 * Implements `arrow_column_i32_append_null_c`.
 * @param handle i64
 * @param val i32
 * @param is_valid i32
 * @return i32
 */
export function arrow_column_i32_append_null_c(handle: i64, val: i32, is_valid: i32): i32 {
  let c: *ArrowColumnMem = handle as *ArrowColumnMem;
  let d: *i32 = 0 as *i32;
  if (c == 0 || c.type_id != ARROW_TYPE_I32 || c.length >= c.capacity) {
    return -1;
  }
  d = c.data as *i32;
  d[c.length] = val;
  arrow_null_bitmap_set(c, c.length, is_valid);
  c.length = c.length + 1;
  return 0;
}

/** Exported function `arrow_column_f32_append_c`.
 * Implements `arrow_column_f32_append_c`.
 * @param handle i64
 * @param val f32
 * @return i32
 */
export function arrow_column_f32_append_c(handle: i64, val: f32): i32 {
  let c: *ArrowColumnMem = handle as *ArrowColumnMem;
  let d: *f32 = 0 as *f32;
  if (c == 0 || c.type_id != ARROW_TYPE_F32 || c.length >= c.capacity) {
    return -1;
  }
  d = c.data as *f32;
  d[c.length] = val;
  arrow_null_bitmap_set(c, c.length, 1);
  c.length = c.length + 1;
  return 0;
}

/** Exported function `arrow_column_f64_append_c`.
 * Implements `arrow_column_f64_append_c`.
 * @param handle i64
 * @param val f64
 * @return i32
 */
export function arrow_column_f64_append_c(handle: i64, val: f64): i32 {
  let c: *ArrowColumnMem = handle as *ArrowColumnMem;
  let d: *f64 = 0 as *f64;
  if (c == 0 || c.type_id != ARROW_TYPE_F64 || c.length >= c.capacity) {
    return -1;
  }
  d = c.data as *f64;
  d[c.length] = val;
  arrow_null_bitmap_set(c, c.length, 1);
  c.length = c.length + 1;
  return 0;
}

/** Exported function `arrow_column_destroy_c`.
 * Implements `arrow_column_destroy_c`.
 * @param handle i64
 * @return void
 */
export function arrow_column_destroy_c(handle: i64): void {
  let c: *ArrowColumnMem = handle as *ArrowColumnMem;
  if (c == 0) {
    return;
  }
  if (c.data != 0 && c.data_owned != 0) {
    unsafe { free(c.data); }
  }
  if (c.null_bitmap != 0) {
    unsafe { free(c.null_bitmap); }
  }
  unsafe { free(c as *u8); }
}

/** Exported function `arrow_batch_create_c`.
 * Implements `arrow_batch_create_c`.
 * @param max_cols i32
 * @return i64
 */
export function arrow_batch_create_c(max_cols: i32): i64 {
  let b: *ArrowBatchMem = 0 as *ArrowBatchMem;
  if (max_cols <= 0) {
    return 0 as i64;
  }
  unsafe { b = calloc(1, 24) as *ArrowBatchMem; }
  if (b == 0) {
    return 0 as i64;
  }
  b.cap_cols = max_cols;
  unsafe { b.cols = calloc(max_cols as usize, 8) as *u64; }
  if (b.cols == 0) {
    unsafe { free(b as *u8); }
    return 0 as i64;
  }
  return b as i64;
}

/** Exported function `arrow_batch_add_column_c`.
 * Implements `arrow_batch_add_column_c`.
 * @param batch i64
 * @param col i64
 * @return i32
 */
export function arrow_batch_add_column_c(batch: i64, col: i64): i32 {
  let b: *ArrowBatchMem = batch as *ArrowBatchMem;
  if (b == 0 || col == 0 || b.n_cols >= b.cap_cols) {
    return -1;
  }
  b.cols[b.n_cols] = col as u64;
  b.n_cols = b.n_cols + 1;
  return 0;
}

/** Exported function `arrow_batch_column_c`.
 * Implements `arrow_batch_column_c`.
 * @param batch i64
 * @param index i32
 * @return i64
 */
export function arrow_batch_column_c(batch: i64, index: i32): i64 {
  let b: *ArrowBatchMem = batch as *ArrowBatchMem;
  if (b == 0 || index < 0 || index >= b.n_cols) {
    return 0 as i64;
  }
  return b.cols[index] as i64;
}

/** Exported function `arrow_batch_len_c`.
 * Implements `arrow_batch_len_c`.
 * @param batch i64
 * @return i32
 */
export function arrow_batch_len_c(batch: i64): i32 {
  let b: *ArrowBatchMem = batch as *ArrowBatchMem;
  if (b == 0) {
    return 0;
  }
  return b.n_cols;
}

/** Exported function `arrow_batch_destroy_c`.
 * Implements `arrow_batch_destroy_c`.
 * @param batch i64
 * @return void
 */
export function arrow_batch_destroy_c(batch: i64): void {
  let b: *ArrowBatchMem = batch as *ArrowBatchMem;
  let i: i32 = 0;
  if (b == 0) {
    return;
  }
  i = 0;
  while (i < b.n_cols) {
    arrow_column_destroy_c(b.cols[i] as i64);
    i = i + 1;
  }
  if (b.cols != 0) {
    unsafe { free(b.cols as *u8); }
  }
  unsafe { free(b as *u8); }
}

/**
 * See implementation.
 */
export function arrow_simd_smoke_inner(): i32 {
  let ci: i64 = 0;
  let cf: i64 = 0;
  let cf2: i64 = 0;
  let sum_i: i32 = 0;
  let sum_f: f32 = 0.0;
  let dot: f32 = 0.0;
  let sv: f32 = 0.0;
  ci = arrow_column_i32_create_c(16);
  cf = arrow_column_f32_create_c(16);
  cf2 = arrow_column_f32_create_c(16);
  if (ci == 0 || cf == 0 || cf2 == 0) {
    return -1;
  }
  if (arrow_column_i32_append_null_c(ci, 10, 1) != 0 || arrow_column_i32_append_null_c(ci, 0, 0) != 0
      || arrow_column_i32_append_null_c(ci, 20, 1) != 0) {
    return -2;
  }
  if (arrow_column_f32_append_c(cf, 1.0) != 0 || arrow_column_f32_append_c(cf, 2.0) != 0
      || arrow_column_f32_append_c(cf, 3.0) != 0 || arrow_column_f32_append_c(cf, 4.0) != 0) {
    return -3;
  }
  if (arrow_column_f32_append_c(cf2, 0.5) != 0 || arrow_column_f32_append_c(cf2, 0.5) != 0
      || arrow_column_f32_append_c(cf2, 0.5) != 0 || arrow_column_f32_append_c(cf2, 0.5) != 0) {
    return -4;
  }
  unsafe { sum_i = arrow_column_i32_sum_valid_c(ci, 3); }
  unsafe { sum_f = arrow_column_f32_sum_c(cf, 4); }
  unsafe { dot = arrow_column_f32_dot_c(cf, cf2, 4); }
  unsafe { sv = arrow_column_f32_sum_valid_c(cf, 4); }
  arrow_column_destroy_c(ci);
  arrow_column_destroy_c(cf);
  arrow_column_destroy_c(cf2);
  if (sv < 9.99 || sv > 10.01) {
    return -8;
  }
  if (sum_i != 30) {
    return -5;
  }
  if (sum_f < 9.99 || sum_f > 10.01) {
    return -6;
  }
  if (dot < 4.99 || dot > 5.01) {
    return -7;
  }
  return 0;
}

/**
 * See implementation.
 */
export function arrow_smoke_c(): i32 {
  let ci: i64 = 0;
  let cf: i64 = 0;
  let cf64: i64 = 0;
  let batch: i64 = 0;
  let adopted: i64 = 0;
  let pi: *i32 = 0 as *i32;
  let pf: *f32 = 0 as *f32;
  let nic_buf: f32[4] = [1.0, 2.0, 3.0, 4.0];
  if (arrow_simd_smoke_inner() != 0) {
    return -10;
  }
  ci = arrow_column_i32_create_c(1024);
  cf = arrow_column_f32_create_c(1024);
  cf64 = arrow_column_f64_create_c(1024);
  if (ci == 0 || cf == 0 || cf64 == 0) {
    return -1;
  }
  if (arrow_column_i32_append_null_c(ci, 42, 1) != 0 || arrow_column_f32_append_c(cf, 3.14) != 0
      || arrow_column_f64_append_c(cf64, 2.718) != 0) {
    return -2;
  }
  if (arrow_column_is_valid_c(ci, 0) != 1) {
    return -3;
  }
  pi = arrow_column_i32_data_c(ci);
  pf = arrow_column_f32_data_c(cf);
  if (pi == 0 || pf == 0 || pi[0] != 42) {
    return -4;
  }
  adopted = arrow_column_adopt_f32_c(&nic_buf[0], 4, 4);
  if (adopted == 0 || arrow_column_data_owned_c(adopted) != 0) {
    return -5;
  }
  if (arrow_column_f32_data_c(adopted)[2] != 3.0) {
    return -6;
  }
  batch = arrow_batch_create_c(8);
  if (batch == 0) {
    arrow_column_destroy_c(adopted);
    return -7;
  }
  if (arrow_batch_add_column_c(batch, ci) != 0 || arrow_batch_add_column_c(batch, cf) != 0
      || arrow_batch_add_column_c(batch, adopted) != 0) {
    arrow_batch_destroy_c(batch);
    return -8;
  }
  if (arrow_batch_len_c(batch) != 3) {
    arrow_batch_destroy_c(batch);
    return -9;
  }
  arrow_batch_destroy_c(batch);
  arrow_column_destroy_c(cf64);
  return 0;
}
