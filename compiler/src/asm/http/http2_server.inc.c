/**
 * std/http/server.inc.c — HTTP/2 h2c server 端 v1（STD-HTTP-H2-v14）
 *
 * 【文件职责】listen + accept 后读 client preface/SETTINGS，处理单 GET HEADERS 并回 200+body。
 * 由 network.inc.c 末尾 #include（复用 io_* 静态 IO 辅助）。
 */

#if !defined(_WIN32) && !defined(_WIN64)
#include <poll.h>
#ifndef _WIN32
#include <sys/wait.h>
#endif
#endif

/** h2c server 协议错误（-1240）。 */
#define HTTP2_ERR_SERVER (-1240)

/** h2 over TLS server 不可用 / ALPN 非 h2（-1241）。 */
#define HTTP2_ERR_SERVER_TLS (-1241)

/** 读 client SETTINGS 并 ACK；成功 0。 */
static int32_t http2_server_read_client_settings_c(io_t *io, peer_settings_t *peer) {
    uint8_t hdr[9];
    uint8_t payload[256];
    uint8_t ack[16];
    int32_t round;
    int32_t ftype;
    int32_t fflags;
    int32_t stream_id;
    int32_t plen;

    if (!io || !peer)
        return -1;
    http2_peer_settings_init_c(peer);
    for (round = 0; round < 16; round++) {
        if (io_read_exact(io, hdr, 9) != 0)
            return HTTP2_ERR_SERVER;
        if (http2_parse_frame_header_c(hdr, 9, &ftype, &fflags, &stream_id, &plen) != 0)
            return HTTP2_ERR_SERVER;
        if (plen < 0 || plen > (int32_t)sizeof(payload))
            return HTTP2_ERR_SERVER;
        if (plen > 0) {
            if (io_read_exact(io, payload, plen) != 0)
                return HTTP2_ERR_SERVER;
        }
        if (ftype == HTTP2_TYPE_SETTINGS) {
            if ((fflags & HTTP2_FLAG_ACK) == 0) {
                if (plen > 0)
                    http2_peer_settings_consume_payload_c(payload, plen, peer);
                if (http2_build_settings_ack_c(ack, (int32_t)sizeof(ack)) != 9)
                    return HTTP2_ERR_SERVER;
                if (io_write_all(io, ack, 9) != 0)
                    return HTTP2_ERR_SERVER;
                return 0;
            }
        }
    }
    return HTTP2_ERR_SERVER;
}

/** 发送 server SETTINGS 帧；成功 0。 */
static int32_t http2_server_send_settings_c(io_t *io) {
    uint8_t ssettings[64];
    int32_t ss_len;
    if (!io)
        return -1;
    ss_len = http2_build_server_settings_c(ssettings, (int32_t)sizeof(ssettings));
    if (ss_len > 0) {
        if (io_write_all(io, ssettings, ss_len) != 0)
            return HTTP2_ERR_SERVER;
    }
    return 0;
}

/** 服务端 h2c 握手：读 preface + client SETTINGS 并 ACK，再发 server SETTINGS。 */
static int32_t http2_server_handshake_h2c_c(int32_t fd, peer_settings_t *peer) {
    io_t io;
    uint8_t preface[32];
    int32_t rc;

    if (fd < 0 || !peer)
        return -1;
    io.fd = fd;
    io.tls_ctx = 0;
    if (io_read_exact(&io, preface, HTTP2_PREFACE_LEN) != 0)
        return HTTP2_ERR_SERVER;
    if (http2_is_connection_preface_c(preface, HTTP2_PREFACE_LEN) == 0)
        return HTTP2_ERR_SERVER;
    rc = http2_server_read_client_settings_c(&io, peer);
    if (rc != 0)
        return rc;
    return http2_server_send_settings_c(&io);
}

/** 服务端 h2 over TLS 握手：无 preface，直接 SETTINGS 交换。 */
static int32_t http2_server_handshake_h2_tls_c(int64_t tls_ctx, peer_settings_t *peer) {
    io_t io;
    int32_t rc;
    if (tls_ctx == 0 || !peer)
        return -1;
    if (net_tls_alpn_is_h2_c(tls_ctx) == 0)
        return HTTP2_ERR_SERVER_TLS;
    io.fd = -1;
    io.tls_ctx = tls_ctx;
    rc = http2_server_read_client_settings_c(&io, peer);
    if (rc != 0)
        return rc;
    return http2_server_send_settings_c(&io);
}

/** 读 client HEADERS 请求帧；成功 0 并写出 stream_id 与 HPACK payload。 */
static int32_t http2_server_read_request_headers_c(io_t *io, int32_t *out_stream_id,
                                                     uint8_t *hpack_out, int32_t hpack_cap,
                                                     int32_t *out_hpack_len) {
    uint8_t hdr[9];
    uint8_t payload[4096];
    int32_t round;
    int32_t ftype;
    int32_t fflags;
    int32_t stream_id;
    int32_t plen;

    if (!io || !out_stream_id || !hpack_out || !out_hpack_len || hpack_cap <= 0)
        return -1;
    *out_hpack_len = 0;

    for (round = 0; round < 32; round++) {
        if (io_read_exact(io, hdr, 9) != 0)
            return HTTP2_ERR_SERVER;
        if (http2_parse_frame_header_c(hdr, 9, &ftype, &fflags, &stream_id, &plen) != 0)
            return HTTP2_ERR_SERVER;
        if (plen < 0 || plen > (int32_t)sizeof(payload))
            return HTTP2_ERR_SERVER;
        if (plen > 0) {
            if (io_read_exact(io, payload, plen) != 0)
                return HTTP2_ERR_SERVER;
        }
        if (ftype == HTTP2_TYPE_SETTINGS) {
            if ((fflags & HTTP2_FLAG_ACK) == 0) {
                uint8_t ack[16];
                if (http2_build_settings_ack_c(ack, (int32_t)sizeof(ack)) != 9)
                    return HTTP2_ERR_SERVER;
                if (io_write_all(io, ack, 9) != 0)
                    return HTTP2_ERR_SERVER;
            }
            continue;
        }
        if (ftype == HTTP2_TYPE_PING) {
            uint8_t pong[32];
            int32_t pn;
            if ((fflags & HTTP2_FLAG_ACK) != 0)
                continue;
            if (plen != HTTP2_PING_PAYLOAD_SIZE)
                return HTTP2_ERR_SERVER;
            pn = http2_build_ping_ack_c(payload, pong, (int32_t)sizeof(pong));
            if (pn <= 0)
                return HTTP2_ERR_SERVER;
            if (io_write_all(io, pong, pn) != 0)
                return HTTP2_ERR_SERVER;
            continue;
        }
        if (ftype == HTTP2_TYPE_HEADERS && stream_id > 0) {
            if (plen > hpack_cap)
                return HTTP2_ERR_SERVER;
            if (plen > 0)
                memcpy(hpack_out, payload, (size_t)plen);
            *out_hpack_len = plen;
            *out_stream_id = stream_id;
            return 0;
        }
    }
    return HTTP2_ERR_SERVER;
}

/** 按对端 MAX_FRAME_SIZE 分片发送 DATA 帧；成功 0。 */
static int32_t http2_server_write_data_capped_c(io_t *io, int32_t stream_id,
                                                  const uint8_t *body, int32_t body_len,
                                                  int32_t max_frame_size) {
    uint8_t frame_buf[HTTP2_DEFAULT_MAX_FRAME_SIZE + HTTP2_FRAME_HEADER_SIZE];
    int32_t limit;
    int32_t buf_payload_max;
    int32_t off;
    int32_t chunk;
    int32_t flags;
    int32_t flen;

    if (!io || stream_id <= 0)
        return -1;
    if (body_len < 0)
        return -1;
    if (body_len > 0 && !body)
        return -1;
    if (body_len == 0)
        return 0;

    limit = http2_frame_payload_limit_c(max_frame_size);
    buf_payload_max = (int32_t)sizeof(frame_buf) - HTTP2_FRAME_HEADER_SIZE;
    off = 0;
    while (off < body_len) {
        chunk = body_len - off;
        if (chunk > limit)
            chunk = limit;
        if (chunk > buf_payload_max)
            chunk = buf_payload_max;
        flags = 0;
        if (off + chunk >= body_len)
            flags = HTTP2_FLAG_END_STREAM;
        flen = http2_build_data_frame_c(stream_id, flags, body + off, chunk, frame_buf,
                                        (int32_t)sizeof(frame_buf));
        if (flen <= 0)
            return HTTP2_ERR_SERVER;
        if (io_write_all(io, frame_buf, flen) != 0)
            return HTTP2_ERR_SERVER;
        off += chunk;
    }
    return 0;
}

/** 向 client 发送 200 HEADERS + DATA 响应（使用 server HPACK 动态表编码 :status）。 */
static int32_t http2_server_send_response_c(io_t *io, int32_t stream_id, const uint8_t *body,
                                              int32_t body_len, hpack_server_dyn_t *enc,
                                              int32_t max_frame_size) {
    uint8_t hpack[16];
    uint8_t frame_buf[512];
    int32_t hlen;
    int32_t hdr_frame_len;
    int32_t hdr_flags;

    if (!io || stream_id <= 0 || !enc)
        return -1;
    if (body_len < 0)
        body_len = 0;
    if (body_len > 0 && !body)
        return -1;

    hlen = http2_hpack_server_encode_status_c(enc, 200, hpack, (int32_t)sizeof(hpack));
    if (hlen <= 0)
        return HTTP2_ERR_SERVER;

    hdr_flags = HTTP2_FLAG_END_HEADERS;
    if (body_len == 0)
        hdr_flags |= HTTP2_FLAG_END_STREAM;
    hdr_frame_len = http2_build_headers_frame_c(stream_id, hdr_flags, hpack, hlen, frame_buf,
                                                (int32_t)sizeof(frame_buf));
    if (hdr_frame_len <= 0)
        return HTTP2_ERR_SERVER;
    if (io_write_all(io, frame_buf, hdr_frame_len) != 0)
        return HTTP2_ERR_SERVER;

    if (body_len > 0) {
        if (http2_server_write_data_capped_c(io, stream_id, body, body_len, max_frame_size) != 0)
            return HTTP2_ERR_SERVER;
    }
    return 0;
}

#include "http2_server_push.inc.c"

/**
 * 对已 handshake h2c 连接：发 PUSH_PROMISE + push body，再回主 GET 200+body。
 */
int32_t http2_server_serve_h2c_with_push_c(int32_t client_fd, const uint8_t *body, int32_t body_len,
                                           const uint8_t *authority, int32_t authority_len,
                                           const uint8_t *push_path, int32_t push_path_len,
                                           const uint8_t *push_body, int32_t push_body_len) {
    io_t io;
    peer_settings_t peer;
    uint8_t hpack[512];
    int32_t stream_id = 0;
    int32_t hpack_len = 0;
    int32_t is_get = 0;
    int32_t promised_id;
    int32_t rc;

    if (client_fd < 0 || !body || body_len < 0 || !authority || authority_len <= 0)
        return -1;
    if (!push_path || push_path_len <= 0 || !push_body || push_body_len <= 0)
        return HTTP2_ERR_SERVER_PUSH;

    rc = http2_server_handshake_h2c_c(client_fd, &peer);
    if (rc != 0)
        return rc;

    io.fd = client_fd;
    io.tls_ctx = 0;
    rc = http2_server_read_request_headers_c(&io, &stream_id, hpack, (int32_t)sizeof(hpack),
                                             &hpack_len);
    if (rc != 0)
        return rc;
    rc = http2_hpack_decode_get_request_c(hpack, hpack_len, &is_get, NULL, 0, NULL);
    if (rc != 0 || is_get == 0)
        return HTTP2_ERR_SERVER;

    promised_id = stream_id + 1;
    {
        hpack_server_dyn_t enc;
        http2_hpack_server_dyn_init_c(&enc, &peer);
        rc = http2_server_send_push_respecting_peer_c(&io, &peer, stream_id, promised_id, authority,
                                                      authority_len, push_path, push_path_len,
                                                      push_body, push_body_len, 0, &enc);
        if (rc != 0)
            return rc;
        return http2_server_send_response_c(&io, stream_id, body, body_len, &enc,
                                            http2_peer_settings_max_frame_size_c(&peer));
    }
}

