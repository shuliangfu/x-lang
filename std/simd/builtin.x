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
 * @return Vec4f — lane-wise sum
 * PLATFORM: SHARED · asm HW intercept · host-C scalar
 */
export function add_f32x4(a: Vec4f, b: Vec4f): Vec4f {
  return a + b;
}

/**
 * Hardware f32x4 vector multiply (4-wide SSE/NEON when intercepted).
 * Host-C / fallthrough: lane-wise scalar product.
 * @param a Vec4f — first operand
 * @param b Vec4f — second operand
 * @return Vec4f — lane-wise product
 * PLATFORM: SHARED · asm HW intercept · host-C scalar
 */
export function mul_f32x4(a: Vec4f, b: Vec4f): Vec4f {
  return a * b;
}

/**
 * Hardware f32x4 vector subtract (4-wide SSE/NEON when intercepted).
 * Host-C / fallthrough: lane-wise scalar difference.
 * @param a Vec4f — minuend
 * @param b Vec4f — subtrahend
 * @return Vec4f — lane-wise difference
 * PLATFORM: SHARED · asm HW intercept · host-C scalar
 */
export function sub_f32x4(a: Vec4f, b: Vec4f): Vec4f {
  return a - b;
}

/**
 * Hardware f32x4 fused multiply-add: lane-wise `a + b * c`.
 * Host-C / fallthrough: scalar a[i] + b[i]*c[i].
 * @param a Vec4f — addend
 * @param b Vec4f — multiplicand
 * @param c Vec4f — multiplier
 * @return Vec4f — lane-wise a + b*c
 * PLATFORM: SHARED · asm HW intercept · host-C scalar
 */
export function fma_f32x4(a: Vec4f, b: Vec4f, c: Vec4f): Vec4f {
  let r: Vec4f = [
    a[0] + b[0] * c[0],
    a[1] + b[1] * c[1],
    a[2] + b[2] * c[2],
    a[3] + b[3] * c[3]
  ];
  return r;
}

/**
 * Hardware f32x4 horizontal sum of lanes into one f32.
 * Host-C / fallthrough: scalar sum of four lanes.
 * @param v Vec4f — vector to reduce
 * @return f32 — v[0]+v[1]+v[2]+v[3]
 * PLATFORM: SHARED · asm HW intercept · host-C scalar
 */
export function hsum_f32x4(v: Vec4f): f32 {
  return v[0] + v[1] + v[2] + v[3];
}

/**
 * Hardware f32x4 dot product: sum of lane-wise products.
 * Host-C / fallthrough: scalar sum of a[i]*b[i].
 * @param a Vec4f — first operand
 * @param b Vec4f — second operand
 * @return f32 — sum_i a[i]*b[i]
 * PLATFORM: SHARED · asm HW intercept · host-C scalar
 */
export function dot_f32x4(a: Vec4f, b: Vec4f): f32 {
  return hsum_f32x4(mul_f32x4(a, b));
}

/**
 * Hardware i32x8 vector add (SSE2/AVX2/NEON when intercepted).
 * Host-C / fallthrough: lane-wise scalar sum.
 * @param a Vec8i — first operand (32B stack home)
 * @param b Vec8i — second operand
 * @return Vec8i — lane-wise sum
 * PLATFORM: SHARED · asm HW intercept · host-C scalar
 */
export function add_i32x8(a: Vec8i, b: Vec8i): Vec8i {
  return a + b;
}

/**
 * Hardware i32x8 vector multiply (SSE4.1/AVX2/NEON when intercepted).
 * Host-C / fallthrough: lane-wise scalar product.
 * @param a Vec8i — first operand
 * @param b Vec8i — second operand
 * @return Vec8i — lane-wise product
 * PLATFORM: SHARED · asm HW intercept · host-C scalar
 */
export function mul_i32x8(a: Vec8i, b: Vec8i): Vec8i {
  return a * b;
}

/**
 * Hardware f32x8 vector add (AVX/NEON when intercepted).
 * Host-C / fallthrough: lane-wise scalar sum.
 * @param a f32x8 — first operand (32B stack home)
 * @param b f32x8 — second operand
 * @return f32x8 — lane-wise sum
 * PLATFORM: SHARED · asm HW intercept · host-C scalar
 */
export function add_f32x8(a: f32x8, b: f32x8): f32x8 {
  return a + b;
}

/**
 * Hardware f32x8 vector multiply (AVX/NEON when intercepted).
 * Host-C / fallthrough: lane-wise scalar product.
 * @param a f32x8 — first operand
 * @param b f32x8 — second operand
 * @return f32x8 — lane-wise product
 * PLATFORM: SHARED · asm HW intercept · host-C scalar
 */
export function mul_f32x8(a: f32x8, b: f32x8): f32x8 {
  return a * b;
}

/**
 * Hardware f32x8 vector subtract (AVX/NEON when intercepted).
 * Host-C / fallthrough: lane-wise scalar difference.
 * @param a f32x8 — minuend
 * @param b f32x8 — subtrahend
 * @return f32x8 — lane-wise difference
 * PLATFORM: SHARED · asm HW intercept · host-C scalar
 */
export function sub_f32x8(a: f32x8, b: f32x8): f32x8 {
  return a - b;
}

/**
 * Hardware i32x8 vector subtract (SSE2/AVX2/NEON when intercepted).
 * Host-C / fallthrough: lane-wise scalar difference.
 * @param a Vec8i — minuend (32B stack home)
 * @param b Vec8i — subtrahend
 * @return Vec8i — lane-wise difference
 * PLATFORM: SHARED · asm HW intercept · host-C scalar
 */
export function sub_i32x8(a: Vec8i, b: Vec8i): Vec8i {
  return a - b;
}
