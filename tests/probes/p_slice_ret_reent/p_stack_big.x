// w2056: 2000 i32 elements (8000 bytes) on the callee's stack. Before w2056
// anything past 1024 bytes was passed through as a dangling alias.
function g(v: i32): []i32 {
  let a: [2000]i32 = [];
  let i: i32 = 0;
  while (i < 2000) { a[i] = v + i; i = i + 1; }
  let s: []i32 = a;
  return s;
}
function clob(v: i32): i32 {
  let z: [3000]i32 = [];
  let i: i32 = 0;
  while (i < 3000) { z[i] = v; i = i + 1; }
  return z[1500];
}
function main(): i32 {
  let p: []i32 = g(7);
  let q: i32 = clob(99);
  if (q != 99) { return 1; }
  if (p.length != 2000) { return 2; }
  if (p[0] != 7) { return 3; }
  if (p[1024] != 1031) { return 4; }
  if (p[1999] != 2006) { return 5; }
  return 0;
}
