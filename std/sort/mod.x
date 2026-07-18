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
// See implementation.
const sort_impl = import("std.sort.sort");

/* See implementation. */
export struct KeyTag {
  key: i32
  tag: i32
}

/** Exported function `sort`.
 * Implements `sort`.
 * @param ptr *i32
 * @param len i32
 * @return void
 */
export function sort(ptr: *i32, len: i32): void {
  if (ptr == 0 || len <= 1) { return; }
  sort_impl.sort_qsort_i32(ptr, 0, len - 1);
}

/** Exported function `sort`.
 * Implements `sort`.
 * @param ptr *u8
 * @param len i32
 * @return void
 */
export function sort(ptr: *u8, len: i32): void {
  if (ptr == 0 || len <= 1) { return; }
  sort_impl.sort_qsort_u8(ptr, 0, len - 1);
}

/** Exported function `stable`.
 * Implements `stable`.
 * @param ptr *i32
 * @param len i32
 * @return void
 */
export function stable(ptr: *i32, len: i32): void {
  sort_impl.sort_stable_i32_impl(ptr, len, 1);
}

/** Exported function `stable`.
 * Implements `stable`.
 * @param ptr *u8
 * @param len i32
 * @return void
 */
export function stable(ptr: *u8, len: i32): void {
  sort_impl.sort_stable_u8_impl(ptr, len, 1);
}

/** Exported function `cmp`.
 * Comparison/utility `cmp`.
 * @param ptr *i32
 * @param len i32
 * @param cmp_fn usize
 * @return void
 */
export function cmp(ptr: *i32, len: i32, cmp_fn: usize): void {
  sort_impl.cmp(ptr, len, cmp_fn);
}

/** Exported function `stable_by_key`.
 * Implements `stable_by_key`.
 * @param ptr *KeyTag
 * @param len i32
 * @return void
 */
export function stable_by_key(ptr: *KeyTag, len: i32): void {
  sort_impl.stable_key_tag(ptr as *sort_impl.SortKeyTag, len);
}

/** Exported function `cmp_desc_fn`.
 * Comparison/utility `cmp_desc_fn`.
 * @return usize
 */
export function cmp_desc_fn(): usize {
  return sort_impl.cmp_desc_fn();
}

/** Exported function `cmp_asc_fn`.
 * Comparison/utility `cmp_asc_fn`.
 * @return usize
 */
export function cmp_asc_fn(): usize {
  return sort_impl.cmp_asc_fn();
}

/** Exported function `cmp_key_fn`.
 * Comparison/utility `cmp_key_fn`.
 * @return usize
 */
export function cmp_key_fn(): usize {
  return sort_impl.cmp_key_fn();
}
