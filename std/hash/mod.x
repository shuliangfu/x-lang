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
// See implementation.
//
// See implementation.
// See implementation.
extern function hash_sip_new_c(): *u8;
extern function hash_sip_write_u32_c(h: *u8, x: u32): void;
extern function hash_sip_write_u64_c(h: *u8, x: u64): void;
extern function hash_sip_write_bytes_c(h: *u8, ptr: *u8, len: i32): void;
extern function hash_sip_finish_c(h: *u8): u64;
extern function hash_sip_free_c(h: *u8): void;
extern function hash_sip_bytes_c(ptr: *u8, len: i32): u64;
extern function hash_default_algo_c(): i32;
extern function hash_unified_new_c(algo: i32): *u8;
extern function hash_unified_write_bytes_c(h: *u8, ptr: *u8, len: i32): void;
extern function hash_unified_write_u32_c(h: *u8, x: u32): void;
extern function hash_unified_finish_c(h: *u8): u64;
extern function hash_unified_free_c(h: *u8): void;
extern function hash_xxhash64_bytes_c(ptr: *u8, len: i32): u64;
extern function hash_xxhash64_seed_bytes_c(ptr: *u8, len: i32, seed: u64): u64;
extern function hash_recommend_hasher_map_c(): i32;
extern function hash_recommend_hasher_fast_c(): i32;

/* See implementation. */
export const HASHER_SIPHASH: i32 = 0;
/* See implementation. */
export const HASHER_AHASH: i32 = 1;
/* See implementation. */
export const HASHER_XXHASH: i32 = 2;

/** Exported function `default_hasher`.
 * Implements `default_hasher`.
 * @return i32
 */
export function default_hasher(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = hash_default_algo_c(); }
  return _rc;
}

/** Exported function `recommend_hasher_map`.
 * Implements `recommend_hasher_map`.
 * @return i32
 */
export function recommend_hasher_map(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = hash_recommend_hasher_map_c(); }
  return _rc;
}

/** Exported function `recommend_hasher_fast`.
 * Implements `recommend_hasher_fast`.
 * @return i32
 */
export function recommend_hasher_fast(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = hash_recommend_hasher_fast_c(); }
  return _rc;
}

/** Exported function `start_algo`.
 * Implements `start_algo`.
 * @param algo i32
 * @return *u8
 */
export function start_algo(algo: i32): *u8 {
  let _rc: *u8 = 0;
  unsafe { _rc = hash_unified_new_c(algo); }
  return _rc;
}

/** Exported function `write_bytes_algo`.
 * Write path helper `write_bytes_algo`.
 * @param h *u8
 * @param ptr *u8
 * @param len i32
 * @return void
 */
export function write_bytes_algo(h: *u8, ptr: *u8, len: i32): void {
  unsafe {
    hash_unified_write_bytes_c(h, ptr, len);
  }
}

/** Exported function `write_algo`.
 * Write path helper `write_algo`.
 * @param h *u8
 * @param x u32
 * @return void
 */
export function write_algo(h: *u8, x: u32): void {
  unsafe {
    hash_unified_write_u32_c(h, x);
  }
}

/** Exported function `finish_algo`.
 * Implements `finish_algo`.
 * @param h *u8
 * @return u64
 */
export function finish_algo(h: *u8): u64 {
  let _rc: u64 = 0;
  unsafe { _rc = hash_unified_finish_c(h); }
  return _rc;
}

/** Exported function `free_algo`.
 * Memory management helper `free_algo`.
 * @param h *u8
 * @return void
 */
export function free_algo(h: *u8): void {
  unsafe {
    hash_unified_free_c(h);
  }
}

/** Exported function `start`.
 * Implements `start`.
 * @return *u8
 */
export function start(): *u8 {
  let _rc: *u8 = 0;
  unsafe { _rc = hash_sip_new_c(); }
  return _rc;
}

/** Exported function `write`.
 * Write path helper `write`.
 * @param h *u8
 * @param x u32
 * @return void
 */
export function write(h: *u8, x: u32): void {
  unsafe {
    hash_sip_write_u32_c(h, x);
  }
}

/** Exported function `write`.
 * Write path helper `write`.
 * @param h *u8
 * @param x u64
 * @return void
 */
export function write(h: *u8, x: u64): void {
  unsafe {
    hash_sip_write_u64_c(h, x);
  }
}

/** Exported function `write_bytes`.
 * Write path helper `write_bytes`.
 * @param h *u8
 * @param ptr *u8
 * @param len i32
 * @return void
 */
export function write_bytes(h: *u8, ptr: *u8, len: i32): void {
  unsafe {
    hash_sip_write_bytes_c(h, ptr, len);
  }
}

/** Exported function `finish`.
 * Implements `finish`.
 * @param h *u8
 * @return u64
 */
export function finish(h: *u8): u64 {
  let _rc: u64 = 0;
  unsafe { _rc = hash_sip_finish_c(h); }
  return _rc;
}

/** Exported function `free`.
 * Memory management helper `free`.
 * @param h *u8
 * @return void
 */
export function free(h: *u8): void {
  unsafe {
    hash_sip_free_c(h);
  }
}

/** Exported function `bytes`.
 * Implements `bytes`.
 * @param ptr *u8
 * @param len i32
 * @return u64
 */
export function bytes(ptr: *u8, len: i32): u64 {
  let _rc: u64 = 0;
  unsafe { _rc = hash_sip_bytes_c(ptr, len); }
  return _rc;
}

/** Exported function `xxhash64`.
 * Implements `xxhash64`.
 * @param ptr *u8
 * @param len i32
 * @return u64
 */
export function xxhash64(ptr: *u8, len: i32): u64 {
  let _rc: u64 = 0;
  unsafe { _rc = hash_xxhash64_bytes_c(ptr, len); }
  return _rc;
}

/** Exported function `xxhash64_seed`.
 * Implements `xxhash64_seed`.
 * @param ptr *u8
 * @param len i32
 * @param seed u64
 * @return u64
 */
export function xxhash64_seed(ptr: *u8, len: i32, seed: u64): u64 {
  let _rc: u64 = 0;
  unsafe { _rc = hash_xxhash64_seed_bytes_c(ptr, len, seed); }
  return _rc;
}
