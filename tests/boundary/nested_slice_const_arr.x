// Isolated green: body const outer fixed array of inner slices.
// Same compound reparse as let `[2][]i32`.
// Expected: compile = 0, run = 71.
// PLATFORM: SHARED — Ubuntu gold parser.

function main(): i32 {
  const x: [2][]i32 = [[1, 2], [3, 4]];
  return 71;
}
