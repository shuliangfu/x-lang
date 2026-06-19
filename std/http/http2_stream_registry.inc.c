/**
 * std/http/http2_stream_registry.inc.c — HTTP/2 多 stream 注册表 v0（STD-HTTP-H2-v9）
 *
 * 【文件职责】连接级 stream id 分配/跟踪（奇数 client-initiated）；离线烟测。
 * 由 http2_client.inc.c 末尾 #include。
 */

/** 注册表最大 stream 槽位数。 */
#define HTTP2_STREAM_REGISTRY_MAX 8

/** 单个 stream 槽位。 */
typedef struct {
    int32_t stream_id;
    int32_t open;
} http2_stream_slot_t;

/** 连接级 stream 注册表。 */
typedef struct {
    http2_stream_slot_t slots[HTTP2_STREAM_REGISTRY_MAX];
    int32_t count;
    int32_t next_id;
} http2_stream_registry_t;

/** 初始化注册表；下一 stream 从 1 开始（奇数）。 */
void http2_stream_registry_init_c(http2_stream_registry_t *reg) {
    int32_t i;
    if (!reg)
        return;
    reg->count = 0;
    reg->next_id = 1;
    for (i = 0; i < HTTP2_STREAM_REGISTRY_MAX; i++) {
        reg->slots[i].stream_id = 0;
        reg->slots[i].open = 0;
    }
}

/** 分配新 stream id 并登记；成功返回 stream_id，表满 -1。 */
int32_t http2_stream_registry_open_c(http2_stream_registry_t *reg) {
    int32_t sid;
    if (!reg || reg->count >= HTTP2_STREAM_REGISTRY_MAX)
        return -1;
    sid = reg->next_id;
    reg->next_id += 2;
    reg->slots[reg->count].stream_id = sid;
    reg->slots[reg->count].open = 1;
    reg->count++;
    return sid;
}

/** 关闭 stream（保留槽位供查询）。 */
void http2_stream_registry_close_c(http2_stream_registry_t *reg, int32_t stream_id) {
    int32_t i;
    if (!reg || stream_id <= 0)
        return;
    for (i = 0; i < reg->count; i++) {
        if (reg->slots[i].stream_id == stream_id && reg->slots[i].open != 0) {
            reg->slots[i].open = 0;
            return;
        }
    }
}

/** stream 是否仍 open；1 是，0 否。 */
int32_t http2_stream_registry_is_open_c(const http2_stream_registry_t *reg, int32_t stream_id) {
    int32_t i;
    if (!reg || stream_id <= 0)
        return 0;
    for (i = 0; i < reg->count; i++) {
        if (reg->slots[i].stream_id == stream_id)
            return reg->slots[i].open;
    }
    return 0;
}

/** 多 stream 注册表 C 烟测；0 通过。 */
int32_t http2_stream_registry_smoke_c(void) {
    http2_stream_registry_t reg;
    int32_t s1;
    int32_t s2;
    int32_t s3;

    http2_stream_registry_init_c(&reg);
    s1 = http2_stream_registry_open_c(&reg);
    s2 = http2_stream_registry_open_c(&reg);
    s3 = http2_stream_registry_open_c(&reg);
    if (s1 != 1 || s2 != 3 || s3 != 5)
        return 1;
    if (reg.count != 3)
        return 2;
    if (http2_stream_registry_is_open_c(&reg, 3) != 1)
        return 3;
    http2_stream_registry_close_c(&reg, 3);
    if (http2_stream_registry_is_open_c(&reg, 3) != 0)
        return 4;
    return 0;
}
