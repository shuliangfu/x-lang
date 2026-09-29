struct P3 { a: i32, b: i32, c: i32 }
function main(): i32 {
  let p: P3 = P3 { a: 1, b: 2, c: 3 };
  if (p.c != 3) { return 3; }
  return 0;
}
