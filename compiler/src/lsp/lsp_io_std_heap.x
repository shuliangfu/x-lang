// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
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

// See implementation.
//
// See implementation.
// std_heap_alloc/std_heap_free；
// See implementation.

/* See implementation. */
export extern "C" function malloc(size: usize): *u8;
export extern "C" function free(ptr: *u8): void;
export extern "C" function calloc(nmemb: usize, size: usize): *u8;

/** Exported function `std_heap_alloc`.
 * Memory management helper `std_heap_alloc`.
 * @param size usize
 * @return *u8
 */
export function std_heap_alloc(size: usize): *u8 {
  if (size == 0 as usize) {
    return 0 as *u8;
  }
  unsafe {
    return malloc(size);
  }
  return 0 as *u8;
}

/** Exported function `std_heap_alloc_zeroed`.
 * Memory management helper `std_heap_alloc_zeroed`.
 * @param size usize
 * @return *u8
 */
export function std_heap_alloc_zeroed(size: usize): *u8 {
  if (size == 0 as usize) {
    return 0 as *u8;
  }
  unsafe {
    return calloc(1 as usize, size);
  }
  return 0 as *u8;
}

/** Exported function `std_heap_free`.
 * Memory management helper `std_heap_free`.
 * @param ptr *u8
 * @return void
 */
export function std_heap_free(ptr: *u8): void {
  if (ptr == 0 as *u8) {
    return;
  }
  unsafe {
    free(ptr);
  }
}
