// Isolated: `[lit] as []T` must parse (not P001) and run as a fat slice.
// as_suffix uses the full type_ref parser; typeck ascribes ARRAY_LIT→[]T
// (stamps the lit SLICE); emit identity-forwards so the existing ARRAY_LIT
// fat path fires. Bare `let s = …` is P010 (no inference). const EXPR_AS
// is a later const-expr leaf.
// Expected: compile = 0, run = 42.
// PLATFORM: SHARED — Ubuntu gold parse+typeck+emit.

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
  return 42;
}
