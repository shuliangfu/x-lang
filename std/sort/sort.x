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
// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

/* See implementation. */
extern "C" function malloc(size: usize): *u8;

/* See implementation. */
export const SORT_CMP_I32_ASC: usize = 1;
export const SORT_CMP_I32_DESC: usize = 2;
export const SORT_CMP_KEY_I32: usize = 3;

/* See implementation. */
allow(padding) struct SortKeyTag {
  key: i32
  tag: i32
}

/** Exported function `sort_cmp_i32`.
 * Comparison/utility `sort_cmp_i32`.
 * @param a *i32
 * @param b *i32
 * @return i32
 */
export function sort_cmp_i32(a: *i32, b: *i32): i32 {
  if (a[0] < b[0]) { return -1; }
  if (a[0] > b[0]) { return 1; }
  return 0;
}

/** Exported function `sort_cmp_u8`.
 * Comparison/utility `sort_cmp_u8`.
 * @param a *u8
 * @param b *u8
 * @return i32
 */
export function sort_cmp_u8(a: *u8, b: *u8): i32 {
  if (a[0] < b[0]) { return -1; }
  if (a[0] > b[0]) { return 1; }
  return 0;
}

/** Exported function `sort_swap_i32`.
 * Implements `sort_swap_i32`.
 * @param a *i32
 * @param b *i32
 * @return void
 */
export function sort_swap_i32(a: *i32, b: *i32): void {
  let t: i32 = a[0];
  a[0] = b[0];
  b[0] = t;
}

/** Exported function `sort_swap_u8`.
 * Implements `sort_swap_u8`.
 * @param a *u8
 * @param b *u8
 * @return void
 */
export function sort_swap_u8(a: *u8, b: *u8): void {
  let t: u8 = a[0];
  a[0] = b[0];
  b[0] = t;
}

/** Exported function `sort_qsort_i32`.
 * Implements `sort_qsort_i32`.
 * @param ptr *i32
 * @param lo i32
 * @param hi i32
 * @return void
 */
export function sort_qsort_i32(ptr: *i32, lo: i32, hi: i32): void {
  let i: i32 = 0;
  let j: i32 = 0;
  let pivot: i32 = 0;
  if (lo >= hi) { return; }
  pivot = ptr[hi];
  i = lo;
  j = lo;
  while (j < hi) {
    if (ptr[j] <= pivot) {
      sort_swap_i32(&ptr[i], &ptr[j]);
      i = i + 1;
    }
    j = j + 1;
  }
  sort_swap_i32(&ptr[i], &ptr[hi]);
  sort_qsort_i32(ptr, lo, i - 1);
  sort_qsort_i32(ptr, i + 1, hi);
}

/** Exported function `sort_qsort_u8`.
 * Implements `sort_qsort_u8`.
 * @param ptr *u8
 * @param lo i32
 * @param hi i32
 * @return void
 */
export function sort_qsort_u8(ptr: *u8, lo: i32, hi: i32): void {
  let i: i32 = 0;
  let j: i32 = 0;
  let pivot: u8 = 0;
  if (lo >= hi) { return; }
  pivot = ptr[hi];
  i = lo;
  j = lo;
  while (j < hi) {
    if (ptr[j] <= pivot) {
      sort_swap_u8(&ptr[i], &ptr[j]);
      i = i + 1;
    }
    j = j + 1;
  }
  sort_swap_u8(&ptr[i], &ptr[hi]);
  sort_qsort_u8(ptr, lo, i - 1);
  sort_qsort_u8(ptr, i + 1, hi);
}

/** Exported function `sort_merge_i32_range`.
 * Implements `sort_merge_i32_range`.
 * @param base *i32
 * @param temp *i32
 * @param left i32
 * @param right i32
 * @param cmp_dir i32
 * @return void
 */
