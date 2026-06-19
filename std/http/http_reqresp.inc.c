/**
 * std/http/http_reqresp.inc.c — HTTP Request/Response 视图解析（STD-HTTP-REQRESP-v0/v1）
 *
 * 【文件职责】从完整 HTTP/1.x 响应缓冲解析 status/header/body 视图；body 指针/复制；由 http.c include。
 */

#include <stdint.h>
#include <string.h>

/**
 * 解析 HTTP/1.x 响应缓冲为视图字段。
 * out_chunked=1 时 out_body_len=0，须调用 http_decode_chunked_body_c。
 * 成功 0，失败 -1。
 */
int32_t http_response_parse_c(const uint8_t *buf, int32_t len, int32_t *out_status,
                              int32_t *out_hdr_end, int32_t *out_body_len,
                              int32_t *out_chunked) {
    if (!buf || len <= 0 || !out_status || !out_hdr_end || !out_body_len || !out_chunked)
        return -1;
    if (http_parse_status_line_c(buf, len, out_status) != 0)
        return -1;
    if (http_headers_body_offset_c(buf, len, out_hdr_end) != 0)
        return -1;
    if (http_has_chunked_encoding_c(buf, len) != 0) {
        *out_chunked = 1;
        *out_body_len = 0;
    } else {
        *out_chunked = 0;
        *out_body_len = len - *out_hdr_end;
        if (*out_body_len < 0)
            *out_body_len = 0;
    }
    return 0;
}

/** Request/Response 解析 C 烟测；0 通过。 */
int32_t http_response_parse_smoke_c(void) {
    static const uint8_t resp[] = "HTTP/1.1 200 OK\r\nContent-Length: 4\r\n\r\nbody";
    int32_t st = 0;
    int32_t he = 0;
    int32_t bl = 0;
    int32_t ch = 0;
    if (http_response_parse_c(resp, (int32_t)(sizeof(resp) - 1), &st, &he, &bl, &ch) != 0)
        return 1;
    if (st != 200 || he != 38 || bl != 4 || ch != 0)
        return 2;
    return 0;
}

/** 返回 raw 缓冲内 identity body 起始指针（buf + hdr_end）。 */
const uint8_t *http_response_body_ptr_c(const uint8_t *buf, int32_t hdr_end) {
    if (!buf || hdr_end < 0)
        return NULL;
    return buf + hdr_end;
}

/**
 * 复制 identity body 到 out（非 chunked）。
 * 成功返回 body_len，失败 -1。
 */
int32_t http_response_body_copy_c(const uint8_t *buf, int32_t hdr_end, int32_t body_len, uint8_t *out,
                                  int32_t out_cap) {
    if (!buf || !out || body_len < 0)
        return -1;
    if (body_len == 0)
        return 0;
    if (body_len > out_cap)
        return -1;
    memcpy(out, buf + hdr_end, (size_t)body_len);
    return body_len;
}

/** 堆 body 复制路径 C 烟测；0 通过。 */
int32_t http_response_body_owned_smoke_c(void) {
    static const uint8_t resp[] = "HTTP/1.1 200 OK\r\nContent-Length: 4\r\n\r\nbody";
    uint8_t out[8];
    if (http_response_body_copy_c(resp, 38, 4, out, 8) != 4)
        return 1;
    if (memcmp(out, "body", 4) != 0)
        return 2;
    return 0;
}

/** std.string.String 固定容量（256）；超过须 HttpUrlOwned。 */
#define HTTP_URL_STRING_CAP 256

/** url_len 是否超过 String 固定缓冲（>256）；1 是，0 否。 */
int32_t http_url_exceeds_string_cap_c(int32_t url_len) {
    return (url_len > HTTP_URL_STRING_CAP) ? 1 : 0;
}

/**
 * 复制 URL 字节到 out（非 null 终止）。
 * 成功返回 len；参数非法或 out_cap 不足 -1。
 */
int32_t http_url_copy_c(const uint8_t *src, int32_t len, uint8_t *out, int32_t out_cap) {
    if (!src || len < 0 || !out)
        return -1;
    if (len == 0)
        return 0;
    if (len > out_cap)
        return -1;
    memcpy(out, src, (size_t)len);
    return len;
}

/** 堆 URL 复制路径 C 烟测（300 字节 >256）；0 通过。 */
int32_t http_url_owned_smoke_c(void) {
    uint8_t src[300];
    uint8_t out[300];
    int32_t i;
    for (i = 0; i < 300; i++)
        src[i] = (uint8_t)('a' + (i % 26));
    if (http_url_exceeds_string_cap_c(300) != 1)
        return 1;
    if (http_url_exceeds_string_cap_c(256) != 0)
        return 2;
    if (http_url_copy_c(src, 300, out, 300) != 300)
        return 3;
    if (memcmp(src, out, 300) != 0)
        return 4;
    return 0;
}

/** HttpRequestOwned 组合路径 C 烟测（URL 300B）；0 通过。 */
int32_t http_request_owned_smoke_c(void) {
    return http_url_owned_smoke_c();
}
