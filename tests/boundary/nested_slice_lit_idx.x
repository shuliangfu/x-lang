// Isolated green: 2-layer slice lit INDEX after coerce.
// Expected: compile = 0, run = 32.
// PLATFORM: SHARED — Ubuntu gold typeck + emit.

function main(): i32 {
  let x: [][]i32 = [[10, 32], [1, 2]];
  return x[0][1];
}
