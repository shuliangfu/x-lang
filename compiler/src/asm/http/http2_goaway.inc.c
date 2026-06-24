/**
 * std/http/http2_goaway.inc.c — HTTP/2 GOAWAY 帧（RFC 7540 §6.8；STD-HTTP-H2-v24）
 *
 * 【文件职责】GOAWAY 帧构建/解析、错误码常量、离线烟测。
 * 由 http2.inc.c 末尾 #include。
 */

/** GOAWAY 帧类型（0x07）。 */
#define HTTP2_TYPE_GOAWAY 0x07

/** GOAWAY payload 固定长度（last_stream_id + error_code）。 */
#define HTTP2_GOAWAY_PAYLOAD_SIZE 8

/** 对端发送 GOAWAY / 期望 GOAWAY 时语义码（-1244）。 */
#define HTTP2_ERR_GOAWAY (-1244)

/** RFC 7540 NO_ERROR 错误码（0）。 */
#define HTTP2_GOAWAY_NO_ERROR 0

/** 返回 GOAWAY 帧类型常量（7）。 */
int32_t http2_frame_goaway_c(void) { return HTTP2_TYPE_GOAWAY; }

/** 返回 GOAWAY NO_ERROR 错误码（0）。 */
int32_t http2_goaway_error_no_error_c(void) { return HTTP2_GOAWAY_NO_ERROR; }

/** 返回 GOAWAY 语义错误码（-1244）。 */
int32_t http2_err_goaway_c(void) { return HTTP2_ERR_GOAWAY; }

/**
 * 构建 GOAWAY 帧（9 字节头 + 8 字节 payload）。
 * last_stream_id：已处理的最大 stream id；error_code：RFC 7540 错误码。
 * 成功返回 17；失败 -1。
 */
int32_t http2_build_goaway_c(int32_t last_stream_id, int32_t error_code, uint8_t *out,
                               int32_t out_cap) {
    int32_t n;
    uint32_t sid;
    if (!out || out_cap < HTTP2_FRAME_HEADER_SIZE + HTTP2_GOAWAY_PAYLOAD_SIZE)
        return -1;
    n = http2_build_frame_header_c(HTTP2_GOAWAY_PAYLOAD_SIZE, HTTP2_TYPE_GOAWAY, 0, 0, out,
                                     out_cap);
    if (n != HTTP2_FRAME_HEADER_SIZE)
        return -1;
    sid = (uint32_t)(last_stream_id & 0x7FFFFFFF);
    out[9] = (uint8_t)((sid >> 24) & 0xFF);
    out[10] = (uint8_t)((sid >> 16) & 0xFF);
    out[11] = (uint8_t)((sid >> 8) & 0xFF);
    out[12] = (uint8_t)(sid & 0xFF);
    out[13] = (uint8_t)((error_code >> 24) & 0xFF);
    out[14] = (uint8_t)((error_code >> 16) & 0xFF);
    out[15] = (uint8_t)((error_code >> 8) & 0xFF);
    out[16] = (uint8_t)(error_code & 0xFF);
    return 17;
}

/**
 * 解析 GOAWAY payload（至少 8 字节）。
 * 成功 0；payload 不足 -1。
 */
int32_t http2_parse_goaway_c(const uint8_t *payload, int32_t plen, int32_t *out_last_stream,
                               int32_t *out_error_code) {
    uint32_t sid;
    uint32_t err;
    if (!payload || plen < HTTP2_GOAWAY_PAYLOAD_SIZE || !out_last_stream || !out_error_code)
        return -1;
    sid = ((uint32_t)payload[0] << 24) | ((uint32_t)payload[1] << 16) | ((uint32_t)payload[2] << 8) |
          (uint32_t)payload[3];
    err = ((uint32_t)payload[4] << 24) | ((uint32_t)payload[5] << 16) | ((uint32_t)payload[6] << 8) |
          (uint32_t)payload[7];
    *out_last_stream = (int32_t)(sid & 0x7FFFFFFFu);
    *out_error_code = (int32_t)err;
    return 0;
}

/** GOAWAY 编解码 C 烟测；0 通过。 */
int32_t http2_goaway_smoke_c(void) {
    uint8_t frame[32];
    int32_t n;
    int32_t ftype = 0;
    int32_t fflags = 0;
    int32_t fsid = 0;
    int32_t fplen = 0;
    int32_t last_stream = 0;
    int32_t err_code = -1;

    n = http2_build_goaway_c(3, HTTP2_GOAWAY_NO_ERROR, frame, (int32_t)sizeof(frame));
    if (n != 17)
        return 1;
    if (http2_parse_frame_header_c(frame, 9, &ftype, &fflags, &fsid, &fplen) != 0)
        return 2;
    if (ftype != HTTP2_TYPE_GOAWAY || fflags != 0 || fsid != 0 || fplen != 8)
        return 3;
    if (http2_parse_goaway_c(frame + 9, fplen, &last_stream, &err_code) != 0)
        return 4;
    if (last_stream != 3 || err_code != 0)
        return 5;
    if (http2_frame_goaway_c() != 7 || http2_err_goaway_c() != HTTP2_ERR_GOAWAY)
        return 6;
    return 0;
}
