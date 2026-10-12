struct P3 { a: i32, b: i32, c: i32 }
function main(): i32 {
  let ps: [3]P3 = [P3 { a: 1, b: 2, c: 3 }, P3 { a: 4, b: 5, c: 6 }, P3 { a: 7, b: 8, c: 9 }];
  if (ps[0].a != 1) { return 1; }
  if (ps[0].b != 2) { return 2; }
  if (ps[0].c != 3) { return 3; }
  if (ps[1].a != 4) { return 4; }
  if (ps[1].b != 5) { return 5; }
  if (ps[1].c != 6) { return 6; }
  if (ps[2].a != 7) { return 7; }
  if (ps[2].b != 8) { return 8; }
  if (ps[2].c != 9) { return 9; }
  return 0;
}
