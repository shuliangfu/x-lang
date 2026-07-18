// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.

export extern "C" function net_dns_ai_addconfig_c_impl(): i32;
export extern "C" function net_dns_map_gai_error_c_impl(err: i32): i32;
export extern "C" function net_dns_ensure_wsa_c_impl(): i32;

/** Exported function `runtime_net_dns_fast_x_doc_anchor`.
 * Implements `runtime_net_dns_fast_x_doc_anchor`.
 * @return i32
 */
export function runtime_net_dns_fast_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */

#[no_mangle]
export function net_dns_ai_addconfig_c(): i32 {
  unsafe {
    return net_dns_ai_addconfig_c_impl();
  }
  return 0;
}

#[no_mangle]
/** Exported function `net_dns_map_gai_error_c`.
 * Implements `net_dns_map_gai_error_c`.
 * @param err i32
 * @return i32
 */
export function net_dns_map_gai_error_c(err: i32): i32 {
  unsafe {
    return net_dns_map_gai_error_c_impl(err);
  }
  return 0;
}

#[no_mangle]
/** Exported function `net_dns_ensure_wsa_c`.
 * Implements `net_dns_ensure_wsa_c`.
 * @return i32
 */
export function net_dns_ensure_wsa_c(): i32 {
  unsafe {
    return net_dns_ensure_wsa_c_impl();
  }
  return 0;
}
