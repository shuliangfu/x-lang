struct Q { a: i64, b: i64, c: i64, d: i64 }
function mk(x: i64): Q { let q: Q = Q { a: x, b: x + 1, c: x + 2, d: x + 3 }; return q; }
function sum(q: Q): i64 { return q.a * 1000 + q.b * 100 + q.c * 10 + q.d; }
function main(): i32 {
  let q: Q = mk(1);
  if (q.d != 4) { return 1; }
  if (sum(q) != 1234) { return 2; }
  return 0;
}
