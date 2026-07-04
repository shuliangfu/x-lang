// STD-160：string ↔ unicode 桥接烟测
const string = import("std.string");

function main(): i32 {
  let txt: u8[3] = [65, 66, 67];
  let v: StrView = string.view(&txt[0], 3);
  if (string.string_view_is_valid_utf8(v) != 1) { return 1; }
  let out: u8[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = string.string_view_case_fold(v, &out[0], 8);
  if (n < 3) { return 2; }
  return 0;
}
