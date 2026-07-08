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

// std/hash/hash.x — F-hash v2：SipHash-2-4 / FNV-1a64 / xxHash64 纯 .x（替代 hash_glue.c）
//
// 【文件职责】
// Hasher 状态机：hash_sip_*、hash_unified_*、hash_xxhash64_*；
// SHUX_HASH_ALGO 环境默认；STD-056/105/148 烟测。
// 经 shux 编译为 hash.o；对外 API 在 mod.x。
//
// 【对标】Zig std.hash、Rust std::hash::Hasher。

const HASHER_SIPHASH: i32 = 0;
const HASHER_AHASH: i32 = 1;
const HASHER_XXHASH: i32 = 2;

/** C 字符串常量（解析器不支持 "..." as *u8）。 */
const HAS_LIT_N1: u8[2] = [49, 0];
const HAS_LIT_N2: u8[2] = [50, 0];
const HAS_LIT_SHUX_HASH_ALGO: u8[15] = [83, 72, 85, 88, 95, 72, 65, 83, 72, 95, 65, 76, 71, 79, 0];
const HAS_LIT_AHASH: u8[6] = [97, 104, 97, 115, 104, 0];
const HAS_LIT_X: u8[2] = [120, 0];
const HAS_LIT_XXHASH: u8[7] = [120, 120, 104, 97, 115, 104, 0];

const XXH64_PRIME1: u64 = 11400714785074694791 as u64;
const XXH64_PRIME2: u64 = 14029467366897019727 as u64;
const XXH64_PRIME3: u64 = 1609587929392839161 as u64;
const XXH64_PRIME4: u64 = 9650029242287828579 as u64;
const XXH64_PRIME5: u64 = 2870177450012600261 as u64;

const FNV1A64_OFFSET: u64 = 14695981039346656037 as u64;
const FNV1A64_PRIME: u64 = 1099511628211 as u64;

const HASH_SIP_CTX_SIZE: usize = 56;
const HASH_UNIFIED_CTX_SIZE: usize = 200;
const HASH_UNIFIED_SIP_OFF: usize = 8;
const HASH_UNIFIED_FNV_OFF: usize = 64;
const HASH_UNIFIED_XXH_OFF: usize = 72;

/** SipHash-2-4 流式状态。 */
allow(padding) struct HashSipCtx {
  v0: u64;
  v1: u64;
  v2: u64;
  v3: u64;
  buf: u8[8];
  buflen: i32;
  total_len: u64;
}

/** xxHash64 流式状态。 */
const HASH_XXH64_CTX_MEM64_OFF: usize = 40;

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

/** 统一 Hasher 上下文（.x 无 union，三族字段扁平存放）。 */
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

/** libc FFI 须 unsafe；集中薄包装，避免 hash_*_c 重复写 unsafe 块。 */
function hash_libc_memcpy(dst: *u8, src: *u8, n: usize): *u8 {
  unsafe { return memcpy(dst, src, n); }
}

/** xxHash64 流式 mem 区起始地址（offset 40 = mem64 字段）。 */
function hash_xxh64_mem_base(s: *HashXxh64Ctx): *u8 {
  return (s as *u8) + HASH_XXH64_CTX_MEM64_OFF;
}

/** F-hash v1 版本标记；供 v1 聚合 gate 校验。 */
function hash_f_hash_v1_marker_c(): i32 {
  return 1;
}

/** F-hash v2 逻辑全量 .x 标记。 */
function hash_f_hash_v2_marker_c(): i32 {
  return 1;
}

/** 统一上下文内 SipHash 子视图（与 HashSipCtx 布局一致，offset 8）。 */
function hash_unified_sip(u: *HashUnifiedCtx): *HashSipCtx {
  return (u as *u8 + HASH_UNIFIED_SIP_OFF) as *HashSipCtx;
}

/** 统一上下文内 xxHash 子视图（offset 72）。 */
function hash_unified_xxh(u: *HashUnifiedCtx): *HashXxh64Ctx {
  return (u as *u8 + HASH_UNIFIED_XXH_OFF) as *HashXxh64Ctx;
}

/** aHash/FNV 写入委托：勿 &u.fnv（field 取址 CALL 实参 asm emit 失败）。 */
function hash_unified_fnv_write_ptr_c(h: *u8, ptr: *u8, len: i32): void {
  let u: *HashUnifiedCtx = h as *HashUnifiedCtx;
  let i: i32 = 0;
  if (h == 0 || ptr == 0 || len <= 0) { return; }
  while (i < len) {
    u.fnv = u.fnv ^ (ptr[i] as u64);
    u.fnv = u.fnv * FNV1A64_PRIME;
    i = i + 1;
  }
}

/** 64 位循环左移（SipHash / xxHash 共用）。 */
function hash_rotl64(x: u64, s: i32): u64 {
  return (x << s) | (x >> (64 - s));
}

