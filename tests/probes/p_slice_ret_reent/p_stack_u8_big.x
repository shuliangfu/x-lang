// w2056: 1500 u8 elements on the callee's stack, read back after another call.
function g(v: i32): []u8 {
  let a: [1500]u8 = [];
  let i: i32 = 0;
  while (i < 1500) { a[i] = ((v + i) % 200) as u8; i = i + 1; }
  let s: []u8 = a;
  return s;
}
function clob(v: i32): i32 {
  let z: [4000]u8 = [];
  let i: i32 = 0;
  while (i < 4000) { z[i] = v as u8; i = i + 1; }
  return z[9] as i32;
}
function main(): i32 {
  let p: []u8 = g(3);
  let q: i32 = clob(77);
  if (q != 77) { return 1; }
  if (p.length != 1500) { return 2; }
  if ((p[0] as i32) != 3) { return 3; }
  if ((p[1100] as i32) != 103) { return 4; }
  if ((p[1499] as i32) != 102) { return 5; }
  return 0;
}
