/* seeds/runtime_net_ipv6_fast.from_x.c — G-02f-20 product TU
 * G-02f-104 helper gates.
 * Product: ../std/net/net_ipv6_fast.o; logic still C until full .x port.
 */
#include <stdint.h>
#include <string.h>

#if defined(_WIN32) || defined(_WIN64)
#include <winsock2.h>
#include <ws2tcpip.h>
static int net_ipv6_wsa_done = 0;
#else
#include <errno.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <poll.h> /* struct pollfd + POLL* constants; Cap calls xlang_net_poll */
#include <sys/socket.h>
#include <xlang_net_cap.h>
/* Cap residual 9.1.7: socket/connect/poll/close via xlang_net_cap.h on Linux.
 * fcntl residual for O_NONBLOCK. PLATFORM: LINUX Cap / POSIX fallback. */
#endif

/* 【Why 根源】asm codegen 对 u16 间接 store 会错发 64 位 store；IPv6 sockaddr_in6 填充须走 C。
 * 从 net_import_alias.c 迁入（F-闭合消除 *_import_alias.c 命名）。
 * 【Invariant】sin 指向至少 28 字节可写缓冲（sizeof(sockaddr_in6)==28）；addr_16 为 16 字节 IPv6 地址。
 * 【Asm/Perf】memset/memcpy 编译为向量指令（SSE2/NEON）。 */
void net_ipv6_set_addr_port_buf_c(uint8_t *sin, uint8_t *addr_16, uint32_t port_u32) {
    struct sockaddr_in6 *sa6 = (struct sockaddr_in6 *)(void *)sin;
    memset(sa6, 0, sizeof(*sa6));
    sa6->sin6_family = AF_INET6;
    sa6->sin6_port = htons((uint16_t)(port_u32 & 0xffffu));
    sa6->sin6_flowinfo = 0;
    memcpy(&sa6->sin6_addr, addr_16, 16);
}
/* thin+rest：thin 函数在 rest 模式下由 .x 提供，前向声明供 rest 函数调用 */
int32_t net_ipv6_ensure_wsa_c(void);
int32_t net_ipv6_close_socket_c(int32_t fd);
int32_t net_ipv6_set_nonblock_c(int32_t fd);
int32_t net_ipv6_poll_writable_c(int32_t fd, uint32_t timeout_ms);
int32_t net_ipv6_connect_retry_ok_c(void);

/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-20 thin+rest：_impl 实现；thin（src/asm/runtime_net_ipv6_fast.x）提供 public wrapper */
int32_t net_ipv6_ensure_wsa_c_impl_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    WSADATA data;
    if (net_ipv6_wsa_done)
        return 0;
    if (WSAStartup(MAKEWORD(2, 2), &data) != 0)
        return -1;
    net_ipv6_wsa_done = 1;
#endif
    return 0;
}

#ifndef XLANG_RUNTIME_NET_IPV6_FAST_FROM_X
/* 完整模式（未定义 thin 宏）：public wrapper 由 seed 提供 */
int32_t net_ipv6_ensure_wsa_c(void) {
    return net_ipv6_ensure_wsa_c_impl_c();
}
#endif


/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-20 thin+rest：_impl 实现；thin（src/asm/runtime_net_ipv6_fast.x）提供 public wrapper */
int32_t net_ipv6_close_socket_c_impl_c(int32_t fd) {
#if defined(_WIN32) || defined(_WIN64)
    return closesocket(fd) == 0 ? 0 : -1;
#else
    return xlang_net_close((int)fd) == 0 ? 0 : -1;
#endif
}

#ifndef XLANG_RUNTIME_NET_IPV6_FAST_FROM_X
/* 完整模式（未定义 thin 宏）：public wrapper 由 seed 提供 */
int32_t net_ipv6_close_socket_c(int32_t fd) {
    return net_ipv6_close_socket_c_impl_c(fd);
}
#endif




/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-20 thin+rest：_impl 实现；thin（src/asm/runtime_net_ipv6_fast.x）提供 public wrapper */
int32_t net_ipv6_set_nonblock_c_impl_c(int32_t fd) {
#if defined(_WIN32) || defined(_WIN64)
    u_long one = 1;
    return ioctlsocket(fd, FIONBIO, &one) == 0 ? 0 : -1;
#else
    int flags = fcntl(fd, F_GETFL, 0);
    if (flags < 0)
        return -1;
    return fcntl(fd, F_SETFL, flags | O_NONBLOCK) == 0 ? 0 : -1;
#endif
}

#ifndef XLANG_RUNTIME_NET_IPV6_FAST_FROM_X
/* 完整模式（未定义 thin 宏）：public wrapper 由 seed 提供 */
int32_t net_ipv6_set_nonblock_c(int32_t fd) {
    return net_ipv6_set_nonblock_c_impl_c(fd);
}
#endif


