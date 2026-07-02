/**
 * std/http/hpack.inc.c — HPACK v1 静态表子集（RFC 7541；STD-HTTP-H2-CLIENT）
 *
 * 【文件职责】整型编解码、indexed/literal 头字段编解码、:status 响应解析。
 * v1 静态表；v3 动态表；v4 Huffman 解码；供 client.inc.c 构建 HEADERS 帧。
 */

#include "http2_hpack_huffman.inc.c"

/** HPACK 整型编码（N 位前缀）；成功返回写入字节数，失败 -1。 */
static int32_t hpack_encode_int(uint32_t I, int32_t N, uint8_t prefix_mask, uint8_t *out,
                                      int32_t out_cap) {
    int32_t pos = 0;
    uint32_t max_prefix;
    if (!out || out_cap <= 0 || N < 1 || N > 8)
        return -1;
    max_prefix = (N >= 32) ? 0xFFFFFFFFu : ((1u << N) - 1u);
    if (I < max_prefix) {
        out[0] = (uint8_t)(prefix_mask | (uint8_t)I);
        return 1;
    }
    out[0] = (uint8_t)(prefix_mask | (uint8_t)max_prefix);
    pos = 1;
    I -= max_prefix;
    while (I >= 128u) {
        if (pos >= out_cap)
            return -1;
        out[pos++] = (uint8_t)((I & 127u) | 128u);
        I >>= 7;
    }
    if (pos >= out_cap)
        return -1;
    out[pos++] = (uint8_t)I;
    return pos;
}

/** HPACK 整型解码；成功返回消耗字节数，失败 -1。 */
static int32_t hpack_decode_int(const uint8_t *in, int32_t in_len, int32_t N, uint32_t *out_I) {
    int32_t pos = 0;
    uint32_t I;
    uint32_t max_prefix;
    uint32_t m;
    if (!in || in_len <= 0 || !out_I || N < 1 || N > 8)
        return -1;
    max_prefix = (N >= 32) ? 0xFFFFFFFFu : ((1u << N) - 1u);
    I = (uint32_t)(in[0] & (uint8_t)(max_prefix & 0xFFu));
    if (I < max_prefix) {
        *out_I = I;
        return 1;
    }
    pos = 1;
    m = 0;
    while (pos < in_len) {
        uint8_t b = in[pos++];
        I += (uint32_t)(b & 127u) << m;
        if ((b & 128u) == 0) {
            *out_I = I;
            return pos;
        }
        m += 7;
        if (m > 28)
            return -1;
    }
    return -1;
}

/** 写入 HPACK 字符串字面量（无 Huffman）；成功返回写入字节数。 */
static int32_t hpack_encode_string(const uint8_t *s, int32_t slen, uint8_t *out, int32_t out_cap) {
    int32_t n;
    int32_t pos;
    if (!out || out_cap <= 0)
        return -1;
    if (slen < 0)
        slen = 0;
    n = hpack_encode_int((uint32_t)slen, 7, 0x00, out, out_cap);
    if (n < 0)
        return -1;
    pos = n;
    if (slen > 0) {
        if (!s || pos + slen > out_cap)
            return -1;
        memcpy(out + pos, s, (size_t)slen);
        pos += slen;
    }
    return pos;
}

/** 解码 HPACK 字符串字面量；成功返回消耗字节数，value 写入 out_val。 */
static int32_t hpack_decode_string(const uint8_t *in, int32_t in_len, uint8_t *out_val,
                                         int32_t out_cap, int32_t *out_vlen) {
    int32_t n;
    uint32_t slen = 0;
    int32_t pos;
    if (!in || in_len <= 0 || !out_vlen)
        return -1;
    n = hpack_decode_int(in, in_len, 7, &slen);
    if (n < 0)
        return -1;
    if ((in[0] & 0x80u) != 0) {
        int32_t dn;
        if (!out_val || out_cap <= 0)
            return -1;
        dn = http2_hpack_huffman_decode_c(in + pos, (int32_t)slen, out_val, out_cap);
        if (dn < 0)
            return -1;
        *out_vlen = dn;
        return pos + (int32_t)slen;
    }
    *out_vlen = (int32_t)slen;
    pos = n;
    if (slen == 0)
        return pos;
    if (pos + (int32_t)slen > in_len)
        return -1;
    if (out_val && out_cap >= (int32_t)slen)
        memcpy(out_val, in + pos, (size_t)slen);
    return pos + (int32_t)slen;
}

/** HPACK 静态表项（RFC 7541 Appendix A 子集）。 */
static const char *hpack_static_name(int32_t index) {
    switch (index) {
    case 1: return ":authority";
    case 2: return ":method";
    case 3: return ":method";
    case 4: return ":path";
    case 5: return ":path";
    case 6: return ":scheme";
    case 7: return ":scheme";
    case 8: return ":status";
    default: return NULL;
    }
}

