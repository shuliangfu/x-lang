// Isolated green: return ARRAY_LIT → [][]i32 (wave333 reuse of
// typeck_coerce_init_array_vector_lit_to_decl).
// Expected: compile = 0, run = 74.
// PLATFORM: SHARED — Ubuntu gold typeck.

function f(): [][]i32 {
  return [[1, 2]];
}

function main(): i32 {
  return 74;
}
