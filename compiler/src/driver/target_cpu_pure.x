// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// - pending（f-2）· SIMD（f-3）· resolve（f-4）· print（f-5）
// See implementation.
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.

let g_driver_pending_target_cpu_features: u32 = 0;

export extern function shu_target_cpu_detect_host(): u32;
export extern function shu_target_cpu_generic_for_host(): u32;

#[no_mangle]
/** Exported function `driver_set_pending_target_cpu_features`.
 * Implements `driver_set_pending_target_cpu_features`.
 * @param features u32
 * @return void
 */
export function driver_set_pending_target_cpu_features(features: u32): void {
  g_driver_pending_target_cpu_features = features;
}

#[no_mangle]
/** Exported function `driver_get_pending_target_cpu_features`.
 * Implements `driver_get_pending_target_cpu_features`.
 * @return u32
 */
export function driver_get_pending_target_cpu_features(): u32 {
  return g_driver_pending_target_cpu_features;
}

/* See implementation. */
#[no_mangle]
export function tcp_tolower(c: u8): u8 {
  if (c >= 65 && c <= 90) {
    return (c + 32) as u8;
  }
  return c;
}

/** Exported function `tcp_eq_at`.
 * Implements `tcp_eq_at`.
 * @param name *u8
 * @param base usize
 * @param n usize
 * @param lit0 u8
 * @param lit1 u8
 * @param lit2 u8
 * @param lit3 u8
 * @param lit4 u8
 * @param lit5 u8
 * @param lit6 u8
 * @param lit7 u8
 * @param lit8 u8
 * @return i32
 */
