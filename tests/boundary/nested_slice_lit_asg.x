// Isolated green: assign ARRAY_LIT → [][]i32 (wave331 reuse).
// Expected: compile = 0, run = 75.
// PLATFORM: SHARED — Ubuntu gold typeck.

function main(): i32 {
  let x: [][]i32 = [[0]];
  x = [[1, 2]];
  return 75;
}
