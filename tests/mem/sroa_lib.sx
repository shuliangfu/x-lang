// MEM-D1.2：跨模块 SROA 辅助库（独立编译单元）。
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
