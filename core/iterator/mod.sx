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

// core.iterator — 最小迭代协议（CORE-006）
// v1 具象迭代器：SliceIter_i32 / SliceIter_u8；next_* 返回 Option（耗尽为 none）。
// 内部用 ptr+length+index 而非嵌套 T[]，避免 slice 形参 ABI 下 struct 字段赋值错误。

const option = import("core.option");

/** i32[] 切片迭代器：ptr/length 为数据源，index 为游标。 */
struct SliceIter_i32 {
  ptr: *i32;
  length: usize;
  index: usize;
}

/** u8[] 切片迭代器：ptr/length 为数据源，index 为游标。 */
struct SliceIter_u8 {
  ptr: *u8;
  length: usize;
  index: usize;
}

/** 从 i32[] 构造迭代器（index 从 0 开始）。 */
function iter_i32(s: i32[]): SliceIter_i32 {
  return SliceIter_i32 { ptr: s.data, length: s.length, index: 0 as usize };
}

/** 从 u8[] 构造迭代器（index 从 0 开始）。 */
function iter_u8(s: u8[]): SliceIter_u8 {
  return SliceIter_u8 { ptr: s.data, length: s.length, index: 0 as usize };
}

/** 推进 i32 迭代器；有下一元素返回 some，否则 none。 */
function next_i32(it: *SliceIter_i32): Option_i32 {
  if (it.index >= it.length) {
    return option.none_i32();
  }
  let v: i32 = it.ptr[it.index];
  it.index = it.index + 1 as usize;
  return option.some_i32(v);
}

/** 推进 u8 迭代器；有下一元素返回 some，否则 none。 */
function next_u8(it: *SliceIter_u8): Option_u8 {
  if (it.index >= it.length) {
    return option.none_u8();
  }
  let v: u8 = it.ptr[it.index];
  it.index = it.index + 1 as usize;
  return option.some_u8(v);
}

/** 返回 i32 迭代器尚未消费的元素个数。 */
function iter_remaining_i32(it: *SliceIter_i32): usize {
  if (it.index >= it.length) { return 0 as usize; }
  return it.length - it.index;
}

/** 返回 u8 迭代器尚未消费的元素个数。 */
function iter_remaining_u8(it: *SliceIter_u8): usize {
  if (it.index >= it.length) { return 0 as usize; }
  return it.length - it.index;
}

/** CORE-020：u64[] 切片迭代器（与 i32/u8 同协议）。 */
struct SliceIter_u64 {
  ptr: *u64;
  length: usize;
  index: usize;
}

/** CORE-020：迭代协议版本号（v1=具象 SliceIter_* 族）。 */
function iterator_protocol_version(): i32 { return 1; }

/** 从 *u64 + length 构造迭代器（避开 u64[] .data typeck 限制）。 */
function iter_u64_from_buf(ptr: *u64, length: usize): SliceIter_u64 {
  return SliceIter_u64 { ptr: ptr, length: length, index: 0 as usize };
}

/** 推进 u64 迭代器；有下一元素返回 some，否则 none。 */
function next_u64(it: *SliceIter_u64): Option_u64 {
  if (it.index >= it.length) {
    return option.none_u64();
  }
  let v: u64 = it.ptr[it.index];
  it.index = it.index + 1 as usize;
  return option.some_u64(v);
}

/** 返回 u64 迭代器尚未消费的元素个数。 */
function iter_remaining_u64(it: *SliceIter_u64): usize {
  if (it.index >= it.length) { return 0 as usize; }
  return it.length - it.index;
}

