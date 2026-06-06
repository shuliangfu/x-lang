/**
 * tests/bench/io_multishot_accept_smoke.c — IO-A4 multishot accept Linux 烟测
 *
 * 监听 127.0.0.1 动态端口，4 客户端建连后 io_uring_accept_many 批量 accept；
 * 在 liburing + 内核 6.0+ 下 shu_io_uring_multishot_accept_hits() 应 > 0。
 *
 * 编译（Linux）：cc -std=c11 -Wall -Wextra -o io_multishot_accept_smoke \
 *   tests/bench/io_multishot_accept_smoke.c std/io/io.o -luring -lpthread
 */
#include <arpa/inet.h>
#include <errno.h>
#include <netinet/in.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

extern int io_uring_accept_many(int listener_fd, int32_t *out_fds, int n, unsigned timeout_ms);
extern unsigned shu_io_uring_multishot_accept_hits(void);
extern void shu_io_uring_multishot_accept_stats_reset(void);

/** 创建监听 socket 并 bind 127.0.0.1:0；成功返回 listener fd，失败 -1。 */
static int listen_on_ephemeral(void) {
    int fd;
    struct sockaddr_in addr;
    socklen_t alen = (socklen_t)sizeof(addr);

    fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0)
        return -1;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    addr.sin_port = 0;
    if (bind(fd, (struct sockaddr *)&addr, sizeof(addr)) != 0) {
        (void)close(fd);
        return -1;
    }
    if (listen(fd, 16) != 0) {
        (void)close(fd);
        return -1;
    }
    if (getsockname(fd, (struct sockaddr *)&addr, &alen) != 0) {
        (void)close(fd);
        return -1;
    }
    return fd;
}

/** 向 listener 端口发起一次 TCP connect；成功返回 client fd。 */
static int connect_to_listener(uint16_t port) {
    int fd;
    struct sockaddr_in addr;

    fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0)
        return -1;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    addr.sin_port = htons(port);
    if (connect(fd, (struct sockaddr *)&addr, sizeof(addr)) != 0) {
        (void)close(fd);
        return -1;
    }
    return fd;
}

/** 读取 listener 绑定端口。 */
static int listener_port(int listener_fd) {
    struct sockaddr_in addr;
    socklen_t alen = (socklen_t)sizeof(addr);
    if (getsockname(listener_fd, (struct sockaddr *)&addr, &alen) != 0)
        return -1;
    return (int)ntohs(addr.sin_port);
}

/**
 * 入口：4 connect + accept_many；Linux CI 上校验 multishot hits。
 */
int main(void) {
    int listener;
    int port;
    int32_t out_fds[8];
    int accepted;
    unsigned hits;
    int i;

#if !defined(__linux__)
    fprintf(stderr, "io_multishot_accept_smoke: skip (not Linux)\n");
    return 0;
#endif

    setenv("SHU_IO_URING_MULTISHOT_ACCEPT", "1", 1);
    shu_io_uring_multishot_accept_stats_reset();

    listener = listen_on_ephemeral();
    if (listener < 0) {
        fprintf(stderr, "io_multishot_accept_smoke: listen failed\n");
        return 1;
    }
    port = listener_port(listener);
    if (port < 0) {
        fprintf(stderr, "io_multishot_accept_smoke: getsockname failed\n");
        (void)close(listener);
        return 2;
    }

    for (i = 0; i < 4; i++) {
        int c = connect_to_listener((uint16_t)port);
        if (c < 0) {
            fprintf(stderr, "io_multishot_accept_smoke: connect %d failed: %s\n", i, strerror(errno));
            (void)close(listener);
            return 3;
        }
        (void)close(c);
    }

    accepted = io_uring_accept_many(listener, out_fds, 4, 5000u);
    if (accepted != 4) {
        fprintf(stderr, "io_multishot_accept_smoke: accepted=%d want 4\n", accepted);
        (void)close(listener);
        return 4;
    }
    for (i = 0; i < accepted; i++)
        (void)close(out_fds[i]);
    (void)close(listener);

    hits = shu_io_uring_multishot_accept_hits();
    if (hits == 0) {
        fprintf(stderr, "io_multishot_accept_smoke: multishot hits=0 (need kernel 6.0+ multishot accept)\n");
        return 5;
    }
    return 0;
}
