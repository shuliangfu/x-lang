// wave281 Cap residual: \xHH decodes to one semantic byte (0x2A = 42).
// PLATFORM: SHARED

function main(): i32 {
  let s: *u8 = "\x2A";
  return s[0] as i32;
}
