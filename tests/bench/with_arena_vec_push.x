/**
 * See implementation.
 * See implementation.
 */
const vec = import("std.vec");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  with_arena(65536 as usize) {
    let v: Vec_u8 = vec.new();
    if (vec.push(&v, 1) != 0) {
      return 1;
    }
    if (vec.push(&v, 2) != 0) {
      return 2;
    }
    if (vec.push(&v, 3) != 0) {
      return 3;
    }
    if (vec.length(v) != 3) {
      return 4;
    }
    if (v.ptr[0] != 1 || v.ptr[1] != 2 || v.ptr[2] != 3) {
      return 5;
    }
  }
  return 0;
}
