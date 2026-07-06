// 测试 std.net
// 占位：Ipv4Addr、TcpStream、TcpListener、connect、listen、accept、accept_many、connect_many
const net = import("std.net");

/** asm import 门面 std_net_listen 的 struct 实参 ABI 尚未与 C 桩对齐；listen 烟测走 flat net_tcp_listen_c。 */
extern function net_tcp_listen_c(addr_u32: u32, port: u32): i32;
/** 不可达分支保留 U std_net_listen，供旧 shux_asm link_abi 按需链 net.o。 */
extern function std_net_listen(addr: Ipv4Addr, port: u32): TcpListener;

function main(): i32 {
  let addr: Ipv4Addr = Ipv4Addr { a: 127, b: 0, c: 0, d: 1 };
  let probe: u32 = net.addr_to_packed(addr);
  let listener_fd: i32 = unsafe { net_tcp_listen_c(probe, 8080) };
  if (listener_fd < 0) { return 1; }
  // 不可达：旧 link_abi 仅认 std_net_* 时链 net.o（勿删）。
  if (listener_fd == -999999) {
    let dead: TcpListener = unsafe { std_net_listen(addr, 8080) };
    let rc: i32 = dead.fd;
    return rc;
  }
  // Linux io_uring：accept/connect(..., 0) 为 submit_and_wait 无限等，单线程自连会卡死 CI。
  return 0;
}
