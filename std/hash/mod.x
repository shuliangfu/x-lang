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

// std.hash — Hasher 抽象与 SipHash-2-4（对标 Zig std.hash、Rust std::hash::Hasher）
// STD-056：统一 Hasher 工厂 start_algo / default_hasher / SHUX_HASH_ALGO。
//
// 【文件职责】start、write/write_bytes、finish、free；单次 bytes。Tier-S 稳定 API 始终 SipHash。
// 【依赖】core；算法在 std/hash/hash.x（F-hash v2 纯 .x）。
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

/** SipHash（抗碰撞，Tier-S 默认）。 */
export const HASHER_SIPHASH: i32 = 0;
/** FNV-1a64 占位 aHash（快速路径预研）。 */
export const HASHER_AHASH: i32 = 1;
/** xxHash64（非对抗快速路径，STD-105）。 */
export const HASHER_XXHASH: i32 = 2;

/** 读取 SHUX_HASH_ALGO 环境变量，返回默认 Hasher 算法 id。 */
export function default_hasher(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = hash_default_algo_c(); }
  return _rc;
}

/** Map/Set 场景推荐 Hasher（SipHash）。 */
export function recommend_hasher_map(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = hash_recommend_hasher_map_c(); }
  return _rc;
}

/** 内部去重/checksum 推荐 Hasher（xxHash64）。 */
export function recommend_hasher_fast(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = hash_recommend_hasher_fast_c(); }
  return _rc;
}

/** 按算法创建 Hasher 状态；失败返回 0。 */
export function start_algo(algo: i32): *u8 {
  let _rc: *u8 = 0;
  unsafe { _rc = hash_unified_new_c(algo); }
  return _rc;
}

/** 向 algo Hasher 写入字节 ptr[0..len)。 */
export function write_bytes_algo(h: *u8, ptr: *u8, len: i32): void {
  unsafe {
    hash_unified_write_bytes_c(h, ptr, len);
  }
}

/** 向 algo Hasher 写入 u32（小端）。 */
export function write_algo(h: *u8, x: u32): void {
  unsafe {
    hash_unified_write_u32_c(h, x);
  }
}

/** 完成 algo Hasher，返回 u64 摘要。 */
export function finish_algo(h: *u8): u64 {
  let _rc: u64 = 0;
  unsafe { _rc = hash_unified_finish_c(h); }
  return _rc;
}

/** 释放 algo Hasher 状态。 */
export function free_algo(h: *u8): void {
  unsafe {
    hash_unified_free_c(h);
  }
}

/** 创建 Hasher 状态（Tier-S：恒 SipHash）；失败返回 0。 */
export function start(): *u8 {
  let _rc: *u8 = 0;
  unsafe { _rc = hash_sip_new_c(); }
  return _rc;
}

/** 写入 u32（小端）。 */
export function write(h: *u8, x: u32): void {
  unsafe {
    hash_sip_write_u32_c(h, x);
  }
}

/** 写入 u64（小端）。 */
export function write(h: *u8, x: u64): void {
  unsafe {
    hash_sip_write_u64_c(h, x);
  }
}

/** 写入字节 ptr[0..len)。 */
export function write_bytes(h: *u8, ptr: *u8, len: i32): void {
  unsafe {
    hash_sip_write_bytes_c(h, ptr, len);
  }
}

/** 完成哈希，返回 u64；调用后 h 仍可继续写。 */
export function finish(h: *u8): u64 {
  let _rc: u64 = 0;
  unsafe { _rc = hash_sip_finish_c(h); }
  return _rc;
}

/** 释放 Hasher 状态。 */
export function free(h: *u8): void {
  unsafe {
    hash_sip_free_c(h);
  }
}

/** 单次对 ptr[0..len) 做 SipHash-2-4，返回 u64。 */
export function bytes(ptr: *u8, len: i32): u64 {
  let _rc: u64 = 0;
  unsafe { _rc = hash_sip_bytes_c(ptr, len); }
  return _rc;
}

/** 一次性 xxHash64（seed=0）。 */
export function xxhash64(ptr: *u8, len: i32): u64 {
  let _rc: u64 = 0;
  unsafe { _rc = hash_xxhash64_bytes_c(ptr, len); }
  return _rc;
}

/** 一次性 xxHash64（指定 seed）。 */
export function xxhash64_seed(ptr: *u8, len: i32, seed: u64): u64 {
  let _rc: u64 = 0;
  unsafe { _rc = hash_xxhash64_seed_bytes_c(ptr, len, seed); }
  return _rc;
}
