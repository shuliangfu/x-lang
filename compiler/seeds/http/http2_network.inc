/**
 * std/http/network.inc.c — HTTP/2 over TLS / h2c 明文网络路径（STD-HTTP-H2-TLS/v8）
 *
 * 【文件职责】TLS+h2 ALPN 与 cleartext h2c 上的多 method 请求；push 读路径收集。
 * 【依赖】std.net TLS ALPN、http2_* HPACK/帧层。
 */

/** 网络 h2 不可用（无 TLS/ALPN 未协商 h2）。 */
#define HTTP2_ERR_NETWORK (-1231)

/** h2c URL 客户端烟测（定义于 http_glue.c；network smoke 调用）。 */
int32_t http_h2c_client_smoke_c(void);

/** 连接池烟测（定义于 conn_pool.inc.c）。 */
int32_t http2_conn_pool_smoke_c(void);
/** 全局池烟测（定义于 global_pool.inc.c）。 */
int32_t http2_global_pool_smoke_c(void);

/** HTTP/2 统一 IO：tls_ctx!=0 走 TLS，否则走 fd 明文。 */
typedef struct {
    int32_t fd;
    int64_t tls_ctx;
} io_t;

/** TLS 写全部字节；失败 -1。 */
static int32_t tls_write_all(int64_t tls_ctx, const uint8_t *data, int32_t len) {
    int32_t sent = 0;
    if (tls_ctx == 0 || !data || len <= 0)
        return -1;
    while (sent < len) {
        int32_t n = net_tls_write_c(tls_ctx, data + sent, len - sent);
        if (n <= 0)
            return -1;
        sent += n;
    }
    return 0;
}

/** TLS 读满 need 字节；失败 -1。 */
static int32_t tls_read_exact(int64_t tls_ctx, uint8_t *buf, int32_t need) {
    int32_t got = 0;
    if (tls_ctx == 0 || !buf || need <= 0)
        return -1;
    while (got < need) {
        int32_t n = net_tls_read_c(tls_ctx, buf + got, need - got);
        if (n <= 0)
            return -1;
        got += n;
    }
    return 0;
}

/** 明文 fd 写全部字节；失败 -1。 */
static int32_t plain_write_all(int32_t fd, const uint8_t *data, int32_t len) {
    int32_t sent = 0;
    if (fd < 0 || !data || len <= 0)
        return -1;
    while (sent < len) {
#if defined(_WIN32) || defined(_WIN64)
        int n = send((SOCKET)fd, (const char *)data + sent, len - sent, 0);
#else
        ssize_t n = send(fd, data + sent, (size_t)(len - sent), 0);
#endif
        if (n <= 0)
            return -1;
        sent += (int32_t)n;
    }
    return 0;
}

/** 明文 fd 读满 need 字节；失败 -1。 */
static int32_t plain_read_exact(int32_t fd, uint8_t *buf, int32_t need) {
    int32_t got = 0;
    if (fd < 0 || !buf || need <= 0)
        return -1;
    while (got < need) {
#if defined(_WIN32) || defined(_WIN64)
        int n = recv((SOCKET)fd, (char *)buf + got, need - got, 0);
#else
        ssize_t n = recv(fd, buf + got, (size_t)(need - got), 0);
#endif
        if (n <= 0)
            return -1;
        got += (int32_t)n;
    }
    return 0;
}

/** 统一 IO 写；失败 -1。 */
static int32_t io_write_all(io_t *io, const uint8_t *data, int32_t len) {
    if (!io || !data || len <= 0)
        return -1;
    if (io->tls_ctx != 0)
        return tls_write_all(io->tls_ctx, data, len);
    return plain_write_all(io->fd, data, len);
}

/** 统一 IO 读；失败 -1。 */
static int32_t io_read_exact(io_t *io, uint8_t *buf, int32_t need) {
    if (!io || !buf || need <= 0)
        return -1;
    if (io->tls_ctx != 0)
        return tls_read_exact(io->tls_ctx, buf, need);
    return plain_read_exact(io->fd, buf, need);
}

/** method_u8 是否携带请求体（POST/PUT/PATCH）。 */
static int32_t method_has_body(uint8_t method_u8) {
    return (method_u8 == 1 || method_u8 == 3 || method_u8 == 5) ? 1 : 0;
}

/** h2 over TLS 网络栈是否可用（TLS 后端链入）。 */
int32_t http2_network_is_available_c(void) {
    return net_tls_is_available_c();
}

/** cleartext h2c TCP 会话 API 是否可用（v8）。 */
int32_t http2_h2c_is_available_c(void) {
    return 1;
}

/**
 * 读取指定 stream 响应并格式化为 HTTP/1 风格；同时收集 server push DATA。
 */
