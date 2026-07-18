// See implementation.
const regex = import("std.regex");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let pat: u8[3] = [97, 43, 98];
  let re: *u8 = regex.compile(&pat[0], 3);
  if (re == 0) { return 1; }
  let hay: u8[3] = [97, 97, 98];
  if (regex.match(re, &hay[0], 3) != 0) { regex.free(re); return 2; }
  let hay2: u8[1] = [98];
  if (regex.match(re, &hay2[0], 1) == 0) { regex.free(re); return 3; }
  regex.free(re);
  return 0;
}
