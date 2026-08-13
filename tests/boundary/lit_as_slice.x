// Isolated: `[lit] as []T` must parse (not P001 drop) and run as a fat slice.
// Same as_suffix authority as `5 as i32` / `as *[]T`; type_from_token half
// table rejected TOKEN_LBRACKET.
// Expected: compile = 0, run = 42.
// PLATFORM: SHARED — Ubuntu gold parse (+ typeck/emit if same product leaf).

/**
 * Let-init `[10, 32] as []i32`.
 * @return []i32 — fat over the array literal
 */
function from_let(): []i32 {
  let s: []i32 = [10, 32] as []i32;
  return s;
}

/**
 * Const-init `[10, 32] as []i32`.
 * @return []i32 — fat over the constant array literal
 */
function from_const(): []i32 {
  const s: []i32 = [10, 32] as []i32;
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
 * Unannotated let: `let s = [10, 32] as []i32`.
 * @return []i32 — type comes from the `as` ascription
 */
function from_bare(): []i32 {
  let s = [10, 32] as []i32;
  return s;
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
  let b: []i32 = from_const();
  if (b.length != 2) { return 4; }
  if (b[0] != 10) { return 5; }
  if (b[1] != 32) { return 6; }
  let c: []i32 = from_ret();
  if (c.length != 2) { return 7; }
  if (c[0] != 10) { return 8; }
  if (c[1] != 32) { return 9; }
  let d: []i32 = from_bare();
  if (d.length != 2) { return 10; }
  if (d[0] != 10) { return 11; }
  if (d[1] != 32) { return 12; }
  return 42;
}
