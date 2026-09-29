// w1509 (终局待办 10.32): i32, i64, f32 and u8 fields of a local struct.
// Before w1509 Darwin and Windows reported CG002 (the field-assign body only
// took plain `=`). Exit 0 when right; a non-zero code names the first wrong check.
struct P { y: i64, x: i32, f: f32, c: u8, p1: u8, p2: u8, p3: u8, p4: i32 }
function main(): i32 {
  let p: P = P { y: 100, x: 10, f: 1.5, c: 250, p1: 0, p2: 0, p3: 0, p4: 0 };
  p.x += 4;
  if (p.x != 14) { return 1; }
  p.y *= 3;
  if (p.y != 300) { return 2; }
  p.c += 10;
  if (p.c != 4) { return 3; }
  p.f += 2.25;
  if (p.f != 3.75) { return 4; }
  p.x -= 20;
  if (p.x != 0 - 6) { return 5; }
  p.y /= 7;
  if (p.y != 42) { return 6; }
  p.y %= 5;
  if (p.y != 2) { return 7; }
  return 0;
}
