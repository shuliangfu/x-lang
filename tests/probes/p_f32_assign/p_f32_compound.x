// w1507 (终局待办 10.34): f32 VAR assign whose value is already f32 bits.
// Before w1507 the store demoted it again as if it were f64 (FLOAT_LIT right
// side counts as f64), so `x = 2.25` and `x += 2.25` were wrong on all three
// targets. Exit 0 when right; the non-zero code names the first wrong check.
function main(): i32 {
  let x: f32 = 1.5;
  x = 2.25; if (x != 2.25) { return 1; }
  x = 1.5;
  x += 2.25; if (x != 3.75) { return 2; }
  x -= 0.75; if (x != 3.0) { return 3; }
  x *= 2.0; if (x != 6.0) { return 4; }
  x /= 4.0; if (x != 1.5) { return 5; }
  let y: f32 = 2.25;
  x += y; if (x != 3.75) { return 6; }
  x -= y; if (x != 1.5) { return 7; }
  x *= y; if (x != 3.375) { return 8; }
  x /= y; if (x != 1.5) { return 9; }
  x = x + 2.25; if (x != 3.75) { return 10; }
  let d: f64 = 1.5;
  d += 2.25; if (d != 3.75) { return 11; }
  d *= 2.0; if (d != 7.5) { return 12; }
  let s: f32 = 0.0;
  let i: i32 = 0;
  while (i < 4) { s += 0.5; i += 1; }
  if (s != 2.0) { return 13; }
  return 0;
}
