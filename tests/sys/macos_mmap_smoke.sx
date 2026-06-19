// B-16 v0：macOS libSystem 匿名 mmap 烟测（Darwin 常规链接）。
const macos = import("std.sys.macos");

function main(): i32 {
  if (macos.macos_mmap_available() != 1) {
    return 1;
  }
  let prot: i32 = 1 | 2;
  let p: *u8 = macos.macos_anonymous_mmap(4096 as usize, prot);
  let p_i: i64 = p as i64;
  if (p_i <= 0) {
    return 2;
  }
  p[0] = 77 as u8;
  p[1] = 77 as u8;
  if (p[0] != 77 as u8 || p[1] != 77 as u8) {
    return 3;
  }
  if (macos.macos_munmap(p, 4096 as usize) != 0) {
    return 4;
  }
  return 0;
}
