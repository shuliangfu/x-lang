/**
 * tls_stub.inc.c — STD-030：TLS 桩后端（无 mbedTLS/OpenSSL 链入）
 *
 * 由 net.c 在未定义 SHU_NET_USE_MBEDTLS / SHU_NET_USE_OPENSSL 时 #include。
 */

int32_t net_tls_is_available_c(void) {
    return 0;
}

const char *net_tls_backend_name_c(void) {
    return "stub";
}

int64_t net_tls_connect_client_c(int32_t fd, const char *sni) {
    (void)sni;
    shu_tls_last_error = 0;
    if (fd < 0) {
        shu_tls_last_error = -2;
        return 0;
    }
    shu_tls_last_error = -9;
    return 0;
}

int32_t net_tls_close_c(int64_t ctx_handle) {
    (void)ctx_handle;
    shu_tls_last_error = 0;
    return 0;
}

int32_t net_tls_read_c(int64_t ctx_handle, uint8_t *buf, int32_t cap) {
    (void)ctx_handle;
    (void)buf;
    (void)cap;
    shu_tls_last_error = -9;
    return -9;
}

int32_t net_tls_write_c(int64_t ctx_handle, const uint8_t *buf, int32_t len) {
    (void)ctx_handle;
    (void)buf;
    (void)len;
    shu_tls_last_error = -9;
    return -9;
}

int32_t net_tls_openssl_smoke_c(void) {
    return -9;
}

int32_t net_tls_mbedtls_smoke_c(void) {
    return -9;
}
