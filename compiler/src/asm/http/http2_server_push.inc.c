/**
 * std/http/server_push.inc.c — HTTP/2 server push 响应 v1（STD-HTTP-H2-v17）
 *
 * 【文件职责】构建 PUSH_PROMISE 帧并在 parent stream 上推送 promised stream 资源。
 * 由 server.inc.c 末尾 #include（复用 io_* 与 HEADERS/DATA 构建）。
 */

/** server push 参数非法（-1242）。 */
#define HTTP2_ERR_SERVER_PUSH (-1242)

/** client SETTINGS ENABLE_PUSH=0，server 软拒绝 push（跳过 PUSH_PROMISE；-1243）。 */
#define HTTP2_ERR_SERVER_PUSH_DISABLED (-1243)

/**
 * 构建 PUSH_PROMISE 帧（parent stream + promised stream + GET HPACK 块）。
 * 成功返回帧总字节数；失败 -1。
 */
int32_t http2_build_push_promise_frame_c(int32_t parent_stream_id, int32_t promised_stream_id,
                                         const uint8_t *authority, int32_t authority_len,
                                         const uint8_t *path, int32_t path_len, int32_t is_https,
                                         uint8_t *out, int32_t out_cap) {
    uint8_t hpack[512];
    uint8_t payload[512];
    int32_t hlen;
    int32_t plen;
    int32_t n;

    if (!out || out_cap <= 0 || parent_stream_id <= 0 || promised_stream_id <= 0)
        return -1;
    if ((promised_stream_id & 1) != 0)
        return -1;
    if (!authority || authority_len <= 0 || !path || path_len <= 0)
        return -1;

    hlen = http2_hpack_encode_get_request_c(authority, authority_len, path, path_len, is_https,
                                            hpack, (int32_t)sizeof(hpack));
    if (hlen <= 0)
        return -1;
    plen = 4 + hlen;
    if (plen > (int32_t)sizeof(payload) || HTTP2_FRAME_HEADER_SIZE + plen > out_cap)
        return -1;

    payload[0] = (uint8_t)((promised_stream_id >> 24) & 0x7F);
    payload[1] = (uint8_t)((promised_stream_id >> 16) & 0xFF);
    payload[2] = (uint8_t)((promised_stream_id >> 8) & 0xFF);
    payload[3] = (uint8_t)(promised_stream_id & 0xFF);
    memcpy(payload + 4, hpack, (size_t)hlen);

    n = http2_build_frame_header_c(plen, HTTP2_TYPE_PUSH_PROMISE, HTTP2_FLAG_END_HEADERS,
                                   parent_stream_id, out, out_cap);
    if (n != HTTP2_FRAME_HEADER_SIZE)
        return -1;
    memcpy(out + n, payload, (size_t)plen);
    return n + plen;
}

/**
 * 在 parent stream 上发送 PUSH_PROMISE，并在 promised stream 回 push body。
 * promised_stream_id 须为偶数；成功 0。
 */
int32_t http2_server_send_push_c(io_t *io, int32_t parent_stream_id, int32_t promised_stream_id,
                                 const uint8_t *authority, int32_t authority_len, const uint8_t *path,
                                 int32_t path_len, const uint8_t *push_body, int32_t push_body_len,
                                 int32_t is_https, hpack_server_dyn_t *enc,
                                 int32_t max_frame_size) {
    uint8_t frame_buf[512];
    int32_t pp_len;
    int32_t rc;

    if (!io || parent_stream_id <= 0 || promised_stream_id <= 0 || !enc)
        return -1;
    if (!authority || authority_len <= 0 || !path || path_len <= 0)
        return HTTP2_ERR_SERVER_PUSH;
    if (push_body_len < 0)
        push_body_len = 0;
    if (push_body_len > 0 && !push_body)
        return HTTP2_ERR_SERVER_PUSH;

    pp_len = http2_build_push_promise_frame_c(parent_stream_id, promised_stream_id, authority,
                                              authority_len, path, path_len, is_https, frame_buf,
                                              (int32_t)sizeof(frame_buf));
    if (pp_len <= 0)
        return HTTP2_ERR_SERVER_PUSH;
    if (io_write_all(io, frame_buf, pp_len) != 0)
        return HTTP2_ERR_SERVER;

    rc = http2_server_send_response_c(io, promised_stream_id, push_body, push_body_len, enc,
                                      max_frame_size);
    if (rc != 0)
        return rc;
    return 0;
}

/**
 * 若对端 ENABLE_PUSH=1 则发 push；否则软拒绝（返回 0，不发 PUSH_PROMISE）。
 * 参数非法仍返回 HTTP2_ERR_SERVER_PUSH / HTTP2_ERR_SERVER。
 */
int32_t http2_server_send_push_respecting_peer_c(
    io_t *io, const peer_settings_t *peer, int32_t parent_stream_id,
    int32_t promised_stream_id, const uint8_t *authority, int32_t authority_len,
    const uint8_t *path, int32_t path_len, const uint8_t *push_body, int32_t push_body_len,
    int32_t is_https, hpack_server_dyn_t *enc) {
    if (!enc)
        return -1;
    if (peer != NULL && http2_peer_settings_enable_push_c(peer) == 0)
        return 0;
    return http2_server_send_push_c(io, parent_stream_id, promised_stream_id, authority,
                                    authority_len, path, path_len, push_body, push_body_len,
                                    is_https, enc,
                                    http2_peer_settings_max_frame_size_c(peer));
}

/** PUSH_PROMISE 构建 C 烟测；0 通过。 */
int32_t http2_server_push_wire_smoke_c(void) {
    uint8_t frame[256];
    int32_t promised = 0;
    int32_t n;
    const uint8_t host[] = "example.com";
    const uint8_t path[] = "/push";

    n = http2_build_push_promise_frame_c(1, 2, host, 11, path, 5, 1, frame, (int32_t)sizeof(frame));
    if (n <= 0)
        return 1;
    if (http2_parse_push_promise_stream_c(frame + 9, n - 9, &promised) != 0)
        return 2;
    if (promised != 2)
        return 3;
    return 0;
}
