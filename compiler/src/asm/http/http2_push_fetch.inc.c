/**
 * std/http/http2_push_fetch.inc.c — HTTP/2 server push 资源离线收集 v0（STD-HTTP-H2-v7）
 *
 * 【文件职责】promised stream DATA 累积；离线烟测；不含网络拉取。
 * 由 http2_push_h2c.inc.c 末尾 #include。
 */

/** 前向声明（定义于 push_h2c 主文件）。 */
int32_t http2_parse_push_promise_stream_c(const uint8_t *payload, int32_t plen,
                                          int32_t *out_promised_id);

/** push 资源视图（body 由调用方缓冲持有）。 */
typedef struct {
    int32_t promised_stream_id;
    int32_t body_len;
} http2_push_resource_t;

/** 最近一次读路径收集到的 push 资源（只读；body 在内部缓冲）。 */
typedef struct {
    int32_t promised_stream_id;
    int32_t body_len;
} http2_push_last_t;

/** push body 内部缓冲上限（v8 网络拉取）。 */
#define HTTP2_PUSH_BODY_MAX 4096

static uint8_t g_http2_push_body[HTTP2_PUSH_BODY_MAX];
static int32_t g_http2_push_body_len;
static http2_push_last_t g_http2_push_last;

/** 重置 push 收集状态（新请求前调用）。 */
void http2_push_last_reset_c(void) {
    g_http2_push_last.promised_stream_id = 0;
    g_http2_push_last.body_len = 0;
    g_http2_push_body_len = 0;
}

/** 复制最近一次 push body；成功返回 body_len，无 push 返回 0，失败 -1。 */
int32_t http2_push_last_copy_c(http2_push_last_t *out_meta, uint8_t *out_body, int32_t out_cap) {
    if (!out_meta)
        return -1;
    out_meta->promised_stream_id = g_http2_push_last.promised_stream_id;
    out_meta->body_len = g_http2_push_last.body_len;
    if (out_meta->body_len <= 0)
        return 0;
    if (!out_body || out_cap < out_meta->body_len)
        return -1;
    memcpy(out_body, g_http2_push_body, (size_t)out_meta->body_len);
    return out_meta->body_len;
}

/**
 * 将 promised stream 上的 DATA 追加到 acc。
 * 首次调用时 *inout_promised_id 可为 0，由 promised_id 参数设定。
 * stream_id 不匹配时返回 0（忽略）；成功追加返回 1；溢出 -1。
 */
int32_t http2_push_collect_data_c(int32_t promised_id, int32_t stream_id, const uint8_t *data,
                                  int32_t dlen, int32_t *inout_promised_id, uint8_t *acc,
                                  int32_t acc_cap, int32_t *acc_len) {
    if (!inout_promised_id || !acc || !acc_len || dlen < 0)
        return -1;
    if (*inout_promised_id == 0)
        *inout_promised_id = promised_id;
    if (stream_id != *inout_promised_id)
        return 0;
    if (dlen == 0)
        return 0;
    if (!data)
        return -1;
    if (*acc_len + dlen > acc_cap)
        return -1;
    memcpy(acc + *acc_len, data, (size_t)dlen);
    *acc_len += dlen;
    return 1;
}

/** push 资源离线收集 C 烟测；0 通过。 */
int32_t http2_push_fetch_smoke_c(void) {
    uint8_t acc[32];
    int32_t acc_len = 0;
    int32_t promised = 0;
    static const uint8_t chunk1[] = "push";
    static const uint8_t chunk2[] = "ed";

    if (http2_push_collect_data_c(2, 2, chunk1, 4, &promised, acc, 32, &acc_len) != 1)
        return 1;
    if (promised != 2 || acc_len != 4)
        return 2;
    if (http2_push_collect_data_c(2, 1, chunk2, 2, &promised, acc, 32, &acc_len) != 0)
        return 3;
    if (acc_len != 4)
        return 4;
    if (http2_push_collect_data_c(2, 2, chunk2, 2, &promised, acc, 32, &acc_len) != 1)
        return 5;
    if (acc_len != 6)
        return 6;
    if (memcmp(acc, "pushed", 6) != 0)
        return 7;
    return 0;
}

/** push 网络拉取路径 C 烟测（模拟读路径收集）；0 通过。 */
int32_t http2_push_network_smoke_c(void) {
    uint8_t pp[4];
    int32_t promised = 0;

    http2_push_last_reset_c();
    pp[0] = 0;
    pp[1] = 0;
    pp[2] = 0;
    pp[3] = 2;
    if (http2_parse_push_promise_stream_c(pp, 4, &promised) != 0 || promised != 2)
        return 1;
    g_http2_push_last.promised_stream_id = promised;
    if (http2_push_collect_data_c(2, 2, (const uint8_t *)"net", 3, &promised, g_http2_push_body,
                                  HTTP2_PUSH_BODY_MAX, &g_http2_push_body_len) != 1)
        return 2;
    g_http2_push_last.body_len = g_http2_push_body_len;
    {
        http2_push_last_t meta;
        uint8_t out[8];
        if (http2_push_last_copy_c(&meta, out, 8) != 3)
            return 3;
        if (meta.promised_stream_id != 2 || memcmp(out, "net", 3) != 0)
            return 4;
    }
    return 0;
}