export function tcp_eq_at(name: *u8, base: usize, n: usize, lit0: u8, lit1: u8, lit2: u8, lit3: u8, lit4: u8, lit5: u8, lit6: u8, lit7: u8, lit8: u8): i32 {
  let i: usize = 0;
  let want: u8 = 0;
  while (i < n) {
    if (i == 0) { want = lit0; }
    if (i == 1) { want = lit1; }
    if (i == 2) { want = lit2; }
    if (i == 3) { want = lit3; }
    if (i == 4) { want = lit4; }
    if (i == 5) { want = lit5; }
    if (i == 6) { want = lit6; }
    if (i == 7) { want = lit7; }
    if (i == 8) { want = lit8; }
    if (tcp_tolower(name[base + i]) != want) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/** Exported function `tcp_set_u32`.
 * Implements `tcp_set_u32`.
 * @param out *u32
 * @param f u32
 * @return void
 */
export function tcp_set_u32(out: *u32, f: u32): void {
  out[0] = f;
}

/** Exported function `tcp_parse_named`.
 * Implements `tcp_parse_named`.
 * @param spec *u8
 * @param base usize
 * @param end usize
 * @param out *u32
 * @return i32
 */
export function tcp_parse_named(spec: *u8, base: usize, end: usize, out: *u32): i32 {
  let n: usize = 0;
  let f: u32 = 0;
  if (end < base) {
    return -1;
  }
  n = end - base;
  /* native */
  if (n == 6 && tcp_eq_at(spec, base, 6, 110, 97, 116, 105, 118, 101, 0, 0, 0) != 0) {
    unsafe { f = shu_target_cpu_detect_host(); }
    tcp_set_u32(out, f);
    return 0;
  }
  /* generic */
  if (n == 7 && tcp_eq_at(spec, base, 7, 103, 101, 110, 101, 114, 105, 99, 0, 0) != 0) {
    unsafe { f = shu_target_cpu_generic_for_host(); }
    tcp_set_u32(out, f);
    return 0;
  }
  /* sse2 */
  if (n == 4 && tcp_eq_at(spec, base, 4, 115, 115, 101, 50, 0, 0, 0, 0, 0) != 0) {
    tcp_set_u32(out, 1);
    return 0;
  }
  /* sse4.1 / sse4_1 */
  if (n == 6 && (tcp_eq_at(spec, base, 6, 115, 115, 101, 52, 46, 49, 0, 0, 0) != 0 ||
                 tcp_eq_at(spec, base, 6, 115, 115, 101, 52, 95, 49, 0, 0, 0) != 0)) {
    tcp_set_u32(out, 1 | 2);
    return 0;
  }
  /* avx */
  if (n == 3 && tcp_eq_at(spec, base, 3, 97, 118, 120, 0, 0, 0, 0, 0, 0) != 0) {
    tcp_set_u32(out, 1 | 2 | 4);
    return 0;
  }
  /* avx2 */
  if (n == 4 && tcp_eq_at(spec, base, 4, 97, 118, 120, 50, 0, 0, 0, 0, 0) != 0) {
    tcp_set_u32(out, 1 | 2 | 4 | 8);
    return 0;
  }
  /* avx512 */
  if (n == 6 && tcp_eq_at(spec, base, 6, 97, 118, 120, 53, 49, 50, 0, 0, 0) != 0) {
    tcp_set_u32(out, 1 | 2 | 4 | 8 | 16);
    return 0;
  }
  /* avx512f */
  if (n == 7 && tcp_eq_at(spec, base, 7, 97, 118, 120, 53, 49, 50, 102, 0, 0) != 0) {
    tcp_set_u32(out, 1 | 2 | 4 | 8 | 16);
    return 0;
  }
  /* x86-64-v2 */
  if (n == 9 && tcp_eq_at(spec, base, 9, 120, 56, 54, 45, 54, 52, 45, 118, 50) != 0) {
    tcp_set_u32(out, 1 | 2 | 32);
    return 0;
  }
  /* x86-64-v3 */
  if (n == 9 && tcp_eq_at(spec, base, 9, 120, 56, 54, 45, 54, 52, 45, 118, 51) != 0) {
    tcp_set_u32(out, 1 | 2 | 4 | 8 | 32 | 64);
    return 0;
  }
  /* x86-64-v4 */
  if (n == 9 && tcp_eq_at(spec, base, 9, 120, 56, 54, 45, 54, 52, 45, 118, 52) != 0) {
    tcp_set_u32(out, 1 | 2 | 4 | 8 | 16 | 32 | 64);
    return 0;
  }
  /* neon */
  if (n == 4 && tcp_eq_at(spec, base, 4, 110, 101, 111, 110, 0, 0, 0, 0, 0) != 0) {
    tcp_set_u32(out, 256);
    return 0;
  }
  /* sve */
  if (n == 3 && tcp_eq_at(spec, base, 3, 115, 118, 101, 0, 0, 0, 0, 0, 0) != 0) {
    tcp_set_u32(out, 256 | 512);
    return 0;
  }
  /* rvv */
  if (n == 3 && tcp_eq_at(spec, base, 3, 114, 118, 118, 0, 0, 0, 0, 0, 0) != 0) {
    tcp_set_u32(out, 65536);
    return 0;
  }
  return -1;
}

#[no_mangle]
/** Exported function `shu_target_cpu_resolve`.
 * Implements `shu_target_cpu_resolve`.
 * @param spec *u8
 * @param spec_len usize
 * @param out *u32
 * @return i32
 */
export function shu_target_cpu_resolve(spec: *u8, spec_len: usize, out: *u32): i32 {
  let start: usize = 0;
  let end: usize = 0;
  let f: u32 = 0;
  if (out == 0 as *u32) {
    return -1;
  }
  if (spec == 0 as *u8 || spec_len == 0) {
    unsafe { f = shu_target_cpu_detect_host(); }
    tcp_set_u32(out, f);
    return 0;
  }
  end = spec_len;
  while (start < end && (spec[start] == 32 || spec[start] == 9)) {
    start = start + 1;
  }
  while (end > start && (spec[end - 1] == 32 || spec[end - 1] == 9)) {
    end = end - 1;
  }
  if (end <= start) {
    unsafe { f = shu_target_cpu_detect_host(); }
    tcp_set_u32(out, f);
    return 0;
  }
  return tcp_parse_named(spec, start, end, out);
}

#[no_mangle]
/** Exported function `tcp_eq5`.
 * Implements `tcp_eq5`.
 * @param name *u8
 * @param a0 u8
 * @param a1 u8
 * @param a2 u8
 * @param a3 u8
 * @param a4 u8
 * @return i32
 */
export function tcp_eq5(name: *u8, a0: u8, a1: u8, a2: u8, a3: u8, a4: u8): i32 {
  return tcp_eq_at(name, 0, 5, a0, a1, a2, a3, a4, 0, 0, 0, 0);
}

#[no_mangle]
/** Exported function `tcp_eq6`.
 * Implements `tcp_eq6`.
 * @param name *u8
 * @param a0 u8
 * @param a1 u8
 * @param a2 u8
 * @param a3 u8
 * @param a4 u8
 * @param a5 u8
 * @return i32
 */
export function tcp_eq6(name: *u8, a0: u8, a1: u8, a2: u8, a3: u8, a4: u8, a5: u8): i32 {
  return tcp_eq_at(name, 0, 6, a0, a1, a2, a3, a4, a5, 0, 0, 0);
}

#[no_mangle]
/** Exported function `shu_simd_is_vector_type_spelling`.
 * Implements `shu_simd_is_vector_type_spelling`.
 * @param name *u8
 * @param name_len usize
 * @return i32
 */
export function shu_simd_is_vector_type_spelling(name: *u8, name_len: usize): i32 {
  if (name == 0 as *u8 || name_len == 0) {
    return 0;
  }
  if (name_len == 5) {
    if (tcp_eq5(name, 105, 51, 50, 120, 52) != 0) { return 1; }
    if (tcp_eq5(name, 105, 51, 50, 120, 56) != 0) { return 1; }
    if (tcp_eq5(name, 117, 51, 50, 120, 52) != 0) { return 1; }
    if (tcp_eq5(name, 117, 51, 50, 120, 56) != 0) { return 1; }
    if (tcp_eq5(name, 102, 51, 50, 120, 52) != 0) { return 1; }
    if (tcp_eq5(name, 118, 101, 99, 52, 102) != 0) { return 1; }
    if (tcp_eq5(name, 118, 101, 99, 56, 105) != 0) { return 1; }
  }
  if (name_len == 6) {
    if (tcp_eq6(name, 105, 51, 50, 120, 49, 54) != 0) { return 1; }
    if (tcp_eq6(name, 117, 51, 50, 120, 49, 54) != 0) { return 1; }
  }
  return 0;
}

#[no_mangle]
/** Exported function `shu_simd_vector_lanes_esz_from_spelling`.
 * Implements `shu_simd_vector_lanes_esz_from_spelling`.
 * @param name *u8
 * @param name_len usize
 * @param out_lanes *i32
 * @param out_esz *i32
 * @return i32
 */
export function shu_simd_vector_lanes_esz_from_spelling(name: *u8, name_len: usize, out_lanes: *i32, out_esz: *i32): i32 {
  let lanes: i32 = 4;
  let esz: i32 = 4;
  if (out_lanes == 0 as *i32 || out_esz == 0 as *i32) {
    return -1;
  }
  if (shu_simd_is_vector_type_spelling(name, name_len) == 0) {
    return -1;
  }
  if (name_len == 5 && name[4] == 56) {
    lanes = 8;
  }
  if (name_len == 6 && name[4] == 49 && name[5] == 54) {
    lanes = 16;
  }
  if (name_len == 5 && tcp_eq5(name, 118, 101, 99, 56, 105) != 0) {
    lanes = 8;
  }
  out_lanes[0] = lanes;
  out_esz[0] = esz;
  return 0;
}

/* See implementation. */

// append_feat_name: see function docblock below.
#[no_mangle]
/** Exported function `append_feat_name`.
 * Implements `append_feat_name`.
 * @param buf *u8
 * @param cap usize
 * @param pos *usize
 * @param name *u8
 * @return void
 */
export function append_feat_name(buf: *u8, cap: usize, pos: *usize, name: *u8): void {
  if (buf == 0) { return; }
  if (pos == 0) { return; }
  if (name == 0) { return; }
  let p: usize = pos[0];
  if (p >= cap) { return; }
  if (p > 0) {
    if (p + 1 < cap) {
      buf[p as i32] = 44;
      p = p + 1;
    }
  }
  let nlen: usize = 0;
  while (nlen < 256) {
    if (name[nlen as i32] == 0) { break; }
    nlen = nlen + 1;
  }
  if (p + nlen >= cap) { return; }
  let i: usize = 0;
  while (i < nlen) {
    buf[(p + i) as i32] = name[i as i32];
    i = i + 1;
  }
  p = p + nlen;
  buf[p as i32] = 0;
  pos[0] = p;
}

// flags_has_token: see function docblock below.
#[no_mangle]
/** Exported function `flags_has_token`.
 * Implements `flags_has_token`.
 * @param hay *u8
 * @param token *u8
 * @return i32
 */
export function flags_has_token(hay: *u8, token: *u8): i32 {
  if (hay == 0) { return 0; }
  if (token == 0) { return 0; }
  let tlen: i32 = 0;
  while (tlen < 256) {
    if (token[tlen] == 0) { break; }
    tlen = tlen + 1;
  }
  if (tlen <= 0) { return 0; }
  let i: i32 = 0;
  while (i < 65536) {
    if (hay[i] == 0) { break; }
    let ok: i32 = 1;
    let j: i32 = 0;
    while (j < tlen) {
      if (hay[i + j] != token[j]) {
        ok = 0;
        break;
      }
      j = j + 1;
    }
    if (ok != 0) {
      let b_ok: i32 = 0;
      if (i == 0) {
        b_ok = 1;
      } else {
        let before: u8 = hay[i - 1];
        if (before == 32) { b_ok = 1; }
        if (before == 9) { b_ok = 1; }
        if (before == 44) { b_ok = 1; }
      }
      let after: u8 = hay[i + tlen];
      let a_ok: i32 = 0;
      if (after == 0) { a_ok = 1; }
      if (after == 32) { a_ok = 1; }
      if (after == 9) { a_ok = 1; }
      if (after == 44) { a_ok = 1; }
      if (after == 10) { a_ok = 1; }
      if (b_ok != 0) {
        if (a_ok != 0) { return 1; }
      }
    }
    i = i + 1;
  }
  return 0;
}

// See implementation.
/* See implementation. */