static const char *hpack_static_value(int32_t index) {
    switch (index) {
    case 1: return "";
    case 2: return "GET";
    case 3: return "POST";
    case 4: return "/";
    case 5: return "/index.html";
    case 6: return "http";
    case 7: return "https";
    case 8: return "200";
    default: return NULL;
    }
}

/**
 * 编码 indexed 头字段（静态表 index 1..8 子集可扩展至 61）。
 * 成功返回写入字节数。
 */
int32_t http2_hpack_encode_indexed_c(int32_t index, uint8_t *out, int32_t out_cap) {
    if (!out || out_cap <= 0 || index <= 0)
        return -1;
    return hpack_encode_int((uint32_t)index, 7, 0x80, out, out_cap);
}

/**
 * 编码 literal 头字段（不索引，indexed name）。
 * name_index 为静态表名索引；value 为字段值。
 */
int32_t http2_hpack_encode_literal_c(int32_t name_index, const uint8_t *value, int32_t value_len,
                                     uint8_t *out, int32_t out_cap) {
    int32_t pos;
    int32_t n;
    if (!out || out_cap <= 0 || name_index <= 0)
        return -1;
    if (value_len < 0)
        value_len = 0;
    n = hpack_encode_int((uint32_t)name_index, 4, 0x00, out, out_cap);
    if (n < 0)
        return -1;
    pos = n;
    n = hpack_encode_string(value, value_len, out + pos, out_cap - pos);
    if (n < 0)
        return -1;
    return pos + n;
}

/**
 * 编码 GET 请求 HPACK 块（:method GET + :scheme + :path + :authority）。
 * is_https 非 0 时使用 https 静态表项。
 */
int32_t http2_hpack_encode_get_request_c(const uint8_t *authority, int32_t authority_len,
                                         const uint8_t *path, int32_t path_len, int32_t is_https,
                                         uint8_t *out, int32_t out_cap) {
    int32_t pos = 0;
    int32_t n;
    int32_t scheme_idx = 6;
    if (!out || out_cap <= 0 || !authority || authority_len <= 0 || !path || path_len <= 0)
        return -1;
    if (is_https != 0)
        scheme_idx = 7;
    n = http2_hpack_encode_indexed_c(2, out + pos, out_cap - pos); /* :method GET */
    if (n < 0)
        return -1;
    pos += n;
    n = http2_hpack_encode_indexed_c(scheme_idx, out + pos, out_cap - pos);
    if (n < 0)
        return -1;
    pos += n;
    if (path_len == 1 && path[0] == (uint8_t)'/') {
        n = http2_hpack_encode_indexed_c(4, out + pos, out_cap - pos);
    } else {
        n = http2_hpack_encode_literal_c(4, path, path_len, out + pos, out_cap - pos);
    }
    if (n < 0)
        return -1;
    pos += n;
    n = http2_hpack_encode_literal_c(1, authority, authority_len, out + pos, out_cap - pos);
    if (n < 0)
        return -1;
    return pos + n;
}

/**
 * 从 HPACK 头块解析 :status 三位码；成功 0，未找到 -2，失败 -1。
 */
int32_t http2_hpack_decode_status_c(const uint8_t *block, int32_t block_len, int32_t *out_status) {
    int32_t pos = 0;
    if (!block || block_len <= 0 || !out_status)
        return -1;
    *out_status = 0;
    while (pos < block_len) {
        uint8_t b = block[pos];
        if ((b & 0x80u) != 0) {
            uint32_t idx = 0;
            int32_t n = hpack_decode_int(block + pos, block_len - pos, 7, &idx);
            const char *name;
            const char *val;
            if (n < 0)
                return -1;
            pos += n;
            name = hpack_static_name((int32_t)idx);
            val = hpack_static_value((int32_t)idx);
            if (name && val && strcmp(name, ":status") == 0) {
                *out_status = (int32_t)(val[0] - '0') * 100 + (int32_t)(val[1] - '0') * 10 +
                              (int32_t)(val[2] - '0');
                return 0;
            }
            continue;
        }
        if ((b & 0xF0u) == 0x00u) {
            uint32_t name_idx = 0;
            int32_t vlen = 0;
            int32_t n;
            uint8_t vbuf[16];
            n = hpack_decode_int(block + pos, block_len - pos, 4, &name_idx);
            if (n < 0)
                return -1;
            pos += n;
            n = hpack_decode_string(block + pos, block_len - pos, vbuf, (int32_t)sizeof(vbuf),
                                        &vlen);
            if (n < 0)
                return -1;
            pos += n;
            if (name_idx == 8 && vlen == 3) {
                *out_status =
                    (int32_t)(vbuf[0] - '0') * 100 + (int32_t)(vbuf[1] - '0') * 10 + (int32_t)(vbuf[2] - '0');
                return 0;
            }
            continue;
        }
        return -1; /* v1 仅支持 indexed / literal without indexing */
    }
    return -2;
}

