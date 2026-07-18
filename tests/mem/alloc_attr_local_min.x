allow(padding) struct Allocator {
  kind: i32;
}

/** Internal function `kind_heap`.
 * Implements `kind_heap`.
 * @return i32
 */
function kind_heap(): i32 { return 0; }

/** Internal function `heap_alloc`.
 * Memory management helper `heap_alloc`.
 * @return Allocator
 */
function heap_alloc(): Allocator {
  return Allocator { kind: kind_heap() };
}

/** Internal function `alloc`.
 * Memory management helper `alloc`.
 * @param al Allocator
 * @param size usize
 * @return *u8
 */
function alloc(al: Allocator, size: usize): *u8 {
  if (al.kind == kind_heap()) {
    return 0 as *u8;
  }
  return size as *u8;
}

#[alloc]
/** Internal function `bump`.
 * Implements `bump`.
 * @param al Allocator
 * @param size usize
 * @return *u8
 */
function bump(al: Allocator, size: usize): *u8 {
  return alloc(al, size);
}

/** Internal function `sentinel`.
 * Implements `sentinel`.
 * @return i32
 */
function sentinel(): i32 {
  return 7;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let p: *u8 = bump(4 as usize);
  if (p != 0 as *u8) { return 1; }
  return sentinel();
}
