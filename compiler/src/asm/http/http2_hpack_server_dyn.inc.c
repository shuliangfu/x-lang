/**
 * std/http/hpack_server_dyn.inc.c — server 端 HPACK 动态表（RFC 7541；STD-HTTP-H2-v22）
 *
 * 【文件职责】按对端 HEADER_TABLE_SIZE 维护响应侧动态表，编码 :status 等响应头。
 * 由 hpack.inc.c 末尾 #include（在 client 动态表之后）。
 */

/** server 动态表最大条目数。 */
#define HTTP2_SERVER_DYN_MAX 16
/** HPACK 静态表最大索引。 */
#define HTTP2_SERVER_HPACK_STATIC_MAX 61
/** 动态表起始索引（RFC 7541）。 */
#define HTTP2_SERVER_DYN_INDEX_BASE 62

/** server 动态表单条。 */
typedef struct {
    uint8_t name[48];
    int32_t name_len;
    uint8_t value[128];
    int32_t value_len;
} server_dyn_entry_t;

/** server 响应 HPACK 编码器（与 mod.sx Http2HpackServerDyn 前缀布局一致）。 */
typedef struct {
    /** 对端 SETTINGS HEADER_TABLE_SIZE 上限（字节）。 */
    int32_t max_table_size;
    /** 当前动态表占用字节（RFC 7541 entry size 之和）。 */
    int32_t current_size;
    /** 动态表条目数。 */
    int32_t count;
    server_dyn_entry_t entries[HTTP2_SERVER_DYN_MAX];
} hpack_server_dyn_t;

/** 计算 HPACK 动态表条目占用字节（name+value+32）。 */
static int32_t http2_hpack_server_dyn_entry_size_c(int32_t name_len, int32_t value_len) {
    return name_len + value_len + 32;
}

/** 动态 index（≥62）→ 槽位 0=最新；失败 -1。 */
static int32_t http2_hpack_server_dyn_index_to_slot_c(int32_t index, int32_t count) {
    int32_t slot;
    if (index < HTTP2_SERVER_DYN_INDEX_BASE)
        return -1;
    slot = index - HTTP2_SERVER_DYN_INDEX_BASE;
    if (slot >= count)
        return -1;
    return slot;
}

/** 槽位 → HPACK 动态 index。 */
static int32_t http2_hpack_server_dyn_slot_to_index_c(int32_t slot) {
    return HTTP2_SERVER_DYN_INDEX_BASE + slot;
}

/** 从动态表尾部丢弃最旧条目直至 current_size ≤ max_table_size。 */
static void http2_hpack_server_dyn_shrink_c(hpack_server_dyn_t *ctx) {
    int32_t i;
    if (!ctx)
        return;
    while (ctx->count > 0 && ctx->current_size > ctx->max_table_size) {
        i = ctx->count - 1;
        ctx->current_size -= http2_hpack_server_dyn_entry_size_c(ctx->entries[i].name_len,
                                                                 ctx->entries[i].value_len);
        ctx->count--;
    }
}

/** 清空 server 动态表（保留 max_table_size）。 */
static void http2_hpack_server_dyn_clear_c(hpack_server_dyn_t *ctx) {
    if (!ctx)
        return;
    ctx->current_size = 0;
    ctx->count = 0;
}

/** 由 peer SETTINGS 初始化 server 响应 HPACK 编码器。 */
void http2_hpack_server_dyn_init_c(hpack_server_dyn_t *ctx,
                                   const peer_settings_t *peer) {
    int32_t sz;
    if (!ctx)
        return;
    sz = HTTP2_DEFAULT_HEADER_TABLE_SIZE;
    if (peer)
        sz = http2_peer_settings_header_table_size_c(peer);
    ctx->max_table_size = sz;
    http2_hpack_server_dyn_clear_c(ctx);
}

/** 更新动态表上限并逐出超限条目（SETTINGS 变更联动）。 */
void http2_hpack_server_dyn_set_table_size_c(hpack_server_dyn_t *ctx, int32_t size) {
    if (!ctx || size <= 0)
        return;
    ctx->max_table_size = size;
    http2_hpack_server_dyn_shrink_c(ctx);
}

