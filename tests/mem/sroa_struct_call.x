// MEM-D1：小 struct 工厂 call SROA — codegen 直写栈复合字面量，消除 make_pair call。
/** 两字段 POD；SROA 候选。 */
struct Pair {
  a: i32
  b: i32
}

/** 按值构造并返回 struct（单 return struct lit）。 */
function make_pair(x: i32, y: i32): Pair {
  return Pair { a: x, b: y };
}

/** 按值读字段求和。 */
function sum_pair(p: Pair): i32 {
  return p.a + p.b;
}

function main(): i32 {
  let p: Pair = make_pair(3, 4);
  return sum_pair(p);
}
