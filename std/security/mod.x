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
//
// See implementation.

const crypto = import("std.crypto");
const random = import("std.random");

extern function security_secure_zero_c(p: *u8, len: i32): void;
extern function security_mlock_c(p: *u8, len: i32): i32;
extern function security_munlock_c(p: *u8, len: i32): i32;
extern function security_hkdf_sha256_c(salt: *u8, salt_len: i32, ikm: *u8, ikm_len: i32,
  info: *u8, info_len: i32, okm: *u8, okm_len: i32): i32;

/** Exported function `key_len`.
 * Query helper `key_len`.
 * @return i32
 */
export function key_len(): i32 { return 32; }
/** Exported function `salt_len_default`.
 * Implements `salt_len_default`.
 * @return i32
 */
export function salt_len_default(): i32 { return 16; }
/** Exported function `min_secret_len`.
 * Query helper `min_secret_len`.
 * @return i32
 */
export function min_secret_len(): i32 { return 8; }

/** Exported function `err_ok`.
 * Implements `err_ok`.
 * @return i32
 */
export function err_ok(): i32 { return 0; }
/** Exported function `err_invalid`.
 * Implements `err_invalid`.
 * @return i32
 */
export function err_invalid(): i32 { return -1; }
/** Exported function `err_random`.
 * Implements `err_random`.
 * @return i32
 */
export function err_random(): i32 { return -2; }
/** Exported function `err_buffer`.
 * Implements `err_buffer`.
 * @return i32
 */
export function err_buffer(): i32 { return -3; }

/* See implementation. */
allow(padding) struct SensitiveBuf {
  ptr: *u8;
  len: i32;
  locked: i32;
}

/** Exported function `ct_compare`.
 * Implements `ct_compare`.
 * @param a *u8
 * @param b *u8
 * @param len i32
 * @return i32
 */
export function ct_compare(a: *u8, b: *u8, len: i32): i32 {
  return crypto.mem_eq(a, b, len);
}

/** Exported function `random_key`.
 * Implements `random_key`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function random_key(buf: *u8, len: i32): i32 {
  let n: i32 = 0;
  if (buf == 0 || len < min_secret_len()) { return err_invalid(); }
  n = random.fill_bytes(buf, len);
  if (n != len) { return err_random(); }
  return err_ok();
}

/** Exported function `random_salt`.
 * Implements `random_salt`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function random_salt(buf: *u8, len: i32): i32 {
  return random_key(buf, len);
}

/* See implementation. */
export function hkdf(salt: *u8, salt_len: i32, ikm: *u8, ikm_len: i32,
  info: *u8, info_len: i32, okm: *u8, okm_len: i32): i32 {
  let r: i32 = 0;
  if (ikm == 0 || okm == 0 || ikm_len <= 0 || okm_len <= 0) { return err_invalid(); }
  unsafe { r = security_hkdf_sha256_c(salt, salt_len, ikm, ikm_len, info, info_len, okm, okm_len); }
  if (r != 0) {
    return err_invalid();
  }
  return err_ok();
}

/** Exported function `secure_zero`.
 * Implements `secure_zero`.
 * @param p *u8
 * @param len i32
 * @return void
 */
export function secure_zero(p: *u8, len: i32): void {
  if (p == 0 || len <= 0) { return; }
  unsafe { security_secure_zero_c(p, len); }
}

/** Exported function `sensitive_lock`.
 * Implements `sensitive_lock`.
 * @param p *u8
 * @param len i32
 * @return i32
 */
export function sensitive_lock(p: *u8, len: i32): i32 {
  if (p == 0 || len <= 0) { return 0; }
  unsafe { return security_mlock_c(p, len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `sensitive_unlock`.
 * Implements `sensitive_unlock`.
 * @param p *u8
 * @param len i32
 * @return i32
 */
export function sensitive_unlock(p: *u8, len: i32): i32 {
  if (p == 0 || len <= 0) { return 0; }
  unsafe { return security_munlock_c(p, len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `sensitive_buf_init`.
 * Implements `sensitive_buf_init`.
 * @param sb *SensitiveBuf
 * @param p *u8
 * @param len i32
 * @param try_lock i32
 * @return i32
 */
export function sensitive_buf_init(sb: *SensitiveBuf, p: *u8, len: i32, try_lock: i32): i32 {
  if (sb == 0 || p == 0 || len <= 0) { return err_invalid(); }
  sb.ptr = p;
  sb.len = len;
  sb.locked = 0;
  if (try_lock != 0) {
    sb.locked = sensitive_lock(p, len);
  }
  return err_ok();
}

/** Exported function `sensitive_buf_wipe`.
 * Implements `sensitive_buf_wipe`.
 * @param sb *SensitiveBuf
 * @return void
 */
export function sensitive_buf_wipe(sb: *SensitiveBuf): void {
  let p: *u8 = 0;
  let n: i32 = 0;
  if (sb == 0) { return; }
  p = sb.ptr;
  n = sb.len;
  if (sb.locked != 0 && p != 0) {
    sensitive_unlock(p, n);
    sb.locked = 0;
  }
  secure_zero(p, n);
  sb.ptr = 0;
  sb.len = 0;
}
