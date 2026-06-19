/**
 * std/http/http2_conn_reuse.inc.c — HTTP/2 单连接多请求复用 v1（STD-HTTP-H2-v11）
 *
 * 【文件职责】同一 TCP/TLS 连接上 preface+SETTINGS 一次握手，多 stream 顺序/并发请求往返。
 * 由 http2_network.inc.c 末尾 #include。
 */

/** 连接未完成 handshake（须 http2_conn_handshake）。 */
#define HTTP2_ERR_CONN_NOT_READY (-1237)

/** 可复用 HTTP/2 连接（io + multistream 状态 + ready / goaway 标志）。 */
typedef struct {
    int32_t fd;
    int64_t tls_ctx;
    int32_t ready;
    int32_t goaway_seen;
    int32_t is_https;
    http2_multistream_client_t ms;
} http2_conn_t;

/** 从 conn 取统一 IO 视图。 */
static http2_io_t http2_conn_io(const http2_conn_t *conn) {
    http2_io_t io;
    io.fd = conn ? conn->fd : -1;
    io.tls_ctx = conn ? conn->tls_ctx : 0;
    return io;
}

/** 初始化连接对象（未 attach / 未 ready）。 */
void http2_conn_init_c(http2_conn_t *conn) {
    if (!conn)
        return;
    conn->fd = -1;
    conn->tls_ctx = 0;
    conn->ready = 0;
    conn->goaway_seen = 0;
    conn->is_https = 0;
    http2_multistream_client_init_c(&conn->ms);
}

/** 绑定 cleartext h2c fd（须已 connect）；成功 0。 */
int32_t http2_conn_attach_h2c_c(int32_t fd, http2_conn_t *conn) {
    if (!conn || fd < 0)
        return -1;
    conn->fd = fd;
    conn->tls_ctx = 0;
    conn->is_https = 0;
    conn->ready = 0;
    return 0;
}

/** 绑定已协商 h2 的 TLS ctx；成功 0。 */
int32_t http2_conn_attach_tls_c(int64_t tls_ctx, http2_conn_t *conn) {
    if (!conn || tls_ctx == 0)
        return -1;
    conn->fd = -1;
    conn->tls_ctx = tls_ctx;
    conn->is_https = 1;
    conn->ready = 0;
    return 0;
}

/** 连接是否已完成 handshake（1 是，0 否）。 */
int32_t http2_conn_is_ready_c(const http2_conn_t *conn) {
    if (!conn)
        return 0;
    return conn->ready != 0 ? 1 : 0;
}

/**
 * 发送 preface + client SETTINGS（含 ENABLE_PUSH），读 server SETTINGS 并 ACK。
 * client_enable_push：1=允许 server push，0=拒绝（RFC SETTINGS ENABLE_PUSH）。
 */
int32_t http2_conn_handshake_with_enable_push_c(http2_conn_t *conn, int32_t client_enable_push) {
    http2_io_t io;
    uint8_t preface[32];
    uint8_t csettings[32];
    uint8_t hdr[9];
    uint8_t payload[256];
    uint8_t ack[16];
    int32_t preface_len;
    int32_t cs_len;
    int32_t round;
    int32_t got_peer_settings;
    int32_t ftype;
    int32_t fflags;
    int32_t stream_id;
    int32_t plen;

    if (!conn)
        return -1;
    if (conn->tls_ctx == 0 && conn->fd < 0)
        return -1;
    if (client_enable_push != 0)
        client_enable_push = 1;

    io = http2_conn_io(conn);
    got_peer_settings = 0;

    if (conn->tls_ctx == 0) {
        preface_len = http2_write_connection_preface_c(preface, (int32_t)sizeof(preface));
        if (preface_len != HTTP2_PREFACE_LEN)
            return -1;
        if (http2_io_write_all(&io, preface, preface_len) != 0)
            return HTTP2_ERR_NETWORK;
    }

    cs_len = http2_build_client_settings_ex_c(100, HTTP2_DEFAULT_INITIAL_WINDOW, client_enable_push,
                                              csettings, 32);
    if (cs_len > 0) {
        if (http2_io_write_all(&io, csettings, cs_len) != 0)
            return HTTP2_ERR_NETWORK;
    }

    for (round = 0; round < 16; round++) {
        if (http2_io_read_exact(&io, hdr, 9) != 0)
            return HTTP2_ERR_NETWORK;
        if (http2_parse_frame_header_c(hdr, 9, &ftype, &fflags, &stream_id, &plen) != 0)
            return -1;
        if (plen < 0 || plen > (int32_t)sizeof(payload))
            return -1;
        if (plen > 0) {
            if (http2_io_read_exact(&io, payload, plen) != 0)
                return HTTP2_ERR_NETWORK;
        }

        if (ftype == HTTP2_TYPE_SETTINGS) {
            if ((fflags & HTTP2_FLAG_ACK) == 0) {
                if (plen > 0)
                    http2_multistream_client_on_settings_c(&conn->ms, payload, plen);
                if (http2_build_settings_ack_c(ack, (int32_t)sizeof(ack)) != 9)
                    return -1;
                if (http2_io_write_all(&io, ack, 9) != 0)
                    return HTTP2_ERR_NETWORK;
                got_peer_settings = 1;
                break;
            }
            continue;
        }
    }

    if (got_peer_settings == 0)
        return HTTP2_ERR_NETWORK;

    conn->ready = 1;
    return 0;
}

