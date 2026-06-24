/**
 * tls_mbedtls_bio.c — F-04 v9：mbedTLS BIO 胶层
 *
 * mbedtls_ssl_set_bio 需 C 函数指针；.sx 暂不支持 fn ptr 取址，故保留最小 send/recv/bind。
 * 主逻辑见 std/net/tls_mbedtls.sx。
 */

#include "mbedtls/ssl.h"

#if !defined(_WIN32) && !defined(_WIN64)

#include <errno.h>
#include <sys/socket.h>

/** mbedTLS BIO send：非阻塞时映射 EAGAIN → WANT_WRITE。 */
static int shu_mbedtls_bio_send(void *ctx, const unsigned char *buf, size_t len) {
    int fd = *(int *)ctx;
    ssize_t r = send(fd, buf, len, 0);
    if (r < 0) {
        if (errno == EAGAIN || errno == EWOULDBLOCK)
            return MBEDTLS_ERR_SSL_WANT_WRITE;
        return MBEDTLS_ERR_SSL_INTERNAL_ERROR;
    }
    return (int)r;
}

/** mbedTLS BIO recv：EOF / EAGAIN 映射 mbedTLS 错误码。 */
static int shu_mbedtls_bio_recv(void *ctx, unsigned char *buf, size_t len) {
    int fd = *(int *)ctx;
    ssize_t r = recv(fd, buf, len, 0);
    if (r < 0) {
        if (errno == EAGAIN || errno == EWOULDBLOCK)
            return MBEDTLS_ERR_SSL_WANT_READ;
        return MBEDTLS_ERR_SSL_INTERNAL_ERROR;
    }
    if (r == 0)
        return MBEDTLS_ERR_SSL_CONN_EOF;
    return (int)r;
}

#endif /* Unix BIO */

/**
 * 将 mbedTLS ssl 上下文绑定到已连接 TCP fd（阻塞握手用）。
 */
void shu_mbedtls_ssl_bind_fd_c(mbedtls_ssl_context *ssl, int *fd) {
#if !defined(_WIN32) && !defined(_WIN64)
    mbedtls_ssl_set_bio(ssl, fd, shu_mbedtls_bio_send, shu_mbedtls_bio_recv, NULL);
#else
    (void)ssl;
    (void)fd;
#endif
}
