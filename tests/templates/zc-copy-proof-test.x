// See implementation.
//
// path_id: REPLACE_ME
// userland_copies: 0
// zc_tier: none
// hot_path: describe the data path under test
// fallback: none
//
// See implementation.
// See implementation.
const string = import("std.string");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  // See implementation.
  let buf: u8[4] = [97, 98, 99, 0];
  let v: StrView = string.view(&buf[0], 3);
  if (string.length(v) != 3) { return 1; }
  return 0;
}