/** SipHash-2-4 单轮（v 为 4 元 u64 工作数组；勿 *u64 形参 + 解引用赋值）。 */
function hash_sipround_arr(v: u64[4]): void {
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

/** 小端读取 8 字节为 u64。 */
function hash_read64le(p: *u8): u64 {
  return (p[0] as u64)
    | ((p[1] as u64) << 8)
    | ((p[2] as u64) << 16)
    | ((p[3] as u64) << 24)
    | ((p[4] as u64) << 32)
    | ((p[5] as u64) << 40)
    | ((p[6] as u64) << 48)
    | ((p[7] as u64) << 56);
}

/** SipHash 压缩一块 64-bit 消息。 */
function hash_sip_compress(ctx: *HashSipCtx, m: u64): void {
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

/** 初始化 SipHash 向量（key 默认 0,0）。 */
function hash_sip_init(ctx: *HashSipCtx): void {
  ctx.v0 = 0x736f6d6570736575 as u64;
  ctx.v1 = 0x646f72616e646f6d as u64;
  ctx.v2 = 0x6c7967656e657261 as u64;
  ctx.v3 = 0x7465646279746573 as u64;
  ctx.buflen = 0;
  ctx.total_len = 0;
}

/** 创建 Hasher 状态；默认 key (0,0)。失败返回 0。 */
function hash_sip_new_c(): *u8 {
  unsafe {
    let ctx: *HashSipCtx = malloc(HASH_SIP_CTX_SIZE) as *HashSipCtx;
    if (ctx == 0) { return 0 as *u8; }
    hash_sip_init(ctx);
    return ctx as *u8;
  }
}

/** 写入任意字节到 SipHash 流。 */
function hash_sip_write_bytes_c(h: *u8, ptr: *u8, len: i32): void {
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

/** 写入 4 字节（小端）。 */
function hash_sip_write_u32_c(h: *u8, x: u32): void {
  let b: u8[4];
  if (h == 0) { return; }
  b[0] = (x as u8);
  b[1] = ((x >> 8) as u8);
  b[2] = ((x >> 16) as u8);
  b[3] = ((x >> 24) as u8);
  hash_sip_write_bytes_c(h, &b[0], 4);
}

/** 写入 8 字节（小端）。 */
function hash_sip_write_u64_c(h: *u8, x: u64): void {
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

/** 完成 SipHash，返回 64-bit 摘要。 */
function hash_sip_finish_c(h: *u8): u64 {
  let ctx: *HashSipCtx = h as *HashSipCtx;
  let len_bits: u64 = 0;
  let i: i32 = 0;
  let v0: u64 = 0;
  let v1: u64 = 0;
  let v2: u64 = 0;
  let v3: u64 = 0;
  if (ctx == 0) { return 0; }
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

/** 释放 Hasher 状态。 */
function hash_sip_free_c(h: *u8): void {
  unsafe {
    free(h);
  }
}

/** 一次性 SipHash-2-4（key 默认 0,0）。 */
function hash_sip_bytes_c(ptr: *u8, len: i32): u64 {
  let h: *u8 = hash_sip_new_c();
  let r: u64 = 0;
  if (h == 0) { return 0; }
  hash_sip_write_bytes_c(h, ptr, len);
  r = hash_sip_finish_c(h);
  hash_sip_free_c(h);
  return r;
}

/** xxHash64 单轮混合。 */
function hash_xxh64_round(acc: u64, input: u64): u64 {
  acc = acc + input * XXH64_PRIME2;
  acc = hash_rotl64(acc, 31);
  acc = acc * XXH64_PRIME1;
  return acc;
}

/** xxHash64 merge 轮。 */
function hash_xxh64_merge_round(acc: u64, val: u64): u64 {
  val = hash_xxh64_round(0, val);
  acc = acc ^ val;
  acc = acc * XXH64_PRIME1 + XXH64_PRIME4;
  return acc;
}

/** xxHash64 雪崩终混。 */
function hash_xxh64_avalanche(h64: u64): u64 {
  h64 = h64 ^ (h64 >> 33);
  h64 = h64 * XXH64_PRIME2;
  h64 = h64 ^ (h64 >> 29);
  h64 = h64 * XXH64_PRIME3;
  h64 = h64 ^ (h64 >> 32);
  return h64;
}

/** 重置 xxHash64 流式状态。 */
function hash_xxh64_reset(s: *HashXxh64Ctx, seed: u64): void {
  s.seed = seed;
  s.v1 = seed + XXH64_PRIME1 + XXH64_PRIME2;
  s.v2 = seed + XXH64_PRIME2;
  s.v3 = seed;
  s.v4 = seed - XXH64_PRIME1;
  s.total_len = 0;
  s.memsize = 0;
  s.mem64 = 0;
}

/** xxHash64 流式更新。 */
function hash_xxh64_update(s: *HashXxh64Ctx, input: *u8, len: usize): void {
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

/** xxHash64 流式完成。 */
function hash_xxh64_digest(s: *HashXxh64Ctx): u64 {
  let h64: u64 = 0;
  let p: *u8 = 0;
  let i: i32 = 0;
  if (s == 0) { return 0; }
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

/** xxHash 写入委托：首参为统一 Hasher 基址 *u8（经 HashUnifiedCtx 取 xxh 子视图）。 */
function hash_unified_xxh_write_ptr_c(h: *u8, ptr: *u8, len: i32): void {
  let u: *HashUnifiedCtx = h as *HashUnifiedCtx;
  hash_xxh64_update(hash_unified_xxh(u), ptr, len as usize);
}

/** xxHash 完成委托：经 hash_unified_xxh 取子视图，避免 h+offset 实参 typeck/asm 歧义。 */
function hash_unified_xxh_digest_ptr_c(h: *u8): u64 {
  let u: *HashUnifiedCtx = h as *HashUnifiedCtx;
  let r: u64 = hash_xxh64_digest(hash_unified_xxh(u));
  return r;
}

/** 一次性 xxHash64（指定 seed）。 */
function hash_xxhash64_seed_bytes_c(ptr: *u8, len: i32, seed: u64): u64 {
  let s: HashXxh64Ctx;
  hash_xxh64_reset(&s, seed);
  if (len > 0 && ptr != 0) {
    hash_xxh64_update(&s, ptr, len);
  }
  return hash_xxh64_digest(&s);
}

/** 一次性 xxHash64（seed=0）。 */
function hash_xxhash64_bytes_c(ptr: *u8, len: i32): u64 {
  return hash_xxhash64_seed_bytes_c(ptr, len, 0);
}


/** 读取 SHUX_HASH_ALGO 环境变量；默认 HASHER_SIPHASH。 */
function hash_default_algo_c(): i32 {
  unsafe {
    let v: *u8 = getenv(&HAS_LIT_SHUX_HASH_ALGO[0]);
    if (v == 0 || v[0] == 0) { return HASHER_SIPHASH; }
    if (strcmp(v, &HAS_LIT_N1[0]) == 0 || strcmp(v, &HAS_LIT_AHASH[0]) == 0) { return HASHER_AHASH; }
    if (strcmp(v, &HAS_LIT_N2[0]) == 0 || strcmp(v, &HAS_LIT_XXHASH[0]) == 0 || strcmp(v, &HAS_LIT_X[0]) == 0) {
      return HASHER_XXHASH;
    }
    return HASHER_SIPHASH;
  }
}

/** Map/Set 推荐 Hasher（SipHash，STD-148）。 */
function hash_recommend_hasher_map_c(): i32 {
  return HASHER_SIPHASH;
}

/** 内部去重/快速路径推荐 Hasher（xxHash64，STD-148）。 */
function hash_recommend_hasher_fast_c(): i32 {
  return HASHER_XXHASH;
}

/** 按算法创建统一 Hasher；失败 0。 */
function hash_unified_new_c(algo: i32): *u8 {
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

/** 统一 Hasher 写入字节。 */
function hash_unified_write_bytes_c(h: *u8, ptr: *u8, len: i32): void {
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

/** 统一 Hasher 写入 u32（小端）。 */
function hash_unified_write_u32_c(h: *u8, x: u32): void {
  let b: u8[4];
  b[0] = (x as u8);
  b[1] = ((x >> 8) as u8);
  b[2] = ((x >> 16) as u8);
  b[3] = ((x >> 24) as u8);
  hash_unified_write_bytes_c(h, &b[0], 4);
}

/** 统一 Hasher 完成并返回 u64 摘要。 */
function hash_unified_finish_c(h: *u8): u64 {
  let u: *HashUnifiedCtx = h as *HashUnifiedCtx;
  if (u == 0) { return 0; }
  if (u.algo == HASHER_SIPHASH) { return hash_sip_finish_c(hash_unified_sip(u) as *u8); }
  if (u.algo == HASHER_AHASH) { return u.fnv; }
  if (u.algo == HASHER_XXHASH) { return hash_unified_xxh_digest_ptr_c(h); }
  return 0;
}

/** 释放统一 Hasher。 */
function hash_unified_free_c(h: *u8): void {
  unsafe {
    free(h);
  }
}

/** STD-056 烟测：aHash("abc") 金样 + SipHash ≠ aHash。 */
function hash_hasher_switch_smoke_c(): i32 {
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

/** STD-105 烟测：xxHash64 空串与 abc 金样。 */
function hash_xxhash_smoke_c(): i32 {
  let abc: u8[4] = [97, 98, 99, 0];
  if (hash_xxhash64_bytes_c(0, 0) != 0xef46db3751d8e999 as u64) { return 1; }
  if (hash_xxhash64_bytes_c(&abc[0], 3) != 0x44bc2cf5ad770999 as u64) { return 2; }
  return 0;
}

/** STD-148 烟测：推荐 Hasher + 三族摘要互异。 */
function hash_default_strategy_smoke_c(): i32 {
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
