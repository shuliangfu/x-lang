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

export const HASHER_SIPHASH: i32 = 0;
export const HASHER_AHASH: i32 = 1;
export const HASHER_XXHASH: i32 = 2;

/* See implementation. */
export const HAS_LIT_N1: u8[2] = [49, 0];
export const HAS_LIT_N2: u8[2] = [50, 0];
export const HAS_LIT_XLANG_HASH_ALGO: u8[15] = [83, 72, 85, 88, 95, 72, 65, 83, 72, 95, 65, 76, 71, 79, 0];
export const HAS_LIT_AHASH: u8[6] = [97, 104, 97, 115, 104, 0];
export const HAS_LIT_X: u8[2] = [120, 0];
export const HAS_LIT_XXHASH: u8[7] = [120, 120, 104, 97, 115, 104, 0];

export const XXH64_PRIME1: u64 = 11400714785074694791 as u64;
export const XXH64_PRIME2: u64 = 14029467366897019727 as u64;
export const XXH64_PRIME3: u64 = 1609587929392839161 as u64;
export const XXH64_PRIME4: u64 = 9650029242287828579 as u64;
export const XXH64_PRIME5: u64 = 2870177450012600261 as u64;

export const FNV1A64_OFFSET: u64 = 14695981039346656037 as u64;
export const FNV1A64_PRIME: u64 = 1099511628211 as u64;

export const HASH_SIP_CTX_SIZE: usize = 56;
export const HASH_UNIFIED_CTX_SIZE: usize = 200;
export const HASH_UNIFIED_SIP_OFF: usize = 8;
export const HASH_UNIFIED_FNV_OFF: usize = 64;
export const HASH_UNIFIED_XXH_OFF: usize = 72;

/* See implementation. */
allow(padding) struct HashSipCtx {
  v0: u64;
  v1: u64;
  v2: u64;
  v3: u64;
  buf: u8[8];
  buflen: i32;
  total_len: u64;
}

/* See implementation. */
export const HASH_XXH64_CTX_MEM64_OFF: usize = 40;

allow(padding) struct HashXxh64Ctx {
  total_len: u64;
  v1: u64;
  v2: u64;
  v3: u64;
  v4: u64;
  mem64: u64;
  memsize: u32;
  seed: u64;
}

/* See implementation. */
allow(padding) struct HashUnifiedCtx {
  algo: i32;
  sip_v0: u64;
  sip_v1: u64;
  sip_v2: u64;
  sip_v3: u64;
  sip_buf: u8[8];
  sip_buflen: i32;
  sip_total_len: u64;
  fnv: u64;
  xxh_total_len: u64;
  xxh_v1: u64;
  xxh_v2: u64;
  xxh_v3: u64;
  xxh_v4: u64;
  xxh_mem64: u64;
  xxh_memsize: u32;
  xxh_seed: u64;
}

extern "C" function malloc(size: usize): *u8;
extern "C" function free(ptr: *u8): void;
extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
extern "C" function getenv(name: *u8): *u8;
extern "C" function strcmp(a: *u8, b: *u8): i32;

/** Exported function `hash_libc_memcpy`.
 * Implements `hash_libc_memcpy`.
 * @param dst *u8
 * @param src *u8
 * @param n usize
 * @return *u8
 */
export function hash_libc_memcpy(dst: *u8, src: *u8, n: usize): *u8 {
  unsafe { return memcpy(dst, src, n); }
  return 0 as *u8; // unreachable — typeck workaround
}

/** Exported function `hash_xxh64_mem_base`.
 * Implements `hash_xxh64_mem_base`.
 * @param s *HashXxh64Ctx
 * @return *u8
 */
export function hash_xxh64_mem_base(s: *HashXxh64Ctx): *u8 {
  return (s as *u8) + HASH_XXH64_CTX_MEM64_OFF;
}

/** Exported function `hash_f_hash_v1_marker_c`.
 * Implements `hash_f_hash_v1_marker_c`.
 * @return i32
 */
export function hash_f_hash_v1_marker_c(): i32 {
  return 1;
}

/** Exported function `hash_f_hash_v2_marker_c`.
 * Implements `hash_f_hash_v2_marker_c`.
 * @return i32
 */
export function hash_f_hash_v2_marker_c(): i32 {
  return 1;
}

