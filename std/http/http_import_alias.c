/**
 * http_import_alias.c — import binding `-o` 链接桩
 *
 * asm co-emit 对 `const http = import("std.http")` 生成 std_http_* 符号；
 * http.o 仅含 http.sx 锚点，mod.sx 门面未 co-emit。本 TU 提供 std_http_* 转发至
 * runtime_http_glue.c 中的 http_*_c。
 */
#include <stdint.h>

extern int32_t http_get_c(const uint8_t *url, int32_t url_len, uint8_t *out_buf, int32_t out_cap);
extern int32_t http_post_c(const uint8_t *url, int32_t url_len, const uint8_t *body, int32_t body_len,
                           uint8_t *out_buf, int32_t out_cap);
extern int32_t http_head_c(const uint8_t *url, int32_t url_len, uint8_t *out_buf, int32_t out_cap);
extern int32_t http_get_timeout_c(const uint8_t *url, int32_t url_len, uint8_t *out_buf, int32_t out_cap,
                                  uint32_t timeout_ms);

/** HTTP GET；转发 http_get_c。 */
int32_t std_http_get(uint8_t *url, int32_t url_len, uint8_t *out_buf, int32_t out_cap) {
  return http_get_c(url, url_len, out_buf, out_cap);
}

/** HTTP POST；转发 http_post_c。 */
int32_t std_http_post(uint8_t *url, int32_t url_len, uint8_t *body, int32_t body_len, uint8_t *out_buf,
                      int32_t out_cap) {
  return http_post_c(url, url_len, body, body_len, out_buf, out_cap);
}

/** HTTP HEAD；转发 http_head_c。 */
int32_t std_http_head(uint8_t *url, int32_t url_len, uint8_t *out_buf, int32_t out_cap) {
  return http_head_c(url, url_len, out_buf, out_cap);
}

/** 带超时的 HTTP GET；转发 http_get_timeout_c。 */
int32_t std_http_get_timeout(uint8_t *url, int32_t url_len, uint8_t *out_buf, int32_t out_cap,
                             uint32_t timeout_ms) {
  return http_get_timeout_c(url, url_len, out_buf, out_cap, timeout_ms);
}
