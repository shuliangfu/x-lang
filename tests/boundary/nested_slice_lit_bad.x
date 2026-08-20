// Isolated red: nested slice lit elem mismatch must stay T001
// (wave672: do not stamp outer on known bool vs i32).
// Expected: compile != 0 (T001).
// PLATFORM: SHARED — Ubuntu gold typeck.

function main(): i32 {
  let x: [][]i32 = [[true]];
  return 77;
}
