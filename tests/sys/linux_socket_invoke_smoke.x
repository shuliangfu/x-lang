// NL-02：Linux freestanding socket(2)+close(2) 烟测（零 libc）。
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
