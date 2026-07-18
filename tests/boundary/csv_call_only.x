const csv = import("std.csv");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let start: i32 = 0;
  let flen: i32 = 0;
  let empty: u8[1] = [0];
  csv.next_field(&empty[0], 0, 0, &start, &flen);
  return 0;
}