/**
 * 发送 preface + client SETTINGS，读 server SETTINGS 并 ACK（最多 16 帧）。
 * 成功 0 并置 ready=1；失败 -1 / HTTP2_ERR_NETWORK。
 */
int32_t http2_conn_handshake_c(http2_conn_t *conn) {
    return http2_conn_handshake_with_enable_push_c(conn, 1);
}

/**
 * handshake 并在 client SETTINGS 中声明 MAX_FRAME_SIZE（供 server 分片 DATA）。
 * client_max_frame_size≤0 时等同 http2_conn_handshake_c。
 */
int32_t http2_conn_handshake_with_max_frame_c(http2_conn_t *conn, int32_t client_max_frame_size) {
    http2_io_t io;
    uint8_t preface[32];
    uint8_t csettings[64];
    uint8_t hdr[9];
    uint8_t payload[256];
    uint8_t ack[16];
    int32_t preface_len;
    int32_t cs_len;
    int32_t round;
    int32_t got_peer_settings;
    int32_t ftype;
    int32_t fflags;
    int32_t stream_id;
    int32_t plen;

    if (!conn)
        return -1;
    if (conn->tls_ctx == 0 && conn->fd < 0)
        return -1;
    if (client_max_frame_size <= 0)
        return http2_conn_handshake_c(conn);

    io = http2_conn_io(conn);
    got_peer_settings = 0;

    if (conn->tls_ctx == 0) {
        preface_len = http2_write_connection_preface_c(preface, (int32_t)sizeof(preface));
        if (preface_len != HTTP2_PREFACE_LEN)
            return -1;
        if (http2_io_write_all(&io, preface, preface_len) != 0)
            return HTTP2_ERR_NETWORK;
    }

    cs_len = http2_build_client_settings_with_max_frame_c(
        100, HTTP2_DEFAULT_INITIAL_WINDOW, 1, client_max_frame_size, csettings,
        (int32_t)sizeof(csettings));
    if (cs_len > 0) {
        if (http2_io_write_all(&io, csettings, cs_len) != 0)
            return HTTP2_ERR_NETWORK;
    }

    for (round = 0; round < 16; round++) {
        if (http2_io_read_exact(&io, hdr, 9) != 0)
            return HTTP2_ERR_NETWORK;
        if (http2_parse_frame_header_c(hdr, 9, &ftype, &fflags, &stream_id, &plen) != 0)
            return -1;
        if (plen < 0 || plen > (int32_t)sizeof(payload))
            return -1;
        if (plen > 0) {
            if (http2_io_read_exact(&io, payload, plen) != 0)
                return HTTP2_ERR_NETWORK;
        }

        if (ftype == HTTP2_TYPE_SETTINGS) {
            if ((fflags & HTTP2_FLAG_ACK) == 0) {
                if (plen > 0)
                    http2_multistream_client_on_settings_c(&conn->ms, payload, plen);
                if (http2_build_settings_ack_c(ack, (int32_t)sizeof(ack)) != 9)
                    return -1;
                if (http2_io_write_all(&io, ack, 9) != 0)
                    return HTTP2_ERR_NETWORK;
                got_peer_settings = 1;
                break;
            }
            continue;
        }
    }

    if (got_peer_settings == 0)
        return HTTP2_ERR_NETWORK;

    conn->ready = 1;
    return 0;
}

