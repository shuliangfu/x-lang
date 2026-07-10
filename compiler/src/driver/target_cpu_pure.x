// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-2/3/4：target_cpu 纯逻辑真迁 .x。
// - pending（f-2）
// - SIMD 拼写（f-3）
// - resolve 具名（f-4；native/generic → detect 半边）
//
// 冷启动：seeds/target_cpu_pure.from_x.c（与本文件语义对齐；全量 -E 可能卡）
// detect_host / generic_for_host / print 仍在 target_cpu.inc。

let g_driver_pending_target_cpu_features: u32 = 0;

extern function shu_target_cpu_detect_host(): u32;
extern function shu_target_cpu_generic_for_host(): u32;

#[no_mangle]
function driver_set_pending_target_cpu_features(features: u32): void {
  g_driver_pending_target_cpu_features = features;
}

#[no_mangle]
function driver_get_pending_target_cpu_features(): u32 {
  return g_driver_pending_target_cpu_features;
}

function tcp_tolower(c: u8): u8 {
  if (c >= 65 && c <= 90) {
    return (c + 32) as u8;
  }
  return c;
}

/** 从 name[base..] 比较 n 字节（忽略大小写）与固定小写序列（由调用方保证长度）。 */
function tcp_eq_at(name: *u8, base: usize, n: usize, lit0: u8, lit1: u8, lit2: u8, lit3: u8, lit4: u8, lit5: u8, lit6: u8, lit7: u8, lit8: u8): i32 {
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

function tcp_set_u32(out: *u32, f: u32): void {
  out[0] = f;
}

/** 具名规格；base/end 为 [base, end)。成功 0。 */
function tcp_parse_named(spec: *u8, base: usize, end: usize, out: *u32): i32 {
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
function shu_target_cpu_resolve(spec: *u8, spec_len: usize, out: *u32): i32 {
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

function tcp_eq5(name: *u8, a0: u8, a1: u8, a2: u8, a3: u8, a4: u8): i32 {
  return tcp_eq_at(name, 0, 5, a0, a1, a2, a3, a4, 0, 0, 0, 0);
}

function tcp_eq6(name: *u8, a0: u8, a1: u8, a2: u8, a3: u8, a4: u8, a5: u8): i32 {
  return tcp_eq_at(name, 0, 6, a0, a1, a2, a3, a4, a5, 0, 0, 0);
}

#[no_mangle]
function shu_simd_is_vector_type_spelling(name: *u8, name_len: usize): i32 {
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
function shu_simd_vector_lanes_esz_from_spelling(name: *u8, name_len: usize, out_lanes: *i32, out_esz: *i32): i32 {
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
