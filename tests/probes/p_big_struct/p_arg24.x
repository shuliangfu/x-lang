struct W { a: i64, b: i64, c: i64 }
function sum(s: W): i64 { return s.a * 100 + s.b * 10 + s.c; }
function main(): i32 {
  let w: W = W { a: 1, b: 2, c: 3 };
  let r: i64 = sum(w);
  if (r != 123) { return 1; }
  return 0;
}
