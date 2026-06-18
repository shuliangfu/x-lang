/**
 * tls_openssl.inc.c — STD-030/083：OpenSSL TLS 客户端实现
 *
 * 由 net.c 在 -DSHU_NET_USE_OPENSSL 下 #include。
 * v1：客户端握手、tls_read/tls_write；证书校验默认关闭（自签/测试用）。
 */

#if defined(SHU_NET_USE_OPENSSL)

#include <openssl/ssl.h>
#include <openssl/err.h>
#include <stdlib.h>
#include <string.h>

#if !defined(_WIN32) && !defined(_WIN64)
#include <unistd.h>
#include <fcntl.h>
#include <poll.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#endif

/** OpenSSL 会话：ctx + ssl + 底层 fd。 */
typedef struct {
    int fd;
    SSL *ssl;
    SSL_CTX *ctx;
} shu_tls_session_t;

/** 将 C 层 handle 转为会话指针。 */
static shu_tls_session_t *shu_tls_sess_ptr(int64_t handle) {
    if (handle == 0) return NULL;
    return (shu_tls_session_t *)(uintptr_t)handle;
}

#if !defined(_WIN32) && !defined(_WIN64)
/** 切换 socket 阻塞模式（握手阶段用阻塞简化 v1）。 */
static int shu_tls_set_blocking(int fd, int blocking) {
    int flags = fcntl(fd, F_GETFL, 0);
    if (flags < 0) return -1;
    if (blocking)
        flags &= ~O_NONBLOCK;
    else
        flags |= O_NONBLOCK;
    return fcntl(fd, F_SETFL, flags) == 0 ? 0 : -1;
}
#endif

/** OpenSSL 链入标记（供 Makefile / 诊断）。 */
const char shu_net_tls_openssl_marker[] = "openssl";

int32_t net_tls_is_available_c(void) {
    return 1;
}

const char *net_tls_backend_name_c(void) {
    return "openssl";
}

int64_t net_tls_connect_client_c(int32_t fd, const char *sni) {
    shu_tls_session_t *sess = NULL;
    SSL_CTX *ctx = NULL;
    SSL *ssl = NULL;
    int rc;

    shu_tls_last_error = 0;
    if (fd < 0) {
        shu_tls_last_error = -2;
        return 0;
    }
    if (!sni || !sni[0]) {
        shu_tls_last_error = -1;
        return 0;
    }

    if (!OPENSSL_init_ssl(OPENSSL_INIT_LOAD_SSL_STRINGS | OPENSSL_INIT_LOAD_CRYPTO_STRINGS, NULL)) {
        shu_tls_last_error = -1;
        return 0;
    }

    sess = (shu_tls_session_t *)calloc(1, sizeof(*sess));
    if (!sess) {
        shu_tls_last_error = -1;
        return 0;
    }

    ctx = SSL_CTX_new(TLS_client_method());
    if (!ctx) {
        free(sess);
        shu_tls_last_error = -1;
        return 0;
    }
    SSL_CTX_set_verify(ctx, SSL_VERIFY_NONE, NULL);

    ssl = SSL_new(ctx);
    if (!ssl) {
        SSL_CTX_free(ctx);
        free(sess);
        shu_tls_last_error = -1;
        return 0;
    }

    SSL_set_fd(ssl, fd);
    if (SSL_set_tlsext_host_name(ssl, sni) != 1) {
        SSL_free(ssl);
        SSL_CTX_free(ctx);
        free(sess);
        shu_tls_last_error = -1;
        return 0;
    }

#if !defined(_WIN32) && !defined(_WIN64)
    shu_tls_set_blocking(fd, 1);
#endif

    rc = SSL_connect(ssl);
    if (rc != 1) {
        shu_tls_last_error = -1;
        SSL_free(ssl);
        SSL_CTX_free(ctx);
        free(sess);
        return 0;
    }

    sess->fd = fd;
    sess->ssl = ssl;
    sess->ctx = ctx;
    shu_tls_last_error = 0;
    return (int64_t)(uintptr_t)sess;
}

