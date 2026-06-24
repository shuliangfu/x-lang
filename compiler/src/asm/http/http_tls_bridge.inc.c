/**
 * http_tls_bridge.inc.c — std.http 可选 TLS 桥（weak 桩，链入 net.o 时被强符号覆盖）
 *
 * 【文件职责】http_glue.c #include；无 net.o 时 HTTPS URL 返回 HTTP_ERR_TLS_NOT_IMPL。
 */

#ifndef SHUX_HTTP_TLS_BRIDGE_INC
#define SHUX_HTTP_TLS_BRIDGE_INC

#include <stdint.h>
#include <string.h>

/** TLS 未链入时 is_available 返回 0。 */
__attribute__((weak)) int32_t net_tls_is_available_c(void) { return 0; }

/** TLS 未链入时 connect 失败（ctx=0）。 */
__attribute__((weak)) int64_t net_tls_connect_client_c(int32_t fd, const char *sni) {
  (void)fd;
  (void)sni;
  return 0;
}

/** TLS 未链入时 read 返回 -9。 */
__attribute__((weak)) int32_t net_tls_read_c(int64_t ctx_handle, uint8_t *buf, int32_t cap) {
  (void)ctx_handle;
  (void)buf;
  (void)cap;
  return -9;
}

/** TLS 未链入时 write 返回 -9。 */
__attribute__((weak)) int32_t net_tls_write_c(int64_t ctx_handle, const uint8_t *buf, int32_t len) {
  (void)ctx_handle;
  (void)buf;
  (void)len;
  return -9;
}

/** TLS 未链入时 close 无操作。 */
__attribute__((weak)) int32_t net_tls_close_c(int64_t ctx_handle) {
  (void)ctx_handle;
  return 0;
}

/** TLS 未链入时 ALPN 握手失败。 */
__attribute__((weak)) int64_t net_tls_connect_client_alpn_c(int32_t fd, const char *sni,
                                                            const uint8_t *alpn_wire,
                                                            int32_t alpn_wire_len) {
  (void)fd;
  (void)sni;
  (void)alpn_wire;
  (void)alpn_wire_len;
  return 0;
}

/** TLS 未链入时无 ALPN。 */
__attribute__((weak)) int32_t net_tls_alpn_selected_c(int64_t ctx_handle, uint8_t *out,
                                                      int32_t out_cap) {
  (void)ctx_handle;
  (void)out;
  (void)out_cap;
  return 0;
}

/** TLS 未链入时非 h2。 */
__attribute__((weak)) int32_t net_tls_alpn_is_h2_c(int64_t ctx_handle) {
  (void)ctx_handle;
  return 0;
}

/** ALPN 线格式（weak 桩：仍返回 h2+http/1.1 wire）。 */
__attribute__((weak)) int32_t net_tls_alpn_h2_http1_wire_c(uint8_t *out, int32_t out_cap) {
  static const uint8_t wire[] = {2, 'h', '2', 8, 'h', 't', 't', 'p', '/', '1', '.', '1'};
  if (!out || out_cap < 12) return -1;
  memcpy(out, wire, 12);
  return 12;
}

/** TLS 服务端上下文（weak 桩：不可用）。 */
__attribute__((weak)) int64_t net_tls_server_ctx_create_mem_c(const uint8_t *cert_pem, int32_t cert_len,
                                                                const uint8_t *key_pem, int32_t key_len) {
  (void)cert_pem;
  (void)cert_len;
  (void)key_pem;
  (void)key_len;
  return 0;
}

/** TLS 服务端上下文销毁（weak 桩）。 */
__attribute__((weak)) void net_tls_server_ctx_destroy_c(int64_t srv_ctx_h) {
  (void)srv_ctx_h;
}

/** TLS 服务端 accept（weak 桩：失败）。 */
__attribute__((weak)) int64_t net_tls_accept_server_c(int64_t srv_ctx_h, int32_t fd) {
  (void)srv_ctx_h;
  (void)fd;
  return 0;
}

#endif /* SHUX_HTTP_TLS_BRIDGE_INC */
