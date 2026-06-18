/**
 * std/url/url.c — URL 解析、构建、query 编解码与 resolve（STD-076）
 *
 * 【文件职责】
 * scheme/host/port/path/query/fragment 拆解与组装；
 * IPv6 bracket host；query percent 编解码；相对 URL resolve。
 */

#include <stdint.h>
#include <stdio.h>
#include <string.h>

#if defined(_WIN32) || defined(_WIN64)
#include <winsock2.h>
#include <ws2tcpip.h>
#ifndef INET6_ADDRSTRLEN
#define INET6_ADDRSTRLEN 46
#endif
#else
#include <arpa/inet.h>
#endif

/** 与 mod.su Url 结构体布局一致（字段顺序须匹配）。 */
typedef struct {
    int32_t scheme_len;
    int32_t host_len;
    int32_t port_len;
    int32_t path_len;
    int32_t query_len;
    int32_t fragment_len;
    uint8_t scheme[32];
    uint8_t host[256];
    uint8_t port[8];
    uint8_t path[512];
    uint8_t query[512];
    uint8_t fragment[256];
} url_parts_t;

/** 拷贝片段到 buf；成功 0。 */
static int url_copy_part(const uint8_t *src, int32_t len, uint8_t *dst, int32_t cap, int32_t *out_len) {
    if (len < 0 || len >= cap) return -1;
    if (len > 0) memcpy(dst, src, (size_t)len);
    dst[len] = 0;
    *out_len = len;
    return 0;
}

/** host 是否需 IPv6 方括号（含 ':' 且非 bracket 形式）。 */
static int url_host_needs_brackets(const uint8_t *host, int32_t host_len) {
    int32_t i;
    if (host_len <= 0) return 0;
    if (host[0] == (uint8_t)'[') return 0;
    for (i = 0; i < host_len; i++) {
        if (host[i] == (uint8_t)':') return 1;
    }
    return 0;
}

/** 查找 "://" 位置；无则 -1。 */
static int32_t url_find_scheme_end(const uint8_t *url, int32_t len) {
    int32_t i;
    for (i = 0; i + 2 < len; i++) {
        if (url[i] == (uint8_t)':' && url[i + 1] == (uint8_t)'/' && url[i + 2] == (uint8_t)'/') return i;
    }
    return -1;
}

/** 解析绝对/相对 URL 到 url_parts_t；成功 0。 */
int url_parse_c(const uint8_t *url, int32_t len, url_parts_t *out) {
    int32_t i = 0;
    int32_t scheme_end;
    int32_t host_start;
    int32_t authority_end;
    if (!url || len <= 0 || !out) return -1;
    memset(out, 0, sizeof(*out));
    scheme_end = url_find_scheme_end(url, len);
    if (scheme_end >= 0) {
        if (url_copy_part(url, scheme_end, out->scheme, (int32_t)sizeof(out->scheme), &out->scheme_len) != 0) return -1;
        i = scheme_end + 3;
        host_start = i;
        if (i < len && url[i] == (uint8_t)'[') {
            i++;
            while (i < len && url[i] != (uint8_t)']') i++;
            if (i >= len || url[i] != (uint8_t)']') return -1;
            i++;
            if (url_copy_part(url + host_start + 1, i - host_start - 2, out->host, (int32_t)sizeof(out->host), &out->host_len) != 0) return -1;
        } else {
            while (i < len && url[i] != (uint8_t)':' && url[i] != (uint8_t)'/' && url[i] != (uint8_t)'?' && url[i] != (uint8_t)'#') i++;
            if (url_copy_part(url + host_start, i - host_start, out->host, (int32_t)sizeof(out->host), &out->host_len) != 0) return -1;
        }
        if (i < len && url[i] == (uint8_t)':') {
            int32_t ps = ++i;
            while (i < len && url[i] >= (uint8_t)'0' && url[i] <= (uint8_t)'9') i++;
            if (url_copy_part(url + ps, i - ps, out->port, (int32_t)sizeof(out->port), &out->port_len) != 0) return -1;
        }
        authority_end = i;
        if (i >= len || url[i] != (uint8_t)'/') {
            out->path[0] = (uint8_t)'/';
            out->path[1] = 0;
            out->path_len = 1;
            i = authority_end;
        }
    } else {
        i = 0;
    }
    if (i < len && url[i] == (uint8_t)'/') {
        int32_t ps = i;
        while (i < len && url[i] != (uint8_t)'?' && url[i] != (uint8_t)'#') i++;
        if (url_copy_part(url + ps, i - ps, out->path, (int32_t)sizeof(out->path), &out->path_len) != 0) return -1;
    } else if (out->path_len == 0) {
        if (scheme_end >= 0) {
            out->path[0] = (uint8_t)'/';
            out->path[1] = 0;
            out->path_len = 1;
        } else if (i < len) {
            int32_t ps = i;
            while (i < len && url[i] != (uint8_t)'?' && url[i] != (uint8_t)'#') i++;
            if (url_copy_part(url + ps, i - ps, out->path, (int32_t)sizeof(out->path), &out->path_len) != 0) return -1;
        }
    }
    if (i < len && url[i] == (uint8_t)'?') {
        int32_t qs = ++i;
        while (i < len && url[i] != (uint8_t)'#') i++;
        if (url_copy_part(url + qs, i - qs, out->query, (int32_t)sizeof(out->query), &out->query_len) != 0) return -1;
    }
    if (i < len && url[i] == (uint8_t)'#') {
        int32_t fs = ++i;
        while (i < len) i++;
        if (url_copy_part(url + fs, i - fs, out->fragment, (int32_t)sizeof(out->fragment), &out->fragment_len) != 0) return -1;
    }
    return 0;
}

