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

// runtime_crypto_inc_glue_darwin.x — Darwin arm64 body for
// runtime_crypto_inc_glue.o.
//
// The cold ensure path pure-asms src/asm/runtime_crypto_inc_glue.x
// (the public wrappers) and this file (SHA-256, HMAC, and the lookup
// tables), then ld -r. It does not pass
// seeds/runtime_crypto_inc_glue.from_x.c to host cc.
// Linux and Windows keep that C seed.
//
// A 64-way if-return does not emit on this compiler, and a C string
// cannot hold an interior 0 byte, so the AES S-box and the SHA-256 K
// table are hex text in 64-character pieces. A 256-byte stack array
// does not fit this frame, so the message schedule and the HMAC
// buffers are malloc'd. Each function keeps a single loop. An index
// is copied into a local before the load or store. This compiler
// sizes a frame short of its last spill, so a function whose store
// lands at or past the frame is split (sigma0/sigma1, the HMAC copy).
//
// SHA-512 still calls ed25519_ref10_sha512. That symbol lives in the
// ed25519 object.
//
// This object is a user companion. It is not in the g05 compiler
// image. A missing object after pure-asm faults falls back to the
// C seed.
//
// PLATFORM: MACOS|DARWIN arm64.

/**
 * Byte copy.
 * @param d *u8 — destination
 * @param s *u8 — source
 * @param n i64 — byte count
 * @return *u8 — destination
 * PLATFORM: POSIX
 */
export extern "C" function memcpy(d: *u8, s: *u8, n: i64): *u8;

/**
 * Fill bytes with a value.
 * @param d *u8 — destination
 * @param c i32 — byte value
 * @param n i64 — count
 * @return *u8 — destination
 * PLATFORM: POSIX
 */
export extern "C" function memset(d: *u8, c: i32, n: i64): *u8;

/**
 * Heap buffer.
 * @param n i64 — byte count
 * @return *u8 — buffer, or null
 * PLATFORM: POSIX
 */
export extern "C" function malloc(n: i64): *u8;

/**
 * Release a buffer from malloc.
 * @param p *u8 — buffer, or null
 * PLATFORM: POSIX
 */
export extern "C" function free(p: *u8): void;

/**
 * SHA-512 from the ed25519 ref10 object.
 * @param message *u8 — bytes
 * @param message_len usize — count
 * @param out *u8 — 64-byte digest
 * @return i32 — 0 on success
 * PLATFORM: SHARED
 */
export extern "C" function ed25519_ref10_sha512(message: *u8, message_len: usize, out: *u8): i32;

/**
 * Hex digit value. Other bytes return 0.
 * @param c u8 — ASCII hex digit
 * @return i32 — 0..15
 * PLATFORM: MACOS|DARWIN
 */
function crypto_hex_val(c: u8): i32 {
  if (c >= 48 as u8 && c <= 57 as u8) {
    return (c as i32) - 48;
  }
  if (c >= 97 as u8 && c <= 102 as u8) {
    return (c as i32) - 87;
  }
  return 0;
}

/**
 * Decode one byte from a hex string. i is a byte index, so the
 * characters sit at i*2.
 * @param s *u8 — hex text
 * @param i i32 — byte index
 * @return u8 — decoded byte
 * PLATFORM: MACOS|DARWIN
 */
function crypto_hex_byte(s: *u8, i: i32): u8 {
  let j: i32 = i * 2;
  let hi: i32 = crypto_hex_val(s[j]);
  let lo: i32 = crypto_hex_val(s[j + 1]);
  return ((hi * 16) + lo) as u8;
}

