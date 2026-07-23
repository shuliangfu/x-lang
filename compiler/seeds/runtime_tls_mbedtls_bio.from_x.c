/* seeds/runtime_tls_mbedtls_bio.from_x.c — G-02f-21 product TU
 * G-02f-105 helper gates.
 * Logic still C until full .x port.
 */
/**
 * tls_mbedtls_bio.c — F-04 v9：mbedTLS BIO 胶层
 *
 * mbedtls_ssl_set_bio 需 C 函数指针；.x 暂不支持 fn ptr 取址，故保留最小 send/recv/bind。
 * 主逻辑见 std/net/tls_mbedtls.x。
 */

#include "mbedtls/ssl.h"

#if !defined(_WIN32) && !defined(_WIN64)

#include <errno.h>
#include <sys/socket.h>

/* thin+rest：thin 函数在 rest 模式下由 .x 提供，前向声明供 shu_mbedtls_ssl_bind_fd_c 取地址 */
int shu_mbedtls_bio_send(void *ctx, const unsigned char *buf, size_t len);
int shu_mbedtls_bio_recv(void *ctx, unsigned char *buf, size_t len);

/** mbedTLS BIO send：非阻塞时映射 EAGAIN → WANT_WRITE。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-21 thin+rest：_impl 实现；thin（src/asm/runtime_tls_mbedtls_bio.x）提供 public wrapper */
int shu_mbedtls_bio_send_impl(void *ctx, const unsigned char *buf, size_t len) {
    int fd = *(int *)ctx;
    ssize_t r = send(fd, buf, len, 0);
    if (r < 0) {
        if (errno == EAGAIN || errno == EWOULDBLOCK)
            return MBEDTLS_ERR_SSL_WANT_WRITE;
        return MBEDTLS_ERR_SSL_INTERNAL_ERROR;
    }
    return (int)r;
}

#ifndef XLANG_RUNTIME_TLS_MBEDTLS_BIO_FROM_X
/* 完整模式（未定义 thin 宏）：public wrapper 由 seed 提供 */
int shu_mbedtls_bio_send(void *ctx, const unsigned char *buf, size_t len) {
    return shu_mbedtls_bio_send_impl(ctx, buf, len);
}
#endif

/** mbedTLS BIO recv：EOF / EAGAIN 映射 mbedTLS 错误码。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-21 thin+rest：_impl 实现；thin（src/asm/runtime_tls_mbedtls_bio.x）提供 public wrapper */
int shu_mbedtls_bio_recv_impl(void *ctx, unsigned char *buf, size_t len) {
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

#ifndef XLANG_RUNTIME_TLS_MBEDTLS_BIO_FROM_X
/* 完整模式（未定义 thin 宏）：public wrapper 由 seed 提供 */
int shu_mbedtls_bio_recv(void *ctx, unsigned char *buf, size_t len) {
    return shu_mbedtls_bio_recv_impl(ctx, buf, len);
}
#endif




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
