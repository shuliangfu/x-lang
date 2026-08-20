// Same-layer twin of nested_slice_lit_arr: VAR row into [N][]T.
// Host-C brace must wrap `a` as a typed fat, not `{a, (slice){…}}`
// (that treats `a` as .data and the next slice as .length).
// INDEX consume so a missing wrap cannot fake-green.
// Expected: compile = 0, run = 71.
// PLATFORM: SHARED — Ubuntu gold typeck + host-C emit.

function main(): i32 {
  let a: [2]i32 = [1, 2];
  let x: [2][]i32 = [a, [3, 4]];
  return x[0][0] + x[0][1] + x[1][0] + x[1][1] + 61;
}