/**
 * Load a big-endian u32 from a hex string at byte index i.
 * @param s *u8 — hex text
 * @param i i32 — byte index of the first byte
 * @return u32 — big-endian word
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
function crypto_hex_u32(s: *u8, i: i32): u32 {
  // A live pad pulls the edge store inside this frame.
  // The unpadded store sat eight bytes past the allocation.
  let frame_pad: u8[64] = [];
  frame_pad[0] = 0;
  let b0: u32 = crypto_hex_byte(s, i) as u32;
  let b1: u32 = crypto_hex_byte(s, i + 1) as u32;
  let b2: u32 = crypto_hex_byte(s, i + 2) as u32;
  let b3: u32 = crypto_hex_byte(s, i + 3) as u32;
  return (b0 << 24) | (b1 << 16) | (b2 << 8) | b3;
}

/**
 * AES S-box byte. idx outside 0..255 returns 0.
 * The table is eight 32-byte hex pieces.
 * @param idx i32 — 0..255
 * @return u8 — S-box byte
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function crypto_aes_sbox_byte_c(idx: i32): u8 {
  if (idx < 0 || idx > 255) {
    return 0 as u8;
  }
  let chunk: i32 = idx / 32;
  let at: i32 = idx - chunk * 32;
  if (chunk == 0) {
    return crypto_hex_byte("637c777bf26b6fc53001672bfed7ab76ca82c97dfa5947f0add4a2af9ca472c0", at);
  }
  if (chunk == 1) {
    return crypto_hex_byte("b7fd9326363ff7cc34a5e5f171d8311504c723c31896059a071280e2eb27b275", at);
  }
  if (chunk == 2) {
    return crypto_hex_byte("09832c1a1b6e5aa0523bd6b329e32f8453d100ed20fcb15b6acbbe394a4c58cf", at);
  }
  if (chunk == 3) {
    return crypto_hex_byte("d0efaafb434d338545f9027f503c9fa851a3408f929d38f5bcb6da2110fff3d2", at);
  }
  if (chunk == 4) {
    return crypto_hex_byte("cd0c13ec5f974417c4a77e3d645d197360814fdc222a908846eeb814de5e0bdb", at);
  }
  if (chunk == 5) {
    return crypto_hex_byte("e0323a0a4906245cc2d3ac629195e479e7c8376d8dd54ea96c56f4ea657aae08", at);
  }
  if (chunk == 6) {
    return crypto_hex_byte("ba78252e1ca6b4c6e8dd741f4bbd8b8a703eb5664803f60e613557b986c11d9e", at);
  }
  return crypto_hex_byte("e1f8981169d98e949b1e87e9ce5528df8ca1890dbfe6426841992d0fb054bb16", at);
}

/**
 * AES Rcon byte. idx outside 0..9 returns 0.
 * @param idx i32 — 0..9
 * @return u8 — Rcon byte
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function crypto_aes_rcon_byte_c(idx: i32): u8 {
  if (idx < 0 || idx > 9) {
    return 0 as u8;
  }
  return crypto_hex_byte("01020408102040801b36", idx);
}

/**
 * ChaCha20 sigma byte. The text is "expand 32-byte k".
 * idx outside 0..15 returns 0.
 * @param idx i32 — 0..15
 * @return u8 — sigma byte
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function crypto_chacha_sigma_byte_c(idx: i32): u8 {
  if (idx < 0 || idx > 15) {
    return 0 as u8;
  }
  let s: *u8 = "expand 32-byte k";
  let j: i32 = idx;
  return s[j];
}

/**
 * SHA-256 round constant. i outside 0..63 returns 0.
 * Eight words per 64-character hex piece.
 * @param i i32 — 0..63
 * @return u32 — K256[i]
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function crypto_sha256_k256_c(i: i32): u32 {
  if (i < 0 || i > 63) {
    return 0;
  }
  let chunk: i32 = i / 8;
  let at: i32 = (i - chunk * 8) * 4;
  if (chunk == 0) {
    return crypto_hex_u32("428a2f9871374491b5c0fbcfe9b5dba53956c25b59f111f1923f82a4ab1c5ed5", at);
  }
  if (chunk == 1) {
    return crypto_hex_u32("d807aa9812835b01243185be550c7dc372be5d7480deb1fe9bdc06a7c19bf174", at);
  }
  if (chunk == 2) {
    return crypto_hex_u32("e49b69c1efbe47860fc19dc6240ca1cc2de92c6f4a7484aa5cb0a9dc76f988da", at);
  }
  if (chunk == 3) {
    return crypto_hex_u32("983e5152a831c66db00327c8bf597fc7c6e00bf3d5a7914706ca635114292967", at);
  }
  if (chunk == 4) {
    return crypto_hex_u32("27b70a852e1b21384d2c6dfc53380d13650a7354766a0abb81c2c92e92722c85", at);
  }
  if (chunk == 5) {
    return crypto_hex_u32("a2bfe8a1a81a664bc24b8b70c76c51a3d192e819d6990624f40e3585106aa070", at);
  }
  if (chunk == 6) {
    return crypto_hex_u32("19a4c1161e376c082748774c34b0bcb5391c0cb34ed8aa4a5b9cca4f682e6ff3", at);
  }
  return crypto_hex_u32("748f82ee78a5636f84c878148cc7020890befffaa4506cebbef9a3f7c67178f2", at);
}

/**
 * Right rotate. A shift of 0 returns x. n is reduced mod 32.
 * @param x u32 — value
 * @param n u32 — rotate count
 * @return u32 — rotated value
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sha256_rotr32_impl(x: u32, n: u32): u32 {
  let k: u32 = n & 31;
  if (k == 0) {
    return x;
  }
  let sh: u32 = 32 - k;
  return (x >> k) | (x << sh);
}

/**
 * Same rotate as xlang_sha256_rotr32_impl. Public name used by callers
 * that do not go through the thin wrapper.
 * @param x u32 — value
 * @param n u32 — rotate count
 * @return u32 — rotated value
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function crypto_rotr32_c(x: u32, n: u32): u32 {
  return xlang_sha256_rotr32_impl(x, n);
}

/**
 * Left rotate. A shift of 0 returns x. n is reduced mod 32.
 * @param x u32 — value
 * @param n u32 — rotate count
 * @return u32 — rotated value
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function crypto_rotl32_impl(x: u32, n: u32): u32 {
  let k: u32 = n & 31;
  if (k == 0) {
    return x;
  }
  let sh: u32 = 32 - k;
  return (x << k) | (x >> sh);
}

/**
 * SHA-256 Ch. Bitwise not is xor with 2^32-1.
 * @param x u32 — first word
 * @param y u32 — second word
 * @param z u32 — third word
 * @return u32 — Ch(x, y, z)
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sha256_ch_impl(x: u32, y: u32, z: u32): u32 {
  return (x & y) ^ ((x ^ 4294967295) & z);
}

/**
 * SHA-256 Maj.
 * @param x u32 — first word
 * @param y u32 — second word
 * @param z u32 — third word
 * @return u32 — Maj(x, y, z)
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sha256_maj_impl(x: u32, y: u32, z: u32): u32 {
  return (x & y) ^ (x & z) ^ (y & z);
}

/**
 * Signed subtraction.
 * @param a i32 — left
 * @param b i32 — right
 * @return i32 — a - b
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function crypto_i32_sub_impl(a: i32, b: i32): i32 {
  return a - b;
}

/**
 * Bytes of padding needed to reach the next 16-byte boundary.
 * used 0 returns 16. used 1 returns 15.
 * @param used i32 — bytes already used in the block
 * @return i32 — 16 - (used & 15)
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function crypto_block16_fill_c(used: i32): i32 {
  return 16 - (used & 15);
}

/**
 * Load one schedule word. The index is a local.
 * @param w *u32 — 64-word schedule
 * @param i i32 — index
 * @return u32 — word
 * PLATFORM: MACOS|DARWIN
 */
