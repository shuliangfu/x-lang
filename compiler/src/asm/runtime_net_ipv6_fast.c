#include <stdint.h>

#if defined(_WIN32) || defined(_WIN64)
#include <winsock2.h>
#include <ws2tcpip.h>
static int net_ipv6_wsa_done = 0;
#else
#include <errno.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <poll.h>
#include <sys/socket.h>
#include <unistd.h>
#endif

extern void net_ipv6_set_addr_port_buf_c(uint8_t *sin, uint8_t *addr_16, uint32_t port_u32);

static int32_t net_ipv6_ensure_wsa_c(void) {
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

static int32_t net_ipv6_close_socket_c(int32_t fd) {
#if defined(_WIN32) || defined(_WIN64)
    return closesocket(fd) == 0 ? 0 : -1;
#else
    return close(fd) == 0 ? 0 : -1;
#endif
}

static int32_t net_ipv6_set_nonblock_c(int32_t fd) {
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

static int32_t net_ipv6_poll_writable_c(int32_t fd, uint32_t timeout_ms) {
#if defined(_WIN32) || defined(_WIN64)
    (void)fd;
    (void)timeout_ms;
    return 0;
#else
    struct pollfd pfd;
    int n;
    pfd.fd = fd;
    pfd.events = POLLOUT;
    pfd.revents = 0;
    n = poll(&pfd, 1, (int)timeout_ms);
    if (n <= 0 || (pfd.revents & (POLLERR | POLLHUP)) != 0)
        return -1;
    return 0;
#endif
}

static int32_t net_ipv6_connect_retry_ok_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    return 1;
#else
    return (errno == EINPROGRESS || errno == EAGAIN) ? 1 : 0;
#endif
}

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
    fd = (int32_t)socket(AF_INET6, SOCK_STREAM, IPPROTO_TCP);
    if (fd < 0)
        return -1;
    if (net_ipv6_set_nonblock_c(fd) != 0) {
        net_ipv6_close_socket_c(fd);
        return -1;
    }
    if (connect(fd, (struct sockaddr *)(void *)&sin_mem[0], (socklen_t)28) != 0) {
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
    fd = (int32_t)socket(AF_INET6, SOCK_STREAM, IPPROTO_TCP);
    if (fd < 0)
        return -1;
    (void)setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, (const void *)&one, (socklen_t)sizeof(one));
    if (bind(fd, (struct sockaddr *)(void *)&sin_mem[0], (socklen_t)28) != 0) {
        net_ipv6_close_socket_c(fd);
        return -1;
    }
    if (listen(fd, 128) != 0) {
        net_ipv6_close_socket_c(fd);
        return -1;
    }
    if (net_ipv6_set_nonblock_c(fd) != 0) {
        net_ipv6_close_socket_c(fd);
        return -1;
    }
    return fd;
}
