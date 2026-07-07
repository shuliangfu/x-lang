/**
 * net_import_alias.c — import binding `-o` 链接桩
 *
 * asm co-emit 对 `const net = import("std.net")` 生成 std_net_* 符号；
 * net.o 仅含 net_*.x 的 net_*_c，mod.x 门面未 co-emit。本 TU 提供 std_net_* 实现（语义对齐 mod.x）。
 */
#include <stdint.h>
#include <string.h>
#if defined(_WIN32) || defined(_WIN64)
#include <winsock2.h>
#include <ws2tcpip.h> /* socklen_t 定义在此；winsock2.h 不提供 */
#else
#include <arpa/inet.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <unistd.h>
#endif

/** 与 mod.x Ipv4Addr 布局一致。 */
typedef struct ShuxIpv4Addr {
  uint8_t a;
  uint8_t b;
  uint8_t c;
  uint8_t d;
} ShuxIpv4Addr;

/** 与 mod.x TcpListener / TcpStream / UdpSocket 布局一致。 */
typedef struct ShuxTcpListener {
  int32_t fd;
} ShuxTcpListener;

typedef struct ShuxTcpStream {
  int32_t fd;
} ShuxTcpStream;

typedef struct ShuxUdpSocket {
  int32_t fd;
} ShuxUdpSocket;

/** 与 std.io.driver Buffer 布局一致（24 字节）。 */
typedef struct ShuxBuffer {
  uint8_t *ptr;
  uintptr_t len;
  uintptr_t handle;
} ShuxBuffer;

/** 前向声明：listen/bind 失败路径须 close fd。 */
int32_t net_close_socket_c(int32_t);

#if defined(_WIN32) || defined(_WIN64)
/* 【Why 根源】Windows Winsock 须先 WSAStartup 才能 socket/bind/listen。
 * net_tcp_listen_c 等 C 桩直接调 socket()，不经 std/net/tcp.x 的 SHUX 层 WSAStartup。
 * 用 constructor 在 main 前自动初始化，确保所有 C 桩可用。
 * 【Invariant】net_wsa_done 防重复初始化；WSACleanup 由 OS 在进程退出时自动回收。
 * 【Asm/Perf】constructor 仅执行一次，热路径无开销。 */
static int net_wsa_done = 0;
static void net_ensure_wsa(void) {
    WSADATA data;
    if (net_wsa_done) return;
    if (WSAStartup(MAKEWORD(2, 2), &data) == 0)
        net_wsa_done = 1;
}
__attribute__((constructor(65534)))
static void net_wsa_ctor(void) { net_ensure_wsa(); }
#endif

#if defined(__linux__) && defined(__GLIBC__)
extern int shu_net_udp_recvmmsg_buf_c(int32_t fd, ShuxBuffer *bufs, int n, uint32_t timeout_ms,
                                      int32_t *out_sizes, uint32_t *out_addrs, uint32_t *out_ports);
extern int shu_net_udp_sendmmsg_buf_c(int32_t fd, const uint32_t *addrs_u32, const uint32_t *ports,
                                      const ShuxBuffer *bufs, int n);
#endif

extern int32_t net_tcp_connect_c(uint32_t addr_u32, uint32_t port_u32, uint32_t timeout_ms);
extern int32_t net_tcp_connect_blocking_c(uint32_t addr_u32, uint32_t port_u32, uint32_t timeout_ms);
extern int32_t net_accept_c(int32_t listener_fd, uint32_t timeout_ms);

/**
 * 填充 IPv4 sockaddr_in 缓冲（16 字节）。
 * asm codegen 对 `p_family[0] = AF_INET as u16` 等 u16 间接写会错发 64 位 store；
 * TCP/UDP listen/bind 须走 C 实现以保证 sa_family/sin_port/sin_addr 正确。
 */
void net_tcp_set_addr_port_buf_c(uint8_t *sin, uint32_t addr_u32, uint32_t port_u32) {
  struct sockaddr_in *sa = (struct sockaddr_in *)(void *)sin;
  sa->sin_family = AF_INET;
  sa->sin_port = htons((uint16_t)(port_u32 & 0xffffu));
  sa->sin_addr.s_addr = htonl(addr_u32);
}

/** 与 net_tcp_set_addr_port_buf_c 相同布局；UDP bind/sendto 共用。 */
void net_udp_set_addr_port_buf_c(uint8_t *sin, uint32_t addr_u32, uint32_t port_u32) {
  net_tcp_set_addr_port_buf_c(sin, addr_u32, port_u32);
}

