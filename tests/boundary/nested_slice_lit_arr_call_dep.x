// Same-layer twin: dep-module CALL row into [N][]T.
// Expected: compile = 0, run = 71.
// PLATFORM: SHARED — Ubuntu gold typeck + host-C / asm emit.

const dep = import("nested_slice_mk_dep.x");

function main(): i32 {
  let x: [2][]i32 = [dep.mk(), [3, 4]];
  return x[0][0] + x[0][1] + x[1][0] + x[1][1] + 61;
}
