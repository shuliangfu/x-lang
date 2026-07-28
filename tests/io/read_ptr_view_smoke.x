/**
 * See implementation.
 * See implementation.
 */
const io = import("std.io");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let v1: ReadPtrView = io.stdin_ptr_view();
  if (v1.ptr == 0 as *u8) {
    return 1;
  }
  if (v1.length < 2) {
    return 2;
  }
  if (io.ptr_view_valid(v1) != 1) {
    return 3;
  }
  if (v1.ptr[0] != 65) {
    return 4;
  }
  /* See implementation. */
  let v2: ReadPtrView = io.stdin_ptr_view();
  if (v2.ptr != 0 as *u8 && v2.length > 0 && v2.ptr[0] == 65 && v2.gen == v1.gen) {
    return 11;
  }
  if (io.ptr_view_valid(v1) != 0) {
    return 5;
  }
  let v3: ReadPtrView = io.ptr_view(io.stdin(), 0);
  if (io.ptr_view_valid(v3) != 1) {
    return 6;
  }
  return 0;
}