/** 返回当前 HEADER_TABLE_SIZE 上限。 */
int32_t http2_hpack_server_dyn_max_size_c(const hpack_server_dyn_t *ctx) {
    if (!ctx)
        return 0;
    return ctx->max_table_size;
}

/** 返回动态表当前占用字节。 */
int32_t http2_hpack_server_dyn_table_size_c(const hpack_server_dyn_t *ctx) {
    if (!ctx)
        return 0;
    return ctx->current_size;
}

/** 返回动态表条目数。 */
int32_t http2_hpack_server_dyn_count_c(const hpack_server_dyn_t *ctx) {
    if (!ctx)
        return 0;
    return ctx->count;
}

/** 在动态表中查找完整匹配；返回 HPACK index 或 -1。 */
static int32_t http2_hpack_server_dyn_find_c(const hpack_server_dyn_t *ctx,
                                             const uint8_t *name, int32_t name_len,
                                             const uint8_t *value, int32_t value_len) {
    int32_t i;
    if (!ctx || !name || name_len <= 0 || !value || value_len < 0)
        return -1;
    for (i = 0; i < ctx->count; i++) {
        if (ctx->entries[i].name_len == name_len && ctx->entries[i].value_len == value_len &&
            memcmp(ctx->entries[i].name, name, (size_t)name_len) == 0 &&
            memcmp(ctx->entries[i].value, value, (size_t)value_len) == 0)
            return http2_hpack_server_dyn_slot_to_index_c(i);
    }
    return -1;
}

/** 由静态/动态 index 取 name；成功 0。 */
static int32_t http2_hpack_server_resolve_name_c(int32_t index, const hpack_server_dyn_t *ctx,
                                                 const uint8_t **out_name, int32_t *out_len) {
    const char *sn;
    int32_t slot;
    if (!out_name || !out_len)
        return -1;
    if (index > 0 && index <= HTTP2_SERVER_HPACK_STATIC_MAX) {
        sn = hpack_static_name(index);
        if (!sn)
            return -1;
        *out_name = (const uint8_t *)sn;
        *out_len = (int32_t)strlen(sn);
        return 0;
    }
    if (!ctx)
        return -1;
    slot = http2_hpack_server_dyn_index_to_slot_c(index, ctx->count);
    if (slot < 0)
        return -1;
    *out_name = ctx->entries[slot].name;
    *out_len = ctx->entries[slot].name_len;
    return 0;
}

/** 将条目插入动态表头部；超 HEADER_TABLE_SIZE 时逐出最旧。 */
static void http2_hpack_server_dyn_push_c(hpack_server_dyn_t *ctx, const uint8_t *name,
                                          int32_t name_len, const uint8_t *value,
                                          int32_t value_len) {
    int32_t i;
    int32_t esz;
    if (!ctx || !name || name_len <= 0 || name_len > (int32_t)sizeof(ctx->entries[0].name))
        return;
    if (!value || value_len < 0 || value_len > (int32_t)sizeof(ctx->entries[0].value))
        return;
    esz = http2_hpack_server_dyn_entry_size_c(name_len, value_len);
    while (ctx->count > 0 &&
           (ctx->current_size + esz > ctx->max_table_size || ctx->count >= HTTP2_SERVER_DYN_MAX)) {
        i = ctx->count - 1;
        ctx->current_size -= http2_hpack_server_dyn_entry_size_c(ctx->entries[i].name_len,
                                                                 ctx->entries[i].value_len);
        ctx->count--;
    }
    if (ctx->current_size + esz > ctx->max_table_size)
        return;
    if (ctx->count >= HTTP2_SERVER_DYN_MAX) {
        i = ctx->count - 1;
        ctx->current_size -= http2_hpack_server_dyn_entry_size_c(ctx->entries[i].name_len,
                                                                 ctx->entries[i].value_len);
        ctx->count--;
    }
    for (i = ctx->count; i > 0; i--)
        ctx->entries[i] = ctx->entries[i - 1];
    ctx->count++;
    memcpy(ctx->entries[0].name, name, (size_t)name_len);
    ctx->entries[0].name_len = name_len;
    if (value_len > 0)
        memcpy(ctx->entries[0].value, value, (size_t)value_len);
    ctx->entries[0].value_len = value_len;
    ctx->current_size += esz;
    http2_hpack_server_dyn_shrink_c(ctx);
}

