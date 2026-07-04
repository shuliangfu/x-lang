// stack_promote_cross_ret.x — 跨模块 struct 按值返回（make_pair import）
const stack_promote_lib = import("stack_promote_lib");

function main(): i32 {
  let p: Pair = make_pair(3, 4);
  return p.a + p.b;
}
