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
// parse/build/stringify；query encode/decode（percent）；
// See implementation.
//
// See implementation.

/* See implementation. */
allow(padding) struct Url {
  scheme_len: i32;
  host_len: i32;
  port_len: i32;
  path_len: i32;
  query_len: i32;
  fragment_len: i32;
  scheme: u8[32];
  host: u8[256];
  port: u8[8];
  path: u8[512];
  query: u8[512];
  fragment: u8[256];
}

extern function url_parse_c(url: *u8, len: i32, out: *Url): i32;
extern function url_build_c(u: *Url, out: *u8, out_cap: i32): i32;
extern function url_query_encode_c(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32;
extern function url_query_decode_c(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32;
extern function url_resolve_c(base: *Url, ref: *u8, ref_len: i32, out: *Url): i32;
extern function url_host_to_ipv6_c(host: *u8, host_len: i32, out_16: *u8): i32;
extern function url_format_ipv6_host_c(addr_16: *u8, out: *u8, out_cap: i32): i32;
extern function url_host_is_ipv6_c(host: *u8, host_len: i32): i32;
extern function url_ipv6_host_smoke_c(): i32;

/** Exported function `parse`.
 * Implements `parse`.
 * @param url *u8
 * @param len i32
 * @param out *Url
 * @return i32
 */
export function parse(url: *u8, len: i32, out: *Url): i32 {
  if (out == 0) { return -1; }
  unsafe { return url_parse_c(url, len, out); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `build`.
 * Implements `build`.
 * @param u Url
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function build(u: Url, out: *u8, out_cap: i32): i32 {
  unsafe { return url_build_c(&u, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `stringify`.
 * Implements `stringify`.
 * @param u Url
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function stringify(u: Url, out: *u8, out_cap: i32): i32 {
  unsafe { return url_build_c(&u, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `query_encode`.
 * Implements `query_encode`.
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function query_encode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return url_query_encode_c(src, src_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `query_decode`.
 * Implements `query_decode`.
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function query_decode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return url_query_decode_c(src, src_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `resolve`.
 * Implements `resolve`.
 * @param base Url
 * @param ref *u8
 * @param ref_len i32
 * @param out *Url
 * @return i32
 */
export function resolve(base: Url, ref: *u8, ref_len: i32, out: *Url): i32 {
  if (out == 0) { return -1; }
  unsafe { return url_resolve_c(&base, ref, ref_len, out); }
  return 0; // unreachable — typeck workaround
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function host_to_ipv6(host: *u8, host_len: i32, out_16: *u8): i32 {
  unsafe { return url_host_to_ipv6_c(host, host_len, out_16); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `format_ipv6_host`.
 * Implements `format_ipv6_host`.
 * @param addr_16 *u8
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function format_ipv6_host(addr_16: *u8, out: *u8, out_cap: i32): i32 {
  unsafe { return url_format_ipv6_host_c(addr_16, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `host_is_ipv6`.
 * Implements `host_is_ipv6`.
 * @param host *u8
 * @param host_len i32
 * @return i32
 */
export function host_is_ipv6(host: *u8, host_len: i32): i32 {
  unsafe { return url_host_is_ipv6_c(host, host_len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ipv6_host_smoke`.
 * Implements `ipv6_host_smoke`.
 * @return i32
 */
export function ipv6_host_smoke(): i32 {
  unsafe { return url_ipv6_host_smoke_c(); }
  return 0; // unreachable — typeck workaround
}
