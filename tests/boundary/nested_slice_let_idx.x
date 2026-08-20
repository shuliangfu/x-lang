// Same-layer twin: dest-SLICE let `let s: []i32 = a[i]`.
// Typeck stamps the INDEX expr to TYPE_SLICE (hides N). N must come from
// the base's elem TYPE_ARRAY. a[1] proves scale uses sizeof([2]i32)=8,
// not the stamped fat 16.
// Expected: compile = 0, run = 42.
// PLATFORM: SHARED — Ubuntu gold typeck + host-C / asm emit.

function main(): i32 {
  let a: [2][2]i32 = [[1, 2], [3, 4]];
  let s0: []i32 = a[0];
  let s1: []i32 = a[1];
  return s0[0] + s0[1] + s1[0] + s1[1] + 32;
}
