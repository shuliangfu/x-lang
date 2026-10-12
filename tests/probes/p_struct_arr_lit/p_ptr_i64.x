struct E { a: *u8, v: i64 }
function main(): i32 {
  let es: [2]E = [E { a: "hi", v: 3 }, E { a: "yo", v: 5 }];
  if (es[0].v != 3) { return 1; }
  if (es[1].v != 5) { return 2; }
  unsafe {
    let p: *u8 = es[1].a;
    if (p[0] != 121) { return 3; }
    let q: *u8 = es[0].a;
    if (q[1] != 105) { return 4; }
  }
  return 0;
}
