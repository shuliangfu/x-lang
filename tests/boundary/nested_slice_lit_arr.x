// Isolated green: outer fixed array of inner slices (`[2][]i32`).
// Host-C brace must emit slice compounds, not `{{1,2},{3,4}}` into fat fields.
// INDEX consumes both rows so a missing stamp cannot fake the constant.
// Expected: compile = 0, run = 71.
// PLATFORM: SHARED — Ubuntu gold typeck + host-C emit.

function main(): i32 {
  let x: [2][]i32 = [[1, 2], [3, 4]];
  return x[0][0] + x[0][1] + x[1][0] + x[1][1] + 61;
}
