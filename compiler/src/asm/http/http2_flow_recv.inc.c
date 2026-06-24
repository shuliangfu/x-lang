/**
 * std/http/http2_flow_recv.inc.c — HTTP/2 接收侧流控 v1（RFC 7540 §6.9；STD-HTTP-H2-v6）
 *
 * 【文件职责】接收 DATA 后扣减本地 recv 窗口、释放已消费字节并构建 WINDOW_UPDATE。
 * 由 http2_flow.inc.c 末尾 #include。
 */

/** 接收侧流控状态（本端尚可接收的字节容量）。 */
typedef struct {
    int32_t conn_left;
    int32_t stream_left;
} http2_flow_recv_state_t;

/** 初始化连接/流 recv 窗口为默认 65535。 */
void http2_flow_recv_init_c(http2_flow_recv_state_t *st) {
    if (!st)
        return;
    st->conn_left = HTTP2_DEFAULT_INITIAL_WINDOW;
    st->stream_left = HTTP2_DEFAULT_INITIAL_WINDOW;
}

/** 重置流 recv 窗口（保留连接窗口）。 */
void http2_flow_recv_reset_stream_c(http2_flow_recv_state_t *st, int32_t initial_window) {
    if (!st || initial_window < 0)
        return;
    st->stream_left = initial_window;
}

/**
 * 收到 DATA 后扣减 recv 窗口。
 * 窗口不足返回 -1；成功 0。
 */
int32_t http2_flow_recv_on_data_c(http2_flow_recv_state_t *st, int32_t nbytes) {
    if (!st || nbytes <= 0)
        return -1;
    if (st->conn_left < nbytes || st->stream_left < nbytes)
        return -1;
    st->conn_left -= nbytes;
    st->stream_left -= nbytes;
    return 0;
}

/**
 * 释放已消费 nbytes 并构建 WINDOW_UPDATE 帧通知对端。
 * 成功返回帧长度（13）；参数非法 -1。
 */
int32_t http2_flow_recv_release_c(http2_flow_recv_state_t *st, int32_t stream_id, int32_t nbytes,
                                  uint8_t *out, int32_t out_cap) {
    int64_t sum;
    if (!st || stream_id < 0 || nbytes <= 0 || !out)
        return -1;
    sum = (int64_t)st->conn_left + (int64_t)nbytes;
    if (sum > 0x7FFFFFFF)
        return -1;
    st->conn_left = (int32_t)sum;
    sum = (int64_t)st->stream_left + (int64_t)nbytes;
    if (sum > 0x7FFFFFFF)
        return -1;
    st->stream_left = (int32_t)sum;
    return http2_build_window_update_c(stream_id, nbytes, out, out_cap);
}

/** 接收侧流控 C 烟测；0 通过。 */
int32_t http2_flow_recv_smoke_c(void) {
    http2_flow_recv_state_t st;
    uint8_t wu[16];
    int32_t n;
    int32_t ftype = 0;
    int32_t flags = 0;
    int32_t sid = 0;
    int32_t plen = 0;

    http2_flow_recv_init_c(&st);
    if (st.conn_left != 65535 || st.stream_left != 65535)
        return 1;
    if (http2_flow_recv_on_data_c(&st, 65535) != 0)
        return 2;
    if (st.conn_left != 0 || st.stream_left != 0)
        return 3;
    n = http2_flow_recv_release_c(&st, 1, 65535, wu, (int32_t)sizeof(wu));
    if (n != 13)
        return 4;
    if (http2_parse_frame_header_c(wu, 9, &ftype, &flags, &sid, &plen) != 0)
        return 5;
    if (ftype != HTTP2_TYPE_WINDOW_UPDATE || sid != 1 || plen != 4)
        return 6;
    if (st.conn_left != 65535 || st.stream_left != 65535)
        return 7;
    return 0;
}