/** Exported function `hash_unified_sip`.
 * Implements `hash_unified_sip`.
 * @param u *HashUnifiedCtx
 * @return *HashSipCtx
 */
export function hash_unified_sip(u: *HashUnifiedCtx): *HashSipCtx {
  return (u as *u8 + HASH_UNIFIED_SIP_OFF) as *HashSipCtx;
}

/** Exported function `hash_unified_xxh`.
 * Implements `hash_unified_xxh`.
 * @param u *HashUnifiedCtx
 * @return *HashXxh64Ctx
 */
export function hash_unified_xxh(u: *HashUnifiedCtx): *HashXxh64Ctx {
  return (u as *u8 + HASH_UNIFIED_XXH_OFF) as *HashXxh64Ctx;
}

/** Exported function `hash_unified_fnv_write_ptr_c`.
 * Write path helper `hash_unified_fnv_write_ptr_c`.
 * @param h *u8
 * @param ptr *u8
 * @param len i32
 * @return void
 */
export function hash_unified_fnv_write_ptr_c(h: *u8, ptr: *u8, len: i32): void {
  let u: *HashUnifiedCtx = h as *HashUnifiedCtx;
  let i: i32 = 0;
  if (h == 0 || ptr == 0 || len <= 0) { return; }
  while (i < len) {
    u.fnv = u.fnv ^ (ptr[i] as u64);
    u.fnv = u.fnv * FNV1A64_PRIME;
    i = i + 1;
  }
}

/** Exported function `hash_rotl64`.
 * Implements `hash_rotl64`.
 * @param x u64
 * @param s i32
 * @return u64
 */
export function hash_rotl64(x: u64, s: i32): u64 {
  return (x << s) | (x >> (64 - s));
}

/** Exported function `hash_sipround_arr`.
 * Implements `hash_sipround_arr`.
 * @param v u64[4]
 * @return void
 */
export function hash_sipround_arr(v: u64[4]): void {
  let v0: u64 = v[0];
  let v1: u64 = v[1];
  let v2: u64 = v[2];
  let v3: u64 = v[3];
  v0 = v0 + v1;
  v2 = v2 + v3;
  v1 = hash_rotl64(v1, 13);
  v3 = hash_rotl64(v3, 16);
  v1 = v1 ^ v0;
  v3 = v3 ^ v2;
  v0 = hash_rotl64(v0, 32);
  v2 = v2 + v1;
  v0 = v0 + v3;
  v1 = hash_rotl64(v1, 17);
  v3 = hash_rotl64(v3, 21);
  v1 = v1 ^ v2;
  v3 = v3 ^ v0;
  v2 = hash_rotl64(v2, 32);
  v[0] = v0;
  v[1] = v1;
  v[2] = v2;
  v[3] = v3;
}

/** Exported function `hash_read64le`.
 * Read path helper `hash_read64le`.
 * @param p *u8
 * @return u64
 */
export function hash_read64le(p: *u8): u64 {
  return (p[0] as u64)
    | ((p[1] as u64) << 8)
    | ((p[2] as u64) << 16)
    | ((p[3] as u64) << 24)
    | ((p[4] as u64) << 32)
    | ((p[5] as u64) << 40)
    | ((p[6] as u64) << 48)
    | ((p[7] as u64) << 56);
}

/** Exported function `hash_sip_compress`.
 * Implements `hash_sip_compress`.
 * @param ctx *HashSipCtx
 * @param m u64
 * @return void
 */
export function hash_sip_compress(ctx: *HashSipCtx, m: u64): void {
  let v0: u64 = ctx.v0;
  let v1: u64 = ctx.v1;
  let v2: u64 = ctx.v2;
  let v3: u64 = ctx.v3;
  v3 = v3 ^ m;
  let vr: u64[4] = [0, 0, 0, 0];
  vr[0] = v0;
  vr[1] = v1;
  vr[2] = v2;
  vr[3] = v3;
  hash_sipround_arr(vr);
  hash_sipround_arr(vr);
  v0 = vr[0];
  v1 = vr[1];
  v2 = vr[2];
  v3 = vr[3];
  v0 = v0 ^ m;
  ctx.v0 = v0;
  ctx.v1 = v1;
  ctx.v2 = v2;
  ctx.v3 = v3;
}

