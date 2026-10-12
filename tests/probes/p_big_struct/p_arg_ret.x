struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function sum(s: W): i64 { return s.a * 100 + s.b * 10 + s.c; }
function main(): i32 {
  let r: i64 = sum(mk(1));
  if (r != 123) { return 1; }
  return 0;
}
