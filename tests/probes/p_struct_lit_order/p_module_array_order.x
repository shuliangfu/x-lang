struct S { c: i64, a: i32, b: i32 }
let GS: S[2] = [S { a: 7, c: 5, b: 9 }, S { b: 10, a: 8, c: 6 }];
function main(): i32 {
  if (GS[0].c != 5) { return 1; }
  if (GS[1].a != 8) { return 2; }
  if (GS[1].b != 10) { return 3; }
  if (GS[0].b != 9) { return 4; }
  return 0;
}
