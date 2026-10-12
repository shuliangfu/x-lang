struct P { a: i64, b: i64 }
function mk(x: i64, y: i64, z: i64, w: i64, v: i64): P { return P { a: x + y + z, b: w * 10 + v }; }
function main(): i32 {
  let p: P = mk(1, 2, 3, 4, 5);
  if (p.a != 6) { return 1; }
  if (p.b != 45) { return 2; }
  return 0;
}
