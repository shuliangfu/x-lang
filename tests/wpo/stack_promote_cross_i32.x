// stack_promote_cross_i32.x — 跨模块仅 i32 返回（对照 dead_user，隔离 struct ABI）
const stack_promote_lib = import("stack_promote_lib");

function main(): i32 {
  let p: Pair = Pair { a: 3, b: 4 };
  return sum_pair(p);
}
