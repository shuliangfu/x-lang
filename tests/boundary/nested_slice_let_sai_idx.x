// Same-layer twin: dest-SLICE let from `[][2]i32` INDEX (`let s = a[1]`).
// Base is TYPE_SLICE of TYPE_ARRAY; N still lives on the elem [2]i32.
// Expected: compile = 0, run = 47.
// PLATFORM: SHARED — Ubuntu gold typeck + host-C / asm emit.

function main(): i32 {
  let a: [][2]i32 = [[1, 2], [3, 4]];
  let s: []i32 = a[1];
  return s[0] + s[1] + 40;
}
