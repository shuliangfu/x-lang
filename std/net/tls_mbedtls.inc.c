/**
 * tls_mbedtls.inc.c — STD-085：mbedTLS TLS 客户端实现
 *
 * 由 net.c 在 -DSHU_NET_USE_MBEDTLS 下 #include。
 * v1：mbedTLS 4.x PSA 路径；证书校验默认关闭（测试/自签）。
 */

#if defined(SHU_NET_USE_MBEDTLS)

#include "mbedtls/ssl.h"
#include "mbedtls/error.h"
#include "psa/crypto.h"
#include <stdlib.h>
#include <string.h>

#if !defined(_WIN32) && !defined(_WIN64)
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#endif

/** mbedTLS 会话：config + ssl + 底层 fd。 */
typedef struct {
    int fd;
    mbedtls_ssl_context ssl;
    mbedtls_ssl_config conf;
} shu_tls_mbedtls_sess_t;

/** 将 handle 转为会话指针。 */
static shu_tls_mbedtls_sess_t *shu_tls_mbedtls_sess_ptr(int64_t handle) {
    if (handle == 0) return NULL;
    return (shu_tls_mbedtls_sess_t *)(uintptr_t)handle;
}

#if !defined(_WIN32) && !defined(_WIN64)
/** 切换 socket 阻塞模式（握手阶段用阻塞简化 v1）。 */
static int shu_tls_mbedtls_set_blocking(int fd, int blocking) {
    int flags = fcntl(fd, F_GETFL, 0);
    if (flags < 0) return -1;
    if (blocking)
        flags &= ~O_NONBLOCK;
    else
        flags |= O_NONBLOCK;
    return fcntl(fd, F_SETFL, flags) == 0 ? 0 : -1;
}

/** mbedTLS BIO send 回调。 */
static int shu_mbedtls_net_send(void *ctx, const unsigned char *buf, size_t len) {
    int fd = *(int *)ctx;
    ssize_t r = send(fd, buf, len, 0);
    if (r < 0) {
        if (errno == EAGAIN || errno == EWOULDBLOCK) return MBEDTLS_ERR_SSL_WANT_WRITE;
        return MBEDTLS_ERR_SSL_INTERNAL_ERROR;
    }
    return (int)r;
}

/** mbedTLS BIO recv 回调。 */
static int shu_mbedtls_net_recv(void *ctx, unsigned char *buf, size_t len) {
    int fd = *(int *)ctx;
    ssize_t r = recv(fd, buf, len, 0);
    if (r < 0) {
        if (errno == EAGAIN || errno == EWOULDBLOCK) return MBEDTLS_ERR_SSL_WANT_READ;
        return MBEDTLS_ERR_SSL_INTERNAL_ERROR;
    }
    if (r == 0) return MBEDTLS_ERR_SSL_CONN_EOF;
    return (int)r;
}
#endif

/** mbedTLS 链入标记（供 Makefile / 诊断）。 */
const char shu_net_tls_mbedtls_marker[] = "mbedtls";

int32_t net_tls_is_available_c(void) {
    return 1;
}

const char *net_tls_backend_name_c(void) {
    return "mbedtls";
}

int64_t net_tls_connect_client_c(int32_t fd, const char *sni) {
    shu_tls_mbedtls_sess_t *sess = NULL;
    psa_status_t psa_st;
    int ret;

    shu_tls_last_error = 0;
    if (fd < 0) {
        shu_tls_last_error = -2;
        return 0;
    }
    if (!sni || !sni[0]) {
        shu_tls_last_error = -1;
        return 0;
    }

    psa_st = psa_crypto_init();
    if (psa_st != PSA_SUCCESS && psa_st != PSA_ERROR_BAD_STATE) {
        shu_tls_last_error = -1;
        return 0;
    }

    sess = (shu_tls_mbedtls_sess_t *)calloc(1, sizeof(*sess));
    if (!sess) {
        shu_tls_last_error = -1;
        return 0;
    }
    sess->fd = fd;

    mbedtls_ssl_config_init(&sess->conf);
    ret = mbedtls_ssl_config_defaults(&sess->conf, MBEDTLS_SSL_IS_CLIENT,
                                      MBEDTLS_SSL_TRANSPORT_STREAM,
                                      MBEDTLS_SSL_PRESET_DEFAULT);
    if (ret != 0) {
        mbedtls_ssl_config_free(&sess->conf);
        free(sess);
        shu_tls_last_error = -1;
        return 0;
    }
    mbedtls_ssl_conf_authmode(&sess->conf, MBEDTLS_SSL_VERIFY_NONE);

    mbedtls_ssl_init(&sess->ssl);
    ret = mbedtls_ssl_setup(&sess->ssl, &sess->conf);
    if (ret != 0) {
        mbedtls_ssl_free(&sess->ssl);
        mbedtls_ssl_config_free(&sess->conf);
        free(sess);
        shu_tls_last_error = -1;
        return 0;
    }

    if (mbedtls_ssl_set_hostname(&sess->ssl, sni) != 0) {
        mbedtls_ssl_free(&sess->ssl);
        mbedtls_ssl_config_free(&sess->conf);
        free(sess);
        shu_tls_last_error = -1;
        return 0;
    }

    mbedtls_ssl_set_bio(&sess->ssl, &sess->fd, shu_mbedtls_net_send, shu_mbedtls_net_recv, NULL);

#if !defined(_WIN32) && !defined(_WIN64)
    shu_tls_mbedtls_set_blocking(fd, 1);
#endif

    while ((ret = mbedtls_ssl_handshake(&sess->ssl)) != 0) {
        if (ret != MBEDTLS_ERR_SSL_WANT_READ && ret != MBEDTLS_ERR_SSL_WANT_WRITE) {
            mbedtls_ssl_free(&sess->ssl);
            mbedtls_ssl_config_free(&sess->conf);
            free(sess);
            shu_tls_last_error = -1;
            return 0;
        }
    }

    shu_tls_last_error = 0;
    return (int64_t)(uintptr_t)sess;
}

