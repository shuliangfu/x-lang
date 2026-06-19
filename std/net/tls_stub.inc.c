/**
 * tls_stub.inc.c — STD-030：TLS 桩后端（无 mbedTLS/OpenSSL 链入）
 *
 * 由 net.c 在未定义 SHUX_NET_USE_MBEDTLS / SHUX_NET_USE_OPENSSL 时 #include。
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

/** 桩：ALPN 握手不可用。 */
int64_t net_tls_connect_client_alpn_c(int32_t fd, const char *sni, const uint8_t *alpn_wire,
                                      int32_t alpn_wire_len) {
    (void)alpn_wire;
    (void)alpn_wire_len;
    return net_tls_connect_client_c(fd, sni);
}

/** 桩：无协商 ALPN。 */
int32_t net_tls_alpn_selected_c(int64_t ctx_handle, uint8_t *out, int32_t out_cap) {
    (void)ctx_handle;
    (void)out;
    (void)out_cap;
    shu_tls_last_error = 0;
    return 0;
}

/** 桩：非 h2。 */
int32_t net_tls_alpn_is_h2_c(int64_t ctx_handle) {
    (void)ctx_handle;
    return 0;
}

/** 桩：TLS 服务端上下文不可用。 */
int64_t net_tls_server_ctx_create_mem_c(const uint8_t *cert_pem, int32_t cert_len,
                                        const uint8_t *key_pem, int32_t key_len) {
    (void)cert_pem;
    (void)cert_len;
    (void)key_pem;
    (void)key_len;
    shu_tls_last_error = -9;
    return 0;
}

/** 桩：无操作。 */
void net_tls_server_ctx_destroy_c(int64_t srv_ctx_h) {
    (void)srv_ctx_h;
}

/** 桩：TLS 服务端 accept 不可用。 */
int64_t net_tls_accept_server_c(int64_t srv_ctx_h, int32_t fd) {
    (void)srv_ctx_h;
    (void)fd;
    shu_tls_last_error = -9;
    return 0;
}
