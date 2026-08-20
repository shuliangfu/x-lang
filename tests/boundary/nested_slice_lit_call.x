// Same-layer twin of nested_slice_lit_var: CALL row returning [N]T into [][]T.
// Host-C fill must wrap `mk()` as a typed fat, not `__xlang_al[0]=mk()`
// (ARRAY return ABI is E*; assigning E* into a slice is BLD001).
// INDEX consume so a missing length cannot fake-green.
// Expected: compile = 0, run = 78.
// PLATFORM: SHARED — Ubuntu gold typeck + host-C emit.

function mk(): [2]i32 {
  return [1, 2];
}

function main(): i32 {
  let x: [][]i32 = [mk()];
  return x[0][0] + x[0][1] + 75;
}
