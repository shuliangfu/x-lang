/**
 * tls_openssl.inc.c — STD-030/083：OpenSSL TLS 客户端实现
 *
 * 由 net.c 在 -DSHUX_NET_USE_OPENSSL 下 #include。
 * v1：客户端握手、tls_read/tls_write；证书校验默认关闭（自签/测试用）。
 */

#if defined(SHUX_NET_USE_OPENSSL)

#include <openssl/ssl.h>
#include <openssl/err.h>
#include <openssl/x509.h>
#include <openssl/pem.h>
#include <openssl/evp.h>
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

/** OpenSSL 服务端 TLS 上下文（共享 SSL_CTX + 证书）。 */
typedef struct {
    SSL_CTX *ctx;
} shu_tls_server_ctx_t;

/** OpenSSL ALPN 服务端选择 h2（RFC 7301）。 */
static int shu_openssl_alpn_select_cb(SSL *ssl, const unsigned char **out, unsigned char *outlen,
                                      const unsigned char *in, unsigned int inlen, void *arg) {
    static const unsigned char proto_h2[] = {2, 'h', '2'};
    (void)ssl;
    (void)arg;
    if (SSL_select_next_proto((unsigned char **)out, outlen, in, inlen, proto_h2, 3) ==
        OPENSSL_NPN_NEGOTIATED)
        return SSL_TLSEXT_ERR_OK;
    return SSL_TLSEXT_ERR_NOACK;
}

/**
 * 从内存 PEM 创建 TLS 服务端上下文（ALPN 优先 h2）。
 * 失败返回 0。
 */
int64_t net_tls_server_ctx_create_mem_c(const uint8_t *cert_pem, int32_t cert_len,
                                        const uint8_t *key_pem, int32_t key_len) {
    shu_tls_server_ctx_t *srv;
    BIO *cert_bio = NULL;
    BIO *key_bio = NULL;
    X509 *cert = NULL;
    EVP_PKEY *pkey = NULL;

    shu_tls_last_error = 0;
    if (!cert_pem || cert_len <= 0 || !key_pem || key_len <= 0) {
        shu_tls_last_error = -2;
        return 0;
    }
    if (!OPENSSL_init_ssl(OPENSSL_INIT_LOAD_SSL_STRINGS | OPENSSL_INIT_LOAD_CRYPTO_STRINGS, NULL)) {
        shu_tls_last_error = -1;
        return 0;
    }
    srv = (shu_tls_server_ctx_t *)calloc(1, sizeof(*srv));
    if (!srv) {
        shu_tls_last_error = -1;
        return 0;
    }
    srv->ctx = SSL_CTX_new(TLS_server_method());
    if (!srv->ctx) {
        free(srv);
        shu_tls_last_error = -1;
        return 0;
    }
    SSL_CTX_set_verify(srv->ctx, SSL_VERIFY_NONE, NULL);
    SSL_CTX_set_alpn_select_cb(srv->ctx, shu_openssl_alpn_select_cb, NULL);

    cert_bio = BIO_new_mem_buf(cert_pem, cert_len);
    key_bio = BIO_new_mem_buf(key_pem, key_len);
    if (!cert_bio || !key_bio) {
        if (cert_bio) BIO_free(cert_bio);
        if (key_bio) BIO_free(key_bio);
        SSL_CTX_free(srv->ctx);
        free(srv);
        shu_tls_last_error = -1;
        return 0;
    }
    cert = PEM_read_bio_X509(cert_bio, NULL, NULL, NULL);
    pkey = PEM_read_bio_PrivateKey(key_bio, NULL, NULL, NULL);
    BIO_free(cert_bio);
    BIO_free(key_bio);
    if (!cert || !pkey || SSL_CTX_use_certificate(srv->ctx, cert) != 1 ||
        SSL_CTX_use_PrivateKey(srv->ctx, pkey) != 1) {
        if (cert) X509_free(cert);
        if (pkey) EVP_PKEY_free(pkey);
        SSL_CTX_free(srv->ctx);
        free(srv);
        shu_tls_last_error = -1;
        return 0;
    }
    X509_free(cert);
    EVP_PKEY_free(pkey);
    return (int64_t)(uintptr_t)srv;
}

