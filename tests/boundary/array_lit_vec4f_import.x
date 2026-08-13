// Isolated: ARRAY_LIT extras on import.binding METHOD (std.simd).
// typeck: find_func_return_type_in_module_by_name_overload coerces
// ARRAY_LIT → Vec4f/Vec8i before score; typeck_check_call_arg_types
// T001s after resolve (first_idx type-mismatch must not stay green).
// Ambient of the METHOD is f32/i32 (hsum / INDEX), NOT Vec4f — so
// wave705 cannot stamp extras. let-then neighborhood stays green.
// PLATFORM: SHARED — Ubuntu gold.

const simd = import("std.simd");

/**
 * Exit 0 when import METHOD ARRAY_LIT extras typeck and emit.
 * @return i32 — 0 ok, else the failing case
 */
function main(): i32 {
  /* Extra ARRAY_LIT; METHOD ambient is f32 (compare), not Vec4f. */
  if (simd.hsum([1.0, 2.0, 3.0, 4.0]) != 10.0) { return 1; }
  /* Two extras + INDEX; METHOD ambient is 0, not Vec4f. */
  if (simd.add([1.0, 2.0, 3.0, 4.0], [10.0, 20.0, 30.0, 40.0])[0] != 11.0) { return 2; }
  /* let-then neighborhood (VAR extras already stamped). */
  let a: Vec4f = [1.0, 2.0, 3.0, 4.0];
  let b: Vec4f = [10.0, 20.0, 30.0, 40.0];
  if (simd.hsum(a) != 10.0) { return 3; }
  if (simd.add(a, b)[0] != 11.0) { return 4; }
  return 0;
}