/** accept 一个 h2c 连接并 serve 带 push 的单次 GET；成功 0。 */
int32_t http2_serve_h2c_one_with_push_c(int32_t listener_fd, const uint8_t *body, int32_t body_len,
                                          const uint8_t *authority, int32_t authority_len,
                                          const uint8_t *push_path, int32_t push_path_len,
                                          const uint8_t *push_body, int32_t push_body_len,
                                          uint32_t timeout_ms) {
#if defined(_WIN32) || defined(_WIN64)
    (void)timeout_ms;
    {
        SOCKET client = accept((SOCKET)listener_fd, NULL, NULL);
        int32_t r;
        if (client == INVALID_SOCKET)
            return -1;
        r = http2_server_serve_h2c_with_push_c((int32_t)client, body, body_len, authority,
                                               authority_len, push_path, push_path_len, push_body,
                                               push_body_len);
        SHUX_HTTP_CLOSE((int)client);
        return r;
    }
#else
    struct pollfd pfd;
    int client;
    int32_t r;
    if (listener_fd < 0)
        return -1;
    if (timeout_ms > 0) {
        pfd.fd = listener_fd;
        pfd.events = POLLIN;
        pfd.revents = 0;
        if (poll(&pfd, 1, (int)timeout_ms) <= 0)
            return -1;
    }
    client = (int)accept(listener_fd, NULL, NULL);
    if (client < 0)
        return -1;
    r = http2_server_serve_h2c_with_push_c(client, body, body_len, authority, authority_len,
                                           push_path, push_path_len, push_body, push_body_len);
    SHUX_HTTP_CLOSE(client);
    return r;
#endif
}

/**
 * 对已 TLS 握手且 ALPN=h2 的连接：发 PUSH_PROMISE + push body，再回主 GET 200+body。
 */
int32_t http2_server_serve_h2_with_push_c(int64_t tls_ctx, const uint8_t *body, int32_t body_len,
                                          const uint8_t *authority, int32_t authority_len,
                                          const uint8_t *push_path, int32_t push_path_len,
                                          const uint8_t *push_body, int32_t push_body_len) {
    io_t io;
    peer_settings_t peer;
    uint8_t hpack[512];
    int32_t stream_id = 0;
    int32_t hpack_len = 0;
    int32_t is_get = 0;
    int32_t promised_id;
    int32_t rc;

    if (tls_ctx == 0 || !body || body_len < 0 || !authority || authority_len <= 0)
        return -1;
    if (!push_path || push_path_len <= 0 || !push_body || push_body_len <= 0)
        return HTTP2_ERR_SERVER_PUSH;

    rc = http2_server_handshake_h2_tls_c(tls_ctx, &peer);
    if (rc != 0)
        return rc;

    io.fd = -1;
    io.tls_ctx = tls_ctx;
    rc = http2_server_read_request_headers_c(&io, &stream_id, hpack, (int32_t)sizeof(hpack),
                                             &hpack_len);
    if (rc != 0)
        return rc;
    rc = http2_hpack_decode_get_request_c(hpack, hpack_len, &is_get, NULL, 0, NULL);
    if (rc != 0 || is_get == 0)
        return HTTP2_ERR_SERVER;

    promised_id = stream_id + 1;
    {
        hpack_server_dyn_t enc;
        http2_hpack_server_dyn_init_c(&enc, &peer);
        rc = http2_server_send_push_respecting_peer_c(&io, &peer, stream_id, promised_id, authority,
                                                      authority_len, push_path, push_path_len,
                                                      push_body, push_body_len, 1, &enc);
        if (rc != 0)
            return rc;
        return http2_server_send_response_c(&io, stream_id, body, body_len, &enc,
                                            http2_peer_settings_max_frame_size_c(&peer));
    }
}

/**
 * accept + TLS 服务端握手 + h2 serve 带 push 的单次 GET；srv_ctx 来自 tls_server_ctx_create。
 */
int32_t http2_serve_h2_one_with_push_c(int32_t listener_fd, int64_t srv_ctx_h, const uint8_t *body,
                                       int32_t body_len, const uint8_t *authority,
                                       int32_t authority_len, const uint8_t *push_path,
                                       int32_t push_path_len, const uint8_t *push_body,
                                       int32_t push_body_len, uint32_t timeout_ms) {
#if defined(_WIN32) || defined(_WIN64)
    (void)timeout_ms;
    {
        SOCKET client = accept((SOCKET)listener_fd, NULL, NULL);
        int64_t tls_ctx;
        int32_t r;
        if (client == INVALID_SOCKET || srv_ctx_h == 0)
            return -1;
        tls_ctx = net_tls_accept_server_c(srv_ctx_h, (int32_t)client);
        if (tls_ctx == 0) {
            SHUX_HTTP_CLOSE((int)client);
            return HTTP2_ERR_SERVER_TLS;
        }
        r = http2_server_serve_h2_with_push_c(tls_ctx, body, body_len, authority, authority_len,
                                                push_path, push_path_len, push_body, push_body_len);
        net_tls_close_c(tls_ctx);
        SHUX_HTTP_CLOSE((int)client);
        return r;
    }
#else
    struct pollfd pfd;
    int client;
    int64_t tls_ctx;
    int32_t r;
    if (listener_fd < 0 || srv_ctx_h == 0)
        return -1;
    if (timeout_ms > 0) {
        pfd.fd = listener_fd;
        pfd.events = POLLIN;
        pfd.revents = 0;
        if (poll(&pfd, 1, (int)timeout_ms) <= 0)
            return -1;
    }
    client = (int)accept(listener_fd, NULL, NULL);
    if (client < 0)
        return -1;
    tls_ctx = net_tls_accept_server_c(srv_ctx_h, client);
    if (tls_ctx == 0) {
        SHUX_HTTP_CLOSE(client);
        return HTTP2_ERR_SERVER_TLS;
    }
    r = http2_server_serve_h2_with_push_c(tls_ctx, body, body_len, authority, authority_len,
                                          push_path, push_path_len, push_body, push_body_len);
    net_tls_close_c(tls_ctx);
    SHUX_HTTP_CLOSE(client);
    return r;
#endif
}

/**
 * 在已握手连接上顺序处理至多 max_requests 个 GET 并各回 200+body。
 * 成功返回已 serve 的 stream 数（>=1）；协议错误 HTTP2_ERR_SERVER；读失败且 0 次则负码。
 */
static int32_t http2_server_serve_io_multi_c(io_t *io, const peer_settings_t *peer,
                                             const uint8_t *body, int32_t body_len,
                                             int32_t max_requests) {
    uint8_t hpack[512];
    int32_t stream_id = 0;
    int32_t hpack_len = 0;
    int32_t is_get = 0;
    int32_t served = 0;
    int32_t rc;
    hpack_server_dyn_t enc;

    if (!io || !body || body_len < 0)
        return -1;
    if (max_requests <= 0)
        max_requests = 1;
    http2_hpack_server_dyn_init_c(&enc, peer);
    {
        int32_t max_frame = http2_peer_settings_max_frame_size_c(peer);

        while (served < max_requests) {
            rc = http2_server_read_request_headers_c(io, &stream_id, hpack, (int32_t)sizeof(hpack),
                                                     &hpack_len);
            if (rc != 0) {
                if (served > 0)
                    return served;
                return rc;
            }
            rc = http2_hpack_decode_get_request_c(hpack, hpack_len, &is_get, NULL, 0, NULL);
            if (rc != 0 || is_get == 0)
                return HTTP2_ERR_SERVER;
            rc = http2_server_send_response_c(io, stream_id, body, body_len, &enc, max_frame);
            if (rc != 0)
                return rc;
            served++;
        }
    }
    return served;
}

/**
 * 在已握手连接上顺序处理至多 max_requests 个 GET：每个请求先发 PUSH_PROMISE + push body，再回主 200+body。
 * 成功返回已 serve 的 stream 数（>=1）；协议/push 参数错误负码。
 */
static int32_t http2_server_serve_io_multi_with_push_c(
    io_t *io, const peer_settings_t *peer, const uint8_t *body, int32_t body_len,
    int32_t max_requests, const uint8_t *authority, int32_t authority_len, const uint8_t *push_path,
    int32_t push_path_len, const uint8_t *push_body, int32_t push_body_len, int32_t is_https) {
    uint8_t hpack[512];
    int32_t stream_id = 0;
    int32_t hpack_len = 0;
    int32_t is_get = 0;
    int32_t promised_id;
    int32_t served = 0;
    int32_t rc;
    hpack_server_dyn_t enc;

    if (!io || !body || body_len < 0 || !authority || authority_len <= 0)
        return -1;
    if (!push_path || push_path_len <= 0 || !push_body || push_body_len <= 0)
        return HTTP2_ERR_SERVER_PUSH;
    if (max_requests <= 0)
        max_requests = 1;

    http2_hpack_server_dyn_init_c(&enc, peer);
    {
        int32_t max_frame = http2_peer_settings_max_frame_size_c(peer);

        while (served < max_requests) {
            rc = http2_server_read_request_headers_c(io, &stream_id, hpack, (int32_t)sizeof(hpack),
                                                     &hpack_len);
            if (rc != 0) {
                if (served > 0)
                    return served;
                return rc;
            }
            rc = http2_hpack_decode_get_request_c(hpack, hpack_len, &is_get, NULL, 0, NULL);
            if (rc != 0 || is_get == 0)
                return HTTP2_ERR_SERVER;
            promised_id = stream_id + 1;
            rc = http2_server_send_push_respecting_peer_c(io, peer, stream_id, promised_id, authority,
                                                          authority_len, push_path, push_path_len,
                                                          push_body, push_body_len, is_https, &enc);
            if (rc != 0)
                return rc;
            rc = http2_server_send_response_c(io, stream_id, body, body_len, &enc, max_frame);
            if (rc != 0)
                return rc;
            served++;
        }
    }
    return served;
}

/** 单次 GET serve（兼容 v14：成功 0）。 */
static int32_t http2_server_serve_io_one_c(io_t *io, const peer_settings_t *peer,
                                             const uint8_t *body, int32_t body_len) {
    int32_t n = http2_server_serve_io_multi_c(io, peer, body, body_len, 1);
    if (n == 1)
        return 0;
    return n;
}

/**
 * 对已 accept 的 h2c 连接处理单次 GET 请求并回 200+body。
 * 非 GET 或协议错误返回 HTTP2_ERR_SERVER(-1240) 或 -1。
 */
int32_t http2_server_serve_h2c_c(int32_t client_fd, const uint8_t *body, int32_t body_len) {
    io_t io;
    peer_settings_t peer;
    int32_t rc;

    if (client_fd < 0 || !body || body_len < 0)
        return -1;

    rc = http2_server_handshake_h2c_c(client_fd, &peer);
    if (rc != 0)
        return rc;

    io.fd = client_fd;
    io.tls_ctx = 0;
    return http2_server_serve_io_one_c(&io, &peer, body, body_len);
}

/**
 * 向 client 发送 GOAWAY 帧（连接优雅关闭前）。
 * 成功 0；IO 失败 HTTP2_ERR_SERVER(-1240)。
 */
