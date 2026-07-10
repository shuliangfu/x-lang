/* seeds/runtime_net_udp_batch.from_x.c — G-02f-20 product TU
 * Product: runtime_net_udp_batch.o; logic still C until full .x port.
 */
/**
 * runtime_net_udp_batch.c — Linux recvmmsg/sendmmsg 胶层（F-ZC：自 std/net/udp_batch_glue.c 迁入）
 *
 * mmsghdr/iovec 批量 syscall 暂由 C 提供；主逻辑与回退路径见 udp_batch.x。
 * 仅 __linux__ && __GLIBC__ 编译有效符号；其它平台为空 TU。与 net.o 一并链入 exe。
 * runtime_asm_io_stubs.c 可 weak-include 本 TU，供旧 shux_asm 未链 runtime_net_udp_batch.o 时解析符号。
 */

#if defined(__linux__) && defined(__GLIBC__)

#define _GNU_SOURCE

#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <errno.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <poll.h>

#ifndef SHUX_NET_UDP_GLUE_WEAK
#define SHUX_NET_UDP_GLUE_WEAK
#endif

#define SHUX_NET_UDP_GLUE_API SHUX_NET_UDP_GLUE_WEAK

#define SHU_UDP_BATCH_MAX 2
#define SHU_UDP_BATCH_BUF_MAX 8

/** 与 std.io.driver Buffer / net.c shu_net_buf_t ABI 一致。 */
typedef struct {
    uint8_t *ptr;
    size_t len;
    size_t handle;
} shu_net_buf_t;

/** 填充 IPv4 sockaddr_in。 */
static void shu_udp_batch_set_addr_port(struct sockaddr_in *sin, uint32_t addr_u32, uint32_t port_u32) {
    sin->sin_family = AF_INET;
    sin->sin_addr.s_addr = htonl(addr_u32);
    sin->sin_port = htons((uint16_t)(port_u32 & 0xFFFFu));
}

/** poll 可读；失败 -1。 */
static int shu_udp_batch_poll_readable(int fd, uint32_t timeout_ms) {
    struct pollfd pfd = { fd, POLLIN, 0 };
    int n = poll(&pfd, 1, (int)(timeout_ms ? timeout_ms : (-1)));
    if (n <= 0 || (pfd.revents & (POLLERR | POLLHUP)))
        return -1;
    return 0;
}

/**
 * Linux recvmmsg：最多 2 段；timeout_ms 非 0 时先 poll。
 * 返回收到报文数；EAGAIN 返回 0；其它错误 -1。
 */
SHUX_NET_UDP_GLUE_API int shu_net_udp_recvmmsg2_c(int32_t fd, uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, int n,
    uint32_t timeout_ms, int32_t *out_sizes, uint32_t *out_addrs, uint32_t *out_ports) {
    struct iovec iov[SHU_UDP_BATCH_MAX];
    struct sockaddr_in addrs[SHU_UDP_BATCH_MAX];
    struct mmsghdr msgvec[SHU_UDP_BATCH_MAX];
    unsigned int i;
    int r;

    if (n <= 0 || n > SHU_UDP_BATCH_MAX || !out_sizes || !out_addrs || !out_ports)
        return -1;
    for (i = 0; i < (unsigned int)n; i++) {
        socklen_t addrlen = sizeof(addrs[0]);
        iov[i].iov_base = (i == 0) ? p0 : p1;
        iov[i].iov_len  = (i == 0) ? l0 : l1;
        msgvec[i].msg_hdr.msg_name = &addrs[i];
        msgvec[i].msg_hdr.msg_namelen = addrlen;
        msgvec[i].msg_hdr.msg_iov = &iov[i];
        msgvec[i].msg_hdr.msg_iovlen = 1;
        msgvec[i].msg_hdr.msg_control = NULL;
        msgvec[i].msg_hdr.msg_controllen = 0;
        msgvec[i].msg_hdr.msg_flags = 0;
    }
    if (timeout_ms != 0) {
        if (shu_udp_batch_poll_readable((int)fd, timeout_ms) != 0)
            return -1;
    }
    r = recvmmsg((int)fd, msgvec, (unsigned int)n, 0, NULL);
    if (r < 0)
        return (errno == EAGAIN) ? 0 : -1;
    for (i = 0; i < (unsigned int)r; i++) {
        out_sizes[i] = (int32_t)msgvec[i].msg_len;
        out_addrs[i] = ntohl(addrs[i].sin_addr.s_addr);
        out_ports[i] = (uint32_t)ntohs(addrs[i].sin_port);
    }
    for (i = (unsigned int)r; i < (unsigned int)n; i++)
        out_sizes[i] = 0;
    return r;
}

/**
 * Linux sendmmsg：最多 2 条目标报文。
 */
