// Isolated: const EXPR_AS must pass the const-expr whitelist (was T001).
// typeck_is_const_expr_ref_impl recurses into as_operand; fold already
// handles EXPR_AS (wave460). Scalar 5 as i32 stamps; [lit] as []T / [N]T
// stay unstamped so emit peel / host-C identity remain authority.
// Expected: compile = 0, run = 42 (host-C and asm).
// PLATFORM: SHARED — Ubuntu gold.

/**
 * Exit 42 when const `[lit] as T` / `5 as i32` typeck and emit.
 * @return i32 — 42 ok, else the failing case
 */
function main(): i32 {
  const n: i32 = 5 as i32;
  if (n != 5) { return 1; }
  const s: []i32 = [10, 32] as []i32;
  if (s.length != 2) { return 2; }
  if (s[0] != 10) { return 3; }
  if (s[1] != 32) { return 4; }
  const a: [2]i32 = [10, 32] as [2]i32;
  if (a[0] != 10) { return 5; }
  if (a[1] != 32) { return 6; }
  return 42;
}
