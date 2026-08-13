// Isolated green: already-typed [N]i32 elem into [][]i32 via
// typeck_coerce_init_slice_from_array (same-layer peel).
// Expected: compile = 0, run = 78.
// PLATFORM: SHARED — Ubuntu gold typeck.

function main(): i32 {
  let a: [2]i32 = [1, 2];
  let x: [][]i32 = [a];
  return 78;
}
