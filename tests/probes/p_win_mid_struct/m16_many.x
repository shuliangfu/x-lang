struct P { a: i64, b: i64 }
function f(a1: i64, a2: i64, a3: i64, s: P, a5: i64, t: P): i64 { return a1 + a2 + a3 + a5 + s.a * 1000 + s.b * 100 + t.a * 10 + t.b; }
function main(): i32 {
  let s: P = P { a: 1, b: 2 };
  let t: P = P { a: 3, b: 4 };
  if (f(1, 1, 1, s, 1, t) != 1238) { return 1; }
  return 0;
}
