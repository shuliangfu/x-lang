// batch_rw_smoke.x — 全平台统一 IO 烟测：write_batch_fd + read_batch_fd 环回校验。
//
// 同一套 API 在 Linux→io_uring、macOS→kqueue/readv、Windows→IOCP 上自动分派；
// 由 tests/run-io-unified-gate.sh 编译运行，不区分平台写分支。
const fs = import("std.fs");

function main(): i32 {
  // 路径 "tests/bench/.io_batch_rw_smoke_tmp"（34 字符 + NUL = 35 字节）
  let path: u8[35] = [
    116, 101, 115, 116, 115, 47, 98, 101, 110, 99, 104, 47, 46, 105, 111, 95,
    98, 97, 116, 99, 104, 95, 114, 119, 95, 115, 109, 111, 107, 101, 95, 116,
    109, 112, 0
  ];
  let w0: u8[8] = [115, 104, 117, 105, 111, 99, 112, 48];
  let w1: u8[8] = [115, 104, 117, 105, 111, 99, 112, 49];
  let r0: u8[8] = [];
  let r1: u8[8] = [];
  let fd: i32 = 0;
  let nw: i32 = 0;
  let nr: i32 = 0;
  let i: i32 = 0;

  fd = fs.open_create(&path[0]);
  if (fd < 0) {
    return 1;
  }
  nw = write_batch_fd(fd, &w0[0], 8, &w1[0], 8, &w0[0], 0, &w0[0], 0, 2);
  if (nw != 16) {
    fs.close(fd);
    return 2;
  }
  if (fs.close(fd) != 0) {
    return 3;
  }

  fd = fs.open(&path[0]);
  if (fd < 0) {
    return 4;
  }
  nr = read_batch_fd(fd, &r0[0], 8, &r1[0], 8, &r0[0], 0, &r0[0], 0, 2);
  if (nr != 16) {
    fs.close(fd);
    return 5;
  }
  i = 0;
  while (i < 8) {
    if (r0[i] != w0[i]) {
      fs.close(fd);
      return 6;
    }
    if (r1[i] != w1[i]) {
      fs.close(fd);
      return 7;
    }
    i = i + 1;
  }
  if (fs.close(fd) != 0) {
    return 8;
  }
  return 0;
}
