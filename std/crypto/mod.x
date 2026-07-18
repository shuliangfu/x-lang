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

extern function crypto_mem_eq_c(a: *u8, b: *u8, len: i32): i32;
extern function crypto_sha256_c(msg: *u8, len: i32, out: *u8): void;
extern function crypto_sha512_c(msg: *u8, len: i32, out: *u8): void;
extern function crypto_hmac_sha256_c(key: *u8, key_len: i32, msg: *u8, msg_len: i32, out: *u8): void;
extern function crypto_hmac_sha512_c(key: *u8, key_len: i32, msg: *u8, msg_len: i32, out: *u8): void;
extern function crypto_ed25519_public_from_seed_c(seed: *u8, pub: *u8): void;
extern function crypto_ed25519_sign_c(seed: *u8, msg: *u8, msg_len: i32, sig: *u8): i32;
extern function crypto_ed25519_verify_c(pub: *u8, msg: *u8, msg_len: i32, sig: *u8): i32;
extern function crypto_ed25519_smoke_c(): i32;
extern function crypto_aes_gcm_seal_c(key: *u8, key_len: i32, iv: *u8, iv_len: i32, aad: *u8,
  aad_len: i32, pt: *u8, pt_len: i32, ct: *u8, tag: *u8): i32;
extern function crypto_aes_gcm_open_c(key: *u8, key_len: i32, iv: *u8, iv_len: i32, aad: *u8,
  aad_len: i32, ct: *u8, ct_len: i32, tag: *u8, pt: *u8): i32;
extern function crypto_chacha20_poly1305_seal_c(key: *u8, key_len: i32, nonce: *u8, nonce_len: i32,
  aad: *u8, aad_len: i32, pt: *u8, pt_len: i32, ct: *u8, tag: *u8): i32;
extern function crypto_chacha20_poly1305_open_c(key: *u8, key_len: i32, nonce: *u8, nonce_len: i32,
  aad: *u8, aad_len: i32, ct: *u8, ct_len: i32, tag: *u8, pt: *u8): i32;
extern function crypto_chacha20_poly1305_smoke_c(): i32;

/** Exported function `ED25519_SEED_LEN`.
 * Query helper `ED25519_SEED_LEN`.
 * @return i32
 */
export function ED25519_SEED_LEN(): i32 { return 32; }
/* See implementation. */
export const AES_GCM_TAG_LEN: i32 = 16;
/** Exported function `CHACHA20_POLY1305_KEY_LEN`.
 * Query helper `CHACHA20_POLY1305_KEY_LEN`.
 * @return i32
 */
export function CHACHA20_POLY1305_KEY_LEN(): i32 { return 32; }
/* See implementation. */
export const SHA512_DIGEST_LEN: i32 = 64;

/** Exported function `mem_eq`.
 * Implements `mem_eq`.
 * @param a *u8
 * @param b *u8
 * @param len i32
 * @return i32
 */
export function mem_eq(a: *u8, b: *u8, len: i32): i32 {
  let __gffi_r: i32 = 0;
  unsafe {
    __gffi_r = crypto_mem_eq_c(a, b, len);
  }
  return __gffi_r;
}

/** Exported function `sha256`.
 * Implements `sha256`.
 * @param msg *u8
 * @param len i32
 * @param out *u8
 * @return void
 */
export function sha256(msg: *u8, len: i32, out: *u8): void {
  unsafe {
    crypto_sha256_c(msg, len, out);
  }
}

/** Exported function `sha512`.
 * Implements `sha512`.
 * @param msg *u8
 * @param len i32
 * @param out *u8
 * @return void
 */
export function sha512(msg: *u8, len: i32, out: *u8): void {
  unsafe {
    crypto_sha512_c(msg, len, out);
  }
}

/** Exported function `hmac_sha512`.
 * Implements `hmac_sha512`.
 * @param key *u8
 * @param key_len i32
 * @param msg *u8
 * @param msg_len i32
 * @param out *u8
 * @return void
 */
export function hmac_sha512(key: *u8, key_len: i32, msg: *u8, msg_len: i32, out: *u8): void {
  unsafe {
    crypto_hmac_sha512_c(key, key_len, msg, msg_len, out);
  }
}

/** Exported function `hmac_sha256`.
 * Implements `hmac_sha256`.
 * @param key *u8
 * @param key_len i32
 * @param msg *u8
 * @param msg_len i32
 * @param out *u8
 * @return void
 */
export function hmac_sha256(key: *u8, key_len: i32, msg: *u8, msg_len: i32, out: *u8): void {
  unsafe {
    crypto_hmac_sha256_c(key, key_len, msg, msg_len, out);
  }
}

/** Exported function `mac_sign`.
 * Implements `mac_sign`.
 * @param key *u8
 * @param key_len i32
 * @param msg *u8
 * @param msg_len i32
 * @param out *u8
 * @return void
 */
export function mac_sign(key: *u8, key_len: i32, msg: *u8, msg_len: i32, out: *u8): void {
  hmac_sha256(key, key_len, msg, msg_len, out);
}

/** Exported function `mac_sign_512`.
 * Implements `mac_sign_512`.
 * @param key *u8
 * @param key_len i32
 * @param msg *u8
 * @param msg_len i32
 * @param out *u8
 * @return void
 */