static int32_t read_response_stream_io(io_t *io, int32_t target_stream_id, uint8_t *out,
                                             int32_t out_cap, peer_settings_t *peer_out,
                                             int32_t *out_goaway_seen) {
    uint8_t hdr[9];
    uint8_t payload[HTTP2_DEFAULT_MAX_FRAME_SIZE];
    uint8_t body_acc[32768];
    uint8_t ack[16];
    uint8_t wu_frame[16];
    flow_recv_state_t recv;
    int32_t body_len = 0;
    int32_t status = 0;
    int32_t got_status = 0;
    int32_t stream_done = 0;
    int32_t push_promised = 0;
    int32_t round;
    int32_t hdr_len;
    int32_t resp_len;
    int32_t ftype;
    int32_t fflags;
    int32_t stream_id;
    int32_t plen;
    int32_t wu_len;

    http2_push_last_reset_c();
    http2_flow_recv_init_c(&recv);
    if (out_goaway_seen)
        *out_goaway_seen = 0;

    for (round = 0; round < 64 && !stream_done; round++) {
        if (io_read_exact(io, hdr, 9) != 0)
            return HTTP2_ERR_NETWORK;
        if (http2_parse_frame_header_c(hdr, 9, &ftype, &fflags, &stream_id, &plen) != 0)
            return -1;
        if (plen < 0 || plen > (int32_t)sizeof(payload))
            return -1;
        if (plen > 0) {
            if (io_read_exact(io, payload, plen) != 0)
                return HTTP2_ERR_NETWORK;
        }

        if (ftype == HTTP2_TYPE_SETTINGS) {
            if ((fflags & HTTP2_FLAG_ACK) == 0) {
                if (peer_out != NULL && plen > 0)
                    http2_peer_settings_consume_payload_c(payload, plen, peer_out);
                if (http2_build_settings_ack_c(ack, (int32_t)sizeof(ack)) != 9)
                    return -1;
                if (io_write_all(io, ack, 9) != 0)
                    return HTTP2_ERR_NETWORK;
            }
            continue;
        }

        if (ftype == HTTP2_TYPE_GOAWAY) {
            if (out_goaway_seen)
                *out_goaway_seen = 1;
            if (stream_done)
                break;
            return HTTP2_ERR_GOAWAY;
        }

        if (ftype == HTTP2_TYPE_RST_STREAM && stream_id == target_stream_id) {
            return HTTP2_ERR_RST_STREAM;
        }

        if (ftype == HTTP2_TYPE_PUSH_PROMISE) {
            if (http2_parse_push_promise_stream_c(payload, plen, &push_promised) == 0)
                g_http2_push_last.promised_stream_id = push_promised;
            continue;
        }

        if (push_promised > 0 && stream_id == push_promised) {
            if (ftype == HTTP2_TYPE_DATA && plen > 0) {
                if (http2_flow_recv_on_data_c(&recv, plen) != 0)
                    return -1;
                if (http2_push_collect_data_c(push_promised, stream_id, payload, plen, &push_promised,
                                             g_http2_push_body, HTTP2_PUSH_BODY_MAX,
                                             &g_http2_push_body_len) < 0)
                    return -1;
                g_http2_push_last.body_len = g_http2_push_body_len;
                wu_len = http2_flow_recv_release_c(&recv, stream_id, plen, wu_frame,
                                                   (int32_t)sizeof(wu_frame));
                if (wu_len > 0) {
                    if (io_write_all(io, wu_frame, wu_len) != 0)
                        return HTTP2_ERR_NETWORK;
                }
            }
            continue;
        }

        if (stream_id != target_stream_id)
            continue;

        if (ftype == HTTP2_TYPE_HEADERS) {
            if (http2_hpack_decode_status_c(payload, plen, &status) == 0)
                got_status = 1;
            if ((fflags & HTTP2_FLAG_END_STREAM) != 0)
                stream_done = 1;
            continue;
        }

        if (ftype == HTTP2_TYPE_DATA) {
            if (body_len + plen > (int32_t)sizeof(body_acc))
                return -1;
            if (plen > 0) {
                if (http2_flow_recv_on_data_c(&recv, plen) != 0)
                    return -1;
                memcpy(body_acc + body_len, payload, (size_t)plen);
                wu_len = http2_flow_recv_release_c(&recv, stream_id, plen, wu_frame,
                                                   (int32_t)sizeof(wu_frame));
                if (wu_len > 0) {
                    if (io_write_all(io, wu_frame, wu_len) != 0)
                        return HTTP2_ERR_NETWORK;
                }
            }
            body_len += plen;
            if ((fflags & HTTP2_FLAG_END_STREAM) != 0)
                stream_done = 1;
        }
    }

    if (!got_status)
        status = 200;

    hdr_len = snprintf((char *)out, (size_t)out_cap, "HTTP/1.1 %03d OK\r\n\r\n", status);
    if (hdr_len <= 0 || hdr_len >= out_cap)
        return -1;
    if (body_len > 0) {
        if (hdr_len + body_len > out_cap)
            return -1;
        memcpy(out + hdr_len, body_acc, (size_t)body_len);
    }
    resp_len = hdr_len + body_len;
    return resp_len;
}

