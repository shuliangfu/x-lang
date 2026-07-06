// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// std.db.arrow — F-05 v1：Apache Arrow 风格列式内存（列/batch 生命周期）
//
// 【文件职责】
// 从 arrow.c 迁出列创建/adopt/append/batch/烟测；SIMD 归约见 arrow_simd_glue.c。
//
// 【布局】64B 对齐 data + null bitmap（bit=1 有效）

const ARROW_ALIGN: usize = 64;
const ARROW_TYPE_I32: i32 = 1;
const ARROW_TYPE_F32: i32 = 2;
const ARROW_TYPE_F64: i32 = 3;

/** 堆上列对象（与 arrow_simd_glue.c arrow_column_t ABI 一致）。 */
allow(padding) struct ArrowColumnMem {
  type_id: i32;
  length: i32;
  capacity: i32;
  data: *u8;
  null_bitmap: *u8;
  data_owned: i32;
}

/** RecordBatch 堆对象。 */
allow(padding) struct ArrowBatchMem {
  n_cols: i32;
  cap_cols: i32;
  cols: *u64;
}

extern function calloc(nmemb: usize, size: usize): *u8;
extern function free(ptr: *u8): void;
extern function memset(s: *u8, c: i32, n: usize): *u8;
extern function posix_memalign(memptr: * *void, alignment: usize, size: usize): i32;

extern function arrow_column_i32_sum_valid_c(handle: i64, n: i32): i32;
extern function arrow_column_f32_sum_c(handle: i64, n: i32): f32;
extern function arrow_column_f32_sum_valid_c(handle: i64, n: i32): f32;
extern function arrow_column_f32_dot_c(handle_a: i64, handle_b: i64, n: i32): f32;

/**
 * 64B 对齐分配；失败返回 null。
 */
function arrow_alloc_aligned(size: usize): *u8 {
  let out: *u8 = 0 as *u8;
  unsafe { if (posix_memalign(&out, ARROW_ALIGN, size) != 0) {
    return 0;
  } }
  return out;
}

/**
 * 分配 null bitmap 并置全有效（0xFF）。
 */
function arrow_null_bitmap_alloc(capacity: i32): *u8 {
  let n: usize = 0;
  let bm: *u8 = 0 as *u8;
  if (capacity <= 0) {
    return 0;
  }
  n = ((capacity as usize + 7) / 8);
  unsafe { bm = calloc(n, 1); }
  if (bm == 0) {
    return 0;
  }
  unsafe { memset(bm, 0xff, n); }
  return bm;
}

/**
 * 设置 null bitmap 某位。
 */
