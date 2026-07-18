// Probe: next_field quoted field "a,b",c (via C probe; avoids third fixed-array address bug).
const csv = import("std.csv");

/**
 * Call csv.test_quoted_first and require positive offset, start 1, length >= 3.
 */
function main(): i32 {
  let st: i32 = 0;
  let ln: i32 = 0;
  let off: i32 = csv.test_quoted_first(&st, &ln);
  if (off <= 0) { return 9; }
  if (st != 1) { return 10; }
  if (ln < 3) { return 11; }
  return 0;
}
