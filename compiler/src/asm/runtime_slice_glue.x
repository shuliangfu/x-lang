// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-22：runtime_slice_glue 产品源迁 seeds/runtime_slice_glue.from_x.c。
// G-02f-rest：rest→.x 迁移：6 个 slice 构造/子切片函数真迁 .x（struct 按值返回）。
// 验证 .x struct 按值返回能力（16 字节 slice：data + length）。

/** i32 切片（与 C struct shux_slice_int32_t ABI 兼容，16 字节）。 */
struct ShuxSliceI32 {
  data: *i32;
  length: usize;
}

/** u8 切片（与 C struct shux_slice_uint8_t ABI 兼容，16 字节）。 */
struct ShuxSliceU8 {
  data: *u8;
  length: usize;
}

/** u64 切片（与 C struct shux_slice_uint64_t ABI 兼容，16 字节）。 */
struct ShuxSliceU64 {
  data: *u64;
  length: usize;
}

function runtime_slice_glue_x_doc_anchor(): i32 {
  return 0;
}

// ---- G-02f-rest：slice 构造/子切片（rest→.x 迁移） ----

/** from_ptr：直接包装 (ptr,len) 为切片，不做边界检查。 */
#[no_mangle]
function core_slice_i32_from_ptr_c(data: *i32, length: usize): ShuxSliceI32 {
  let s: ShuxSliceI32 = ShuxSliceI32 { data: data, length: length };
  return s;
}

#[no_mangle]
function core_slice_u8_from_ptr_c(data: *u8, length: usize): ShuxSliceU8 {
  let s: ShuxSliceU8 = ShuxSliceU8 { data: data, length: length };
  return s;
}

#[no_mangle]
function core_slice_u64_from_ptr_c(data: *u64, length: usize): ShuxSliceU64 {
  let s: ShuxSliceU64 = ShuxSliceU64 { data: data, length: length };
  return s;
}

/** subslice：从 start 起取 len 个元素；越界钳制（start>=total → 空，尾部不足截断）。 */
#[no_mangle]
function core_subslice_i32_c(data: *i32, total_len: usize, start: usize, len: usize): ShuxSliceI32 {
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

#[no_mangle]
function core_subslice_u8_c(data: *u8, total_len: usize, start: usize, len: usize): ShuxSliceU8 {
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

#[no_mangle]
function core_subslice_u64_c(data: *u64, total_len: usize, start: usize, len: usize): ShuxSliceU64 {
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