static int32_t http2_server_send_goaway_c(io_t *io, int32_t last_stream_id, int32_t error_code) {
    uint8_t frame[32];
    int32_t n;

    if (!io)
        return -1;
    n = http2_build_goaway_c(last_stream_id, error_code, frame, (int32_t)sizeof(frame));
    if (n <= 0)
        return HTTP2_ERR_SERVER;
    if (io_write_all(io, frame, n) != 0)
        return HTTP2_ERR_SERVER;
    return 0;
}

/**
 * h2c 单次 GET serve 后向 client 发 GOAWAY（NO_ERROR）。
 * last_stream_id 通常为已处理的最大 client stream id（如 1）。
 */
int32_t http2_server_serve_h2c_with_goaway_c(int32_t client_fd, const uint8_t *body, int32_t body_len,
                                              int32_t last_stream_id) {
    io_t io;
    peer_settings_t peer;
    int32_t rc;

    if (client_fd < 0 || !body || body_len < 0)
        return -1;

    rc = http2_server_handshake_h2c_c(client_fd, &peer);
    if (rc != 0)
        return rc;

    io.fd = client_fd;
    io.tls_ctx = 0;
    rc = http2_server_serve_io_one_c(&io, &peer, body, body_len);
    if (rc != 0)
        return rc;
    return http2_server_send_goaway_c(&io, last_stream_id, HTTP2_GOAWAY_NO_ERROR);
}

/**
 * 对已 handshake 的 h2c 连接顺序处理至多 max_requests 个 GET。
 * 成功返回 serve 次数；失败负码 / HTTP2_ERR_SERVER。
 */
int32_t http2_server_serve_h2c_multi_c(int32_t client_fd, const uint8_t *body, int32_t body_len,
                                       int32_t max_requests) {
    io_t io;
    peer_settings_t peer;
    int32_t rc;

    if (client_fd < 0 || !body || body_len < 0)
        return -1;

    rc = http2_server_handshake_h2c_c(client_fd, &peer);
    if (rc != 0)
        return rc;

    io.fd = client_fd;
    io.tls_ctx = 0;
    return http2_server_serve_io_multi_c(&io, &peer, body, body_len, max_requests);
}

/**
 * 对已 handshake 的 h2c 连接顺序处理至多 max_requests 个 GET，每个带 PUSH_PROMISE + push body。
 */
int32_t http2_server_serve_h2c_multi_with_push_c(int32_t client_fd, const uint8_t *body,
                                                 int32_t body_len, int32_t max_requests,
                                                 const uint8_t *authority, int32_t authority_len,
                                                 const uint8_t *push_path, int32_t push_path_len,
                                                 const uint8_t *push_body, int32_t push_body_len) {
    io_t io;
    peer_settings_t peer;
    int32_t rc;

    if (client_fd < 0 || !body || body_len < 0 || !authority || authority_len <= 0)
        return -1;
    if (!push_path || push_path_len <= 0 || !push_body || push_body_len <= 0)
        return HTTP2_ERR_SERVER_PUSH;

    rc = http2_server_handshake_h2c_c(client_fd, &peer);
    if (rc != 0)
        return rc;

    io.fd = client_fd;
    io.tls_ctx = 0;
    return http2_server_serve_io_multi_with_push_c(&io, &peer, body, body_len, max_requests,
                                                   authority, authority_len, push_path,
                                                   push_path_len, push_body, push_body_len, 0);
}

/**
 * accept 一个 h2c 连接、处理单次 GET 并关闭 client。
 * listener_fd 来自 http_listen_c；timeout_ms 为 accept 等待毫秒（0=阻塞）。
 */
int32_t http2_serve_h2c_one_c(int32_t listener_fd, const uint8_t *body, int32_t body_len,
                              uint32_t timeout_ms) {
#if defined(_WIN32) || defined(_WIN64)
    (void)timeout_ms;
    {
        SOCKET client = accept((SOCKET)listener_fd, NULL, NULL);
        int32_t r;
        if (client == INVALID_SOCKET)
            return -1;
        r = http2_server_serve_h2c_c((int32_t)client, body, body_len);
        SHUX_HTTP_CLOSE((int)client);
        return r;
    }
#else
    struct pollfd pfd;
    int client;
    int32_t r;
    if (listener_fd < 0)
        return -1;
    if (timeout_ms > 0) {
        pfd.fd = listener_fd;
        pfd.events = POLLIN;
        pfd.revents = 0;
        if (poll(&pfd, 1, (int)timeout_ms) <= 0)
            return -1;
    }
    client = (int)accept(listener_fd, NULL, NULL);
    if (client < 0)
        return -1;
    r = http2_server_serve_h2c_c(client, body, body_len);
    SHUX_HTTP_CLOSE(client);
    return r;
#endif
}

/**
 * accept 一个 h2c 连接、处理单次 GET、发 GOAWAY 后关闭 client。
 * last_stream_id 为 GOAWAY payload 中的 last processed stream id。
 */
int32_t http2_serve_h2c_one_with_goaway_c(int32_t listener_fd, const uint8_t *body, int32_t body_len,
                                           int32_t last_stream_id, uint32_t timeout_ms) {
#if defined(_WIN32) || defined(_WIN64)
    (void)timeout_ms;
    {
        SOCKET client = accept((SOCKET)listener_fd, NULL, NULL);
        int32_t r;
        if (client == INVALID_SOCKET)
            return -1;
        r = http2_server_serve_h2c_with_goaway_c((int32_t)client, body, body_len, last_stream_id);
        SHUX_HTTP_CLOSE((int)client);
        return r;
    }
#else
    struct pollfd pfd;
    int client;
    int32_t r;
    if (listener_fd < 0)
        return -1;
    if (timeout_ms > 0) {
        pfd.fd = listener_fd;
        pfd.events = POLLIN;
        pfd.revents = 0;
        if (poll(&pfd, 1, (int)timeout_ms) <= 0)
            return -1;
    }
    client = (int)accept(listener_fd, NULL, NULL);
    if (client < 0)
        return -1;
    r = http2_server_serve_h2c_with_goaway_c(client, body, body_len, last_stream_id);
    SHUX_HTTP_CLOSE(client);
    return r;
#endif
}

/**
 * 对已 TLS 握手且 ALPN=h2 的连接处理单次 GET 并回 200+body。
 */
int32_t http2_server_serve_h2_c(int64_t tls_ctx, const uint8_t *body, int32_t body_len) {
    io_t io;
    peer_settings_t peer;
    int32_t rc;

    if (tls_ctx == 0 || !body || body_len < 0)
        return -1;

    rc = http2_server_handshake_h2_tls_c(tls_ctx, &peer);
    if (rc != 0)
        return rc;

    io.fd = -1;
    io.tls_ctx = tls_ctx;
    return http2_server_serve_io_one_c(&io, &peer, body, body_len);
}

/**
 * 对已 TLS+h2 会话顺序处理至多 max_requests 个 GET；成功返回 serve 次数。
 */
int32_t http2_server_serve_h2_multi_c(int64_t tls_ctx, const uint8_t *body, int32_t body_len,
                                      int32_t max_requests) {
    io_t io;
    peer_settings_t peer;
    int32_t rc;

    if (tls_ctx == 0 || !body || body_len < 0)
        return -1;

    rc = http2_server_handshake_h2_tls_c(tls_ctx, &peer);
    if (rc != 0)
        return rc;

    io.fd = -1;
    io.tls_ctx = tls_ctx;
    return http2_server_serve_io_multi_c(&io, &peer, body, body_len, max_requests);
}

/**
 * 对已 TLS+h2 会话顺序处理至多 max_requests 个 GET，每个带 PUSH_PROMISE + push body。
 */
int32_t http2_server_serve_h2_multi_with_push_c(int64_t tls_ctx, const uint8_t *body,
                                                int32_t body_len, int32_t max_requests,
                                                const uint8_t *authority, int32_t authority_len,
                                                const uint8_t *push_path, int32_t push_path_len,
                                                const uint8_t *push_body, int32_t push_body_len) {
    io_t io;
    peer_settings_t peer;
    int32_t rc;

    if (tls_ctx == 0 || !body || body_len < 0 || !authority || authority_len <= 0)
        return -1;
    if (!push_path || push_path_len <= 0 || !push_body || push_body_len <= 0)
        return HTTP2_ERR_SERVER_PUSH;

    rc = http2_server_handshake_h2_tls_c(tls_ctx, &peer);
    if (rc != 0)
        return rc;

    io.fd = -1;
    io.tls_ctx = tls_ctx;
    return http2_server_serve_io_multi_with_push_c(&io, &peer, body, body_len, max_requests,
                                                   authority, authority_len, push_path,
                                                   push_path_len, push_body, push_body_len, 1);
}

/** 从内存 PEM 创建 h2 TLS 服务端上下文；失败 0。 */
int64_t http2_tls_server_ctx_create_c(const uint8_t *cert_pem, int32_t cert_len,
                                      const uint8_t *key_pem, int32_t key_len) {
    if (net_tls_is_available_c() == 0)
        return 0;
    return net_tls_server_ctx_create_mem_c(cert_pem, cert_len, key_pem, key_len);
}

/** 销毁 h2 TLS 服务端上下文。 */
void http2_tls_server_ctx_destroy_c(int64_t srv_ctx_h) {
    net_tls_server_ctx_destroy_c(srv_ctx_h);
}

/**
 * accept + TLS 服务端握手 + h2 serve 单次 GET；srv_ctx 来自 tls_server_ctx_create。
 */
int32_t http2_serve_h2_one_c(int32_t listener_fd, int64_t srv_ctx_h, const uint8_t *body,
                             int32_t body_len, uint32_t timeout_ms) {
#if defined(_WIN32) || defined(_WIN64)
    (void)timeout_ms;
    {
        SOCKET client = accept((SOCKET)listener_fd, NULL, NULL);
        int64_t tls_ctx;
        int32_t r;
        if (client == INVALID_SOCKET || srv_ctx_h == 0)
            return -1;
        tls_ctx = net_tls_accept_server_c(srv_ctx_h, (int32_t)client);
        if (tls_ctx == 0) {
            SHUX_HTTP_CLOSE((int)client);
            return HTTP2_ERR_SERVER_TLS;
        }
        r = http2_server_serve_h2_c(tls_ctx, body, body_len);
        net_tls_close_c(tls_ctx);
        SHUX_HTTP_CLOSE((int)client);
        return r;
    }
#else
    struct pollfd pfd;
    int client;
    int64_t tls_ctx;
    int32_t r;
    if (listener_fd < 0 || srv_ctx_h == 0)
        return -1;
    if (timeout_ms > 0) {
        pfd.fd = listener_fd;
        pfd.events = POLLIN;
        pfd.revents = 0;
        if (poll(&pfd, 1, (int)timeout_ms) <= 0)
            return -1;
    }
    client = (int)accept(listener_fd, NULL, NULL);
    if (client < 0)
        return -1;
    tls_ctx = net_tls_accept_server_c(srv_ctx_h, client);
    if (tls_ctx == 0) {
        SHUX_HTTP_CLOSE(client);
        return HTTP2_ERR_SERVER_TLS;
    }
    r = http2_server_serve_h2_c(tls_ctx, body, body_len);
    net_tls_close_c(tls_ctx);
    SHUX_HTTP_CLOSE(client);
    return r;
#endif
}

/**
 * accept 一个 h2c 连接并顺序 serve 至多 max_requests 个 GET；成功返回 serve 次数。
 */