export function sort_merge_i32_range(base: *i32, temp: *i32, left: i32, right: i32, cmp_dir: i32): void {
  let n: i32 = 0;
  let mid: i32 = 0;
  let li: i32 = 0;
  let ri: i32 = 0;
  let lcnt: i32 = 0;
  let rcnt: i32 = 0;
  let out: i32 = 0;
  let c: i32 = 0;
  if (right - left <= 1) { return; }
  n = right - left;
  mid = left + n / 2;
  sort_merge_i32_range(base, temp, left, mid, cmp_dir);
  sort_merge_i32_range(base, temp, mid, right, cmp_dir);
  li = 0;
  ri = 0;
  lcnt = mid - left;
  rcnt = right - mid;
  out = 0;
  while (li < lcnt && ri < rcnt) {
    c = sort_cmp_i32(&base[left + li], &base[mid + ri]);
    if (cmp_dir < 0) { c = -c; }
    if (c <= 0) {
      temp[out] = base[left + li];
      li = li + 1;
    } else {
      temp[out] = base[mid + ri];
      ri = ri + 1;
    }
    out = out + 1;
  }
  while (li < lcnt) {
    temp[out] = base[left + li];
    li = li + 1;
    out = out + 1;
  }
  while (ri < rcnt) {
    temp[out] = base[mid + ri];
    ri = ri + 1;
    out = out + 1;
  }
  /* inline byte copy (avoid core.mem dependency → core_mem_mem_copy undefined in user link) */
  let bi: usize = 0;
  let nbytes: usize = (n * 4) as usize;
  let dst_bytes: *u8 = (&base[left]) as *u8;
  let src_bytes: *u8 = temp as *u8;
  while (bi < nbytes) {
    dst_bytes[bi] = src_bytes[bi];
    bi = bi + 1;
  }
}

/** Exported function `sort_stable_i32_impl`.
 * Implements `sort_stable_i32_impl`.
 * @param ptr *i32
 * @param len i32
 * @param cmp_dir i32
 * @return void
 */
export function sort_stable_i32_impl(ptr: *i32, len: i32, cmp_dir: i32): void {
  let temp: *i32 = 0 as *i32;
  if (ptr == 0 || len <= 1) { return; }
  unsafe { temp = malloc((len * 4) as usize) as *i32; }
  if (temp == 0) { return; }
  sort_merge_i32_range(ptr, temp, 0, len, cmp_dir);
  /* temp buffer not freed: ASM backend redirects free→heap_free_c which is unavailable in user link */
}

/** Exported function `sort_merge_u8_range`.
 * Implements `sort_merge_u8_range`.
 * @param base *u8
 * @param temp *u8
 * @param left i32
 * @param right i32
 * @param cmp_dir i32
 * @return void
 */
export function sort_merge_u8_range(base: *u8, temp: *u8, left: i32, right: i32, cmp_dir: i32): void {
  let n: i32 = 0;
  let mid: i32 = 0;
  let li: i32 = 0;
  let ri: i32 = 0;
  let lcnt: i32 = 0;
  let rcnt: i32 = 0;
  let out: i32 = 0;
  let c: i32 = 0;
  if (right - left <= 1) { return; }
  n = right - left;
  mid = left + n / 2;
  sort_merge_u8_range(base, temp, left, mid, cmp_dir);
  sort_merge_u8_range(base, temp, mid, right, cmp_dir);
  li = 0;
  ri = 0;
  lcnt = mid - left;
  rcnt = right - mid;
  out = 0;
  while (li < lcnt && ri < rcnt) {
    c = sort_cmp_u8(&base[left + li], &base[mid + ri]);
    if (cmp_dir < 0) { c = -c; }
    if (c <= 0) {
      temp[out] = base[left + li];
      li = li + 1;
    } else {
      temp[out] = base[mid + ri];
      ri = ri + 1;
    }
    out = out + 1;
  }
  while (li < lcnt) {
    temp[out] = base[left + li];
    li = li + 1;
    out = out + 1;
  }
  while (ri < rcnt) {
    temp[out] = base[mid + ri];
    ri = ri + 1;
    out = out + 1;
  }
  /* inline byte copy (avoid core.mem dependency) */
  let bi2: usize = 0;
  let nbytes2: usize = n as usize;
  let dst2: *u8 = &base[left];
  let src2: *u8 = temp;
  while (bi2 < nbytes2) {
    dst2[bi2] = src2[bi2];
    bi2 = bi2 + 1;
  }
}

