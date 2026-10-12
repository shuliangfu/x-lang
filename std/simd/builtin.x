// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0
//
// Stage 10 (10.5.1) slice0–10: language SIMD builtins.
// Asm backend intercepts CALL/METHOD_CALL by name
// (try_emit_simd_lang_builtin_call_elf_c) and emits HW ops.
// Host-C / missing HW feats fall through to these scalar lane bodies
// (slice10; no panic).
// PLATFORM: SHARED surface; LINUX|x86_64 asm SSE/AVX/FMA · aarch64 NEON;
//   host-C scalar fallthrough.

/**
 * Hardware f32x4 vector add (4-wide SSE/NEON when intercepted).
 * Host-C / fallthrough: lane-wise scalar sum.
 * @param a Vec4f — first operand
 * @param b Vec4f — second operand
 * @param out *f32 — four lanes; must not be null
 * @return i32 — 0 after the lanes are written
 * PLATFORM: SHARED — the installed product cannot asm-emit a Vec4f return.
 */
export function add_f32x4(a: Vec4f, b: Vec4f, out: *f32): i32 {
  /* A Vec4f return does not asm-emit. Four f32 lanes stay in the caller buffer. */
  out[0] = a[0] + b[0];
  out[1] = a[1] + b[1];
  out[2] = a[2] + b[2];
  out[3] = a[3] + b[3];
  return 0;
}

/**
 * Hardware f32x4 vector multiply (4-wide SSE/NEON when intercepted).
 * Host-C / fallthrough: lane-wise scalar product.
 * @param a Vec4f — first operand
 * @param b Vec4f — second operand
 * @param out *f32 — four lanes; must not be null
 * @return i32 — 0 after the lanes are written
 * PLATFORM: SHARED — the installed product cannot asm-emit a Vec4f return.
 */
export function mul_f32x4(a: Vec4f, b: Vec4f, out: *f32): i32 {
  out[0] = a[0] * b[0];
  out[1] = a[1] * b[1];
  out[2] = a[2] * b[2];
  out[3] = a[3] * b[3];
  return 0;
}

/**
 * Hardware f32x4 vector subtract (4-wide SSE/NEON when intercepted).
 * Host-C / fallthrough: lane-wise scalar difference.
 * @param a Vec4f — minuend
 * @param b Vec4f — subtrahend
 * @param out *f32 — four lanes; must not be null
 * @return i32 — 0 after the lanes are written
 * PLATFORM: SHARED — the installed product cannot asm-emit a Vec4f return.
 */
export function sub_f32x4(a: Vec4f, b: Vec4f, out: *f32): i32 {
  out[0] = a[0] - b[0];
  out[1] = a[1] - b[1];
  out[2] = a[2] - b[2];
  out[3] = a[3] - b[3];
  return 0;
}

/**
 * Hardware f32x4 fused multiply-add: lane-wise `a + b * c`.
 * Host-C / fallthrough: scalar a[i] + b[i]*c[i].
 * @param a Vec4f — addend
 * @param b Vec4f — multiplicand
 * @param c Vec4f — multiplier
 * @param out *f32 — four lanes; must not be null
 * @return i32 — 0 after the lanes are written
 * PLATFORM: SHARED — the installed product cannot asm-emit a Vec4f return.
 */
export function fma_f32x4(a: Vec4f, b: Vec4f, c: Vec4f, out: *f32): i32 {
  out[0] = a[0] + b[0] * c[0];
  out[1] = a[1] + b[1] * c[1];
  out[2] = a[2] + b[2] * c[2];
  out[3] = a[3] + b[3] * c[3];
  return 0;
}

/**
 * Hardware f32x4 horizontal sum of lanes into one f32.
 * Host-C / fallthrough: scalar sum of four lanes.
 * @param v Vec4f — vector to reduce
 * @param out *f32 — one sum; must not be null
 * @return i32 — 0 after the sum is written
 * PLATFORM: SHARED — the installed product cannot asm-emit an f32 return.
 */
export function hsum_f32x4(v: Vec4f, out: *f32): i32 {
  /* f32 uses xmm0. The sum is stored, not returned in a register. */
  out[0] = v[0] + v[1] + v[2] + v[3];
  return 0;
}

/**
 * Hardware f32x4 dot product: sum of lane-wise products.
 * Host-C / fallthrough: scalar sum of a[i]*b[i].
 * @param a Vec4f — first operand
 * @param b Vec4f — second operand
 * @param out *f32 — one dot product; must not be null
 * @return i32 — 0 after the product is written
 * PLATFORM: SHARED — the installed product cannot asm-emit an f32 return.
 */
export function dot_f32x4(a: Vec4f, b: Vec4f, out: *f32): i32 {
  let p: f32[4] = [0.0, 0.0, 0.0, 0.0];
  mul_f32x4(a, b, &p[0]);
  out[0] = p[0] + p[1] + p[2] + p[3];
  return 0;
}

