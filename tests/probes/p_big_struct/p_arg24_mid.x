struct W { a: i64, b: i64, c: i64 }
function f(k: i64, s: W, m: i64): i64 { return k * 10000 + s.a * 1000 + s.b * 100 + s.c * 10 + m; }
function main(): i32 {
  let w: W = W { a: 1, b: 2, c: 3 };
  let r: i64 = f(5, w, 7);
  if (r != 51237) { return 1; }
  return 0;
}
