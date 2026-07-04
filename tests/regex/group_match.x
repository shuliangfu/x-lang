// STD-063：分组 `(ab)c`
const regex = import("std.regex");

function main(): i32 {
  let pat: u8[5] = [40, 97, 98, 41, 99];
  let re: *u8 = regex.compile(&pat[0], 5);
  if (re == 0) { return 1; }
  let hay: u8[5] = [120, 97, 98, 99, 121];
  if (regex.match(re, &hay[0], 5) != 0) { regex.free(re); return 2; }
  regex.free(re);
  return 0;
}
