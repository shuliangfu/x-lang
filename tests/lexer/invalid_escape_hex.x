// wave281 Cap residual: incomplete \x escape must hard-fail L010.
// PLATFORM: SHARED

function main(): i32 {
  let s: *u8 = "\xG";
  return 42;
}