function arrow_null_bitmap_set(col: *ArrowColumnMem, index: i32, is_valid: i32): void {
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
 * 按类型创建列；elem_size 为单元素字节数。
 */
function arrow_column_create_typed(type_id: i32, capacity: i32, elem_size: usize): *ArrowColumnMem {
  let c: *ArrowColumnMem = 0 as *ArrowColumnMem;
  if (capacity <= 0) {
    return 0;
  }
  unsafe { c = calloc(1, 32) as *ArrowColumnMem; }
  if (c == 0) {
    return 0;
  }
  c.type_id = type_id;
  c.capacity = capacity;
  c.data_owned = 1;
  c.null_bitmap = arrow_null_bitmap_alloc(capacity);
  if (c.null_bitmap == 0) {
    unsafe { free(c as *u8); }
    return 0;
  }
  c.data = arrow_alloc_aligned((capacity as usize) * elem_size);
  if (c.data == 0) {
    unsafe { free(c.null_bitmap); }
    unsafe { free(c as *u8); }
    return 0;
  }
  return c;
}

/** 创建 Int32 列句柄。 */
function arrow_column_i32_create_c(capacity: i32): i64 {
  let c: *ArrowColumnMem = arrow_column_create_typed(ARROW_TYPE_I32, capacity, 4);
  if (c == 0) {
    return 0 as i64;
  }
  return c as i64;
}

/** 创建 Float32 列句柄。 */
function arrow_column_f32_create_c(capacity: i32): i64 {
  let c: *ArrowColumnMem = arrow_column_create_typed(ARROW_TYPE_F32, capacity, 4);
  if (c == 0) {
    return 0 as i64;
  }
  return c as i64;
}

/** 创建 Float64 列句柄。 */
function arrow_column_f64_create_c(capacity: i32): i64 {
  let c: *ArrowColumnMem = arrow_column_create_typed(ARROW_TYPE_F64, capacity, 8);
  if (c == 0) {
    return 0 as i64;
  }
  return c as i64;
}

/** 零拷贝接管外部 F32 buffer。 */
function arrow_column_adopt_f32_c(ptr: *f32, len: i32, capacity: i32): i64 {
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

/** 零拷贝接管外部 I32 buffer。 */
function arrow_column_adopt_i32_c(ptr: *i32, len: i32, capacity: i32): i64 {
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

/** 列类型 id。 */
function arrow_column_type_c(handle: i64): i32 {
  let c: *ArrowColumnMem = handle as *ArrowColumnMem;
  if (c == 0) {
    return 0;
  }
  return c.type_id;
}

/** 列长度。 */
function arrow_column_len_c(handle: i64): i32 {
  let c: *ArrowColumnMem = handle as *ArrowColumnMem;
  if (c == 0) {
    return 0;
  }
  return c.length;
}

/** 列容量。 */
function arrow_column_capacity_c(handle: i64): i32 {
  let c: *ArrowColumnMem = handle as *ArrowColumnMem;
  if (c == 0) {
    return 0;
  }
  return c.capacity;
}

/** data 是否模块拥有。 */
function arrow_column_data_owned_c(handle: i64): i32 {
  let c: *ArrowColumnMem = handle as *ArrowColumnMem;
  if (c == 0) {
    return 0;
  }
  return c.data_owned;
}

/** null bitmap 指针。 */
function arrow_column_null_bitmap_c(handle: i64): *u8 {
  let c: *ArrowColumnMem = handle as *ArrowColumnMem;
  if (c == 0) {
    return 0;
  }
  return c.null_bitmap;
}

/** 索引处是否有效。 */
function arrow_column_is_valid_c(handle: i64, index: i32): i32 {
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

/** I32 data 指针。 */
function arrow_column_i32_data_c(handle: i64): *i32 {
  let c: *ArrowColumnMem = handle as *ArrowColumnMem;
  if (c == 0 || c.type_id != ARROW_TYPE_I32) {
    return 0;
  }
  return c.data as *i32;
}

/** F32 data 指针。 */
function arrow_column_f32_data_c(handle: i64): *f32 {
  let c: *ArrowColumnMem = handle as *ArrowColumnMem;
  if (c == 0 || c.type_id != ARROW_TYPE_F32) {
    return 0;
  }
  return c.data as *f32;
}

/** F64 data 指针。 */
function arrow_column_f64_data_c(handle: i64): *f64 {
  let c: *ArrowColumnMem = handle as *ArrowColumnMem;
  if (c == 0 || c.type_id != ARROW_TYPE_F64) {
    return 0;
  }
  return c.data as *f64;
}

/** 追加 Int32。 */
function arrow_column_i32_append_c(handle: i64, val: i32): i32 {
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

/** 追加 Int32 可 null。 */
function arrow_column_i32_append_null_c(handle: i64, val: i32, is_valid: i32): i32 {
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

/** 追加 Float32。 */
function arrow_column_f32_append_c(handle: i64, val: f32): i32 {
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

/** 追加 Float64。 */
function arrow_column_f64_append_c(handle: i64, val: f64): i32 {
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

/** 销毁列。 */
function arrow_column_destroy_c(handle: i64): void {
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

/** 创建 batch。 */
function arrow_batch_create_c(max_cols: i32): i64 {
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

/** batch 添加列（取得所有权）。 */
function arrow_batch_add_column_c(batch: i64, col: i64): i32 {
  let b: *ArrowBatchMem = batch as *ArrowBatchMem;
  if (b == 0 || col == 0 || b.n_cols >= b.cap_cols) {
    return -1;
  }
  b.cols[b.n_cols] = col as u64;
  b.n_cols = b.n_cols + 1;
  return 0;
}

/** 取 batch 内列句柄。 */
function arrow_batch_column_c(batch: i64, index: i32): i64 {
  let b: *ArrowBatchMem = batch as *ArrowBatchMem;
  if (b == 0 || index < 0 || index >= b.n_cols) {
    return 0 as i64;
  }
  return b.cols[index] as i64;
}

/** batch 列数。 */
function arrow_batch_len_c(batch: i64): i32 {
  let b: *ArrowBatchMem = batch as *ArrowBatchMem;
  if (b == 0) {
    return 0;
  }
  return b.n_cols;
}

/** 销毁 batch 及所含列。 */
function arrow_batch_destroy_c(batch: i64): void {
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
 * SIMD 子烟测（委托胶层归约 API）。
 */
function arrow_simd_smoke_inner(): i32 {
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
 * 烟测：列/batch/adopt + SIMD 归约。
 */
function arrow_smoke_c(): i32 {
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
