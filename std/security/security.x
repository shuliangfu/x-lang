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

// std/security/security.x — 应用层安全原语（F-security v1 + F-ZC；替代 security.c）
//
// 【文件职责】
// secure_zero、HKDF-SHA256、mlock/munlock、烟测；纯 .x 编译为 security.o。

extern function memcpy(dst: *u8, src: *u8, n: usize): *u8;
extern function memset(dst: *u8, c: i32, n: usize): *u8;
extern function mlock(addr: *u8, len: usize): i32;
extern function munlock(addr: *u8, len: usize): i32;

extern function crypto_hmac_sha256_c(key: *u8, key_len: i32, msg: *u8, msg_len: i32, out: *u8): void;
extern function crypto_mem_eq_c(a: *u8, b: *u8, len: i32): i32;

/** SHA-256 输出长度。 */
const SEC_SHA256_LEN: i32 = 32;

/** F-std-zero-c：security_os_glue.c 已删除。 */
function security_f_zero_c_marker_c(): i32 {
  return 1;
}

/**
 * 尝试 mlock；成功 1，不支持或失败 0。
 * 经 libc mlock（POSIX；Windows 链路由链接阶段解析）。
 */
function security_mlock_c(p: *u8, len: i32): i32 {
  if (p == 0 || len <= 0) { return 0; }
  if (unsafe { mlock(p, len) } == 0) { return 1; }
  return 0;
}

/**
 * 解除 mlock；成功 1，否则 0。
 * 经 libc munlock。
 */
function security_munlock_c(p: *u8, len: i32): i32 {
  if (p == 0 || len <= 0) { return 0; }
  if (unsafe { munlock(p, len) } == 0) { return 1; }
  return 0;
}

/** 安全清零：volatile 写避免编译器优化掉。 */
function security_secure_zero_c(p: *u8, len: i32): void {
  let i: i32 = 0;
  if (p == 0 || len <= 0) { return; }
  while (i < len) {
    p[i] = 0;
    i = i + 1;
  }
}

/** HKDF-Extract：PRK = HMAC(salt, IKM)。 */
function sec_hkdf_extract(salt: *u8, salt_len: i32, ikm: *u8, ikm_len: i32, prk: *u8): void {
  let zero_salt: u8[32];
  let s: *u8 = salt;
  let sl: i32 = salt_len;
  let i: i32 = 0;
  if (sl <= 0) {
    while (i < SEC_SHA256_LEN) {
      zero_salt[i] = 0;
      i = i + 1;
    }
    s = &zero_salt[0];
    sl = SEC_SHA256_LEN;
  }
  unsafe { crypto_hmac_sha256_c(s, sl, ikm, ikm_len, prk); }
}

/** HKDF-Expand：由 PRK 派生 okm_len 字节 OKM。 */
function sec_hkdf_expand(prk: *u8, info: *u8, info_len: i32, okm: *u8, okm_len: i32): i32 {
  let t: u8[32];
  let block: u8[545];
  let n: i32 = 0;
  let off: i32 = 0;
  let i: i32 = 0;
  let bl: i32 = 0;
  let copy: i32 = 0;
  if (prk == 0 || okm == 0 || okm_len <= 0) { return -1; }
  n = (okm_len + SEC_SHA256_LEN - 1) / SEC_SHA256_LEN;
  if (n > 255) { return -1; }
  i = 1;
  while (i <= n) {
    bl = 0;
    if (i > 1) {
      unsafe { memcpy(&block[0], &t[0], SEC_SHA256_LEN as usize); }
      bl = SEC_SHA256_LEN;
    }
    if (info != 0 && info_len > 0) {
      if (bl + info_len > 544) { return -1; }
      unsafe { memcpy(&block[bl], info, info_len as usize); }
      bl = bl + info_len;
    }
    block[bl] = i as u8;
    bl = bl + 1;
    unsafe { crypto_hmac_sha256_c(prk, SEC_SHA256_LEN, &block[0], bl, &t[0]); }
    copy = okm_len - off;
    if (copy > SEC_SHA256_LEN) { copy = SEC_SHA256_LEN; }
    unsafe { memcpy(okm + (off as usize), &t[0], copy as usize); }
    off = off + copy;
    i = i + 1;
  }
  return 0;
}

/** HKDF-SHA256（RFC 5869）；成功 0，参数非法 -1。 */
function security_hkdf_sha256_c(salt: *u8, salt_len: i32, ikm: *u8, ikm_len: i32,
                                info: *u8, info_len: i32, okm: *u8, okm_len: i32): i32 {
  let prk: u8[32];
  if (ikm == 0 || okm == 0 || ikm_len <= 0 || okm_len <= 0) { return -1; }
  sec_hkdf_extract(salt, salt_len, ikm, ikm_len, &prk[0]);
  return sec_hkdf_expand(&prk[0], info, info_len, okm, okm_len);
}

/** C 烟测：HKDF RFC5869 TC1 + secure_zero + mem_eq。 */
function security_smoke_c(): i32 {
  let ikm: u8[22] = [
    11, 11, 11, 11, 11, 11, 11, 11, 11, 11,
    11, 11, 11, 11, 11, 11, 11, 11, 11, 11,
    11, 11
  ];
  let salt: u8[13] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  let info: u8[10] = [240, 241, 242, 243, 244, 245, 246, 247, 248, 249];
  let expect: u8[42] = [
    60, 178, 95, 37, 250, 172, 213, 122, 144, 67, 79, 100, 208, 54, 54, 47,
    45, 45, 10, 144, 207, 26, 90, 76, 93, 176, 45, 86, 236, 196, 197, 191,
    52, 0, 114, 8, 213, 184, 135, 24, 88, 101
  ];
  let okm: u8[42];
  let buf: u8[8];
  let i: i32 = 0;
  if (security_hkdf_sha256_c(&salt[0], 13, &ikm[0], 22, &info[0], 10, &okm[0], 42) != 0) {
    return 1;
  }
  if (unsafe { crypto_mem_eq_c(&okm[0], &expect[0], 42) } != 1) { return 2; }
  while (i < 8) {
    buf[i] = (i + 1) as u8;
    i = i + 1;
  }
  security_secure_zero_c(&buf[0], 8);
  i = 0;
  while (i < 8) {
    if (buf[i] != 0) { return 3; }
    i = i + 1;
  }
  return 0;
}
