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

// std.db.arrow — Apache Arrow 风格零拷贝列式内存 v1
//
// 【文件职责】
// 64B 对齐连续列（I32/F32/F64）+ null bitmap；adopt_* 零拷贝接管网卡 buffer。
// 配合 std.simd 向量化；无反序列化。
//
// 64B 对齐列 + null bitmap；adopt 零拷贝接管网卡 buffer。
// 实现见 arrow.x + arrow_simd_glue.c（F-05 v1）。

const simd = import("std.simd");

/** 列类型：Int32。 */
export const ARROW_I32: i32 = 1;
/** 列类型：Float32。 */
export const ARROW_F32: i32 = 2;
/** 列类型：Float64。 */
export const ARROW_F64: i32 = 3;

/** 列对齐字节数（与 arrow.x ARROW_ALIGN 一致）。 */
export const ARROW_ALIGN_BYTES: i32 = 64;

/** 不透明列句柄。 */
export struct ArrowColumn {
  handle: i64;
}

/** RecordBatch：多列零拷贝视图。 */
export struct ArrowBatch {
  handle: i64;
}

extern function arrow_column_i32_create_c(capacity: i32): i64;
extern function arrow_column_f32_create_c(capacity: i32): i64;
extern function arrow_column_f64_create_c(capacity: i32): i64;
extern function arrow_column_adopt_f32_c(ptr: *f32, len: i32, capacity: i32): i64;
extern function arrow_column_adopt_i32_c(ptr: *i32, len: i32, capacity: i32): i64;
extern function arrow_column_type_c(handle: i64): i32;
extern function arrow_column_len_c(handle: i64): i32;
extern function arrow_column_capacity_c(handle: i64): i32;
extern function arrow_column_data_owned_c(handle: i64): i32;
extern function arrow_column_null_bitmap_c(handle: i64): *u8;
extern function arrow_column_is_valid_c(handle: i64, index: i32): i32;
extern function arrow_column_i32_data_c(handle: i64): *i32;
extern function arrow_column_f32_data_c(handle: i64): *f32;
extern function arrow_column_f64_data_c(handle: i64): *f64;
extern function arrow_column_i32_append_c(handle: i64, val: i32): i32;
extern function arrow_column_i32_append_null_c(handle: i64, val: i32, is_valid: i32): i32;
extern function arrow_column_f32_append_c(handle: i64, val: f32): i32;
extern function arrow_column_f64_append_c(handle: i64, val: f64): i32;
extern function arrow_column_destroy_c(handle: i64): void;
extern function arrow_batch_create_c(max_cols: i32): i64;
extern function arrow_batch_add_column_c(batch: i64, col: i64): i32;
extern function arrow_batch_column_c(batch: i64, index: i32): i64;
extern function arrow_batch_len_c(batch: i64): i32;
extern function arrow_batch_destroy_c(batch: i64): void;
extern function arrow_column_i32_sum_valid_c(handle: i64, n: i32): i32;
extern function arrow_column_f32_sum_c(handle: i64, n: i32): f32;
extern function arrow_column_f32_sum_valid_c(handle: i64, n: i32): f32;
extern function arrow_column_f32_dot_c(handle_a: i64, handle_b: i64, n: i32): f32;
extern function arrow_smoke_c(): i32;

/** 创建 Int32 列。 */
export function new_i32(capacity: i32): ArrowColumn {
  let _rc: ArrowColumn = 0;
  unsafe { _rc = ArrowColumn { handle: arrow_column_i32_create_c(capacity) }; }
  return _rc;
}

/** 创建 Float32 列。 */
export function new_f32(capacity: i32): ArrowColumn {
  let _rc: ArrowColumn = 0;
  unsafe { _rc = ArrowColumn { handle: arrow_column_f32_create_c(capacity) }; }
  return _rc;
}

/** 创建 Float64 列。 */
export function new_f64(capacity: i32): ArrowColumn {
  let _rc: ArrowColumn = 0;
  unsafe { _rc = ArrowColumn { handle: arrow_column_f64_create_c(capacity) }; }
  return _rc;
}

/**
 * 零拷贝：接管外部 F32  buffer（网卡 DMA 等）；destroy 不释放 ptr。
 * len 为当前有效元素数，capacity 为 buffer 容量。
 */
export function adopt(ptr: *f32, len: i32, capacity: i32): ArrowColumn {
  let _rc: ArrowColumn = 0;
  unsafe { _rc = ArrowColumn { handle: arrow_column_adopt_f32_c(ptr, len, capacity) }; }
  return _rc;
}

/** 零拷贝：接管外部 I32 buffer。 */
export function adopt(ptr: *i32, len: i32, capacity: i32): ArrowColumn {
  let _rc: ArrowColumn = 0;
  unsafe { _rc = ArrowColumn { handle: arrow_column_adopt_i32_c(ptr, len, capacity) }; }
  return _rc;
}

/** 列当前元素个数。 */
export function len(col: ArrowColumn): i32 {
  unsafe { return arrow_column_len_c(col.handle); }
  return 0; // unreachable — typeck workaround
}

