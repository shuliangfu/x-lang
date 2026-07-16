/* seeds/runtime_net_sock_fast.from_x.c — G-02f-20 product TU
 * G-02f-104 helper gates.
 * Product: ../std/net/net_sock_fast.o; logic still C until full .x port.
 */
#include <stdint.h>

#if defined(_WIN32) || defined(_WIN64)
#include <winsock2.h>
#include <ws2tcpip.h>
#else
#include <fcntl.h>
#include <netinet/in.h>
#include <poll.h>
#include <sys/socket.h>
#include <unistd.h>
#endif

/* 前向声明：net_tcp_set_addr_port_buf_c / net_udp_set_addr_port_buf_c 由 runtime_net_addr_fast.c 提供。 */
extern void net_tcp_set_addr_port_buf_c(uint8_t *sin, uint32_t addr_u32, uint32_t port_u32);
extern void net_udp_set_addr_port_buf_c(uint8_t *sin, uint32_t addr_u32, uint32_t port_u32);

/*
 * 【Why 根源】std/net 下 .x 经 -backend asm 出 .o 时，extern shux_sys_poll 为真 U 符号；
 * C 前端 user TU 靠 preamble static inline，不会导出给 net.o。
 * 权威体放 net.o 合并的 sock_fast（与 net_close_socket_c 同层），asm/C 两路径可链。
 * 语义对齐 rt_preamble.from_x.c / std.io.sync：poll(pollfd*, nfds, timeout)。
 */
int32_t shux_sys_poll(uint8_t *fds, int32_t nfds, int32_t timeout) {
#if defined(_WIN32) || defined(_WIN64)
    /* Winsock：WSAPoll；nfds/timeout 与 POSIX poll 对齐（timeout ms，-1 无限）。 */
    if (fds == 0 || nfds <= 0)
        return -1;
    return (int32_t)WSAPoll((WSAPOLLFD *)(void *)fds, (ULONG)nfds, (INT)timeout);
#else
    return (int32_t)poll((struct pollfd *)(void *)fds, (nfds_t)nfds, (int)timeout);
#endif
}

/* 【Why 根源】Windows Winsock 须先 WSAStartup 才能 socket/bind/listen。
 * 从 net_import_alias.c 迁入（F-闭合消除 *_import_alias.c 命名）。
 * 【Invariant】net_wsa_done 防重复初始化；WSACleanup 由 OS 在进程退出时自动回收。
 * 【Asm/Perf】constructor 仅执行一次，热路径无开销。 */
#if defined(_WIN32) || defined(_WIN64)
static int net_wsa_done = 0;
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-20 thin+rest：_impl 实现；thin（src/asm/runtime_net_sock_fast.x）提供 public wrapper */
void net_ensure_wsa_impl(void) {
    WSADATA data;
    if (net_wsa_done) return;
    if (WSAStartup(MAKEWORD(2, 2), &data) == 0)
        net_wsa_done = 1;
}

#ifndef SHUX_RUNTIME_NET_SOCK_FAST_FROM_X
/* 完整模式（未定义 thin 宏）：public wrapper 由 seed 提供 */
void net_ensure_wsa(void) {
    net_ensure_wsa_impl();
}
#endif



__attribute__((constructor(65534)))
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
void net_wsa_ctor_impl(void) { net_ensure_wsa_impl(); }

#ifndef SHUX_RUNTIME_NET_SOCK_FAST_FROM_X
/* 完整模式（未定义 thin 宏）：public wrapper 由 seed 提供 */
void net_wsa_ctor(void) { net_ensure_wsa(); }
#endif



#endif

int32_t net_set_blocking_c(int32_t fd, int32_t blocking) {
    if (fd < 0)
        return -1;
#if defined(_WIN32) || defined(_WIN64)
    u_long mode = blocking == 0 ? 1UL : 0UL;
    return ioctlsocket(fd, FIONBIO, &mode) == 0 ? 0 : -1;
#else
    int flags = fcntl(fd, F_GETFL, 0);
    if (flags < 0)
        return -1;
    if (blocking != 0)
        flags &= ~O_NONBLOCK;
    else
        flags |= O_NONBLOCK;
    return fcntl(fd, F_SETFL, flags) == 0 ? 0 : -1;
#endif
}

/* 【Why 根源】sock.x 单文件 co-emit 时 net_close_socket_c 可能被 WPO 剔除；C 实现保证 net.o 可链。
 * 从 net_import_alias.c 迁入（F-闭合消除 *_import_alias.c 命名）。
 * 【Invariant】fd < 0 时 no-op 返回 0；成功返回 0，失败返回 -1。 */
int32_t net_close_socket_c(int32_t fd) {
    if (fd < 0)
        return 0;
#if defined(_WIN32) || defined(_WIN64)
    return closesocket(fd) == 0 ? 0 : -1;
#else
    return close(fd) == 0 ? 0 : -1;
#endif
}

/* 【Why 根源】asm codegen 对 socket/bind/listen/setsockopt 字面量实参有误；listen 烟测须走 C。
 * 从 net_import_alias.c 迁入（F-闭合消除 *_import_alias.c 命名）。
 * 【Invariant】fd < 0 表示失败；成功返回的 fd 已设为非阻塞。
 * 【Asm/Perf】setsockopt(SO_REUSEADDR) 仅 listen 前一次调用，非热路径。 */
int32_t net_tcp_listen_c(uint32_t addr_u32, uint32_t port_u32) {
    uint8_t sin[16];
    int32_t fd;
    int one = 1;
    net_tcp_set_addr_port_buf_c(sin, addr_u32, port_u32);
    fd = (int32_t)socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (fd < 0)
        return -1;
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

/* 【Why 根源】asm codegen 对 socket/bind/setsockopt 字面量实参有误；UDP bind 须走 C。
 * 从 net_import_alias.c 迁入（F-闭合消除 *_import_alias.c 命名）。
 * 【Invariant】fd < 0 表示失败；成功返回的 fd 已设为非阻塞。 */
int32_t net_udp_bind_c(uint32_t addr_u32, uint32_t port_u32) {
    uint8_t sin[16];
    int32_t fd;
    int one = 1;
    net_udp_set_addr_port_buf_c(sin, addr_u32, port_u32);
    fd = (int32_t)socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (fd < 0)
        return -1;
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
