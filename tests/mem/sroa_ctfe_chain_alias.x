// MEM-D3：CTFE 别名链 — q = p 后 sum_pair(q) 仍折叠为 return 7。
struct Pair {
  a: i32
  b: i32
}

function make_pair(x: i32, y: i32): Pair {
  return Pair { a: x, b: y };
}

function sum_pair(p: Pair): i32 {
  return p.a + p.b;
}

function main(): i32 {
  let p: Pair = make_pair(3, 4);
  let q: Pair = p;
  return sum_pair(q);
}
