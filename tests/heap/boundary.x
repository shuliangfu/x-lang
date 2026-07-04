// TST-002：std.heap 边界烟测（alloc / arena / typed alloc）
//
// 【文件职责】≥8 边界 case；堆分配与 Arena64 基本路径。
// 【运行方式】tests/run-tst-002-boundary-gate.sh
const heap = import("std.heap");

function main(): i32 {
  // case 1：零长分配哨兵
  if (heap.alloc_size_zero() != 0) { return 1; }
  // case 2：alloc + free
  let p: *u8 = heap.alloc(32 as usize);
  if (p == 0 as *u8) { return 2; }
  // case 3
  heap.free(p);
  // case 4：alloc_zero 首字节为 0
  let z: *u8 = heap.alloc_zero(8);
  if (z == 0 as *u8) { return 4; }
  if (z[0] != 0) { return 5; }
  heap.free(z);
  // case 5：realloc 扩大
  let r: *u8 = heap.alloc(4 as usize);
  if (r == 0 as *u8) { return 6; }
  let r2: *u8 = heap.realloc(r, 64);
  if (r2 == 0 as *u8) { return 7; }
  heap.free(r2);
  // case 6：alloc_i32 数组
  let pi: *i32 = heap.alloc(4);
  if (pi == 0 as *i32) { return 8; }
  pi[0] = 42;
  if (pi[0] != 42) { return 9; }
  heap.free(pi);
  // case 7：Arena64 bump
  let ar: Arena64 = heap.arena64_empty();
  if (heap.arena64_init(&ar, 128) != 0) { return 10; }
  let ap: *u8 = heap.arena64_alloc(&ar, 16 as usize, 8 as usize);
  if (ap == 0 as *u8) { return 11; }
  heap.arena64_deinit(&ar);
  // case 8：ptr_mod 对齐
  let al: *u8 = heap.alloc_align(8, 24);
  if (al == 0 as *u8) { return 12; }
  if (heap.ptr_mod(al, 8) != 0) { return 13; }
  heap.free(al);
  return 0;
}