function crypto_w_load(w: *u32, i: i32): u32 {
  let j: i32 = i;
  return w[j];
}

/**
 * Store one schedule word. The index is a local.
 * @param w *u32 — 64-word schedule
 * @param i i32 — index
 * @param v u32 — word
 * PLATFORM: MACOS|DARWIN
 */
function crypto_w_store(w: *u32, i: i32, v: u32): void {
  let j: i32 = i;
  w[j] = v;
}

/**
 * Load the first 16 schedule words from a 64-byte block.
 * @param w *u32 — schedule
 * @param block *u8 — 64 bytes
 * PLATFORM: MACOS|DARWIN
 */
function crypto_sha256_load16(w: *u32, block: *u8): void {
  let i: i32 = 0;
  while (i < 16) {
    let bi: i32 = i * 4;
    let b0: u32 = block[bi] as u32;
    let b1: u32 = block[bi + 1] as u32;
    let b2: u32 = block[bi + 2] as u32;
    let b3: u32 = block[bi + 3] as u32;
    let v: u32 = (b0 << 24) | (b1 << 16) | (b2 << 8) | b3;
    crypto_w_store(w, i, v);
    i = i + 1;
  }
}

/**
 * SHA-256 message-schedule sigma0. Split out so expand's frame covers
 * its own slots.
 * @param x u32 — w[i-15]
 * @return u32 — ROTR7 ^ ROTR18 ^ SHR3
 * PLATFORM: MACOS|DARWIN
 */
