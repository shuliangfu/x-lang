// stack_promote_escape_global.x — WPO-S3 负例：struct 栈指针写入更长生命周期槽（typeck 应拒）
// 语言尚无 module 级 var；用跨函数 Slot 模拟 global 逃逸。

/** 两字段 POD。 */
struct Pair {
  a: i32
  b: i32
}

/** 模拟 global 槽：在 caller 栈上持久，可被写入 *Pair。 */
struct Slot {
  ptr: *Pair
}

/** 将局部 struct 地址写入 slot（ callee 返回后 p 已失效 — 负例语义）。 */
function stash_pair_ptr(slot: *Slot, p: *Pair): void {
  slot.ptr = p;
}

/** 在子帧构造 Pair 并写入 caller slot（负例：&p 逃逸到外层 *Slot）。 */
function fill_and_stash(slot: *Slot): i32 {
  let p: Pair = Pair { a: 3, b: 4 };
  slot.ptr = &p;
  let pp: *Pair = slot.ptr;
  return pp.a + pp.b;
}

function main(): i32 {
  let slot: Slot = Slot { ptr: 0 as *Pair };
  return fill_and_stash(&slot);
}
