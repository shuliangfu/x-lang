/**
 * DOD-CL-S2 smoke：std.heap Arena64 64B 对齐 chunk + bump alloc。
 * chunk 与分配指针均须 mod 64 == 0 → exit 0。
 */
const heap = import("std.heap");

function main(): i32 {
  /** arena64_empty 在 asm skip dep emit 时不链入；字面量初始化等价于 empty()。 */
  let a: Arena64 = Arena64 { chunk: 0 as *u8, cap: 0 as usize, off: 0 as usize };
  if (heap.arena64_init(&a, 4096) != 0) {
    return 1;
  }
  if (heap.ptr_mod(a.chunk, 64) != 0) {
    heap.arena64_deinit(&a);
    return 2;
  }
  let p: *u8 = heap.arena64_alloc(&a, 128 as usize, 64 as usize);
  if (p == 0 as *u8) {
    heap.arena64_deinit(&a);
    return 3;
  }
  if (heap.ptr_mod(p, 64) != 0) {
    heap.arena64_deinit(&a);
    return 4;
  }
  heap.arena64_deinit(&a);
  return 0;
}
