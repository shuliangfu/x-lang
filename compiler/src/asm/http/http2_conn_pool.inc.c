/**
 * std/http/conn_pool.inc.c — HTTP/2 连接池 + 长连接 URL 客户端（STD-HTTP-H2-v12）
 *
 * 【文件职责】同 host:port 复用已 handshake 的 Http2Conn；h2c / h2 over TLS URL 请求。
 * 由 std/http/http_glue.c 在 network.inc.c 之后 #include。
 */

#include <stdlib.h>

#if !defined(_WIN32) && !defined(_WIN64)
#ifndef _WIN32
#include <sys/wait.h>
#endif
#endif

/** H2 连接池最大 idle 连接数。 */
#define HTTP2_POOL_MAX_CONNS 4

/** URL scheme 与池类型不匹配（-1238）。 */
#define HTTP2_ERR_POOL_SCHEME (-1238)

/** 池类型：cleartext h2c 或 https h2。 */
#define HTTP2_POOL_SCHEME_H2C 1
#define HTTP2_POOL_SCHEME_H2 0

/** HTTP/2 连接池（idle 栈 + 累计 connect 次数）。 */
typedef struct {
    char host[SHUX_HTTP_HOST_MAX];
    char port[8];
    int32_t max_conns;
    int32_t n_idle;
    int32_t connect_count;
    int32_t scheme_h2c;
    conn_t idle[HTTP2_POOL_MAX_CONNS];
} conn_pool_t;

/** URL host:port 是否与池绑定一致。 */
static int32_t pool_url_matches(const conn_pool_t *pool, const uint8_t *url,
                                      int32_t url_len, int32_t *out_is_https) {
    char host_buf[SHUX_HTTP_HOST_MAX];
    char port_buf[8];
    char path_buf[SHUX_HTTP_PATH_MAX];
    int32_t is_https = 0;
    if (!pool || !url || url_len <= 0)
        return 0;
    if (parse_http_url(url, url_len, host_buf, SHUX_HTTP_HOST_MAX, port_buf, (int)sizeof(port_buf),
                       path_buf, SHUX_HTTP_PATH_MAX, &is_https) != 0)
        return 0;
    if (out_is_https)
        *out_is_https = is_https;
    if (is_https != 0 && pool->scheme_h2c != 0)
        return 0;
    if (is_https == 0 && pool->scheme_h2c == 0)
        return 0;
    if (strcmp(host_buf, pool->host) != 0)
        return 0;
    if (strcmp(port_buf, pool->port) != 0)
        return 0;
    return 1;
}