/** 组装 URL 字符串；返回写入长度，失败 -1。 */
int url_build_c(const url_parts_t *u, uint8_t *out, int32_t out_cap) {
    int n = 0;
    int32_t rem;
    if (!u || !out || out_cap <= 0) return -1;
    rem = out_cap;
    if (u->scheme_len > 0) {
        if (u->scheme_len + 3 >= rem) return -1;
        memcpy(out + n, u->scheme, (size_t)u->scheme_len);
        n += u->scheme_len;
        out[n++] = (uint8_t)':';
        out[n++] = (uint8_t)'/';
        out[n++] = (uint8_t)'/';
        rem = out_cap - n;
    }
    if (u->host_len > 0) {
        if (url_host_needs_brackets(u->host, u->host_len)) {
            if (u->host_len + 2 > rem) return -1;
            out[n++] = (uint8_t)'[';
            memcpy(out + n, u->host, (size_t)u->host_len);
            n += u->host_len;
            out[n++] = (uint8_t)']';
        } else {
            if (u->host_len > rem) return -1;
            memcpy(out + n, u->host, (size_t)u->host_len);
            n += u->host_len;
        }
        rem = out_cap - n;
    }
    if (u->port_len > 0) {
        if (1 + u->port_len > rem) return -1;
        out[n++] = (uint8_t)':';
        memcpy(out + n, u->port, (size_t)u->port_len);
        n += u->port_len;
        rem = out_cap - n;
    }
    if (u->path_len > 0) {
        if (u->path_len > rem) return -1;
        memcpy(out + n, u->path, (size_t)u->path_len);
        n += u->path_len;
        rem = out_cap - n;
    }
    if (u->query_len > 0) {
        if (1 + u->query_len > rem) return -1;
        out[n++] = (uint8_t)'?';
        memcpy(out + n, u->query, (size_t)u->query_len);
        n += u->query_len;
        rem = out_cap - n;
    }
    if (u->fragment_len > 0) {
        if (1 + u->fragment_len > rem) return -1;
        out[n++] = (uint8_t)'#';
        memcpy(out + n, u->fragment, (size_t)u->fragment_len);
        n += u->fragment_len;
    }
    if (n >= out_cap) return -1;
    out[n] = 0;
    return n;
}