int32_t http2_serve_h2c_multi_one_c(int32_t listener_fd, const uint8_t *body, int32_t body_len,
                                    int32_t max_requests, uint32_t timeout_ms) {
#if defined(_WIN32) || defined(_WIN64)
    (void)timeout_ms;
    {
        SOCKET client = accept((SOCKET)listener_fd, NULL, NULL);
        int32_t r;
        if (client == INVALID_SOCKET)
            return -1;
        r = http2_server_serve_h2c_multi_c((int32_t)client, body, body_len, max_requests);
        SHUX_HTTP_CLOSE((int)client);
        return r;
    }
#else
    struct pollfd pfd;
    int client;
    int32_t r;
    if (listener_fd < 0)
        return -1;
    if (timeout_ms > 0) {
        pfd.fd = listener_fd;
        pfd.events = POLLIN;
        pfd.revents = 0;
        if (poll(&pfd, 1, (int)timeout_ms) <= 0)
            return -1;
    }
    client = (int)accept(listener_fd, NULL, NULL);
    if (client < 0)
        return -1;
    r = http2_server_serve_h2c_multi_c(client, body, body_len, max_requests);
    SHUX_HTTP_CLOSE(client);
    return r;
#endif
}

/**
 * accept 一个 h2c 连接并顺序 serve 至多 max_requests 个带 push 的 GET；成功返回 serve 次数。
 */
int32_t http2_serve_h2c_multi_one_with_push_c(int32_t listener_fd, const uint8_t *body,
                                              int32_t body_len, int32_t max_requests,
                                              const uint8_t *authority, int32_t authority_len,
                                              const uint8_t *push_path, int32_t push_path_len,
                                              const uint8_t *push_body, int32_t push_body_len,
                                              uint32_t timeout_ms) {
#if defined(_WIN32) || defined(_WIN64)
    (void)timeout_ms;
    {
        SOCKET client = accept((SOCKET)listener_fd, NULL, NULL);
        int32_t r;
        if (client == INVALID_SOCKET)
            return -1;
        r = http2_server_serve_h2c_multi_with_push_c((int32_t)client, body, body_len,
                                                     max_requests, authority, authority_len,
                                                     push_path, push_path_len, push_body,
                                                     push_body_len);
        SHUX_HTTP_CLOSE((int)client);
        return r;
    }
#else
    struct pollfd pfd;
    int client;
    int32_t r;
    if (listener_fd < 0)
        return -1;
    if (timeout_ms > 0) {
        pfd.fd = listener_fd;
        pfd.events = POLLIN;
        pfd.revents = 0;
        if (poll(&pfd, 1, (int)timeout_ms) <= 0)
            return -1;
    }
    client = (int)accept(listener_fd, NULL, NULL);
    if (client < 0)
        return -1;
    r = http2_server_serve_h2c_multi_with_push_c(client, body, body_len, max_requests, authority,
                                                 authority_len, push_path, push_path_len, push_body,
                                                 push_body_len);
    SHUX_HTTP_CLOSE(client);
    return r;
#endif
}

/**
 * accept + TLS + 至多 max_requests 个 GET serve；成功返回 serve 次数。
 */
int32_t http2_serve_h2_multi_one_c(int32_t listener_fd, int64_t srv_ctx_h, const uint8_t *body,
                                   int32_t body_len, int32_t max_requests, uint32_t timeout_ms) {
#if defined(_WIN32) || defined(_WIN64)
    (void)timeout_ms;
    {
        SOCKET client = accept((SOCKET)listener_fd, NULL, NULL);
        int64_t tls_ctx;
        int32_t r;
        if (client == INVALID_SOCKET || srv_ctx_h == 0)
            return -1;
        tls_ctx = net_tls_accept_server_c(srv_ctx_h, (int32_t)client);
        if (tls_ctx == 0) {
            SHUX_HTTP_CLOSE((int)client);
            return HTTP2_ERR_SERVER_TLS;
        }
        r = http2_server_serve_h2_multi_c(tls_ctx, body, body_len, max_requests);
        net_tls_close_c(tls_ctx);
        SHUX_HTTP_CLOSE((int)client);
        return r;
    }
#else
    struct pollfd pfd;
    int client;
    int64_t tls_ctx;
    int32_t r;
    if (listener_fd < 0 || srv_ctx_h == 0)
        return -1;
    if (timeout_ms > 0) {
        pfd.fd = listener_fd;
        pfd.events = POLLIN;
        pfd.revents = 0;
        if (poll(&pfd, 1, (int)timeout_ms) <= 0)
            return -1;
    }
    client = (int)accept(listener_fd, NULL, NULL);
    if (client < 0)
        return -1;
    tls_ctx = net_tls_accept_server_c(srv_ctx_h, client);
    if (tls_ctx == 0) {
        SHUX_HTTP_CLOSE(client);
        return HTTP2_ERR_SERVER_TLS;
    }
    r = http2_server_serve_h2_multi_c(tls_ctx, body, body_len, max_requests);
    net_tls_close_c(tls_ctx);
    SHUX_HTTP_CLOSE(client);
    return r;
#endif
}

/**
 * accept + TLS + 至多 max_requests 个带 push 的 GET serve；成功返回 serve 次数。
 */
int32_t http2_serve_h2_multi_one_with_push_c(int32_t listener_fd, int64_t srv_ctx_h,
                                             const uint8_t *body, int32_t body_len,
                                             int32_t max_requests, const uint8_t *authority,
                                             int32_t authority_len, const uint8_t *push_path,
                                             int32_t push_path_len, const uint8_t *push_body,
                                             int32_t push_body_len, uint32_t timeout_ms) {
#if defined(_WIN32) || defined(_WIN64)
    (void)timeout_ms;
    {
        SOCKET client = accept((SOCKET)listener_fd, NULL, NULL);
        int64_t tls_ctx;
        int32_t r;
        if (client == INVALID_SOCKET || srv_ctx_h == 0)
            return -1;
        tls_ctx = net_tls_accept_server_c(srv_ctx_h, (int32_t)client);
        if (tls_ctx == 0) {
            SHUX_HTTP_CLOSE((int)client);
            return HTTP2_ERR_SERVER_TLS;
        }
        r = http2_server_serve_h2_multi_with_push_c(tls_ctx, body, body_len, max_requests,
                                                    authority, authority_len, push_path,
                                                    push_path_len, push_body, push_body_len);
        net_tls_close_c(tls_ctx);
        SHUX_HTTP_CLOSE((int)client);
        return r;
    }
#else
    struct pollfd pfd;
    int client;
    int64_t tls_ctx;
    int32_t r;
    if (listener_fd < 0 || srv_ctx_h == 0)
        return -1;
    if (timeout_ms > 0) {
        pfd.fd = listener_fd;
        pfd.events = POLLIN;
        pfd.revents = 0;
        if (poll(&pfd, 1, (int)timeout_ms) <= 0)
            return -1;
    }
    client = (int)accept(listener_fd, NULL, NULL);
    if (client < 0)
        return -1;
    tls_ctx = net_tls_accept_server_c(srv_ctx_h, client);
    if (tls_ctx == 0) {
        SHUX_HTTP_CLOSE(client);
        return HTTP2_ERR_SERVER_TLS;
    }
    r = http2_server_serve_h2_multi_with_push_c(tls_ctx, body, body_len, max_requests, authority,
                                                authority_len, push_path, push_path_len, push_body,
                                                push_body_len);
    net_tls_close_c(tls_ctx);
    SHUX_HTTP_CLOSE(client);
    return r;
#endif
}

/** h2c server 离线烟测（无效 fd 须失败）；0 通过。 */
int32_t http2_server_offline_smoke_c(void) {
    if (http2_server_serve_h2c_c(-1, (const uint8_t *)"ok", 2) != -1)
        return 1;
    return 0;
}

/**
 * h2c server 集成烟测：fork 本地 listen + client h2c GET 往返；Windows 跳过返回 0。
 * 0 通过。
 */
int32_t http2_h2c_server_smoke_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    return 0;
#else
    struct sockaddr_in sin;
    socklen_t slen = (socklen_t)sizeof(sin);
    pid_t pid;
    int lfd;
    uint16_t bound_port;
    int status;
    static const uint8_t body[] = "ok";

    if (http2_server_offline_smoke_c() != 0)
        return 1;

    lfd = (int)http_listen_c(0x7f000001u, 0u, 4);
    if (lfd < 0)
        return 2;
    slen = (socklen_t)sizeof(sin);
    if (getsockname(lfd, (struct sockaddr *)&sin, &slen) != 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 3;
    }
    bound_port = ntohs(sin.sin_port);

    pid = fork();
    if (pid < 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 4;
    }
    if (pid == 0) {
        conn_t conn;
        uint8_t out[512];
        int32_t code;
        int32_t n;
        struct sockaddr_in cli;
        int cfd;
        char port_buf[8];
        char host_buf[16];
        uint8_t path[] = "/";

        memset(&cli, 0, sizeof(cli));
        cli.sin_family = AF_INET;
        cli.sin_port = htons(bound_port);
        cli.sin_addr.s_addr = htonl(0x7f000001u);
        cfd = (int)socket(AF_INET, SOCK_STREAM, 0);
        if (cfd < 0)
            _exit(10);
        if (connect(cfd, (struct sockaddr *)&cli, (socklen_t)sizeof(cli)) != 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(11);
        }
        if (snprintf(host_buf, sizeof(host_buf), "127.0.0.1") <= 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(12);
        }
        if (snprintf(port_buf, sizeof(port_buf), "%u", (unsigned)bound_port) <= 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(13);
        }
        (void)port_buf;
        http2_conn_init_c(&conn);
        if (http2_conn_attach_h2c_c(cfd, &conn) != 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(14);
        }
        if (http2_conn_handshake_c(&conn) != 0) {
            http2_conn_shutdown_c(&conn);
            _exit(15);
        }
        n = http2_conn_request_c(&conn, 0, (const uint8_t *)host_buf, (int32_t)strlen(host_buf),
                               path, 1, NULL, 0, out, (int32_t)sizeof(out));
        http2_conn_shutdown_c(&conn);
        if (n <= 0)
            _exit(16);
        if (http_parse_status_line_c(out, n, &code) != 0 || code != 200)
            _exit(17);
        if (strstr((char *)out, "ok") == NULL)
            _exit(18);
        _exit(0);
    }

    if (http2_serve_h2c_one_c(lfd, body, 2, 5000u) != 0) {
        (void)kill(pid, SIGKILL);
        (void)waitpid(pid, NULL, 0);
        SHUX_HTTP_CLOSE(lfd);
        return 5;
    }
    if (waitpid(pid, &status, 0) != pid || !WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 6;
    }
    SHUX_HTTP_CLOSE(lfd);
    return 0;
#endif
}

/**
 * h2c server push 集成烟测：server 发 PUSH_PROMISE + push body；client 收集 push；Windows 跳过。
 */
