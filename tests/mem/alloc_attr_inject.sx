// MEM-C1 #[alloc]：省略 al 首参时 codegen 注入 default_alloc()。
const heap = import("std.heap");

/** 本地 #[alloc] 包装：验证调用点隐式注入 al。 */
#[alloc]
function proxy_bump(al: heap.Allocator, size: usize): *u8 {
  return heap.bump_alloc(al, size);
}

function main(): i32 {
  let p: *u8 = proxy_bump(4 as usize);
  if (p == 0) { return 1; }
  return 0;
}
