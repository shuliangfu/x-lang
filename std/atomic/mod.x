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

/**
 * C11 stdatomic C ABI wrappers.
 *
 * All `atomic_*_c` functions below are thin wrappers over C11 <stdatomic.h>
 * intrinsics (atomic_load / atomic_store / atomic_compare_exchange /
 * atomic_fetch_add / atomic_fetch_sub / atomic_fence_*). They are implemented
 * in C (see seeds) and exposed to SHUX via `extern "C"` declarations.
 *
 * ABI: C (System V / AAPCS). Calling convention matches libc/C runtime.
 * PLATFORM: SHARED — atomic intrinsics are available on all targets
 * (macOS arm64 / Ubuntu x86_64 / Windows MSYS2).
 *
 * Memory model: C11 memory_order_* (ORDER_RELAXED=0, ORDER_ACQUIRE=1,
 * ORDER_RELEASE=2, ORDER_ACQ_REL=3, ORDER_SEQ_CST=4).
 *
 * Unsafe contract: callers must wrap `atomic_*_c` calls in `unsafe { }`
 * blocks. P0a semantic downgrade currently allows unwrapped calls; P1
 * typeck enforcement (post-bootstrap) will reject unwrapped calls.
 */
extern "C" function atomic_load_i32_c(ptr: *i32): i32;
extern "C" function atomic_store_i32_c(ptr: *i32, val: i32): void;
extern "C" function atomic_compare_exchange_i32_c(ptr: *i32, expected: *i32, desired: i32): i32;
extern "C" function atomic_fetch_add_i32_c(ptr: *i32, delta: i32): i32;
extern "C" function atomic_fetch_sub_i32_c(ptr: *i32, delta: i32): i32;
extern "C" function atomic_load_u32_c(ptr: *u32): u32;
extern "C" function atomic_store_u32_c(ptr: *u32, val: u32): void;
extern "C" function atomic_compare_exchange_u32_c(ptr: *u32, expected: *u32, desired: u32): i32;
extern "C" function atomic_fetch_add_u32_c(ptr: *u32, delta: u32): u32;
extern "C" function atomic_load_i64_c(ptr: *i64): i64;
extern "C" function atomic_store_i64_c(ptr: *i64, val: i64): void;
extern "C" function atomic_load_u64_c(ptr: *u64): u64;
extern "C" function atomic_store_u64_c(ptr: *u64, val: u64): void;
extern "C" function atomic_fetch_add_i64_c(ptr: *i64, delta: i64): i64;
extern "C" function atomic_load_i16_c(ptr: *i16): i16;
extern "C" function atomic_store_i16_c(ptr: *i16, val: i16): void;
extern "C" function atomic_fetch_add_i16_c(ptr: *i16, delta: i16): i16;
extern "C" function atomic_compare_exchange_i16_c(ptr: *i16, expected: *i16, desired: i16): i32;
extern "C" function atomic_load_u16_c(ptr: *u16): u16;
extern "C" function atomic_store_u16_c(ptr: *u16, val: u16): void;
extern "C" function atomic_fetch_add_u16_c(ptr: *u16, delta: u16): u16;
extern "C" function atomic_compare_exchange_u16_c(ptr: *u16, expected: *u16, desired: u16): i32;
extern "C" function atomic_compare_exchange_i64_c(ptr: *i64, expected: *i64, desired: i64): i32;
extern "C" function atomic_fetch_sub_i64_c(ptr: *i64, delta: i64): i64;
extern "C" function atomic_fetch_add_u64_c(ptr: *u64, delta: u64): u64;
extern "C" function atomic_fetch_sub_u64_c(ptr: *u64, delta: u64): u64;
extern "C" function atomic_compare_exchange_u64_c(ptr: *u64, expected: *u64, desired: u64): i32;

/** Exported function `load`.
 * Implements `load`.
 * @param ptr *i32
 * @return i32
 */
