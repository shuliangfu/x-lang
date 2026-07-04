// net_import_alias.x — import binding -o 链接桩（从 .c 转换）

extern function net_tcp_connect_c(addr_u32: u32, port_u32: u32, timeout_ms: u32): i32;
extern function net_tcp_connect_blocking_c(addr_u32: u32, port_u32: u32, timeout_ms: u32): i32;
extern function net_accept_c(listener_fd: i32, timeout_ms: u32): i32;

function std_net_addr_to_u32(addr: ShuxIpv4Addr): u32 { return 0 as u32; }
function std_net_listen(addr: ShuxIpv4Addr, port: u32): ShuxTcpListener { return 0 as ShuxTcpListener; }
function std_net_connect(addr: ShuxIpv4Addr, port: u32, timeout_ms: u32): ShuxTcpStream { return 0 as ShuxTcpStream; }
function std_net_connect_blocking(addr: ShuxIpv4Addr, port: u32, timeout_ms: u32): ShuxTcpStream { return 0 as ShuxTcpStream; }
function std_net_accept(listener: ShuxTcpListener, timeout_ms: u32): ShuxTcpStream { return 0 as ShuxTcpStream; }
function std_net_udp_bind(addr: ShuxIpv4Addr, port: u32): ShuxUdpSocket { return 0 as ShuxUdpSocket; }
function std_net_udp_recv_many_buf(sock: ShuxUdpSocket, bufs: *ShuxBuffer, n: i32, timeout_ms: u32, out_sizes: *i32, out_addrs: *u32, out_ports: *u32): i32 { return 0 as i32; }
function std_net_udp_send_many_buf(sock: ShuxUdpSocket, addrs: *u32, ports: *u32, bufs: *ShuxBuffer, n: i32): i32 { return 0 as i32; }
function std_net_close_udp(sock: ShuxUdpSocket): i32 { return 0 as i32; }
function std_net_close_stream(stream: ShuxTcpStream): i32 { return 0 as i32; }
