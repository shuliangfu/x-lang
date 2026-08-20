// Isolated green: body const 3-layer slice lit (`[][][]i32`).
// Same is_let gate as 2-layer; one reparse via parse_expr covers nest.
// Expected: compile = 0, run = 73.
// PLATFORM: SHARED — Ubuntu gold parser.

function main(): i32 {
  const x: [][][]i32 = [[[1]]];
  return 73;
}
