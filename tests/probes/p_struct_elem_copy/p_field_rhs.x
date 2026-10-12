struct Q { a: i64, b: i64 }
struct H { k: i64, q: Q }
function main(): i32 {
  let qs: [2]Q;
  qs[0].a = 1; qs[0].b = 1; qs[1].a = 1; qs[1].b = 1;
  let h: H = H { k: 3, q: Q { a: 4, b: 5 } };
  qs[1] = h.q;
  if (qs[1].a != 4) { return 1; }
  if (qs[1].b != 5) { return 2; }
  if (qs[0].a != 1) { return 11; }
  return 0;
}
