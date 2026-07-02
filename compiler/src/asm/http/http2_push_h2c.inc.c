/**
 * std/http/push_h2c.inc.c — HTTP/2 server push 检测 + h2c 升级识别（STD-HTTP-H2-v6）
 *
 * 【文件职责】PUSH_PROMISE 帧类型/promised stream 解析；HTTP/1.1→h2c 101 响应识别。
 * 不含 push 资源拉取或 cleartext 会话；由 http2.inc.c 末尾 #include。
 */

/** PUSH_PROMISE 帧类型（RFC 7540 §6.6）。 */
#define HTTP2_TYPE_PUSH_PROMISE 0x05
/** server push 未实现。 */
#define HTTP2_ERR_PUSH_NOT_IMPL (-1233)
/** cleartext h2c 会话未实现（升级路径）。 */
#define HTTP2_ERR_H2C_NOT_IMPL (-1234)
/** h2c 客户端仅支持 http://（https:// 须用 h2_get）。 */
#define HTTP2_ERR_H2C_SCHEME (-1235)

#include "http2_push_fetch.inc.c"

/** 返回 PUSH_PROMISE 帧类型常量（5）。 */
int32_t http2_frame_push_promise_c(void) { return HTTP2_TYPE_PUSH_PROMISE; }

/** ftype 是否为 PUSH_PROMISE；1 是，0 否。 */
int32_t http2_is_push_promise_frame_c(int32_t ftype) {
    return (ftype == HTTP2_TYPE_PUSH_PROMISE) ? 1 : 0;
}

/**
 * 解析 PUSH_PROMISE payload 前 4 字节 promised stream id。
 * 成功 0；payload 不足 -1。
 */
int32_t http2_parse_push_promise_stream_c(const uint8_t *payload, int32_t plen,
                                          int32_t *out_promised_id) {
    uint32_t sid;
    if (!payload || plen < 4 || !out_promised_id)
        return -1;
    sid = ((uint32_t)(payload[0] & 0x7Fu) << 24) | ((uint32_t)payload[1] << 16) |
          ((uint32_t)payload[2] << 8) | (uint32_t)payload[3];
    *out_promised_id = (int32_t)sid;
    return 0;
}

/** 在 buf 中查找子串 needle（简单字节扫描）。 */
static int32_t http2_buf_find_substr_c(const uint8_t *buf, int32_t len, const char *needle) {
    int32_t i;
    int32_t n;
    int32_t j;
    if (!buf || len <= 0 || !needle)
        return -1;
    n = 0;
    while (needle[n] != '\0')
        n++;
    if (n <= 0 || n > len)
        return -1;
    for (i = 0; i <= len - n; i++) {
        for (j = 0; j < n; j++) {
            if (buf[i + j] != (uint8_t)needle[j])
                break;
        }
        if (j == n)
            return i;
    }
    return -1;
}

/**
 * 检测 HTTP/1.1 101 Switching Protocols 且含 Upgrade: h2c。
 * 1=匹配，0=不匹配。
 */
int32_t http2_is_h2c_upgrade_response_c(const uint8_t *buf, int32_t len) {
    if (!buf || len < 32)
        return 0;
    if (http2_buf_find_substr_c(buf, len, "HTTP/1.1 101") < 0 &&
        http2_buf_find_substr_c(buf, len, "HTTP/1.0 101") < 0)
        return 0;
    if (http2_buf_find_substr_c(buf, len, "Upgrade: h2c") < 0 &&
        http2_buf_find_substr_c(buf, len, "upgrade: h2c") < 0)
        return 0;
    return 1;
}

/** cleartext h2c wire 层可用；完整 TCP 会话见 http2_h2c_is_available_c（network 层）。 */
int32_t http2_h2c_wire_is_available_c(void) { return 1; }

/**
 * 构建 h2c 直连起始字节（连接 preface，24 字节）。
 * 成功返回 24；缓冲不足 -1。
 */
int32_t http2_h2c_session_begin_c(uint8_t *out, int32_t out_cap) {
    return http2_write_connection_preface_c(out, out_cap);
}

/** push + h2c wire 层 C 烟测；0 通过。 */
int32_t http2_push_h2c_smoke_c(void) {
    static const uint8_t upgrade[] =
        "HTTP/1.1 101 Switching Protocols\r\n"
        "Connection: Upgrade\r\n"
        "Upgrade: h2c\r\n"
        "\r\n";
    uint8_t pp[4];
    int32_t promised = 0;

    if (http2_is_h2c_upgrade_response_c(upgrade, (int32_t)(sizeof(upgrade) - 1)) != 1)
        return 1;
    if (http2_is_push_promise_frame_c(HTTP2_TYPE_PUSH_PROMISE) != 1)
        return 2;
    if (http2_h2c_wire_is_available_c() != 1)
        return 6;
    {
        uint8_t preface[32];
        if (http2_h2c_session_begin_c(preface, 32) != HTTP2_PREFACE_LEN)
            return 7;
        if (http2_is_connection_preface_c(preface, HTTP2_PREFACE_LEN) != 1)
            return 8;
    }
    pp[0] = 0;
    pp[1] = 0;
    pp[2] = 0;
    pp[3] = 4;
    if (http2_parse_push_promise_stream_c(pp, 4, &promised) != 0)
        return 4;
    if (promised != 4)
        return 5;
    if (http2_push_fetch_smoke_c() != 0)
        return 9;
    return 0;
}
