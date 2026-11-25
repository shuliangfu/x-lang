// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// std_simd_formal_darwin.x — Darwin arm64 + Linux body of std/simd/simd.o.
//
// Twin of std/simd/formal_surface.c. f32x4 is INTEGER dual-GP {lo,hi}
// (not float[4] / SSE). i32x8 is 32B MEMORY as eight i32 fields.
// Windows keeps formal_surface.c (记224).
// PLATFORM: MACOS|DARWIN arm64 | LINUX.

extern function memcpy(dst: *u8, src: *u8, n: u64): *u8;
extern "C" function getenv(name: *u8): *u8;

/** INTEGER dual-GP 16B — SysV rdi+rsi / ret rax+rdx. */
struct F32x4 {
  lo: u64;
  hi: u64;
}

/** 32B MEMORY by-value. */
struct I32x8 {
  v0: i32;
  v1: i32;
  v2: i32;
  v3: i32;
  v4: i32;
  v5: i32;
  v6: i32;
  v7: i32;
}

// Cap tip: f32 formals are passed/returned in GPRs by callers, but some
// callees still read d0–d3. Keep lane/pack helpers on u32 bit patterns in
// GPRs only (knife256/10.2 shuffle_select SEGV→wrong-lane root).
// PLATFORM: MACOS Cap tip / SHARED formal.
function f32_store_bits(p: *u8, bits: u32): void {
  let x: u32 = bits;
  unsafe {
    let src: *u8 = &x as *u8;
    memcpy(p, src, 4);
  }
}

function f32_load_bits(p: *u8): u32 {
  let v: u32 = 0;
  unsafe {
    let dst: *u8 = &v as *u8;
    memcpy(dst, p, 4);
  }
  return v;
}

function f32_from_bits(bits: u32): f32 {
  let out: f32 = 0.0;
  let b: u32 = bits;
  unsafe {
    memcpy(&out as *u8, &b as *u8, 4);
  }
  return out;
}

function f32_to_bits(v: f32): u32 {
  let b: u32 = 0;
  let t: f32 = v;
  unsafe {
    memcpy(&b as *u8, &t as *u8, 4);
  }
  return b;
}

function f32x4_from_lanes(o: *F32x4, a: u32, b: u32, c: u32, d: u32): void {
  unsafe {
    let q: *u8 = o as *u8;
    f32_store_bits(q, a);
    f32_store_bits(q + 4, b);
    f32_store_bits(q + 8, c);
    f32_store_bits(q + 12, d);
  }
}

function f32x4_lane_bits(v: F32x4, i: i32): u32 {
  let tmp: F32x4 = v;
  unsafe {
    let q: *u8 = &tmp as *u8;
    if (i == 0) { return f32_load_bits(q); }
    if (i == 1) { return f32_load_bits(q + 4); }
    if (i == 2) { return f32_load_bits(q + 8); }
    return f32_load_bits(q + 12);
  }
}

function f32x4_lane(v: F32x4, i: i32): f32 {
  return f32_from_bits(f32x4_lane_bits(v, i));
}

function i32x8_get(v: I32x8, i: i32): i32 {
  if (i == 0) { return v.v0; }
  if (i == 1) { return v.v1; }
  if (i == 2) { return v.v2; }
  if (i == 3) { return v.v3; }
  if (i == 4) { return v.v4; }
  if (i == 5) { return v.v5; }
  if (i == 6) { return v.v6; }
  return v.v7;
}

function i32x8_set(v: *I32x8, i: i32, x: i32): void {
  if (i == 0) { v.v0 = x; return; }
  if (i == 1) { v.v1 = x; return; }
  if (i == 2) { v.v2 = x; return; }
  if (i == 3) { v.v3 = x; return; }
  if (i == 4) { v.v4 = x; return; }
  if (i == 5) { v.v5 = x; return; }
  if (i == 6) { v.v6 = x; return; }
  v.v7 = x;
}

function simd_cstr_eq(a: *u8, b: *u8): i32 {
  if (a == 0) { return 0; }
  if (b == 0) { return 0; }
  let i: i32 = 0;
  while (i < 256) {
    let ca: u8 = 0;
    let cb: u8 = 0;
    unsafe {
      ca = a[i];
      cb = b[i];
    }
    if (ca != cb) { return 0; }
    if (ca == 0) { return 1; }
    i = i + 1;
  }
  return 0;
}

#[no_mangle]
export function std_simd_formal_darwin_x_doc_anchor(): i32 {
  return 0;
}

#[no_mangle]
export function std_simd_placeholder(): i32 {
  return 0;
}

#[no_mangle]
export function std_simd_SIMD_PATH_SCALAR(): i32 {
  return 0;
}

#[no_mangle]
export function std_simd_SIMD_PATH_HW(): i32 {
  return 1;
}

#[no_mangle]
export function std_simd_hw_available(): i32 {
  return 1;
}

