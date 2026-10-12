struct Q2 { x: i64, y: i64 }
function sum(qs: [4]Q2): i64 {
  let s: i64 = 0;
  let i: i32 = 0;
  while (i < 4) { s = s + qs[i].x * 10 + qs[i].y; i = i + 1; }
  return s;
}
function main(): i32 {
  let qs: [4]Q2 = [Q2 { x: 1, y: 2 }, Q2 { x: 3, y: 4 }, Q2 { x: 5, y: 6 }, Q2 { x: 7, y: 8 }];
  let t: i64 = 0;
  let i: i32 = 0;
  while (i < 4) { t = t + qs[i].x * 10 + qs[i].y; i = i + 1; }
  if (t != 180) { return 1; }
  let a: i32 = 5;
  let b: i32 = 6;
  if (a + b != 11) { return 2; }
  return 0;
}
