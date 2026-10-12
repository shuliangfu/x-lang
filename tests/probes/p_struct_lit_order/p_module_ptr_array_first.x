struct S { t: *u8, a: i32, b: i32 }
let GS: S[2] = [S { a: 7, t: "defgh", b: 9 }, S { a: 8, t: "xy", b: 10 }];
function main(): i32 {
  unsafe {
    let p: *u8 = GS[0].t;
    if (*(p + 0) != 100) { return 1; }
    if (*(p + 3) != 103) { return 2; }
    if (*(p + 4) != 104) { return 3; }
    if (*(p + 5) != 0) { return 4; }
    if (GS[0].b != 9) { return 5; }
    let q: *u8 = GS[1].t;
    if (*(q + 1) != 121) { return 6; }
    if (GS[1].a != 8) { return 7; }
  }
  return 0;
}