int32_t http2_h2c_server_push_smoke_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    return 0;
#else
    struct sockaddr_in sin;
    socklen_t slen = (socklen_t)sizeof(sin);
    pid_t pid;
    int lfd;
    uint16_t bound_port;
    int status;
    static const uint8_t main_body[] = "ok";
    static const uint8_t push_body[] = "push";
    static const uint8_t authority[] = "127.0.0.1";
    static const uint8_t push_path[] = "/push";

    if (http2_server_push_wire_smoke_c() != 0)
        return 1;

    lfd = (int)http_listen_c(0x7f000001u, 0u, 4);
    if (lfd < 0)
        return 2;
    slen = (socklen_t)sizeof(sin);
    if (getsockname(lfd, (struct sockaddr *)&sin, &slen) != 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 3;
    }
    bound_port = ntohs(sin.sin_port);

    pid = fork();
    if (pid < 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 4;
    }
    if (pid == 0) {
        conn_t conn;
        push_last_t push_meta;
        uint8_t out[512];
        uint8_t push_out[16];
        int32_t code;
        int32_t n;
        int32_t pn;
        struct sockaddr_in cli;
        int cfd;
        char host_buf[16];
        uint8_t path[] = "/";

        memset(&cli, 0, sizeof(cli));
        cli.sin_family = AF_INET;
        cli.sin_port = htons(bound_port);
        cli.sin_addr.s_addr = htonl(0x7f000001u);
        cfd = (int)socket(AF_INET, SOCK_STREAM, 0);
        if (cfd < 0)
            _exit(10);
        if (connect(cfd, (struct sockaddr *)&cli, (socklen_t)sizeof(cli)) != 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(11);
        }
        if (snprintf(host_buf, sizeof(host_buf), "127.0.0.1") <= 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(12);
        }
        http2_conn_init_c(&conn);
        if (http2_conn_attach_h2c_c(cfd, &conn) != 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(13);
        }
        if (http2_conn_handshake_c(&conn) != 0) {
            http2_conn_shutdown_c(&conn);
            _exit(14);
        }
        n = http2_conn_request_c(&conn, 0, (const uint8_t *)host_buf, (int32_t)strlen(host_buf), path,
                               1, NULL, 0, out, (int32_t)sizeof(out));
        http2_conn_shutdown_c(&conn);
        if (n <= 0)
            _exit(15);
        if (http_parse_status_line_c(out, n, &code) != 0 || code != 200)
            _exit(16);
        if (strstr((char *)out, "ok") == NULL)
            _exit(17);
        pn = http2_push_last_copy_c(&push_meta, push_out, (int32_t)sizeof(push_out));
        if (pn != 4 || push_meta.promised_stream_id != 2)
            _exit(18);
        if (memcmp(push_out, "push", 4) != 0)
            _exit(19);
        _exit(0);
    }

    if (http2_serve_h2c_one_with_push_c(lfd, main_body, 2, authority, 9, push_path, 5, push_body, 4,
                                        5000u) != 0) {
        (void)kill(pid, SIGKILL);
        (void)waitpid(pid, NULL, 0);
        SHUX_HTTP_CLOSE(lfd);
        return 5;
    }
    if (waitpid(pid, &status, 0) != pid || !WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 6;
    }
    SHUX_HTTP_CLOSE(lfd);
    return 0;
#endif
}

/**
 * h2c server push SETTINGS 烟测：client ENABLE_PUSH=0 时 server 软拒绝 push；Windows 跳过。
 */
int32_t http2_h2c_server_push_settings_smoke_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    return 0;
#else
    struct sockaddr_in sin;
    socklen_t slen = (socklen_t)sizeof(sin);
    pid_t pid;
    int lfd;
    uint16_t bound_port;
    int status;
    static const uint8_t main_body[] = "ok";
    static const uint8_t push_body[] = "push";
    static const uint8_t authority[] = "127.0.0.1";
    static const uint8_t push_path[] = "/push";

    lfd = (int)http_listen_c(0x7f000001u, 0u, 4);
    if (lfd < 0)
        return 1;
    slen = (socklen_t)sizeof(sin);
    if (getsockname(lfd, (struct sockaddr *)&sin, &slen) != 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 2;
    }
    bound_port = ntohs(sin.sin_port);

    pid = fork();
    if (pid < 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 3;
    }
    if (pid == 0) {
        conn_t conn;
        push_last_t push_meta;
        uint8_t out[512];
        uint8_t push_out[16];
        int32_t code;
        int32_t n;
        int32_t pn;
        struct sockaddr_in cli;
        int cfd;
        char host_buf[16];
        uint8_t path[] = "/";

        memset(&cli, 0, sizeof(cli));
        cli.sin_family = AF_INET;
        cli.sin_port = htons(bound_port);
        cli.sin_addr.s_addr = htonl(0x7f000001u);
        cfd = (int)socket(AF_INET, SOCK_STREAM, 0);
        if (cfd < 0)
            _exit(60);
        if (connect(cfd, (struct sockaddr *)&cli, (socklen_t)sizeof(cli)) != 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(61);
        }
        if (snprintf(host_buf, sizeof(host_buf), "127.0.0.1") <= 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(62);
        }
        http2_conn_init_c(&conn);
        if (http2_conn_attach_h2c_c(cfd, &conn) != 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(63);
        }
        if (http2_conn_handshake_with_enable_push_c(&conn, 0) != 0) {
            http2_conn_shutdown_c(&conn);
            _exit(64);
        }
        n = http2_conn_request_c(&conn, 0, (const uint8_t *)host_buf, (int32_t)strlen(host_buf),
                               path, 1, NULL, 0, out, (int32_t)sizeof(out));
        http2_conn_shutdown_c(&conn);
        if (n <= 0)
            _exit(65);
        if (http_parse_status_line_c(out, n, &code) != 0 || code != 200)
            _exit(66);
        if (strstr((char *)out, "ok") == NULL)
            _exit(67);
        pn = http2_push_last_copy_c(&push_meta, push_out, (int32_t)sizeof(push_out));
        if (pn != 0)
            _exit(68);
        _exit(0);
    }

    if (http2_serve_h2c_one_with_push_c(lfd, main_body, 2, authority, 9, push_path, 5, push_body, 4,
                                        5000u) != 0) {
        (void)kill(pid, SIGKILL);
        (void)waitpid(pid, NULL, 0);
        SHUX_HTTP_CLOSE(lfd);
        return 4;
    }
    if (waitpid(pid, &status, 0) != pid || !WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 5;
    }
    SHUX_HTTP_CLOSE(lfd);
    return 0;
#endif
}

/**
 * h2c server 全量 SETTINGS 协商烟测：client 读 server SETTINGS 并校验；Windows 跳过。
 */
int32_t http2_h2c_server_settings_full_smoke_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    return 0;
#else
    struct sockaddr_in sin;
    socklen_t slen = (socklen_t)sizeof(sin);
    pid_t pid;
    int lfd;
    uint16_t bound_port;
    int status;
    static const uint8_t body[] = "ok";

    lfd = (int)http_listen_c(0x7f000001u, 0u, 4);
    if (lfd < 0)
        return 1;
    slen = (socklen_t)sizeof(sin);
    if (getsockname(lfd, (struct sockaddr *)&sin, &slen) != 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 2;
    }
    bound_port = ntohs(sin.sin_port);

    pid = fork();
    if (pid < 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 3;
    }
    if (pid == 0) {
        conn_t conn;
        uint8_t out[512];
        int32_t n;
        struct sockaddr_in cli;
        int cfd;
        char host_buf[16];
        uint8_t path[] = "/";

        memset(&cli, 0, sizeof(cli));
        cli.sin_family = AF_INET;
        cli.sin_port = htons(bound_port);
        cli.sin_addr.s_addr = htonl(0x7f000001u);
        cfd = (int)socket(AF_INET, SOCK_STREAM, 0);
        if (cfd < 0)
            _exit(80);
        if (connect(cfd, (struct sockaddr *)&cli, (socklen_t)sizeof(cli)) != 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(81);
        }
        if (snprintf(host_buf, sizeof(host_buf), "127.0.0.1") <= 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(82);
        }
        http2_conn_init_c(&conn);
        if (http2_conn_attach_h2c_c(cfd, &conn) != 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(83);
        }
        if (http2_conn_handshake_c(&conn) != 0) {
            http2_conn_shutdown_c(&conn);
            _exit(84);
        }
        if (http2_peer_settings_header_table_size_c(&conn.ms.peer) != 4096)
            _exit(85);
        if (http2_peer_settings_max_frame_size_c(&conn.ms.peer) != 16384)
            _exit(86);
        if (http2_peer_settings_max_streams_c(&conn.ms.peer) != 100)
            _exit(87);
        n = http2_conn_request_c(&conn, 0, (const uint8_t *)host_buf, (int32_t)strlen(host_buf),
                               path, 1, NULL, 0, out, (int32_t)sizeof(out));
        http2_conn_shutdown_c(&conn);
        if (n <= 0)
            _exit(88);
        _exit(0);
    }

    if (http2_serve_h2c_one_c(lfd, body, 2, 5000u) != 0) {
        (void)kill(pid, SIGKILL);
        (void)waitpid(pid, NULL, 0);
        SHUX_HTTP_CLOSE(lfd);
        return 4;
    }
    if (waitpid(pid, &status, 0) != pid || !WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 5;
    }
    SHUX_HTTP_CLOSE(lfd);
    return 0;
#endif
}

/**
 * h2c server 多 stream 集成烟测：单连接 2 次 GET；Windows 跳过返回 0。
 */
int32_t http2_h2c_server_multistream_smoke_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    return 0;
#else
    struct sockaddr_in sin;
    socklen_t slen = (socklen_t)sizeof(sin);
    pid_t pid;
    int lfd;
    uint16_t bound_port;
    int status;
    static const uint8_t body[] = "ok";

    lfd = (int)http_listen_c(0x7f000001u, 0u, 4);
    if (lfd < 0)
        return 1;
    slen = (socklen_t)sizeof(sin);
    if (getsockname(lfd, (struct sockaddr *)&sin, &slen) != 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 2;
    }
    bound_port = ntohs(sin.sin_port);

    pid = fork();
    if (pid < 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 3;
    }
    if (pid == 0) {
        conn_t conn;
        uint8_t out1[512];
        uint8_t out2[512];
        int32_t code;
        int32_t n1;
        int32_t n2;
        struct sockaddr_in cli;
        int cfd;
        char host_buf[16];
        uint8_t path1[] = "/a";
        uint8_t path2[] = "/b";

        memset(&cli, 0, sizeof(cli));
        cli.sin_family = AF_INET;
        cli.sin_port = htons(bound_port);
        cli.sin_addr.s_addr = htonl(0x7f000001u);
        cfd = (int)socket(AF_INET, SOCK_STREAM, 0);
        if (cfd < 0)
            _exit(40);
        if (connect(cfd, (struct sockaddr *)&cli, (socklen_t)sizeof(cli)) != 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(41);
        }
        if (snprintf(host_buf, sizeof(host_buf), "127.0.0.1") <= 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(42);
        }
        http2_conn_init_c(&conn);
        if (http2_conn_attach_h2c_c(cfd, &conn) != 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(43);
        }
        if (http2_conn_handshake_c(&conn) != 0) {
            http2_conn_shutdown_c(&conn);
            _exit(44);
        }
        n1 = http2_conn_request_c(&conn, 0, (const uint8_t *)host_buf, (int32_t)strlen(host_buf),
                                  path1, 1, NULL, 0, out1, (int32_t)sizeof(out1));
        n2 = http2_conn_request_c(&conn, 0, (const uint8_t *)host_buf, (int32_t)strlen(host_buf),
                                  path2, 1, NULL, 0, out2, (int32_t)sizeof(out2));
        http2_conn_shutdown_c(&conn);
        if (n1 <= 0 || n2 <= 0)
            _exit(45);
        if (http_parse_status_line_c(out1, n1, &code) != 0 || code != 200)
            _exit(46);
        if (http_parse_status_line_c(out2, n2, &code) != 0 || code != 200)
            _exit(47);
        if (strstr((char *)out1, "ok") == NULL || strstr((char *)out2, "ok") == NULL)
            _exit(48);
        _exit(0);
    }

    if (http2_serve_h2c_multi_one_c(lfd, body, 2, 2, 5000u) != 2) {
        (void)kill(pid, SIGKILL);
        (void)waitpid(pid, NULL, 0);
        SHUX_HTTP_CLOSE(lfd);
        return 4;
    }
    if (waitpid(pid, &status, 0) != pid || !WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 5;
    }
    SHUX_HTTP_CLOSE(lfd);
    return 0;
#endif
}

/**
 * h2c server 多 stream + push 集成烟测：单连接 2 次 GET 各带 push；Windows 跳过返回 0。
 */
