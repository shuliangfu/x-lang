struct P { a: i64, b: i64 }
function mk(x: i64): P { return P { a: x, b: x + 1 }; }
function sum(s: P): i64 { return s.a * 10 + s.b; }
function main(): i32 {
  if (sum(mk(3)) != 34) { return 1; }
  return 0;
}
