// Isolated: ARRAY_LIT as SIMD METHOD receiver (UFCS self = formal 0).
// emit: pipeline_asm_emit_method_call_elf_c places receiver via
// glue_emit_one_call_arg (pty=self) + dual-GP spill/load.
// Non-const elems block WPO fold so run≠7 cannot hide behind mov-imm.
// PLATFORM: SHARED — Ubuntu gold.

/**
 * Extract lane 0 of an i32x4 METHOD receiver.
 * @param self i32x4 — vector value (UFCS self)
 * @return i32 — lane 0
 */
function take0(self: i32x4): i32 {
  return self[0];
}

/**
 * Add two i32x4 values (METHOD self + extra SIMD arg).
 * @param self i32x4 — left lanes
 * @param other i32x4 — right lanes
 * @return i32x4 — self + other
 */
function add4(self: i32x4, other: i32x4): i32x4 {
  return self + other;
}

/**
 * Exit 0 when ARRAY_LIT SIMD METHOD receiver typecks and emits (lane0 == expected).
 * @return i32 — 0 ok, else the failing case
 */
function main(): i32 {
  /* Bare const ARRAY_LIT receiver — may still WPO-fold. */
  if ([7, 8, 9, 10].take0() != 7) { return 1; }
  /* Non-const elem: fold cannot mov-imm; must emit packed lanes as dual-GP self. */
  let x: i32 = 7;
  if ([x, 8, 9, 10].take0() != 7) { return 2; }
  /* Extra SIMD arg + nested METHOD (self dual-GP then other dual-GP). */
  let y: i32 = 10;
  if ([1, 2, 3, 4].add4([y, 20, 30, 40]).take0() != 11) { return 3; }
  /* let-then-METHOD neighborhood (VAR receiver already packed). */
  let a: i32x4 = [1, 2, 3, 4];
  if (a.take0() != 1) { return 4; }
  return 0;
}