int32_t http2_h2c_server_multistream_push_smoke_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    return 0;
#else
    struct sockaddr_in sin;
    socklen_t slen = (socklen_t)sizeof(sin);
    pid_t pid;
    int lfd;
    uint16_t bound_port;
    int status;
    static const uint8_t main_body[] = "ok";
    static const uint8_t push_body[] = "push";
    static const uint8_t authority[] = "127.0.0.1";
    static const uint8_t push_path[] = "/push";

    lfd = (int)http_listen_c(0x7f000001u, 0u, 4);
    if (lfd < 0)
        return 1;
    slen = (socklen_t)sizeof(sin);
    if (getsockname(lfd, (struct sockaddr *)&sin, &slen) != 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 2;
    }
    bound_port = ntohs(sin.sin_port);

    pid = fork();
    if (pid < 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 3;
    }
    if (pid == 0) {
        conn_t conn;
        push_last_t push_meta;
        uint8_t out1[512];
        uint8_t out2[512];
        uint8_t push_out[16];
        int32_t code;
        int32_t n1;
        int32_t n2;
        int32_t pn;
        struct sockaddr_in cli;
        int cfd;
        char host_buf[16];
        uint8_t path1[] = "/a";
        uint8_t path2[] = "/b";

        memset(&cli, 0, sizeof(cli));
        cli.sin_family = AF_INET;
        cli.sin_port = htons(bound_port);
        cli.sin_addr.s_addr = htonl(0x7f000001u);
        cfd = (int)socket(AF_INET, SOCK_STREAM, 0);
        if (cfd < 0)
            _exit(50);
        if (connect(cfd, (struct sockaddr *)&cli, (socklen_t)sizeof(cli)) != 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(51);
        }
        if (snprintf(host_buf, sizeof(host_buf), "127.0.0.1") <= 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(52);
        }
        http2_conn_init_c(&conn);
        if (http2_conn_attach_h2c_c(cfd, &conn) != 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(53);
        }
        if (http2_conn_handshake_c(&conn) != 0) {
            http2_conn_shutdown_c(&conn);
            _exit(54);
        }
        n1 = http2_conn_request_c(&conn, 0, (const uint8_t *)host_buf, (int32_t)strlen(host_buf),
                                  path1, 1, NULL, 0, out1, (int32_t)sizeof(out1));
        if (n1 <= 0)
            _exit(55);
        if (http_parse_status_line_c(out1, n1, &code) != 0 || code != 200)
            _exit(56);
        pn = http2_push_last_copy_c(&push_meta, push_out, (int32_t)sizeof(push_out));
        if (pn != 4 || push_meta.promised_stream_id != 2)
            _exit(57);
        if (memcmp(push_out, "push", 4) != 0)
            _exit(58);
        n2 = http2_conn_request_c(&conn, 0, (const uint8_t *)host_buf, (int32_t)strlen(host_buf),
                                  path2, 1, NULL, 0, out2, (int32_t)sizeof(out2));
        http2_conn_shutdown_c(&conn);
        if (n2 <= 0)
            _exit(59);
        if (http_parse_status_line_c(out2, n2, &code) != 0 || code != 200)
            _exit(60);
        if (strstr((char *)out2, "ok") == NULL)
            _exit(61);
        pn = http2_push_last_copy_c(&push_meta, push_out, (int32_t)sizeof(push_out));
        if (pn != 4 || push_meta.promised_stream_id != 4)
            _exit(62);
        if (memcmp(push_out, "push", 4) != 0)
            _exit(63);
        _exit(0);
    }

    if (http2_serve_h2c_multi_one_with_push_c(lfd, main_body, 2, 2, authority, 9, push_path, 5,
                                              push_body, 4, 5000u) != 2) {
        (void)kill(pid, SIGKILL);
        (void)waitpid(pid, NULL, 0);
        SHUX_HTTP_CLOSE(lfd);
        return 4;
    }
    if (waitpid(pid, &status, 0) != pid || !WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 5;
    }
    SHUX_HTTP_CLOSE(lfd);
    return 0;
#endif
}

#include "http2_test_tls_cert.inc.c"

/**
 * h2 over TLS server 集成烟测：fork + 自签 PEM；TLS 不可用或 Windows 跳过返回 0。
 */
int32_t http2_h2_server_smoke_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    return 0;
#else
    struct sockaddr_in sin;
    socklen_t slen = (socklen_t)sizeof(sin);
    pid_t pid;
    int lfd;
    uint16_t bound_port;
    int64_t srv_ctx;
    int status;
    int32_t cert_len;
    int32_t key_len;
    static const uint8_t body[] = "ok";

    if (net_tls_is_available_c() == 0)
        return 0;
    cert_len = (int32_t)(sizeof(g_http2_test_tls_cert_pem) - 1);
    key_len = (int32_t)(sizeof(g_http2_test_tls_key_pem) - 1);
    srv_ctx = http2_tls_server_ctx_create_c((const uint8_t *)g_http2_test_tls_cert_pem, cert_len,
                                            (const uint8_t *)g_http2_test_tls_key_pem, key_len);
    if (srv_ctx == 0)
        return 1;

    lfd = (int)http_listen_c(0x7f000001u, 0u, 4);
    if (lfd < 0) {
        http2_tls_server_ctx_destroy_c(srv_ctx);
        return 2;
    }
    slen = (socklen_t)sizeof(sin);
    if (getsockname(lfd, (struct sockaddr *)&sin, &slen) != 0) {
        SHUX_HTTP_CLOSE(lfd);
        http2_tls_server_ctx_destroy_c(srv_ctx);
        return 3;
    }
    bound_port = ntohs(sin.sin_port);

    pid = fork();
    if (pid < 0) {
        SHUX_HTTP_CLOSE(lfd);
        http2_tls_server_ctx_destroy_c(srv_ctx);
        return 4;
    }
    if (pid == 0) {
        conn_t conn;
        uint8_t alpn_wire[16];
        uint8_t out[512];
        char url[128];
        int32_t code;
        int32_t n;
        int32_t alpn_len;
        struct sockaddr_in cli;
        int cfd;
        int64_t tls_ctx;

        if (snprintf(url, sizeof(url), "https://127.0.0.1:%u/", (unsigned)bound_port) <= 0)
            _exit(20);
        memset(&cli, 0, sizeof(cli));
        cli.sin_family = AF_INET;
        cli.sin_port = htons(bound_port);
        cli.sin_addr.s_addr = htonl(0x7f000001u);
        cfd = (int)socket(AF_INET, SOCK_STREAM, 0);
        if (cfd < 0)
            _exit(21);
        if (connect(cfd, (struct sockaddr *)&cli, (socklen_t)sizeof(cli)) != 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(22);
        }
        alpn_len = net_tls_alpn_h2_http1_wire_c(alpn_wire, (int32_t)sizeof(alpn_wire));
        if (alpn_len <= 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(23);
        }
        tls_ctx = net_tls_connect_client_alpn_c(cfd, "127.0.0.1", alpn_wire, alpn_len);
        if (tls_ctx == 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(24);
        }
        if (net_tls_alpn_is_h2_c(tls_ctx) == 0) {
            net_tls_close_c(tls_ctx);
            SHUX_HTTP_CLOSE(cfd);
            _exit(25);
        }
        http2_conn_init_c(&conn);
        if (http2_conn_attach_tls_c(tls_ctx, &conn) != 0) {
            net_tls_close_c(tls_ctx);
            SHUX_HTTP_CLOSE(cfd);
            _exit(26);
        }
        if (http2_conn_handshake_c(&conn) != 0) {
            http2_conn_shutdown_c(&conn);
            _exit(27);
        }
        n = http2_conn_request_c(&conn, 0, (const uint8_t *)"127.0.0.1", 9, (const uint8_t *)"/", 1,
                                 NULL, 0, out, (int32_t)sizeof(out));
        http2_conn_shutdown_c(&conn);
        if (n <= 0)
            _exit(28);
        if (http_parse_status_line_c(out, n, &code) != 0 || code != 200)
            _exit(29);
        if (strstr((char *)out, "ok") == NULL)
            _exit(30);
        _exit(0);
    }

    if (http2_serve_h2_one_c(lfd, srv_ctx, body, 2, 5000u) != 0) {
        (void)kill(pid, SIGKILL);
        (void)waitpid(pid, NULL, 0);
        SHUX_HTTP_CLOSE(lfd);
        http2_tls_server_ctx_destroy_c(srv_ctx);
        return 5;
    }
    if (waitpid(pid, &status, 0) != pid || !WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        SHUX_HTTP_CLOSE(lfd);
        http2_tls_server_ctx_destroy_c(srv_ctx);
        return 6;
    }
    SHUX_HTTP_CLOSE(lfd);
    http2_tls_server_ctx_destroy_c(srv_ctx);
    return 0;
#endif
}

/**
 * h2 over TLS server push 集成烟测：fork + 自签 PEM；TLS 不可用或 Windows 跳过返回 0。
 */
int32_t http2_h2_server_push_smoke_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    return 0;
#else
    struct sockaddr_in sin;
    socklen_t slen = (socklen_t)sizeof(sin);
    pid_t pid;
    int lfd;
    uint16_t bound_port;
    int64_t srv_ctx;
    int status;
    int32_t cert_len;
    int32_t key_len;
    static const uint8_t main_body[] = "ok";
    static const uint8_t push_body[] = "push";
    static const uint8_t authority[] = "127.0.0.1";
    static const uint8_t push_path[] = "/push";

    if (net_tls_is_available_c() == 0)
        return 0;
    cert_len = (int32_t)(sizeof(g_http2_test_tls_cert_pem) - 1);
    key_len = (int32_t)(sizeof(g_http2_test_tls_key_pem) - 1);
    srv_ctx = http2_tls_server_ctx_create_c((const uint8_t *)g_http2_test_tls_cert_pem, cert_len,
                                            (const uint8_t *)g_http2_test_tls_key_pem, key_len);
    if (srv_ctx == 0)
        return 1;

    lfd = (int)http_listen_c(0x7f000001u, 0u, 4);
    if (lfd < 0) {
        http2_tls_server_ctx_destroy_c(srv_ctx);
        return 2;
    }
    slen = (socklen_t)sizeof(sin);
    if (getsockname(lfd, (struct sockaddr *)&sin, &slen) != 0) {
        SHUX_HTTP_CLOSE(lfd);
        http2_tls_server_ctx_destroy_c(srv_ctx);
        return 3;
    }
    bound_port = ntohs(sin.sin_port);

    pid = fork();
    if (pid < 0) {
        SHUX_HTTP_CLOSE(lfd);
        http2_tls_server_ctx_destroy_c(srv_ctx);
        return 4;
    }
    if (pid == 0) {
        conn_t conn;
        push_last_t push_meta;
        uint8_t alpn_wire[16];
        uint8_t out[512];
        uint8_t push_out[16];
        int32_t code;
        int32_t n;
        int32_t pn;
        int32_t alpn_len;
        struct sockaddr_in cli;
        int cfd;
        int64_t tls_ctx;
        uint8_t path[] = "/";

        memset(&cli, 0, sizeof(cli));
        cli.sin_family = AF_INET;
        cli.sin_port = htons(bound_port);
        cli.sin_addr.s_addr = htonl(0x7f000001u);
        cfd = (int)socket(AF_INET, SOCK_STREAM, 0);
        if (cfd < 0)
            _exit(20);
        if (connect(cfd, (struct sockaddr *)&cli, (socklen_t)sizeof(cli)) != 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(21);
        }
        alpn_len = net_tls_alpn_h2_http1_wire_c(alpn_wire, (int32_t)sizeof(alpn_wire));
        if (alpn_len <= 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(22);
        }
        tls_ctx = net_tls_connect_client_alpn_c(cfd, "127.0.0.1", alpn_wire, alpn_len);
        if (tls_ctx == 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(23);
        }
        if (net_tls_alpn_is_h2_c(tls_ctx) == 0) {
            net_tls_close_c(tls_ctx);
            SHUX_HTTP_CLOSE(cfd);
            _exit(24);
        }
        http2_conn_init_c(&conn);
        if (http2_conn_attach_tls_c(tls_ctx, &conn) != 0) {
            net_tls_close_c(tls_ctx);
            SHUX_HTTP_CLOSE(cfd);
            _exit(25);
        }
        if (http2_conn_handshake_c(&conn) != 0) {
            http2_conn_shutdown_c(&conn);
            _exit(26);
        }
        n = http2_conn_request_c(&conn, 0, authority, 9, path, 1, NULL, 0, out, (int32_t)sizeof(out));
        http2_conn_shutdown_c(&conn);
        if (n <= 0)
            _exit(27);
        if (http_parse_status_line_c(out, n, &code) != 0 || code != 200)
            _exit(28);
        if (strstr((char *)out, "ok") == NULL)
            _exit(29);
        pn = http2_push_last_copy_c(&push_meta, push_out, (int32_t)sizeof(push_out));
        if (pn != 4 || push_meta.promised_stream_id != 2)
            _exit(30);
        if (memcmp(push_out, "push", 4) != 0)
            _exit(31);
        _exit(0);
    }

    if (http2_serve_h2_one_with_push_c(lfd, srv_ctx, main_body, 2, authority, 9, push_path, 5,
                                       push_body, 4, 5000u) != 0) {
        (void)kill(pid, SIGKILL);
        (void)waitpid(pid, NULL, 0);
        SHUX_HTTP_CLOSE(lfd);
        http2_tls_server_ctx_destroy_c(srv_ctx);
        return 5;
    }
    if (waitpid(pid, &status, 0) != pid || !WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        SHUX_HTTP_CLOSE(lfd);
        http2_tls_server_ctx_destroy_c(srv_ctx);
        return 6;
    }
    SHUX_HTTP_CLOSE(lfd);
    http2_tls_server_ctx_destroy_c(srv_ctx);
    return 0;