export function mac_sign_512(key: *u8, key_len: i32, msg: *u8, msg_len: i32, out: *u8): void {
  hmac_sha512(key, key_len, msg, msg_len, out);
}

/** Exported function `mac_verify`.
 * Implements `mac_verify`.
 * @param key *u8
 * @param key_len i32
 * @param msg *u8
 * @param msg_len i32
 * @param tag *u8
 * @return i32
 */
export function mac_verify(key: *u8, key_len: i32, msg: *u8, msg_len: i32, tag: *u8): i32 {
  let calc: u8[32] = [];
  hmac_sha256(key, key_len, msg, msg_len, &calc[0]);
  return mem_eq(&calc[0], tag, 32);
}

/** Exported function `mac_verify_512`.
 * Implements `mac_verify_512`.
 * @param key *u8
 * @param key_len i32
 * @param msg *u8
 * @param msg_len i32
 * @param tag *u8
 * @return i32
 */
export function mac_verify_512(key: *u8, key_len: i32, msg: *u8, msg_len: i32, tag: *u8): i32 {
  let calc: u8[64] = [];
  hmac_sha512(key, key_len, msg, msg_len, &calc[0]);
  return mem_eq(&calc[0], tag, 64);
}

/** Exported function `ed25519_public_from_seed`.
 * Implements `ed25519_public_from_seed`.
 * @param seed *u8
 * @param pub *u8
 * @return void
 */
export function ed25519_public_from_seed(seed: *u8, pub: *u8): void {
  unsafe {
    crypto_ed25519_public_from_seed_c(seed, pub);
  }
}

/** Exported function `ed25519_sign`.
 * Implements `ed25519_sign`.
 * @param seed *u8
 * @param msg *u8
 * @param msg_len i32
 * @param sig *u8
 * @return i32
 */
export function ed25519_sign(seed: *u8, msg: *u8, msg_len: i32, sig: *u8): i32 {
  let __gffi_r: i32 = 0;
  unsafe {
    __gffi_r = crypto_ed25519_sign_c(seed, msg, msg_len, sig);
  }
  return __gffi_r;
}

/** Exported function `ed25519_verify`.
 * Implements `ed25519_verify`.
 * @param pub *u8
 * @param msg *u8
 * @param msg_len i32
 * @param sig *u8
 * @return i32
 */
export function ed25519_verify(pub: *u8, msg: *u8, msg_len: i32, sig: *u8): i32 {
  let __gffi_r: i32 = 0;
  unsafe {
    __gffi_r = crypto_ed25519_verify_c(pub, msg, msg_len, sig);
  }
  return __gffi_r;
}

/** Exported function `ed25519_smoke`.
 * Implements `ed25519_smoke`.
 * @return i32
 */
export function ed25519_smoke(): i32 {
  let __gffi_r: i32 = 0;
  unsafe {
    __gffi_r = crypto_ed25519_smoke_c();
  }
  return __gffi_r;
}

/* See implementation. */
export function aes_gcm_seal(key: *u8, key_len: i32, iv: *u8, iv_len: i32, aad: *u8, aad_len: i32,
  pt: *u8, pt_len: i32, ct: *u8, tag: *u8): i32 {
  let __gffi_r: i32 = 0;
  unsafe {
    __gffi_r = crypto_aes_gcm_seal_c(key, key_len, iv, iv_len, aad, aad_len, pt, pt_len, ct, tag);
  }
  return __gffi_r;
}

/* See implementation. */
export function aes_gcm_open(key: *u8, key_len: i32, iv: *u8, iv_len: i32, aad: *u8, aad_len: i32,
  ct: *u8, ct_len: i32, tag: *u8, pt: *u8): i32 {
  let __gffi_r: i32 = 0;
  unsafe {
    __gffi_r = crypto_aes_gcm_open_c(key, key_len, iv, iv_len, aad, aad_len, ct, ct_len, tag, pt);
  }
  return __gffi_r;
}

/* See implementation. */
export function chacha20_poly1305_seal(key: *u8, key_len: i32, nonce: *u8, nonce_len: i32, aad: *u8,
  aad_len: i32, pt: *u8, pt_len: i32, ct: *u8, tag: *u8): i32 {
  let __gffi_r: i32 = 0;
  unsafe {
    __gffi_r = crypto_chacha20_poly1305_seal_c(key, key_len, nonce, nonce_len, aad, aad_len, pt, pt_len, ct, tag);
  }
  return __gffi_r;
}

/* See implementation. */
export function chacha20_poly1305_open(key: *u8, key_len: i32, nonce: *u8, nonce_len: i32, aad: *u8,
  aad_len: i32, ct: *u8, ct_len: i32, tag: *u8, pt: *u8): i32 {
  let __gffi_r: i32 = 0;
  unsafe {
    __gffi_r = crypto_chacha20_poly1305_open_c(key, key_len, nonce, nonce_len, aad, aad_len, ct, ct_len, tag, pt);
  }
  return __gffi_r;
}

/** Exported function `chacha20_poly1305_smoke`.
 * Implements `chacha20_poly1305_smoke`.
 * @return i32
 */
export function chacha20_poly1305_smoke(): i32 {
  let __gffi_r: i32 = 0;
  unsafe {
    __gffi_r = crypto_chacha20_poly1305_smoke_c();
  }
  return __gffi_r;
}
