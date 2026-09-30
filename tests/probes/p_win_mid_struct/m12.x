allow(padding) struct T { a: i64, b: i32 }
function mk(x: i64, y: i32): T { return T { a: x, b: y }; }
function sum(t: T, k: i64): i64 { return t.a * 100 + (t.b as i64) + k; }
function main(): i32 {
  let t: T = mk(7, 9);
  if (t.a != 7) { return 1; }
  if (t.b != 9) { return 2; }
  if (sum(t, 1) != 710) { return 3; }
  if (sum(mk(1, 2), 3) != 105) { return 4; }
  return 0;
}