/**
 * Hardware i32x8 vector add (SSE2/AVX2/NEON when intercepted).
 * Host-C / fallthrough: lane-wise scalar sum.
 * @param a Vec8i — first operand (32B stack home)
 * @param b Vec8i — second operand
 * @param out *i32 — eight lanes; must not be null
 * @return i32 — 0 after the lanes are written
 * PLATFORM: SHARED — the installed product cannot asm-emit a Vec8i return.
 */
export function add_i32x8(a: Vec8i, b: Vec8i, out: *i32): i32 {
  out[0] = a[0] + b[0];
  out[1] = a[1] + b[1];
  out[2] = a[2] + b[2];
  out[3] = a[3] + b[3];
  out[4] = a[4] + b[4];
  out[5] = a[5] + b[5];
  out[6] = a[6] + b[6];
  out[7] = a[7] + b[7];
  return 0;
}

/**
 * Hardware i32x8 vector multiply (SSE4.1/AVX2/NEON when intercepted).
 * Host-C / fallthrough: lane-wise scalar product.
 * @param a Vec8i — first operand
 * @param b Vec8i — second operand
 * @param out *i32 — eight lanes; must not be null
 * @return i32 — 0 after the lanes are written
 * PLATFORM: SHARED — the installed product cannot asm-emit a Vec8i return.
 */
export function mul_i32x8(a: Vec8i, b: Vec8i, out: *i32): i32 {
  out[0] = a[0] * b[0];
  out[1] = a[1] * b[1];
  out[2] = a[2] * b[2];
  out[3] = a[3] * b[3];
  out[4] = a[4] * b[4];
  out[5] = a[5] * b[5];
  out[6] = a[6] * b[6];
  out[7] = a[7] * b[7];
  return 0;
}

/**
 * Hardware f32x8 vector add (AVX/NEON when intercepted).
 * Host-C / fallthrough: lane-wise scalar sum.
 * @param a f32x8 — first operand (32B stack home)
 * @param b f32x8 — second operand
 * @param out *f32 — eight lanes; must not be null
 * @return i32 — 0 after the lanes are written
 * PLATFORM: SHARED — the installed product cannot asm-emit an f32x8 return.
 */
export function add_f32x8(a: f32x8, b: f32x8, out: *f32): i32 {
  out[0] = a[0] + b[0];
  out[1] = a[1] + b[1];
  out[2] = a[2] + b[2];
  out[3] = a[3] + b[3];
  out[4] = a[4] + b[4];
  out[5] = a[5] + b[5];
  out[6] = a[6] + b[6];
  out[7] = a[7] + b[7];
  return 0;
}

/**
 * Hardware f32x8 vector multiply (AVX/NEON when intercepted).
 * Host-C / fallthrough: lane-wise scalar product.
 * @param a f32x8 — first operand
 * @param b f32x8 — second operand
 * @param out *f32 — eight lanes; must not be null
 * @return i32 — 0 after the lanes are written
 * PLATFORM: SHARED — the installed product cannot asm-emit an f32x8 return.
 */
export function mul_f32x8(a: f32x8, b: f32x8, out: *f32): i32 {
  out[0] = a[0] * b[0];
  out[1] = a[1] * b[1];
  out[2] = a[2] * b[2];
  out[3] = a[3] * b[3];
  out[4] = a[4] * b[4];
  out[5] = a[5] * b[5];
  out[6] = a[6] * b[6];
  out[7] = a[7] * b[7];
  return 0;
}

/**
 * Hardware f32x8 vector subtract (AVX/NEON when intercepted).
 * Host-C / fallthrough: lane-wise scalar difference.
 * @param a f32x8 — minuend
 * @param b f32x8 — subtrahend
 * @param out *f32 — eight lanes; must not be null
 * @return i32 — 0 after the lanes are written
 * PLATFORM: SHARED — the installed product cannot asm-emit an f32x8 return.
 */
export function sub_f32x8(a: f32x8, b: f32x8, out: *f32): i32 {
  out[0] = a[0] - b[0];
  out[1] = a[1] - b[1];
  out[2] = a[2] - b[2];
  out[3] = a[3] - b[3];
  out[4] = a[4] - b[4];
  out[5] = a[5] - b[5];
  out[6] = a[6] - b[6];
  out[7] = a[7] - b[7];
  return 0;
}

/**
 * Hardware i32x8 vector subtract (SSE2/AVX2/NEON when intercepted).
 * Host-C / fallthrough: lane-wise scalar difference.
 * @param a Vec8i — minuend (32B stack home)
 * @param b Vec8i — subtrahend
 * @param out *i32 — eight lanes; must not be null
 * @return i32 — 0 after the lanes are written
 * PLATFORM: SHARED — the installed product cannot asm-emit a Vec8i return.
 */
export function sub_i32x8(a: Vec8i, b: Vec8i, out: *i32): i32 {
  out[0] = a[0] - b[0];
  out[1] = a[1] - b[1];
  out[2] = a[2] - b[2];
  out[3] = a[3] - b[3];
  out[4] = a[4] - b[4];
  out[5] = a[5] - b[5];
  out[6] = a[6] - b[6];
  out[7] = a[7] - b[7];
  return 0;
}