#[no_mangle]
export function std_simd_recommend_path(): i32 {
  // XLANG_SIMD_HW / XLANG_SIMD_AUTovec — same rules as formal_surface.c
  let k_hw: u8[14] = [88, 76, 65, 78, 71, 95, 83, 73, 77, 68, 95, 72, 87, 0];
  let k_aut: u8[19] = [88, 76, 65, 78, 71, 95, 83, 73, 77, 68, 95, 65, 85, 84, 111, 118, 101, 99, 0];
  let s_scalar: u8[7] = [115, 99, 97, 108, 97, 114, 0];
  let s0: u8[2] = [48, 0];
  unsafe {
    let hw: *u8 = getenv(&k_hw[0]);
    if (hw != 0) {
      if (hw[0] == 48) {
        if (hw[1] == 0) { return 0; }
      }
    }
    let aut: *u8 = getenv(&k_aut[0]);
    if (aut != 0) {
      if (simd_cstr_eq(aut, &s_scalar[0]) != 0) { return 0; }
      if (simd_cstr_eq(aut, &s0[0]) != 0) { return 0; }
    }
  }
  if (std_simd_hw_available() != 0) { return 1; }
  return 0;
}

#[no_mangle]
export function simd_hw_available_c(): i32 {
  return std_simd_hw_available();
}

#[no_mangle]
export function simd_recommend_path_c(): i32 {
  return std_simd_recommend_path();
}

#[no_mangle]
export function std_simd_splat_f32(x: f32): F32x4 {
  let r: F32x4 = { lo: 0, hi: 0 };
  let xb: u32 = f32_to_bits(x);
  f32x4_from_lanes(&r, xb, xb, xb, xb);
  return r;
}

#[no_mangle]
export function std_simd_splat_i32(x: i32): I32x8 {
  let r: I32x8 = { v0: x, v1: x, v2: x, v3: x, v4: x, v5: x, v6: x, v7: x };
  return r;
}

#[no_mangle]
export function std_simd_select_lane_i32_i32_i32(mask_lane: i32, a_lane: i32, b_lane: i32): i32 {
  if (mask_lane != 0) { return a_lane; }
  return b_lane;
}

#[no_mangle]
export function std_simd_select_lane_f32_f32_f32(mask_lane: f32, a_lane: f32, b_lane: f32): f32 {
  // Cap tip passes f32 lanes in GPRs; compare via bits (knife256/10.2).
  let mb: u32 = f32_to_bits(mask_lane);
  let ab: u32 = f32_to_bits(a_lane);
  let bb: u32 = f32_to_bits(b_lane);
  if (mb != 0) { return f32_from_bits(ab); }
  return f32_from_bits(bb);
}

function select_lane_f32_bits(mask_bits: u32, a_bits: u32, b_bits: u32): u32 {
  if (mask_bits != 0) { return a_bits; }
  return b_bits;
}

#[no_mangle]
export function std_simd_hsum(v: F32x4): f32 {
  return f32x4_lane(v, 0) + f32x4_lane(v, 1) + f32x4_lane(v, 2) + f32x4_lane(v, 3);
}

#[no_mangle]
export function std_simd_add_f32x4_f32x4(a: F32x4, b: F32x4): F32x4 {
  let r: F32x4 = { lo: 0, hi: 0 };
  f32x4_from_lanes(&r,
    f32_to_bits(f32x4_lane(a, 0) + f32x4_lane(b, 0)),
    f32_to_bits(f32x4_lane(a, 1) + f32x4_lane(b, 1)),
    f32_to_bits(f32x4_lane(a, 2) + f32x4_lane(b, 2)),
    f32_to_bits(f32x4_lane(a, 3) + f32x4_lane(b, 3)));
  return r;
}

#[no_mangle]
export function std_simd_sub_f32x4_f32x4(a: F32x4, b: F32x4): F32x4 {
  let r: F32x4 = { lo: 0, hi: 0 };
  f32x4_from_lanes(&r,
    f32_to_bits(f32x4_lane(a, 0) - f32x4_lane(b, 0)),
    f32_to_bits(f32x4_lane(a, 1) - f32x4_lane(b, 1)),
    f32_to_bits(f32x4_lane(a, 2) - f32x4_lane(b, 2)),
    f32_to_bits(f32x4_lane(a, 3) - f32x4_lane(b, 3)));
  return r;
}

#[no_mangle]
export function std_simd_mul_f32x4_f32x4(a: F32x4, b: F32x4): F32x4 {
  let r: F32x4 = { lo: 0, hi: 0 };
  f32x4_from_lanes(&r,
    f32_to_bits(f32x4_lane(a, 0) * f32x4_lane(b, 0)),
    f32_to_bits(f32x4_lane(a, 1) * f32x4_lane(b, 1)),
    f32_to_bits(f32x4_lane(a, 2) * f32x4_lane(b, 2)),
    f32_to_bits(f32x4_lane(a, 3) * f32x4_lane(b, 3)));
  return r;
}

#[no_mangle]
export function std_simd_dot(a: F32x4, b: F32x4): f32 {
  return std_simd_hsum(std_simd_mul_f32x4_f32x4(a, b));
}

