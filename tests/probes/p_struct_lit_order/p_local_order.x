struct S { c: i64, a: i32, b: i32 }
function main(): i32 {
  let s: S = S { a: 7, c: 5, b: 9 };
  if (s.c != 5) { return 1; }
  if (s.a != 7) { return 2; }
  if (s.b != 9) { return 3; }
  return 0;
}
