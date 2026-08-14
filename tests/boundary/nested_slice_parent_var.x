// Same-layer twin of nested_slice_lit_var: parent-block TYPE_ARRAY into [][]i32.
// resolve walks Block.parent_block_ref (inner if-body has no `a`).
// INDEX consume so a missing length cannot fake-green.
// Expected: compile = 0, run = 78.
// PLATFORM: SHARED — Ubuntu gold typeck + freestanding emit.

function main(): i32 {
  let a: [2]i32 = [1, 2];
  if (1 != 0) {
    let x: [][]i32 = [a];
    return x[0][0] + x[0][1] + 75;
  }
  return 1;
}
