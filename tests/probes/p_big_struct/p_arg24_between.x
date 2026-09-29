struct W { a: i64, b: i64, c: i64 }
function sum(x: i64, s: W, y: i64): i64 { return x * 1000 + s.a * 100 + s.b * 10 + s.c + y; }
function main(): i32 {
  let w: W = W { a: 1, b: 2, c: 3 };
  let r: i64 = sum(4, w, 5);
  if (r != 4128) { return 1; }
  return 0;
}