#endif
}

/**
 * h2 over TLS server 多 stream + push 集成烟测；TLS 不可用或 Windows 跳过返回 0。
 */
int32_t http2_h2_server_multistream_push_smoke_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    return 0;
#else
    struct sockaddr_in sin;
    socklen_t slen = (socklen_t)sizeof(sin);
    pid_t pid;
    int lfd;
    uint16_t bound_port;
    int64_t srv_ctx;
    int status;
    int32_t cert_len;
    int32_t key_len;
    static const uint8_t main_body[] = "ok";
    static const uint8_t push_body[] = "push";
    static const uint8_t authority[] = "127.0.0.1";
    static const uint8_t push_path[] = "/push";

    if (net_tls_is_available_c() == 0)
        return 0;
    cert_len = (int32_t)(sizeof(g_http2_test_tls_cert_pem) - 1);
    key_len = (int32_t)(sizeof(g_http2_test_tls_key_pem) - 1);
    srv_ctx = http2_tls_server_ctx_create_c((const uint8_t *)g_http2_test_tls_cert_pem, cert_len,
                                            (const uint8_t *)g_http2_test_tls_key_pem, key_len);
    if (srv_ctx == 0)
        return 1;

    lfd = (int)http_listen_c(0x7f000001u, 0u, 4);
    if (lfd < 0) {
        http2_tls_server_ctx_destroy_c(srv_ctx);
        return 2;
    }
    slen = (socklen_t)sizeof(sin);
    if (getsockname(lfd, (struct sockaddr *)&sin, &slen) != 0) {
        SHUX_HTTP_CLOSE(lfd);
        http2_tls_server_ctx_destroy_c(srv_ctx);
        return 3;
    }
    bound_port = ntohs(sin.sin_port);

    pid = fork();
    if (pid < 0) {
        SHUX_HTTP_CLOSE(lfd);
        http2_tls_server_ctx_destroy_c(srv_ctx);
        return 4;
    }
    if (pid == 0) {
        conn_t conn;
        push_last_t push_meta;
        uint8_t alpn_wire[16];
        uint8_t out1[512];
        uint8_t out2[512];
        uint8_t push_out[16];
        int32_t code;
        int32_t n1;
        int32_t n2;
        int32_t pn;
        int32_t alpn_len;
        struct sockaddr_in cli;
        int cfd;
        int64_t tls_ctx;
        uint8_t path1[] = "/a";
        uint8_t path2[] = "/b";

        memset(&cli, 0, sizeof(cli));
        cli.sin_family = AF_INET;
        cli.sin_port = htons(bound_port);
        cli.sin_addr.s_addr = htonl(0x7f000001u);
        cfd = (int)socket(AF_INET, SOCK_STREAM, 0);
        if (cfd < 0)
            _exit(70);
        if (connect(cfd, (struct sockaddr *)&cli, (socklen_t)sizeof(cli)) != 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(71);
        }
        alpn_len = net_tls_alpn_h2_http1_wire_c(alpn_wire, (int32_t)sizeof(alpn_wire));
        if (alpn_len <= 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(72);
        }
        tls_ctx = net_tls_connect_client_alpn_c(cfd, "127.0.0.1", alpn_wire, alpn_len);
        if (tls_ctx == 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(73);
        }
        if (net_tls_alpn_is_h2_c(tls_ctx) == 0) {
            net_tls_close_c(tls_ctx);
            SHUX_HTTP_CLOSE(cfd);
            _exit(74);
        }
        http2_conn_init_c(&conn);
        if (http2_conn_attach_tls_c(tls_ctx, &conn) != 0) {
            net_tls_close_c(tls_ctx);
            SHUX_HTTP_CLOSE(cfd);
            _exit(75);
        }
        if (http2_conn_handshake_c(&conn) != 0) {
            http2_conn_shutdown_c(&conn);
            _exit(76);
        }
        n1 = http2_conn_request_c(&conn, 0, authority, 9, path1, 1, NULL, 0, out1,
                                  (int32_t)sizeof(out1));
        if (n1 <= 0)
            _exit(77);
        if (http_parse_status_line_c(out1, n1, &code) != 0 || code != 200)
            _exit(78);
        pn = http2_push_last_copy_c(&push_meta, push_out, (int32_t)sizeof(push_out));
        if (pn != 4 || push_meta.promised_stream_id != 2)
            _exit(79);
        if (memcmp(push_out, "push", 4) != 0)
            _exit(80);
        n2 = http2_conn_request_c(&conn, 0, authority, 9, path2, 1, NULL, 0, out2,
                                  (int32_t)sizeof(out2));
        http2_conn_shutdown_c(&conn);
        if (n2 <= 0)
            _exit(81);
        if (http_parse_status_line_c(out2, n2, &code) != 0 || code != 200)
            _exit(82);
        pn = http2_push_last_copy_c(&push_meta, push_out, (int32_t)sizeof(push_out));
        if (pn != 4 || push_meta.promised_stream_id != 4)
            _exit(83);
        if (memcmp(push_out, "push", 4) != 0)
            _exit(84);
        _exit(0);
    }

    if (http2_serve_h2_multi_one_with_push_c(lfd, srv_ctx, main_body, 2, 2, authority, 9,
                                             push_path, 5, push_body, 4, 5000u) != 2) {
        (void)kill(pid, SIGKILL);
        (void)waitpid(pid, NULL, 0);
        SHUX_HTTP_CLOSE(lfd);
        http2_tls_server_ctx_destroy_c(srv_ctx);
        return 5;
    }
    if (waitpid(pid, &status, 0) != pid || !WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        SHUX_HTTP_CLOSE(lfd);
        http2_tls_server_ctx_destroy_c(srv_ctx);
        return 6;
    }
    SHUX_HTTP_CLOSE(lfd);
    http2_tls_server_ctx_destroy_c(srv_ctx);
    return 0;
#endif
}

/** HTTP/2 server API 是否可用（v14 恒 1）。 */
int32_t http2_server_is_available_c(void) { return 1; }

/** HTTP/2 server 多 stream API 是否可用（v16 恒 1）。 */
int32_t http2_server_multistream_is_available_c(void) { return 1; }

/** HTTP/2 server push API 是否可用（v17 恒 1）。 */
int32_t http2_server_push_is_available_c(void) { return 1; }

/** HTTP/2 server 多 stream + push API 是否可用（v19 恒 1）。 */
int32_t http2_server_multistream_push_is_available_c(void) { return 1; }

/** server 多 stream + push 烟测（h2c + TLS fork 集成）；0 通过。 */
int32_t http2_server_multistream_push_smoke_c(void) {
    if (http2_h2c_server_multistream_push_smoke_c() != 0)
        return 1;
    if (http2_h2_server_multistream_push_smoke_c() != 0)
        return 2;
    return 0;
}

/** server push 烟测（离线线格式 + fork h2c/h2 集成）；0 通过。 */
int32_t http2_server_push_smoke_c(void) {
    if (http2_server_push_wire_smoke_c() != 0)
        return 1;
    if (http2_h2c_server_push_smoke_c() != 0)
        return 2;
    if (http2_h2_server_push_smoke_c() != 0)
        return 3;
    return 0;
}

/** server push SETTINGS/ENABLE_PUSH 协商烟测；0 通过。 */
int32_t http2_server_push_settings_smoke_c(void) {
    if (http2_h2c_server_push_settings_smoke_c() != 0)
        return 1;
    return 0;
}

/** server 全量 SETTINGS 协商烟测（HEADER_TABLE_SIZE/MAX_FRAME_SIZE 等）；0 通过。 */
int32_t http2_server_settings_full_smoke_c(void) {
    if (http2_h2c_server_settings_full_smoke_c() != 0)
        return 1;
    return 0;
}

/**
 * h2c server MAX_FRAME_SIZE 分片 DATA 集成烟测：client SETTINGS=4096 + 6000 字节 body；Windows 跳过。
 */
int32_t http2_h2c_server_max_frame_smoke_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    return 0;
#else
    struct sockaddr_in sin;
    socklen_t slen = (socklen_t)sizeof(sin);
    pid_t pid;
    int lfd;
    uint16_t bound_port;
    int status;
    static uint8_t body[16385];
    int32_t i;

    for (i = 0; i < 16385; i++)
        body[i] = (uint8_t)'B';

    lfd = (int)http_listen_c(0x7f000001u, 0u, 4);
    if (lfd < 0)
        return 1;
    if (getsockname(lfd, (struct sockaddr *)&sin, &slen) != 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 2;
    }
    bound_port = ntohs(sin.sin_port);

    pid = fork();
    if (pid < 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 3;
    }
    if (pid == 0) {
        conn_t conn;
        static uint8_t out[24576];
        int32_t n;
        int32_t bcount = 0;
        int32_t j;
        struct sockaddr_in cli;
        int cfd;
        char host_buf[16];
        uint8_t path[] = "/";

        memset(&cli, 0, sizeof(cli));
        cli.sin_family = AF_INET;
        cli.sin_port = htons(bound_port);
        cli.sin_addr.s_addr = htonl(0x7f000001u);
        cfd = (int)socket(AF_INET, SOCK_STREAM, 0);
        if (cfd < 0)
            _exit(90);
        if (connect(cfd, (struct sockaddr *)&cli, (socklen_t)sizeof(cli)) != 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(91);
        }
        if (snprintf(host_buf, sizeof(host_buf), "127.0.0.1") <= 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(92);
        }
        http2_conn_init_c(&conn);
        if (http2_conn_attach_h2c_c(cfd, &conn) != 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(93);
        }
        if (http2_conn_handshake_c(&conn) != 0) {
            http2_conn_shutdown_c(&conn);
            _exit(94);
        }
        n = http2_conn_request_c(&conn, 0, (const uint8_t *)host_buf, (int32_t)strlen(host_buf), path,
                               1, NULL, 0, out, (int32_t)sizeof(out));
        http2_conn_shutdown_c(&conn);
        if (n <= 0)
            _exit(95);
        for (j = 0; j < n; j++) {
            if (out[j] == (uint8_t)'B')
                bcount++;
        }
        if (bcount < 16385)
            _exit(96);
        _exit(0);
    }

    if (http2_serve_h2c_one_c(lfd, body, 16385, 5000u) != 0) {
        (void)kill(pid, SIGKILL);
        (void)waitpid(pid, NULL, 0);
        SHUX_HTTP_CLOSE(lfd);
        return 4;
    }
    if (waitpid(pid, &status, 0) != pid || !WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 5;
    }
    SHUX_HTTP_CLOSE(lfd);
    return 0;
