struct Q { a: i32, b: i32, c: i32 }
function main(): i32 {
  let qs: [4]Q;
  let i: i32 = 0;
  while (i < 4) { qs[i].a = i; qs[i].b = i + 10; qs[i].c = i + 20; i = i + 1; }
  i = 0;
  while (i < 3) { qs[i] = qs[i + 1]; i = i + 1; }
  i = 0;
  while (i < 3) {
    if (qs[i].a != i + 1) { return 1; }
    if (qs[i].b != i + 11) { return 2; }
    if (qs[i].c != i + 21) { return 3; }
    i = i + 1;
  }
  if (qs[3].c != 23) { return 4; }
  return 0;
}
