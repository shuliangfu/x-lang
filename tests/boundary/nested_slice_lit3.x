// Isolated green: 3-layer slice lit must recurse past one peel
// (`expected [][]i32 found [1][1]i32` was the live hole).
// Expected: compile = 0, run = 73.
// PLATFORM: SHARED — Ubuntu gold typeck.

function main(): i32 {
  let x: [][][]i32 = [[[1]]];
  return 73;
}