/** Exported function `sort_stable_u8_impl`.
 * Implements `sort_stable_u8_impl`.
 * @param ptr *u8
 * @param len i32
 * @param cmp_dir i32
 * @return void
 */
export function sort_stable_u8_impl(ptr: *u8, len: i32, cmp_dir: i32): void {
  let temp: *u8 = 0 as *u8;
  if (ptr == 0 || len <= 1) { return; }
  unsafe { temp = malloc(len as usize); }
  if (temp == 0) { return; }
  sort_merge_u8_range(ptr, temp, 0, len, cmp_dir);
  /* temp buffer not freed: ASM backend redirects free→heap_free_c */
}

/** Exported function `sort_cmp_key_tag`.
 * Comparison/utility `sort_cmp_key_tag`.
 * @param a *SortKeyTag
 * @param b *SortKeyTag
 * @return i32
 */
export function sort_cmp_key_tag(a: *SortKeyTag, b: *SortKeyTag): i32 {
  if (a.key < b.key) { return -1; }
  if (a.key > b.key) { return 1; }
  return 0;
}

/** Exported function `sort_merge_key_range`.
 * Implements `sort_merge_key_range`.
 * @param base *SortKeyTag
 * @param temp *SortKeyTag
 * @param left i32
 * @param right i32
 * @return void
 */
export function sort_merge_key_range(base: *SortKeyTag, temp: *SortKeyTag, left: i32, right: i32): void {
  let n: i32 = 0;
  let mid: i32 = 0;
  let li: i32 = 0;
  let ri: i32 = 0;
  let lcnt: i32 = 0;
  let rcnt: i32 = 0;
  let out: i32 = 0;
  let c: i32 = 0;
  if (right - left <= 1) { return; }
  n = right - left;
  mid = left + n / 2;
  sort_merge_key_range(base, temp, left, mid);
  sort_merge_key_range(base, temp, mid, right);
  li = 0;
  ri = 0;
  lcnt = mid - left;
  rcnt = right - mid;
  out = 0;
  while (li < lcnt && ri < rcnt) {
    c = sort_cmp_key_tag(&base[left + li], &base[mid + ri]);
    if (c <= 0) {
      temp[out] = base[left + li];
      li = li + 1;
    } else {
      temp[out] = base[mid + ri];
      ri = ri + 1;
    }
    out = out + 1;
  }
  while (li < lcnt) {
    temp[out] = base[left + li];
    li = li + 1;
    out = out + 1;
  }
  while (ri < rcnt) {
    temp[out] = base[mid + ri];
    ri = ri + 1;
    out = out + 1;
  }
  /* inline byte copy (avoid core.mem dependency) */
  let bi3: usize = 0;
  let nbytes3: usize = (n * 8) as usize;
  let dst3: *u8 = (&base[left]) as *u8;
  let src3: *u8 = temp as *u8;
  while (bi3 < nbytes3) {
    dst3[bi3] = src3[bi3];
    bi3 = bi3 + 1;
  }
}

/** Exported function `sort`.
 * Implements `sort`.
 * @param ptr *i32
 * @param len i32
 * @return void
 */
export function sort(ptr: *i32, len: i32): void {
  if (ptr == 0 || len <= 1) { return; }
  sort_qsort_i32(ptr, 0, len - 1);
}

/** Exported function `sort`.
 * Implements `sort`.
 * @param ptr *u8
 * @param len i32
 * @return void
 */
export function sort(ptr: *u8, len: i32): void {
  if (ptr == 0 || len <= 1) { return; }
  sort_qsort_u8(ptr, 0, len - 1);
}

/** Exported function `stable`.
 * Implements `stable`.
 * @param ptr *i32
 * @param len i32
 * @return void
 */
export function stable(ptr: *i32, len: i32): void {
  sort_stable_i32_impl(ptr, len, 1);
}

