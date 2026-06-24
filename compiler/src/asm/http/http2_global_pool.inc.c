/**
 * std/http/http2_global_pool.inc.c — HTTP/2 全局连接池（STD-HTTP-H2-v13）
 *
 * 【文件职责】按 URL 解析 host:port + scheme，自动查找或创建 per-host H2 连接池并转发请求。
 * 由 std/http/http_glue.c 在 http2_conn_pool.inc.c 之后 #include。
 */

#include <stdlib.h>

/** 全局池最多缓存的不同 host:port 条目数。 */
#define HTTP2_GLOBAL_POOL_MAX_ENTRIES 8

/** 全局池条目已满（-1239）。 */
#define HTTP2_ERR_GLOBAL_POOL_FULL (-1239)

/** 全局池内单 host 路由条目（scheme + host:port → 子连接池句柄）。 */
typedef struct {
    char host[SHUX_HTTP_HOST_MAX];
    char port[8];
    int32_t scheme_h2c;
    int64_t pool_h;
} http2_global_pool_entry_t;

/** HTTP/2 全局连接池（多 host:port 子池路由表）。 */
typedef struct {
    int32_t max_entries;
    int32_t max_conns_per_host;
    int32_t n_entries;
    http2_global_pool_entry_t entries[HTTP2_GLOBAL_POOL_MAX_ENTRIES];
} http2_global_pool_t;

/** host:port + scheme 是否与条目一致。 */
static int32_t http2_global_entry_matches(const http2_global_pool_entry_t *e, const char *host,
                                          const char *port, int32_t scheme_h2c) {
    if (!e || e->pool_h == 0)
        return 0;
    if (e->scheme_h2c != scheme_h2c)
        return 0;
    if (strcmp(e->host, host) != 0)
        return 0;
    if (strcmp(e->port, port) != 0)
        return 0;
    return 1;
}

/** 查找已有子池条目；未找到返回 NULL。 */
static http2_global_pool_entry_t *http2_global_find_entry_c(http2_global_pool_t *gp,
                                                            const char *host, const char *port,
                                                            int32_t scheme_h2c) {
    int32_t i;
    if (!gp)
        return NULL;
    for (i = 0; i < gp->n_entries; i++) {
        if (http2_global_entry_matches(&gp->entries[i], host, port, scheme_h2c) != 0)
            return &gp->entries[i];
    }
    return NULL;
}

/** 为 host:port 新建子连接池并登记；失败 -1；满池 HTTP2_ERR_GLOBAL_POOL_FULL。 */
static int32_t http2_global_add_entry_c(http2_global_pool_t *gp, const char *host, const char *port,
                                        int32_t scheme_h2c) {
    http2_global_pool_entry_t *e;
    int64_t pool_h;
    int32_t host_len;
    int32_t port_len;

    if (!gp || !host || !port)
        return -1;
    if (gp->n_entries >= gp->max_entries || gp->n_entries >= HTTP2_GLOBAL_POOL_MAX_ENTRIES)
        return HTTP2_ERR_GLOBAL_POOL_FULL;
    host_len = (int32_t)strlen(host);
    port_len = (int32_t)strlen(port);
    if (scheme_h2c != 0)
        pool_h = http2_conn_pool_create_h2c_c((const uint8_t *)host, host_len, (const uint8_t *)port,
                                              port_len, gp->max_conns_per_host);
    else
        pool_h = http2_conn_pool_create_h2_c((const uint8_t *)host, host_len, (const uint8_t *)port,
                                             port_len, gp->max_conns_per_host);
    if (pool_h == 0)
        return -1;
    e = &gp->entries[gp->n_entries];
    memset(e, 0, sizeof(*e));
    strncpy(e->host, host, SHUX_HTTP_HOST_MAX - 1);
    strncpy(e->port, port, (size_t)(sizeof(e->port) - 1));
    e->scheme_h2c = scheme_h2c;
    e->pool_h = pool_h;
    gp->n_entries++;
    return 0;
}

