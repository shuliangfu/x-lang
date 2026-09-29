struct S6 { a: i16, b: i16, c: i16 }
function main(): i32 {
  let ss: [3]S6 = [S6 { a: 1, b: 2, c: 3 }, S6 { a: 4, b: 5, c: 6 }, S6 { a: 7, b: 8, c: 9 }];
  if (ss[0].c != 3) { return 1; }
  if (ss[1].a != 4) { return 2; }
  if (ss[1].c != 6) { return 3; }
  if (ss[2].b != 8) { return 4; }
  if (ss[2].c != 9) { return 5; }
  return 0;
}
