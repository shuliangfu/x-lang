// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0
//
// Stage 10 (10.4.1) slice1: language atomic builtins — panic bodies.
// Asm backend intercepts CALL/METHOD_CALL by name and emits x86_64
// lock/xchg/cmpxchg (try_emit_atomic_builtin_call_elf_c). Host-C / other
// arches fall through here (honest panic) until later slices.
// slice2 adds i64 load/store/cas on the same intercept path.
// PLATFORM: SHARED surface; LINUX|x86_64 asm lowering (slice1–2).

/**
 * Atomic load of i32 (seq_cst-class via plain aligned load on x86).
 * Asm backend replaces the call with `movl (%rax), %eax`.
 * @param ptr *i32 — address of the cell
 * @return i32 — loaded value
 * PLATFORM: SHARED · asm LINUX|x86_64
 */
export function atomic_load_i32(ptr: *i32): i32 {
  panic();
  return 0;
}

/**
 * Atomic store of i32 (x86 `xchg` for store-release strength).
 * Asm backend replaces the call with spill + `xchg %edx, (%rax)`.
 * @param ptr *i32 — address of the cell
 * @param val i32 — value to store
 * @return i32 — 0 (void-shaped; return slot unused)
 * PLATFORM: SHARED · asm LINUX|x86_64
 */
export function atomic_store_i32(ptr: *i32, val: i32): i32 {
  panic();
  return 0;
}

/**
 * Atomic compare-and-swap of i32 (strong).
 * On success writes `desired` and returns 1; on failure writes the observed
 * value back through `expected` and returns 0.
 * Asm: `lock cmpxchg` + update `*expected` + `sete`.
 * @param ptr *i32 — address of the cell
 * @param expected *i32 — in/out expected value
 * @param desired i32 — value to write on match
 * @return i32 — 1 on success, 0 on failure
 * PLATFORM: SHARED · asm LINUX|x86_64
 */
export function atomic_cas_i32(ptr: *i32, expected: *i32, desired: i32): i32 {
  panic();
  return 0;
}

/**
 * Atomic load of i64 (seq_cst-class via plain aligned load on x86_64).
 * Asm backend replaces the call with `movq (%rax), %rax`.
 * @param ptr *i64 — address of the cell
 * @return i64 — loaded value
 * PLATFORM: SHARED · asm LINUX|x86_64
 */
export function atomic_load_i64(ptr: *i64): i64 {
  panic();
  return 0;
}

/**
 * Atomic store of i64 (x86 `xchg` for store-release strength).
 * Asm backend replaces the call with spill + `xchg %rdx, (%rax)`.
 * @param ptr *i64 — address of the cell
 * @param val i64 — value to store
 * @return i64 — 0 (void-shaped; return slot unused)
 * PLATFORM: SHARED · asm LINUX|x86_64
 */
export function atomic_store_i64(ptr: *i64, val: i64): i64 {
  panic();
  return 0;
}

/**
 * Atomic compare-and-swap of i64 (strong).
 * On success writes `desired` and returns 1; on failure writes the observed
 * value back through `expected` and returns 0.
 * Asm: `lock cmpxchg` (64-bit) + update `*expected` + `sete`.
 * @param ptr *i64 — address of the cell
 * @param expected *i64 — in/out expected value
 * @param desired i64 — value to write on match
 * @return i32 — 1 on success, 0 on failure
 * PLATFORM: SHARED · asm LINUX|x86_64
 */
export function atomic_cas_i64(ptr: *i64, expected: *i64, desired: i64): i32 {
  panic();
  return 0;
}
