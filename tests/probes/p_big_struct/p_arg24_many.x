struct W { a: i64, b: i64, c: i64 }
function f(a1: i64, a2: i64, a3: i64, a4: i64, a5: i64, a6: i64, a7: i64, s: W): i64 { return a1 + a2 + a3 + a4 + a5 + a6 + a7 + s.a * 1000 + s.b * 100 + s.c * 10; }
function main(): i32 {
  let w: W = W { a: 1, b: 2, c: 3 };
  let r: i64 = f(1, 1, 1, 1, 1, 1, 1, w);
  if (r != 1237) { return 1; }
  return 0;
}
