struct Q { a: i32, b: i32, c: i32 }
let G: [3]Q = [Q { a: 0, b: 0, c: 0 }, Q { a: 0, b: 0, c: 0 }, Q { a: 0, b: 0, c: 0 }];
function main(): i32 {
  G[1].a = 4;
  G[1].b = 5;
  G[1].c = 6;
  G[0] = G[1];
  if (G[0].a != 4) { return 1; }
  if (G[0].b != 5) { return 2; }
  if (G[0].c != 6) { return 3; }
  return 0;
}
