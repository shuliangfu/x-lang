/**
 * std/http/flow.inc.c — HTTP/2 流控 v4（RFC 7540 WINDOW_UPDATE；STD-HTTP-H2-v4）
 *
 * 【文件职责】WINDOW_UPDATE 帧构建与默认窗口常量；由 http2.inc.c include。
 */

#include <stdint.h>

/** WINDOW_UPDATE 帧类型（RFC 7540 §6.9）。 */
#define HTTP2_TYPE_WINDOW_UPDATE 0x08
/** 连接级默认初始窗口（65535）。 */
#define HTTP2_DEFAULT_INITIAL_WINDOW 65535

/**
 * 构建 WINDOW_UPDATE 帧（9 字节头 + 4 字节 increment）。
 * increment 为 31 位有效（不含 reserved bit）；成功返回 13。
 */
int32_t http2_build_window_update_c(int32_t stream_id, int32_t increment, uint8_t *out,
                                    int32_t out_cap) {
    int32_t n;
    if (!out || out_cap < 13 || stream_id < 0 || increment <= 0 || increment > 0x7FFFFFFF)
        return -1;
    n = http2_build_frame_header_c(4, HTTP2_TYPE_WINDOW_UPDATE, 0, stream_id, out, out_cap);
    if (n != 9)
        return -1;
    out[9] = (uint8_t)((increment >> 24) & 0x7F);
    out[10] = (uint8_t)((increment >> 16) & 0xFF);
    out[11] = (uint8_t)((increment >> 8) & 0xFF);
    out[12] = (uint8_t)(increment & 0xFF);
    return 13;
}

/** 返回默认初始窗口大小（65535）。 */
int32_t http2_default_initial_window_c(void) { return HTTP2_DEFAULT_INITIAL_WINDOW; }

/** 流控 C 烟测：构建 stream 1 WINDOW_UPDATE(100) 并校验帧头。 */
int32_t http2_flow_control_smoke_c(void) {
    uint8_t frame[16];
    int32_t n;
    int32_t ftype = 0;
    int32_t flags = 0;
    int32_t sid = 0;
    int32_t plen = 0;
    n = http2_build_window_update_c(1, 100, frame, (int32_t)sizeof(frame));
    if (n != 13)
        return 1;
    if (http2_parse_frame_header_c(frame, 9, &ftype, &flags, &sid, &plen) != 0)
        return 2;
    if (ftype != HTTP2_TYPE_WINDOW_UPDATE || sid != 1 || plen != 4)
        return 3;
    if (frame[9] != 0 || frame[10] != 0 || frame[11] != 0 || frame[12] != 100)
        return 4;
    if (http2_default_initial_window_c() != 65535)
        return 5;
    return 0;
}

#include "http2_flow_state.inc"
#include "http2_flow_recv.inc"