function crypto_sha256_small_sigma0(x: u32): u32 {
  let r7: u32 = xlang_sha256_rotr32_impl(x, 7);
  let r18: u32 = xlang_sha256_rotr32_impl(x, 18);
  return r7 ^ r18 ^ (x >> 3);
}

/**
 * SHA-256 message-schedule sigma1.
 * @param x u32 — w[i-2]
 * @return u32 — ROTR17 ^ ROTR19 ^ SHR10
 * PLATFORM: MACOS|DARWIN
 */
function crypto_sha256_small_sigma1(x: u32): u32 {
  let r17: u32 = xlang_sha256_rotr32_impl(x, 17);
  let r19: u32 = xlang_sha256_rotr32_impl(x, 19);
  return r17 ^ r19 ^ (x >> 10);
}

/**
 * Expand schedule words 16..63.
 * @param w *u32 — schedule, first 16 words already stored
 * PLATFORM: MACOS|DARWIN
 */
function crypto_sha256_expand(w: *u32): void {
  let i: i32 = 16;
  while (i < 64) {
    let im2: i32 = i - 2;
    let im7: i32 = i - 7;
    let im15: i32 = i - 15;
    let im16: i32 = i - 16;
    let w2: u32 = crypto_w_load(w, im2);
    let w7: u32 = crypto_w_load(w, im7);
    let w15: u32 = crypto_w_load(w, im15);
    let w16: u32 = crypto_w_load(w, im16);
    let s0: u32 = crypto_sha256_small_sigma0(w15);
    let s1: u32 = crypto_sha256_small_sigma1(w2);
    crypto_w_store(w, i, s1 + w7 + s0 + w16);
    i = i + 1;
  }
}

/**
 * 64 compression rounds. Adds the result back into H.
 * @param h *u32 — 8-word state
 * @param w *u32 — full schedule
 * PLATFORM: MACOS|DARWIN
 */
function crypto_sha256_rounds(h: *u32, w: *u32): void {
  let a: u32 = crypto_w_load(h, 0);
  let b: u32 = crypto_w_load(h, 1);
  let c: u32 = crypto_w_load(h, 2);
  let d: u32 = crypto_w_load(h, 3);
  let e: u32 = crypto_w_load(h, 4);
  let f: u32 = crypto_w_load(h, 5);
  let g: u32 = crypto_w_load(h, 6);
  let hh: u32 = crypto_w_load(h, 7);
  let i: i32 = 0;
  while (i < 64) {
    let s1: u32 = xlang_sha256_rotr32_impl(e, 6) ^ xlang_sha256_rotr32_impl(e, 11) ^ xlang_sha256_rotr32_impl(e, 25);
    let ch: u32 = xlang_sha256_ch_impl(e, f, g);
    let t1: u32 = hh + s1 + ch + crypto_sha256_k256_c(i) + crypto_w_load(w, i);
    let s0: u32 = xlang_sha256_rotr32_impl(a, 2) ^ xlang_sha256_rotr32_impl(a, 13) ^ xlang_sha256_rotr32_impl(a, 22);
    let t2: u32 = s0 + xlang_sha256_maj_impl(a, b, c);
    hh = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
    i = i + 1;
  }
  crypto_w_store(h, 0, crypto_w_load(h, 0) + a);
  crypto_w_store(h, 1, crypto_w_load(h, 1) + b);
  crypto_w_store(h, 2, crypto_w_load(h, 2) + c);
  crypto_w_store(h, 3, crypto_w_load(h, 3) + d);
  crypto_w_store(h, 4, crypto_w_load(h, 4) + e);
  crypto_w_store(h, 5, crypto_w_load(h, 5) + f);
  crypto_w_store(h, 6, crypto_w_load(h, 6) + g);
  crypto_w_store(h, 7, crypto_w_load(h, 7) + hh);
}

