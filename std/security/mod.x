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

// std.security — 应用层安全原语（STD-079）
//
// 【文件职责】
// 常量时间比较（委托 std.crypto.mem_eq）、CSPRNG 密钥/盐、HKDF-SHA256、
// secure_zero、可选 mlock；密钥材料生命周期辅助。
//
// 【对标】Go crypto/subtle + golang.org/x/crypto/hkdf 最小子集。

const crypto = import("std.crypto");
const random = import("std.random");

extern function security_secure_zero_c(p: *u8, len: i32): void;
extern function security_mlock_c(p: *u8, len: i32): i32;
extern function security_munlock_c(p: *u8, len: i32): i32;
extern function security_hkdf_sha256_c(salt: *u8, salt_len: i32, ikm: *u8, ikm_len: i32,
  info: *u8, info_len: i32, okm: *u8, okm_len: i32): i32;

/** 推荐 AES-256 密钥长度（字节）。 */
function key_len(): i32 { return 32; }
/** 默认盐长度（字节）。 */
function salt_len_default(): i32 { return 16; }
/** 最小可接受密钥/盐长度。 */
function min_secret_len(): i32 { return 8; }

/** 成功。 */
function err_ok(): i32 { return 0; }
/** 参数非法。 */
function err_invalid(): i32 { return -1; }
/** 随机源失败。 */
function err_random(): i32 { return -2; }
/** 输出缓冲不足。 */
function err_buffer(): i32 { return -3; }

/** 敏感缓冲描述（指针 + 长度 + 是否已 mlock）。 */
allow(padding) struct SensitiveBuf {
  ptr: *u8;
  len: i32;
  locked: i32;
}

/** 常量时间比较；与 std.crypto.mem_eq 同义，语义别名便于安全审计。 */
function ct_compare(a: *u8, b: *u8, len: i32): i32 {
  return crypto.mem_eq(a, b, len);
}

/** 用 CSPRNG 填充密钥材料；len 须 >= min_secret_len()。 */
function random_key(buf: *u8, len: i32): i32 {
  let n: i32 = 0;
  if (buf == 0 || len < min_secret_len()) { return err_invalid(); }
  n = random.fill_bytes(buf, len);
  if (n != len) { return err_random(); }
  return err_ok();
}

/** 用 CSPRNG 填充盐；len 须 >= min_secret_len()。 */
function random_salt(buf: *u8, len: i32): i32 {
  return random_key(buf, len);
}

/** HKDF-SHA256 派生；okm_len 须 > 0。 */
function hkdf(salt: *u8, salt_len: i32, ikm: *u8, ikm_len: i32,
  info: *u8, info_len: i32, okm: *u8, okm_len: i32): i32 {
  let r: i32 = 0;
  if (ikm == 0 || okm == 0 || ikm_len <= 0 || okm_len <= 0) { return err_invalid(); }
  unsafe { r = security_hkdf_sha256_c(salt, salt_len, ikm, ikm_len, info, info_len, okm, okm_len); }
  if (r != 0) {
    return err_invalid();
  }
  return err_ok();
}

/** 安全清零缓冲（密钥释放前调用）。 */
function secure_zero(p: *u8, len: i32): void {
  if (p == 0 || len <= 0) { return; }
  unsafe { security_secure_zero_c(p, len); }
}

/** 尝试锁定敏感页；不支持时返回 0（静默回退）。 */
function sensitive_lock(p: *u8, len: i32): i32 {
  if (p == 0 || len <= 0) { return 0; }
  unsafe { return security_mlock_c(p, len); }
}

/** 解除敏感页锁定。 */
function sensitive_unlock(p: *u8, len: i32): i32 {
  if (p == 0 || len <= 0) { return 0; }
  unsafe { return security_munlock_c(p, len); }
}

/** 绑定 SensitiveBuf 并可选 mlock。 */
function sensitive_buf_init(sb: *SensitiveBuf, p: *u8, len: i32, try_lock: i32): i32 {
  if (sb == 0 || p == 0 || len <= 0) { return err_invalid(); }
  sb.ptr = p;
  sb.len = len;
  sb.locked = 0;
  if (try_lock != 0) {
    sb.locked = sensitive_lock(p, len);
  }
  return err_ok();
}

/** 释放 SensitiveBuf：unlock + secure_zero。 */
function sensitive_buf_wipe(sb: *SensitiveBuf): void {
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