/**
 * 在已 ready 连接上发单请求（新 stream）并读该 stream 响应（HTTP/1 风格 out）。
 * 成功返回 raw_len；未 handshake HTTP2_ERR_CONN_NOT_READY(-1237)。
 */
int32_t http2_conn_request_c(http2_conn_t *conn, uint8_t method_u8, const uint8_t *authority,
                             int32_t authority_len, const uint8_t *path, int32_t path_len,
                             const uint8_t *body, int32_t body_len, uint8_t *out, int32_t out_cap) {
    http2_io_t io;
    uint8_t payload[4096];
    int32_t stream_id;
    int32_t hdr_frame_len;
    int32_t has_body;
    int32_t data_frame_len;
    int32_t is_https;
    int32_t rc;

    if (!conn || !authority || authority_len <= 0 || !path || path_len <= 0 || !out || out_cap <= 64)
        return -1;
    if (conn->ready == 0)
        return HTTP2_ERR_CONN_NOT_READY;
    if (conn->tls_ctx == 0 && conn->fd < 0)
        return -1;

    has_body = http2_method_has_body(method_u8);
    if (has_body != 0) {
        if (body_len <= 0 || !body)
            return -1;
    } else {
        body_len = 0;
    }

    io = http2_conn_io(conn);
    stream_id = http2_multistream_client_open_stream_c(&conn->ms);
    if (stream_id == HTTP2_ERR_MAX_STREAMS)
        return HTTP2_ERR_MAX_STREAMS;
    if (stream_id < 0)
        return -1;

    is_https = conn->is_https != 0 ? 1 : 0;
    hdr_frame_len = http2_build_request_headers_frame_c(
        method_u8, authority, authority_len, path, path_len, is_https, has_body, stream_id,
        payload, (int32_t)sizeof(payload));
    if (hdr_frame_len <= 0)
        return -1;
    if (http2_io_write_all(&io, payload, hdr_frame_len) != 0)
        return HTTP2_ERR_NETWORK;

    if (has_body != 0) {
        int32_t init_win;
        int32_t send_len;
        init_win = http2_peer_settings_initial_window_c(&conn->ms.peer);
        http2_flow_state_apply_initial_window_c(&conn->ms.flow, init_win);
        if (http2_flow_state_can_send_c(&conn->ms.flow, body_len) == 0)
            return HTTP2_FLOW_ERR_BLOCKED;
        send_len = http2_flow_state_max_send_c(&conn->ms.flow, body_len);
        if (send_len != body_len)
            return HTTP2_FLOW_ERR_BLOCKED;
        data_frame_len = http2_build_data_frame_c(stream_id, HTTP2_FLAG_END_STREAM, body, body_len,
                                                  payload, (int32_t)sizeof(payload));
        if (data_frame_len <= 0)
            return -1;
        if (http2_flow_state_consume_send_c(&conn->ms.flow, body_len) != 0)
            return HTTP2_FLOW_ERR_BLOCKED;
        if (http2_io_write_all(&io, payload, data_frame_len) != 0)
            return HTTP2_ERR_NETWORK;
    }

    rc = http2_read_response_stream_io(&io, stream_id, out, out_cap, &conn->ms.peer,
                                       &conn->goaway_seen);
    if (conn->goaway_seen != 0)
        conn->ready = 0;
    http2_multistream_client_close_stream_c(&conn->ms, stream_id);
    return rc;
}

/** 连接是否已探测/收到对端 GOAWAY（不可再复用）。 */
int32_t http2_conn_goaway_seen_c(const http2_conn_t *conn) {
    if (!conn)
        return 0;
    return conn->goaway_seen != 0 ? 1 : 0;
}

/** 标记连接已 GOAWAY（连接池 discard 路径）。 */
void http2_conn_mark_goaway_seen_c(http2_conn_t *conn) {
    if (!conn)
        return;
    conn->goaway_seen = 1;
    conn->ready = 0;
}

