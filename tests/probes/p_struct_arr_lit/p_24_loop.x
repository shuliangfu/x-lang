struct W { a: i64, b: i64, c: i64 }
function main(): i32 {
  let ws: [3]W = [W { a: 1, b: 2, c: 3 }, W { a: 4, b: 5, c: 6 }, W { a: 7, b: 8, c: 9 }];
  let s: i64 = 0;
  let i: i32 = 0;
  while (i < 3) { s = s * 10 + ws[i].a + ws[i].b + ws[i].c; i = i + 1; }
  let want: i64 = 774;
  if (s != want) { return 1; }
  let nine: i64 = 9;
  if (ws[2].c != nine) { return 2; }
  return 0;
}
