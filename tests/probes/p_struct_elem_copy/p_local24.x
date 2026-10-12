struct Q { a: i64, b: i64, c: i64 }
function main(): i32 {
  let qs: [3]Q = [Q { a: 0, b: 0, c: 0 }, Q { a: 0, b: 0, c: 0 }, Q { a: 0, b: 0, c: 0 }];
  qs[1].a = 4; qs[2].a = 7;
  qs[1].b = 5; qs[2].b = 8;
  qs[1].c = 6; qs[2].c = 9;
  qs[0] = qs[1];
  if (qs[0].a != 4) { return 1; }
  if (qs[0].b != 5) { return 2; }
  if (qs[0].c != 6) { return 3; }
  if (qs[2].a != 7) { return 11; }
  if (qs[2].b != 8) { return 12; }
  if (qs[2].c != 9) { return 13; }
  qs[2] = qs[0];
  if (qs[2].a != 4) { return 21; }
  if (qs[2].b != 5) { return 22; }
  if (qs[2].c != 6) { return 23; }
  return 0;
}
