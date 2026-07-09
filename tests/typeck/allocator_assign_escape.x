// MEM-C1 AL-04/06 负例：with_arena 内把值赋给块外变量 → allocator region escape。
// 不 import std.vec（vec→heap 依赖链在部分 shux 上 check 会挂死）。
function main(): i32 {
  let v: i32 = 0;
  with_arena(4096) {
    v = 1;
  }
  return v;
}
