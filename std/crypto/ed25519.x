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

// std.crypto.ed25519 — F-04 v19：Ed25519 签名/验签 C ABI（RFC 8032）
//
// 从 ed25519.inc.c 迁出 crypto_ed25519_* 导出与烟测；ref10 曲线运算见 ed25519_ref10_glue.c。

extern function crypto_mem_eq_c(a: *u8, b: *u8, len: i32): i32;

/** ref10：由 seed 导出公钥与 64 字节私钥（glue 提供）。 */
extern function ed25519_create_keypair(public_key: *u8, private_key: *u8, seed: *u8): void;

/** ref10：对消息签名（glue 提供）。 */
extern function ed25519_sign(signature: *u8, message: *u8, message_len: usize, public_key: *u8, private_key: *u8): void;

/** ref10：验签；成功 1，失败 0（glue 提供）。 */
extern function ed25519_verify(signature: *u8, message: *u8, message_len: usize, public_key: *u8): i32;

/** 由 32 字节 seed 导出 Ed25519 公钥至 pub[0..32]。 */
function crypto_ed25519_public_from_seed_c(seed: *u8, pub: *u8): void {
  let priv: u8[64] = [];
  if (seed == 0 || pub == 0) {
    return;
  }
  unsafe { ed25519_create_keypair(pub, &priv[0], seed); }
}

/**
 * 使用 seed 对 msg 签名；sig 写入 64 字节。
 * 成功 0，参数非法 -1。
 */
function crypto_ed25519_sign_c(seed: *u8, msg: *u8, msg_len: i32, sig: *u8): i32 {
  let pub: u8[32] = [];
  let priv: u8[64] = [];
  if (seed == 0 || sig == 0 || msg_len < 0) {
    return -1;
  }
  if (msg_len > 0 && msg == 0) {
    return -1;
  }
  unsafe { ed25519_create_keypair(&pub[0], &priv[0], seed); }
  unsafe { ed25519_sign(sig, msg, msg_len, &pub[0], &priv[0]); }
  return 0;
}

/**
 * 验签；成功 0，失败 -1。
 * 内部 ed25519_verify 返回 1/0，此处映射为 0/-1。
 */
function crypto_ed25519_verify_c(pub: *u8, msg: *u8, msg_len: i32, sig: *u8): i32 {
  if (pub == 0 || sig == 0 || msg_len < 0) {
    return -1;
  }
  if (msg_len > 0 && msg == 0) {
    return -1;
  }
  unsafe { if (ed25519_verify(sig, msg, msg_len, pub) != 1) {
    return -1;
  } }
  return 0;
}

/** RFC 8032 TEST 1（空消息）C 烟测；0 通过。 */
function crypto_ed25519_smoke_c(): i32 {
  let seed: u8[32] = [
    0x9d, 0x61, 0xb1, 0x9d, 0xef, 0xfd, 0x5a, 0x60, 0xba, 0x84, 0x4a, 0xf4, 0x92, 0xec, 0x2c, 0xc4,
    0x44, 0x49, 0xc5, 0x69, 0x7b, 0x32, 0x69, 0x19, 0x70, 0x3b, 0xac, 0x03, 0x1c, 0xae, 0x7f, 0x60
  ];
  let expect_pub: u8[32] = [
    0xd7, 0x5a, 0x98, 0x01, 0x82, 0xb1, 0x0a, 0xb7, 0xd5, 0x4b, 0xfe, 0xd3, 0xc9, 0x64, 0x07, 0x3a,
    0x0e, 0xe1, 0x72, 0xf3, 0xda, 0xa6, 0x23, 0x25, 0xaf, 0x02, 0x1a, 0x68, 0xf7, 0x07, 0x51, 0x1a
  ];
  let expect_sig: u8[64] = [
    0xe5, 0x56, 0x43, 0x00, 0xc3, 0x60, 0xac, 0x72, 0x90, 0x86, 0xe2, 0xcc, 0x80, 0x6e, 0x82, 0x8a,
    0x84, 0x87, 0x7f, 0x1e, 0xb8, 0xe5, 0xd9, 0x74, 0xd8, 0x73, 0xe0, 0x65, 0x22, 0x49, 0x01, 0x55,
    0x5f, 0xb8, 0x82, 0x15, 0x90, 0xa3, 0x3b, 0xac, 0xc6, 0x1e, 0x39, 0x70, 0x1c, 0xf9, 0xb4, 0x6b,
    0xd2, 0x5b, 0xf5, 0xf0, 0x59, 0x5b, 0xbe, 0x24, 0x65, 0x51, 0x41, 0x43, 0x8e, 0x7a, 0x10, 0x0b
  ];
  let pub: u8[32] = [];
  let sig: u8[64] = [];
  crypto_ed25519_public_from_seed_c(&seed[0], &pub[0]);
  unsafe { if (crypto_mem_eq_c(&pub[0], &expect_pub[0], 32) != 1) {
    return 1;
  } }
  if (crypto_ed25519_sign_c(&seed[0], 0 as *u8, 0, &sig[0]) != 0) {
    return 2;
  }
  unsafe { if (crypto_mem_eq_c(&sig[0], &expect_sig[0], 64) != 1) {
    return 3;
  } }
  if (crypto_ed25519_verify_c(&pub[0], 0 as *u8, 0, &sig[0]) != 0) {
    return 4;
  }
  sig[0] = sig[0] ^ 1;
  if (crypto_ed25519_verify_c(&pub[0], 0 as *u8, 0, &sig[0]) != -1) {
    return 5;
  }
  return 0;
}
