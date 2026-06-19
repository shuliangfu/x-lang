/**
 * std/net/tcp_pool.inc.c — TCP idle 连接复用池（STD-164）
 *
 * 【文件职责】按 IPv4 addr:port 缓存 idle TCP fd；acquire 优先复用，否则 net_tcp_connect_blocking。
 * 由 net.c 末尾 #include。
 */

#include <stdlib.h>
#include <string.h>

#if !defined(_WIN32) && !defined(_WIN64)
#include <poll.h>
#include <signal.h>
#include <sys/wait.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#endif

/** 单池最大 idle 连接数。 */
#define NET_TCP_POOL_MAX_IDLE 8

/** TCP 连接池（IPv4 host-order addr + port + idle 栈）。 */
typedef struct {
    uint32_t addr_u32;
    uint32_t port_u32;
    int32_t max_idle;
    int32_t n_idle;
    int32_t connect_count;
    int32_t idle_fds[NET_TCP_POOL_MAX_IDLE];
} net_tcp_pool_t;

/**
 * 创建 TCP 连接池；addr_u32 为 IPv4（如 0x7f000001）；max_idle≤0 时默认 1。
 * 失败返回 0。
 */
int64_t net_tcp_pool_create_c(uint32_t addr_u32, uint32_t port_u32, int32_t max_idle) {
    net_tcp_pool_t *pool;
    int32_t i;

    if (max_idle <= 0)
        max_idle = 1;
    if (max_idle > NET_TCP_POOL_MAX_IDLE)
        max_idle = NET_TCP_POOL_MAX_IDLE;
    pool = (net_tcp_pool_t *)calloc(1, sizeof(*pool));
    if (!pool)
        return 0;
    pool->addr_u32 = addr_u32;
    pool->port_u32 = port_u32;
    pool->max_idle = max_idle;
    for (i = 0; i < NET_TCP_POOL_MAX_IDLE; i++)
        pool->idle_fds[i] = -1;
    return (int64_t)(intptr_t)pool;
}

/** 关闭全部 idle fd 并清零栈（不 free 池对象）。 */
void net_tcp_pool_drain_c(int64_t pool_h) {
    net_tcp_pool_t *pool = (net_tcp_pool_t *)(intptr_t)pool_h;
    int32_t i;

    if (!pool)
        return;
    for (i = 0; i < pool->n_idle; i++) {
        if (pool->idle_fds[i] >= 0)
            (void)net_close_socket_c(pool->idle_fds[i]);
        pool->idle_fds[i] = -1;
    }
    pool->n_idle = 0;
}

/** 销毁连接池（先 drain 再 free）。 */
void net_tcp_pool_destroy_c(int64_t pool_h) {
    net_tcp_pool_t *pool = (net_tcp_pool_t *)(intptr_t)pool_h;
    if (!pool)
        return;
    net_tcp_pool_drain_c(pool_h);
    free(pool);
}

/**
 * 从池取连接：有 idle 则复用；否则 net_tcp_connect_blocking 并递增 connect_count。
 * 失败返回 -1。
 */
int32_t net_tcp_pool_acquire_c(int64_t pool_h, uint32_t timeout_ms) {
    net_tcp_pool_t *pool = (net_tcp_pool_t *)(intptr_t)pool_h;
    int32_t fd;

    if (!pool)
        return -1;
    if (pool->n_idle > 0) {
        pool->n_idle--;
        fd = pool->idle_fds[pool->n_idle];
        pool->idle_fds[pool->n_idle] = -1;
        return fd;
    }
    fd = net_tcp_connect_blocking_c(pool->addr_u32, pool->port_u32, timeout_ms);
    if (fd >= 0)
        pool->connect_count++;
    return fd;
}

/**
 * 归还 fd 到 idle 栈；栈满则 close。
 * 成功 0；参数非法 -1。
 */
int32_t net_tcp_pool_release_c(int64_t pool_h, int32_t fd) {
    net_tcp_pool_t *pool = (net_tcp_pool_t *)(intptr_t)pool_h;

    if (!pool || fd < 0)
        return -1;
    if (pool->n_idle >= pool->max_idle) {
        (void)net_close_socket_c(fd);
        return 0;
    }
    pool->idle_fds[pool->n_idle] = fd;
    pool->n_idle++;
    return 0;
}

/** 累计新建 TCP 连接次数（烟测/诊断）。 */
int32_t net_tcp_pool_connect_count_c(int64_t pool_h) {
    net_tcp_pool_t *pool = (net_tcp_pool_t *)(intptr_t)pool_h;
    if (!pool)
        return -1;
    return pool->connect_count;
}

/** 当前 idle 连接数。 */
int32_t net_tcp_pool_idle_count_c(int64_t pool_h) {
    net_tcp_pool_t *pool = (net_tcp_pool_t *)(intptr_t)pool_h;
    if (!pool)
        return -1;
    return pool->n_idle;
}

#if !defined(_WIN32) && !defined(_WIN64)
/**
 * fork 烟测专用：阻塞 listener（与 http_listen_c 一致，避免 net_tcp_listen_c 非阻塞 accept 时序问题）。
 */