/** 是否 query 未编码字符（RFC 3986 unreserved + 常见保留在 value 内）。 */
static int url_query_unreserved(uint8_t c) {
    if ((c >= (uint8_t)'a' && c <= (uint8_t)'z') || (c >= (uint8_t)'A' && c <= (uint8_t)'Z')) return 1;
    if (c >= (uint8_t)'0' && c <= (uint8_t)'9') return 1;
    if (c == (uint8_t)'-' || c == (uint8_t)'_' || c == (uint8_t)'.' || c == (uint8_t)'~') return 1;
    return 0;
}

/** query 组件 percent 编码；返回写入长度。 */
int url_query_encode_c(const uint8_t *src, int32_t src_len, uint8_t *out, int32_t out_cap) {
    int32_t i;
    int32_t n = 0;
    if (!src || !out || out_cap <= 0) return -1;
    if (src_len <= 0) return 0;
    for (i = 0; i < src_len; i++) {
        uint8_t c = src[i];
        if (url_query_unreserved(c)) {
            if (n + 1 >= out_cap) return -1;
            out[n++] = c;
        } else {
            if (n + 3 >= out_cap) return -1;
            snprintf((char *)(out + n), (size_t)(out_cap - n), "%%%02X", (unsigned)c);
            n += 3;
        }
    }
    return n;
}

/** 读取 hex。 */
static int url_hex_val(uint8_t c) {
    if (c >= (uint8_t)'0' && c <= (uint8_t)'9') return (int)(c - (uint8_t)'0');
    if (c >= (uint8_t)'a' && c <= (uint8_t)'f') return (int)(c - (uint8_t)'a' + 10);
    if (c >= (uint8_t)'A' && c <= (uint8_t)'F') return (int)(c - (uint8_t)'A' + 10);
    return -1;
}

/** query 组件 percent 解码；返回写入长度。 */
int url_query_decode_c(const uint8_t *src, int32_t src_len, uint8_t *out, int32_t out_cap) {
    int32_t i = 0;
    int32_t n = 0;
    if (!src || !out || out_cap <= 0) return -1;
    while (i < src_len) {
        if (src[i] == (uint8_t)'%' && i + 2 < src_len) {
            int hi = url_hex_val(src[i + 1]);
            int lo = url_hex_val(src[i + 2]);
            if (hi < 0 || lo < 0) return -1;
            if (n + 1 >= out_cap) return -1;
            out[n++] = (uint8_t)((hi << 4) | lo);
            i += 3;
        } else {
            if (n + 1 >= out_cap) return -1;
            out[n++] = src[i++];
        }
    }
    return n;
}

/** 路径段 pop（去掉最后非空段）。 */
static void url_path_pop_segment(uint8_t *path, int32_t *path_len) {
    int32_t len = *path_len;
    while (len > 0 && path[len - 1] == (uint8_t)'/') len--;
    while (len > 0 && path[len - 1] != (uint8_t)'/') len--;
    if (len <= 0) {
        path[0] = (uint8_t)'/';
        path[1] = 0;
        *path_len = 1;
        return;
    }
    path[len] = 0;
    *path_len = len;
}

/** 合并 base path 与相对 ref path（URL 风格 '/' 分隔）。 */
static int url_merge_paths(const uint8_t *base_path, int32_t base_len, const uint8_t *ref_path, int32_t ref_len,
                           uint8_t *out, int32_t out_cap, int32_t *out_len) {
    int32_t i = 0;
    int32_t n = 0;
    int32_t bl = base_len;
    if (!base_path || !ref_path || !out || !out_len) return -1;
    if (ref_len > 0 && ref_path[0] == (uint8_t)'/') {
        return url_copy_part(ref_path, ref_len, out, out_cap, out_len);
    }
    while (bl > 0 && base_path[bl - 1] == (uint8_t)'/') bl--;
    if (bl <= 0) {
        out[0] = (uint8_t)'/';
        n = 1;
    } else {
        if (bl >= out_cap) return -1;
        memcpy(out, base_path, (size_t)bl);
        n = bl;
        if (out[n - 1] != (uint8_t)'/') {
            if (n + 1 >= out_cap) return -1;
            out[n++] = (uint8_t)'/';
        }
    }
    while (i < ref_len) {
        if (ref_path[i] == (uint8_t)'/' ) {
            i++;
            continue;
        }
        if (i + 2 < ref_len && ref_path[i] == (uint8_t)'.' && ref_path[i + 1] == (uint8_t)'.' &&
            (i + 2 == ref_len || ref_path[i + 2] == (uint8_t)'/')) {
            url_path_pop_segment(out, &n);
            i += 2;
            if (i < ref_len && ref_path[i] == (uint8_t)'/') i++;
            continue;
        }
        if (ref_path[i] == (uint8_t)'.' && (i + 1 == ref_len || ref_path[i + 1] == (uint8_t)'/')) {
            i++;
            if (i < ref_len && ref_path[i] == (uint8_t)'/') i++;
            continue;
        }
        while (i < ref_len && ref_path[i] != (uint8_t)'/') {
            if (n + 1 >= out_cap) return -1;
            out[n++] = ref_path[i++];
        }
        if (i < ref_len && ref_path[i] == (uint8_t)'/') {
            if (n + 1 >= out_cap) return -1;
            out[n++] = (uint8_t)'/';
            i++;
        }
    }
    if (n <= 0) {
        out[0] = (uint8_t)'/';
        n = 1;
    }
    out[n] = 0;
    *out_len = n;
    return 0;
}

