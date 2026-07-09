/**
 * std/http/settings.inc.c — HTTP/2 SETTINGS 解析与对端协商（STD-HTTP-H2-v10）
 *
 * 【文件职责】SETTINGS payload 解析、对端参数应用、双条 SETTINGS 帧构建。
 * 由 http2.inc.c 末尾 #include（在 flow.inc.c 之后）。
 */

/** 对端 SETTINGS 未协商时的默认并发 stream 上限（本实现注册表 8 槽）。 */
#define HTTP2_DEFAULT_MAX_CONCURRENT_STREAMS 100

/** SETTINGS INITIAL_WINDOW_SIZE id（0x0004）。 */
#define HTTP2_SETTING_INITIAL_WINDOW_SIZE 0x0004
/** SETTINGS ENABLE_PUSH id（0x0002；RFC 7540 §6.5.2）。 */
#define HTTP2_SETTING_ENABLE_PUSH 0x0002
/** SETTINGS HEADER_TABLE_SIZE id（0x0001）。 */
#define HTTP2_SETTING_HEADER_TABLE_SIZE 0x0001
/** SETTINGS MAX_FRAME_SIZE id（0x0005）。 */
#define HTTP2_SETTING_MAX_FRAME_SIZE 0x0005
/** SETTINGS MAX_HEADER_LIST_SIZE id（0x0006）。 */
#define HTTP2_SETTING_MAX_HEADER_LIST_SIZE 0x0006

/** RFC 7540 默认 HEADER_TABLE_SIZE。 */
#define HTTP2_DEFAULT_HEADER_TABLE_SIZE 4096
/** RFC 7540 默认/最小 MAX_FRAME_SIZE。 */
#define HTTP2_DEFAULT_MAX_FRAME_SIZE 16384

/** 对端 SETTINGS 视图（RFC 7540 §6.5）。 */
typedef struct {
    int32_t max_concurrent_streams;
    int32_t initial_window_size;
    int32_t settings_ack_sent;
    /** ENABLE_PUSH：1=允许 server push（RFC 默认），0=拒绝。 */
    int32_t enable_push;
    /** HEADER_TABLE_SIZE；0=未设置（用默认 4096）。 */
    int32_t header_table_size;
    /** MAX_FRAME_SIZE；0=未设置（用默认 16384）。 */
    int32_t max_frame_size;
    /** MAX_HEADER_LIST_SIZE；0=未设置（无限制）。 */
    int32_t max_header_list_size;
} peer_settings_t;

/** 初始化对端 SETTINGS（0 表示尚未收到，使用 RFC 默认）。 */
void http2_peer_settings_init_c(peer_settings_t *ps) {
    if (!ps)
        return;
    ps->max_concurrent_streams = 0;
    ps->initial_window_size = 0;
    ps->settings_ack_sent = 0;
    ps->enable_push = 1;
    ps->header_table_size = 0;
    ps->max_frame_size = 0;
    ps->max_header_list_size = 0;
}

/** 向 payload 写入一条 6 字节 SETTINGS 条目。 */
static void http2_write_settings_entry_c(uint8_t *out, int32_t setting_id, int32_t value) {
    out[0] = (uint8_t)((setting_id >> 8) & 0xFF);
    out[1] = (uint8_t)(setting_id & 0xFF);
    out[2] = (uint8_t)((value >> 24) & 0xFF);
    out[3] = (uint8_t)((value >> 16) & 0xFF);
    out[4] = (uint8_t)((value >> 8) & 0xFF);
    out[5] = (uint8_t)(value & 0xFF);
}

/** SETTINGS payload 中 6 字节条目数量；plen 非 6 倍数返回 -1。 */
int32_t http2_settings_entry_count_c(int32_t plen) {
    if (plen < 0 || (plen % 6) != 0)
        return -1;
    return plen / 6;
}

/**
 * 读取 SETTINGS payload 中第 entry_index 条（0-based）。
 * 成功 0；无此条目 -2；参数非法 -1。
 */
int32_t http2_parse_settings_entry_c(const uint8_t *payload, int32_t plen, int32_t entry_index,
                                     int32_t *out_id, int32_t *out_value) {
    int32_t off;
    if (!payload || entry_index < 0 || !out_id || !out_value)
        return -1;
    off = entry_index * 6;
    if (off + 6 > plen)
        return -2;
    *out_id = ((int32_t)payload[off] << 8) | (int32_t)payload[off + 1];
    *out_value = ((int32_t)payload[off + 2] << 24) | ((int32_t)payload[off + 3] << 16) |
                 ((int32_t)payload[off + 4] << 8) | (int32_t)payload[off + 5];
    return 0;
}