SHUX_NET_UDP_GLUE_API int shu_net_udp_sendmmsg2_c(int32_t fd, uint32_t a0, uint32_t port0, const uint8_t *p0, size_t l0,
    uint32_t a1, uint32_t port1, const uint8_t *p1, size_t l1, int n) {
    struct sockaddr_in addrs[SHU_UDP_BATCH_MAX];
    struct iovec iov[SHU_UDP_BATCH_MAX];
    struct mmsghdr msgvec[SHU_UDP_BATCH_MAX];
    unsigned int i;
    int r;

    if (n <= 0 || n > SHU_UDP_BATCH_MAX)
        return -1;
    for (i = 0; i < (unsigned int)n; i++) {
        shu_udp_batch_set_addr_port(&addrs[i], (i == 0) ? a0 : a1, (i == 0) ? port0 : port1);
        iov[i].iov_base = (void *)((i == 0) ? p0 : p1);
        iov[i].iov_len  = (i == 0) ? l0 : l1;
        msgvec[i].msg_hdr.msg_name = &addrs[i];
        msgvec[i].msg_hdr.msg_namelen = sizeof(addrs[i]);
        msgvec[i].msg_hdr.msg_iov = &iov[i];
        msgvec[i].msg_hdr.msg_iovlen = 1;
        msgvec[i].msg_hdr.msg_control = NULL;
        msgvec[i].msg_hdr.msg_controllen = 0;
        msgvec[i].msg_hdr.msg_flags = 0;
    }
    r = sendmmsg((int)fd, msgvec, (unsigned int)n, 0);
    return (r < 0) ? -1 : r;
}

/**
 * Linux recvmmsg：Buffer 切片，n 为 1..8。
 */
SHUX_NET_UDP_GLUE_API int shu_net_udp_recvmmsg_buf_c(int32_t fd, shu_net_buf_t *bufs, int n, uint32_t timeout_ms,
    int32_t *out_sizes, uint32_t *out_addrs, uint32_t *out_ports) {
    struct iovec iov[SHU_UDP_BATCH_BUF_MAX];
    struct sockaddr_in addrs[SHU_UDP_BATCH_BUF_MAX];
    struct mmsghdr msgvec[SHU_UDP_BATCH_BUF_MAX];
    unsigned int i;
    int r;

    if (n <= 0 || n > SHU_UDP_BATCH_BUF_MAX || !bufs || !out_sizes || !out_addrs || !out_ports)
        return -1;
    for (i = 0; i < (unsigned int)n; i++) {
        socklen_t addrlen = sizeof(addrs[0]);
        iov[i].iov_base = bufs[i].ptr;
        iov[i].iov_len  = bufs[i].len;
        msgvec[i].msg_hdr.msg_name = &addrs[i];
        msgvec[i].msg_hdr.msg_namelen = addrlen;
        msgvec[i].msg_hdr.msg_iov = &iov[i];
        msgvec[i].msg_hdr.msg_iovlen = 1;
        msgvec[i].msg_hdr.msg_control = NULL;
        msgvec[i].msg_hdr.msg_controllen = 0;
        msgvec[i].msg_hdr.msg_flags = 0;
    }
    if (timeout_ms != 0) {
        if (shu_udp_batch_poll_readable((int)fd, timeout_ms) != 0)
            return -1;
    }
    r = recvmmsg((int)fd, msgvec, (unsigned int)n, 0, NULL);
    if (r < 0)
        return (errno == EAGAIN) ? 0 : -1;
    for (i = 0; i < (unsigned int)r; i++) {
        out_sizes[i] = (int32_t)msgvec[i].msg_len;
        out_addrs[i] = ntohl(addrs[i].sin_addr.s_addr);
        out_ports[i] = (uint32_t)ntohs(addrs[i].sin_port);
    }
    for (i = (unsigned int)r; i < (unsigned int)n; i++)
        out_sizes[i] = 0;
    return r;
}

/**
 * Linux sendmmsg：Buffer 切片，n 为 1..8。
 */
SHUX_NET_UDP_GLUE_API int shu_net_udp_sendmmsg_buf_c(int32_t fd, const uint32_t *addrs_u32, const uint32_t *ports,
    const shu_net_buf_t *bufs, int n) {
    struct sockaddr_in sa[SHU_UDP_BATCH_BUF_MAX];
    struct iovec iov[SHU_UDP_BATCH_BUF_MAX];
    struct mmsghdr msgvec[SHU_UDP_BATCH_BUF_MAX];
    unsigned int i;
    int r;

    if (n <= 0 || n > SHU_UDP_BATCH_BUF_MAX || !addrs_u32 || !ports || !bufs)
        return -1;
    for (i = 0; i < (unsigned int)n; i++) {
        shu_udp_batch_set_addr_port(&sa[i], addrs_u32[i], ports[i]);
        iov[i].iov_base = (void *)bufs[i].ptr;
        iov[i].iov_len  = bufs[i].len;
        msgvec[i].msg_hdr.msg_name = &sa[i];
        msgvec[i].msg_hdr.msg_namelen = sizeof(sa[i]);
        msgvec[i].msg_hdr.msg_iov = &iov[i];
        msgvec[i].msg_hdr.msg_iovlen = 1;
        msgvec[i].msg_hdr.msg_control = NULL;
        msgvec[i].msg_hdr.msg_controllen = 0;
        msgvec[i].msg_hdr.msg_flags = 0;
    }
    r = sendmmsg((int)fd, msgvec, (unsigned int)n, 0);
    return (r >= 0) ? r : -1;
}

#endif /* __linux__ && __GLIBC__ */
