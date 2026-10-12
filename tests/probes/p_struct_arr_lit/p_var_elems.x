struct P3 { a: i32, b: i32, c: i32 }
function mk(x: i32): P3 { return P3 { a: x, b: x + 1, c: x + 2 }; }
function main(): i32 {
  let x: P3 = P3 { a: 10, b: 11, c: 12 };
  let y: P3 = P3 { a: 20, b: 21, c: 22 };
  let ps: [3]P3 = [x, y, P3 { a: 30, b: 31, c: 32 }];
  if (ps[0].c != 12) { return 1; }
  if (ps[1].a != 20) { return 2; }
  if (ps[1].c != 22) { return 3; }
  if (ps[2].b != 31) { return 4; }
  let qs: [2]P3 = [ps[2], ps[0]];
  if (qs[0].c != 32) { return 5; }
  if (qs[1].b != 11) { return 6; }
  let z: i32 = 7;
  let rs: [2]P3 = [P3 { a: z, b: z * 2, c: z * 3 }, P3 { a: z + 1, b: 0, c: z - 1 }];
  if (rs[0].c != 21) { return 7; }
  if (rs[1].a != 8) { return 8; }
  if (rs[1].c != 6) { return 9; }
  return 0;
}
