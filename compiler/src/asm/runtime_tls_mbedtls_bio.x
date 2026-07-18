// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-21：runtime_tls_mbedtls_bio 产品源迁 seeds/runtime_tls_mbedtls_bio.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// G-02f-105：+ bio send/recv 薄门闩。

export extern "C" function shu_mbedtls_bio_send_impl(ctx: *u8, buf: *u8, len: usize): i32;
export extern "C" function shu_mbedtls_bio_recv_impl(ctx: *u8, buf: *u8, len: usize): i32;

export function runtime_tls_mbedtls_bio_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-105：mbedtls bio 门闩 ---- */

#[no_mangle]
export function shu_mbedtls_bio_send(ctx: *u8, buf: *u8, len: usize): i32 {
  unsafe {
    return shu_mbedtls_bio_send_impl(ctx, buf, len);
  }
  return 0 - 1;
}

#[no_mangle]
export function shu_mbedtls_bio_recv(ctx: *u8, buf: *u8, len: usize): i32 {
  unsafe {
    return shu_mbedtls_bio_recv_impl(ctx, buf, len);
  }
  return 0 - 1;
}
