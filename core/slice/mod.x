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

// core.slice — 切片类型与边界安全访问（自举前实现）
// []T 支持 .length / .data 字段；提供 subslice / split_at / chunks 零拷贝视图（CORE-004/157）。
// subslice 构造经 core/slice/slice.c 薄封装（语言暂无 slice 复合字面量）。

const option = import("core.option");

extern function core_slice_i32_from_ptr_c(data: *i32, length: usize): []i32;
extern function core_subslice_i32_c(data: *i32, total_len: usize, start: usize, len: usize): []i32;
extern function core_slice_u8_from_ptr_c(data: *u8, length: usize): []u8;
extern function core_subslice_u8_c(data: *u8, total_len: usize, start: usize, len: usize): []u8;
extern function core_slice_u64_from_ptr_c(data: *u64, length: usize): []u64;
extern function core_subslice_u64_c(data: *u64, total_len: usize, start: usize, len: usize): []u64;

/** split_at 返回的左右子切片对（[]i32）。 */
export struct Split_i32 {
  left: []i32;
  right: []i32;
}

/** split_at 返回的左右子切片对（[]u8）。 */
export struct Split_u8 {
  left: []u8;
  right: []u8;
}

/** split_at 返回的左右子切片对（[]u64，CORE-157）。 */
export struct Split_u64 {
  left: []u64;
  right: []u64;
}

// ——— []i32 ———
/** 返回 []i32 切片的长度（元素个数）。 */
export function len_i32(s: []i32): usize { return s.length; }

/** 边界内返回 some(s.data[i])，越界返回 option.none_i32()。 */
export function get_i32(s: []i32, i: usize): Option_i32 {
  if (i >= s.length) {
    return option.none_i32();
  }
  return option.some_i32(s.data[i]);
}

/** 直接返回 s.data[i]；调用方须保证 i < s.length。 */
export function get_i32_unchecked(s: []i32, i: usize): i32 { return s.data[i]; }

/** 是否为空切片。 */
export function is_empty_i32(s: []i32): i32 {
  if (s.length == 0 as usize) { return 1; }
  return 0;
}

/** 取首元素；空切片返回 none。 */
export function first_i32(s: []i32): Option_i32 {
  return get_i32(s, 0 as usize);
}

/** 取尾元素；空切片返回 none。 */
export function last_i32(s: []i32): Option_i32 {
  if (s.length == 0 as usize) { return option.none_i32(); }
  return get_i32(s, s.length - 1 as usize);
}

/** 零拷贝子切片：从 start 起取 len 个元素；(offset, count) 语义。 */
export function subslice_i32(s: []i32, start: usize, len: usize): []i32 {
  let r: []i32;
  unsafe { r = core_subslice_i32_c(s.data, s.length, start, len); }
  return r;
}

/** 在 at 处拆分为左右两段；at 超出 length 时 left 为整段、right 为空。 */
export function split_at_i32(s: []i32, at: usize): Split_i32 {
  let at_clamped: usize = at;
  if (at_clamped > s.length) { at_clamped = s.length; }
  return Split_i32 {
    left: subslice_i32(s, 0 as usize, at_clamped),
    right: subslice_i32(s, at_clamped, s.length - at_clamped),
  };
}

/** 固定 chunk_size 时的 chunk 个数；chunk_size==0 返回 0。 */
export function chunks_len_i32(s: []i32, chunk_size: usize): usize {
  if (chunk_size == 0 as usize) { return 0 as usize; }
  if (s.length == 0 as usize) { return 0 as usize; }
  return (s.length + chunk_size - 1 as usize) / chunk_size;
}

/** 取第 index 个 chunk（每块 chunk_size 元素）；越界 index 返回空切片。 */
export function chunk_i32(s: []i32, chunk_size: usize, index: usize): []i32 {
  if (chunk_size == 0 as usize) {
    let empty0: []i32;
    unsafe { empty0 = core_slice_i32_from_ptr_c(s.data, 0 as usize); }
    return empty0;
  }
  let off: usize = index * chunk_size;
  if (off >= s.length) {
    let empty1: []i32;
    unsafe { empty1 = core_slice_i32_from_ptr_c(s.data, 0 as usize); }
    return empty1;
  }
  let n: usize = chunk_size;
  if (off + n > s.length) { n = s.length - off; }
  return subslice_i32(s, off, n);
}

// ——— []u8 ———
/** 返回 []u8 切片的长度。 */
export function len_u8(s: []u8): usize { return s.length; }

/** 边界内返回 some(s.data[i])，越界返回 option.none_u8()。 */
export function get_u8(s: []u8, i: usize): Option_u8 {
  if (i >= s.length) {
    return option.none_u8();
  }
  return option.some_u8(s.data[i]);
}

