// w1508 (终局待办 10.33): compound ops on a local i32 array element.
// Before w1508 Darwin and Windows reported CG002 (the index-assign seed only
// took plain `=`). Exit 0 when right; a non-zero code names the first wrong check.
function part1(): i32 {
  let a: [4]i32 = [1, 2, 3, 4];
  a[1] += 10;
  if a[1] != 12 { return 1; }
  a[2] *= 5;
  if a[2] != 15 { return 2; }
  a[3] -= 1;
  if a[3] != 3 { return 3; }
  return 0;
}

function part2(): i32 {
  let a: [8]i32 = [100, 17, 12, 10, 12, 5, 64, 1];
  a[0] /= 7;
  if a[0] != 14 { return 1; }
  a[1] %= 5;
  if a[1] != 2 { return 2; }
  a[2] &= 10;
  if a[2] != 8 { return 3; }
  a[3] |= 5;
  if a[3] != 15 { return 4; }
  a[4] ^= 6;
  if a[4] != 10 { return 5; }
  a[5] <<= 2;
  if a[5] != 20 { return 6; }
  a[6] >>= 3;
  if a[6] != 8 { return 7; }
  a[7] -= 9;
  if a[7] != -8 { return 8; }
  return 0;
}
function main(): i32 {
  let r: i32 = part1();
  if (r != 0) { return r; }
  let s: i32 = part2();
  if (s != 0) { return 10 + s; }
  return 0;
}