/** 将单条 SETTINGS 应用到对端视图（RFC 7540 §6.5.2 已识别项）。 */
void http2_peer_settings_apply_entry_c(peer_settings_t *ps, int32_t setting_id,
                                       int32_t value) {
    if (!ps)
        return;
    if (setting_id == HTTP2_SETTING_HEADER_TABLE_SIZE) {
        if (value > 0)
            ps->header_table_size = value;
        return;
    }
    if (setting_id == HTTP2_SETTING_MAX_CONCURRENT_STREAMS) {
        if (value > 0)
            ps->max_concurrent_streams = value;
        return;
    }
    if (setting_id == HTTP2_SETTING_INITIAL_WINDOW_SIZE) {
        if (value >= 0)
            ps->initial_window_size = value;
        return;
    }
    if (setting_id == HTTP2_SETTING_ENABLE_PUSH) {
        ps->enable_push = (value != 0) ? 1 : 0;
        return;
    }
    if (setting_id == HTTP2_SETTING_MAX_FRAME_SIZE) {
        if (value >= HTTP2_DEFAULT_MAX_FRAME_SIZE && value <= 16777215)
            ps->max_frame_size = value;
        return;
    }
    if (setting_id == HTTP2_SETTING_MAX_HEADER_LIST_SIZE) {
        if (value >= 0)
            ps->max_header_list_size = value;
    }
}

/** 解析完整 SETTINGS payload 并累加到 ps；成功 0，格式错 -1。 */
int32_t http2_peer_settings_consume_payload_c(const uint8_t *payload, int32_t plen,
                                              peer_settings_t *ps) {
    int32_t n;
    int32_t i;
    int32_t sid;
    int32_t val;
    if (!ps)
        return -1;
    n = http2_settings_entry_count_c(plen);
    if (n < 0)
        return -1;
    for (i = 0; i < n; i++) {
        if (http2_parse_settings_entry_c(payload, plen, i, &sid, &val) != 0)
            return -1;
        http2_peer_settings_apply_entry_c(ps, sid, val);
    }
    return 0;
}

/**
 * 构建含 MAX_CONCURRENT_STREAMS + INITIAL_WINDOW_SIZE + ENABLE_PUSH 的客户端 SETTINGS 帧。
 * enable_push：1=允许 push，0=拒绝；成功返回 27（9 头 + 18 payload）；失败 -1。
 */
int32_t http2_build_client_settings_ex_c(int32_t max_streams, int32_t initial_window,
                                         int32_t enable_push, uint8_t *out, int32_t out_cap) {
    int32_t n;
    if (!out || out_cap < 27 || max_streams <= 0 || initial_window < 0)
        return -1;
    if (enable_push != 0)
        enable_push = 1;
    n = http2_build_frame_header_c(18, HTTP2_TYPE_SETTINGS, 0, 0, out, out_cap);
    if (n != HTTP2_FRAME_HEADER_SIZE)
        return -1;
    out[9] = 0x00;
    out[10] = 0x03;
    out[11] = (uint8_t)((max_streams >> 24) & 0xFF);
    out[12] = (uint8_t)((max_streams >> 16) & 0xFF);
    out[13] = (uint8_t)((max_streams >> 8) & 0xFF);
    out[14] = (uint8_t)(max_streams & 0xFF);
    out[15] = 0x00;
    out[16] = 0x04;
    out[17] = (uint8_t)((initial_window >> 24) & 0xFF);
    out[18] = (uint8_t)((initial_window >> 16) & 0xFF);
    out[19] = (uint8_t)((initial_window >> 8) & 0xFF);
    out[20] = (uint8_t)(initial_window & 0xFF);
    out[21] = 0x00;
    out[22] = 0x02;
    out[23] = 0;
    out[24] = 0;
    out[25] = 0;
    out[26] = (uint8_t)enable_push;
    return 27;
}

/**
 * 构建含 MAX_CONCURRENT_STREAMS + INITIAL_WINDOW_SIZE 的客户端 SETTINGS 帧。
 * 成功返回 21（9 头 + 12 payload）；失败 -1。
 */
int32_t http2_build_client_settings_c(int32_t max_streams, int32_t initial_window, uint8_t *out,
                                      int32_t out_cap) {
    return http2_build_client_settings_ex_c(max_streams, initial_window, 1, out, out_cap);
}

