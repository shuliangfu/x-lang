/**
 * ws.inc.c — STD-031：WebSocket 客户端草案（RFC 6455 子集）
 *
 * 由 net.c #include；无外部 TLS/第三方依赖。
 * v1：Sec-WebSocket-Accept 计算、客户端 TEXT 帧编解码、握手请求缓冲构建。
 */

#include <stdint.h>
#include <string.h>
#include <stdio.h>

#define SHU_WS_GUID "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

/* ---------- 最小 SHA-1（WebSocket Accept 用） ---------- */
typedef struct {
    uint32_t state[5];
    uint32_t count[2];
    uint8_t buffer[64];
} shu_ws_sha1_ctx;

static uint32_t shu_ws_rol(uint32_t v, int bits) {
    return (v << bits) | (v >> (32 - bits));
}

static void shu_ws_sha1_transform(uint32_t state[5], const uint8_t block[64]) {
    uint32_t w[80];
    int i;
    for (i = 0; i < 16; i++) {
        w[i] = ((uint32_t)block[i * 4] << 24) | ((uint32_t)block[i * 4 + 1] << 16)
             | ((uint32_t)block[i * 4 + 2] << 8) | (uint32_t)block[i * 4 + 3];
    }
    for (i = 16; i < 80; i++)
        w[i] = shu_ws_rol(w[i - 3] ^ w[i - 8] ^ w[i - 14] ^ w[i - 16], 1);
    {
        uint32_t a = state[0], b = state[1], c = state[2], d = state[3], e = state[4];
        for (i = 0; i < 80; i++) {
            uint32_t f, k;
            if (i < 20) { f = (b & c) | ((~b) & d); k = 0x5A827999U; }
            else if (i < 40) { f = b ^ c ^ d; k = 0x6ED9EBA1U; }
            else if (i < 60) { f = (b & c) | (b & d) | (c & d); k = 0x8F1BBCDCU; }
            else { f = b ^ c ^ d; k = 0xCA62C1D6U; }
            uint32_t t = shu_ws_rol(a, 5) + f + e + k + w[i];
            e = d; d = c; c = shu_ws_rol(b, 30); b = a; a = t;
        }
        state[0] += a; state[1] += b; state[2] += c; state[3] += d; state[4] += e;
    }
}

static void shu_ws_sha1_init(shu_ws_sha1_ctx *ctx) {
    ctx->state[0] = 0x67452301U;
    ctx->state[1] = 0xEFCDAB89U;
    ctx->state[2] = 0x98BADCFEU;
    ctx->state[3] = 0x10325476U;
    ctx->state[4] = 0xC3D2E1F0U;
    ctx->count[0] = ctx->count[1] = 0;
}

static void shu_ws_sha1_update(shu_ws_sha1_ctx *ctx, const uint8_t *data, size_t len) {
    size_t i = 0;
    uint32_t j = (ctx->count[0] >> 3) & 63U;
    if ((ctx->count[0] += (uint32_t)(len << 3)) < (uint32_t)(len << 3)) ctx->count[1]++;
    ctx->count[1] += (uint32_t)(len >> 29);
    while (i < len) {
        size_t n = 64U - (size_t)j;
        if (n > len - i) n = len - i;
        memcpy(&ctx->buffer[j], data + i, n);
        i += n; j += (uint32_t)n;
        if (j == 64U) {
            shu_ws_sha1_transform(ctx->state, ctx->buffer);
            j = 0;
        }
    }
}

static void shu_ws_sha1_final(shu_ws_sha1_ctx *ctx, uint8_t digest[20]) {
    uint8_t finalcount[8];
    int i;
    for (i = 0; i < 8; i++)
        finalcount[i] = (uint8_t)((ctx->count[(i >= 4) ? 1 : 0] >> ((3 - (i & 3)) * 8)) & 0xFF);
    shu_ws_sha1_update(ctx, (const uint8_t *)"\x80", 1);
    while ((ctx->count[0] & 504U) != 448U)
        shu_ws_sha1_update(ctx, (const uint8_t *)"\0", 1);
    shu_ws_sha1_update(ctx, finalcount, 8);
    for (i = 0; i < 20; i++)
        digest[i] = (uint8_t)((ctx->state[i >> 2] >> ((3 - (i & 3)) * 8)) & 0xFF);
}

/* ---------- 最小 Base64 标准编码（20 字节 → 28 字符 + NUL） ---------- */
static const char shu_ws_b64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static int32_t shu_ws_b64_encode(const uint8_t *src, int32_t src_len, uint8_t *out, int32_t out_cap) {
    int32_t i = 0, o = 0;
    if (!src || !out || src_len < 0 || out_cap < 1) return -1;
    while (i < src_len) {
        uint32_t v = (uint32_t)src[i++] << 16;
        if (i < src_len) v |= (uint32_t)src[i++] << 8;
        if (i < src_len) v |= (uint32_t)src[i++];
        if (o + 4 >= out_cap) return -1;
        out[o++] = (uint8_t)shu_ws_b64[(v >> 18) & 63];
        out[o++] = (uint8_t)shu_ws_b64[(v >> 12) & 63];
        out[o++] = (uint8_t)(((i - 1) < src_len) ? shu_ws_b64[(v >> 6) & 63] : '=');
        out[o++] = (uint8_t)((i < src_len) ? shu_ws_b64[v & 63] : '=');
    }
    if (o >= out_cap) return -1;
    out[o] = 0;
    return o;
}