/** 解析 URL 并查找/创建子池；失败 -1；满池 HTTP2_ERR_GLOBAL_POOL_FULL。 */
static int64_t http2_global_resolve_pool_c(http2_global_pool_t *gp, const uint8_t *url,
                                           int32_t url_len) {
    char host_buf[SHUX_HTTP_HOST_MAX];
    char port_buf[8];
    char path_buf[SHUX_HTTP_PATH_MAX];
    http2_global_pool_entry_t *e;
    int32_t is_https = 0;
    int32_t scheme_h2c;
    int32_t rc;

    if (!gp || !url || url_len <= 0)
        return 0;
    if (parse_http_url(url, url_len, host_buf, SHUX_HTTP_HOST_MAX, port_buf, (int)sizeof(port_buf),
                       path_buf, SHUX_HTTP_PATH_MAX, &is_https) != 0)
        return 0;
    scheme_h2c = (is_https == 0) ? 1 : 0;
    e = http2_global_find_entry_c(gp, host_buf, port_buf, scheme_h2c);
    if (e != NULL)
        return e->pool_h;
    rc = http2_global_add_entry_c(gp, host_buf, port_buf, scheme_h2c);
    if (rc != 0)
        return (int64_t)rc;
    e = http2_global_find_entry_c(gp, host_buf, port_buf, scheme_h2c);
    if (e == NULL)
        return 0;
    return e->pool_h;
}

/** 创建全局 H2 连接池；max_entries<=0 默认 4；max_conns_per_host<=0 默认 2。 */
int64_t http2_global_pool_create_c(int32_t max_entries, int32_t max_conns_per_host) {
    http2_global_pool_t *gp;
    if (max_entries <= 0)
        max_entries = 4;
    if (max_entries > HTTP2_GLOBAL_POOL_MAX_ENTRIES)
        max_entries = HTTP2_GLOBAL_POOL_MAX_ENTRIES;
    if (max_conns_per_host <= 0)
        max_conns_per_host = 2;
    if (max_conns_per_host > HTTP2_POOL_MAX_CONNS)
        max_conns_per_host = HTTP2_POOL_MAX_CONNS;
    gp = (http2_global_pool_t *)calloc(1, sizeof(*gp));
    if (!gp)
        return 0;
    gp->max_entries = max_entries;
    gp->max_conns_per_host = max_conns_per_host;
    return (int64_t)(intptr_t)gp;
}

/** 销毁全局池及全部子连接池。 */
void http2_global_pool_destroy_c(int64_t gpool_h) {
    http2_global_pool_t *gp = (http2_global_pool_t *)(intptr_t)gpool_h;
    int32_t i;
    if (!gp)
        return;
    for (i = 0; i < gp->n_entries; i++) {
        if (gp->entries[i].pool_h != 0)
            http2_conn_pool_destroy_c(gp->entries[i].pool_h);
    }
    free(gp);
}

/** 当前已登记的不同 host:port 子池数量（烟测用）。 */
int32_t http2_global_pool_entry_count_c(int64_t gpool_h) {
    http2_global_pool_t *gp = (http2_global_pool_t *)(intptr_t)gpool_h;
    if (!gp)
        return -1;
    return gp->n_entries;
}

/** 全局池内全部子池累计新建连接次数（烟测/诊断）。 */
int32_t http2_global_pool_connect_count_c(int64_t gpool_h) {
    http2_global_pool_t *gp = (http2_global_pool_t *)(intptr_t)gpool_h;
    int32_t i;
    int32_t sum = 0;
    if (!gp)
        return -1;
    for (i = 0; i < gp->n_entries; i++) {
        if (gp->entries[i].pool_h != 0)
            sum += http2_conn_pool_connect_count_c(gp->entries[i].pool_h);
    }
    return sum;
}

/**
 * 经全局池发 HTTP/2 请求（URL 自动路由 host:port + scheme）。
 * 成功返回 raw_len；满池 HTTP2_ERR_GLOBAL_POOL_FULL(-1239)。
 */
int32_t http2_global_pool_request_c(int64_t gpool_h, uint8_t method_u8, const uint8_t *url,
                                    int32_t url_len, const uint8_t *body, int32_t body_len,
                                    uint8_t *out_buf, int32_t out_cap, uint32_t timeout_ms) {
    int64_t pool_h;
    if (!url || !out_buf || url_len <= 0 || out_cap <= 0)
        return -1;
    pool_h = http2_global_resolve_pool_c((http2_global_pool_t *)(intptr_t)gpool_h, url, url_len);
    if (pool_h == 0)
        return -1;
    if (pool_h < 0)
        return (int32_t)pool_h;
    return http2_conn_pool_request_c(pool_h, method_u8, url, url_len, body, body_len, out_buf,
                                     out_cap, timeout_ms);
}

