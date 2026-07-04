struct Pair {
  a: i32
  b: i32
}

function main(): i32 {
  let p: Pair = Pair { a: 0, b: 2 };
  p.a = 1;
  return p.a;
}
