struct E { t: *u8, v: i64 }
let G: E[2] = [E { t: "ab", v: 3 }, E { t: "cd", v: 4 }];
function main(): i32 {
  unsafe {
    if (G[1].v != 4) { return 1; }
    let p: *u8 = G[1].t;
    if (*(p + 0) != 99) { return 2; }
    p = G[0].t;
    if (*(p + 1) != 98) { return 3; }
  }
  return 0;
}
