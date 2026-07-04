// stack_promote_escape_cross.x — WPO-S3 跨模块：&local 传 import read_pair_ptr
// make_pair 内联写栈槽；dep 侧经 *Pair 读字段仍须 exit 7。

const stack_promote_lib = import("stack_promote_lib");

function main(): i32 {
  let p: Pair = make_pair(3, 4);
  return read_pair_ptr(&p);
}
