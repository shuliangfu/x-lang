// Isolated typeck: ARRAY_LIT as CALL argument to i32x4 formals.
// let / return already coerce via typeck_coerce_init_array_vector_lit_to_decl;
// CALL args were scored as TYPE_ARRAY [N]i32 vs NAMED i32x4 → T001.
// Bare `take_vec([lit])` emit (ARRAY_LIT as SIMD CALL arg, no fold) is a
// later codegen knife — do not assert it here.
// PLATFORM: SHARED — Ubuntu gold; no METHOD receiver (emit leftover).

/**
 * Extract lane 0 of an i32x4 (CALL formal).
 * @param v i32x4 — vector value
 * @return i32 — lane 0
 */
function take_vec(v: i32x4): i32 {
  return v[0];
}

/**
 * Add two i32x4 values (CALL formals).
 * @param a i32x4 — left lanes
 * @param b i32x4 — right lanes
 * @return i32x4 — a + b
 */
function add4(a: i32x4, b: i32x4): i32x4 {
  return a + b;
}

/**
 * Exit 0 when ARRAY_LIT CALL args coerce to i32x4.
 * @return i32 — 0 ok, else the failing case
 */
function main(): i32 {
  /* Nested CALL: typeck must accept ARRAY_LIT formals (fold/emit may constant-fold). */
  if (take_vec(add4([1, 2, 3, 4], [10, 20, 30, 40])) != 11) { return 1; }
  /* let-then-CALL neighborhood (already green before this knife). */
  let a: i32x4 = [1, 2, 3, 4];
  let b: i32x4 = [10, 20, 30, 40];
  if (take_vec(add4(a, b)) != 11) { return 2; }
  return 0;
}