/** 全局池 GET URL 请求（http:// 或 https:// 自动选 h2c/h2 子池）。 */
int32_t http2_global_pool_get_c(int64_t gpool_h, const uint8_t *url, int32_t url_len,
                                uint8_t *out_buf, int32_t out_cap, uint32_t timeout_ms) {
    return http2_global_pool_request_c(gpool_h, 0, url, url_len, NULL, 0, out_buf, out_cap,
                                       timeout_ms);
}

/** 全局池 C 烟测（路由 + 满池检测，无需真实 server）；0 通过。 */
int32_t http2_global_pool_smoke_c(void) {
    int64_t gpool;
    uint8_t out[64];
    static const uint8_t url_a[] = "http://127.0.0.1:9/a";
    static const uint8_t url_b[] = "http://other:9/b";
    static const uint8_t url_c[] = "http://third:9/c";

    gpool = http2_global_pool_create_c(2, 1);
    if (gpool == 0)
        return 1;
    (void)http2_global_pool_get_c(gpool, url_a, (int32_t)(sizeof(url_a) - 1), out, 64, 0);
    if (http2_global_pool_entry_count_c(gpool) != 1)
        return 2;
    (void)http2_global_pool_get_c(gpool, url_a, (int32_t)(sizeof(url_a) - 1), out, 64, 0);
    if (http2_global_pool_entry_count_c(gpool) != 1)
        return 3;
    (void)http2_global_pool_get_c(gpool, url_b, (int32_t)(sizeof(url_b) - 1), out, 64, 0);
    if (http2_global_pool_entry_count_c(gpool) != 2)
        return 4;
    if (http2_global_pool_get_c(gpool, url_c, (int32_t)(sizeof(url_c) - 1), out, 64, 0) !=
        HTTP2_ERR_GLOBAL_POOL_FULL)
        return 5;
    http2_global_pool_destroy_c(gpool);
    return 0;
}

/** 全局池 API 是否可用（v13 恒 1）。 */
int32_t http2_global_pool_is_available_c(void) { return 1; }

#if !defined(_WIN32) && !defined(_WIN64)
#include <sys/wait.h>
#endif

/**
 * 全局池 GOAWAY 感知集成烟测：经 global_pool 两次 GET 须新建两条 TCP；Windows 跳过。
 */
int32_t http2_h2c_global_pool_goaway_smoke_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    return 0;
#else
    struct sockaddr_in sin;
    socklen_t slen = (socklen_t)sizeof(sin);
    pid_t pid;
    int lfd;
    uint16_t bound_port;
    int status;
    static const uint8_t body[] = "gp";

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
        int64_t gpool;
        uint8_t out[512];
        char url_buf[64];
        int32_t n1;
        int32_t n2;
        int32_t cc;

        if (snprintf(url_buf, sizeof(url_buf), "http://127.0.0.1:%u/g", (unsigned)bound_port) <= 0)
            _exit(50);
        gpool = http2_global_pool_create_c(1, 1);
        if (gpool == 0)
            _exit(51);
        n1 = http2_global_pool_get_c(gpool, (const uint8_t *)url_buf, (int32_t)strlen(url_buf), out,
                                     (int32_t)sizeof(out), 5000u);
        if (n1 <= 0) {
            http2_global_pool_destroy_c(gpool);
            _exit(52);
        }
        n2 = http2_global_pool_get_c(gpool, (const uint8_t *)url_buf, (int32_t)strlen(url_buf), out,
                                     (int32_t)sizeof(out), 5000u);
        cc = http2_global_pool_connect_count_c(gpool);
        http2_global_pool_destroy_c(gpool);
        if (n2 <= 0)
            _exit(53);
        if (cc != 2)
            _exit(54);
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

/**
 * HTTP/2 v1 收口烟测：RST_STREAM 离线 + 全局池 GOAWAY fork 集成；0 通过。
 * 作为 std.http HTTP/2 能力全集的门禁汇总入口（不再逐步扩展 #78+）。
 */
int32_t http2_http2_complete_smoke_c(void) {
    if (http2_rst_stream_smoke_c() != 0)
        return 1;
    if (http2_h2c_global_pool_goaway_smoke_c() != 0)
        return 2;
    return 0;
}
