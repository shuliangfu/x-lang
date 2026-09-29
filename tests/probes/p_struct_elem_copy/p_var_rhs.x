struct Q { a: i32, b: i32, c: i32 }
function main(): i32 {
  let qs: [3]Q;
  qs[0].a = 1; qs[0].b = 1; qs[0].c = 1;
  qs[2].a = 7; qs[2].b = 8; qs[2].c = 9;
  let q: Q = Q { a: 4, b: 5, c: 6 };
  qs[1] = q;
  if (qs[1].a != 4) { return 1; }
  if (qs[1].b != 5) { return 2; }
  if (qs[1].c != 6) { return 3; }
  if (qs[2].a != 7) { return 11; }
  if (qs[0].c != 1) { return 12; }
  return 0;
}
