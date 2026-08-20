// Isolated green: body const nested slice lit must parse (not P001).
// Same compound-init authority as let; is_let gate was the hole.
// Unused INDEX so a missing stamp cannot fake the constant.
// Expected: compile = 0, run = 70.
// PLATFORM: SHARED — Ubuntu gold parser.

function main(): i32 {
  const x: [][]i32 = [[1, 2], [3, 4]];
  return 70;
}
