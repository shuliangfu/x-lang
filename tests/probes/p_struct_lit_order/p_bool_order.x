struct B { f: bool, x: i32, y: i64 }
function main(): i32 {
  let b: B = B { y: 3, x: 5, f: true };
  if (b.y != 3) { return 1; }
  if (b.x != 5) { return 2; }
  if (!b.f) { return 3; }
  return 0;
}
