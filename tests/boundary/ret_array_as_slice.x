// Isolated green: return already-typed [N]T as []T (VAR / FIELD / STRUCT_LIT.field).
// Typeck accepts without stamping TYPE_SLICE; emit durables the payload
// then builds a fat pair (stack view would dangle after return).
// Expected: compile = 0, run = 42.
// PLATFORM: SHARED — Ubuntu gold typeck+emit.

struct W {
  xs: [2]i32
}

/**
 * Return a local [2]i32 as []i32.
 * @return []i32 — fat over a durable copy of [10, 32]
 */
function from_var(): []i32 {
  let a: [2]i32 = [10, 32];
  return a;
}

/**
 * Return a named struct field [2]i32 as []i32.
 * @return []i32 — fat over a durable copy of w.xs
 */
function from_field(): []i32 {
  let w: W = W { xs: [10, 32] };
  return w.xs;
}

/**
 * Return STRUCT_LIT.field [2]i32 as []i32.
 * @return []i32 — fat over a durable copy of W{}.xs
 */
function from_lit(): []i32 {
  return W { xs: [10, 32] }.xs;
}

/**
 * Exit 42 when return [N]T → []T typecks and emits a live fat.
 * @return i32 — 42 ok, else the failing case
 */
function main(): i32 {
  let s: []i32 = from_var();
  if (s.length != 2) { return 1; }
  if (s[0] != 10) { return 2; }
  if (s[1] != 32) { return 3; }
  let t: []i32 = from_field();
  if (t.length != 2) { return 4; }
  if (t[0] != 10) { return 5; }
  if (t[1] != 32) { return 6; }
  let u: []i32 = from_lit();
  if (u.length != 2) { return 7; }
  if (u[0] != 10) { return 8; }
  if (u[1] != 32) { return 9; }
  return 42;
}
