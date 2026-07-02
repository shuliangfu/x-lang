/**
 * std/http/client.inc.c — HTTP/2 v1 客户端帧层（STD-HTTP-H2-CLIENT）
 *
 * 【文件职责】HEADERS/DATA 帧构建、GET 请求块组装、多路复用 stream 烟测。
 * 网络 h2 over TLS 仍依赖 std.net ALPN（v2）；v1 提供离线可 gate 的编解码路径。
 */

/** HEADERS 帧类型。 */
#define HTTP2_TYPE_HEADERS 0x01
/** DATA 帧类型。 */
#define HTTP2_TYPE_DATA 0x00
/** END_STREAM 标志。 */
#define HTTP2_FLAG_END_STREAM 0x01
/** END_HEADERS 标志。 */
#define HTTP2_FLAG_END_HEADERS 0x04

#include "http2_stream_registry.inc.c"

/** 构建 HEADERS 帧（9 字节头 + HPACK payload）。 */
int32_t http2_build_headers_frame_c(int32_t stream_id, int32_t flags, const uint8_t *hpack,
                                    int32_t hpack_len, uint8_t *out, int32_t out_cap) {
    int32_t n;
    if (!out || out_cap < HTTP2_FRAME_HEADER_SIZE + hpack_len)
        return -1;
    if (hpack_len > 0 && !hpack)
        return -1;
    n = http2_build_frame_header_c(hpack_len, HTTP2_TYPE_HEADERS, flags, stream_id, out, out_cap);
    if (n != HTTP2_FRAME_HEADER_SIZE)
        return -1;
    if (hpack_len > 0) {
        memcpy(out + n, hpack, (size_t)hpack_len);
        n += hpack_len;
    }
    return n;
}

/** 构建 DATA 帧。 */
int32_t http2_build_data_frame_c(int32_t stream_id, int32_t flags, const uint8_t *data,
                                 int32_t data_len, uint8_t *out, int32_t out_cap) {
    int32_t n;
    if (!out || out_cap < HTTP2_FRAME_HEADER_SIZE + data_len)
        return -1;
    if (data_len > 0 && !data)
        return -1;
    n = http2_build_frame_header_c(data_len, HTTP2_TYPE_DATA, flags, stream_id, out, out_cap);
    if (n != HTTP2_FRAME_HEADER_SIZE)
        return -1;
    if (data_len > 0) {
        memcpy(out + n, data, (size_t)data_len);
        n += data_len;
    }
    return n;
}

/**
 * 构建 HTTP 请求 HEADERS 帧。
 * method_u8：0=GET … 6=OPTIONS；has_body 非 0 时不设 END_STREAM（后续发 DATA）。
 */
int32_t http2_build_request_headers_frame_c(uint8_t method_u8, const uint8_t *authority,
                                            int32_t authority_len, const uint8_t *path,
                                            int32_t path_len, int32_t is_https, int32_t has_body,
                                            int32_t stream_id, uint8_t *out, int32_t out_cap) {
    uint8_t hpack[512];
    int32_t hlen;
    int32_t flags;
    if (!out || out_cap <= 0)
        return -1;
    http2_hpack_dyn_reset_c();
    if (method_u8 == 0 && has_body == 0) {
        hlen = http2_hpack_encode_get_request_c(authority, authority_len, path, path_len, is_https,
                                                hpack, (int32_t)sizeof(hpack));
    } else {
        hlen = http2_hpack_encode_request_c(method_u8, authority, authority_len, path, path_len,
                                            is_https, hpack, (int32_t)sizeof(hpack));
    }
    if (hlen <= 0)
        return -1;
    flags = HTTP2_FLAG_END_HEADERS;
    if (has_body == 0)
        flags |= HTTP2_FLAG_END_STREAM;
    return http2_build_headers_frame_c(stream_id, flags, hpack, hlen, out, out_cap);
}

/**
 * 构建 stream 1 的 GET HEADERS 帧（END_STREAM|END_HEADERS）。
 * 成功返回帧总字节数。
 */
int32_t http2_build_get_headers_frame_c(const uint8_t *authority, int32_t authority_len,
                                        const uint8_t *path, int32_t path_len, int32_t is_https,
                                        uint8_t *out, int32_t out_cap) {
    return http2_build_request_headers_frame_c(0, authority, authority_len, path, path_len, is_https,
                                               0, 1, out, out_cap);
}

/** v1 客户端编解码层可用（HPACK + 帧；不含 TLS ALPN 网络路径）。 */
int32_t http2_client_is_available_c(void) { return 1; }

#include "http2_multistream_client.inc.c"

/**
 * 多路复用烟测：构建 stream 1/3 两个 GET HEADERS 帧；校验 stream_id 与帧类型。
 * 0 通过。
 */
int32_t http2_client_smoke_c(void) {
    uint8_t frame1[512];
    uint8_t frame3[512];
    int32_t n1;
    int32_t n3;
    int32_t t1 = 0;
    int32_t f1 = 0;
    int32_t s1 = 0;
    int32_t p1 = 0;
    int32_t t3 = 0;
    int32_t f3 = 0;
    int32_t s3 = 0;
    int32_t p3 = 0;
    const uint8_t host[] = "example.com";
    const uint8_t path1[] = "/a";
    const uint8_t path3[] = "/b";
    uint8_t hpack1[128];
    uint8_t hpack3[128];
    int32_t h1;
    int32_t h3;

    if (http2_hpack_smoke_c() != 0)
        return 1;
    h1 = http2_hpack_encode_get_request_c(host, 11, path1, 2, 1, hpack1, (int32_t)sizeof(hpack1));
    h3 = http2_hpack_encode_get_request_c(host, 11, path3, 2, 1, hpack3, (int32_t)sizeof(hpack3));
    if (h1 <= 0 || h3 <= 0)
        return 2;
    n1 = http2_build_headers_frame_c(1, HTTP2_FLAG_END_STREAM | HTTP2_FLAG_END_HEADERS, hpack1, h1,
                                     frame1, (int32_t)sizeof(frame1));
    n3 = http2_build_headers_frame_c(3, HTTP2_FLAG_END_STREAM | HTTP2_FLAG_END_HEADERS, hpack3, h3,
                                     frame3, (int32_t)sizeof(frame3));
    if (n1 <= 0 || n3 <= 0)
        return 3;
    if (http2_parse_frame_header_c(frame1, 9, &t1, &f1, &s1, &p1) != 0)
        return 4;
    if (http2_parse_frame_header_c(frame3, 9, &t3, &f3, &s3, &p3) != 0)
        return 5;
    if (t1 != HTTP2_TYPE_HEADERS || t3 != HTTP2_TYPE_HEADERS)
        return 6;
    if (s1 != 1 || s3 != 3)
        return 7;
    if (p1 != h1 || p3 != h3)
        return 8;
    if (http2_build_get_headers_frame_c(host, 11, path1, 2, 1, frame1, (int32_t)sizeof(frame1)) <= 0)
        return 9;
    if (http2_stream_registry_smoke_c() != 0)
        return 10;
    if (http2_settings_smoke_c() != 0)
        return 11;
    if (http2_multistream_client_smoke_c() != 0)
        return 12;
    return 0;
}

#include "http2_frame_capped.inc.c"
