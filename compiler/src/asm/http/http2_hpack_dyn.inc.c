/**
 * std/http/hpack_dyn.inc.c — HPACK 动态表 v3（RFC 7541 子集；STD-HTTP-H2-v3）
 *
 * 【文件职责】固定容量 FIFO 动态表、incremental/indexed 编解码扩展。
 * 由 hpack.inc.c 末尾 #include；共享其 static 编解码 helper。
 */

/** 动态表最大条目数。 */
#define HTTP2_DYN_MAX 16
/** 静态表最大索引（RFC 7541）。 */
#define HTTP2_HPACK_STATIC_MAX 61
/** 动态表起始索引。 */
#define HTTP2_DYN_INDEX_BASE 62

/** 动态表条目。 */
typedef struct {
    uint8_t name[48];
    int32_t name_len;
    uint8_t value[128];
    int32_t value_len;
} dyn_entry_t;

static dyn_entry_t g_http2_dyn[HTTP2_DYN_MAX];
static int32_t g_http2_dyn_count = 0;

/** 清空动态表。 */
void http2_hpack_dyn_reset_c(void) {
    g_http2_dyn_count = 0;
}

/** 返回动态表当前条目数。 */
int32_t http2_hpack_dyn_count_c(void) {
    return g_http2_dyn_count;
}

/** 动态 index（≥62）→ 槽位 0=最新；失败 -1。 */
static int32_t hpack_dyn_index_to_slot(int32_t index) {
    int32_t slot;
    if (index < HTTP2_DYN_INDEX_BASE)
        return -1;
    slot = index - HTTP2_DYN_INDEX_BASE;
    if (slot >= g_http2_dyn_count)
        return -1;
    return slot;
}

/** 槽位 → HPACK 动态 index。 */
static int32_t hpack_dyn_slot_to_index(int32_t slot) {
    return HTTP2_DYN_INDEX_BASE + slot;
}

/** 将条目插入动态表头部（满则丢弃最旧）。 */
static void hpack_dyn_push(const uint8_t *name, int32_t name_len, const uint8_t *value,
                                 int32_t value_len) {
    int32_t i;
    if (!name || name_len <= 0 || name_len > (int32_t)sizeof(g_http2_dyn[0].name))
        return;
    if (!value || value_len < 0 || value_len > (int32_t)sizeof(g_http2_dyn[0].value))
        return;
    if (g_http2_dyn_count >= HTTP2_DYN_MAX) {
        for (i = HTTP2_DYN_MAX - 1; i > 0; i--)
            g_http2_dyn[i] = g_http2_dyn[i - 1];
    } else {
        for (i = g_http2_dyn_count; i > 0; i--)
            g_http2_dyn[i] = g_http2_dyn[i - 1];
        g_http2_dyn_count++;
    }
    memcpy(g_http2_dyn[0].name, name, (size_t)name_len);
    g_http2_dyn[0].name_len = name_len;
    if (value_len > 0)
        memcpy(g_http2_dyn[0].value, value, (size_t)value_len);
    g_http2_dyn[0].value_len = value_len;
}

/** 在动态表中查找完整匹配；返回 HPACK index 或 -1。 */
static int32_t hpack_dyn_find(const uint8_t *name, int32_t name_len, const uint8_t *value,
                                    int32_t value_len) {
    int32_t i;
    for (i = 0; i < g_http2_dyn_count; i++) {
        if (g_http2_dyn[i].name_len == name_len && g_http2_dyn[i].value_len == value_len &&
            memcmp(g_http2_dyn[i].name, name, (size_t)name_len) == 0 &&
            memcmp(g_http2_dyn[i].value, value, (size_t)value_len) == 0)
            return hpack_dyn_slot_to_index(i);
    }
    return -1;
}

/** 由静态/动态 index 取 name 指针与长度；成功 0。 */
static int32_t hpack_resolve_name(int32_t index, const uint8_t **out_name, int32_t *out_len) {
    const char *sn;
    int32_t slot;
    if (!out_name || !out_len)
        return -1;
    if (index > 0 && index <= HTTP2_HPACK_STATIC_MAX) {
        sn = hpack_static_name(index);
        if (!sn)
            return -1;
        *out_name = (const uint8_t *)sn;
        *out_len = (int32_t)strlen(sn);
        return 0;
    }
    slot = hpack_dyn_index_to_slot(index);
    if (slot < 0)
        return -1;
    *out_name = g_http2_dyn[slot].name;
    *out_len = g_http2_dyn[slot].name_len;
    return 0;
}

/**
 * 编码 incremental indexing + indexed name（0x40 前缀）；并写入动态表。
 * name_index 为静态表名索引（如 1=:authority）。
 */
