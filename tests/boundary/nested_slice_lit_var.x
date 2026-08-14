// Isolated green: already-typed [N]i32 elem into [][]i32 via
// typeck_coerce_init_slice_from_array (same-layer peel).
// INDEX consume so host-C `__xlang_al[0]=a` cannot fake-green.
// Expected: compile = 0, run = 78.
// PLATFORM: SHARED — Ubuntu gold typeck + host-C emit.

function main(): i32 {
  let a: [2]i32 = [1, 2];
  let x: [][]i32 = [a];
  return x[0][0] + x[0][1] + 75;
}
