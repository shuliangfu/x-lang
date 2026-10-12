struct S { t: *u8, a: i32, b: i32 }
let GS: S = S { a: 7, t: "xy", b: 9 };
function main(): i32 {
  unsafe { let p: *u8 = GS.t; if (*(p + 1) != 121) { return 1; } }
  if (GS.a != 7) { return 2; }
  if (GS.b != 9) { return 3; }
  return 0;
}
