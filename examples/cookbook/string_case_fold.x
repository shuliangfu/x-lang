/**
 * Cookbook STR-02：string_view_case_fold Unicode 桥接（STD-160）。
 */
const string = import("std.string");

function main(): i32 {
  let txt: u8[3] = [65, 66, 67];
  let v: StrView = string.view(&txt[0], 3);
  let out: u8[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = string.string_view_case_fold(v, &out[0], 8);
  if (n < 3 || out[0] != 97) { return 1; }
  return 0;
}
