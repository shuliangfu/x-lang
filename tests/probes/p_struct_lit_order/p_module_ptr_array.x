struct S { t: *u8, a: i32, b: i32 }
let GS: S[2] = [S { t: "ab", a: 7, b: 9 }, S { a: 8, t: "xy", b: 10 }];
function main(): i32 {
  unsafe { let p: *u8 = GS[1].t; if (*(p + 1) != 121) { return 1; } }
  if (GS[1].a != 8) { return 2; }
  return 0;
}
