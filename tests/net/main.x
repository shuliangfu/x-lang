// 测试 std.net（listen 烟测）
// import 触发 need_net 链 net.o；listen 走 flat C ABI，避免 struct 复合字面量双权威。
const net = import("std.net");

/** asm import 门面 std_net_listen 的 struct 实参 ABI 尚未与 C 桩对齐；listen 烟测走 flat net_tcp_listen_c。 */
extern function net_tcp_listen_c(addr_u32: u32, port: u32): i32;

function main(): i32 {
  /* 127.0.0.1 大端 packed（与 std.net.addr_to_packed 一致）。 */
  let probe: u32 = ((127 as u32) << 24) | ((0 as u32) << 16) | ((0 as u32) << 8) | (1 as u32);
  let listener_fd: i32 = unsafe { net_tcp_listen_c(probe, 8080) };
  if (listener_fd < 0) { return 1; }
  // Linux io_uring：accept/connect(..., 0) 为 submit_and_wait 无限等，单线程自连会卡死 CI。
  return 0;
}
