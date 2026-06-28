/**
 * std/http/ping.inc.c — HTTP/2 PING/PONG 帧（RFC 7540 §6.7；STD-HTTP-H2-v25）
 *
 * 【文件职责】PING 帧构建/解析、PONG ACK 响应、离线烟测。
 * 由 http2.inc.c 末尾 #include。
 */

/** PING 帧类型（0x06）。 */
#define HTTP2_TYPE_PING 0x06

/** PING payload 固定长度（8 字节 opaque data）。 */
#define HTTP2_PING_PAYLOAD_SIZE 8

/** PING 往返失败 / 未收到匹配 PONG（-1245）。 */
#define HTTP2_ERR_PING (-1245)

/** 返回 PING 帧类型常量（6）。 */
int32_t http2_frame_ping_c(void) { return HTTP2_TYPE_PING; }

/** 返回 PING 语义错误码（-1245）。 */
int32_t http2_err_ping_c(void) { return HTTP2_ERR_PING; }

/**
 * 构建 PING 帧（9 字节头 + 8 字节 opaque data）。
 * opaque 须 8 字节；成功返回 17；失败 -1。
 */
int32_t http2_build_ping_c(const uint8_t *opaque, uint8_t *out, int32_t out_cap) {
    int32_t n;
    if (!opaque || !out || out_cap < HTTP2_FRAME_HEADER_SIZE + HTTP2_PING_PAYLOAD_SIZE)
        return -1;
    n = http2_build_frame_header_c(HTTP2_PING_PAYLOAD_SIZE, HTTP2_TYPE_PING, 0, 0, out, out_cap);
    if (n != HTTP2_FRAME_HEADER_SIZE)
        return -1;
    memcpy(out + 9, opaque, HTTP2_PING_PAYLOAD_SIZE);
    return 17;
}

/**
 * 构建 PONG（PING + ACK）帧，payload 与对端 PING 相同。
 * opaque 须 8 字节；成功返回 17；失败 -1。
 */
int32_t http2_build_ping_ack_c(const uint8_t *opaque, uint8_t *out, int32_t out_cap) {
    int32_t n;
    if (!opaque || !out || out_cap < HTTP2_FRAME_HEADER_SIZE + HTTP2_PING_PAYLOAD_SIZE)
        return -1;
    n = http2_build_frame_header_c(HTTP2_PING_PAYLOAD_SIZE, HTTP2_TYPE_PING, HTTP2_FLAG_ACK, 0, out,
                                   out_cap);
    if (n != HTTP2_FRAME_HEADER_SIZE)
        return -1;
    memcpy(out + 9, opaque, HTTP2_PING_PAYLOAD_SIZE);
    return 17;
}

/**
 * 解析 PING/PONG payload（须 8 字节）。
 * 成功 0；payload 不足 -1。
 */
int32_t http2_parse_ping_c(const uint8_t *payload, int32_t plen, uint8_t *out_opaque) {
    if (!payload || plen < HTTP2_PING_PAYLOAD_SIZE || !out_opaque)
        return -1;
    memcpy(out_opaque, payload, HTTP2_PING_PAYLOAD_SIZE);
    return 0;
}

/** 比较两段 8 字节 opaque data；相等 1，否则 0。 */
int32_t http2_ping_opaque_match_c(const uint8_t *a, const uint8_t *b) {
    if (!a || !b)
        return 0;
    return (memcmp(a, b, HTTP2_PING_PAYLOAD_SIZE) == 0) ? 1 : 0;
}

/** PING/PONG 编解码 C 烟测；0 通过。 */
int32_t http2_ping_smoke_c(void) {
    uint8_t opaque[8] = {0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08};
    uint8_t frame[32];
    uint8_t got[8];
    int32_t n;
    int32_t ftype = 0;
    int32_t fflags = 0;
    int32_t fsid = 0;
    int32_t fplen = 0;

    n = http2_build_ping_c(opaque, frame, (int32_t)sizeof(frame));
    if (n != 17)
        return 1;
    if (http2_parse_frame_header_c(frame, 9, &ftype, &fflags, &fsid, &fplen) != 0)
        return 2;
    if (ftype != HTTP2_TYPE_PING || fflags != 0 || fsid != 0 || fplen != 8)
        return 3;
    if (http2_parse_ping_c(frame + 9, fplen, got) != 0)
        return 4;
    if (http2_ping_opaque_match_c(opaque, got) != 1)
        return 5;

    n = http2_build_ping_ack_c(opaque, frame, (int32_t)sizeof(frame));
    if (n != 17)
        return 6;
    if (http2_parse_frame_header_c(frame, 9, &ftype, &fflags, &fsid, &fplen) != 0)
        return 7;
    if (ftype != HTTP2_TYPE_PING || fflags != HTTP2_FLAG_ACK || fsid != 0 || fplen != 8)
        return 8;
    if (http2_frame_ping_c() != 6 || http2_err_ping_c() != HTTP2_ERR_PING)
        return 9;
    return 0;
}