/** 连接是否可归还连接池 idle 栈（ready 且未 GOAWAY）。 */
int32_t http2_conn_is_pool_reusable_c(const http2_conn_t *conn) {
    if (!conn)
        return 0;
    return (conn->ready != 0 && conn->goaway_seen == 0) ? 1 : 0;
}

/**
 * 向对端发送 RST_STREAM 取消指定 stream。
 * 成功 0；未 ready HTTP2_ERR_CONN_NOT_READY(-1237)。
 */
int32_t http2_conn_reset_stream_c(http2_conn_t *conn, int32_t stream_id, int32_t error_code) {
    http2_io_t io;
    uint8_t frame[32];
    int32_t n;

    if (!conn || stream_id <= 0)
        return -1;
    if (conn->ready == 0)
        return HTTP2_ERR_CONN_NOT_READY;
    n = http2_build_rst_stream_c(stream_id, error_code, frame, (int32_t)sizeof(frame));
    if (n <= 0)
        return -1;
    io = http2_conn_io(conn);
    if (http2_io_write_all(&io, frame, n) != 0)
        return HTTP2_ERR_NETWORK;
    http2_multistream_client_close_stream_c(&conn->ms, stream_id);
    return 0;
}

/** 标记连接关闭（不 shutdown fd/TLS；调用方仍负责底层 IO 生命周期）。 */
void http2_conn_close_c(http2_conn_t *conn) {
    if (!conn)
        return;
    conn->ready = 0;
    conn->fd = -1;
    conn->tls_ctx = 0;
}

/** 关闭底层 fd/TLS 并重置连接（连接池 discard 路径）。 */
void http2_conn_shutdown_c(http2_conn_t *conn) {
    if (!conn)
        return;
    if (conn->tls_ctx != 0) {
        net_tls_close_c(conn->tls_ctx);
        conn->tls_ctx = 0;
    }
    if (conn->fd >= 0) {
        SHUX_HTTP_CLOSE(conn->fd);
        conn->fd = -1;
    }
    conn->ready = 0;
}

/**
 * 向对端发送 GOAWAY 后 shutdown 底层 IO（连接优雅关闭）。
 * last_stream_id：已处理的最大 stream id；error_code：RFC 7540 错误码。
 */
void http2_conn_shutdown_graceful_c(http2_conn_t *conn, int32_t last_stream_id, int32_t error_code) {
    http2_io_t io;
    uint8_t frame[32];
    int32_t n;

    if (!conn)
        return;
    if (conn->ready != 0) {
        io = http2_conn_io(conn);
        n = http2_build_goaway_c(last_stream_id, error_code, frame, (int32_t)sizeof(frame));
        if (n > 0)
            (void)http2_io_write_all(&io, frame, n);
    }
    http2_conn_shutdown_c(conn);
}

/**
 * 读下一 GOAWAY 帧并解析 payload。
 * 成功 0；非 GOAWAY 或超时轮次耗尽返回 HTTP2_ERR_GOAWAY(-1244)。
 */
int32_t http2_conn_read_goaway_c(http2_conn_t *conn, int32_t *out_last_stream,
                                   int32_t *out_error_code) {
    http2_io_t io;
    uint8_t hdr[9];
    uint8_t payload[32];
    int32_t round;
    int32_t ftype;
    int32_t fflags;
    int32_t stream_id;
    int32_t plen;

    if (!conn || !out_last_stream || !out_error_code)
        return -1;
    if (conn->ready == 0)
        return HTTP2_ERR_CONN_NOT_READY;

    io = http2_conn_io(conn);
    for (round = 0; round < 32; round++) {
        if (http2_io_read_exact(&io, hdr, 9) != 0)
            return HTTP2_ERR_NETWORK;
        if (http2_parse_frame_header_c(hdr, 9, &ftype, &fflags, &stream_id, &plen) != 0)
            return -1;
        if (plen < 0 || plen > (int32_t)sizeof(payload))
            return -1;
        if (plen > 0) {
            if (http2_io_read_exact(&io, payload, plen) != 0)
                return HTTP2_ERR_NETWORK;
        }
        if (ftype == HTTP2_TYPE_GOAWAY) {
            http2_conn_mark_goaway_seen_c(conn);
            if (http2_parse_goaway_c(payload, plen, out_last_stream, out_error_code) != 0)
                return -1;
            return 0;
        }
    }
    return HTTP2_ERR_GOAWAY;
}

