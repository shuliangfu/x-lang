// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.

export extern "C" function xlang_mbedtls_bio_send_impl(ctx: *u8, buf: *u8, len: usize): i32;
export extern "C" function xlang_mbedtls_bio_recv_impl(ctx: *u8, buf: *u8, len: usize): i32;

/** Exported function `runtime_tls_mbedtls_bio_x_doc_anchor`.
 * Implements `runtime_tls_mbedtls_bio_x_doc_anchor`.
 * @return i32
 */
export function runtime_tls_mbedtls_bio_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */

#[no_mangle]
export function xlang_mbedtls_bio_send(ctx: *u8, buf: *u8, len: usize): i32 {
  unsafe {
    return xlang_mbedtls_bio_send_impl(ctx, buf, len);
  }
  return 0 - 1;
}

/** Exported function `xlang_mbedtls_bio_recv`.
 * Implements `xlang_mbedtls_bio_recv`.
 * @param ctx *u8
 * @param buf *u8
 * @param len usize
 * @return i32
 */
#[no_mangle]
export function xlang_mbedtls_bio_recv(ctx: *u8, buf: *u8, len: usize): i32 {
  unsafe {
    return xlang_mbedtls_bio_recv_impl(ctx, buf, len);
  }
  return 0 - 1;
}
