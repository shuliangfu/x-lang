// Probe: adjacent concat that exceeds 63 combined semantic bytes → L011.
// wave283 Cap residual pure.
// PLATFORM: SHARED.

function main(): i32 {
  // 40 + 40 = 80 > 63
  let s: *u8 = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
  return 42;
}