/**
 * Compress one 64-byte block into H.
 * The schedule is a 256-byte heap buffer.
 * @param H *u32 — 8-word state
 * @param block *u8 — 64 bytes
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sha256_block_impl(H: *u32, block: *u8): void {
  let raw: *u8 = 0;
  unsafe {
    raw = malloc(256);
  }
  if (raw == 0) {
    return;
  }
  let w: *u32 = raw as *u32;
  crypto_sha256_load16(w, block);
  crypto_sha256_expand(w);
  crypto_sha256_rounds(H, w);
  unsafe {
    free(raw);
  }
}

/**
 * Write the SHA-256 IV into h.
 * @param h *u32 — 8 words
 * PLATFORM: MACOS|DARWIN
 */
function crypto_sha256_iv(h: *u32): void {
  let s: *u8 = "6a09e667bb67ae853c6ef372a54ff53a510e527f9b05688c1f83d9ab5be0cd19";
  let i: i32 = 0;
  while (i < 8) {
    crypto_w_store(h, i, crypto_hex_u32(s, i * 4));
    i = i + 1;
  }
}

/**
 * Copy n bytes from src at off into dst. The index is a local.
 * @param dst *u8 — destination
 * @param src *u8 — source
 * @param off i32 — source start
 * @param n i32 — count
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
function crypto_copy_span(dst: *u8, src: *u8, off: i32, n: i32): void {
  // A live pad pulls the copy index inside this frame.
  // The unpadded store sat eight bytes past the allocation.
  let frame_pad: u8[64] = [];
  frame_pad[0] = 0;
  let i: i32 = 0;
  while (i < n) {
    let at: i32 = off + i;
    dst[i] = src[at];
    i = i + 1;
  }
}

/**
 * Absorb every full 64-byte chunk. Returns the leftover byte count.
 * @param h *u32 — state
 * @param msg *u8 — message
 * @param len i32 — byte count
 * @return i32 — len mod 64
 * PLATFORM: MACOS|DARWIN
 */
function crypto_sha256_full(h: *u32, msg: *u8, len: i32): i32 {
  let off: i32 = 0;
  let rem: i32 = len;
  while (rem >= 64) {
    let blk: *u8 = 0;
    unsafe {
      blk = malloc(64);
    }
    if (blk == 0) {
      return 0 - 1;
    }
    crypto_copy_span(blk, msg, off, 64);
    xlang_sha256_block_impl(h as *u32, blk);
    unsafe {
      free(blk);
    }
    off = off + 64;
    rem = rem - 64;
  }
  return rem;
}

/**
 * Store an 8-byte big-endian bit length at dst[56..63].
 * @param dst *u8 — 64-byte block
 * @param bits u64 — message bit length
 * PLATFORM: MACOS|DARWIN
 */
function crypto_put_len(dst: *u8, bits: u64): void {
  dst[56] = ((bits >> 56) as u32) as u8;
  dst[57] = ((bits >> 48) as u32) as u8;
  dst[58] = ((bits >> 40) as u32) as u8;
  dst[59] = ((bits >> 32) as u32) as u8;
  dst[60] = ((bits >> 24) as u32) as u8;
  dst[61] = ((bits >> 16) as u32) as u8;
  dst[62] = ((bits >> 8) as u32) as u8;
  dst[63] = (bits as u32) as u8;
}

/**
 * Write the digest as eight big-endian words.
 * @param h *u32 — state
 * @param out *u8 — 32 bytes
 * PLATFORM: MACOS|DARWIN
 */
function crypto_sha256_out(h: *u32, out: *u8): void {
  let i: i32 = 0;
  while (i < 8) {
    let v: u32 = crypto_w_load(h, i);
    let o: i32 = i * 4;
    out[o] = ((v >> 24) & 255) as u8;
    out[o + 1] = ((v >> 16) & 255) as u8;
    out[o + 2] = ((v >> 8) & 255) as u8;
    out[o + 3] = (v & 255) as u8;
    i = i + 1;
  }
}

