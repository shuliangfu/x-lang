// Isolated green: body const outer fixed array of inner slices.
// Same compound reparse as let `[2][]i32`. Host-C must not brace-init
// slice rows as ints. INDEX consumes both rows.
// Expected: compile = 0, run = 71.
// PLATFORM: SHARED — Ubuntu gold parser + host-C emit.

function main(): i32 {
  const x: [2][]i32 = [[1, 2], [3, 4]];
  return x[0][0] + x[0][1] + x[1][0] + x[1][1] + 61;
}
