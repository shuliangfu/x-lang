struct P { a: i64, b: i64 }
function mk(x: i64): P { let v: P = P { a: x, b: x + 1 }; return v; }
function fw(x: i64): P { return mk(x + 1); }
function id(s: P): P { return s; }
function main(): i32 {
  let p: P = fw(9);
  if (p.a != 10) { return 1; }
  if (p.b != 11) { return 2; }
  let q: P = id(p);
  if (q.b != 11) { return 3; }
  let r: P = id(mk(20));
  if (r.a != 20) { return 4; }
  if (r.b != 21) { return 5; }
  return 0;
}
