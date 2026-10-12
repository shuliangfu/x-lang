struct P3 { a: i32, b: i32, c: i32 }
function mk(x: i32): P3 { return P3 { a: x, b: x + 1, c: x + 2 }; }
function main(): i32 {
  let ps: [2]P3 = [mk(10), mk(20)];
  if (ps[0].a != 10) { return 1; }
  if (ps[0].c != 12) { return 2; }
  if (ps[1].b != 21) { return 3; }
  if (ps[1].c != 22) { return 4; }
  return 0;
}