/**
 * Pad the leftover bytes and compress the final block.
 * Split out of crypto_sha256_c so that function's frame covers its slots.
 * @param h *u32 — state
 * @param block *u8 — 64-byte scratch
 * @param msg *u8 — message
 * @param len i32 — full byte count
 * @param rem i32 — leftover byte count
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
function crypto_sha256_finish(h: *u32, block: *u8, msg: *u8, len: i32, rem: i32): void {
  // A live pad pulls the edge store inside this frame.
  // The unpadded store sat eight bytes past the allocation.
  let frame_pad: u8[64] = [];
  frame_pad[0] = 0;
  unsafe { memset(block, 0, 64); }
  let off: i32 = len - rem;
  if (rem > 0) {
    crypto_copy_span(block, msg, off, rem);
  }
  block[rem] = 128 as u8;
  let pad: i32 = rem + 1;
  if (pad > 56) {
    xlang_sha256_block_impl(h, block);
    unsafe { memset(block, 0, 64); }
  }
  let bits: u64 = (len as u64) * 8;
  crypto_put_len(block, bits);
  xlang_sha256_block_impl(h, block);
}

/**
 * SHA-256. A null out or a negative length writes 32 zero bytes when
 * out is present, then returns. The empty message is a valid digest.
 * @param msg *u8 — message, may be null when len is 0
 * @param len i32 — byte count
 * @param out *u8 — 32-byte digest
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function crypto_sha256_c(msg: *u8, len: i32, out: *u8): void {
  if (out == 0 || len < 0) {
    if (out != 0) {
      unsafe {
        memset(out, 0, 32);
      }
    }
    return;
  }
  let raw: *u8 = 0;
  let block: *u8 = 0;
  unsafe {
    raw = malloc(32);
    block = malloc(64);
  }
  if (raw == 0 || block == 0) {
    unsafe {
      if (raw != 0) { free(raw); }
      if (block != 0) { free(block); }
    }
    unsafe { memset(out, 0, 32); }
    return;
  }
  let h: *u32 = raw as *u32;
  crypto_sha256_iv(h);
  let rem: i32 = crypto_sha256_full(h, msg, len);
  if (rem < 0) {
    unsafe {
      free(raw);
      free(block);
      memset(out, 0, 32);
    }
    return;
  }
  crypto_sha256_finish(h, block, msg, len, rem);
  crypto_sha256_out(h, out);
  unsafe {
    free(raw);
    free(block);
  }
}

/**
 * Copy n bytes from src into dst at dst_off. The index is a local.
 * Split out of HMAC so that function's frame covers its own slots.
 * @param dst *u8 — destination
 * @param dst_off i32 — destination start
 * @param src *u8 — source
 * @param n i32 — count
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
function crypto_copy_at(dst: *u8, dst_off: i32, src: *u8, n: i32): void {
  // A live pad pulls the copy index inside this frame.
  // The unpadded store sat eight bytes past the allocation.
  let frame_pad: u8[64] = [];
  frame_pad[0] = 0;
  let i: i32 = 0;
  while (i < n) {
    let at: i32 = dst_off + i;
    dst[at] = src[i];
    i = i + 1;
  }
}

/**
 * Release up to four malloc buffers. A null pointer is skipped.
 * @param a *u8 — buffer or null
 * @param b *u8 — buffer or null
 * @param c *u8 — buffer or null
 * @param d *u8 — buffer or null
 * PLATFORM: MACOS|DARWIN
 */
function crypto_free4(a: *u8, b: *u8, c: *u8, d: *u8): void {
  unsafe {
    if (a != 0) { free(a); }
    if (b != 0) { free(b); }
    if (c != 0) { free(c); }
    if (d != 0) { free(d); }
  }
}

/**
 * XOR n bytes of src with pad into dst.
 * @param dst *u8 — destination
 * @param src *u8 — source
 * @param n i32 — count
 * @param pad u8 — xor byte
 * PLATFORM: MACOS|DARWIN
 */
function crypto_xor_pad(dst: *u8, src: *u8, n: i32, pad: u8): void {
  let i: i32 = 0;
  while (i < n) {
    dst[i] = (src[i] ^ pad);
    i = i + 1;
  }
}

