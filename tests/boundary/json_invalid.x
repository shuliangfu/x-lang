// See implementation.
const json = import("std.json");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let consumed: i32 = 0;
  let bad: u8[4] = [123, 125, 125, 0];
  if (json.parse_null(&bad[0], 3, &consumed) != 0) {
    return 0;
  }
  return 1;
}
