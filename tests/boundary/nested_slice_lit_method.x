// Same-layer twin of nested_slice_lit_call: METHOD_CALL returning [N]T.
// N comes from the impl method return TYPE_ARRAY (same-module resolve).
// Expected: compile = 0, run = 78.
// PLATFORM: SHARED — Ubuntu gold typeck + host-C emit.

struct W { n: i32 }
impl W {
  function xs(self: W): [2]i32 {
    return [1, 2];
  }
}

function main(): i32 {
  let w: W = { n: 0 };
  let x: [][]i32 = [w.xs()];
  return x[0][0] + x[0][1] + 75;
}
