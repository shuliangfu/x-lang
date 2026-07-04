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

// std.sort — 排序（对标 Zig std.sort、Rust Vec::sort）
//
// 【文件职责】sort_i32、sort_u8 原地不稳定升序；sort_stable_* 稳定归并；
// sort_i32_cmp 自定义比较器；sort_stable_by_key 按 KeyTag.key 稳定排序。
// 【依赖】core；实现见 sort.x（F-sort v1）。
const sort_impl = import("std.sort.sort");

/** key+payload 对：稳定排序时仅比较 key，保留 tag 相对顺序（STD-150）。 */
struct KeyTag {
  key: i32
  tag: i32
}

/** 原地对 ptr[0..len] 升序排序（i32）；不稳定。 */
function sort(ptr: *i32, len: i32): void {
  sort_impl.sort(ptr, len);
}

/** 原地对 ptr[0..len] 升序排序（u8）；不稳定。 */
function sort(ptr: *u8, len: i32): void {
  sort_impl.sort(ptr, len);
}

/** 原地稳定升序排序 ptr[0..len]（i32）。 */
function stable(ptr: *i32, len: i32): void {
  sort_impl.stable(ptr, len);
}

/** 原地稳定升序排序 ptr[0..len]（u8）。 */
function stable(ptr: *u8, len: i32): void {
  sort_impl.stable(ptr, len);
}

/** 原地稳定排序 ptr[0..len]（i32）；cmp_fn 为 usize 承载的 C 比较器。 */
function cmp(ptr: *i32, len: i32, cmp_fn: usize): void {
  sort_impl.cmp(ptr, len, cmp_fn);
}

/** KeyTag 数组按 key 稳定升序排序。 */
function stable_by_key(ptr: *KeyTag, len: i32): void {
  sort_impl.stable_key_tag(ptr as *sort_impl.SortKeyTag, len);
}

/** 返回降序 i32 比较器函数地址（usize）。 */
function cmp_desc_fn(): usize {
  return sort_impl.cmp_desc_fn();
}

/** 返回升序 i32 比较器函数地址（usize）。 */
function cmp_asc_fn(): usize {
  return sort_impl.cmp_asc_fn();
}

/** 返回 KeyTag key 比较器函数地址（usize）。 */
function cmp_key_fn(): usize {
  return sort_impl.cmp_key_fn();
}