#include "http2_conn_reuse.inc"
#include "http2_server.inc"

/**
 * 在已建立 h2 的 IO 上执行单次请求（内部走 conn handshake + request）。
 */
static int32_t http2_session_request_io_c(io_t *io, uint8_t method_u8, const uint8_t *authority,
                                          int32_t authority_len, const uint8_t *path, int32_t path_len,
                                          const uint8_t *body, int32_t body_len, uint8_t *out,
                                          int32_t out_cap) {
    conn_t conn;
    int32_t rc;

    if (!io || !authority || authority_len <= 0 || !path || path_len <= 0 || !out || out_cap <= 64)
        return -1;
    if (io->tls_ctx == 0 && io->fd < 0)
        return -1;

    http2_conn_init_c(&conn);
    conn.fd = io->fd;
    conn.tls_ctx = io->tls_ctx;
    conn.is_https = (io->tls_ctx != 0) ? 1 : 0;

    rc = http2_conn_handshake_c(&conn);
    if (rc != 0)
        return rc;
    return http2_conn_request_c(&conn, method_u8, authority, authority_len, path, path_len, body,
                              body_len, out, out_cap);
}

/**
 * 在已协商 h2 的 TLS 连接上执行请求（GET/POST/HEAD/…）。
 */
int32_t http2_session_request_tls_c(int64_t tls_ctx, uint8_t method_u8, const uint8_t *authority,
                                  int32_t authority_len, const uint8_t *path, int32_t path_len,
                                  const uint8_t *body, int32_t body_len, uint8_t *out,
                                  int32_t out_cap) {
    io_t io;
    if (tls_ctx == 0)
        return -1;
    io.fd = -1;
    io.tls_ctx = tls_ctx;
    return http2_session_request_io_c(&io, method_u8, authority, authority_len, path, path_len, body,
                                    body_len, out, out_cap);
}

/**
 * cleartext h2c：在已连接 TCP fd 上发 preface+请求（无 TLS）。
 * fd 须为已 connect 的 TCP socket。
 */
int32_t http2_session_request_h2c_c(int32_t fd, uint8_t method_u8, const uint8_t *authority,
                                    int32_t authority_len, const uint8_t *path, int32_t path_len,
                                    const uint8_t *body, int32_t body_len, uint8_t *out,
                                    int32_t out_cap) {
    io_t io;
    if (fd < 0)
        return -1;
    io.fd = fd;
    io.tls_ctx = 0;
    return http2_session_request_io_c(&io, method_u8, authority, authority_len, path, path_len, body,
                                    body_len, out, out_cap);
}

/** 兼容：GET 专用别名。 */
int32_t http2_session_get_tls_c(int64_t tls_ctx, const uint8_t *authority, int32_t authority_len,
                                const uint8_t *path, int32_t path_len, uint8_t *out, int32_t out_cap) {
    return http2_session_request_tls_c(tls_ctx, 0, authority, authority_len, path, path_len, NULL, 0,
                                     out, out_cap);
}

/** h2c 明文会话 C 烟测（无效 fd 须失败）；0 通过。 */
int32_t http2_h2c_network_smoke_c(void) {
    uint8_t preface[32];
    if (http2_h2c_is_available_c() != 1)
        return 1;
    if (http2_h2c_session_begin_c(preface, 32) != HTTP2_PREFACE_LEN)
        return 2;
    if (http2_session_request_h2c_c(-1, 0, (const uint8_t *)"example.com", 11, (const uint8_t *)"/",
                                    1, NULL, 0, preface, 32) != -1)
        return 3;
    if (http2_push_network_smoke_c() != 0)
        return 4;
    return 0;
}

/** 网络层烟测（ALPN wire + HPACK + 动态表；不建连）。 */
int32_t http2_network_smoke_c(void) {
    uint8_t wire[16];
    if (net_tls_alpn_h2_http1_wire_c(wire, 16) != 12)
        return 1;
    if (http2_hpack_smoke_c() != 0)
        return 2;
    if (http2_hpack_dyn_smoke_c() != 0)
        return 3;
    if (http2_hpack_huffman_smoke_c() != 0)
        return 4;
    if (http2_flow_control_smoke_c() != 0)
        return 5;
    if (http2_flow_state_smoke_c() != 0)
        return 6;
    if (http2_flow_recv_smoke_c() != 0)
        return 7;
    if (http2_push_h2c_smoke_c() != 0)
        return 8;
    if (http2_h2c_network_smoke_c() != 0)
        return 9;
    if (http_h2c_client_smoke_c() != 0)
        return 10;
    if (http2_settings_smoke_c() != 0)
        return 11;
    if (http2_multistream_client_smoke_c() != 0)
        return 12;
    if (http2_conn_reuse_smoke_c() != 0)
        return 13;
    if (http2_conn_pool_smoke_c() != 0)
        return 14;
    if (http2_global_pool_smoke_c() != 0)
        return 15;
    if (http2_server_smoke_c() != 0)
        return 16;
    return 0;
}