/**
 * 构建含 MAX_FRAME_SIZE 的客户端 SETTINGS 帧（在 ex 基础上追加一条）。
 * max_frame_size≤0 时等同 ex；成功返回 33（9 头 + 24 payload）；失败 -1。
 */
int32_t http2_build_client_settings_with_max_frame_c(int32_t max_streams, int32_t initial_window,
                                                       int32_t enable_push, int32_t max_frame_size,
                                                       uint8_t *out, int32_t out_cap) {
    int32_t n;
    if (!out || out_cap < 27 || max_streams <= 0 || initial_window < 0)
        return -1;
    if (enable_push != 0)
        enable_push = 1;
    n = http2_build_client_settings_ex_c(max_streams, initial_window, enable_push, out, out_cap);
    if (n != 27)
        return n;
    if (max_frame_size <= 0)
        return 27;
    if (max_frame_size < HTTP2_DEFAULT_MAX_FRAME_SIZE)
        max_frame_size = HTTP2_DEFAULT_MAX_FRAME_SIZE;
    if (max_frame_size > 16777215)
        max_frame_size = 16777215;
    if (out_cap < 33)
        return -1;
    out[0] = 0x00;
    out[1] = 0x00;
    out[2] = 0x18;
    http2_write_settings_entry_c(out + 27, HTTP2_SETTING_MAX_FRAME_SIZE, max_frame_size);
    return 33;
}

/** 返回 SETTINGS ENABLE_PUSH 常量（2）。 */
int32_t http2_setting_enable_push_c(void) { return HTTP2_SETTING_ENABLE_PUSH; }

/** 返回 SETTINGS HEADER_TABLE_SIZE 常量（1）。 */
int32_t http2_setting_header_table_size_c(void) { return HTTP2_SETTING_HEADER_TABLE_SIZE; }

/** 返回 SETTINGS MAX_FRAME_SIZE 常量（5）。 */
int32_t http2_setting_max_frame_size_c(void) { return HTTP2_SETTING_MAX_FRAME_SIZE; }

/** 返回 SETTINGS MAX_HEADER_LIST_SIZE 常量（6）。 */
int32_t http2_setting_max_header_list_size_c(void) { return HTTP2_SETTING_MAX_HEADER_LIST_SIZE; }

/** 对端是否允许 server push（ENABLE_PUSH=0 时返回 0；未设置时 RFC 默认 1）。 */
int32_t http2_peer_settings_enable_push_c(const peer_settings_t *ps) {
    if (!ps)
        return 1;
    return ps->enable_push != 0 ? 1 : 0;
}

/** 有效 HEADER_TABLE_SIZE（未设置时 4096）。 */
int32_t http2_peer_settings_header_table_size_c(const peer_settings_t *ps) {
    if (!ps || ps->header_table_size <= 0)
        return HTTP2_DEFAULT_HEADER_TABLE_SIZE;
    return ps->header_table_size;
}

/** 有效 MAX_FRAME_SIZE（未设置时 16384）。 */
int32_t http2_peer_settings_max_frame_size_c(const peer_settings_t *ps) {
    if (!ps || ps->max_frame_size <= 0)
        return HTTP2_DEFAULT_MAX_FRAME_SIZE;
    return ps->max_frame_size;
}

/** 有效 MAX_HEADER_LIST_SIZE（未设置时 0=无限制）。 */
int32_t http2_peer_settings_max_header_list_size_c(const peer_settings_t *ps) {
    if (!ps)
        return 0;
    return ps->max_header_list_size;
}

/**
 * 构建 server 全量 SETTINGS 帧（HEADER_TABLE_SIZE/ENABLE_PUSH/MAX_CONCURRENT_STREAMS/
 * INITIAL_WINDOW_SIZE/MAX_FRAME_SIZE）；成功 39 字节；失败 -1。
 */
int32_t http2_build_server_settings_c(uint8_t *out, int32_t out_cap) {
    int32_t n;
    if (!out || out_cap < 39)
        return -1;
    n = http2_build_frame_header_c(30, HTTP2_TYPE_SETTINGS, 0, 0, out, out_cap);
    if (n != HTTP2_FRAME_HEADER_SIZE)
        return -1;
    http2_write_settings_entry_c(out + 9, HTTP2_SETTING_HEADER_TABLE_SIZE,
                                   HTTP2_DEFAULT_HEADER_TABLE_SIZE);
    http2_write_settings_entry_c(out + 15, HTTP2_SETTING_ENABLE_PUSH, 1);
    http2_write_settings_entry_c(out + 21, HTTP2_SETTING_MAX_CONCURRENT_STREAMS, 100);
    http2_write_settings_entry_c(out + 27, HTTP2_SETTING_INITIAL_WINDOW_SIZE,
                                   HTTP2_DEFAULT_INITIAL_WINDOW);
    http2_write_settings_entry_c(out + 33, HTTP2_SETTING_MAX_FRAME_SIZE,
                                   HTTP2_DEFAULT_MAX_FRAME_SIZE);
    return 39;
}