/** Exported function `hash_sip_init`.
 * Implements `hash_sip_init`.
 * @param ctx *HashSipCtx
 * @return void
 */
export function hash_sip_init(ctx: *HashSipCtx): void {
  ctx.v0 = 0x736f6d6570736575 as u64;
  ctx.v1 = 0x646f72616e646f6d as u64;
  ctx.v2 = 0x6c7967656e657261 as u64;
  ctx.v3 = 0x7465646279746573 as u64;
  ctx.buflen = 0;
  ctx.total_len = 0;
}

/** Exported function `hash_sip_new_c`.
 * Implements `hash_sip_new_c`.
 * @return *u8
 */
export function hash_sip_new_c(): *u8 {
  unsafe {
    let ctx: *HashSipCtx = malloc(HASH_SIP_CTX_SIZE) as *HashSipCtx;
    if (ctx == 0) { return 0 as *u8; }
    hash_sip_init(ctx);
    return ctx as *u8;
  }
}

/** Exported function `hash_sip_write_bytes_c`.
 * Write path helper `hash_sip_write_bytes_c`.
 * @param h *u8
 * @param ptr *u8
 * @param len i32
 * @return void
 */
export function hash_sip_write_bytes_c(h: *u8, ptr: *u8, len: i32): void {
  let ctx: *HashSipCtx = h as *HashSipCtx;
  let i: i32 = 0;
  if (ctx == 0 || ptr == 0 || len <= 0) { return; }
  ctx.total_len = ctx.total_len + (len as u64);
  if (ctx.buflen > 0) {
    while (ctx.buflen < 8 && i < len) {
      ctx.buf[ctx.buflen] = ptr[i];
      ctx.buflen = ctx.buflen + 1;
      i = i + 1;
    }
    if (ctx.buflen == 8) {
      hash_sip_compress(ctx, hash_read64le(&ctx.buf[0]));
      ctx.buflen = 0;
    }
  }
  while (i + 8 <= len) {
    hash_sip_compress(ctx, hash_read64le(&ptr[i]));
    i = i + 8;
  }
  while (i < len) {
    ctx.buf[ctx.buflen] = ptr[i];
    ctx.buflen = ctx.buflen + 1;
    i = i + 1;
  }
}

/** Exported function `hash_sip_write_u32_c`.
 * Write path helper `hash_sip_write_u32_c`.
 * @param h *u8
 * @param x u32
 * @return void
 */
export function hash_sip_write_u32_c(h: *u8, x: u32): void {
  let b: u8[4];
  if (h == 0) { return; }
  b[0] = (x as u8);
  b[1] = ((x >> 8) as u8);
  b[2] = ((x >> 16) as u8);
  b[3] = ((x >> 24) as u8);
  hash_sip_write_bytes_c(h, &b[0], 4);
}

/** Exported function `hash_sip_write_u64_c`.
 * Write path helper `hash_sip_write_u64_c`.
 * @param h *u8
 * @param x u64
 * @return void
 */
export function hash_sip_write_u64_c(h: *u8, x: u64): void {
  let b: u8[8];
  if (h == 0) { return; }
  b[0] = (x as u8);
  b[1] = ((x >> 8) as u8);
  b[2] = ((x >> 16) as u8);
  b[3] = ((x >> 24) as u8);
  b[4] = ((x >> 32) as u8);
  b[5] = ((x >> 40) as u8);
  b[6] = ((x >> 48) as u8);
  b[7] = ((x >> 56) as u8);
  hash_sip_write_bytes_c(h, &b[0], 8);
}

/** Exported function `hash_sip_finish_c`.
 * Implements `hash_sip_finish_c`.
 * @param h *u8
 * @return u64
 */
export function hash_sip_finish_c(h: *u8): u64 {
  let ctx: *HashSipCtx = h as *HashSipCtx;
  let len_bits: u64 = 0;
  let i: i32 = 0;
  let v0: u64 = 0;
  let v1: u64 = 0;
  let v2: u64 = 0;
  let v3: u64 = 0;
  if (ctx == 0) { return 0 as u64; }
  len_bits = ctx.total_len * 8;
  i = ctx.buflen;
  while (i < 8) {
    ctx.buf[i] = (len_bits >> (i * 8)) as u8;
    i = i + 1;
  }
  hash_sip_compress(ctx, hash_read64le(&ctx.buf[0]));
  v0 = ctx.v0;
  v1 = ctx.v1;
  v2 = ctx.v2;
  v3 = ctx.v3;
  v2 = v2 ^ 0xff as u64;
  let vr: u64[4] = [0, 0, 0, 0];
  vr[0] = v0;
  vr[1] = v1;
  vr[2] = v2;
  vr[3] = v3;
  hash_sipround_arr(vr);
  hash_sipround_arr(vr);
  hash_sipround_arr(vr);
  hash_sipround_arr(vr);
  v0 = vr[0];
  v1 = vr[1];
  v2 = vr[2];
  v3 = vr[3];
  return v0 ^ v1 ^ v2 ^ v3;
}

