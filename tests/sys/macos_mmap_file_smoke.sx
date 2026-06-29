// B-16 v1：macOS std.sys 文件 MAP_SHARED mmap 烟测（Darwin 常规链接，无 mmap.inc.c）。
const sys = import("std.sys");

function main(): i32 {
  if (sys.mmap_available() != 1) {
    return 1;
  }
  // "/tmp/shux_macos_mmap_file_gate.dat\0"（gate 脚本 touch 空文件）
  let path: u8[34] = [
    47, 116, 109, 112, 47, 115, 104, 117, 120, 95, 109, 97, 99, 111, 115,
    95, 109, 109, 97, 112, 95, 102, 105, 108, 101, 95, 103, 97, 116, 101,
    46, 100, 97, 116, 0,
  ];
  let out_sz: usize = 0;
  let min_sz: usize = 4096 as usize;
  let p: *u8 = sys.mmap_rw(&path[0], min_sz, &out_sz);
  let p_i: i64 = p as i64;
  if (p_i <= 0) {
    return 2;
  }
  if (out_sz < min_sz) {
    return 3;
  }
  p[0] = 77 as u8;
  p[1] = 77 as u8;
  if (sys.msync(p, out_sz) != 0) {
    return 4;
  }
  if (sys.munmap(p, out_sz) != 0) {
    return 5;
  }
  let buf: u8[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = sys.read_file_into(&path[0], &buf[0], 8);
  if (n < 2) {
    return 6;
  }
  if (buf[0] != 77 as u8 || buf[1] != 77 as u8) {
    return 7;
  }
  return 0;
}
