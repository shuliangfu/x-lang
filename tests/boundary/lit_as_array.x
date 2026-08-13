// Isolated: `[lit] as [N]T` must parse and store as a fixed array.
// Same as_suffix type_ref authority as `as []T`; asm peels identity ascription
// so the existing ARRAY_LIT braced / vector_let path fires (was CG002).
// Expected: compile = 0, run = 42 (host-C and asm).
// PLATFORM: SHARED — Ubuntu gold.

/**
 * Exit 42 when `[10, 32] as [2]i32` parses and indexes.
 * @return i32 — 42 ok, else the failing case
 */
function main(): i32 {
  let a: [2]i32 = [10, 32] as [2]i32;
  if (a[0] != 10) { return 1; }
  if (a[1] != 32) { return 2; }
  return 42;
}