/** 新建 TCP 连接并返回 fd；失败 -1。 */
static int32_t http2_pool_tcp_connect_c(const char *host, const char *port, uint32_t timeout_ms) {
#if defined(_WIN32) || defined(_WIN64)
    SOCKET fd;
#else
    int fd;
#endif
    struct addrinfo hints;
    struct addrinfo *res = NULL;

    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    if (getaddrinfo(host, port, &hints, &res) != 0 || !res)
        return -1;
#if defined(_WIN32) || defined(_WIN64)
    fd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
    if (fd == INVALID_SOCKET) {
#else
    fd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
    if (fd < 0) {
#endif
        freeaddrinfo(res);
        return -1;
    }
    if (timeout_ms > 0) {
        int32_t cr = http_connect_timeout((int)fd, res, timeout_ms);
        if (cr != 0) {
            SHUX_HTTP_CLOSE((int)fd);
            freeaddrinfo(res);
            return -1;
        }
    } else {
#if defined(_WIN32) || defined(_WIN64)
        if (connect(fd, res->ai_addr, (int)res->ai_addrlen) != 0) {
#else
        if (connect(fd, res->ai_addr, res->ai_addrlen) != 0) {
#endif
            SHUX_HTTP_CLOSE((int)fd);
            freeaddrinfo(res);
            return -1;
        }
    }
    freeaddrinfo(res);
    if (http_set_timeouts((int)fd, timeout_ms) != 0) {
        SHUX_HTTP_CLOSE((int)fd);
        return -1;
    }
    return (int32_t)fd;
}

/** 新建 h2c 连接并完成 handshake；成功 0。 */
static int32_t http2_pool_connect_h2c_new_c(conn_pool_t *pool, conn_t *conn,
                                            uint32_t timeout_ms) {
    int32_t fd;
    int32_t rc;

    if (!pool || !conn)
        return -1;
    fd = http2_pool_tcp_connect_c(pool->host, pool->port, timeout_ms);
    if (fd < 0)
        return -1;
    http2_conn_init_c(conn);
    if (http2_conn_attach_h2c_c(fd, conn) != 0) {
        SHUX_HTTP_CLOSE(fd);
        return -1;
    }
    rc = http2_conn_handshake_c(conn);
    if (rc != 0) {
        http2_conn_shutdown_c(conn);
        return rc;
    }
    pool->connect_count++;
    return 0;
}

/** 新建 h2 over TLS 连接并完成 handshake；成功 0。 */
static int32_t http2_pool_connect_h2_tls_new_c(conn_pool_t *pool, conn_t *conn,
                                                 uint32_t timeout_ms) {
    uint8_t alpn_wire[16];
    int32_t fd;
    int32_t alpn_len;
    int64_t tls_ctx;
    int32_t rc;

    if (!pool || !conn)
        return -1;
    if (http2_network_is_available_c() == 0)
        return HTTP2_ERR_NETWORK;
    fd = http2_pool_tcp_connect_c(pool->host, pool->port, timeout_ms);
    if (fd < 0)
        return -1;
    alpn_len = net_tls_alpn_h2_http1_wire_c(alpn_wire, (int32_t)sizeof(alpn_wire));
    if (alpn_len <= 0) {
        SHUX_HTTP_CLOSE(fd);
        return HTTP2_ERR_NETWORK;
    }
    tls_ctx = net_tls_connect_client_alpn_c(fd, pool->host, alpn_wire, alpn_len);
    if (tls_ctx == 0) {
        SHUX_HTTP_CLOSE(fd);
        return -1;
    }
    if (net_tls_alpn_is_h2_c(tls_ctx) == 0) {
        net_tls_close_c(tls_ctx);
        SHUX_HTTP_CLOSE(fd);
        return HTTP2_ERR_NETWORK;
    }
    http2_conn_init_c(conn);
    conn->fd = fd;
    if (http2_conn_attach_tls_c(tls_ctx, conn) != 0) {
        net_tls_close_c(tls_ctx);
        SHUX_HTTP_CLOSE(fd);
        return -1;
    }
    rc = http2_conn_handshake_c(conn);
    if (rc != 0) {
        http2_conn_shutdown_c(conn);
        return rc;
    }
    pool->connect_count++;
    return 0;
}

/** 从 idle 栈取出可复用连接；丢弃已 GOAWAY 的 idle 项。 */
static conn_t *http2_pool_acquire_conn_c(conn_pool_t *pool) {
    while (pool && pool->n_idle > 0) {
        conn_t *conn;
        pool->n_idle--;
        conn = &pool->idle[pool->n_idle];
        if (http2_conn_is_pool_reusable_c(conn) != 0)
            return conn;
        http2_conn_shutdown_c(conn);
    }
    return NULL;
}

/** 归还 ready 且未 GOAWAY 的连接到 idle 栈；否则 shutdown。 */
static void http2_pool_release_conn_c(conn_pool_t *pool, conn_t *conn) {
    if (!pool || !conn)
        return;
    if (http2_conn_is_pool_reusable_c(conn) == 0) {
        http2_conn_shutdown_c(conn);
        return;
    }
    if (pool->n_idle >= pool->max_conns) {
        http2_conn_shutdown_c(conn);
        return;
    }
    pool->idle[pool->n_idle] = *conn;
    pool->n_idle++;
}

/** 内部：创建池（scheme_h2c 非 0 表示 h2c）。 */
static int64_t http2_conn_pool_create_c(const uint8_t *host, int32_t host_len, const uint8_t *port,
                                        int32_t port_len, int32_t max_conns, int32_t scheme_h2c) {
    conn_pool_t *pool;
    if (!host || host_len <= 0 || host_len >= SHUX_HTTP_HOST_MAX)
        return 0;
    if (!port || port_len <= 0 || port_len >= 8)
        return 0;
    if (scheme_h2c == 0 && http2_network_is_available_c() == 0)
        return 0;
    if (max_conns <= 0)
        max_conns = 1;
    if (max_conns > HTTP2_POOL_MAX_CONNS)
        max_conns = HTTP2_POOL_MAX_CONNS;
    pool = (conn_pool_t *)calloc(1, sizeof(*pool));
    if (!pool)
        return 0;
    memcpy(pool->host, host, (size_t)host_len);
    pool->host[host_len] = '\0';
    memcpy(pool->port, port, (size_t)port_len);
    pool->port[port_len] = '\0';
    pool->max_conns = max_conns;
    pool->scheme_h2c = scheme_h2c;
    return (int64_t)(intptr_t)pool;
}

/** 创建 h2c（http://）连接池；失败返回 0。 */
int64_t http2_conn_pool_create_h2c_c(const uint8_t *host, int32_t host_len, const uint8_t *port,
                                     int32_t port_len, int32_t max_conns) {
    return http2_conn_pool_create_c(host, host_len, port, port_len, max_conns, HTTP2_POOL_SCHEME_H2C);
}

/** 创建 h2 over TLS（https://）连接池；失败返回 0。 */
int64_t http2_conn_pool_create_h2_c(const uint8_t *host, int32_t host_len, const uint8_t *port,
                                    int32_t port_len, int32_t max_conns) {
    return http2_conn_pool_create_c(host, host_len, port, port_len, max_conns, HTTP2_POOL_SCHEME_H2);
}

/** 关闭池内全部 idle 连接并释放池。 */
void http2_conn_pool_destroy_c(int64_t pool_h) {
    conn_pool_t *pool = (conn_pool_t *)(intptr_t)pool_h;
    int32_t i;
    if (!pool)
        return;
    for (i = 0; i < pool->n_idle; i++)
        http2_conn_shutdown_c(&pool->idle[i]);
    free(pool);
}

/**
 * 经连接池发 HTTP/2 请求（URL 须匹配池 host:port + scheme）。
 * 对端 GOAWAY 后自动丢弃连接并重试一次新建连接。
 * 成功返回 raw_len；scheme 不匹配 HTTP2_ERR_POOL_SCHEME(-1238)。
 */
int32_t http2_conn_pool_request_c(int64_t pool_h, uint8_t method_u8, const uint8_t *url,
                                int32_t url_len, const uint8_t *body, int32_t body_len,
                                uint8_t *out_buf, int32_t out_cap, uint32_t timeout_ms) {
    conn_pool_t *pool = (conn_pool_t *)(intptr_t)pool_h;
    char host_buf[SHUX_HTTP_HOST_MAX];
    char port_buf[8];
    char path_buf[SHUX_HTTP_PATH_MAX];
    conn_t work;
    conn_t *conn;
    int32_t is_https = 0;
    int32_t rc;
    int32_t attempt;

    if (!pool || !url || !out_buf || url_len <= 0 || out_cap <= 0)
        return -1;
    if (http_method_from_u8(method_u8) == NULL)
        return -1;
    if (pool_url_matches(pool, url, url_len, &is_https) == 0) {
        if (parse_http_url(url, url_len, host_buf, SHUX_HTTP_HOST_MAX, port_buf, (int)sizeof(port_buf),
                           path_buf, SHUX_HTTP_PATH_MAX, &is_https) != 0)
            return -1;
        if ((is_https != 0 && pool->scheme_h2c != 0) || (is_https == 0 && pool->scheme_h2c == 0))
            return HTTP2_ERR_POOL_SCHEME;
        return -1;
    }
    if (parse_http_url(url, url_len, host_buf, SHUX_HTTP_HOST_MAX, port_buf, (int)sizeof(port_buf),
                       path_buf, SHUX_HTTP_PATH_MAX, &is_https) != 0)
        return -1;

    for (attempt = 0; attempt < 2; attempt++) {
        conn = http2_pool_acquire_conn_c(pool);
        if (conn == NULL) {
            conn = &work;
            if (pool->scheme_h2c != 0)
                rc = http2_pool_connect_h2c_new_c(pool, conn, timeout_ms);
            else
                rc = http2_pool_connect_h2_tls_new_c(pool, conn, timeout_ms);
            if (rc != 0)
                return rc;
        }

        rc = http2_conn_request_c(conn, method_u8, (const uint8_t *)host_buf, (int32_t)strlen(host_buf),
                                  (const uint8_t *)path_buf, (int32_t)strlen(path_buf), body, body_len,
                                  out_buf, out_cap);
        if (rc >= 0) {
            http2_pool_release_conn_c(pool, conn);
            return rc;
        }
        http2_conn_shutdown_c(conn);
        if (rc != HTTP2_ERR_GOAWAY && http2_conn_goaway_seen_c(conn) == 0)
            return rc;
    }
    return HTTP2_ERR_GOAWAY;
}

/** h2c 池 GET URL 请求。 */
int32_t http_h2c_pool_get_c(int64_t pool_h, const uint8_t *url, int32_t url_len, uint8_t *out_buf,
                            int32_t out_cap, uint32_t timeout_ms) {
    return http2_conn_pool_request_c(pool_h, 0, url, url_len, NULL, 0, out_buf, out_cap, timeout_ms);
}

/** h2 over TLS 池 GET URL 请求。 */
int32_t http_h2_pool_get_c(int64_t pool_h, const uint8_t *url, int32_t url_len, uint8_t *out_buf,
                           int32_t out_cap, uint32_t timeout_ms) {
    return http2_conn_pool_request_c(pool_h, 0, url, url_len, NULL, 0, out_buf, out_cap, timeout_ms);
}

/** 池累计新建连接次数（烟测用）。 */
int32_t http2_conn_pool_connect_count_c(int64_t pool_h) {
    conn_pool_t *pool = (conn_pool_t *)(intptr_t)pool_h;
    if (!pool)
        return -1;
    return pool->connect_count;
}

/** 连接池 C 烟测（create/destroy + scheme 检测）；0 通过。 */
int32_t http2_conn_pool_smoke_c(void) {
    int64_t h2c_pool;
    int64_t h2_pool;
    uint8_t out[64];
    static const uint8_t h2c_url[] = "http://127.0.0.1:9/a";
    static const uint8_t https_url[] = "https://127.0.0.1/a";

    h2c_pool = http2_conn_pool_create_h2c_c((const uint8_t *)"127.0.0.1", 9, (const uint8_t *)"9", 1, 2);
    if (h2c_pool == 0)
        return 1;
    if (http2_conn_pool_connect_count_c(h2c_pool) != 0)
        return 2;
    if (http2_conn_pool_request_c(h2c_pool, 0, https_url, (int32_t)(sizeof(https_url) - 1), NULL, 0,
                                  out, 64, 0) != HTTP2_ERR_POOL_SCHEME)
        return 3;
    if (http2_conn_pool_request_c(h2c_pool, 0, (const uint8_t *)"http://other:9/", 15, NULL, 0, out,
                                  64, 0) != -1)
        return 4;
    http2_conn_pool_destroy_c(h2c_pool);

    if (http2_network_is_available_c() != 0) {
        h2_pool = http2_conn_pool_create_h2_c((const uint8_t *)"127.0.0.1", 9, (const uint8_t *)"9", 1, 1);
        if (h2_pool == 0)
            return 5;
        if (http_h2_pool_get_c(h2_pool, h2c_url, (int32_t)(sizeof(h2c_url) - 1), out, 64, 0) !=
            HTTP2_ERR_POOL_SCHEME)
            return 6;
        http2_conn_pool_destroy_c(h2_pool);
    }
    return 0;
}

/** 连接池 API 是否可用（v12 恒 1）。 */
int32_t http2_conn_pool_is_available_c(void) { return 1; }

/**
 * h2c 连接池 GOAWAY 感知集成烟测：首连 serve+GOAWAY 后第二次请求须新建 TCP；Windows 跳过。
 */
int32_t http2_h2c_pool_goaway_smoke_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    return 0;
#else
    struct sockaddr_in sin;
    socklen_t slen = (socklen_t)sizeof(sin);
    pid_t pid;
    int lfd;
    uint16_t bound_port;
    int status;
    static const uint8_t body[] = "p2";
    char url_buf[64];

    lfd = (int)http_listen_c(0x7f000001u, 0u, 4);
    if (lfd < 0)
        return 1;
    if (getsockname(lfd, (struct sockaddr *)&sin, &slen) != 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 2;
    }
    bound_port = ntohs(sin.sin_port);

    pid = fork();
    if (pid < 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 3;
    }
    if (pid == 0) {
        int64_t pool;
        uint8_t out[512];
        char port_buf[8];
        int32_t n1;
        int32_t n2;
        int32_t cc;

        if (snprintf(port_buf, sizeof(port_buf), "%u", (unsigned)bound_port) <= 0)
            _exit(60);
        if (snprintf(url_buf, sizeof(url_buf), "http://127.0.0.1:%u/", (unsigned)bound_port) <= 0)
            _exit(61);
        pool = http2_conn_pool_create_h2c_c((const uint8_t *)"127.0.0.1", 9, (const uint8_t *)port_buf,
                                            (int32_t)strlen(port_buf), 1);
        if (pool == 0)
            _exit(62);
        n1 = http_h2c_pool_get_c(pool, (const uint8_t *)url_buf, (int32_t)strlen(url_buf), out,
                                 (int32_t)sizeof(out), 5000u);
        if (n1 <= 0) {
            http2_conn_pool_destroy_c(pool);
            _exit(63);
        }
        n2 = http_h2c_pool_get_c(pool, (const uint8_t *)url_buf, (int32_t)strlen(url_buf), out,
                                 (int32_t)sizeof(out), 5000u);
        cc = http2_conn_pool_connect_count_c(pool);
        http2_conn_pool_destroy_c(pool);
        if (n2 <= 0)
            _exit(64);
        if (cc != 2)
            _exit(65);
        _exit(0);
    }

    if (http2_serve_h2c_one_with_goaway_c(lfd, body, 2, 1, 5000u) != 0) {
        (void)kill(pid, SIGKILL);
        (void)waitpid(pid, NULL, 0);
        SHUX_HTTP_CLOSE(lfd);
        return 4;
    }
    if (http2_serve_h2c_one_c(lfd, body, 2, 5000u) != 0) {
        (void)kill(pid, SIGKILL);
        (void)waitpid(pid, NULL, 0);
        SHUX_HTTP_CLOSE(lfd);
        return 5;
    }
    if (waitpid(pid, &status, 0) != pid || !WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 6;
    }
    SHUX_HTTP_CLOSE(lfd);
    return 0;
#endif
}

/** 连接池 GOAWAY 感知烟测（离线 + h2c fork 集成）；0 通过。 */
int32_t http2_conn_pool_goaway_smoke_c(void) {
    if (http2_conn_pool_smoke_c() != 0)
        return 1;
    if (http2_h2c_pool_goaway_smoke_c() != 0)
        return 2;
    return 0;
}
