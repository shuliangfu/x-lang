struct P { a: i64, b: i64 }
function mk(x: i64): P { return P { a: x, b: x + 1 }; }
function main(): i32 {
  let p: P = mk(10);
  if (p.a != 10) { return 1; }
  if (p.b != 11) { return 2; }
  return 0;
}