/** 直接返回 s.data[i]；调用方须保证 i < s.length。 */
export function get_u8_unchecked(s: []u8, i: usize): u8 { return s.data[i]; }

/** 是否为空切片。 */
export function is_empty_u8(s: []u8): i32 {
  if (s.length == 0 as usize) { return 1; }
  return 0;
}

/** 取首元素。 */
export function first_u8(s: []u8): Option_u8 {
  return get_u8(s, 0 as usize);
}

/** 零拷贝 subslice（[]u8）。 */
export function subslice_u8(s: []u8, start: usize, len: usize): []u8 {
  let r: []u8;
  unsafe { r = core_subslice_u8_c(s.data, s.length, start, len); }
  return r;
}

/** 在 at 处拆分（[]u8）。 */
export function split_at_u8(s: []u8, at: usize): Split_u8 {
  let at_clamped: usize = at;
  if (at_clamped > s.length) { at_clamped = s.length; }
  return Split_u8 {
    left: subslice_u8(s, 0 as usize, at_clamped),
    right: subslice_u8(s, at_clamped, s.length - at_clamped),
  };
}

/** chunk 个数（[]u8）。 */
export function chunks_len_u8(s: []u8, chunk_size: usize): usize {
  if (chunk_size == 0 as usize) { return 0 as usize; }
  if (s.length == 0 as usize) { return 0 as usize; }
  return (s.length + chunk_size - 1 as usize) / chunk_size;
}

/** 取第 index 个 chunk（[]u8）。 */
export function chunk_u8(s: []u8, chunk_size: usize, index: usize): []u8 {
  if (chunk_size == 0 as usize) {
    let empty0: []u8;
    unsafe { empty0 = core_slice_u8_from_ptr_c(s.data, 0 as usize); }
    return empty0;
  }
  let off: usize = index * chunk_size;
  if (off >= s.length) {
    let empty1: []u8;
    unsafe { empty1 = core_slice_u8_from_ptr_c(s.data, 0 as usize); }
    return empty1;
  }
  let n: usize = chunk_size;
  if (off + n > s.length) { n = s.length - off; }
  return subslice_u8(s, off, n);
}

// ——— []u64（CORE-157） ———
/** 返回 []u64 切片的长度。 */
export function len_u64(s: []u64): usize { return s.length; }

/** 边界内返回 some(s.data[i])，越界返回 option.none_u64()。 */
export function get_u64(s: []u64, i: usize): Option_u64 {
  if (i >= s.length) {
    return option.none_u64();
  }
  return option.some_u64(s.data[i]);
}

/** 是否为空切片（[]u64）。 */
export function is_empty_u64(s: []u64): i32 {
  if (s.length == 0 as usize) { return 1; }
  return 0;
}

/** 取首元素（[]u64）。 */
export function first_u64(s: []u64): Option_u64 {
  return get_u64(s, 0 as usize);
}

/** 取尾元素（[]u64）。 */
export function last_u64(s: []u64): Option_u64 {
  if (s.length == 0 as usize) { return option.none_u64(); }
  return get_u64(s, s.length - 1 as usize);
}

/** 零拷贝 subslice（[]u64）。 */
export function subslice_u64(s: []u64, start: usize, len: usize): []u64 {
  let r: []u64;
  unsafe { r = core_subslice_u64_c(s.data, s.length, start, len); }
  return r;
}

/** 在 at 处拆分（[]u64）。 */
export function split_at_u64(s: []u64, at: usize): Split_u64 {
  let at_clamped: usize = at;
  if (at_clamped > s.length) { at_clamped = s.length; }
  return Split_u64 {
    left: subslice_u64(s, 0 as usize, at_clamped),
    right: subslice_u64(s, at_clamped, s.length - at_clamped),
  };
}

/** chunk 个数（[]u64）。 */
export function chunks_len_u64(s: []u64, chunk_size: usize): usize {
  if (chunk_size == 0 as usize) { return 0 as usize; }
  if (s.length == 0 as usize) { return 0 as usize; }
  return (s.length + chunk_size - 1 as usize) / chunk_size;
}

/** 取第 index 个 chunk（[]u64）。 */
export function chunk_u64(s: []u64, chunk_size: usize, index: usize): []u64 {
  if (chunk_size == 0 as usize) {
    let empty0: []u64;
    unsafe { empty0 = core_slice_u64_from_ptr_c(s.data, 0 as usize); }
    return empty0;
  }
  let off: usize = index * chunk_size;
  if (off >= s.length) {
    let empty1: []u64;
    unsafe { empty1 = core_slice_u64_from_ptr_c(s.data, 0 as usize); }
    return empty1;
  }
  let n: usize = chunk_size;
  if (off + n > s.length) { n = s.length - off; }
  return subslice_u64(s, off, n);
}
