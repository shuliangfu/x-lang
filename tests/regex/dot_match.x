// See implementation.
const regex = import("std.regex");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let pat: u8[3] = [104, 46, 108];
  let re: *u8 = regex.compile(&pat[0], 3);
  if (re == 0) { return 1; }
  let hay: u8[4] = [104, 105, 108, 111];
  if (regex.match(re, &hay[0], 4) != 0) { regex.free(re); return 2; }
  regex.free(re);
  return 0;
}
