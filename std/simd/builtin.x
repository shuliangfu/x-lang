// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0
//
// Stage 10 (10.5.1) slice0–7: language SIMD builtins — panic bodies.
// Asm backend intercepts CALL/METHOD_CALL by name
// (try_emit_simd_lang_builtin_call_elf_c). Host-C / non-x86 fall through
// to panic until later slices.
// PLATFORM: SHARED surface; LINUX|x86_64 asm SSE/AVX/FMA lowering (Vec4f).

/**
 * Hardware f32x4 vector add (4-wide SSE addps).
 * Asm replaces the call with movups + addps + movups on stack slots.
 * @param a Vec4f — first operand
 * @param b Vec4f — second operand
 * @return Vec4f — lane-wise sum
 * PLATFORM: SHARED · asm LINUX|x86_64 (SSE); host-C / aarch64 panic
 */
export function add_f32x4(a: Vec4f, b: Vec4f): Vec4f {
  panic();
  return [0.0, 0.0, 0.0, 0.0];
}

/**
 * Hardware f32x4 vector multiply (4-wide SSE mulps).
 * Asm replaces the call with movups + mulps + movups on stack slots.
 * @param a Vec4f — first operand
 * @param b Vec4f — second operand
 * @return Vec4f — lane-wise product
 * PLATFORM: SHARED · asm LINUX|x86_64 (SSE); host-C / aarch64 panic
 */
export function mul_f32x4(a: Vec4f, b: Vec4f): Vec4f {
  panic();
  return [0.0, 0.0, 0.0, 0.0];
}

/**
 * Hardware f32x4 vector subtract (4-wide SSE subps).
 * Asm replaces the call with movups + subps + movups on stack slots.
 * @param a Vec4f — minuend
 * @param b Vec4f — subtrahend
 * @return Vec4f — lane-wise difference
 * PLATFORM: SHARED · asm LINUX|x86_64 (SSE); host-C / aarch64 panic
 */
export function sub_f32x4(a: Vec4f, b: Vec4f): Vec4f {
  panic();
  return [0.0, 0.0, 0.0, 0.0];
}

/**
 * Hardware f32x4 fused multiply-add: lane-wise `a + b * c`.
 * Asm replaces the call with FMA3 vfmadd231ps when available, else mulps+addps.
 * @param a Vec4f — addend
 * @param b Vec4f — multiplicand
 * @param c Vec4f — multiplier
 * @return Vec4f — lane-wise a + b*c
 * PLATFORM: SHARED · asm LINUX|x86_64 (SSE/FMA3); host-C / aarch64 panic
 */
export function fma_f32x4(a: Vec4f, b: Vec4f, c: Vec4f): Vec4f {
  panic();
  return [0.0, 0.0, 0.0, 0.0];
}

/**
 * Hardware i32x8 vector add (8-wide SSE2 paddd or AVX2 vpaddd).
 * Asm replaces the call with movups + paddd/vpaddd into the sret let slot.
 * @param a Vec8i — first operand (32B stack home)
 * @param b Vec8i — second operand
 * @return Vec8i — lane-wise sum (>16B sret into let slot)
 * PLATFORM: SHARED · asm LINUX|x86_64 (SSE2/AVX2); host-C / aarch64 panic
 */
export function add_i32x8(a: Vec8i, b: Vec8i): Vec8i {
  panic();
  return [0, 0, 0, 0, 0, 0, 0, 0];
}

/**
 * Hardware i32x8 vector multiply (8-wide SSE4.1 pmulld or AVX2 vpmulld).
 * Asm replaces the call with movups + pmulld/vpmulld into the sret let slot.
 * @param a Vec8i — first operand
 * @param b Vec8i — second operand
 * @return Vec8i — lane-wise product (>16B sret into let slot)
 * PLATFORM: SHARED · asm LINUX|x86_64 (SSE4.1/AVX2); host-C / aarch64 panic
 */
export function mul_i32x8(a: Vec8i, b: Vec8i): Vec8i {
  panic();
  return [0, 0, 0, 0, 0, 0, 0, 0];
}

/**
 * Hardware f32x8 vector add (8-wide AVX vaddps or dual SSE addps).
 * Asm replaces the call with ymm/xmm movups + vaddps/addps into sret let slot.
 * @param a f32x8 — first operand (32B stack home)
 * @param b f32x8 — second operand
 * @return f32x8 — lane-wise sum (>16B sret into let slot)
 * PLATFORM: SHARED · asm LINUX|x86_64 (AVX2 ymm preferred); host-C / aarch64 panic
 */
export function add_f32x8(a: f32x8, b: f32x8): f32x8 {
  panic();
  return [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
}

/**
 * Hardware f32x8 vector multiply (8-wide AVX vmulps or dual SSE mulps).
 * @param a f32x8 — first operand
 * @param b f32x8 — second operand
 * @return f32x8 — lane-wise product (>16B sret into let slot)
 * PLATFORM: SHARED · asm LINUX|x86_64 (AVX2 ymm preferred); host-C / aarch64 panic
 */
export function mul_f32x8(a: f32x8, b: f32x8): f32x8 {
  panic();
  return [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
}

/**
 * Hardware f32x8 vector subtract (8-wide AVX vsubps or dual SSE subps).
 * @param a f32x8 — minuend
 * @param b f32x8 — subtrahend
 * @return f32x8 — lane-wise difference (>16B sret into let slot)
 * PLATFORM: SHARED · asm LINUX|x86_64 (AVX2 ymm preferred); host-C / aarch64 panic
 */
export function sub_f32x8(a: f32x8, b: f32x8): f32x8 {
  panic();
  return [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
}

/**
 * Hardware i32x8 vector subtract (8-wide SSE2 psubd or AVX2 vpsubd).
 * Asm replaces the call with movups + psubd/vpsubd into the sret let slot.
 * @param a Vec8i — minuend (32B stack home)
 * @param b Vec8i — subtrahend
 * @return Vec8i — lane-wise difference (>16B sret into let slot)
 * PLATFORM: SHARED · asm LINUX|x86_64 (SSE2/AVX2); host-C / aarch64 panic
 */
export function sub_i32x8(a: Vec8i, b: Vec8i): Vec8i {
  panic();
  return [0, 0, 0, 0, 0, 0, 0, 0];
}