int32_t net_tls_close_c(int64_t ctx_handle) {
    shu_tls_mbedtls_sess_t *sess = shu_tls_mbedtls_sess_ptr(ctx_handle);
    if (!sess) return 0;
    mbedtls_ssl_close_notify(&sess->ssl);
    mbedtls_ssl_free(&sess->ssl);
    mbedtls_ssl_config_free(&sess->conf);
    free(sess);
    shu_tls_last_error = 0;
    return 0;
}

int32_t net_tls_read_c(int64_t ctx_handle, uint8_t *buf, int32_t cap) {
    shu_tls_mbedtls_sess_t *sess = shu_tls_mbedtls_sess_ptr(ctx_handle);
    int n;
    if (!sess) {
        shu_tls_last_error = -2;
        return -2;
    }
    if (!buf || cap <= 0) {
        shu_tls_last_error = -2;
        return -2;
    }
    do {
        n = mbedtls_ssl_read(&sess->ssl, buf, (size_t)cap);
    } while (n == MBEDTLS_ERR_SSL_WANT_READ || n == MBEDTLS_ERR_SSL_WANT_WRITE);
    if (n <= 0) {
        shu_tls_last_error = -1;
        return -1;
    }
    shu_tls_last_error = 0;
    return (int32_t)n;
}

int32_t net_tls_write_c(int64_t ctx_handle, const uint8_t *buf, int32_t len) {
    shu_tls_mbedtls_sess_t *sess = shu_tls_mbedtls_sess_ptr(ctx_handle);
    int n;
    if (!sess) {
        shu_tls_last_error = -2;
        return -2;
    }
    if (!buf || len <= 0) {
        shu_tls_last_error = -2;
        return -2;
    }
    do {
        n = mbedtls_ssl_write(&sess->ssl, buf, (size_t)len);
    } while (n == MBEDTLS_ERR_SSL_WANT_READ || n == MBEDTLS_ERR_SSL_WANT_WRITE);
    if (n <= 0) {
        shu_tls_last_error = -1;
        return -1;
    }
    shu_tls_last_error = 0;
    return (int32_t)n;
}

#if !defined(_WIN32) && !defined(_WIN64)
/** 连接 127.0.0.1:port；失败返回 -1。 */
static int shu_tls_mbedtls_smoke_tcp_connect(int port) {
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
 * mbedTLS 烟测：连接 SHU_TLS_SMOKE_PORT 上的 s_server 并完成握手。
 */
int32_t net_tls_mbedtls_smoke_c(void) {
    const char *port_env = getenv("SHU_TLS_SMOKE_PORT");
    int port = port_env ? atoi(port_env) : 0;
    int fd;
    int64_t ctx;

    if (net_tls_backend_name_c()[0] != 'm') return 1;
    if (port <= 0 || port > 65535) return 2;

    fd = shu_tls_mbedtls_smoke_tcp_connect(port);
    if (fd < 0) return 3;

    ctx = net_tls_connect_client_c(fd, "localhost");
    if (!ctx) {
        close(fd);
        return 4;
    }

    if (net_tls_close_c(ctx) != 0) {
        close(fd);
        return 5;
    }
    close(fd);
    return 0;
}

/** OpenSSL 烟测桩：mbedTLS 构建下不可用。 */
int32_t net_tls_openssl_smoke_c(void) {
    return -9;
}
#endif /* !Windows smoke */

#endif /* SHU_NET_USE_MBEDTLS */
