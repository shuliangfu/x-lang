// Isolated: `[lit] as []T` must parse and emit a live fat (let / return / assign).
// as_suffix type_ref + typeck ARRAY_LIT stamp + asm peel of identity ascription
// so the existing ARRAY_LIT dual-GP path fires. Bare `let s = …` is P010.
// const EXPR_AS is a later const-expr leaf.
// Expected: compile = 0, run = 42 (host-C and asm).
// PLATFORM: SHARED — Ubuntu gold.

/**
 * Let-init `[10, 32] as []i32`.
 * @return []i32 — fat over the array literal
 */
function from_let(): []i32 {
  let s: []i32 = [10, 32] as []i32;
  return s;
}

/**
 * Return `[10, 32] as []i32` directly.
 * @return []i32 — fat over a durable copy of the literal
 */
function from_ret(): []i32 {
  return [10, 32] as []i32;
}

/**
 * Exit 42 when `[lit] as []i32` parses, typecks, and emits a live fat.
 * @return i32 — 42 ok, else the failing case
 */
function main(): i32 {
  let a: []i32 = from_let();
  if (a.length != 2) { return 1; }
  if (a[0] != 10) { return 2; }
  if (a[1] != 32) { return 3; }
  let c: []i32 = from_ret();
  if (c.length != 2) { return 7; }
  if (c[0] != 10) { return 8; }
  if (c[1] != 32) { return 9; }
  let d: []i32 = [0, 0];
  d = [10, 32] as []i32;
  if (d.length != 2) { return 11; }
  if (d[0] != 10) { return 12; }
  if (d[1] != 32) { return 13; }
  return 42;
}
