struct P { a: i64, b: i64 }
function sum(s: P): i64 { return s.a * 10 + s.b; }
function main(): i32 {
  let p: P = P { a: 3, b: 4 };
  if (sum(p) != 34) { return 1; }
  if (p.a != 3) { return 2; }
  return 0;
}
