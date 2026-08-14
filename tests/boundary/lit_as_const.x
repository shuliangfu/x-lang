// Isolated: const EXPR_AS must pass the const-expr whitelist (was T001).
// typeck_is_const_expr_ref_impl recurses into as_operand; fold (wave460)
// stamps scalar targets. Aggregate `const s: []T = [lit] as []T` compiles
// after this leaf but emit (host-C decl / asm fat) is a later consume leaf.
// Expected: compile = 0, run = 42 (host-C and asm).
// PLATFORM: SHARED — Ubuntu gold.

/**
 * Exit 42 when `const n: i32 = 5 as i32` typecks and folds.
 * @return i32 — 42 ok, else the failing case
 */
function main(): i32 {
  const n: i32 = 5 as i32;
  if (n != 5) { return 1; }
  const m: i32 = (2 as i32) + (3 as i32);
  if (m != 5) { return 2; }
  return 42;
}
