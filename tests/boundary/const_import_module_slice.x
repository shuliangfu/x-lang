// Isolated: function-scope const of an import-module const FIELD.
// Same-module `const n:i32 = A` is already green. Import spelling is
// `dep.K` (FIELD): the const-expr whitelist only accepted enum variants,
// so typeck emitted T001. Typed `dep.A` also stamped a dep-arena type_ref
// (not portable) → `[]i32` vs i32. This knife closes both typeck holes.
// dest-SLICE `const s:[]i32 = dep.A` typecks now; host-C still emits
// `dep.A` (undeclared) and asm CG002 — emit leftover, next knife.
// Expected: compile = 0, run = 42 (three backends).
// PLATFORM: SHARED — Ubuntu gold typeck import-const FIELD.

const dep = import("const_import_module_slice_dep.x");

/**
 * Function-scope const of an import-module scalar const FIELD.
 * typeck whitelist must accept binding.CONST (not only enum FIELD).
 * @return i32 — 42 ok, else the failing case
 */
function wrap_cdecl(): i32 {
  const n: i32 = dep.K;
  if (n != 10) { return 51; }
  const m: i32 = dep.K + 32;
  if (m != 42) { return 52; }
  return 42;
}

/**
 * Main: import-module const FIELD must be a const-expr.
 * @return i32 — 42 ok, else the first failing helper code
 */
function main(): i32 {
  let rc: i32 = wrap_cdecl();
  if (rc != 42) { return rc; }
  return 42;
}
