// Isolated green: 2-layer named slice lit (`[][]Cell`).
// Expected: compile = 0, run = 76.
// PLATFORM: SHARED — Ubuntu gold typeck.

struct Cell { v: i32 }

function main(): i32 {
  let x: [][]Cell = [[Cell { v: 1 }]];
  return 76;
}
