// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-20：runtime_crypto_inc_glue 产品源迁 seeds/runtime_crypto_inc_glue.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// 产品：cc seeds/runtime_crypto_inc_glue.from_x.c → runtime_crypto_inc_glue.o
// G-02f-99：+ sha256 rotr/ch/maj 薄门闩。
// G-02f-100：+ sha256_block 薄门闩。

extern "C" function shu_sha256_rotr32_impl(x: u32, n: u32): u32;
extern "C" function shu_sha256_ch_impl(x: u32, y: u32, z: u32): u32;
extern "C" function shu_sha256_maj_impl(x: u32, y: u32, z: u32): u32;
extern "C" function shu_sha256_block_impl(H: *u32, block: *u8): void;

function runtime_crypto_inc_glue_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-99：SHA-256 pure helpers 门闩 ---- */




#[no_mangle]
function shu_sha256_block(H: *u32, block: *u8): void {
  unsafe {
    shu_sha256_block_impl(H, block);
  }
}

// G-02f-114：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）

#[no_mangle]
function shu_sha256_rotr32(x: u32, n: u32): u32 {
  n = n & 31;
  return (x >> n) | (x << (32 - n));
}

#[no_mangle]
function shu_sha256_ch(x: u32, y: u32, z: u32): u32 {
  return (x & y) ^ ((~x) & z);
}

#[no_mangle]
function shu_sha256_maj(x: u32, y: u32, z: u32): u32 {
  return (x & y) ^ (x & z) ^ (y & z);
}