/** 相对 URL resolve：base + ref → out；成功 0。 */
int url_resolve_c(const url_parts_t *base, const uint8_t *ref, int32_t ref_len, url_parts_t *out) {
    url_parts_t rel;
    uint8_t merged[512];
    int32_t merged_len = 0;
    if (!base || !ref || !out) return -1;
    if (url_parse_c(ref, ref_len, &rel) != 0) return -1;
    if (rel.scheme_len > 0) {
        *out = rel;
        return 0;
    }
    *out = *base;
    if (rel.host_len > 0) {
        out->host_len = rel.host_len;
        memcpy(out->host, rel.host, (size_t)rel.host_len);
        out->host[out->host_len] = 0;
        out->port_len = rel.port_len;
        memcpy(out->port, rel.port, (size_t)rel.port_len);
        out->port[out->port_len] = 0;
    }
    if (rel.path_len > 0) {
        if (url_merge_paths(base->path, base->path_len, rel.path, rel.path_len, merged, (int32_t)sizeof(merged), &merged_len) != 0) return -1;
        if (url_copy_part(merged, merged_len, out->path, (int32_t)sizeof(out->path), &out->path_len) != 0) return -1;
    }
    if (rel.query_len > 0) {
        if (url_copy_part(rel.query, rel.query_len, out->query, (int32_t)sizeof(out->query), &out->query_len) != 0) return -1;
    }
    if (rel.fragment_len > 0) {
        if (url_copy_part(rel.fragment, rel.fragment_len, out->fragment, (int32_t)sizeof(out->fragment), &out->fragment_len) != 0) return -1;
    }
    return 0;
}

/** 将 host 片段拷贝为 NUL 结尾 C 串；成功 0。 */
static int url_host_to_nul(const uint8_t *host, int32_t host_len, char *dst, int32_t cap) {
    if (!host || !dst || host_len <= 0 || host_len >= cap) return -1;
    memcpy(dst, host, (size_t)host_len);
    dst[host_len] = '\0';
    return 0;
}

/**
 * 解析 host[0..host_len) 为 IPv6 16 字节（无方括号）。
 * 成功 0 并写入 out_16；非 IPv6 或非法返回 -1。
 * 与 std.net Ipv6Addr.b0..b15 布局一致，供 connect_ipv6 使用。
 */
int url_host_to_ipv6_c(const uint8_t *host, int32_t host_len, uint8_t *out_16) {
    char buf[256];
#if defined(_WIN32) || defined(_WIN64)
    struct in6_addr a6;
#else
    struct in6_addr a6;
#endif
    if (!host || !out_16) return -1;
    if (url_host_to_nul(host, host_len, buf, (int32_t)sizeof(buf)) != 0) return -1;
    if (inet_pton(AF_INET6, buf, &a6) != 1) return -1;
    memcpy(out_16, &a6, 16);
    return 0;
}

/**
 * 将 16 字节 IPv6 格式化为 host 文本（无方括号）；返回写入长度，失败 -1。
 */
