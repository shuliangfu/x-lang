// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

export extern "C" function xlang_sha256_rotr32_impl(x: u32, n: u32): u32;
export extern "C" function xlang_sha256_ch_impl(x: u32, y: u32, z: u32): u32;
export extern "C" function xlang_sha256_maj_impl(x: u32, y: u32, z: u32): u32;
export extern "C" function xlang_sha256_block_impl(H: *u32, block: *u8): void;

/** Exported function `runtime_crypto_inc_glue_x_doc_anchor`.
 * Implements `runtime_crypto_inc_glue_x_doc_anchor`.
 * @return i32
 */
export function runtime_crypto_inc_glue_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */




#[no_mangle]
export function xlang_sha256_block(H: *u32, block: *u8): void {
  unsafe {
    xlang_sha256_block_impl(H, block);
  }
}

// xlang_sha256_rotr32: see function docblock below.

/** Exported function `xlang_sha256_rotr32`.
 * Implements `xlang_sha256_rotr32`.
 * @param x u32
 * @param n u32
 * @return u32
 */
#[no_mangle]
export function xlang_sha256_rotr32(x: u32, n: u32): u32 {
  n = n & 31;
  return (x >> n) | (x << (32 - n));
}

/** Exported function `xlang_sha256_ch`.
 * Implements `xlang_sha256_ch`.
 * @param x u32
 * @param y u32
 * @param z u32
 * @return u32
 */
#[no_mangle]
export function xlang_sha256_ch(x: u32, y: u32, z: u32): u32 {
  return (x & y) ^ ((~x) & z);
}

/** Exported function `xlang_sha256_maj`.
 * Implements `xlang_sha256_maj`.
 * @param x u32
 * @param y u32
 * @param z u32
 * @return u32
 */
#[no_mangle]
export function xlang_sha256_maj(x: u32, y: u32, z: u32): u32 {
  return (x & y) ^ (x & z) ^ (y & z);
}

// crypto_i32_sub_c: see function docblock below.

/** Exported function `crypto_i32_sub_c`.
 * Implements `crypto_i32_sub_c`.
 * @param a i32
 * @param b i32
 * @return i32
 */
#[no_mangle]
export function crypto_i32_sub_c(a: i32, b: i32): i32 {
  return a - b;
}

/** Exported function `crypto_rotl32_c`.
 * Implements `crypto_rotl32_c`.
 * @param x u32
 * @param n u32
 * @return u32
 */
#[no_mangle]
export function crypto_rotl32_c(x: u32, n: u32): u32 {
  n = n & 31;
  return (x << n) | (x >> (32 - n));
}