/** Exported function `hash_sip_free_c`.
 * Memory management helper `hash_sip_free_c`.
 * @param h *u8
 * @return void
 */
export function hash_sip_free_c(h: *u8): void {
  unsafe {
    free(h);
  }
}

/** Exported function `hash_sip_bytes_c`.
 * Implements `hash_sip_bytes_c`.
 * @param ptr *u8
 * @param len i32
 * @return u64
 */
export function hash_sip_bytes_c(ptr: *u8, len: i32): u64 {
  let h: *u8 = hash_sip_new_c();
  let r: u64 = 0;
  if (h == 0) { return 0 as u64; }
  hash_sip_write_bytes_c(h, ptr, len);
  r = hash_sip_finish_c(h);
  hash_sip_free_c(h);
  return r;
}

/** Exported function `hash_xxh64_round`.
 * Implements `hash_xxh64_round`.
 * @param acc u64
 * @param input u64
 * @return u64
 */
export function hash_xxh64_round(acc: u64, input: u64): u64 {
  acc = acc + input * XXH64_PRIME2;
  acc = hash_rotl64(acc, 31);
  acc = acc * XXH64_PRIME1;
  return acc;
}

/** Exported function `hash_xxh64_merge_round`.
 * Implements `hash_xxh64_merge_round`.
 * @param acc u64
 * @param val u64
 * @return u64
 */
export function hash_xxh64_merge_round(acc: u64, val: u64): u64 {
  val = hash_xxh64_round(0, val);
  acc = acc ^ val;
  acc = acc * XXH64_PRIME1 + XXH64_PRIME4;
  return acc;
}

/** Exported function `hash_xxh64_avalanche`.
 * Implements `hash_xxh64_avalanche`.
 * @param h64 u64
 * @return u64
 */
export function hash_xxh64_avalanche(h64: u64): u64 {
  h64 = h64 ^ (h64 >> 33);
  h64 = h64 * XXH64_PRIME2;
  h64 = h64 ^ (h64 >> 29);
  h64 = h64 * XXH64_PRIME3;
  h64 = h64 ^ (h64 >> 32);
  return h64;
}

/** Exported function `hash_xxh64_reset`.
 * Implements `hash_xxh64_reset`.
 * @param s *HashXxh64Ctx
 * @param seed u64
 * @return void
 */
export function hash_xxh64_reset(s: *HashXxh64Ctx, seed: u64): void {
  s.seed = seed;
  s.v1 = seed + XXH64_PRIME1 + XXH64_PRIME2;
  s.v2 = seed + XXH64_PRIME2;
  s.v3 = seed;
  s.v4 = seed - XXH64_PRIME1;
  s.total_len = 0;
  s.memsize = 0;
  s.mem64 = 0;
}

/** Exported function `hash_xxh64_update`.
 * Implements `hash_xxh64_update`.
 * @param s *HashXxh64Ctx
 * @param input *u8
 * @param len usize
 * @return void
 */
