// Isolated: function-scope const dest-SLICE of an import-module TYPE_ARRAY.
// Same-module `const s:[]i32 = A` is already green. Import spelling is
// `dep.A` (FIELD): the const-expr whitelist only accepted enum variants,
// so typeck emitted T001 "const init must be constant expression".
// Same-layer completions: `[dep.A]` ARRAY_LIT row and `dep.A[1]` INDEX.
// Expected: compile = 0, run = 42 (three backends).
// PLATFORM: SHARED — Ubuntu gold typeck + host-C / asm emit.

const dep = import("const_import_module_slice_dep.x");

/**
 * dest-SLICE let of an import-module const TYPE_ARRAY (not T001; emit path).
 * @return i32 — 42 ok, else the failing case
 */
function wrap_let(): i32 {
  let s: []i32 = dep.A;
  if (s.length != 2) { return 1; }
  if (s[0] != 10) { return 2; }
  if (s[1] != 32) { return 3; }
  return 42;
}

/**
 * Function-scope const dest-SLICE / row / INDEX of import-module const FIELD.
 * typeck whitelist must accept binding.CONST (not only enum FIELD).
 * @return i32 — 42 ok, else the failing case
 */
function wrap_cdecl(): i32 {
  const s: []i32 = dep.A;
  if (s.length != 2) { return 51; }
  if (s[0] != 10) { return 52; }
  if (s[1] != 32) { return 53; }
  const x: [][]i32 = [dep.A];
  if (x.length != 1) { return 54; }
  if (x[0].length != 2) { return 55; }
  if (x[0][0] != 10) { return 56; }
  if (x[0][1] != 32) { return 57; }
  const n: i32 = dep.A[1];
  if (n != 32) { return 58; }
  return 42;
}

/**
 * Main: import-module dest-SLICE wraps must be 42.
 * @return i32 — 42 ok, else the first failing helper code
 */
function main(): i32 {
  let rc: i32 = wrap_let();
  if (rc != 42) { return rc; }
  rc = wrap_cdecl();
  if (rc != 42) { return rc; }
  return 42;
}