/** 填充 IPv6 sockaddr_in6 缓冲（28 字节）；addr_16 为 16 字节 IPv6 地址。 */
void net_ipv6_set_addr_port_buf_c(uint8_t *sin, uint8_t *addr_16, uint32_t port_u32) {
  struct sockaddr_in6 *sa6 = (struct sockaddr_in6 *)(void *)sin;
  memset(sa6, 0, sizeof(*sa6));
  sa6->sin6_family = AF_INET6;
  sa6->sin6_port = htons((uint16_t)(port_u32 & 0xffffu));
  sa6->sin6_flowinfo = 0;
  memcpy(&sa6->sin6_addr, addr_16, 16);
}

/**
 * TCP listen（非阻塞 listener fd）。
 * asm codegen 对 socket/bind/listen/setsockopt 字面量实参有误；listen 烟测须走 C。
 */
int32_t net_tcp_listen_c(uint32_t addr_u32, uint32_t port_u32) {
  uint8_t sin[16];
  int32_t fd;
  int one = 1;
  net_tcp_set_addr_port_buf_c(sin, addr_u32, port_u32);
#if defined(_WIN32) || defined(_WIN64)
  fd = (int32_t)socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
#else
  fd = (int32_t)socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
#endif
  if (fd < 0) {
    return -1;
  }
  if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, (const char *)&one, (socklen_t)sizeof(one)) != 0) {
    net_close_socket_c(fd);
    return -1;
  }
  if (bind(fd, (struct sockaddr *)(void *)sin, (socklen_t)16) != 0) {
    net_close_socket_c(fd);
    return -1;
  }
  if (listen(fd, 128) != 0) {
    net_close_socket_c(fd);
    return -1;
  }
#if !defined(_WIN32) && !defined(_WIN64)
  {
    int fl = fcntl(fd, F_GETFL, 0);
    if (fl < 0 || fcntl(fd, F_SETFL, fl | O_NONBLOCK) != 0) {
      net_close_socket_c(fd);
      return -1;
    }
  }
#endif
  return fd;
}

/**
 * UDP bind（非阻塞 fd）；供 udp_batch_buf 等烟测。
 */
int32_t net_udp_bind_c(uint32_t addr_u32, uint32_t port_u32) {
  uint8_t sin[16];
  int32_t fd;
  int one = 1;
  net_udp_set_addr_port_buf_c(sin, addr_u32, port_u32);
  fd = (int32_t)socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
  if (fd < 0) {
    return -1;
  }
  if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, (const char *)&one, (socklen_t)sizeof(one)) != 0) {
    net_close_socket_c(fd);
    return -1;
  }
  if (bind(fd, (struct sockaddr *)(void *)sin, (socklen_t)16) != 0) {
    net_close_socket_c(fd);
    return -1;
  }
#if !defined(_WIN32) && !defined(_WIN64)
  {
    int fl = fcntl(fd, F_GETFL, 0);
    if (fl < 0 || fcntl(fd, F_SETFL, fl | O_NONBLOCK) != 0) {
      net_close_socket_c(fd);
      return -1;
    }
  }
#endif
  return fd;
}

/**
 * UDP 批量 recv/send（Buffer 切片）；Linux 走 recvmmsg/sendmmsg 胶层。
 * asm 对 `n > UDP_BATCH_BUF_MAX` 等常量比较 codegen 有误，batch 入口须走 C。
 */
int32_t net_udp_recv_many_buf_c(int32_t fd, ShuxBuffer *bufs, int32_t n, uint32_t timeout_ms,
                                int32_t *out_sizes, uint32_t *out_addrs, uint32_t *out_ports) {
#if defined(__linux__) && defined(__GLIBC__)
  if (n <= 0 || n > 8 || !bufs || !out_sizes || !out_addrs || !out_ports)
    return -1;
  return (int32_t)shu_net_udp_recvmmsg_buf_c(fd, bufs, (int)n, timeout_ms, out_sizes, out_addrs, out_ports);
#else
  (void)fd;
  (void)bufs;
  (void)n;
  (void)timeout_ms;
  (void)out_sizes;
  (void)out_addrs;
  (void)out_ports;
  return -1;
#endif
}