export function hash_xxh64_update(s: *HashXxh64Ctx, input: *u8, len: usize): void {
  unsafe {
    let p: usize = 0;
    let buf: u8[32];
    if (s == 0 || (input == 0 && len > 0)) { return; }
    s.total_len = s.total_len + (len as u64);
    if ((s.memsize) + len < 32) {
      let mem_base: *u8 = hash_xxh64_mem_base(s);
      hash_libc_memcpy(&mem_base[s.memsize as i32], input, len);
      s.memsize = s.memsize + (len as u32);
      return;
    }
    if (s.memsize > 0) {
      let mem_base: *u8 = hash_xxh64_mem_base(s);
      hash_libc_memcpy(&buf[0], mem_base, s.memsize as usize);
      hash_libc_memcpy(&buf[s.memsize as i32], input, (32 as usize) - (s.memsize as usize));
      s.v1 = hash_xxh64_round(s.v1, hash_read64le(&buf[0]));
      s.v2 = hash_xxh64_round(s.v2, hash_read64le(&buf[8]));
      s.v3 = hash_xxh64_round(s.v3, hash_read64le(&buf[16]));
      s.v4 = hash_xxh64_round(s.v4, hash_read64le(&buf[24]));
      p = (32 as usize) - (s.memsize as usize);
      s.memsize = 0;
    }
    while (p + (32 as usize) <= len) {
      s.v1 = hash_xxh64_round(s.v1, hash_read64le(&input[p as i32]));
      s.v2 = hash_xxh64_round(s.v2, hash_read64le(&input[(p + 8) as i32]));
      s.v3 = hash_xxh64_round(s.v3, hash_read64le(&input[(p + 16) as i32]));
      s.v4 = hash_xxh64_round(s.v4, hash_read64le(&input[(p + 24) as i32]));
      p = p + (32 as usize);
    }
    if (p < len) {
      s.memsize = (len - p) as u32;
      hash_libc_memcpy(hash_xxh64_mem_base(s), &input[p as i32], (len - p));
    }
  }
}

/** Exported function `hash_xxh64_digest`.
 * Implements `hash_xxh64_digest`.
 * @param s *HashXxh64Ctx
 * @return u64
 */
export function hash_xxh64_digest(s: *HashXxh64Ctx): u64 {
  let h64: u64 = 0;
  let p: *u8 = 0;
  let i: i32 = 0;
  if (s == 0) { return 0 as u64; }
  if (s.total_len >= 32) {
    h64 = hash_rotl64(s.v1, 1) + hash_rotl64(s.v2, 7) + hash_rotl64(s.v3, 12)
      + hash_rotl64(s.v4, 18);
    h64 = hash_xxh64_merge_round(h64, s.v1);
    h64 = hash_xxh64_merge_round(h64, s.v2);
    h64 = hash_xxh64_merge_round(h64, s.v3);
    h64 = hash_xxh64_merge_round(h64, s.v4);
  } else {
    h64 = s.seed + XXH64_PRIME5;
  }
  h64 = h64 + s.total_len;
  p = hash_xxh64_mem_base(s);
  i = 0;
  while (i + 8 <= (s.memsize as i32)) {
    h64 = hash_xxh64_round(h64, hash_read64le(&p[i]));
    i = i + 8;
  }
  if (i + 4 <= (s.memsize as i32)) {
    h64 = h64 ^ (hash_read64le(&p[i]) & 0xffffffff as u64);
    h64 = hash_rotl64(h64, 23) * XXH64_PRIME2 + XXH64_PRIME3;
    i = i + 4;
  }
  while (i < (s.memsize as i32)) {
    h64 = h64 ^ ((p[i] as u64) * XXH64_PRIME5);
    h64 = hash_rotl64(h64, 11) * XXH64_PRIME1;
    i = i + 1;
  }
  return hash_xxh64_avalanche(h64);
}

/** Exported function `hash_unified_xxh_write_ptr_c`.
 * Write path helper `hash_unified_xxh_write_ptr_c`.
 * @param h *u8
 * @param ptr *u8
 * @param len i32
 * @return void
 */
export function hash_unified_xxh_write_ptr_c(h: *u8, ptr: *u8, len: i32): void {
  let u: *HashUnifiedCtx = h as *HashUnifiedCtx;
  hash_xxh64_update(hash_unified_xxh(u), ptr, len as usize);
}

/** Exported function `hash_unified_xxh_digest_ptr_c`.
 * Implements `hash_unified_xxh_digest_ptr_c`.
 * @param h *u8
 * @return u64
 */
export function hash_unified_xxh_digest_ptr_c(h: *u8): u64 {
  let u: *HashUnifiedCtx = h as *HashUnifiedCtx;
  let r: u64 = hash_xxh64_digest(hash_unified_xxh(u));
  return r;
}

/** Exported function `hash_xxhash64_seed_bytes_c`.
 * Implements `hash_xxhash64_seed_bytes_c`.
 * @param ptr *u8
 * @param len i32
 * @param seed u64
 * @return u64
 */
