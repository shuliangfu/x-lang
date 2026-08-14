// Isolated: const INDEX whitelist. `const s: []i32 = a[1]` was T001
// because typeck_is_const_expr_ref_impl had no EXPR_INDEX=47 case.
// Base + index must both be const-expr (prior const / lit / ARRAY_LIT).
// dest-SLICE / dest-[N]T / scalar consume already exist on the emit side.
// Expected: compile = 0, run = 42 (asm and host-C).
// PLATFORM: SHARED — Ubuntu gold typeck.

/**
 * Exit 42 when const INDEX of a prior const / ARRAY_LIT is a const-expr.
 * @return i32 — 42 ok, else the failing case
 */
function main(): i32 {
  const a: [2][2]i32 = [[1, 2], [10, 32]];
  const s: []i32 = a[1];
  if (s.length != 2) { return 1; }
  if (s[0] != 10) { return 2; }
  if (s[1] != 32) { return 3; }
  const t: []i32 = [[1, 2], [10, 32]][0];
  if (t.length != 2) { return 4; }
  if (t[0] != 1) { return 5; }
  const r: [2]i32 = a[0];
  if (r[0] != 1) { return 6; }
  if (r[1] != 2) { return 7; }
  const b: [2]i32 = [10, 32];
  const n: i32 = b[1];
  if (n != 32) { return 8; }
  const k: i32 = 1;
  const u: []i32 = a[k];
  if (u.length != 2) { return 9; }
  if (u[0] != 10) { return 10; }
  return 42;
}
