// w1502 (终局待办 10.25): compound assign on VAR targets (locals + module lets).
// Exit 0 when every op is right; the non-zero code names the first wrong check.
// Darwin and Windows reported CG002 on all of these before w1502.
function main(): i32 {
  let a: i32 = 20;
  a += 3; if (a != 23) { return 1; }
  a -= 5; if (a != 18) { return 2; }
  a *= 2; if (a != 36) { return 3; }
  a /= 4; if (a != 9) { return 4; }
  a %= 5; if (a != 4) { return 5; }
  a |= 8; if (a != 12) { return 6; }
  a &= 10; if (a != 8) { return 7; }
  a ^= 3; if (a != 11) { return 8; }
  a <<= 2; if (a != 44) { return 9; }
  a >>= 1; if (a != 22) { return 10; }
  let b: i64 = 30000;
  b += 30000; if (b != 60000) { return 11; }
  b -= 1; if (b != 59999) { return 12; }
  b *= 2; if (b != 119998) { return 13; }
  b %= 7; if (b != 4) { return 14; }
  let w: i64 = 100000;
  w *= 100000; w /= 100000; if (w != 100000) { return 18; }
  let c: u8 = 250;
  c += 3; if (c != 253) { return 15; }
  let n: i32 = -7;
  n /= 2; if (n != -3) { return 16; }
  let s: i32 = 0;
  let i: i32 = 0;
  while (i < 10) { s += i; i += 1; }
  if (s != 45) { return 17; }
  return 0;
}
