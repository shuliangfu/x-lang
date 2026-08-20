// Same-layer twin: dest-SLICE ARRAY_LIT row `[][]i32 = [a[1]]`.
// Helper must wrap INDEX (kind 47) with N from base elem TYPE_ARRAY.
// INDEX consume so a missing length cannot fake-green.
// Expected: compile = 0, run = 82.
// PLATFORM: SHARED — Ubuntu gold typeck + host-C / asm emit.

function main(): i32 {
  let a: [2][2]i32 = [[1, 2], [3, 4]];
  let x: [][]i32 = [a[1]];
  return x[0][0] + x[0][1] + 75;
}