/** server 侧 incremental indexing + indexed name；并写入动态表。 */
static int32_t http2_hpack_server_encode_literal_incremental_c(hpack_server_dyn_t *ctx,
                                                               int32_t name_index,
                                                               const uint8_t *value,
                                                               int32_t value_len, uint8_t *out,
                                                               int32_t out_cap) {
    int32_t pos;
    int32_t n;
    const uint8_t *name;
    int32_t name_len;
    if (name_index <= 0 || !out || out_cap <= 0)
        return -1;
    if (http2_hpack_server_resolve_name_c(name_index, ctx, &name, &name_len) != 0)
        return -1;
    n = hpack_encode_int((uint32_t)name_index, 6, 0x40, out, out_cap);
    if (n < 0)
        return -1;
    pos = n;
    n = hpack_encode_string(value, value_len, out + pos, out_cap - pos);
    if (n < 0)
        return -1;
    pos += n;
    http2_hpack_server_dyn_push_c(ctx, name, name_len, value, value_len);
    return pos;
}

/** server 侧 indexed 头（静态或动态 index≥62）。 */
static int32_t http2_hpack_server_encode_indexed_any_c(const hpack_server_dyn_t *ctx,
                                                         int32_t index, uint8_t *out,
                                                         int32_t out_cap) {
    if (index <= 0 || !out || out_cap <= 0)
        return -1;
    if (index > HTTP2_SERVER_HPACK_STATIC_MAX) {
        if (http2_hpack_server_dyn_index_to_slot_c(index, ctx ? ctx->count : 0) < 0)
            return -1;
    }
    return hpack_encode_int((uint32_t)index, 7, 0x80, out, out_cap);
}

/**
 * 编码 :status 响应 HPACK 块（200 用静态 indexed 8；其它码写入 server 动态表并复用）。
 * 成功返回写入字节数。
 */
int32_t http2_hpack_server_encode_status_c(hpack_server_dyn_t *ctx, int32_t status,
                                             uint8_t *out, int32_t out_cap) {
    uint8_t digits[4];
    int32_t dlen;
    int32_t dyn_idx;
    static const uint8_t k_status_name[] = ":status";
    if (!ctx || !out || out_cap <= 0 || status < 100 || status > 999)
        return -1;
    if (status == 200)
        return http2_hpack_encode_indexed_c(8, out, out_cap);
    digits[0] = (uint8_t)('0' + (status / 100) % 10);
    digits[1] = (uint8_t)('0' + (status / 10) % 10);
    digits[2] = (uint8_t)('0' + status % 10);
    dlen = 3;
    dyn_idx = http2_hpack_server_dyn_find_c(ctx, k_status_name, 7, digits, dlen);
    if (dyn_idx > 0)
        return http2_hpack_server_encode_indexed_any_c(ctx, dyn_idx, out, out_cap);
    return http2_hpack_server_encode_literal_incremental_c(ctx, 8, digits, dlen, out, out_cap);
}

/** server HPACK 动态表离线烟测；0 通过。 */
int32_t http2_hpack_server_dyn_smoke_c(void) {
    hpack_server_dyn_t ctx;
    peer_settings_t ps;
    uint8_t block1[32];
    uint8_t block2[32];
    int32_t n1;
    int32_t n2;

    http2_peer_settings_init_c(&ps);
    ps.header_table_size = 4096;
    http2_hpack_server_dyn_init_c(&ctx, &ps);
    if (http2_hpack_server_dyn_max_size_c(&ctx) != 4096)
        return 1;
    n1 = http2_hpack_server_encode_status_c(&ctx, 418, block1, (int32_t)sizeof(block1));
    if (n1 <= 0 || http2_hpack_server_dyn_count_c(&ctx) != 1)
        return 2;
    n2 = http2_hpack_server_encode_status_c(&ctx, 418, block2, (int32_t)sizeof(block2));
    if (n2 <= 0 || n2 >= n1)
        return 3;

    http2_hpack_server_dyn_set_table_size_c(&ctx, 40);
    if (http2_hpack_server_dyn_max_size_c(&ctx) != 40)
        return 4;
    if (http2_hpack_server_dyn_table_size_c(&ctx) > 40)
        return 5;

    http2_peer_settings_init_c(&ps);
    http2_hpack_server_dyn_init_c(&ctx, &ps);
    if (http2_hpack_server_dyn_max_size_c(&ctx) != HTTP2_DEFAULT_HEADER_TABLE_SIZE)
        return 6;
    return 0;
}

