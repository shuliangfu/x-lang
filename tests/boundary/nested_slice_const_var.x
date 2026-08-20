// Same-layer twin of nested_slice_lit_var: const TYPE_ARRAY into [][]i32.
// N comes from pipeline_block_resolve_var_type_ref (const before let).
// INDEX consume so a missing length cannot fake-green.
// Expected: compile = 0, run = 78.
// PLATFORM: SHARED — Ubuntu gold typeck + freestanding emit.

function main(): i32 {
  const a: [2]i32 = [1, 2];
  let x: [][]i32 = [a];
  return x[0][0] + x[0][1] + 75;
}