/** 释放 TLS 服务端上下文。 */
void net_tls_server_ctx_destroy_c(int64_t srv_ctx_h) {
    shu_tls_server_ctx_t *srv = (shu_tls_server_ctx_t *)(uintptr_t)srv_ctx_h;
    if (!srv)
        return;
    if (srv->ctx)
        SSL_CTX_free(srv->ctx);
    free(srv);
}

/** 在已 accept 的 TCP fd 上完成 TLS 服务端握手；失败返回 0。 */
int64_t net_tls_accept_server_c(int64_t srv_ctx_h, int32_t fd) {
    shu_tls_server_ctx_t *srv = (shu_tls_server_ctx_t *)(uintptr_t)srv_ctx_h;
    shu_tls_session_t *sess = NULL;
    SSL *ssl = NULL;
    int rc;

    shu_tls_last_error = 0;
    if (!srv || !srv->ctx || fd < 0) {
        shu_tls_last_error = -2;
        return 0;
    }
    sess = (shu_tls_session_t *)calloc(1, sizeof(*sess));
    if (!sess) {
        shu_tls_last_error = -1;
        return 0;
    }
    ssl = SSL_new(srv->ctx);
    if (!ssl) {
        free(sess);
        shu_tls_last_error = -1;
        return 0;
    }
    SSL_set_fd(ssl, fd);
#if !defined(_WIN32) && !defined(_WIN64)
    shu_tls_set_blocking(fd, 1);
#endif
    rc = SSL_accept(ssl);
    if (rc != 1) {
        SSL_free(ssl);
        free(sess);
        shu_tls_last_error = -1;
        return 0;
    }
    sess->fd = fd;
    sess->ssl = ssl;
    sess->ctx = NULL;
    return (int64_t)(uintptr_t)sess;
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

/**
 * 带 ALPN 的 TLS 客户端握手；alpn_wire 为 RFC 7301 长度前缀协议列表。
 * 失败返回 0。
 */
int64_t net_tls_connect_client_alpn_c(int32_t fd, const char *sni, const uint8_t *alpn_wire,
                                      int32_t alpn_wire_len) {
    shu_tls_session_t *sess = NULL;
    SSL_CTX *ctx = NULL;
    SSL *ssl = NULL;
    int rc;

    shu_tls_last_error = 0;
    if (fd < 0 || !alpn_wire || alpn_wire_len <= 0) {
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
    if (SSL_CTX_set_alpn_protos(ctx, alpn_wire, (unsigned int)alpn_wire_len) != 0) {
        SSL_CTX_free(ctx);
        free(sess);
        shu_tls_last_error = -1;
        return 0;
    }

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

/** 读取协商后的 ALPN 协议名；返回协议长度，写入 out（可 NULL）。 */
int32_t net_tls_alpn_selected_c(int64_t ctx_handle, uint8_t *out, int32_t out_cap) {
    shu_tls_session_t *sess = shu_tls_sess_ptr(ctx_handle);
    const unsigned char *sel = NULL;
    unsigned int len = 0;
    if (!sess || !sess->ssl) {
        shu_tls_last_error = -2;
        return -1;
    }
    SSL_get0_alpn_selected(sess->ssl, &sel, &len);
    if (len == 0)
        return 0;
    if (out && out_cap > 0) {
        int32_t n = (int32_t)len;
        if (n > out_cap)
            n = out_cap;
        memcpy(out, sel, (size_t)n);
    }
    return (int32_t)len;
}

/** 协商协议是否为 h2；1 是，0 否。 */
int32_t net_tls_alpn_is_h2_c(int64_t ctx_handle) {
    uint8_t buf[4];
    int32_t n = net_tls_alpn_selected_c(ctx_handle, buf, 4);
    if (n == 2 && buf[0] == (uint8_t)'h' && buf[1] == (uint8_t)'2')
        return 1;
    return 0;
}

int32_t net_tls_close_c(int64_t ctx_handle) {
    shu_tls_session_t *sess = shu_tls_sess_ptr(ctx_handle);
    if (!sess) return 0;
    SSL_shutdown(sess->ssl);
    SSL_free(sess->ssl);
    if (sess->ctx)
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
 * OpenSSL 烟测：连接 SHUX_TLS_SMOKE_PORT 上的 s_server，握手并读取响应前缀。
 * 返回 0 成功；>0 为失败码。
 */
int32_t net_tls_openssl_smoke_c(void) {
    const char *port_env = getenv("SHUX_TLS_SMOKE_PORT");
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

#endif /* SHUX_NET_USE_OPENSSL */