int32_t net_udp_send_many_buf_c(int32_t fd, uint32_t *addrs, uint32_t *ports, ShuxBuffer *bufs, int32_t n) {
#if defined(__linux__) && defined(__GLIBC__)
  if (n <= 0 || n > 8 || !addrs || !ports || !bufs)
    return -1;
  return (int32_t)shu_net_udp_sendmmsg_buf_c(fd, addrs, ports, bufs, (int)n);
#else
  (void)fd;
  (void)addrs;
  (void)ports;
  (void)bufs;
  (void)n;
  return -1;
#endif
}

/** sock.x 单文件 co-emit 时 net_close_socket_c 可能被 WPO 剔除；C 桩保证 net.o 可链。 */
int32_t net_close_socket_c(int32_t fd) {
  if (fd < 0)
    return 0;
#if defined(_WIN32) || defined(_WIN64)
  return closesocket(fd) == 0 ? 0 : -1;
#else
  return close(fd) == 0 ? 0 : -1;
#endif
}

/** Ipv4Addr → u32 大端；对齐 mod.x addr_to_packed。 */
static uint32_t net_addr_to_u32_val(ShuxIpv4Addr addr) {
  return ((uint32_t)addr.a << 24) | ((uint32_t)addr.b << 16) | ((uint32_t)addr.c << 8) | (uint32_t)addr.d;
}

/** addr_to_packed 门面；供测试与 UDP 批量发送使用。 */
uint32_t std_net_addr_to_u32(ShuxIpv4Addr addr) { return net_addr_to_u32_val(addr); }

/** TCP listen；返回 TcpListener{fd}。 */
ShuxTcpListener std_net_listen(ShuxIpv4Addr addr, uint32_t port) {
  ShuxTcpListener out;
  out.fd = net_tcp_listen_c(net_addr_to_u32_val(addr), port);
  return out;
}

/** TCP connect；返回 TcpStream{fd}。 */
ShuxTcpStream std_net_connect(ShuxIpv4Addr addr, uint32_t port, uint32_t timeout_ms) {
  ShuxTcpStream out;
  out.fd = net_tcp_connect_c(net_addr_to_u32_val(addr), port, timeout_ms);
  return out;
}

/** TCP connect_blocking；返回 TcpStream{fd}。 */
ShuxTcpStream std_net_connect_blocking(ShuxIpv4Addr addr, uint32_t port, uint32_t timeout_ms) {
  ShuxTcpStream out;
  out.fd = net_tcp_connect_blocking_c(net_addr_to_u32_val(addr), port, timeout_ms);
  return out;
}

/** TCP accept；返回 TcpStream{fd}。 */
ShuxTcpStream std_net_accept(ShuxTcpListener listener, uint32_t timeout_ms) {
  ShuxTcpStream out;
  out.fd = net_accept_c(listener.fd, timeout_ms);
  return out;
}

/** UDP bind；返回 UdpSocket{fd}。 */
ShuxUdpSocket std_net_udp_bind(ShuxIpv4Addr addr, uint32_t port) {
  ShuxUdpSocket out;
  out.fd = net_udp_bind_c(net_addr_to_u32_val(addr), port);
  return out;
}

/** UDP 批量 recv（Buffer 切片）；转发 net_udp_recv_many_buf_c。 */
int32_t std_net_udp_recv_many_buf(ShuxUdpSocket sock, ShuxBuffer *bufs, int32_t n, uint32_t timeout_ms,
                                  int32_t *out_sizes, uint32_t *out_addrs, uint32_t *out_ports) {
  return net_udp_recv_many_buf_c(sock.fd, bufs, n, timeout_ms, out_sizes, out_addrs, out_ports);
}

/** UDP 批量 send（Buffer 切片）；转发 net_udp_send_many_buf_c。 */
int32_t std_net_udp_send_many_buf(ShuxUdpSocket sock, uint32_t *addrs, uint32_t *ports, ShuxBuffer *bufs,
                                  int32_t n) {
  return net_udp_send_many_buf_c(sock.fd, addrs, ports, bufs, n);
}

/** 关闭 UdpSocket；转发 net_close_socket_c。 */
int32_t std_net_close_udp(ShuxUdpSocket sock) { return net_close_socket_c(sock.fd); }

/** 关闭 TcpStream；转发 net_close_socket_c。 */
int32_t std_net_close_stream(ShuxTcpStream stream) { return net_close_socket_c(stream.fd); }