/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-20 thin+rest：_impl 实现；thin（src/asm/runtime_net_ipv6_fast.x）提供 public wrapper */
int32_t net_ipv6_poll_writable_c_impl_c(int32_t fd, uint32_t timeout_ms) {
#if defined(_WIN32) || defined(_WIN64)
    (void)fd;
    (void)timeout_ms;
    return 0;
#else
    struct pollfd pfd;
    int n;
    /* POLLOUT=4 POLLERR=8 POLLHUP=16 — avoid libc poll(); Cap xlang_net_poll. */
#ifndef POLLOUT
#define POLLOUT 4
#endif
#ifndef POLLERR
#define POLLERR 8
#endif
#ifndef POLLHUP
#define POLLHUP 16
#endif
    pfd.fd = fd;
    pfd.events = POLLOUT;
    pfd.revents = 0;
    n = xlang_net_poll(&pfd, 1, (int)timeout_ms);
    if (n <= 0 || (pfd.revents & (POLLERR | POLLHUP)) != 0)
        return -1;
    return 0;
#endif
}

#ifndef XLANG_RUNTIME_NET_IPV6_FAST_FROM_X
/* 完整模式（未定义 thin 宏）：public wrapper 由 seed 提供 */
int32_t net_ipv6_poll_writable_c(int32_t fd, uint32_t timeout_ms) {
    return net_ipv6_poll_writable_c_impl_c(fd, timeout_ms);
}
#endif


/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-20 thin+rest：_impl 实现；thin（src/asm/runtime_net_ipv6_fast.x）提供 public wrapper */
int32_t net_ipv6_connect_retry_ok_c_impl_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    return 1;
#else
    return (errno == EINPROGRESS || errno == EAGAIN) ? 1 : 0;
#endif
}

#ifndef XLANG_RUNTIME_NET_IPV6_FAST_FROM_X
/* 完整模式（未定义 thin 宏）：public wrapper 由 seed 提供 */
int32_t net_ipv6_connect_retry_ok_c(void) {
    return net_ipv6_connect_retry_ok_c_impl_c();
}
#endif




int32_t net_tcp_connect_ipv6_c(uint8_t *addr_16, uint32_t port_u32, uint32_t timeout_ms) {
    uint8_t sin_mem[28];
    int32_t fd;
    int32_t err = 0;
    socklen_t errlen = (socklen_t)sizeof(err);
    if (net_ipv6_ensure_wsa_c() != 0)
        return -1;
    if (!addr_16)
        return -1;
    net_ipv6_set_addr_port_buf_c(&sin_mem[0], addr_16, port_u32);
#if defined(_WIN32) || defined(_WIN64)
    fd = (int32_t)socket(AF_INET6, SOCK_STREAM, IPPROTO_TCP);
#else
    fd = (int32_t)xlang_net_socket(AF_INET6, SOCK_STREAM, IPPROTO_TCP);
#endif
    if (fd < 0)
        return -1;
    if (net_ipv6_set_nonblock_c(fd) != 0) {
        net_ipv6_close_socket_c(fd);
        return -1;
    }
#if defined(_WIN32) || defined(_WIN64)
    if (connect(fd, (struct sockaddr *)(void *)&sin_mem[0], (socklen_t)28) != 0) {
#else
    if (xlang_net_connect((int)fd, (const void *)&sin_mem[0], 28) != 0) {
#endif
        if (net_ipv6_connect_retry_ok_c() == 0) {
            net_ipv6_close_socket_c(fd);
            return -1;
        }
        if (net_ipv6_poll_writable_c(fd, timeout_ms) != 0) {
            net_ipv6_close_socket_c(fd);
            return -1;
        }
        err = 0;
        if (getsockopt(fd, SOL_SOCKET, SO_ERROR, (void *)&err, &errlen) != 0 || err != 0) {
            net_ipv6_close_socket_c(fd);
            return -1;
        }
    }
    return fd;
}

int32_t net_tcp_listen_ipv6_c(uint8_t *addr_16, uint32_t port_u32) {
    uint8_t sin_mem[28];
    int32_t fd;
    int32_t one = 1;
    if (net_ipv6_ensure_wsa_c() != 0)
        return -1;
    if (!addr_16)
        return -1;
    net_ipv6_set_addr_port_buf_c(&sin_mem[0], addr_16, port_u32);
#if defined(_WIN32) || defined(_WIN64)
    fd = (int32_t)socket(AF_INET6, SOCK_STREAM, IPPROTO_TCP);
#else
    fd = (int32_t)xlang_net_socket(AF_INET6, SOCK_STREAM, IPPROTO_TCP);
#endif
    if (fd < 0)
        return -1;
#if defined(_WIN32) || defined(_WIN64)
    (void)setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, (const void *)&one, (socklen_t)sizeof(one));
    if (bind(fd, (struct sockaddr *)(void *)&sin_mem[0], (socklen_t)28) != 0) {
        net_ipv6_close_socket_c(fd);
        return -1;
    }
    if (listen(fd, 128) != 0) {
        net_ipv6_close_socket_c(fd);
        return -1;
    }
#else
    (void)xlang_net_setsockopt((int)fd, SOL_SOCKET, SO_REUSEADDR, &one, (unsigned int)sizeof(one));
    if (xlang_net_bind((int)fd, (const void *)&sin_mem[0], 28) != 0) {
        net_ipv6_close_socket_c(fd);
        return -1;
    }
    if (xlang_net_listen((int)fd, 128) != 0) {
        net_ipv6_close_socket_c(fd);
        return -1;
    }
#endif
    if (net_ipv6_set_nonblock_c(fd) != 0) {
        net_ipv6_close_socket_c(fd);
        return -1;
    }
    return fd;
}
