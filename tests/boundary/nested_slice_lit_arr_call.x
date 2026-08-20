// Same-layer twin: CALL row into [N][]T brace (emit_braced + try_emit CALL).
// Expected: compile = 0, run = 71.
// PLATFORM: SHARED — Ubuntu gold typeck + host-C emit.

function mk(): [2]i32 {
  return [1, 2];
}

function main(): i32 {
  let x: [2][]i32 = [mk(), [3, 4]];
  return x[0][0] + x[0][1] + x[1][0] + x[1][1] + 61;
}
