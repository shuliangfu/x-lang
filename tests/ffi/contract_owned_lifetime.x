// SAFE-004 C6：owned 指针 new→use→free 单次释放路径。
const ffi = import("std.ffi");

function main(): i32 {
  let src: u8[3] = [49, 50, 51];
  let p: *u8 = ffi.cstring_new(&src[0], 3);
  if (p == 0 as *u8) {
    return 1;
  }
  let sum: i32 = (p[0] as i32) + (p[1] as i32) + (p[2] as i32);
  ffi.cstring_free(p);
  if (sum != 150) {
    return 2;
  }
  return 0;
}
