/**
 * std/http/http2.inc.c — HTTP/2 v0 线格式层（RFC 7540 子集；STD-HTTP-H2）
 *
 * 【文件职责】连接 preface 检测、9 字节帧头编解码、SETTINGS ACK/单条 SETTINGS 构建、ALPN "h2" 写入。
 * 不含 HPACK/多路复用客户端；完整 HTTP/2 客户端仍为远期目标。
 * 【所属模块】由 std/http/http_glue.c include；符号供 std/http/mod.x 导出。
 */

/** HTTP/2 帧头固定长度（字节）。 */
#define HTTP2_FRAME_HEADER_SIZE 9
/** SETTINGS 帧类型（RFC 7540 §6.5）。 */
#define HTTP2_TYPE_SETTINGS 0x04
/** SETTINGS ACK 标志位。 */
#define HTTP2_FLAG_ACK 0x01
/** SETTINGS MAX_CONCURRENT_STREAMS（id=0x0003）。 */
#define HTTP2_SETTING_MAX_CONCURRENT_STREAMS 0x0003
/** 客户端连接 preface 长度。 */
#define HTTP2_PREFACE_LEN 24

/** RFC 7540 §3.5 连接 preface（client）。 */
static const uint8_t g_http2_connection_preface[HTTP2_PREFACE_LEN] = {
    'P', 'R', 'I', ' ', '*', ' ', 'H', 'T', 'T', 'P', '/', '2', '.', '0', '\r', '\n', '\r', '\n',
    'S', 'M', '\r', '\n', '\r', '\n'};

/** 返回连接 preface 字节长度（恒 24）。 */
int32_t http2_preface_len_c(void) { return HTTP2_PREFACE_LEN; }

/**
 * 检测 buf 是否为 HTTP/2 连接 preface。
 * 返回 1=匹配，0=不匹配或长度不足。
 */
int32_t http2_is_connection_preface_c(const uint8_t *buf, int32_t len) {
    if (!buf || len < HTTP2_PREFACE_LEN)
        return 0;
    return (memcmp(buf, g_http2_connection_preface, HTTP2_PREFACE_LEN) == 0) ? 1 : 0;
}

/** 将连接 preface 写入 out；成功返回 24。 */
int32_t http2_write_connection_preface_c(uint8_t *out, int32_t out_cap) {
    if (!out || out_cap < HTTP2_PREFACE_LEN)
        return -1;
    memcpy(out, g_http2_connection_preface, HTTP2_PREFACE_LEN);
    return HTTP2_PREFACE_LEN;
}

/**
 * 解析 HTTP/2 帧头（9 字节）。
 * 成功 0；buf 不足或参数非法 -1。
 */
int32_t http2_parse_frame_header_c(const uint8_t *buf, int32_t len, int32_t *out_type,
                                   int32_t *out_flags, int32_t *out_stream_id,
                                   int32_t *out_payload_len) {
    uint32_t plen;
    uint32_t sid;
    if (!buf || len < HTTP2_FRAME_HEADER_SIZE || !out_type || !out_flags || !out_stream_id ||
        !out_payload_len)
        return -1;
    plen = ((uint32_t)buf[0] << 16) | ((uint32_t)buf[1] << 8) | (uint32_t)buf[2];
    *out_payload_len = (int32_t)plen;
    *out_type = (int32_t)buf[3];
    *out_flags = (int32_t)buf[4];
    sid = ((uint32_t)buf[5] << 24) | ((uint32_t)buf[6] << 16) | ((uint32_t)buf[7] << 8) |
          (uint32_t)buf[8];
    *out_stream_id = (int32_t)(sid & 0x7FFFFFFFu);
    return 0;
}

/**
 * 写入 HTTP/2 帧头至 out；成功返回 9，失败 -1。
 */
