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
// See implementation.

/**
 * Fill ptr[0..n) with byte. Local loop — do not call imported core.mem.mem_set
 * from this nested heap file: typeck of import("std.heap") re-checks ops.x and
 * treats `mem.mem_set` as METHOD on an unbound import (T001). Same bytes as
 * core/mem/mod.x mem_set.
 * @param ptr *u8 — destination; null + n>0 is caller error
 * @param byte u8 — fill value
 * @param n i32 — byte count; n<=0 is no-op
 * @return void
 * PLATFORM: SHARED — unblocks formal_mod compile of std/vec via import heap.
 */
export function heap_mem_set_c(ptr: *u8, byte: u8, n: i32): void {
  if (n <= 0) {
    return;
  }
  let i: i32 = 0;
  while (i < n) {
    ptr[i] = byte;
    i = i + 1;
  }
}

/**
 * Compare a[0..n) vs b[0..n); -1/0/1. Local loop (same reason as heap_mem_set_c).
 * @param a *u8 — left bytes
 * @param b *u8 — right bytes
 * @param n i32 — byte count; n<=0 → 0
 * @return i32 — memcmp-style
 * PLATFORM: SHARED
 */
export function heap_mem_compare_c(a: *u8, b: *u8, n: i32): i32 {
  if (n <= 0) {
    return 0;
  }
  let i: i32 = 0;
  while (i < n) {
    if (a[i] < b[i]) {
      return -1;
    }
    if (a[i] > b[i]) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

/**
 * See implementation.
 */
export function map_slot(key: i32, cap: i32): i32 {
  let h: i32 = key % cap;
  if (h < 0) {
    return h + cap;
  }
  return h;
}

/**
 * See implementation.
 */
export function map_i32_i32_find_c(keys: *i32, occupied: *u8, cap: i32, key: i32): i32 {
  if (cap <= 0) {
    return -1;
  }
  let start: i32 = map_slot(key, cap);
  let i: i32 = start;
  let guard: i32 = 0;
  while (guard < cap) {
    if (occupied[i] == 0) {
      return -1;
    }
    if (keys[i] == key) {
      return i;
    }
    i = i + 1;
    if (i >= cap) {
      i = 0;
    }
    if (i == start) {
      return -1;
    }
    guard = guard + 1;
  }
  return -1;
}