int url_format_ipv6_host_c(const uint8_t *addr_16, uint8_t *out, int32_t out_cap) {
    char buf[INET6_ADDRSTRLEN];
    const char *p;
    size_t len;
    if (!addr_16 || !out || out_cap <= 0) return -1;
    p = inet_ntop(AF_INET6, addr_16, buf, sizeof(buf));
    if (!p) return -1;
    len = strlen(p);
    if ((int32_t)len + 1 > out_cap) return -1;
    memcpy(out, p, len + 1);
    return (int32_t)len;
}

/** host 是否为合法 IPv6 文本；1 是，0 否。 */
int url_host_is_ipv6_c(const uint8_t *host, int32_t host_len) {
    uint8_t tmp[16];
    return url_host_to_ipv6_c(host, host_len, tmp) == 0 ? 1 : 0;
}

/** STD-134：IPv6 host 解析/格式化与 bracket URL 金样。 */
int url_ipv6_host_smoke_c(void) {
    url_parts_t u;
    uint8_t addr[16];
    uint8_t host_buf[64];
    uint8_t url_buf[128];
    int n;
    static const uint8_t s_loop[] = "http://[::1]:8080/path";
    static const uint8_t s_db8[] = "http://[2001:db8::1]:443/";
    if (url_parse_c(s_loop, (int32_t)(sizeof(s_loop) - 1), &u) != 0) return 1;
    if (u.host_len != 3 || u.host[0] != (uint8_t)':' || u.host[1] != (uint8_t)':' || u.host[2] != (uint8_t)'1') return 2;
    if (url_host_to_ipv6_c(u.host, u.host_len, addr) != 0) return 3;
    if (addr[15] != 1) return 4;
    n = url_format_ipv6_host_c(addr, host_buf, 64);
    if (n != 3 || host_buf[0] != (uint8_t)':') return 5;
    if (url_host_is_ipv6_c(u.host, u.host_len) != 1) return 6;
    if (url_host_is_ipv6_c((const uint8_t *)"example.com", 11) != 0) return 7;
    if (url_parse_c(s_db8, (int32_t)(sizeof(s_db8) - 1), &u) != 0) return 8;
    if (url_host_to_ipv6_c(u.host, u.host_len, addr) != 0) return 9;
    if (url_build_c(&u, url_buf, 128) <= 0) return 10;
    if (url_buf[7] != (uint8_t)'[' || url_buf[8] != (uint8_t)'2') return 11;
    return 0;
}

/** C 烟测。 */
int url_smoke_c(void) {
    url_parts_t u;
    url_parts_t out;
    uint8_t buf[512];
    uint8_t enc[64];
    uint8_t dec[64];
    int n;
    static const uint8_t s1[] = "http://example.com:8080/path?q=1#frag";
    static const uint8_t s2[] = "http://[::1]:8080/";
    if (url_parse_c(s1, (int32_t)(sizeof(s1) - 1), &u) != 0) return 1;
    if (u.scheme_len != 4 || u.host_len != 11 || u.port_len != 4) return 2;
    if (url_build_c(&u, buf, 512) <= 0) return 3;
    if (url_parse_c(s2, (int32_t)(sizeof(s2) - 1), &u) != 0) return 4;
    if (u.host_len != 3) return 5;
    n = url_query_encode_c((const uint8_t *)"a b", 3, enc, 64);
    if (n != 5) return 6;
    if (enc[0] != (uint8_t)'a' || enc[1] != (uint8_t)'%') return 7;
    n = url_query_decode_c(enc, n, dec, 64);
    if (n != 3 || dec[0] != (uint8_t)'a' || dec[1] != (uint8_t)' ' || dec[2] != (uint8_t)'b') return 8;
    if (url_parse_c((const uint8_t *)"http://a.com/foo/bar", 20, &u) != 0) return 9;
    if (url_resolve_c(&u, (const uint8_t *)"../baz", 6, &out) != 0) return 10;
    if (out.path_len < 8) return 11;
    if (url_ipv6_host_smoke_c() != 0) return 12;
    return 0;
}