export function load(ptr: *i32): i32 {
  unsafe { return atomic_load_i32_c(ptr); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `load`.
 * Implements `load`.
 * @param ptr *u32
 * @return u32
 */
export function load(ptr: *u32): u32 {
  unsafe { return atomic_load_u32_c(ptr); }
  return 0 as u32; // unreachable — typeck workaround
}
/** Exported function `load`.
 * Implements `load`.
 * @param ptr *i64
 * @return i64
 */
export function load(ptr: *i64): i64 {
  unsafe { return atomic_load_i64_c(ptr); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `load`.
 * Implements `load`.
 * @param ptr *u64
 * @return u64
 */
export function load(ptr: *u64): u64 {
  unsafe { return atomic_load_u64_c(ptr); }
  return 0 as u64; // unreachable — typeck workaround
}
/** Exported function `load`.
 * Implements `load`.
 * @param ptr *i16
 * @return i16
 */
export function load(ptr: *i16): i16 {
  unsafe { return atomic_load_i16_c(ptr); }
  return 0 as i16; // unreachable — typeck workaround
}
/** Exported function `load`.
 * Implements `load`.
 * @param ptr *u16
 * @return u16
 */
export function load(ptr: *u16): u16 {
  unsafe { return atomic_load_u16_c(ptr); }
  return 0 as u16; // unreachable — typeck workaround
}

/** Exported function `store`.
 * Implements `store`.
 * @param ptr *i32
 * @param val i32
 * @return void
 */
export function store(ptr: *i32, val: i32): void {
  unsafe { atomic_store_i32_c(ptr, val); }
}
/** Exported function `store`.
 * Implements `store`.
 * @param ptr *u32
 * @param val u32
 * @return void
 */
export function store(ptr: *u32, val: u32): void {
  unsafe { atomic_store_u32_c(ptr, val); }
}
/** Exported function `store`.
 * Implements `store`.
 * @param ptr *i64
 * @param val i64
 * @return void
 */
export function store(ptr: *i64, val: i64): void {
  unsafe { atomic_store_i64_c(ptr, val); }
}
/** Exported function `store`.
 * Implements `store`.
 * @param ptr *u64
 * @param val u64
 * @return void
 */
export function store(ptr: *u64, val: u64): void {
  unsafe { atomic_store_u64_c(ptr, val); }
}
/** Exported function `store`.
 * Implements `store`.
 * @param ptr *i16
 * @param val i16
 * @return void
 */
export function store(ptr: *i16, val: i16): void {
  unsafe { atomic_store_i16_c(ptr, val); }
}
/** Exported function `store`.
 * Implements `store`.
 * @param ptr *u16
 * @param val u16
 * @return void
 */
export function store(ptr: *u16, val: u16): void {
  unsafe { atomic_store_u16_c(ptr, val); }
}

/** Exported function `compare_exchange`.
 * Implements `compare_exchange`.
 * @param ptr *i32
 * @param expected *i32
 * @param desired i32
 * @return i32
 */
export function compare_exchange(ptr: *i32, expected: *i32, desired: i32): i32 {
  unsafe { return atomic_compare_exchange_i32_c(ptr, expected, desired); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `compare_exchange`.
 * Implements `compare_exchange`.
 * @param ptr *u32
 * @param expected *u32
 * @param desired u32
 * @return i32
 */
export function compare_exchange(ptr: *u32, expected: *u32, desired: u32): i32 {
  unsafe { return atomic_compare_exchange_u32_c(ptr, expected, desired); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `compare_exchange`.
 * Implements `compare_exchange`.
 * @param ptr *i64
 * @param expected *i64
 * @param desired i64
 * @return i32
 */
export function compare_exchange(ptr: *i64, expected: *i64, desired: i64): i32 {
  unsafe { return atomic_compare_exchange_i64_c(ptr, expected, desired); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `compare_exchange`.
 * Implements `compare_exchange`.
 * @param ptr *u64
 * @param expected *u64
 * @param desired u64
 * @return i32
 */
export function compare_exchange(ptr: *u64, expected: *u64, desired: u64): i32 {
  unsafe { return atomic_compare_exchange_u64_c(ptr, expected, desired); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `compare_exchange`.
 * Implements `compare_exchange`.
 * @param ptr *i16
 * @param expected *i16
 * @param desired i16
 * @return i32
 */
export function compare_exchange(ptr: *i16, expected: *i16, desired: i16): i32 {
  unsafe { return atomic_compare_exchange_i16_c(ptr, expected, desired); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `compare_exchange`.
 * Implements `compare_exchange`.
 * @param ptr *u16
 * @param expected *u16
 * @param desired u16
 * @return i32
 */
export function compare_exchange(ptr: *u16, expected: *u16, desired: u16): i32 {
  unsafe { return atomic_compare_exchange_u16_c(ptr, expected, desired); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `fetch_add`.
 * Implements `fetch_add`.
 * @param ptr *i32
 * @param delta i32
 * @return i32
 */
export function fetch_add(ptr: *i32, delta: i32): i32 {
  unsafe { return atomic_fetch_add_i32_c(ptr, delta); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `fetch_add`.
 * Implements `fetch_add`.
 * @param ptr *u32
 * @param delta u32
 * @return u32
 */
export function fetch_add(ptr: *u32, delta: u32): u32 {
  unsafe { return atomic_fetch_add_u32_c(ptr, delta); }
  return 0 as u32; // unreachable — typeck workaround
}
/** Exported function `fetch_add`.
 * Implements `fetch_add`.
 * @param ptr *i64
 * @param delta i64
 * @return i64
 */
export function fetch_add(ptr: *i64, delta: i64): i64 {
  unsafe { return atomic_fetch_add_i64_c(ptr, delta); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `fetch_add`.
 * Implements `fetch_add`.
 * @param ptr *u64
 * @param delta u64
 * @return u64
 */
export function fetch_add(ptr: *u64, delta: u64): u64 {
  unsafe { return atomic_fetch_add_u64_c(ptr, delta); }
  return 0 as u64; // unreachable — typeck workaround
}
/** Exported function `fetch_add`.
 * Implements `fetch_add`.
 * @param ptr *i16
 * @param delta i16
 * @return i16
 */
export function fetch_add(ptr: *i16, delta: i16): i16 {
  unsafe { return atomic_fetch_add_i16_c(ptr, delta); }
  return 0 as i16; // unreachable — typeck workaround
}
/** Exported function `fetch_add`.
 * Implements `fetch_add`.
 * @param ptr *u16
 * @param delta u16
 * @return u16
 */
export function fetch_add(ptr: *u16, delta: u16): u16 {
  unsafe { return atomic_fetch_add_u16_c(ptr, delta); }
  return 0 as u16; // unreachable — typeck workaround
}

/** Exported function `fetch_sub`.
 * Implements `fetch_sub`.
 * @param ptr *i32
 * @param delta i32
 * @return i32
 */
export function fetch_sub(ptr: *i32, delta: i32): i32 {
  unsafe { return atomic_fetch_sub_i32_c(ptr, delta); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `fetch_sub`.
 * Implements `fetch_sub`.
 * @param ptr *i64
 * @param delta i64
 * @return i64
 */
export function fetch_sub(ptr: *i64, delta: i64): i64 {
  unsafe { return atomic_fetch_sub_i64_c(ptr, delta); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `fetch_sub`.
 * Implements `fetch_sub`.
 * @param ptr *u64
 * @param delta u64
 * @return u64
 */
export function fetch_sub(ptr: *u64, delta: u64): u64 {
  unsafe { return atomic_fetch_sub_u64_c(ptr, delta); }
  return 0 as u64; // unreachable — typeck workaround
}

/* See implementation. */

/** C11 memory_order_relaxed。 */
export const ORDER_RELAXED: i32 = 0;
/** C11 memory_order_acquire。 */
export const ORDER_ACQUIRE: i32 = 1;
/** C11 memory_order_release。 */
export const ORDER_RELEASE: i32 = 2;
/** C11 memory_order_acq_rel。 */
export const ORDER_ACQ_REL: i32 = 3;
/* See implementation. */
export const ORDER_SEQ_CST: i32 = 4;

extern "C" function atomic_fence_seq_cst_c(): void;
extern "C" function atomic_fence_acquire_c(): void;
extern "C" function atomic_fence_release_c(): void;

/** Exported function `fence_seq_cst`.
 * Implements `fence_seq_cst`.
 * @return void
 */
export function fence_seq_cst(): void {
  unsafe { atomic_fence_seq_cst_c(); }
}

/** Exported function `fence_acquire`.
 * Implements `fence_acquire`.
 * @return void
 */
export function fence_acquire(): void {
  unsafe { atomic_fence_acquire_c(); }
}

/** Exported function `fence_release`.
 * Implements `fence_release`.
 * @return void
 */
export function fence_release(): void {
  unsafe { atomic_fence_release_c(); }
}

/** Exported function `atomic_module_anchor`.
 * Implements `atomic_module_anchor`.
 * @return i32
 */
export function atomic_module_anchor(): i32 { return 0; }
