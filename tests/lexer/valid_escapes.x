// wave281 Cap residual: product single-char escapes still decode correctly.
// \n → 10; also regression for L002/L009 neighborhood.
// PLATFORM: SHARED

function main(): i32 {
  let s: *u8 = "\n";
  return s[0] as i32;
}
