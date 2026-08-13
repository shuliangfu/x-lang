// Isolated green: outer fixed array of inner slices (`[2][]i32`).
// Same peel hole as [][]i32 (elem decl is TYPE_SLICE).
// Expected: compile = 0, run = 71.
// PLATFORM: SHARED — Ubuntu gold typeck.

function main(): i32 {
  let x: [2][]i32 = [[1, 2], [3, 4]];
  return 71;
}
