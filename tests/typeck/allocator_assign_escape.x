// MEM-C1 AL-04/06 负例：with_arena 内 arena Vec 赋给块外变量。
const vec = import("std.vec");

function main(): i32 {
  let v: Vec_u8 = vec.new();
  with_arena(4096) {
    v = vec.new();
  }
  return 0;
}
