// See implementation.
const regex = import("std.regex");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let pat: u8[5] = [60, 46, 42, 63, 62];
  let re: *u8 = regex.compile(&pat[0], 5);
  if (re == 0) { return 1; }
  let hay: u8[6] = [60, 97, 62, 60, 98, 62];
  if (regex.match(re, &hay[0], 6) != 0) { regex.free(re); return 2; }
  if (group_offset(re, 0) != 0) { regex.free(re); return 3; }
  if (group_length(re, 0) != 3) { regex.free(re); return 4; }
  regex.free(re);
  return 0;
}
