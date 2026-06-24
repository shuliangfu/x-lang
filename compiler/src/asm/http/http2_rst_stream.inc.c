/**
 * std/http/http2_rst_stream.inc.c — HTTP/2 RST_STREAM 帧（RFC 7540 §6.4；STD-HTTP-H2-v27）
 *
 * 【文件职责】RST_STREAM 构建/解析、错误码常量、离线烟测。
 * 由 http2.inc.c 末尾 #include。
 */

/** RST_STREAM 帧类型（0x03）。 */
#define HTTP2_TYPE_RST_STREAM 0x03

/** RST_STREAM payload 固定长度（error_code）。 */
#define HTTP2_RST_STREAM_PAYLOAD_SIZE 4

/** 收到 RST_STREAM / stream 被对端取消（-1246）。 */
#define HTTP2_ERR_RST_STREAM (-1246)

/** RFC 7540 CANCEL 错误码（8）。 */
#define HTTP2_RST_CANCEL 8

/** 返回 RST_STREAM 帧类型常量（3）。 */
int32_t http2_frame_rst_stream_c(void) { return HTTP2_TYPE_RST_STREAM; }

/** 返回 RST_STREAM CANCEL 错误码（8）。 */
int32_t http2_rst_error_cancel_c(void) { return HTTP2_RST_CANCEL; }

/** 返回 RST_STREAM 语义错误码（-1246）。 */
int32_t http2_err_rst_stream_c(void) { return HTTP2_ERR_RST_STREAM; }

/**
 * 构建 RST_STREAM 帧（9 字节头 + 4 字节 error_code）。
 * 成功返回 13；失败 -1。
 */
int32_t http2_build_rst_stream_c(int32_t stream_id, int32_t error_code, uint8_t *out,
                                   int32_t out_cap) {
    int32_t n;
    if (!out || out_cap < HTTP2_FRAME_HEADER_SIZE + HTTP2_RST_STREAM_PAYLOAD_SIZE)
        return -1;
    if (stream_id <= 0)
        return -1;
    n = http2_build_frame_header_c(HTTP2_RST_STREAM_PAYLOAD_SIZE, HTTP2_TYPE_RST_STREAM, 0,
                                   stream_id, out, out_cap);
    if (n != HTTP2_FRAME_HEADER_SIZE)
        return -1;
    out[9] = (uint8_t)((error_code >> 24) & 0xFF);
    out[10] = (uint8_t)((error_code >> 16) & 0xFF);
    out[11] = (uint8_t)((error_code >> 8) & 0xFF);
    out[12] = (uint8_t)(error_code & 0xFF);
    return 13;
}

/**
 * 解析 RST_STREAM payload（至少 4 字节）。
 * 成功 0；payload 不足 -1。
 */
int32_t http2_parse_rst_stream_c(const uint8_t *payload, int32_t plen, int32_t *out_error_code) {
    uint32_t err;
    if (!payload || plen < HTTP2_RST_STREAM_PAYLOAD_SIZE || !out_error_code)
        return -1;
    err = ((uint32_t)payload[0] << 24) | ((uint32_t)payload[1] << 16) | ((uint32_t)payload[2] << 8) |
          (uint32_t)payload[3];
    *out_error_code = (int32_t)err;
    return 0;
}

/** RST_STREAM 编解码 C 烟测；0 通过。 */
int32_t http2_rst_stream_smoke_c(void) {
    uint8_t frame[32];
    int32_t n;
    int32_t ftype = 0;
    int32_t fflags = 0;
    int32_t fsid = 0;
    int32_t fplen = 0;
    int32_t err_code = -1;

    n = http2_build_rst_stream_c(5, HTTP2_RST_CANCEL, frame, (int32_t)sizeof(frame));
    if (n != 13)
        return 1;
    if (http2_parse_frame_header_c(frame, 9, &ftype, &fflags, &fsid, &fplen) != 0)
        return 2;
    if (ftype != HTTP2_TYPE_RST_STREAM || fflags != 0 || fsid != 5 || fplen != 4)
        return 3;
    if (http2_parse_rst_stream_c(frame + 9, fplen, &err_code) != 0)
        return 4;
    if (err_code != HTTP2_RST_CANCEL)
        return 5;
    if (http2_frame_rst_stream_c() != 3 || http2_err_rst_stream_c() != HTTP2_ERR_RST_STREAM)
        return 6;
    return 0;
}
