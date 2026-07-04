// STD-063：交替 `cat|dog`
const regex = import("std.regex");

function main(): i32 {
  let pat: u8[7] = [99, 97, 116, 124, 100, 111, 103];
  let re: *u8 = regex.compile(&pat[0], 7);
  if (re == 0) { return 1; }
  let hay: u8[6] = [97, 32, 100, 111, 103, 33];
  if (regex.match(re, &hay[0], 6) != 0) { regex.free(re); return 2; }
  regex.free(re);
  return 0;
}
