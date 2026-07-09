// NL-02：Linux freestanding socket(2)+close(2) 烟测（零 libc）。
//
// 【Why import】bug ①②③ 修复完成后恢复为 import 版本（与 NL-06 manifest 一致）。
const net = import("std.net.freestanding_linux");

function main(): i32 {
  if (net.freestanding_net_available() != 1) {
    return 1;
  }
  let fd: i32 = net.freestanding_socket_tcp();
  if (fd < 0) {
    return 2;
  }
  if (net.freestanding_close(fd) != 0) {
    return 3;
  }
  return 0;
}
