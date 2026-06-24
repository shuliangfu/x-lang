// CORE-001：泛型 size_of<T> / align_of<T> 金样（标量、指针、结构体、数组）
const types = import("core.types");

struct Pair {
  a: i32;
  b: i32;
}

function main(): i32 {
  // 标量
  if (types.size_of<i32>() != 4) { return 1; }
  if (types.align_of<i32>() != 4) { return 2; }
  if (types.size_of<u8>() != 1) { return 3; }
  // 指针
  if (types.size_of<*u8>() != 8) { return 4; }
  if (types.align_of<*u8>() != 8) { return 5; }
  // 结构体
  if (types.size_of<Pair>() != 8) { return 6; }
  if (types.align_of<Pair>() != 4) { return 7; }
  // 定长数组
  if (types.size_of<u8[4]>() != 4) { return 8; }
  if (types.align_of<u8[4]>() != 1) { return 9; }
  return 0;
}