/** 有效并发 stream 上限（0=未设置时用默认 100）。 */
int32_t http2_peer_settings_max_streams_c(const peer_settings_t *ps) {
    if (!ps || ps->max_concurrent_streams <= 0)
        return HTTP2_DEFAULT_MAX_CONCURRENT_STREAMS;
    return ps->max_concurrent_streams;
}

/** 有效初始窗口（0=未设置时用 65535）。 */
int32_t http2_peer_settings_initial_window_c(const peer_settings_t *ps) {
    if (!ps || ps->initial_window_size <= 0)
        return HTTP2_DEFAULT_INITIAL_WINDOW;
    return ps->initial_window_size;
}

/** SETTINGS 解析/构建 C 烟测；0 通过。 */
int32_t http2_settings_smoke_c(void) {
    uint8_t frame[64];
    peer_settings_t ps;
    int32_t sid;
    int32_t val;
    int32_t n;

    http2_peer_settings_init_c(&ps);
    if (http2_build_client_settings_c(128, 131072, frame, 32) != 27)
        return 1;
    if (http2_settings_entry_count_c(18) != 3)
        return 2;
    if (http2_parse_settings_entry_c(frame + 9, 18, 0, &sid, &val) != 0)
        return 3;
    if (sid != HTTP2_SETTING_MAX_CONCURRENT_STREAMS || val != 128)
        return 4;
    if (http2_parse_settings_entry_c(frame + 9, 18, 1, &sid, &val) != 0)
        return 5;
    if (sid != HTTP2_SETTING_INITIAL_WINDOW_SIZE || val != 131072)
        return 6;
    if (http2_parse_settings_entry_c(frame + 9, 18, 2, &sid, &val) != 0)
        return 7;
    if (sid != HTTP2_SETTING_ENABLE_PUSH || val != 1)
        return 8;
    if (http2_peer_settings_consume_payload_c(frame + 9, 18, &ps) != 0)
        return 9;
    if (http2_peer_settings_max_streams_c(&ps) != 128)
        return 10;
    if (http2_peer_settings_initial_window_c(&ps) != 131072)
        return 11;
    if (http2_peer_settings_enable_push_c(&ps) != 1)
        return 12;
    n = http2_build_settings_one_c(HTTP2_SETTING_MAX_CONCURRENT_STREAMS, 2, frame, 32);
    if (n != 15)
        return 13;
    http2_peer_settings_init_c(&ps);
    if (http2_peer_settings_consume_payload_c(frame + 9, 6, &ps) != 0)
        return 14;
    if (http2_peer_settings_max_streams_c(&ps) != 2)
        return 15;
    n = http2_build_client_settings_ex_c(64, 65535, 0, frame, 32);
    if (n != 27)
        return 16;
    http2_peer_settings_init_c(&ps);
    if (http2_peer_settings_consume_payload_c(frame + 9, 18, &ps) != 0)
        return 17;
    if (http2_peer_settings_enable_push_c(&ps) != 0)
        return 18;
    if (http2_setting_enable_push_c() != HTTP2_SETTING_ENABLE_PUSH)
        return 19;
    if (http2_build_server_settings_c(frame, (int32_t)sizeof(frame)) != 39)
        return 20;
    if (http2_settings_entry_count_c(30) != 5)
        return 21;
    http2_peer_settings_init_c(&ps);
    if (http2_peer_settings_consume_payload_c(frame + 9, 30, &ps) != 0)
        return 22;
    if (http2_peer_settings_header_table_size_c(&ps) != HTTP2_DEFAULT_HEADER_TABLE_SIZE)
        return 23;
    if (http2_peer_settings_max_frame_size_c(&ps) != HTTP2_DEFAULT_MAX_FRAME_SIZE)
        return 24;
    if (http2_peer_settings_max_streams_c(&ps) != 100)
        return 25;
    if (http2_setting_header_table_size_c() != HTTP2_SETTING_HEADER_TABLE_SIZE)
        return 26;
    return 0;
}
