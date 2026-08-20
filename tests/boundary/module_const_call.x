// Isolated red: module-level const init must be a const-expr (not a call).
// Function-scope `const x = foo()` is already T001; module scope used to skip.
// Expected: compile T001.
// PLATFORM: SHARED — Ubuntu gold typeck.

function foo(): i32 {
  return 1;
}

const x: i32 = foo();

/**
 * Unreachable if typeck rejects the module const.
 * @return i32 — 0
 */
function main(): i32 {
  return 0;
}