int32_t http2_hpack_encode_literal_incremental_c(int32_t name_index, const uint8_t *value,
                                                 int32_t value_len, uint8_t *out, int32_t out_cap) {
    int32_t pos;
    int32_t n;
    const uint8_t *name;
    int32_t name_len;
    if (name_index <= 0 || !out || out_cap <= 0)
        return -1;
    if (hpack_resolve_name(name_index, &name, &name_len) != 0)
        return -1;
    n = hpack_encode_int((uint32_t)name_index, 6, 0x40, out, out_cap);
    if (n < 0)
        return -1;
    pos = n;
    n = hpack_encode_string(value, value_len, out + pos, out_cap - pos);
    if (n < 0)
        return -1;
    pos += n;
    hpack_dyn_push(name, name_len, value, value_len);
    return pos;
}

/** 编码 indexed 头（静态或动态 index≥62）。 */
int32_t http2_hpack_encode_indexed_any_c(int32_t index, uint8_t *out, int32_t out_cap) {
    if (index <= 0 || !out || out_cap <= 0)
        return -1;
    if (index > HTTP2_HPACK_STATIC_MAX) {
        if (hpack_dyn_index_to_slot(index) < 0)
            return -1;
    }
    return hpack_encode_int((uint32_t)index, 7, 0x80, out, out_cap);
}

/** 解析 method_u8（0=GET…6=OPTIONS）为 HPACK :method 编码。 */
static int32_t hpack_encode_method_u8(uint8_t method_u8, uint8_t *out, int32_t out_cap) {
    static const char *other_methods[] = {"HEAD", "PUT", "DELETE", "PATCH", "OPTIONS"};
    if (method_u8 == 0)
        return http2_hpack_encode_indexed_c(2, out, out_cap);
    if (method_u8 == 1)
        return http2_hpack_encode_indexed_c(3, out, out_cap);
    if (method_u8 >= 2 && method_u8 <= 6) {
        const char *m = other_methods[method_u8 - 2];
        return http2_hpack_encode_literal_incremental_c(2, (const uint8_t *)m, (int32_t)strlen(m),
                                                      out, out_cap);
    }
    return -1;
}

/**
 * 编码 HTTP 请求 HPACK 块（多 method；authority/path 复用动态表）。
 * method_u8 与 std.http.Method 一致（0=GET … 6=OPTIONS）。
 */
int32_t http2_hpack_encode_request_c(uint8_t method_u8, const uint8_t *authority,
                                     int32_t authority_len, const uint8_t *path, int32_t path_len,
                                     int32_t is_https, uint8_t *out, int32_t out_cap) {
    int32_t pos = 0;
    int32_t n;
    int32_t scheme_idx = 6;
    int32_t dyn_idx;
    static const uint8_t k_auth_name[] = ":authority";
    static const uint8_t k_path_name[] = ":path";
    if (!out || out_cap <= 0 || !authority || authority_len <= 0 || !path || path_len <= 0)
        return -1;
    if (is_https != 0)
        scheme_idx = 7;
    n = hpack_encode_method_u8(method_u8, out + pos, out_cap - pos);
    if (n < 0)
        return -1;
    pos += n;
    n = http2_hpack_encode_indexed_c(scheme_idx, out + pos, out_cap - pos);
    if (n < 0)
        return -1;
    pos += n;
    dyn_idx = hpack_dyn_find(k_path_name, 5, path, path_len);
    if (dyn_idx > 0) {
        n = http2_hpack_encode_indexed_any_c(dyn_idx, out + pos, out_cap - pos);
    } else if (path_len == 1 && path[0] == (uint8_t)'/') {
        n = http2_hpack_encode_literal_incremental_c(4, path, path_len, out + pos, out_cap - pos);
    } else {
        n = http2_hpack_encode_literal_incremental_c(4, path, path_len, out + pos, out_cap - pos);
    }
    if (n < 0)
        return -1;
    pos += n;
    dyn_idx = hpack_dyn_find(k_auth_name, 10, authority, authority_len);
    if (dyn_idx > 0) {
        n = http2_hpack_encode_indexed_any_c(dyn_idx, out + pos, out_cap - pos);
    } else {
        n = http2_hpack_encode_literal_incremental_c(1, authority, authority_len, out + pos,
                                                   out_cap - pos);
    }
    if (n < 0)
        return -1;
    return pos + n;
}

/** 动态表烟测：两次编码复用 authority 动态 index；0 通过。 */
int32_t http2_hpack_dyn_smoke_c(void) {
    uint8_t block1[128];
    uint8_t block2[128];
    int32_t n1;
    int32_t n2;
    const uint8_t host[] = "example.com";
    const uint8_t path[] = "/v3";
    http2_hpack_dyn_reset_c();
    n1 = http2_hpack_encode_request_c(1, host, 11, path, 3, 1, block1, (int32_t)sizeof(block1));
    if (n1 <= 0 || http2_hpack_dyn_count_c() < 2)
        return 1;
    n2 = http2_hpack_encode_request_c(0, host, 11, path, 3, 1, block2, (int32_t)sizeof(block2));
    if (n2 <= 0)
        return 2;
    if (n2 >= n1)
        return 3;
    return 0;
}
