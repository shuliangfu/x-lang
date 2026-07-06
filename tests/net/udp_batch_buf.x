// 测试 std.net 切片化 UDP API：udp_recv_many_buf、udp_send_many_buf（指针+段数）
// 覆盖 net_udp_recv_many_buf_c/net_udp_send_many_buf_c 的编译与链接；bind 后 send 一发。
const net = import("std.net");
// 引入 Buffer struct 定义（与 std.io.driver ABI 一致，ptr+len+handle 24 字节）
const driver = import("std.io.driver");

/** flat C API：避免 std_net_udp_* import 门面 struct ABI 与 asm codegen 未对齐。 */
extern function net_udp_bind_c(addr_u32: u32, port: u32): i32;
extern function net_udp_recv_many_buf_c(fd: i32, bufs: *Buffer, n: i32, timeout_ms: u32, out_sizes: *i32, out_addrs: *u32, out_ports: *u32): i32;
extern function net_udp_send_many_buf_c(fd: i32, addrs: *u32, ports: *u32, bufs: *Buffer, n: i32): i32;
extern function net_close_socket_c(fd: i32): i32;

function main(): i32 {
  /** 127.0.0.1 主机序；bind port 0 = 内核分配。 */
  let loopback: u32 = 0x7f000001;
  let sock_fd: i32 = unsafe { net_udp_bind_c(loopback, 0) };
  if (sock_fd < 0) { return 1; }
  let recv_buf: u8[64] = 0;
  let recv_io: Buffer = Buffer { ptr: &recv_buf[0], len: 64, handle: 0 };
  let out_size0: i32 = 0;
  let out_addr0: u32 = 0;
  let out_port0: u32 = 0;
  let _recv: i32 = unsafe { net_udp_recv_many_buf_c(sock_fd, &recv_io, 1, 1, &out_size0, &out_addr0, &out_port0) };
  let send_addr0: u32 = loopback;
  let send_port0: u32 = 9;
  let payload: u8[4] = [1, 2, 3, 4];
  /** 勿用 Buffer[1]=[...]：asm ARRAY_LIT 会把 ptr 覆写成 struct 自身地址。 */
  let send_io: Buffer = Buffer { ptr: &payload[0], len: 4, handle: 0 };
  let n_send: i32 = unsafe { net_udp_send_many_buf_c(sock_fd, &send_addr0, &send_port0, &send_io, 1) };
  let c: i32 = unsafe { net_close_socket_c(sock_fd) };
  if (c != 0) { return 2; }
  /** macOS/BSD 无 sendmmsg，net_udp_send_many_buf_c 返回 -1；编译/链接验证即通过。 */
  if (n_send < 0) { return 0; }
  if (n_send != 1) { return 3; }
  return 0;
}
