// See implementation.
const mem = import("core.mem");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: u8[8] = [1, 2, 3, 4, 5, 6, 7, 8];
  let b: u8[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let c: u8[8] = [1, 2, 3, 4, 9, 9, 9, 9];
  mem.mem_copy(b, a, 8);
  mem.mem_set(b, 0, 4);
  mem.mem_move(b, a, 4);
  let cmp: i32 = mem.mem_compare(a, c, 8);
  if (cmp >= 0) {
    return 1;
  }
  return 0;
}