int32_t net_tls_close_c(int64_t ctx_handle) {
    shu_tls_session_t *sess = shu_tls_sess_ptr(ctx_handle);
    if (!sess) return 0;
    SSL_shutdown(sess->ssl);
    SSL_free(sess->ssl);
    SSL_CTX_free(sess->ctx);
    free(sess);
    shu_tls_last_error = 0;
    return 0;
}

int32_t net_tls_read_c(int64_t ctx_handle, uint8_t *buf, int32_t cap) {
    shu_tls_session_t *sess = shu_tls_sess_ptr(ctx_handle);
    int n;
    if (!sess || !sess->ssl) {
        shu_tls_last_error = -2;
        return -2;
    }
    if (!buf || cap <= 0) {
        shu_tls_last_error = -2;
        return -2;
    }
    n = SSL_read(sess->ssl, buf, cap);
    if (n <= 0) {
        shu_tls_last_error = -1;
        return -1;
    }
    shu_tls_last_error = 0;
    return (int32_t)n;
}

int32_t net_tls_write_c(int64_t ctx_handle, const uint8_t *buf, int32_t len) {
    shu_tls_session_t *sess = shu_tls_sess_ptr(ctx_handle);
    int n;
    if (!sess || !sess->ssl) {
        shu_tls_last_error = -2;
        return -2;
    }
    if (!buf || len <= 0) {
        shu_tls_last_error = -2;
        return -2;
    }
    n = SSL_write(sess->ssl, buf, len);
    if (n <= 0) {
        shu_tls_last_error = -1;
        return -1;
    }
    shu_tls_last_error = 0;
    return (int32_t)n;
}

#if !defined(_WIN32) && !defined(_WIN64)
/** 连接 127.0.0.1:port；失败返回 -1。 */
static int shu_tls_smoke_tcp_connect(int port) {
    int fd;
    struct sockaddr_in sa;
    memset(&sa, 0, sizeof(sa));
    sa.sin_family = AF_INET;
    sa.sin_port = htons((uint16_t)port);
    if (inet_pton(AF_INET, "127.0.0.1", &sa.sin_addr) != 1) return -1;
    fd = (int)socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0) return -1;
    if (connect(fd, (struct sockaddr *)&sa, sizeof(sa)) != 0) {
        close(fd);
        return -1;
    }
    return fd;
}

/**
 * OpenSSL 烟测：连接 SHU_TLS_SMOKE_PORT 上的 s_server，握手并读取响应前缀。
 * 返回 0 成功；>0 为失败码。
 */
int32_t net_tls_openssl_smoke_c(void) {
    const char *port_env = getenv("SHU_TLS_SMOKE_PORT");
    int port = port_env ? atoi(port_env) : 0;
    int fd;
    int64_t ctx;
    int32_t n;
    uint8_t buf[64];
    const char *req = "GET /\r\n\r\n";

    if (net_tls_backend_name_c()[0] != 'o') return 1;
    if (port <= 0 || port > 65535) return 2;

    fd = shu_tls_smoke_tcp_connect(port);
    if (fd < 0) return 3;

    ctx = net_tls_connect_client_c(fd, "localhost");
    if (!ctx) {
        close(fd);
        return 4;
    }

    if (net_tls_write_c(ctx, (const uint8_t *)req, (int32_t)strlen(req)) <= 0) {
        net_tls_close_c(ctx);
        close(fd);
        return 5;
    }

    n = net_tls_read_c(ctx, buf, (int32_t)sizeof(buf) - 1);
    if (n <= 0) {
        net_tls_close_c(ctx);
        close(fd);
        return 6;
    }
    buf[n] = '\0';
    if (strstr((char *)buf, "HTTP") == NULL && strstr((char *)buf, "html") == NULL &&
        strstr((char *)buf, "HTML") == NULL) {
        net_tls_close_c(ctx);
        close(fd);
        return 7;
    }

    if (net_tls_close_c(ctx) != 0) {
        close(fd);
        return 8;
    }
    close(fd);
    return 0;
}

/** mbedTLS 烟测桩：OpenSSL 构建下不可用。 */
int32_t net_tls_mbedtls_smoke_c(void) {
    return -9;
}
#endif /* !Windows smoke */

#endif /* SHU_NET_USE_OPENSSL */