#endif
}

/** server MAX_FRAME_SIZE 分片烟测（离线 + h2c 集成）；0 通过。 */
int32_t http2_server_max_frame_smoke_c(void) {
    if (http2_frame_capped_smoke_c() != 0)
        return 1;
    if (http2_h2c_server_max_frame_smoke_c() != 0)
        return 2;
    return 0;
}

/**
 * h2c server GOAWAY 集成烟测：client GET 200 后读 server GOAWAY；Windows 跳过返回 0。
 */
int32_t http2_h2c_server_goaway_smoke_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    return 0;
#else
    struct sockaddr_in sin;
    socklen_t slen = (socklen_t)sizeof(sin);
    pid_t pid;
    int lfd;
    uint16_t bound_port;
    int status;
    static const uint8_t body[] = "goaway-ok";

    lfd = (int)http_listen_c(0x7f000001u, 0u, 4);
    if (lfd < 0)
        return 1;
    if (getsockname(lfd, (struct sockaddr *)&sin, &slen) != 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 2;
    }
    bound_port = ntohs(sin.sin_port);

    pid = fork();
    if (pid < 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 3;
    }
    if (pid == 0) {
        conn_t conn;
        uint8_t out[512];
        int32_t n;
        int32_t last_stream = 0;
        int32_t err_code = -1;
        struct sockaddr_in cli;
        int cfd;
        char host_buf[16];
        uint8_t path[] = "/";

        memset(&cli, 0, sizeof(cli));
        cli.sin_family = AF_INET;
        cli.sin_port = htons(bound_port);
        cli.sin_addr.s_addr = htonl(0x7f000001u);
        cfd = (int)socket(AF_INET, SOCK_STREAM, 0);
        if (cfd < 0)
            _exit(80);
        if (connect(cfd, (struct sockaddr *)&cli, (socklen_t)sizeof(cli)) != 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(81);
        }
        if (snprintf(host_buf, sizeof(host_buf), "127.0.0.1") <= 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(82);
        }
        http2_conn_init_c(&conn);
        if (http2_conn_attach_h2c_c(cfd, &conn) != 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(83);
        }
        if (http2_conn_handshake_c(&conn) != 0) {
            http2_conn_shutdown_c(&conn);
            _exit(84);
        }
        n = http2_conn_request_c(&conn, 0, (const uint8_t *)host_buf, (int32_t)strlen(host_buf), path,
                               1, NULL, 0, out, (int32_t)sizeof(out));
        if (n <= 0) {
            http2_conn_shutdown_c(&conn);
            _exit(85);
        }
        if (http2_conn_read_goaway_c(&conn, &last_stream, &err_code) != 0) {
            http2_conn_shutdown_c(&conn);
            _exit(86);
        }
        http2_conn_shutdown_c(&conn);
        if (last_stream < 1 || err_code != HTTP2_GOAWAY_NO_ERROR)
            _exit(87);
        _exit(0);
    }

    if (http2_serve_h2c_one_with_goaway_c(lfd, body, 9, 1, 5000u) != 0) {
        (void)kill(pid, SIGKILL);
        (void)waitpid(pid, NULL, 0);
        SHUX_HTTP_CLOSE(lfd);
        return 4;
    }
    if (waitpid(pid, &status, 0) != pid || !WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 5;
    }
    SHUX_HTTP_CLOSE(lfd);
    return 0;
#endif
}

/**
 * 对已 accept 的 h2c 连接：handshake 后读 client PING 并回 PONG（单次）。
 * 成功 0；未收到 PING HTTP2_ERR_SERVER(-1240)。
 */
int32_t http2_server_serve_h2c_ping_echo_c(int32_t client_fd) {
    io_t io;
    peer_settings_t peer;
    uint8_t hdr[9];
    uint8_t payload[16];
    uint8_t pong[32];
    int32_t round;
    int32_t ftype;
    int32_t fflags;
    int32_t stream_id;
    int32_t plen;
    int32_t pn;
    int32_t rc;

    if (client_fd < 0)
        return -1;

    rc = http2_server_handshake_h2c_c(client_fd, &peer);
    if (rc != 0)
        return rc;

    io.fd = client_fd;
    io.tls_ctx = 0;

    for (round = 0; round < 32; round++) {
        if (io_read_exact(&io, hdr, 9) != 0)
            return HTTP2_ERR_SERVER;
        if (http2_parse_frame_header_c(hdr, 9, &ftype, &fflags, &stream_id, &plen) != 0)
            return HTTP2_ERR_SERVER;
        if (plen < 0 || plen > (int32_t)sizeof(payload))
            return HTTP2_ERR_SERVER;
        if (plen > 0) {
            if (io_read_exact(&io, payload, plen) != 0)
                return HTTP2_ERR_SERVER;
        }
        if (ftype == HTTP2_TYPE_PING) {
            if ((fflags & HTTP2_FLAG_ACK) != 0)
                continue;
            if (plen != HTTP2_PING_PAYLOAD_SIZE)
                return HTTP2_ERR_SERVER;
            pn = http2_build_ping_ack_c(payload, pong, (int32_t)sizeof(pong));
            if (pn <= 0)
                return HTTP2_ERR_SERVER;
            if (io_write_all(&io, pong, pn) != 0)
                return HTTP2_ERR_SERVER;
            return 0;
        }
    }
    return HTTP2_ERR_SERVER;
}

/**
 * accept 一个 h2c 连接并回显单次 client PING（PONG）。
 * listener_fd 来自 http_listen_c；timeout_ms 为 accept 等待毫秒。
 */
int32_t http2_serve_h2c_one_ping_echo_c(int32_t listener_fd, uint32_t timeout_ms) {
#if defined(_WIN32) || defined(_WIN64)
    (void)timeout_ms;
    {
        SOCKET client = accept((SOCKET)listener_fd, NULL, NULL);
        int32_t r;
        if (client == INVALID_SOCKET)
            return -1;
        r = http2_server_serve_h2c_ping_echo_c((int32_t)client);
        SHUX_HTTP_CLOSE((int)client);
        return r;
    }
#else
    struct pollfd pfd;
    int client;
    int32_t r;
    if (listener_fd < 0)
        return -1;
    if (timeout_ms > 0) {
        pfd.fd = listener_fd;
        pfd.events = POLLIN;
        pfd.revents = 0;
        if (poll(&pfd, 1, (int)timeout_ms) <= 0)
            return -1;
    }
    client = (int)accept(listener_fd, NULL, NULL);
    if (client < 0)
        return -1;
    r = http2_server_serve_h2c_ping_echo_c(client);
    SHUX_HTTP_CLOSE(client);
    return r;
#endif
}

/**
 * h2c server PING/PONG 集成烟测：client handshake 后发 PING 读 PONG；Windows 跳过。
 */
int32_t http2_h2c_server_ping_smoke_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    return 0;
#else
    struct sockaddr_in sin;
    socklen_t slen = (socklen_t)sizeof(sin);
    pid_t pid;
    int lfd;
    uint16_t bound_port;
    int status;
    static const uint8_t opaque[8] = {0xDE, 0xAD, 0xBE, 0xEF, 0xCA, 0xFE, 0x00, 0x01};

    lfd = (int)http_listen_c(0x7f000001u, 0u, 4);
    if (lfd < 0)
        return 1;
    if (getsockname(lfd, (struct sockaddr *)&sin, &slen) != 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 2;
    }
    bound_port = ntohs(sin.sin_port);

    pid = fork();
    if (pid < 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 3;
    }
    if (pid == 0) {
        conn_t conn;
        struct sockaddr_in cli;
        int cfd;

        memset(&cli, 0, sizeof(cli));
        cli.sin_family = AF_INET;
        cli.sin_port = htons(bound_port);
        cli.sin_addr.s_addr = htonl(0x7f000001u);
        cfd = (int)socket(AF_INET, SOCK_STREAM, 0);
        if (cfd < 0)
            _exit(70);
        if (connect(cfd, (struct sockaddr *)&cli, (socklen_t)sizeof(cli)) != 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(71);
        }
        http2_conn_init_c(&conn);
        if (http2_conn_attach_h2c_c(cfd, &conn) != 0) {
            SHUX_HTTP_CLOSE(cfd);
            _exit(72);
        }
        if (http2_conn_handshake_c(&conn) != 0) {
            http2_conn_shutdown_c(&conn);
            _exit(73);
        }
        if (http2_conn_ping_c(&conn, opaque) != 0) {
            http2_conn_shutdown_c(&conn);
            _exit(74);
        }
        http2_conn_shutdown_c(&conn);
        _exit(0);
    }

    if (http2_serve_h2c_one_ping_echo_c(lfd, 5000u) != 0) {
        (void)kill(pid, SIGKILL);
        (void)waitpid(pid, NULL, 0);
        SHUX_HTTP_CLOSE(lfd);
        return 4;
    }
    if (waitpid(pid, &status, 0) != pid || !WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        SHUX_HTTP_CLOSE(lfd);
        return 5;
    }
    SHUX_HTTP_CLOSE(lfd);
    return 0;
#endif
}

/** server HPACK 动态表烟测（离线 + h2c 多 stream 集成）；0 通过。 */
int32_t http2_server_hpack_dyn_smoke_c(void) {
    if (http2_hpack_server_dyn_smoke_c() != 0)
        return 1;
    if (http2_h2c_server_multistream_smoke_c() != 0)
        return 2;
    return 0;
}

/** TLS h2 server push fork 烟测；TLS 不可用时跳过返回 0。 */
int32_t http2_server_push_tls_smoke_c(void) {
    return http2_h2_server_push_smoke_c();
}

/** server 多 stream 烟测；0 通过。 */
int32_t http2_server_multistream_smoke_c(void) {
    if (http2_h2c_server_multistream_smoke_c() != 0)
        return 1;
    return 0;
}

/** server 烟测入口（离线 + h2c/h2 集成）；0 通过。 */
int32_t http2_server_smoke_c(void) {
    if (http2_server_offline_smoke_c() != 0)
        return 1;
    if (http2_h2c_server_smoke_c() != 0)
        return 2;
    if (http2_h2_server_smoke_c() != 0)
        return 3;
    if (http2_server_multistream_smoke_c() != 0)
        return 4;
    if (http2_server_push_smoke_c() != 0)
        return 5;
    if (http2_server_push_settings_smoke_c() != 0)
        return 6;
    if (http2_server_settings_full_smoke_c() != 0)
        return 7;
    if (http2_server_hpack_dyn_smoke_c() != 0)
        return 8;
    if (http2_server_max_frame_smoke_c() != 0)
        return 9;
    if (http2_server_multistream_push_smoke_c() != 0)
        return 10;
    return 0;
}
