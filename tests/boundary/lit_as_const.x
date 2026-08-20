// Isolated: const EXPR_AS whitelist + mid-body const stmt_order kind=0.
// Prefix `const n` was already in stmt_order; later `const m` after a stmt
// was pool-only (host-C BLD001 undeclared). Nested-block mid-body const
// is the parse_block twin (append_block_lets_from_res now copies consts).
// Expected: compile = 0, run = 42 (host-C and asm).
// PLATFORM: SHARED — Ubuntu gold.

/**
 * Exit 42 when prefix, mid-body, and nested-block const decls emit.
 * @return i32 — 42 ok, else the failing case
 */
function main(): i32 {
  const n: i32 = 5 as i32;
  if (n != 5) { return 1; }
  const m: i32 = (2 as i32) + (3 as i32);
  if (m != 5) { return 2; }
  if (1 == 1) {
    const k: i32 = 4 as i32;
    if (k != 4) { return 3; }
  }
  return 42;
}
