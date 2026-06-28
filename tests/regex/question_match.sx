// STD-051：`colou?r` 零或一次
const regex = import("std.regex");

function main(): i32 {
  let pat: u8[7] = [99, 111, 108, 111, 117, 63, 114];
  let re: *u8 = regex.compile(&pat[0], 7);
  if (re == 0) { return 1; }
  let us: u8[6] = [99, 111, 108, 111, 117, 114];
  let uk: u8[5] = [99, 111, 108, 111, 114];
  if (regex.match(re, &us[0], 6) != 0) { regex.free(re); return 2; }
  if (regex.match(re, &uk[0], 5) != 0) { regex.free(re); return 3; }
  regex.free(re);
  return 0;
}
