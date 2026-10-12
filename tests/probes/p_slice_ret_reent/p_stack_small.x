// w2056: a 3-element slice over the callee's own array survives a later call
// that reuses the same stack.
function g(v: i32): []i32 {
  let a: [3]i32 = [v, v + 1, v + 2];
  let s: []i32 = a;
  return s;
}
function clob(v: i32): i32 {
  let z: [8]i32 = [v, v, v, v, v, v, v, v];
  return z[3];
}
function main(): i32 {
  let p: []i32 = g(30);
  let q: i32 = clob(99);
  if (q != 99) { return 1; }
  if (p.length != 3) { return 2; }
  if (p[0] != 30) { return 3; }
  if (p[2] != 32) { return 4; }
  return 0;
}