/**
 * 从 HPACK 请求头块解析 :method 与 :path（v1 静态表/literal 子集）。
 * 成功 0 且 out_is_get 非 0 表示 GET；非 GET 返回 1；解析失败 -1。
 */
int32_t http2_hpack_decode_get_request_c(const uint8_t *block, int32_t block_len, int32_t *out_is_get,
                                         uint8_t *out_path, int32_t path_cap, int32_t *out_path_len) {
    int32_t pos = 0;
    int32_t is_get = 0;
    int32_t got_method = 0;
    int32_t path_len = 0;
    if (!block || block_len <= 0 || !out_is_get)
        return -1;
    if (out_path_len)
        *out_path_len = 0;
    *out_is_get = 0;
    while (pos < block_len) {
        uint8_t b = block[pos];
        if ((b & 0x80u) != 0) {
            uint32_t idx = 0;
            int32_t n = hpack_decode_int(block + pos, block_len - pos, 7, &idx);
            const char *name;
            const char *val;
            if (n < 0)
                return -1;
            pos += n;
            name = hpack_static_name((int32_t)idx);
            val = hpack_static_value((int32_t)idx);
            if (name && val && strcmp(name, ":method") == 0) {
                got_method = 1;
                is_get = (strcmp(val, "GET") == 0) ? 1 : 0;
            }
            if (name && val && strcmp(name, ":path") == 0 && out_path && path_cap > 0) {
                int32_t vlen = (int32_t)strlen(val);
                if (vlen >= path_cap)
                    vlen = path_cap - 1;
                memcpy(out_path, val, (size_t)vlen);
                out_path[vlen] = '\0';
                path_len = vlen;
            }
            continue;
        }
        if ((b & 0xF0u) == 0x00u) {
            uint32_t name_idx = 0;
            int32_t vlen = 0;
            int32_t n;
            uint8_t vbuf[SHUX_HTTP_PATH_MAX];
            const char *name;
            n = hpack_decode_int(block + pos, block_len - pos, 4, &name_idx);
            if (n < 0)
                return -1;
            pos += n;
            n = hpack_decode_string(block + pos, block_len - pos, vbuf, (int32_t)sizeof(vbuf),
                                          &vlen);
            if (n < 0)
                return -1;
            pos += n;
            name = hpack_static_name((int32_t)name_idx);
            if (name && strcmp(name, ":method") == 0) {
                got_method = 1;
                is_get = (vlen == 3 && vbuf[0] == 'G' && vbuf[1] == 'E' && vbuf[2] == 'T') ? 1 : 0;
            }
            if (name && strcmp(name, ":path") == 0 && out_path && path_cap > 0) {
                if (vlen >= path_cap)
                    vlen = path_cap - 1;
                memcpy(out_path, vbuf, (size_t)vlen);
                out_path[vlen] = '\0';
                path_len = vlen;
            }
            continue;
        }
        return -1;
    }
    if (got_method == 0)
        return -1;
    if (is_get != 0)
        *out_is_get = 1;
    if (out_path_len)
        *out_path_len = path_len;
    return (is_get != 0) ? 0 : 1;
}

/**
 * 编码 :status 响应 HPACK 块（200 用 indexed 8；其它三位码用 literal）。
 * 成功返回写入字节数。
 */
int32_t http2_hpack_encode_status_c(int32_t status, uint8_t *out, int32_t out_cap) {
    uint8_t digits[4];
    int32_t dlen;
    if (!out || out_cap <= 0 || status < 100 || status > 999)
        return -1;
    if (status == 200)
        return http2_hpack_encode_indexed_c(8, out, out_cap);
    digits[0] = (uint8_t)('0' + (status / 100) % 10);
    digits[1] = (uint8_t)('0' + (status / 10) % 10);
    digits[2] = (uint8_t)('0' + status % 10);
    dlen = 3;
    return http2_hpack_encode_literal_c(8, digits, dlen, out, out_cap);
}

/** HPACK 编解码 C 烟测；0 通过。 */
int32_t http2_hpack_smoke_c(void) {
    uint8_t block[128];
    int32_t blen;
    int32_t st = 0;
    const uint8_t host[] = "example.com";
    const uint8_t path[] = "/index.html";
    const uint8_t resp[] = {0x88};
    blen = http2_hpack_encode_get_request_c(host, 11, path, 12, 1, block, (int32_t)sizeof(block));
    if (blen <= 0)
        return 1;
    if (http2_hpack_decode_status_c(resp, (int32_t)sizeof(resp), &st) != 0 || st != 200)
        return 2;
    {
        int32_t is_get = 0;
        uint8_t path[64];
        int32_t plen = 0;
        if (http2_hpack_decode_get_request_c(block, blen, &is_get, path, 64, &plen) != 0 || is_get == 0)
            return 3;
        if (http2_hpack_encode_status_c(200, block, (int32_t)sizeof(block)) != 1 || block[0] != 0x88)
            return 4;
    }
    return 0;
}

#include "http2_hpack_dyn.inc.c"
#include "http2_hpack_server_dyn.inc.c"
