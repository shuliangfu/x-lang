// Same-layer twin: dest-SLICE ARRAY-of-SLICE row `[2][]i32 = [a[1], [5, 6]]`.
// Expected: compile = 0, run = 78.
// PLATFORM: SHARED — Ubuntu gold typeck + host-C / asm emit.

function main(): i32 {
  let a: [2][2]i32 = [[1, 2], [3, 4]];
  let x: [2][]i32 = [a[1], [5, 6]];
  return x[0][0] + x[0][1] + x[1][0] + x[1][1] + 60;
}
