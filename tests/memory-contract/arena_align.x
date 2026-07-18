// See implementation.
//
// See implementation.
/** Local align_up (inlined from core.mem to avoid field_access callee — seed typeck limitation). */
function align_up(addr: usize, alignment: usize): usize {
  if (alignment == 0) {
    return addr;
  }
  return ((addr + alignment - 1) / alignment) * alignment;
}

/**
 * See implementation.
 * See implementation.
 */
function bump_simulate(off: usize, size: usize, align_bytes: usize): usize {
  // See implementation.
  let a: usize = 1;
  if (align_bytes != 0) {
    a = align_bytes;
  }
  let start: usize = align_up(off, a);
  let end: usize = start + size;
  if (end < start) {
    return 0;
  }
  return end;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let off: usize = 0;
  let end1: usize = bump_simulate(off, 13, 8);
  if (end1 == 0) {
    return 1;
  }
  if (end1 != 13) {
    return 2;
  }
  /* See implementation. */
  let start2: usize = align_up(end1, 8);
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

