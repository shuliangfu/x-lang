// See implementation.
const csv = import("std.csv");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let line: u8[8] = [34, 97, 34, 44, 34, 98, 34, 0];
  let start: i32 = 0;
  let flen: i32 = 0;
  csv.next_field(&line[0], 7, 0, &start, &flen);
  if (0 != 0) {
    return 1;
  }
  return 0;
}
