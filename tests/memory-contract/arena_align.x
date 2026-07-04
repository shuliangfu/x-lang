// L9 / X2：Bump 分配须 align_up — 13 字节对象后下一槽 8 字节对齐（防 ARM64 SIGBUS）。
//
// 验收：13B bump 后 off=13；align_up(13,8)=16 为下一槽；再 bump 8B 后 off=24。
const mem = import("core.mem");

/**
 * 模拟 page_mmap_heap_alloc 的 offset 推进（与 std/heap/page_mmap.x 一致）。
 * 成功返回下一 off；溢出/失败返回 0。
 */
function bump_simulate(off: usize, size: usize, align_bytes: usize): usize {
  let a: usize = if (align_bytes == 0) { 1 } else { align_bytes };
  let start: usize = mem.align_up(off, a);
  let end: usize = start + size;
  if (end < start) {
    return 0;
  }
  return end;
}

/** 入口：13B 后第二槽须 8 对齐且 next_off=16。 */
function main(): i32 {
  let off: usize = 0;
  let end1: usize = bump_simulate(off, 13, 8);
  if (end1 == 0) {
    return 1;
  }
  if (end1 != 13) {
    return 2;
  }
  /* 下一槽须 align_up(13,8)==16，防 ARM64 SIGBUS */
  let start2: usize = mem.align_up(end1, 8);
  if (start2 != 16) {
    return 5;
  }
  if ((start2 % 8) != 0) {
    return 3;
  }
  let end2: usize = bump_simulate(end1, 8, 8);
  if (end2 != 24) {
    return 4;
  }
  return 0;
}