export function hash_xxhash64_seed_bytes_c(ptr: *u8, len: i32, seed: u64): u64 {
  let s: HashXxh64Ctx;
  hash_xxh64_reset(&s, seed);
  if (len > 0 && ptr != 0) {
    hash_xxh64_update(&s, ptr, len);
  }
  return hash_xxh64_digest(&s);
}

/** Exported function `hash_xxhash64_bytes_c`.
 * Implements `hash_xxhash64_bytes_c`.
 * @param ptr *u8
 * @param len i32
 * @return u64
 */
export function hash_xxhash64_bytes_c(ptr: *u8, len: i32): u64 {
  return hash_xxhash64_seed_bytes_c(ptr, len, 0);
}


/** Exported function `hash_default_algo_c`.
 * Implements `hash_default_algo_c`.
 * @return i32
 */
export function hash_default_algo_c(): i32 {
  unsafe {
    let v: *u8 = getenv(&HAS_LIT_XLANG_HASH_ALGO[0]);
    if (v == 0 || v[0] == 0) { return HASHER_SIPHASH; }
    if (strcmp(v, &HAS_LIT_N1[0]) == 0 || strcmp(v, &HAS_LIT_AHASH[0]) == 0) { return HASHER_AHASH; }
    if (strcmp(v, &HAS_LIT_N2[0]) == 0 || strcmp(v, &HAS_LIT_XXHASH[0]) == 0 || strcmp(v, &HAS_LIT_X[0]) == 0) {
      return HASHER_XXHASH;
    }
    return HASHER_SIPHASH;
  }
}

/** Exported function `hash_recommend_hasher_map_c`.
 * Implements `hash_recommend_hasher_map_c`.
 * @return i32
 */
export function hash_recommend_hasher_map_c(): i32 {
  return HASHER_SIPHASH;
}

/** Exported function `hash_recommend_hasher_fast_c`.
 * Implements `hash_recommend_hasher_fast_c`.
 * @return i32
 */
export function hash_recommend_hasher_fast_c(): i32 {
  return HASHER_XXHASH;
}

/** Exported function `hash_unified_new_c`.
 * Implements `hash_unified_new_c`.
 * @param algo i32
 * @return *u8
 */
export function hash_unified_new_c(algo: i32): *u8 {
  unsafe {
    let u: *HashUnifiedCtx = malloc(HASH_UNIFIED_CTX_SIZE) as *HashUnifiedCtx;
    if (u == 0) { return 0 as *u8; }
    u.algo = algo;
    if (algo == HASHER_SIPHASH) {
      hash_sip_init(hash_unified_sip(u));
    } else if (algo == HASHER_AHASH) {
      u.fnv = FNV1A64_OFFSET;
    } else if (algo == HASHER_XXHASH) {
      hash_xxh64_reset(hash_unified_xxh(u), 0);
    } else {
      free(u as *u8);
      return 0 as *u8;
    }
    return u as *u8;
  }
}

/** Exported function `hash_unified_write_bytes_c`.
 * Write path helper `hash_unified_write_bytes_c`.
 * @param h *u8
 * @param ptr *u8
 * @param len i32
 * @return void
 */
export function hash_unified_write_bytes_c(h: *u8, ptr: *u8, len: i32): void {
  let u: *HashUnifiedCtx = h as *HashUnifiedCtx;
  if (u == 0 || ptr == 0 || len <= 0) { return; }
  if (u.algo == HASHER_SIPHASH) {
    hash_sip_write_bytes_c(hash_unified_sip(u) as *u8, ptr, len);
  } else if (u.algo == HASHER_AHASH) {
    hash_unified_fnv_write_ptr_c(h, ptr, len);
  } else if (u.algo == HASHER_XXHASH) {
    hash_unified_xxh_write_ptr_c(h, ptr, len);
  }
}

/** Exported function `hash_unified_write_u32_c`.
 * Write path helper `hash_unified_write_u32_c`.
 * @param h *u8
 * @param x u32
 * @return void
 */
export function hash_unified_write_u32_c(h: *u8, x: u32): void {
  let b: u8[4];
  b[0] = (x as u8);
  b[1] = ((x >> 8) as u8);
  b[2] = ((x >> 16) as u8);
  b[3] = ((x >> 24) as u8);
  hash_unified_write_bytes_c(h, &b[0], 4);
}