/** data 是否由 arrow 模块拥有（adopt 列为 0）。 */
export function owned(col: ArrowColumn): i32 {
  unsafe { return arrow_column_data_owned_c(col.handle); }
  return 0; // unreachable — typeck workaround
}

/** null bitmap 指针（bit=1 表示有效值）。 */
export function null_bitmap(col: ArrowColumn): *u8 {
  unsafe { return arrow_column_null_bitmap_c(col.handle); }
  return 0; // unreachable — typeck workaround
}

/** 索引处元素是否有效（非 null）。 */
export function valid(col: ArrowColumn, index: i32): i32 {
  unsafe { return arrow_column_is_valid_c(col.handle, index); }
  return 0; // unreachable — typeck workaround
}

/** 零拷贝 Int32 data 指针。 */
export function data_i32(col: ArrowColumn): *i32 {
  unsafe { return arrow_column_i32_data_c(col.handle); }
  return 0; // unreachable — typeck workaround
}

/** 零拷贝 Float32 data 指针。 */
export function data_f32(col: ArrowColumn): *f32 {
  unsafe { return arrow_column_f32_data_c(col.handle); }
  return 0; // unreachable — typeck workaround
}

/** 零拷贝 Float64 data 指针。 */
export function data_f64(col: ArrowColumn): *f64 {
  unsafe { return arrow_column_f64_data_c(col.handle); }
  return 0; // unreachable — typeck workaround
}

/** 追加 Int32（非 null）。 */
export function append(col: ArrowColumn, val: i32): i32 {
  unsafe { return arrow_column_i32_append_c(col.handle, val); }
  return 0; // unreachable — typeck workaround
}

/** 追加 Int32 并可标记 null（is_valid=0 表示 null）。 */
export function append_null(col: ArrowColumn, val: i32, is_valid: i32): i32 {
  unsafe { return arrow_column_i32_append_null_c(col.handle, val, is_valid); }
  return 0; // unreachable — typeck workaround
}

/** 追加 Float32。 */
export function append(col: ArrowColumn, val: f32): i32 {
  unsafe { return arrow_column_f32_append_c(col.handle, val); }
  return 0; // unreachable — typeck workaround
}

/** 追加 Float64。 */
export function append(col: ArrowColumn, val: f64): i32 {
  unsafe { return arrow_column_f64_append_c(col.handle, val); }
  return 0; // unreachable — typeck workaround
}

/** 释放列（adopt 列不 free 外部 data）。 */
export function free(col: ArrowColumn): void {
  unsafe { arrow_column_destroy_c(col.handle); }
}

/** 创建 RecordBatch。 */
export function batch(max_cols: i32): ArrowBatch {
  let _rc: ArrowBatch = 0;
  unsafe { _rc = ArrowBatch { handle: arrow_batch_create_c(max_cols) }; }
  return _rc;
}

/** 向 batch 添加列（batch 取得所有权）。 */
export function add(batch: ArrowBatch, col: ArrowColumn): i32 {
  unsafe { return arrow_batch_add_column_c(batch.handle, col.handle); }
  return 0; // unreachable — typeck workaround
}

/** 按索引取列。 */
export function get(batch: ArrowBatch, index: i32): ArrowColumn {
  let _rc: ArrowColumn = 0;
  unsafe { _rc = ArrowColumn { handle: arrow_batch_column_c(batch.handle, index) }; }
  return _rc;
}

/** batch 列数。 */
export function len(batch: ArrowBatch): i32 {
  unsafe { return arrow_batch_len_c(batch.handle); }
  return 0; // unreachable — typeck workaround
}

/** 销毁 batch 及所含列。 */
export function free(batch: ArrowBatch): void {
  unsafe { arrow_batch_destroy_c(batch.handle); }
}

/**
 * Int32 列前 n 个有效元素累加（跳过 null）；C SIMD 内核。
 */
export function sum_valid_i32(col: ArrowColumn, n: i32): i32 {
  unsafe { return arrow_column_i32_sum_valid_c(col.handle, n); }
  return 0; // unreachable — typeck workaround
}

/** Float32 列前 n 元素求和（SIMD 内核）。 */
export function sum(col: ArrowColumn, n: i32): f32 {
  unsafe { return arrow_column_f32_sum_c(col.handle, n); }
  return 0; // unreachable — typeck workaround
}

/** Float32 列前 n 个有效元素求和（null-aware SIMD 内核）。 */
export function sum_valid_f32(col: ArrowColumn, n: i32): f32 {
  unsafe { return arrow_column_f32_sum_valid_c(col.handle, n); }
  return 0; // unreachable — typeck workaround
}

/** 两列 Float32 点积 sum(a[i]*b[i])（SIMD 内核）。 */
export function dot(a: ArrowColumn, b: ArrowColumn, n: i32): f32 {
  unsafe { return arrow_column_f32_dot_c(a.handle, b.handle, n); }
  return 0; // unreachable — typeck workaround
}

/** SIMD 硬件是否可用。 */
export function simd_hw_available(): i32 {
  return simd.hw_available();
}
