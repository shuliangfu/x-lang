// Dest-SLICE CALL row whose callee is in a dep module.
// `[][]i32 = [dep.mk()]` — N must come from dep return TYPE_ARRAY
// (typeck stamps the row to TYPE_SLICE, hiding N).
// INDEX consume so a missing length cannot fake-green.
// Expected: compile = 0, run = 78.
// PLATFORM: SHARED — Ubuntu gold typeck + host-C / asm emit.

const dep = import("nested_slice_mk_dep.x");

function main(): i32 {
  let x: [][]i32 = [dep.mk()];
  return x[0][0] + x[0][1] + 75;
}
