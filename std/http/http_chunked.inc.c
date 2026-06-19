/**
 * http_chunked.inc.c — STD-033：HTTP 分块传输与 Keep-Alive 解析（RFC 7230 子集）
 *
 * 由 http.c #include；纯缓冲解析，无 socket 依赖。
 */

#include <stdint.h>
#include <string.h>
#include <stdio.h>

/** 不区分大小写比较子串（ASCII）。 */
static int shu_http_ci_eq(const uint8_t *a, const uint8_t *b, int32_t n) {
    int32_t i;
    for (i = 0; i < n; i++) {
        uint8_t ca = a[i];
        uint8_t cb = b[i];
        if (ca >= 'A' && ca <= 'Z') ca = (uint8_t)(ca + 32);
        if (cb >= 'A' && cb <= 'Z') cb = (uint8_t)(cb + 32);
        if (ca != cb) return 0;
    }
    return 1;
}

/** 返回响应头结束后的 body 偏移（\\r\\n\\r\\n 之后）；失败 -1。 */
int32_t http_headers_body_offset_c(const uint8_t *buf, int32_t len, int32_t *out_off) {
    int32_t i;
    if (!buf || !out_off || len < 4) return -1;
    for (i = 3; i < len; i++) {
        if (buf[i - 3] == '\r' && buf[i - 2] == '\n' && buf[i - 1] == '\r' && buf[i] == '\n') {
            *out_off = i + 1;
            return 0;
        }
    }
    return -1;
}

/** 扫描响应头是否含 Transfer-Encoding: chunked（不区分大小写）。 */
int32_t http_has_chunked_encoding_c(const uint8_t *buf, int32_t len) {
    static const uint8_t te[] = "transfer-encoding:";
    int32_t hdr_end = -1;
    int32_t off = 0;
    if (!buf || len < 20) return 0;
    if (http_headers_body_offset_c(buf, len, &hdr_end) != 0) return 0;
    while (off + 18 <= hdr_end) {
        if (shu_http_ci_eq(buf + off, te, 18)) {
            int32_t j = off + 18;
            while (j < hdr_end && (buf[j] == ' ' || buf[j] == '\t')) j++;
            if (j + 7 <= hdr_end && shu_http_ci_eq(buf + j, (const uint8_t *)"chunked", 7))
                return 1;
        }
        off++;
    }
    return 0;
}

/** 扫描响应头是否含 Connection: keep-alive。 */
int32_t http_has_keep_alive_c(const uint8_t *buf, int32_t len) {
    static const uint8_t conn[] = "connection:";
    int32_t off = 0, hdr_end = -1;
    if (!buf || len < 20) return 0;
    if (http_headers_body_offset_c(buf, len, &hdr_end) != 0) return 0;
    while (off + 11 <= hdr_end) {
        if (shu_http_ci_eq(buf + off, conn, 11)) {
            int32_t j = off + 11;
            while (j < hdr_end && (buf[j] == ' ' || buf[j] == '\t')) j++;
            if (j + 10 <= hdr_end && shu_http_ci_eq(buf + j, (const uint8_t *)"keep-alive", 10))
                return 1;
        }
        off++;
    }
    return 0;
}

/** 解析十六进制 chunk 大小行（至 \\r\\n）；写 *out_size，返回行后偏移，失败 -1。 */
static int32_t shu_http_parse_chunk_size(const uint8_t *buf, int32_t len, int32_t off,
    int32_t *out_size) {
    int32_t size = 0;
    int32_t i = off;
    if (!buf || !out_size || off < 0 || off >= len) return -1;
    while (i < len) {
        uint8_t c = buf[i];
        if (c == '\r' && i + 1 < len && buf[i + 1] == '\n') {
            *out_size = size;
            return i + 2;
        }
        if (c >= '0' && c <= '9')
            size = (size << 4) + (c - '0');
        else if (c >= 'a' && c <= 'f')
            size = (size << 4) + (c - 'a' + 10);
        else if (c >= 'A' && c <= 'F')
            size = (size << 4) + (c - 'A' + 10);
        else
            return -1;
        if (size > 65536) return -1;
        i++;
    }
    return -1;
}

/**
 * 从完整响应缓冲解码 chunked body（hdr_end 为 body 起始偏移）。
 * 将拼接后的实体写入 out_body；返回字节数，失败 -1。
 */
int32_t http_decode_chunked_body_c(const uint8_t *buf, int32_t len, int32_t hdr_end,
    uint8_t *out_body, int32_t out_cap) {
    int32_t off = hdr_end;
    int32_t out_len = 0;
    int32_t chunk_size;
    if (!buf || !out_body || hdr_end < 0 || hdr_end >= len || out_cap < 1) return -1;
    for (;;) {
        off = shu_http_parse_chunk_size(buf, len, off, &chunk_size);
        if (off < 0) return -1;
        if (chunk_size == 0) return out_len;
        if (off + chunk_size + 2 > len) return -1;
        if (out_len + chunk_size > out_cap) return -1;
        memcpy(out_body + out_len, buf + off, (size_t)chunk_size);
        out_len += chunk_size;
        off += chunk_size;
        if (buf[off] != '\r' || buf[off + 1] != '\n') return -1;
        off += 2;
    }
}

/** 构建 HTTP/1.1 GET + Connection: keep-alive 请求到 out；返回字节数，失败 -1。 */
int32_t http_build_get_keep_alive_c(const uint8_t *host, const uint8_t *path,
    uint8_t *out, int32_t out_cap) {
    int n;
    if (!host || !path || !out || out_cap < 48) return -1;
    n = snprintf((char *)out, (size_t)out_cap,
        "GET %s HTTP/1.1\r\n"
        "Host: %s\r\n"
        "Connection: keep-alive\r\n"
        "\r\n",
        (const char *)path, (const char *)host);
    if (n <= 0 || n >= out_cap) return -1;
    return (int32_t)n;
}

/** 扫描请求/响应头是否含 Upgrade: websocket（不区分大小写）。 */
int32_t http_is_upgrade_websocket_c(const uint8_t *buf, int32_t len) {
    static const uint8_t upg[] = "upgrade:";
    int32_t hdr_end = -1;
    int32_t off = 0;
    if (!buf || len < 24) return 0;
    if (http_headers_body_offset_c(buf, len, &hdr_end) != 0) return 0;
    while (off + 8 <= hdr_end) {
        if (shu_http_ci_eq(buf + off, upg, 8)) {
            int32_t j = off + 8;
            while (j < hdr_end && (buf[j] == ' ' || buf[j] == '\t')) j++;
            if (j + 9 <= hdr_end && shu_http_ci_eq(buf + j, (const uint8_t *)"websocket", 9))
                return 1;
        }
        off++;
    }
    return 0;
}

/**
 * 构建 HTTP/1.1 101 Switching Protocols（WebSocket 握手响应头）。
 * @param accept Sec-WebSocket-Accept 值（NUL 结尾）
 */
int32_t http_build_ws_upgrade_101_c(const uint8_t *accept, uint8_t *out, int32_t out_cap) {
    int n;
    if (!accept || !out || out_cap < 64) return -1;
    n = snprintf((char *)out, (size_t)out_cap,
        "HTTP/1.1 101 Switching Protocols\r\n"
        "Upgrade: websocket\r\n"
        "Connection: Upgrade\r\n"
        "Sec-WebSocket-Accept: %s\r\n"
        "\r\n",
        (const char *)accept);
    if (n <= 0 || n >= out_cap) return -1;
    return (int32_t)n;
}
