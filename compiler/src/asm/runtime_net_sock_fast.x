// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.

export extern "C" function net_ensure_wsa_impl(): void;
export extern "C" function net_wsa_ctor_impl(): void;

/** Exported function `runtime_net_sock_fast_x_doc_anchor`.
 * Implements `runtime_net_sock_fast_x_doc_anchor`.
 * @return i32
 */
export function runtime_net_sock_fast_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */

#[no_mangle]
export function net_ensure_wsa(): void {
  unsafe {
    net_ensure_wsa_impl();
  }
}

#[no_mangle]
/** Exported function `net_wsa_ctor`.
 * Implements `net_wsa_ctor`.
 * @return void
 */
export function net_wsa_ctor(): void {
  unsafe {
    net_wsa_ctor_impl();
  }
}