/** 计算 Sec-WebSocket-Accept；out 须 ≥ 29 字节（28 字符 + NUL）。 */
int32_t net_ws_compute_accept_c(const uint8_t *key, int32_t key_len, uint8_t *out, int32_t out_cap) {
    shu_ws_sha1_ctx ctx;
    uint8_t digest[20];
    uint8_t buf[128];
    int32_t guid_len = 36;
    if (!key || !out || key_len <= 0 || key_len > 80 || out_cap < 29) return -1;
    if (key_len + guid_len > (int32_t)sizeof(buf)) return -1;
    memcpy(buf, key, (size_t)key_len);
    memcpy(buf + key_len, SHU_WS_GUID, (size_t)guid_len);
    shu_ws_sha1_init(&ctx);
    shu_ws_sha1_update(&ctx, buf, (size_t)key_len + (size_t)guid_len);
    shu_ws_sha1_final(&ctx, digest);
    return shu_ws_b64_encode(digest, 20, out, out_cap);
}

/** 客户端 TEXT 帧编码（FIN+opcode=1，MASK=1）；返回帧总字节数，失败 -1。 */
int32_t net_ws_encode_text_frame_c(const uint8_t *payload, int32_t payload_len,
    uint8_t *out, int32_t out_cap) {
    uint8_t mask[4];
    int32_t hdr = 2;
    int32_t i;
    if (!payload || !out || payload_len < 0 || payload_len > 125) return -1;
    if (out_cap < 2 + 4 + payload_len) return -1;
    out[0] = 0x81;
    out[1] = (uint8_t)(0x80 | (payload_len & 0x7F));
    mask[0] = 0x37; mask[1] = 0xfa; mask[2] = 0x21; mask[3] = 0x3d;
    out[hdr++] = mask[0];
    out[hdr++] = mask[1];
    out[hdr++] = mask[2];
    out[hdr++] = mask[3];
    for (i = 0; i < payload_len; i++)
        out[hdr + i] = (uint8_t)(payload[i] ^ mask[i & 3]);
    return hdr + payload_len;
}

/**
 * 解析 WebSocket 帧；将负载解掩码写入 out_payload。
 * 返回 0 成功，-1 协议/缓冲错误。
 */
int32_t net_ws_decode_frame_c(const uint8_t *buf, int32_t buf_len, int32_t *out_opcode,
    uint8_t *out_payload, int32_t out_payload_cap, int32_t *out_payload_len) {
    int32_t off = 0;
    int32_t plen;
    int32_t masked;
    int32_t i;
    const uint8_t *mask;
    if (!buf || !out_opcode || !out_payload || !out_payload_len || buf_len < 2) return -1;
    *out_opcode = (int32_t)(buf[0] & 0x0F);
    masked = (buf[1] & 0x80) != 0;
    plen = (int32_t)(buf[1] & 0x7F);
    off = 2;
    if (plen == 126 || plen == 127) return -1;
    if (masked) {
        if (off + 4 > buf_len) return -1;
        mask = buf + off;
        off += 4;
    } else {
        mask = NULL;
    }
    if (off + plen > buf_len || plen > out_payload_cap) return -1;
    if (masked) {
        for (i = 0; i < plen; i++)
            out_payload[i] = (uint8_t)(buf[off + i] ^ mask[i & 3]);
    } else {
        memcpy(out_payload, buf + off, (size_t)plen);
    }
    *out_payload_len = plen;
    return 0;
}

/** 构建客户端握手 HTTP 请求到 out；返回字节数（不含 NUL），失败 -1。 */
int32_t net_ws_handshake_request_c(const uint8_t *host, const uint8_t *path, const uint8_t *key,
    uint8_t *out, int32_t out_cap) {
    int n;
    if (!host || !path || !key || !out || out_cap < 64) return -1;
    n = snprintf((char *)out, (size_t)out_cap,
        "GET %s HTTP/1.1\r\n"
        "Host: %s\r\n"
        "Upgrade: websocket\r\n"
        "Connection: Upgrade\r\n"
        "Sec-WebSocket-Key: %s\r\n"
        "Sec-WebSocket-Version: 13\r\n"
        "\r\n",
        (const char *)path, (const char *)host, (const char *)key);
    if (n <= 0 || n >= out_cap) return -1;
    return (int32_t)n;
}

/** 校验握手响应缓冲含 HTTP/1.1 101 与匹配的 Sec-WebSocket-Accept。 */
int32_t net_ws_validate_handshake_c(const uint8_t *resp, int32_t resp_len,
    const uint8_t *key, int32_t key_len) {
    uint8_t expect[32];
    char needle[40];
    int32_t n;
    if (!resp || !key || resp_len < 12 || key_len <= 0) return -1;
    if (net_ws_compute_accept_c(key, key_len, expect, (int32_t)sizeof(expect)) < 0) return -1;
    if (resp_len < 12) return -1;
    {
        int i;
        int found = 0;
        for (i = 0; i + 11 <= resp_len; i++) {
            if (memcmp(resp + i, "HTTP/1.1 101", 12) == 0) { found = 1; break; }
        }
        if (!found) return -1;
    }
    n = snprintf(needle, sizeof(needle), "Sec-WebSocket-Accept: %s", (char *)expect);
    if (n <= 0 || n >= (int32_t)sizeof(needle)) return -1;
    {
        int i;
        for (i = 0; i + n <= resp_len; i++) {
            if (memcmp(resp + i, needle, (size_t)n) == 0) return 0;
        }
    }
    return -1;
}
