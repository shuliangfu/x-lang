// Isolated green: 2-layer slice lit must coerce ARRAY_LIT → [][]i32
// (4.2.3 deep lit typeck). Unused INDEX so a missing stamp cannot
// fake the constant. Expected: compile = 0, run = 70.
// PLATFORM: SHARED — Ubuntu gold typeck.

function main(): i32 {
  let x: [][]i32 = [[1, 2], [3, 4]];
  return 70;
}
