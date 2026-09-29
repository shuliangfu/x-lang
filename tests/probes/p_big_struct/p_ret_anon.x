struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return { a: x, b: x + 1, c: x + 2 }; }
function main(): i32 {
  let w: W = mk(10);
  if (w.a != 10) { return 1; }
  if (w.b != 11) { return 2; }
  if (w.c != 12) { return 3; }
  return 0;
}