/** h2c server GOAWAY fork 集成烟测（定义于 http2_server.inc.c）；0 通过。 */
int32_t http2_h2c_server_goaway_smoke_c(void);

/** GOAWAY 编解码 + h2c fork 集成 C 烟测；0 通过。 */
int32_t http2_conn_goaway_smoke_c(void) {
    if (http2_goaway_smoke_c() != 0)
        return 1;
    if (http2_h2c_server_goaway_smoke_c() != 0)
        return 2;
    return 0;
}

/** h2c server PING/PONG fork 集成烟测（定义于 http2_server.inc.c）；0 通过。 */
int32_t http2_h2c_server_ping_smoke_c(void);

/**
 * 在已 ready 连接上发 PING 并等待匹配 PONG（PING+ACK）。
 * opaque 须 8 字节；成功 0；超时/不匹配 HTTP2_ERR_PING(-1245)。
 */
int32_t http2_conn_ping_c(http2_conn_t *conn, const uint8_t *opaque) {
    http2_io_t io;
    uint8_t frame[32];
    uint8_t hdr[9];
    uint8_t payload[16];
    uint8_t got[8];
    int32_t n;
    int32_t round;
    int32_t ftype;
    int32_t fflags;
    int32_t stream_id;
    int32_t plen;

    if (!conn || !opaque)
        return -1;
    if (conn->ready == 0)
        return HTTP2_ERR_CONN_NOT_READY;

    n = http2_build_ping_c(opaque, frame, (int32_t)sizeof(frame));
    if (n <= 0)
        return -1;
    io = http2_conn_io(conn);
    if (http2_io_write_all(&io, frame, n) != 0)
        return HTTP2_ERR_NETWORK;

    for (round = 0; round < 32; round++) {
        if (http2_io_read_exact(&io, hdr, 9) != 0)
            return HTTP2_ERR_NETWORK;
        if (http2_parse_frame_header_c(hdr, 9, &ftype, &fflags, &stream_id, &plen) != 0)
            return -1;
        if (plen < 0 || plen > (int32_t)sizeof(payload))
            return -1;
        if (plen > 0) {
            if (http2_io_read_exact(&io, payload, plen) != 0)
                return HTTP2_ERR_NETWORK;
        }
        if (ftype == HTTP2_TYPE_PING && (fflags & HTTP2_FLAG_ACK) != 0 && stream_id == 0 &&
            plen == HTTP2_PING_PAYLOAD_SIZE) {
            if (http2_parse_ping_c(payload, plen, got) != 0)
                return -1;
            if (http2_ping_opaque_match_c(opaque, got) == 1)
                return 0;
        }
    }
    return HTTP2_ERR_PING;
}

/** PING/PONG 编解码 + h2c fork 集成 C 烟测；0 通过。 */
int32_t http2_conn_ping_smoke_c(void) {
    if (http2_ping_smoke_c() != 0)
        return 1;
    if (http2_h2c_server_ping_smoke_c() != 0)
        return 2;
    return 0;
}

/** 单连接复用 C 烟测（无效 fd handshake 须失败）；0 通过。 */
int32_t http2_conn_reuse_smoke_c(void) {
    http2_conn_t conn;
    uint8_t out[128];

    http2_conn_init_c(&conn);
    if (http2_conn_is_ready_c(&conn) != 0)
        return 1;
    if (http2_conn_attach_h2c_c(-1, &conn) != -1)
        return 2;
    if (http2_conn_attach_h2c_c(999999, &conn) != 0)
        return 3;
    if (http2_conn_handshake_c(&conn) != HTTP2_ERR_NETWORK)
        return 4;
    if (http2_conn_is_ready_c(&conn) != 0)
        return 5;
    if (http2_conn_request_c(&conn, 0, (const uint8_t *)"example.com", 11, (const uint8_t *)"/", 1,
                             NULL, 0, out, 128) != HTTP2_ERR_CONN_NOT_READY)
        return 6;
    http2_conn_close_c(&conn);
    if (http2_conn_is_ready_c(&conn) != 0)
        return 7;
    return 0;
}

/** 单连接复用 API 是否可用（v11 恒 1）。 */
int32_t http2_conn_reuse_is_available_c(void) { return 1; }