/** Exported function `hash_unified_finish_c`.
 * Implements `hash_unified_finish_c`.
 * @param h *u8
 * @return u64
 */
export function hash_unified_finish_c(h: *u8): u64 {
  let u: *HashUnifiedCtx = h as *HashUnifiedCtx;
  if (u == 0) { return 0 as u64; }
  if (u.algo == HASHER_SIPHASH) { return hash_sip_finish_c(hash_unified_sip(u) as *u8); }
  if (u.algo == HASHER_AHASH) { return u.fnv; }
  if (u.algo == HASHER_XXHASH) { return hash_unified_xxh_digest_ptr_c(h); }
  return 0 as u64;
}

/** Exported function `hash_unified_free_c`.
 * Memory management helper `hash_unified_free_c`.
 * @param h *u8
 * @return void
 */
export function hash_unified_free_c(h: *u8): void {
  unsafe {
    free(h);
  }
}

/** Exported function `hash_hasher_switch_smoke_c`.
 * Implements `hash_hasher_switch_smoke_c`.
 * @return i32
 */
export function hash_hasher_switch_smoke_c(): i32 {
  let abc: u8[4] = [97, 98, 99, 0];
  let ha: *u8 = 0;
  let hs: *u8 = 0;
  let ra: u64 = 0;
  let rs: u64 = 0;
  ha = hash_unified_new_c(HASHER_AHASH);
  if (ha == 0) { return 1; }
  hash_unified_write_bytes_c(ha, &abc[0], 3);
  ra = hash_unified_finish_c(ha);
  hash_unified_free_c(ha);
  if (ra != 0xe71fa2190541574b as u64) { return 2; }
  hs = hash_unified_new_c(HASHER_SIPHASH);
  if (hs == 0) { return 3; }
  hash_unified_write_bytes_c(hs, &abc[0], 3);
  rs = hash_unified_finish_c(hs);
  hash_unified_free_c(hs);
  if (rs == ra) { return 4; }
  return 0;
}

/** Exported function `hash_xxhash_smoke_c`.
 * Implements `hash_xxhash_smoke_c`.
 * @return i32
 */
export function hash_xxhash_smoke_c(): i32 {
  let abc: u8[4] = [97, 98, 99, 0];
  if (hash_xxhash64_bytes_c(0, 0) != 0xef46db3751d8e999 as u64) { return 1; }
  if (hash_xxhash64_bytes_c(&abc[0], 3) != 0x44bc2cf5ad770999 as u64) { return 2; }
  return 0;
}

/** Exported function `hash_default_strategy_smoke_c`.
 * Implements `hash_default_strategy_smoke_c`.
 * @return i32
 */
export function hash_default_strategy_smoke_c(): i32 {
  let abc: u8[4] = [97, 98, 99, 0];
  let hs: *u8 = 0;
  let ha: *u8 = 0;
  let hx: *u8 = 0;
  let rs: u64 = 0;
  let ra: u64 = 0;
  let rx: u64 = 0;
  if (hash_recommend_hasher_map_c() != HASHER_SIPHASH) { return 1; }
  if (hash_recommend_hasher_fast_c() != HASHER_XXHASH) { return 2; }
  if (hash_default_algo_c() != HASHER_SIPHASH) { return 3; }
  hs = hash_unified_new_c(HASHER_SIPHASH);
  ha = hash_unified_new_c(HASHER_AHASH);
  hx = hash_unified_new_c(HASHER_XXHASH);
  if (hs == 0 || ha == 0 || hx == 0) { return 4; }
  hash_unified_write_bytes_c(hs, &abc[0], 3);
  hash_unified_write_bytes_c(ha, &abc[0], 3);
  hash_unified_write_bytes_c(hx, &abc[0], 3);
  rs = hash_unified_finish_c(hs);
  ra = hash_unified_finish_c(ha);
  rx = hash_unified_finish_c(hx);
  hash_unified_free_c(hs);
  hash_unified_free_c(ha);
  hash_unified_free_c(hx);
  if (rs == 0 || ra == 0 || rx == 0) { return 5; }
  if (rs == ra || rs == rx || ra == rx) { return 6; }
  if (hash_xxhash64_bytes_c(&abc[0], 3) != rx) { return 7; }
  return 0;
}
