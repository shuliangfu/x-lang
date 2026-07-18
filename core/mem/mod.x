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

// core.mem — memory ops: copy/move/set/compare and alignment (pre-selfhost minimal).
// Provides align_of_*, mem_copy (non-overlap), mem_set/zero, mem_move (high→low overlap-tolerant), mem_compare, mem_swap, align_up/down.
// C-like memcpy/memset/memcmp; mem_move is high→low only (not full bidirectional memmove). mem_compare returns -1/0/1. Pure .x loops.

// Module import marker.
/** `placeholder`: see signature for params/returns; contracts in body. */
export function placeholder(): i32 { return 0; }

// --- Alignment queries (mirror core.types for core.mem-only imports) ---
/** `align_of_i32`: see signature for params/returns; contracts in body. */
export function align_of_i32(): i32 { return 4; }
/** `align_of_bool`: see signature for params/returns; contracts in body. */
export function align_of_bool(): i32 { return 1; }
/** `align_of_u8`: see signature for params/returns; contracts in body. */
export function align_of_u8(): i32 { return 1; }
/** `align_of_u32`: see signature for params/returns; contracts in body. */
export function align_of_u32(): i32 { return 4; }
/** `align_of_u64`: see signature for params/returns; contracts in body. */
export function align_of_u64(): i32 { return 8; }
/** `align_of_i64`: see signature for params/returns; contracts in body. */
export function align_of_i64(): i32 { return 8; }
/** `align_of_usize`: see signature for params/returns; contracts in body. */
export function align_of_usize(): i32 { return 8; }
/** `align_of_isize`: see signature for params/returns; contracts in body. */
export function align_of_isize(): i32 { return 8; }
/** `align_of_f32`: see signature for params/returns; contracts in body. */
export function align_of_f32(): i32 { return 4; }
/** `align_of_f64`: see signature for params/returns; contracts in body. */
export function align_of_f64(): i32 { return 8; }
/** `align_of_pointer`: see signature for params/returns; contracts in body. */
export function align_of_pointer(): i32 { return 8; }

// --- Byte copy; non-overlapping; C memcpy semantics.
// Implemented as .x loop to avoid clashing with platform memcpy macros.
/** `mem_copy`: see signature for params/returns; contracts in body. */
export function mem_copy(dst: *u8, src: *u8, n: usize): void {
  let i: usize = 0;
  while (i < n) {
    dst[i] = src[i];
    i = i + 1;
  }
}

// --- Fill dst[0..n) with byte (C memset).
/** `mem_set`: see signature for params/returns; contracts in body. */
export function mem_set(dst: *u8, byte: u8, n: usize): void {
  let i: usize = 0;
  while (i < n) {
    dst[i] = byte;
    i = i + 1;
  }
}

// --- Overlap-tolerant copy always high→low; correct when dst is after src (not full bidirectional memmove).
/** `mem_move`: see signature for params/returns; contracts in body. */
export function mem_move(dst: *u8, src: *u8, n: usize): void {
  let i: usize = n;
  while (i > 0) {
    i = i - 1;
    dst[i] = src[i];
  }
}

// --- Byte compare a[0..n) vs b[0..n); returns -1/0/1 (C memcmp style).
/** `mem_compare`: see signature for params/returns; contracts in body. */
export function mem_compare(a: *u8, b: *u8, n: usize): i32 {
  let i: usize = 0;
  while (i < n) {
    if (a[i] < b[i]) { return -1; }
    if (a[i] > b[i]) { return 1; }
    i = i + 1;
  }
  return 0;
}

// --- Zero dst[0..n); same as mem_set(dst, 0, n).
/** `mem_zero`: see signature for params/returns; contracts in body. */
export function mem_zero(dst: *u8, n: usize): void {
  mem_set(dst, 0, n);
}

// --- Swap a[0..n) with b[0..n); non-overlapping required.
/** `mem_swap`: see signature for params/returns; contracts in body. */
export function mem_swap(a: *u8, b: *u8, n: usize): void {
  let i: usize = 0;
  while (i < n) {
    let t: u8 = a[i];
    a[i] = b[i];
    b[i] = t;
    i = i + 1;
  }
}

// --- True if x is non-zero power of two (alignment validation); 0 → false.
/** `is_alignment_power_of_two`: see signature for params/returns; contracts in body. */
export function is_alignment_power_of_two(x: usize): bool {
  if (x == 0) { return false; }
  let m: usize = x - 1;
  let and_val: usize = x & m;
  return and_val == 0;
}

// --- Alignment rounding for allocators; alignment 0 leaves addr unchanged ---
/** `align_up`: see signature for params/returns; contracts in body. */
export function align_up(addr: usize, alignment: usize): usize {
  if (alignment == 0) {
    return addr;
  }
  return ((addr + alignment - 1) / alignment) * alignment;
}

/** `align_down`: see signature for params/returns; contracts in body. */
export function align_down(addr: usize, alignment: usize): usize {
  if (alignment == 0) {
    return addr;
  }
  return (addr / alignment) * alignment;
}

// --- Volatile loads/stores and fences (CORE-017; pure .x, no mem.c) ---
/*
 /* note */
 /* note */
 /* note */
 */

/** Volatile load u8; null returns 0. */
export function volatile_load_u8(ptr: *u8): u8 {
  if (ptr == 0) { return 0 as u8; }
  return ptr[0];
}

/** Volatile store u8; null is a no-op. */
export function volatile_store_u8(ptr: *u8, val: u8): void {
  if (ptr == 0) { return; }
  ptr[0] = val;
}

/** Volatile load u16; ptr must be 2-byte aligned; null returns 0. */
export function volatile_load_u16(ptr: *u8): u16 {
  if (ptr == 0) { return 0 as u16; }
  let p: *u16 = (ptr as *u16);
  return p[0];
}

/** Volatile store u16; null is a no-op. */
export function volatile_store_u16(ptr: *u8, val: u16): void {
  if (ptr == 0) { return; }
  let p: *u16 = (ptr as *u16);
  p[0] = val;
}

/** Volatile load u32; ptr must be 4-byte aligned; null returns 0. */
export function volatile_load_u32(ptr: *u8): u32 {
  if (ptr == 0) { return 0 as u32; }
  let p: *u32 = (ptr as *u32);
  return p[0];
}

/** Volatile store u32; null is a no-op. */
export function volatile_store_u32(ptr: *u8, val: u32): void {
  if (ptr == 0) { return; }
  let p: *u32 = (ptr as *u32);
  p[0] = val;
}

/** Compiler fence placeholder (currently a no-op). */
export function compiler_fence(): void {
  /* note */
}

/** Acquire fence (G-01 v1: compiler_fence only). */
export function fence_acquire(): void {
  compiler_fence();
}

/** Release fence (G-01 v1: compiler_fence only). */
export function fence_release(): void {
  compiler_fence();
}

/** Seq-cst fence (G-01 v1: compiler_fence only). */
export function fence_seq_cst(): void {
  compiler_fence();
}
