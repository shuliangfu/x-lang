/* seeds/runtime_http_glue_surface.from_x.c
 * G-02f-21 runtime_http_glue R2 mixed (thin+rest + DIRECT) surface — isomorphic with src/asm/http/runtime_http_glue.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o + ld -r with rest (seeds/runtime_http_glue.from_x.c)
 * Prove: full.x vs this surface → nm IDENTICAL (12 #[no_mangle] + 1 doc_anchor)
 * Mode: mixed - 11 thin+rest forwards (http_ and xlang_http_ prefix _c -> _impl extern C bridges) +
 *   1 DIRECT (http_method_has_body - pure method string check for POST/PUT/PATCH)
 * Cap residual: 11 _impl - http_set_timeouts/connect_timeout/send_all/parse_url/transport_close/
 *   send_all/recv_fill/format_request/drain_request/start_tls/request_timeout_ex_c (POSIX socket +
 *   Win32 winsock + TLS bridge in rest seed)
 * Note: doc_anchor runtime_http_glue_x_doc_anchor (no ast_; http_ and xlang_http_ prefix not trigger).
 *   .x lives in asm/http/ subdirectory - prove path is src/asm/http/runtime_http_glue.x.
 * Logic: 12 functions = 11 thin+rest forwards + http_method_has_body (DIRECT: checks POST/PUT/PATCH).
 * Regen: ./xlang-c -E ... runtime_http_glue.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

extern int32_t http_set_timeouts_impl(int32_t fd, uint32_t timeout_ms);
extern int32_t http_connect_timeout_impl(int32_t fd, uint8_t *res, uint32_t timeout_ms);
extern int32_t xlang_http_send_all_impl(int32_t fd, uint8_t *buf, int32_t len, int32_t is_socket);
extern int32_t parse_http_url_impl(uint8_t *url, int32_t url_len, uint8_t *host_buf, int32_t host_cap,
                                   uint8_t *port_buf, int32_t port_cap, uint8_t *path_buf, int32_t path_cap,
                                   int32_t *out_is_https);
extern void http_transport_close_impl(uint8_t *tr);
extern int32_t http_transport_send_all_impl(uint8_t *tr, uint8_t *data, int32_t len);
extern int32_t http_transport_recv_fill_impl(uint8_t *tr, uint8_t *out_buf, int32_t out_cap, uint32_t timeout_ms);
extern int32_t http_format_request_impl(uint8_t *method, uint8_t *path_buf, uint8_t *host_buf,
                                        int32_t body_len, uint8_t *req, int32_t req_cap);
extern int32_t http_drain_request_impl(int32_t fd);
extern int32_t http_transport_start_tls_impl(uint8_t *tr, int32_t is_https, uint8_t *host);
extern int32_t http_request_timeout_ex_c_impl(uint8_t *method, uint8_t *url, int32_t url_len,
                                              uint8_t *body, int32_t body_len, uint8_t *out,
                                              int32_t out_cap, uint32_t timeout_ms);

int32_t runtime_http_glue_x_doc_anchor(void) {
  return 0;
}

int32_t http_set_timeouts(int32_t fd, uint32_t timeout_ms) {
  return http_set_timeouts_impl(fd, timeout_ms);
}

int32_t http_connect_timeout(int32_t fd, uint8_t *res, uint32_t timeout_ms) {
  return http_connect_timeout_impl(fd, res, timeout_ms);
}

int32_t xlang_http_send_all(int32_t fd, uint8_t *buf, int32_t len, int32_t is_socket) {
  return xlang_http_send_all_impl(fd, buf, len, is_socket);
}

int32_t parse_http_url(uint8_t *url, int32_t url_len, uint8_t *host_buf, int32_t host_cap,
                       uint8_t *port_buf, int32_t port_cap, uint8_t *path_buf, int32_t path_cap,
                       int32_t *out_is_https) {
  return parse_http_url_impl(url, url_len, host_buf, host_cap, port_buf, port_cap, path_buf, path_cap,
                            out_is_https);
}

void http_transport_close(uint8_t *tr) {
  http_transport_close_impl(tr);
}

int32_t http_transport_send_all(uint8_t *tr, uint8_t *data, int32_t len) {
  return http_transport_send_all_impl(tr, data, len);
}

int32_t http_transport_recv_fill(uint8_t *tr, uint8_t *out_buf, int32_t out_cap, uint32_t timeout_ms) {
  return http_transport_recv_fill_impl(tr, out_buf, out_cap, timeout_ms);
}

int32_t http_format_request(uint8_t *method, uint8_t *path_buf, uint8_t *host_buf,
                            int32_t body_len, uint8_t *req, int32_t req_cap) {
  return http_format_request_impl(method, path_buf, host_buf, body_len, req, req_cap);
}

int32_t http_drain_request(int32_t fd) {
  return http_drain_request_impl(fd);
}

int32_t http_transport_start_tls(uint8_t *tr, int32_t is_https, uint8_t *host) {
  return http_transport_start_tls_impl(tr, is_https, host);
}

int32_t http_request_timeout_ex_c(uint8_t *method, uint8_t *url, int32_t url_len,
                                  uint8_t *body, int32_t body_len, uint8_t *out,
                                  int32_t out_cap, uint32_t timeout_ms) {
  return http_request_timeout_ex_c_impl(method, url, url_len, body, body_len, out, out_cap, timeout_ms);
}

int32_t http_method_has_body(uint8_t *method) {
  if (method == 0) { return 0; }
  /* POST */
  if (method[0] == 80 && method[1] == 79 && method[2] == 83 && method[3] == 84 && method[4] == 0) {
    return 1;
  }
  /* PUT */
  if (method[0] == 80 && method[1] == 85 && method[2] == 84 && method[3] == 0) {
    return 1;
  }
  /* PATCH */
  if (method[0] == 80 && method[1] == 65 && method[2] == 84 && method[3] == 67 && method[4] == 72 && method[5] == 0) {
    return 1;
  }
  return 0;
}
