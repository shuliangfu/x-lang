struct Q2 { a: i64, b: i64 }
function main(): i32 {
  let ps: [3]Q2 = [Q2 { a: 1, b: 2 }, Q2 { a: 3, b: 4 }, Q2 { a: 5, b: 6 }];
  if (ps[0].a != 1) { return 1; }
  if (ps[0].b != 2) { return 2; }
  if (ps[1].a != 3) { return 3; }
  if (ps[1].b != 4) { return 4; }
  if (ps[2].a != 5) { return 5; }
  if (ps[2].b != 6) { return 6; }
  return 0;
}