static int32_t net_tcp_pool_listen_ephemeral_c(uint16_t *out_port) {
    struct sockaddr_in sin;
    socklen_t slen = (socklen_t)sizeof(sin);
    int opt = 1;
    int fd;

    if (!out_port)
        return -1;
    fd = (int)socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0)
        return -1;
    (void)setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &opt, (socklen_t)sizeof(opt));
    memset(&sin, 0, sizeof(sin));
    sin.sin_family = AF_INET;
    sin.sin_addr.s_addr = htonl(0x7f000001u);
    sin.sin_port = 0;
    if (bind(fd, (struct sockaddr *)&sin, slen) != 0) {
        close(fd);
        return -1;
    }
    if (listen(fd, 8) != 0) {
        close(fd);
        return -1;
    }
    if (getsockname(fd, (struct sockaddr *)&sin, &slen) != 0) {
        close(fd);
        return -1;
    }
    *out_port = ntohs(sin.sin_port);
    return (int32_t)fd;
}

/**
 * fork 集成烟测：单池 acquire→release→acquire 须只建连 1 次；Windows 跳过返回 0。
 */
static int32_t net_tcp_pool_fork_smoke_c(void) {
    uint16_t bound_port;
    pid_t pid;
    int lfd;
    int status;
    int client;
    uint8_t buf[8];
    ssize_t n;

    lfd = net_tcp_pool_listen_ephemeral_c(&bound_port);
    if (lfd < 0)
        return 1;
    pid = fork();
    if (pid < 0) {
        close(lfd);
        return 3;
    }
    if (pid == 0) {
        int64_t pool_h;
        int32_t fd1;
        int32_t fd2;
        int32_t cc;
        static const uint8_t msg_a[] = "A";
        static const uint8_t msg_b[] = "B";

        pool_h = net_tcp_pool_create_c(0x7f000001u, (uint32_t)bound_port, 1);
        if (pool_h == 0)
            _exit(10);
        fd1 = net_tcp_pool_acquire_c(pool_h, 5000u);
        if (fd1 < 0) {
            net_tcp_pool_destroy_c(pool_h);
            _exit(11);
        }
        if (net_set_blocking_c(fd1, 1) != 0) {
            net_tcp_pool_destroy_c(pool_h);
            _exit(12);
        }
        if (send(fd1, msg_a, 1, 0) != 1) {
            net_tcp_pool_destroy_c(pool_h);
            _exit(13);
        }
        if (net_tcp_pool_release_c(pool_h, fd1) != 0) {
            net_tcp_pool_destroy_c(pool_h);
            _exit(14);
        }
        fd2 = net_tcp_pool_acquire_c(pool_h, 5000u);
        if (fd2 < 0) {
            net_tcp_pool_destroy_c(pool_h);
            _exit(15);
        }
        if (net_set_blocking_c(fd2, 1) != 0) {
            net_tcp_pool_destroy_c(pool_h);
            _exit(16);
        }
        if (send(fd2, msg_b, 1, 0) != 1) {
            net_tcp_pool_destroy_c(pool_h);
            _exit(17);
        }
        cc = net_tcp_pool_connect_count_c(pool_h);
        net_tcp_pool_destroy_c(pool_h);
        if (cc != 1)
            _exit(18);
        _exit(0);
    }

    {
        struct pollfd pfd;
        int total = 0;

        pfd.fd = lfd;
        pfd.events = POLLIN;
        pfd.revents = 0;
        if (poll(&pfd, 1, 10000) <= 0) {
            (void)kill(pid, SIGKILL);
            (void)waitpid(pid, NULL, 0);
            close(lfd);
            return 4;
        }
        client = (int)accept(lfd, NULL, NULL);
        if (client < 0) {
            (void)kill(pid, SIGKILL);
            (void)waitpid(pid, NULL, 0);
            close(lfd);
            return 4;
        }
        while (total < 2) {
            n = recv(client, buf + total, sizeof(buf) - (size_t)total, 0);
            if (n <= 0)
                break;
            total += (int)n;
        }
        if (total != 2 || buf[0] != (uint8_t)'A' || buf[1] != (uint8_t)'B') {
            close(client);
            (void)kill(pid, SIGKILL);
            (void)waitpid(pid, NULL, 0);
            close(lfd);
            return 5;
        }
    }
    close(client);
    if (waitpid(pid, &status, 0) != pid || !WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        close(lfd);
        return 6;
    }
    close(lfd);
    return 0;
}
#endif

/** TCP 连接池 C 烟测（离线 + fork 集成）；0 通过。 */
int32_t net_tcp_pool_smoke_c(void) {
    int64_t pool_h;

    pool_h = net_tcp_pool_create_c(0x7f000001u, 9u, 2);
    if (pool_h == 0)
        return 1;
    if (net_tcp_pool_connect_count_c(pool_h) != 0)
        return 2;
    if (net_tcp_pool_idle_count_c(pool_h) != 0)
        return 3;
    net_tcp_pool_destroy_c(pool_h);
#if !defined(_WIN32) && !defined(_WIN64)
    {
        int32_t attempt;
        int32_t fr;

        for (attempt = 0; attempt < 3; attempt++) {
            fr = net_tcp_pool_fork_smoke_c();
            if (fr == 0)
                break;
            if (attempt == 2)
                return 4;
        }
    }
#endif
    return 0;
}
