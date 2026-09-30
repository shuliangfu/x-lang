struct P { a: i64, b: i64 }
struct A { v: i64 }
impl A {
  function take(self: A, p: P): i64 { return self.v + p.a * 10 + p.b; }
}
function mk(x: i64): P { return P { a: x, b: x + 1 }; }
function main(): i32 {
  let a: A = { v: 1 };
  let p: P = P { a: 5, b: 4 };
  if (a.take(p) != 55) { return 3; }
  if (a.take(mk(3)) != 35) { return 4; }
  return 0;
}
