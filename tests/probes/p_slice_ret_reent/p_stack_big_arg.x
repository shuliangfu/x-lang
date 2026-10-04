// w2056: the same rule on the call-argument path: g()'s slice is copied before
// sum() runs clob() over the stack it came from.
function g(v: i32): []i32 {
  let a: [1500]i32 = [];
  let i: i32 = 0;
  while (i < 1500) { a[i] = v + i; i = i + 1; }
  let s: []i32 = a;
  return s;
}
function clob(v: i32): i32 {
  let z: [3000]i32 = [];
  let i: i32 = 0;
  while (i < 3000) { z[i] = v; i = i + 1; }
  return z[7];
}
function sum(s: []i32, k: i32): i32 {
  let q: i32 = clob(k);
  if (q != k) { return 0 - 1; }
  if (s.length != 1500) { return 0 - 2; }
  return s[0] + s[1499];
}
function main(): i32 {
  let r: i32 = sum(g(1), 55);
  if (r != 1501) { return 1; }
  return 0;
}
