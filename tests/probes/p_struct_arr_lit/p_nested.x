struct In { u: i32, v: i32 }
struct Out { k: i32, i: In, t: i32 }
function main(): i32 {
  let os: [2]Out = [Out { k: 1, i: In { u: 2, v: 3 }, t: 4 }, Out { k: 5, i: In { u: 6, v: 7 }, t: 8 }];
  if (os[0].i.v != 3) { return 1; }
  if (os[1].k != 5) { return 2; }
  if (os[1].i.u != 6) { return 3; }
  if (os[1].t != 8) { return 4; }
  if (os[0].t != 4) { return 5; }
  return 0;
}