/**
 * HMAC-SHA256. A message that would pass 4160 bytes with the 64-byte
 * key block writes a zero digest. key longer than 64 bytes is hashed
 * down to 32 first.
 * @param key *u8 — key bytes
 * @param key_len i32 — key length
 * @param msg *u8 — message
 * @param msg_len i32 — message length
 * @param out *u8 — 32-byte MAC
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function crypto_hmac_sha256_c(key: *u8, key_len: i32, msg: *u8, msg_len: i32, out: *u8): void {
  if (out == 0) {
    return;
  }
  if (key_len < 0 || msg_len < 0 || 64 + msg_len > 4160) {
    unsafe { memset(out, 0, 32); }
    return;
  }
  let kbuf: *u8 = 0;
  let ko: *u8 = 0;
  let inner: *u8 = 0;
  let outer: *u8 = 0;
  unsafe {
    kbuf = malloc(32);
    ko = malloc(64);
    inner = malloc((64 + msg_len) as i64);
    outer = malloc(96);
  }
  if (kbuf == 0 || ko == 0 || inner == 0 || outer == 0) {
    crypto_free4(kbuf, ko, inner, outer);
    unsafe { memset(out, 0, 32); }
    return;
  }
  let kptr: *u8 = key;
  let klen: i32 = key_len;
  if (key_len > 64) {
    crypto_sha256_c(key, key_len, kbuf);
    kptr = kbuf;
    klen = 32;
  }
  unsafe { memset(ko, 0, 64); }
  if (kptr != 0 && klen > 0) {
    unsafe { memcpy(ko, kptr, klen as i64); }
  }
  crypto_xor_pad(inner, ko, 64, 54 as u8);
  if (msg_len > 0 && msg != 0) {
    crypto_copy_at(inner, 64, msg, msg_len);
  }
  crypto_sha256_c(inner, 64 + msg_len, out);
  crypto_xor_pad(outer, ko, 64, 92 as u8);
  crypto_copy_at(outer, 64, out, 32);
  crypto_sha256_c(outer, 96, out);
  crypto_free4(kbuf, ko, inner, outer);
}

/**
 * SHA-512 via ed25519_ref10_sha512. A null out or a negative length
 * writes 64 zero bytes when out is present.
 * @param msg *u8 — message
 * @param len i32 — byte count
 * @param out *u8 — 64-byte digest
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function crypto_sha512_c(msg: *u8, len: i32, out: *u8): void {
  if (out == 0 || len < 0) {
    if (out != 0) {
      unsafe { memset(out, 0, 64); }
    }
    return;
  }
  unsafe {
    ed25519_ref10_sha512(msg, len as usize, out);
  }
}

/**
 * HMAC-SHA512. A message that would pass 4224 bytes with the 128-byte
 * key block writes a zero digest. key longer than 128 bytes is hashed
 * down to 64 first.
 * @param key *u8 — key bytes
 * @param key_len i32 — key length
 * @param msg *u8 — message
 * @param msg_len i32 — message length
 * @param out *u8 — 64-byte MAC
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function crypto_hmac_sha512_c(key: *u8, key_len: i32, msg: *u8, msg_len: i32, out: *u8): void {
  if (out == 0) {
    return;
  }
  if (key_len < 0 || msg_len < 0 || 128 + msg_len > 4224) {
    unsafe { memset(out, 0, 64); }
    return;
  }
  let kbuf: *u8 = 0;
  let ko: *u8 = 0;
  let inner: *u8 = 0;
  let outer: *u8 = 0;
  unsafe {
    kbuf = malloc(128);
    ko = malloc(128);
    inner = malloc((128 + msg_len) as i64);
    outer = malloc(192);
  }
  if (kbuf == 0 || ko == 0 || inner == 0 || outer == 0) {
    crypto_free4(kbuf, ko, inner, outer);
    unsafe { memset(out, 0, 64); }
    return;
  }
  let kptr: *u8 = key;
  let klen: i32 = key_len;
  if (key_len > 128) {
    crypto_sha512_c(key, key_len, kbuf);
    kptr = kbuf;
    klen = 64;
  }
  unsafe { memset(ko, 0, 128); }
  if (kptr != 0 && klen > 0) {
    unsafe { memcpy(ko, kptr, klen as i64); }
  }
  crypto_xor_pad(inner, ko, 128, 54 as u8);
  if (msg_len > 0 && msg != 0) {
    crypto_copy_at(inner, 128, msg, msg_len);
  }
  crypto_sha512_c(inner, 128 + msg_len, out);
  crypto_xor_pad(outer, ko, 128, 92 as u8);
  crypto_copy_at(outer, 128, out, 64);
  crypto_sha512_c(outer, 192, out);
  crypto_free4(kbuf, ko, inner, outer);
}
