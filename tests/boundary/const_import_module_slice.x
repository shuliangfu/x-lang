// Isolated: function-scope const of an import-module const FIELD.
// Product spelling is `dep.Name` (bare import const is rejected).
// typeck whitelist + caller-arena remap already closed (T001 / i32 stamp).
// This knife is asm emit: import FIELD is not a struct member.
// INT_LIT (`dep.K`) mov-imm; dest-SLICE / INDEX (`dep.A`) durable
// ARRAY_LIT from the dep arena (consts-only dep is not co-emitted).
// Expected: compile = 0, run = 42 (host-C + asm).
// PLATFORM: SHARED — Ubuntu gold import-const FIELD asm.

const dep = import("const_import_module_slice_dep.x");

/**
 * Function-scope const of an import-module scalar const FIELD.
 * host-C must inline the dep INT_LIT (dep-arena init_ref).
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
 * dest-SLICE let of an import-module const TYPE_ARRAY FIELD.
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
 * dest-SLICE ARRAY_LIT row of an import-module const TYPE_ARRAY.
 * @return i32 — 42 ok, else the failing case
 */
function wrap_row(): i32 {
  let x: [][]i32 = [dep.A];
  if (x.length != 1) { return 31; }
  if (x[0].length != 2) { return 32; }
  if (x[0][0] != 10) { return 33; }
  if (x[0][1] != 32) { return 34; }
  return 42;
}

/**
 * Function-scope const dest-SLICE / row / INDEX of an import const FIELD.
 * @return i32 — 42 ok, else the failing case
 */
function wrap_slice(): i32 {
  const s: []i32 = dep.A;
  if (s.length != 2) { return 61; }
  if (s[0] != 10) { return 62; }
  if (s[1] != 32) { return 63; }
  const x: [][]i32 = [dep.A];
  if (x.length != 1) { return 64; }
  if (x[0].length != 2) { return 65; }
  if (x[0][0] != 10) { return 66; }
  if (x[0][1] != 32) { return 67; }
  const n: i32 = dep.A[1];
  if (n != 32) { return 68; }
  return 42;
}

/**
 * Main: import-module const FIELD emit must be a legal C initializer.
 * @return i32 — 42 ok, else the first failing helper code
 */
function main(): i32 {
  let rc: i32 = wrap_cdecl();
  if (rc != 42) { return rc; }
  rc = wrap_let();
  if (rc != 42) { return rc; }
  rc = wrap_row();
  if (rc != 42) { return rc; }
  rc = wrap_slice();
  if (rc != 42) { return rc; }
  return 42;
}