#[no_mangle]
export function std_simd_fma(a: F32x4, b: F32x4, c: F32x4): F32x4 {
  let r: F32x4 = { lo: 0, hi: 0 };
  f32x4_from_lanes(&r,
    f32_to_bits(f32x4_lane(a, 0) + f32x4_lane(b, 0) * f32x4_lane(c, 0)),
    f32_to_bits(f32x4_lane(a, 1) + f32x4_lane(b, 1) * f32x4_lane(c, 1)),
    f32_to_bits(f32x4_lane(a, 2) + f32x4_lane(b, 2) * f32x4_lane(c, 2)),
    f32_to_bits(f32x4_lane(a, 3) + f32x4_lane(b, 3) * f32x4_lane(c, 3)));
  return r;
}

#[no_mangle]
export function std_simd_madd(a: F32x4, b: F32x4, c: F32x4): F32x4 {
  return std_simd_fma(a, b, c);
}

#[no_mangle]
export function std_simd_add_i32x8_i32x8(a: I32x8, b: I32x8): I32x8 {
  let r: I32x8 = {
    v0: a.v0 + b.v0, v1: a.v1 + b.v1, v2: a.v2 + b.v2, v3: a.v3 + b.v3,
    v4: a.v4 + b.v4, v5: a.v5 + b.v5, v6: a.v6 + b.v6, v7: a.v7 + b.v7
  };
  return r;
}

#[no_mangle]
export function std_simd_sub_i32x8_i32x8(a: I32x8, b: I32x8): I32x8 {
  let r: I32x8 = {
    v0: a.v0 - b.v0, v1: a.v1 - b.v1, v2: a.v2 - b.v2, v3: a.v3 - b.v3,
    v4: a.v4 - b.v4, v5: a.v5 - b.v5, v6: a.v6 - b.v6, v7: a.v7 - b.v7
  };
  return r;
}

#[no_mangle]
export function std_simd_mul_i32x8_i32x8(a: I32x8, b: I32x8): I32x8 {
  let r: I32x8 = {
    v0: a.v0 * b.v0, v1: a.v1 * b.v1, v2: a.v2 * b.v2, v3: a.v3 * b.v3,
    v4: a.v4 * b.v4, v5: a.v5 * b.v5, v6: a.v6 * b.v6, v7: a.v7 * b.v7
  };
  return r;
}

#[no_mangle]
export function std_simd_select_i32x8_i32x8_i32x8(mask: I32x8, a: I32x8, b: I32x8): I32x8 {
  let r: I32x8 = { v0: 0, v1: 0, v2: 0, v3: 0, v4: 0, v5: 0, v6: 0, v7: 0 };
  let i: i32 = 0;
  while (i < 8) {
    i32x8_set(&r, i, std_simd_select_lane_i32_i32_i32(i32x8_get(mask, i), i32x8_get(a, i), i32x8_get(b, i)));
    i = i + 1;
  }
  return r;
}

#[no_mangle]
export function std_simd_select_f32x4_f32x4_f32x4(mask: F32x4, a: F32x4, b: F32x4): F32x4 {
  let r: F32x4 = { lo: 0, hi: 0 };
  f32x4_from_lanes(&r,
    select_lane_f32_bits(f32x4_lane_bits(mask, 0), f32x4_lane_bits(a, 0), f32x4_lane_bits(b, 0)),
    select_lane_f32_bits(f32x4_lane_bits(mask, 1), f32x4_lane_bits(a, 1), f32x4_lane_bits(b, 1)),
    select_lane_f32_bits(f32x4_lane_bits(mask, 2), f32x4_lane_bits(a, 2), f32x4_lane_bits(b, 2)),
    select_lane_f32_bits(f32x4_lane_bits(mask, 3), f32x4_lane_bits(a, 3), f32x4_lane_bits(b, 3)));
  return r;
}

#[no_mangle]
export function std_simd_shuffle_f32x4_i32_a4(v: F32x4, mask: *i32): F32x4 {
  let i0: i32 = 0;
  let i1: i32 = 0;
  let i2: i32 = 0;
  let i3: i32 = 0;
  unsafe {
    if (mask != 0) {
      i0 = mask[0];
      i1 = mask[1];
      i2 = mask[2];
      i3 = mask[3];
    }
  }
  let r: F32x4 = { lo: 0, hi: 0 };
  f32x4_from_lanes(&r,
    f32x4_lane_bits(v, i0 & 3),
    f32x4_lane_bits(v, i1 & 3),
    f32x4_lane_bits(v, i2 & 3),
    f32x4_lane_bits(v, i3 & 3));
  return r;
}

#[no_mangle]
export function std_simd_shuffle_i32x8_i32_a8(v: I32x8, mask: *i32): I32x8 {
  let r: I32x8 = { v0: 0, v1: 0, v2: 0, v3: 0, v4: 0, v5: 0, v6: 0, v7: 0 };
  let i: i32 = 0;
  while (i < 8) {
    let idx: i32 = 0;
    unsafe {
      if (mask != 0) { idx = mask[i]; }
    }
    i32x8_set(&r, i, i32x8_get(v, idx & 7));
    i = i + 1;
  }
  return r;
}
