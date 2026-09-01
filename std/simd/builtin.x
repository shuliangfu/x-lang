// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0
//
// Stage 10 (10.5.1) slice0: language SIMD builtins — panic bodies.
// Asm backend intercepts CALL/METHOD_CALL by name
// (try_emit_simd_lang_builtin_call_elf_c). Host-C / non-x86 fall through
// to panic until later slices.
// PLATFORM: SHARED surface; LINUX|x86_64 asm SSE/AVX lowering (Vec4f).

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
