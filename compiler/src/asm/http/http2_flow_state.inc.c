/**
 * std/http/flow_state.inc.c — HTTP/2 流控状态机 v1（RFC 7540 §6.9；STD-HTTP-H2-v5）
 *
 * 【文件职责】连接/流级发送窗口跟踪、WINDOW_UPDATE 应用、DATA 背压分块。
 * 由 flow.inc.c 末尾 #include。
 */

/** SETTINGS INITIAL_WINDOW_SIZE（0x0004）。 */
#define HTTP2_SETTING_INITIAL_WINDOW_SIZE 0x0004
/** 发送窗口耗尽（须等待 WINDOW_UPDATE）。 */
#define HTTP2_FLOW_ERR_BLOCKED (-1232)

/** 流控状态（客户端发送 DATA 视角：对端授予的窗口）。 */
typedef struct {
    int32_t conn_window;
    int32_t stream_window;
} flow_state_t;

/** 初始化连接/流窗口为默认 65535。 */
void http2_flow_state_init_c(flow_state_t *st) {
    if (!st)
        return;
    st->conn_window = HTTP2_DEFAULT_INITIAL_WINDOW;
    st->stream_window = HTTP2_DEFAULT_INITIAL_WINDOW;
}

/** 重置流窗口（保留连接窗口）；用于新 stream。 */
void http2_flow_state_reset_stream_c(flow_state_t *st, int32_t initial_window) {
    if (!st || initial_window < 0)
        return;
    st->stream_window = initial_window;
}

/** 应用 SETTINGS INITIAL_WINDOW_SIZE 到新 stream 基准。 */
void http2_flow_state_apply_initial_window_c(flow_state_t *st, int32_t initial_window) {
    if (!st || initial_window < 0)
        return;
    st->stream_window = initial_window;
}

/**
 * 解析 WINDOW_UPDATE payload（4 字节，31 位 increment）。
 * increment 须 > 0；成功 0，失败 -1。
 */
int32_t http2_parse_window_update_payload_c(const uint8_t *payload, int32_t plen,
                                              int32_t *out_increment) {
    uint32_t inc;
    if (!payload || plen != 4 || !out_increment)
        return -1;
    inc = ((uint32_t)(payload[0] & 0x7Fu) << 24) | ((uint32_t)payload[1] << 16) |
          ((uint32_t)payload[2] << 8) | (uint32_t)payload[3];
    if (inc == 0)
        return -1;
    if (inc > 0x7FFFFFFFu)
        return -1;
    *out_increment = (int32_t)inc;
    return 0;
}

/**
 * 应用 WINDOW_UPDATE：stream_id=0 增连接窗口，否则增流窗口。
 * 成功 0；increment 非法 -1。
 */
int32_t http2_flow_state_apply_window_update_c(flow_state_t *st, int32_t stream_id,
                                                 int32_t increment) {
    int64_t sum;
    if (!st || increment <= 0)
        return -1;
    if (stream_id == 0) {
        sum = (int64_t)st->conn_window + (int64_t)increment;
        if (sum > 0x7FFFFFFF)
            return -1;
        st->conn_window = (int32_t)sum;
    } else {
        sum = (int64_t)st->stream_window + (int64_t)increment;
        if (sum > 0x7FFFFFFF)
            return -1;
        st->stream_window = (int32_t)sum;
    }
    return 0;
}

/** 返回当前可发送字节数 min(conn, stream, want)；0 表示背压阻塞。 */
int32_t http2_flow_state_max_send_c(const flow_state_t *st, int32_t want) {
    int32_t avail;
    if (!st || want <= 0)
        return 0;
    avail = st->conn_window;
    if (st->stream_window < avail)
        avail = st->stream_window;
    if (avail <= 0)
        return 0;
    if (want < avail)
        return want;
    return avail;
}

/** want 字节是否可发送（1 是，0 否）。 */
int32_t http2_flow_state_can_send_c(const flow_state_t *st, int32_t want) {
    if (http2_flow_state_max_send_c(st, want) >= want)
        return 1;
    return 0;
}

/**
 * 发送 DATA 后扣减连接/流窗口。
 * 窗口不足返回 HTTP2_FLOW_ERR_BLOCKED(-1232)；成功 0。
 */
int32_t http2_flow_state_consume_send_c(flow_state_t *st, int32_t nbytes) {
    if (!st || nbytes <= 0)
        return -1;
    if (st->conn_window < nbytes || st->stream_window < nbytes)
        return HTTP2_FLOW_ERR_BLOCKED;
    st->conn_window -= nbytes;
    st->stream_window -= nbytes;
    return 0;
}

/** 流控状态机 C 烟测；0 通过。 */
int32_t http2_flow_state_smoke_c(void) {
    flow_state_t st;
    int32_t chunk;
    uint8_t payload[4];

    http2_flow_state_init_c(&st);
    if (st.conn_window != 65535 || st.stream_window != 65535)
        return 1;

    chunk = http2_flow_state_max_send_c(&st, 70000);
    if (chunk != 65535)
        return 2;
    if (http2_flow_state_consume_send_c(&st, 65535) != 0)
        return 3;
    if (http2_flow_state_can_send_c(&st, 1) != 0)
        return 4;

    if (http2_flow_state_apply_window_update_c(&st, 1, 100) != 0)
        return 5;
    if (st.stream_window != 100 || st.conn_window != 0)
        return 6;
    if (http2_flow_state_max_send_c(&st, 50) != 0)
        return 7;

    if (http2_flow_state_apply_window_update_c(&st, 0, 200) != 0)
        return 8;
    chunk = http2_flow_state_max_send_c(&st, 50);
    if (chunk != 50)
        return 9;
    if (http2_flow_state_consume_send_c(&st, 50) != 0)
        return 10;
    if (st.conn_window != 150 || st.stream_window != 50)
        return 11;

    payload[0] = 0;
    payload[1] = 0;
    payload[2] = 0;
    payload[3] = 64;
    {
        int32_t inc = 0;
        if (http2_parse_window_update_payload_c(payload, 4, &inc) != 0 || inc != 64)
            return 12;
    }

    http2_flow_state_apply_initial_window_c(&st, 16384);
    if (st.stream_window != 16384)
        return 13;
    return 0;
}
