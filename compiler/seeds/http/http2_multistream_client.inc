/**
 * std/http/multistream_client.inc.c — HTTP/2 多 stream 并发客户端 v1（STD-HTTP-H2-v10）
 *
 * 【文件职责】连接级 registry + 对端 SETTINGS + 发送流控；并发 open stream 与并行 GET 帧构建。
 * 由 client.inc.c 末尾 #include。
 */

/** 并发 stream 已达对端 SETTINGS 上限（-1236）。 */
#define HTTP2_ERR_MAX_STREAMS (-1236)

/** 多 stream 并发客户端（离线编解码 + 协商状态）。 */
typedef struct {
    stream_registry_t registry;
    peer_settings_t peer;
    flow_state_t flow;
    int32_t open_count;
} multistream_client_t;

/** 初始化客户端：registry/flow/对端 SETTINGS 清零。 */
void http2_multistream_client_init_c(multistream_client_t *cli) {
    if (!cli)
        return;
    http2_stream_registry_init_c(&cli->registry);
    http2_peer_settings_init_c(&cli->peer);
    http2_flow_state_init_c(&cli->flow);
    cli->open_count = 0;
}

/** 应用对端 SETTINGS payload（通常来自 server SETTINGS 帧）。 */
int32_t http2_multistream_client_on_settings_c(multistream_client_t *cli,
                                               const uint8_t *payload, int32_t plen) {
    if (!cli)
        return -1;
    return http2_peer_settings_consume_payload_c(payload, plen, &cli->peer);
}

/**
 * 在 SETTINGS 限制内分配 stream 并刷新流窗口。
 * 成功返回 stream_id；表满 -1；超并发 HTTP2_ERR_MAX_STREAMS(-1236)。
 */
int32_t http2_multistream_client_open_stream_c(multistream_client_t *cli) {
    int32_t sid;
    int32_t max_streams;
    if (!cli)
        return -1;
    max_streams = http2_peer_settings_max_streams_c(&cli->peer);
    if (cli->open_count >= max_streams)
        return HTTP2_ERR_MAX_STREAMS;
    sid = http2_stream_registry_open_c(&cli->registry);
    if (sid < 0)
        return -1;
    cli->open_count++;
    http2_flow_state_reset_stream_c(&cli->flow,
                                    http2_peer_settings_initial_window_c(&cli->peer));
    return sid;
}

/** 关闭 stream 并递减 open_count。 */
void http2_multistream_client_close_stream_c(multistream_client_t *cli, int32_t stream_id) {
    if (!cli || stream_id <= 0)
        return;
    if (http2_stream_registry_is_open_c(&cli->registry, stream_id) != 0) {
        http2_stream_registry_close_c(&cli->registry, stream_id);
        if (cli->open_count > 0)
            cli->open_count--;
    }
}

/**
 * 在指定 stream 上构建 GET HEADERS 帧写入 out。
 * 成功返回帧长度；失败 -1。
 */
int32_t http2_multistream_client_build_get_c(multistream_client_t *cli, int32_t stream_id,
                                             const uint8_t *authority, int32_t authority_len,
                                             const uint8_t *path, int32_t path_len,
                                             uint8_t *out, int32_t out_cap) {
    (void)cli;
    if (stream_id <= 0 || !authority || authority_len <= 0 || !path || path_len <= 0 || !out)
        return -1;
    return http2_build_request_headers_frame_c(0, authority, authority_len, path, path_len, 1, 0,
                                               stream_id, out, out_cap);
}

/**
 * 并发构建 n 个 GET HEADERS 帧（依次 open stream）；帧顺序写入 out。
 * 成功返回写入总字节数；失败 -1；超并发 HTTP2_ERR_MAX_STREAMS。
 */
int32_t http2_multistream_client_build_parallel_get_c(multistream_client_t *cli,
                                                      const uint8_t *authority,
                                                      int32_t authority_len, const uint8_t *path,
                                                      int32_t path_len, int32_t n_reqs,
                                                      uint8_t *out, int32_t out_cap) {
    int32_t i;
    int32_t off = 0;
    int32_t sid;
    int32_t flen;
    uint8_t frame[512];
    if (!cli || !authority || authority_len <= 0 || !path || path_len <= 0 || !out || n_reqs <= 0)
        return -1;
    for (i = 0; i < n_reqs; i++) {
        sid = http2_multistream_client_open_stream_c(cli);
        if (sid == HTTP2_ERR_MAX_STREAMS)
            return HTTP2_ERR_MAX_STREAMS;
        if (sid < 0)
            return -1;
        flen = http2_multistream_client_build_get_c(cli, sid, authority, authority_len, path,
                                                    path_len, frame, (int32_t)sizeof(frame));
        if (flen <= 0)
            return -1;
        if (off + flen > out_cap)
            return -1;
        memcpy(out + off, frame, (size_t)flen);
        off += flen;
    }
    return off;
}

/** 多 stream 并发客户端 C 烟测；0 通过。 */
int32_t http2_multistream_client_smoke_c(void) {
    multistream_client_t cli;
    uint8_t settings_frame[32];
    uint8_t out[2048];
    int32_t sid1;
    int32_t sid2;
    int32_t sid3;
    int32_t total;
    uint8_t frame[512];
    int32_t ftype;
    int32_t fflags;
    int32_t fsid;
    int32_t fplen;

    http2_multistream_client_init_c(&cli);
    if (http2_build_client_settings_c(2, 65535, settings_frame, 32) != 27)
        return 1;
    if (http2_multistream_client_on_settings_c(&cli, settings_frame + 9, 12) != 0)
        return 2;
    sid1 = http2_multistream_client_open_stream_c(&cli);
    sid2 = http2_multistream_client_open_stream_c(&cli);
    sid3 = http2_multistream_client_open_stream_c(&cli);
    if (sid1 != 1 || sid2 != 3)
        return 3;
    if (sid3 != HTTP2_ERR_MAX_STREAMS)
        return 4;
    http2_multistream_client_close_stream_c(&cli, sid2);
    sid3 = http2_multistream_client_open_stream_c(&cli);
    if (sid3 != 5)
        return 5;
    http2_multistream_client_init_c(&cli);
    if (http2_multistream_client_on_settings_c(&cli, settings_frame + 9, 12) != 0)
        return 6;
    total = http2_multistream_client_build_parallel_get_c(
        &cli, (const uint8_t *)"example.com", 11, (const uint8_t *)"/p", 2, 2, out,
        (int32_t)sizeof(out));
    if (total <= 0)
        return 7;
    if (http2_parse_frame_header_c(out, 9, &ftype, &fflags, &fsid, &fplen) != 0)
        return 8;
    if (ftype != HTTP2_TYPE_HEADERS || fsid != 1)
        return 9;
    if (http2_parse_frame_header_c(out + 9 + fplen, 9, &ftype, &fflags, &fsid, &fplen) != 0)
        return 10;
    if (fsid != 3)
        return 11;
    if (http2_multistream_client_build_get_c(&cli, 1, (const uint8_t *)"example.com", 11,
                                             (const uint8_t *)"/z", 2, frame,
                                             (int32_t)sizeof(frame)) <= 0)
        return 12;
    return 0;
}