int32_t http2_build_frame_header_c(int32_t payload_len, int32_t type, int32_t flags, int32_t stream_id,
                                   uint8_t *out, int32_t out_cap) {
    if (!out || out_cap < HTTP2_FRAME_HEADER_SIZE || payload_len < 0 || payload_len > 0xFFFFFF)
        return -1;
    out[0] = (uint8_t)((payload_len >> 16) & 0xFF);
    out[1] = (uint8_t)((payload_len >> 8) & 0xFF);
    out[2] = (uint8_t)(payload_len & 0xFF);
    out[3] = (uint8_t)(type & 0xFF);
    out[4] = (uint8_t)(flags & 0xFF);
    out[5] = (uint8_t)((stream_id >> 24) & 0x7F);
    out[6] = (uint8_t)((stream_id >> 16) & 0xFF);
    out[7] = (uint8_t)((stream_id >> 8) & 0xFF);
    out[8] = (uint8_t)(stream_id & 0xFF);
    return HTTP2_FRAME_HEADER_SIZE;
}

/** 构建空 payload 的 SETTINGS ACK 帧（9 字节）；成功返回 9。 */
int32_t http2_build_settings_ack_c(uint8_t *out, int32_t out_cap) {
    return http2_build_frame_header_c(0, HTTP2_TYPE_SETTINGS, HTTP2_FLAG_ACK, 0, out, out_cap);
}

/**
 * 构建含一条 SETTINGS 参数的帧（MAX_CONCURRENT_STREAMS 或任意 id/value）。
 * setting_id/value 为 SETTINGS 键值对；成功返回 15（9 头 + 6 payload）。
 */
int32_t http2_build_settings_one_c(int32_t setting_id, int32_t value, uint8_t *out, int32_t out_cap) {
    int32_t n;
    if (!out || out_cap < 15)
        return -1;
    n = http2_build_frame_header_c(6, HTTP2_TYPE_SETTINGS, 0, 0, out, out_cap);
    if (n != HTTP2_FRAME_HEADER_SIZE)
        return -1;
    out[9] = (uint8_t)((setting_id >> 8) & 0xFF);
    out[10] = (uint8_t)(setting_id & 0xFF);
    out[11] = (uint8_t)((value >> 24) & 0xFF);
    out[12] = (uint8_t)((value >> 16) & 0xFF);
    out[13] = (uint8_t)((value >> 8) & 0xFF);
    out[14] = (uint8_t)(value & 0xFF);
    return 15;
}

/** 线格式层是否可用（v0 恒 1）。 */
int32_t http2_wire_is_available_c(void) { return 1; }

/** ALPN 协议标识 "h2" 长度（字节）。 */
int32_t http2_alpn_h2_len_c(void) { return 2; }

/** 将 ALPN "h2" 写入 out；成功返回 2。 */
int32_t http2_write_alpn_h2_c(uint8_t *out, int32_t out_cap) {
    if (!out || out_cap < 2)
        return -1;
    out[0] = (uint8_t)'h';
    out[1] = (uint8_t)'2';
    return 2;
}

/** C 侧线格式烟测；0 通过。 */
int32_t http2_smoke_c(void) {
    uint8_t ack[9];
    int32_t t = 0;
    int32_t f = 0;
    int32_t sid = 0;
    int32_t plen = 0;
    uint8_t settings[15];
    int32_t st = 0;
    int32_t sf = 0;
    int32_t ssid = 0;
    int32_t splen = 0;

    if (http2_build_settings_ack_c(ack, 9) != 9)
        return 1;
    if (http2_parse_frame_header_c(ack, 9, &t, &f, &sid, &plen) != 0)
        return 2;
    if (t != HTTP2_TYPE_SETTINGS || f != HTTP2_FLAG_ACK || sid != 0 || plen != 0)
        return 3;
    if (http2_is_connection_preface_c(g_http2_connection_preface, HTTP2_PREFACE_LEN) != 1)
        return 4;
    if (http2_build_settings_one_c(HTTP2_SETTING_MAX_CONCURRENT_STREAMS, 100, settings, 15) != 15)
        return 5;
    if (http2_parse_frame_header_c(settings, 9, &st, &sf, &ssid, &splen) != 0)
        return 6;
    if (st != HTTP2_TYPE_SETTINGS || sf != 0 || ssid != 0 || splen != 6)
        return 7;
    if (settings[9] != 0x00 || settings[10] != 0x03)
        return 8;
    return 0;
}

#include "http2_flow.inc.c"
#include "http2_settings.inc.c"
#include "http2_push_h2c.inc.c"
#include "http2_goaway.inc.c"
#include "http2_ping.inc.c"
#include "http2_rst_stream.inc.c"