/** 烟测用 server 动态表句柄槽位数。 */
#define HTTP2_SERVER_DYN_HANDLE_SLOTS 4

static hpack_server_dyn_t g_http2_server_dyn_slots[HTTP2_SERVER_DYN_HANDLE_SLOTS];
static int32_t g_http2_server_dyn_slot_used[HTTP2_SERVER_DYN_HANDLE_SLOTS];

/** 由句柄 id 取内部 ctx；无效返回 NULL。 */
static hpack_server_dyn_t *http2_hpack_server_dyn_from_handle_c(int64_t handle) {
    int32_t idx;
    if (handle <= 0 || handle > HTTP2_SERVER_DYN_HANDLE_SLOTS)
        return NULL;
    idx = (int32_t)(handle - 1);
    if (g_http2_server_dyn_slot_used[idx] == 0)
        return NULL;
    return &g_http2_server_dyn_slots[idx];
}

/** 创建 server HPACK 动态表（对端 SETTINGS 联动）；失败返回 0。 */
int64_t http2_hpack_server_dyn_create_c(const peer_settings_t *peer) {
    int32_t i;
    for (i = 0; i < HTTP2_SERVER_DYN_HANDLE_SLOTS; i++) {
        if (g_http2_server_dyn_slot_used[i] == 0) {
            g_http2_server_dyn_slot_used[i] = 1;
            http2_hpack_server_dyn_init_c(&g_http2_server_dyn_slots[i], peer);
            return (int64_t)(i + 1);
        }
    }
    return 0;
}

/** 释放 server HPACK 动态表句柄。 */
void http2_hpack_server_dyn_destroy_c(int64_t handle) {
    int32_t idx;
    if (handle <= 0 || handle > HTTP2_SERVER_DYN_HANDLE_SLOTS)
        return;
    idx = (int32_t)(handle - 1);
    g_http2_server_dyn_slot_used[idx] = 0;
    http2_hpack_server_dyn_clear_c(&g_http2_server_dyn_slots[idx]);
}

/** 更新句柄动态表上限。 */
void http2_hpack_server_dyn_set_table_size_h_c(int64_t handle, int32_t size) {
    hpack_server_dyn_t *ctx = http2_hpack_server_dyn_from_handle_c(handle);
    if (ctx)
        http2_hpack_server_dyn_set_table_size_c(ctx, size);
}

/** 返回句柄 HEADER_TABLE_SIZE 上限。 */
int32_t http2_hpack_server_dyn_max_size_h_c(int64_t handle) {
    hpack_server_dyn_t *ctx = http2_hpack_server_dyn_from_handle_c(handle);
    if (!ctx)
        return 0;
    return http2_hpack_server_dyn_max_size_c(ctx);
}

/** 返回句柄动态表条目数。 */
int32_t http2_hpack_server_dyn_count_h_c(int64_t handle) {
    hpack_server_dyn_t *ctx = http2_hpack_server_dyn_from_handle_c(handle);
    if (!ctx)
        return 0;
    return http2_hpack_server_dyn_count_c(ctx);
}

/** 使用句柄动态表编码 :status。 */
int32_t http2_hpack_server_encode_status_h_c(int64_t handle, int32_t status, uint8_t *out,
                                               int32_t out_cap) {
    hpack_server_dyn_t *ctx = http2_hpack_server_dyn_from_handle_c(handle);
    if (!ctx)
        return -1;
    return http2_hpack_server_encode_status_c(ctx, status, out, out_cap);
}