/** Exported function `stable`.
 * Implements `stable`.
 * @param ptr *u8
 * @param len i32
 * @return void
 */
export function stable(ptr: *u8, len: i32): void {
  sort_stable_u8_impl(ptr, len, 1);
}

/** Exported function `cmp`.
 * Comparison/utility `cmp`.
 * @param ptr *i32
 * @param len i32
 * @param cmp_fn usize
 * @return void
 */
export function cmp(ptr: *i32, len: i32, cmp_fn: usize): void {
  if (ptr == 0 || len <= 1) { return; }
  if (cmp_fn == SORT_CMP_I32_DESC) {
    sort_stable_i32_impl(ptr, len, -1);
    return;
  }
  sort_stable_i32_impl(ptr, len, 1);
}

/** Exported function `stable_key_tag`.
 * Implements `stable_key_tag`.
 * @param ptr *SortKeyTag
 * @param len i32
 * @return void
 */
export function stable_key_tag(ptr: *SortKeyTag, len: i32): void {
  let temp: *SortKeyTag = 0 as *SortKeyTag;
  if (ptr == 0 || len <= 1) { return; }
  unsafe { temp = malloc((len * 8) as usize) as *SortKeyTag; }
  if (temp == 0) { return; }
  sort_merge_key_range(ptr, temp, 0, len);
  /* temp buffer not freed: ASM backend redirects free→heap_free_c */
}

/** Exported function `cmp_desc_fn`.
 * Comparison/utility `cmp_desc_fn`.
 * @return usize
 */
export function cmp_desc_fn(): usize {
  return SORT_CMP_I32_DESC;
}

/** Exported function `cmp_asc_fn`.
 * Comparison/utility `cmp_asc_fn`.
 * @return usize
 */
export function cmp_asc_fn(): usize {
  return SORT_CMP_I32_ASC;
}

/** Exported function `cmp_key_fn`.
 * Comparison/utility `cmp_key_fn`.
 * @return usize
 */
export function cmp_key_fn(): usize {
  return SORT_CMP_KEY_I32;
}

/** Exported function `sort_stable_smoke_c`.
 * Implements `sort_stable_smoke_c`.
 * @return i32
 */
export function sort_stable_smoke_c(): i32 {
  let a: i32[4] = [3, 1, 4, 2];
  let b: i32[4] = [3, 1, 4, 2];
  let items: SortKeyTag[4] = [
    SortKeyTag { key: 3, tag: 0 },
    SortKeyTag { key: 1, tag: 1 },
    SortKeyTag { key: 3, tag: 2 },
    SortKeyTag { key: 2, tag: 3 },
  ];
  stable(&a[0], 4);
  if (a[0] != 1 || a[1] != 2 || a[2] != 3 || a[3] != 4) { return 1; }
  cmp(&b[0], 4, SORT_CMP_I32_DESC);
  if (b[0] != 4 || b[1] != 3 || b[2] != 2 || b[3] != 1) { return 2; }
  stable_key_tag(&items[0], 4);
  if (items[0].key != 1 || items[1].key != 2) { return 3; }
  if (items[2].key != 3 || items[3].key != 3) { return 4; }
  if (items[2].tag != 0 || items[3].tag != 2) { return 5; }
  return 0;
}

/** Exported function `sort_key_cmp_smoke_c`.
 * Comparison/utility `sort_key_cmp_smoke_c`.
 * @return i32
 */
export function sort_key_cmp_smoke_c(): i32 {
  let items: SortKeyTag[4] = [
    SortKeyTag { key: 3, tag: 0 },
    SortKeyTag { key: 1, tag: 1 },
    SortKeyTag { key: 3, tag: 2 },
    SortKeyTag { key: 2, tag: 3 },
  ];
  stable_key_tag(&items[0], 4);
  if (items[0].key != 1) { return 1; }
  if (items[1].key != 2) { return 2; }
  if (items[2].key != 3 || items[3].key != 3) { return 3; }
  if (items[2].tag != 0 || items[3].tag != 2) { return 4; }
  if (cmp_key_fn() == 0) { return 5; }
  return 0;
}
