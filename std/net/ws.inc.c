/**
 * ws.inc.c — STD-031：WebSocket 客户端草案（RFC 6455 子集）
 *
 * 由 net.c #include；无外部 TLS/第三方依赖。
 * v1：Sec-WebSocket-Accept 计算、客户端 TEXT 帧编解码、握手请求缓冲构建。
 */

#include <stdint.h>
#include <string.h>
#include <stdio.h>

#define SHUX_WS_GUID "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

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
  /* 64 位 bit 长度大端写入 finalcount（count[1]=高 32 位，count[0]=低 32 位）。 */
  for (i = 0; i < 8; i++) {
    finalcount[i] = (uint8_t)((ctx->count[(i >= 4) ? 0 : 1] >> ((3 - (i & 3)) * 8)) & 0xFF);
  }
  shu_ws_sha1_update(ctx, (const uint8_t *)"\x80", 1);
  while ((ctx->count[0] & 504U) != 448U) {
    shu_ws_sha1_update(ctx, (const uint8_t *)"\0", 1);
  }
  shu_ws_sha1_update(ctx, finalcount, 8);
  for (i = 0; i < 20; i++) {
    digest[i] = (uint8_t)((ctx->state[i >> 2] >> ((3 - (i & 3)) * 8)) & 0xFF);
  }
}

/* ---------- 最小 Base64 标准编码（20 字节 → 28 字符 + NUL） ---------- */
static const char shu_ws_b64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static int32_t shu_ws_b64_encode(const uint8_t *src, int32_t src_len, uint8_t *out, int32_t out_cap) {
    int32_t i = 0;
    int32_t o = 0;
    if (!src || !out || src_len < 0 || out_cap < 1)
        return -1;
    while (i < src_len) {
        uint32_t v = 0;
        int32_t rem = src_len - i;
        v = (uint32_t)src[i++] << 16;
        if (rem >= 2)
            v |= (uint32_t)src[i++] << 8;
        if (rem >= 3)
            v |= (uint32_t)src[i++];
        if (o + 4 >= out_cap)
            return -1;
        out[o++] = (uint8_t)shu_ws_b64[(v >> 18) & 63];
        out[o++] = (uint8_t)shu_ws_b64[(v >> 12) & 63];
        out[o++] = (uint8_t)(rem >= 2 ? shu_ws_b64[(v >> 6) & 63] : '=');
        out[o++] = (uint8_t)(rem >= 3 ? shu_ws_b64[v & 63] : '=');
    }
    if (o >= out_cap)
        return -1;
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
    memcpy(buf + key_len, SHUX_WS_GUID, (size_t)guid_len);
    shu_ws_sha1_init(&ctx);
    shu_ws_sha1_update(&ctx, buf, (size_t)key_len + (size_t)guid_len);
    shu_ws_sha1_final(&ctx, digest);
    return shu_ws_b64_encode(digest, 20, out, out_cap);
}

/** 客户端 MASKED 帧编码公共路径（FIN=1，payload ≤ 125）。 */
static int32_t net_ws_encode_masked_frame_c(uint8_t first_byte, const uint8_t *payload, int32_t payload_len,
                                            uint8_t *out, int32_t out_cap) {
    uint8_t mask[4];
    int32_t hdr = 2;
    int32_t i;
    if (!out || payload_len < 0 || payload_len > 125) return -1;
    if (payload_len > 0 && !payload) return -1;
    if (out_cap < 2 + 4 + payload_len) return -1;
    out[0] = first_byte;
    out[1] = (uint8_t)(0x80 | (payload_len & 0x7F));
    mask[0] = 0x37;
    mask[1] = 0xfa;
    mask[2] = 0x21;
    mask[3] = 0x3d;
    out[hdr++] = mask[0];
    out[hdr++] = mask[1];
    out[hdr++] = mask[2];
    out[hdr++] = mask[3];
    for (i = 0; i < payload_len; i++)
        out[hdr + i] = (uint8_t)(payload[i] ^ mask[i & 3]);
    return hdr + payload_len;
}

/** 客户端 TEXT 帧编码（FIN+opcode=1，MASK=1）；返回帧总字节数，失败 -1。 */
int32_t net_ws_encode_text_frame_c(const uint8_t *payload, int32_t payload_len,
    uint8_t *out, int32_t out_cap) {
    if (payload_len < 0) return -1;
    if (payload_len > 0 && !payload) return -1;
    return net_ws_encode_masked_frame_c(0x81, payload, payload_len, out, out_cap);
}

/** 客户端 BINARY 帧编码（FIN+opcode=2，MASK=1）；返回帧总字节数，失败 -1。 */
int32_t net_ws_encode_binary_frame_c(const uint8_t *payload, int32_t payload_len,
                                      uint8_t *out, int32_t out_cap) {
    if (payload_len < 0) return -1;
    if (payload_len > 0 && !payload) return -1;
    return net_ws_encode_masked_frame_c(0x82, payload, payload_len, out, out_cap);
}

/** 客户端 PING 帧（opcode=9）；payload 可为空（心跳）。 */
int32_t net_ws_encode_ping_frame_c(const uint8_t *payload, int32_t payload_len, uint8_t *out, int32_t out_cap) {
    return net_ws_encode_masked_frame_c(0x89, payload, payload_len, out, out_cap);
}

/** 客户端 PONG 帧（opcode=10）；通常 echo ping 负载。 */
int32_t net_ws_encode_pong_frame_c(const uint8_t *payload, int32_t payload_len, uint8_t *out, int32_t out_cap) {
    return net_ws_encode_masked_frame_c(0x8A, payload, payload_len, out, out_cap);
}

/**
 * 客户端 CLOSE 帧（opcode=8）。
 * status_code < 0 且无 reason 时发空负载；否则 payload 为 2 字节大端 status + 可选 UTF-8 reason。
 */
int32_t net_ws_encode_close_frame_c(int32_t status_code, const uint8_t *reason, int32_t reason_len,
                                    uint8_t *out, int32_t out_cap) {
    uint8_t pl[128];
    int32_t plen = 0;
    if (reason_len < 0) return -1;
    if (reason_len > 0 && !reason) return -1;
    if (status_code >= 0) {
        if (reason_len + 2 > 125) return -1;
        pl[0] = (uint8_t)((status_code >> 8) & 0xFF);
        pl[1] = (uint8_t)(status_code & 0xFF);
        plen = 2;
        if (reason_len > 0) {
            memcpy(pl + 2, reason, (size_t)reason_len);
            plen += reason_len;
        }
    } else {
        if (reason_len > 0) return -1;
        plen = 0;
    }
    return net_ws_encode_masked_frame_c(0x88, plen > 0 ? pl : NULL, plen, out, out_cap);
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
    char needle[64];
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

/* ---------- 客户端 connect / 握手 / 读写（STD-031 v2） ---------- */

#define WS_ERR_TLS_NOT_IMPL (-1221)

/** 传输层：明文 TCP 或 TLS 封装。 */
typedef struct {
    int32_t fd;
    int64_t tls_ctx;
} shu_ws_io_t;

/** 关闭 TCP fd（握手失败清理）。 */
static void shu_ws_close_fd(int32_t fd) {
    if (fd < 0) return;
    (void)net_close_socket_c(fd);
}

/** 关闭传输层（TLS + TCP）。 */
static void shu_ws_io_close(shu_ws_io_t *io) {
    if (!io) return;
    if (io->tls_ctx != 0) {
        net_tls_close_c(io->tls_ctx);
        io->tls_ctx = 0;
    }
    shu_ws_close_fd(io->fd);
    io->fd = -1;
}

/** 阻塞写满 len 字节；失败 -1。 */
static int32_t shu_ws_tcp_send_all(int32_t fd, const uint8_t *buf, int32_t len, uint32_t timeout_ms) {
    int32_t sent = 0;
    if (fd < 0 || !buf || len < 0) return -1;
    while (sent < len) {
        if (timeout_ms != 0 && shu_net_poll_writable(fd, timeout_ms) != 0) return -1;
#if defined(_WIN32) || defined(_WIN64)
        {
            int n = send((SOCKET)fd, (const char *)(buf + sent), len - sent, 0);
            if (n <= 0) return -1;
            sent += n;
        }
#else
        {
            ssize_t n = send(fd, buf + (size_t)sent, (size_t)(len - sent), 0);
            if (n <= 0) return -1;
            sent += (int32_t)n;
        }
#endif
    }
    return sent;
}

/** 阻塞读满 len 字节；失败 -1。 */
static int32_t shu_ws_tcp_read_all(int32_t fd, uint8_t *buf, int32_t len, uint32_t timeout_ms) {
    int32_t got = 0;
    if (fd < 0 || !buf || len < 0) return -1;
    while (got < len) {
        if (timeout_ms != 0 && shu_net_poll_readable(fd, timeout_ms) != 0) return -1;
#if defined(_WIN32) || defined(_WIN64)
        {
            int n = recv((SOCKET)fd, (char *)(buf + got), len - got, 0);
            if (n <= 0) return -1;
            got += n;
        }
#else
        {
            ssize_t n = recv(fd, buf + (size_t)got, (size_t)(len - got), 0);
            if (n <= 0) return -1;
            got += (int32_t)n;
        }
#endif
    }
    return got;
}

/** 传输层写满 len 字节；失败 -1。 */
static int32_t shu_ws_io_send_all(shu_ws_io_t *io, const uint8_t *buf, int32_t len, uint32_t timeout_ms) {
    int32_t sent = 0;
    if (!io || io->fd < 0 || !buf || len < 0) return -1;
    if (io->tls_ctx != 0) {
        while (sent < len) {
            int32_t n = net_tls_write_c(io->tls_ctx, buf + sent, len - sent);
            if (n <= 0) return -1;
            sent += n;
        }
        return sent;
    }
    return shu_ws_tcp_send_all(io->fd, buf, len, timeout_ms);
}

/** 传输层读满 len 字节；失败 -1。 */
static int32_t shu_ws_io_read_all(shu_ws_io_t *io, uint8_t *buf, int32_t len, uint32_t timeout_ms) {
    int32_t got = 0;
    if (!io || io->fd < 0 || !buf || len < 0) return -1;
    if (io->tls_ctx != 0) {
        while (got < len) {
            int32_t n = net_tls_read_c(io->tls_ctx, buf + got, len - got);
            if (n <= 0) return -1;
            got += n;
        }
        return got;
    }
    return shu_ws_tcp_read_all(io->fd, buf, len, timeout_ms);
}

/** 传输层读若干字节（握手收 HTTP 头）；失败 -1。 */
static int32_t shu_ws_io_read_some(shu_ws_io_t *io, uint8_t *buf, int32_t cap, uint32_t timeout_ms) {
    if (!io || io->fd < 0 || !buf || cap <= 0) return -1;
    if (io->tls_ctx != 0) return net_tls_read_c(io->tls_ctx, buf, cap);
    if (timeout_ms != 0 && shu_net_poll_readable(io->fd, timeout_ms) != 0) return -1;
#if defined(_WIN32) || defined(_WIN64)
    return recv((SOCKET)io->fd, (char *)buf, cap, 0);
#else
    return (int32_t)recv(io->fd, buf, (size_t)cap, 0);
#endif
}

/** 查找 HTTP 头结束 \\r\\n\\r\\n；返回结束位置（不含）或 0。 */
static int32_t shu_ws_header_end(const uint8_t *buf, int32_t len) {
    int32_t i;
    if (!buf || len < 4) return 0;
    for (i = 3; i < len; i++) {
        if (buf[i - 3] == '\r' && buf[i - 2] == '\n' && buf[i - 1] == '\r' && buf[i] == '\n') return i + 1;
    }
    return 0;
}

/** 填充 16 字节 CSPRNG（链入 std/random/random.o 时可用）。 */
static int32_t shu_ws_fill_random16(uint8_t *buf) {
    extern int32_t random_fill_bytes_c(uint8_t *buf, int32_t len);
    return random_fill_bytes_c(buf, 16) == 16 ? 0 : -1;
}

/** 生成 Sec-WebSocket-Key（16 随机字节 Base64）；成功返回 24，失败 -1。 */
int32_t net_ws_generate_key_c(uint8_t *out, int32_t out_cap) {
    uint8_t rnd[16];
    if (!out || out_cap < 25) return -1;
    if (shu_ws_fill_random16(rnd) != 0) return -1;
    return shu_ws_b64_encode(rnd, 16, out, out_cap);
}

/**
 * 在已连接传输层上完成 WebSocket 客户端握手。
 * key/key_len 为空时自动生成 Key；成功 0。
 */
static int32_t net_ws_client_handshake_io_c(shu_ws_io_t *io, const uint8_t *host, const uint8_t *path,
                                            const uint8_t *key, int32_t key_len, uint32_t timeout_ms) {
    uint8_t req[512];
    uint8_t resp[2048];
    uint8_t key_auto[32];
    const uint8_t *use_key = key;
    int32_t use_key_len = key_len;
    int32_t req_len;
    int32_t resp_len = 0;
    int32_t hdr_end;

    if (!io || io->fd < 0 || !host || !path) return -1;
    if (!key || key_len <= 0) {
        int32_t kl = net_ws_generate_key_c(key_auto, (int32_t)sizeof(key_auto));
        if (kl != 24) return -1;
        use_key = key_auto;
        use_key_len = 24;
    }
    if (io->tls_ctx == 0 && shu_net_set_blocking(io->fd, 1) != 0) return -1;
    req_len = net_ws_handshake_request_c(host, path, use_key, req, (int32_t)sizeof(req));
    if (req_len < 0) return -1;
    if (shu_ws_io_send_all(io, req, req_len, timeout_ms) != req_len) return -1;
    while (resp_len < (int32_t)sizeof(resp) - 1) {
        int32_t chunk = shu_ws_io_read_some(io, resp + resp_len, (int32_t)sizeof(resp) - 1 - resp_len, timeout_ms);
        if (chunk <= 0) return -1;
        resp_len += chunk;
        hdr_end = shu_ws_header_end(resp, resp_len);
        if (hdr_end > 0) {
            resp_len = hdr_end;
            break;
        }
    }
    if (resp_len <= 0) return -1;
    if (net_ws_validate_handshake_c(resp, resp_len, use_key, use_key_len) != 0) return -1;
    if (io->tls_ctx == 0) (void)shu_net_set_blocking(io->fd, 0);
    return 0;
}

/** 在已连接 TCP fd 上完成 WebSocket 客户端握手（明文 ws://）。 */
int32_t net_ws_client_handshake_c(int32_t fd, const uint8_t *host, const uint8_t *path, const uint8_t *key,
                                  int32_t key_len, uint32_t timeout_ms) {
    shu_ws_io_t io = { fd, 0 };
    return net_ws_client_handshake_io_c(&io, host, path, key, key_len, timeout_ms);
}

/** TCP 连接 + WebSocket 握手一站式；成功返回 fd，失败 -1。port=0 时用 80。 */
int32_t net_ws_connect_c(const uint8_t *host, uint32_t port, const uint8_t *path, const uint8_t *key,
                         int32_t key_len, uint32_t timeout_ms) {
    uint32_t addr;
    int32_t fd;
    if (!host || !path) return -1;
    addr = net_resolve_ipv4_c((const char *)host);
    if (addr == 0) return -1;
    if (port == 0) port = 80;
    fd = net_tcp_connect_c(addr, port, timeout_ms);
    if (fd < 0) return -1;
    if (net_ws_client_handshake_c(fd, host, path, key, key_len, timeout_ms) != 0) {
        shu_ws_close_fd(fd);
        return -1;
    }
    return fd;
}

/** wss:// 一站式：TCP + TLS + 握手；成功返回 fd 并写 *out_tls_ctx，失败 -1 或 WS_ERR_TLS_NOT_IMPL。 */
int32_t net_ws_connect_tls_c(const uint8_t *host, uint32_t port, const uint8_t *path, const uint8_t *key,
                             int32_t key_len, uint32_t timeout_ms, int64_t *out_tls_ctx) {
    uint32_t addr;
    int32_t fd;
    int64_t tls;
    shu_ws_io_t io;

    if (!host || !path || !out_tls_ctx) return -1;
    *out_tls_ctx = 0;
    if (net_tls_is_available_c() == 0) return WS_ERR_TLS_NOT_IMPL;
    addr = net_resolve_ipv4_c((const char *)host);
    if (addr == 0) return -1;
    if (port == 0) port = 443;
    fd = net_tcp_connect_c(addr, port, timeout_ms);
    if (fd < 0) return -1;
    tls = net_tls_connect_client_c(fd, (const char *)host);
    if (tls == 0) {
        shu_ws_close_fd(fd);
        return -1;
    }
    io.fd = fd;
    io.tls_ctx = tls;
    if (net_ws_client_handshake_io_c(&io, host, path, key, key_len, timeout_ms) != 0) {
        shu_ws_io_close(&io);
        return -1;
    }
    *out_tls_ctx = tls;
    return fd;
}

/** 解析 ws(s)://host[:port]/path；out_secure=1 为 wss；默认端口 80/443。 */
int32_t net_ws_parse_url_c(const uint8_t *url, int32_t url_len, char *host, int32_t host_cap, char *path,
                           int32_t path_cap, uint32_t *out_port, int32_t *out_secure) {
    int32_t i = 0;
    uint32_t default_port = 80;
    int32_t secure = 0;

    if (!url || url_len < 5 || !host || !path || !out_port || host_cap < 2 || path_cap < 2) return -1;
    if (out_secure) *out_secure = 0;
    if (url_len >= 6 && url[0] == 'w' && url[1] == 's' && url[2] == 's' && url[3] == ':' && url[4] == '/' &&
        url[5] == '/') {
        i = 6;
        default_port = 443;
        secure = 1;
    } else if (url_len >= 5 && url[0] == 'w' && url[1] == 's' && url[2] == ':' && url[3] == '/' && url[4] == '/') {
        i = 5;
    } else {
        return -1;
    }
    if (out_secure) *out_secure = secure;
    {
        int32_t host_start = i;
        while (i < url_len && url[i] != ':' && url[i] != '/') i++;
        int32_t host_len = i - host_start;
        if (host_len <= 0 || host_len >= host_cap) return -1;
        memcpy(host, url + host_start, (size_t)host_len);
        host[host_len] = '\0';
    }
    if (i < url_len && url[i] == ':') {
        uint32_t port = 0;
        i++;
        if (i >= url_len) return -1;
        while (i < url_len && url[i] != '/') {
            if (url[i] < '0' || url[i] > '9') return -1;
            port = port * 10u + (uint32_t)(url[i] - '0');
            if (port > 65535u) return -1;
            i++;
        }
        if (port == 0) return -1;
        *out_port = port;
    } else {
        *out_port = default_port;
    }
    if (i < url_len && url[i] == '/') {
        int32_t path_len = url_len - i;
        if (path_len >= path_cap) return -1;
        memcpy(path, url + i, (size_t)path_len);
        path[path_len] = '\0';
    } else {
        path[0] = '/';
        path[1] = '\0';
    }
    return 0;
}

/** ws(s):// URL 一站式连接；成功 0 并写 out_fd/out_tls_ctx（明文时 tls=0）。 */
int32_t net_ws_connect_url_c(const uint8_t *url, int32_t url_len, const uint8_t *key, int32_t key_len,
                             uint32_t timeout_ms, int32_t *out_fd, int64_t *out_tls_ctx) {
    char host[256];
    char path[512];
    uint32_t port = 0;
    int32_t secure = 0;
    int32_t fd;

    if (!url || !out_fd || !out_tls_ctx) return -1;
    *out_fd = -1;
    *out_tls_ctx = 0;
    if (net_ws_parse_url_c(url, url_len, host, (int32_t)sizeof(host), path, (int32_t)sizeof(path), &port,
                           &secure) != 0)
        return -1;
    if (secure) {
        fd = net_ws_connect_tls_c((const uint8_t *)host, port, (const uint8_t *)path, key, key_len, timeout_ms,
                                  out_tls_ctx);
        if (fd < 0) return fd;
        *out_fd = fd;
        return 0;
    }
    fd = net_ws_connect_c((const uint8_t *)host, port, (const uint8_t *)path, key, key_len, timeout_ms);
    if (fd < 0) return -1;
    *out_fd = fd;
    return 0;
}

/** WSS 是否可用（同 std.net TLS 后端探测）。 */
int32_t net_ws_tls_is_available_c(void) {
    return net_tls_is_available_c();
}

/** URL 解析烟测。 */
int32_t net_ws_parse_url_smoke_c(void) {
    char host[64];
    char path[64];
    uint32_t port = 0;
    int32_t sec = 0;
    static const uint8_t u1[] = "ws://localhost/chat";
    static const uint8_t u2[] = "wss://example.com:8443/ws";

    if (net_ws_parse_url_c(u1, (int32_t)(sizeof(u1) - 1), host, 64, path, 64, &port, &sec) != 0) return 1;
    if (sec != 0 || port != 80 || strcmp(host, "localhost") != 0 || strcmp(path, "/chat") != 0) return 2;
    if (net_ws_parse_url_c(u2, (int32_t)(sizeof(u2) - 1), host, 64, path, 64, &port, &sec) != 0) return 3;
    if (sec != 1 || port != 8443 || strcmp(host, "example.com") != 0 || strcmp(path, "/ws") != 0) return 4;
    return 0;
}

/** 编码并发送 TEXT 帧；tls_ctx=0 为明文；成功返回 payload_len。 */
int32_t net_ws_write_text_c(int32_t fd, int64_t tls_ctx, const uint8_t *payload, int32_t payload_len) {
    uint8_t frame[140];
    int32_t flen;
    shu_ws_io_t io = { fd, tls_ctx };
    if (fd < 0 || payload_len < 0) return -1;
    if (payload_len > 0 && !payload) return -1;
    flen = net_ws_encode_text_frame_c(payload, payload_len, frame, (int32_t)sizeof(frame));
    if (flen < 0) return -1;
    if (shu_ws_io_send_all(&io, frame, flen, 5000) != flen) return -1;
    return payload_len;
}

/** 编码并发送 BINARY 帧；tls_ctx=0 为明文；成功返回 payload_len。 */
int32_t net_ws_write_binary_c(int32_t fd, int64_t tls_ctx, const uint8_t *payload, int32_t payload_len) {
    uint8_t frame[140];
    int32_t flen;
    shu_ws_io_t io = { fd, tls_ctx };
    if (fd < 0 || payload_len < 0) return -1;
    if (payload_len > 0 && !payload) return -1;
    flen = net_ws_encode_binary_frame_c(payload, payload_len, frame, (int32_t)sizeof(frame));
    if (flen < 0) return -1;
    if (shu_ws_io_send_all(&io, frame, flen, 5000) != flen) return -1;
    return payload_len;
}

/** 从传输层读一帧；tls_ctx=0 为明文；成功 0。 */
int32_t net_ws_read_frame_c(int32_t fd, int64_t tls_ctx, int32_t *out_opcode, uint8_t *out_payload, int32_t out_cap,
                            int32_t *out_payload_len, uint32_t timeout_ms) {
    uint8_t wire[140];
    int32_t masked;
    int32_t plen;
    int32_t off;
    shu_ws_io_t io = { fd, tls_ctx };
    if (fd < 0 || !out_opcode || !out_payload || !out_payload_len) return -1;
    if (shu_ws_io_read_all(&io, wire, 2, timeout_ms) != 2) return -1;
    masked = (wire[1] & 0x80) != 0;
    plen = (int32_t)(wire[1] & 0x7F);
    if (plen == 126 || plen == 127) return -1;
    off = 2;
    if (masked) {
        if (shu_ws_io_read_all(&io, wire + 2, 4, timeout_ms) != 4) return -1;
        off = 6;
    }
    if (plen > out_cap || plen + off > (int32_t)sizeof(wire)) return -1;
    if (plen > 0 && shu_ws_io_read_all(&io, wire + off, plen, timeout_ms) != plen) return -1;
    return net_ws_decode_frame_c(wire, off + plen, out_opcode, out_payload, out_cap, out_payload_len);
}

/* ---------- 服务端 Upgrade accept（STD-031 v3） ---------- */

/** 不区分大小写比较 a[0..n) 与 ASCII 字面量 b。 */
static int32_t shu_ws_ci_eq_lit(const uint8_t *a, const char *b, int32_t n) {
    int32_t i;
    if (!a || !b || n <= 0) return 0;
    for (i = 0; i < n; i++) {
        char ca = (char)a[i];
        char cb = b[i];
        if (ca >= 'A' && ca <= 'Z') ca = (char)(ca + 32);
        if (cb >= 'A' && cb <= 'Z') cb = (char)(cb + 32);
        if (ca != cb) return 0;
    }
    return 1;
}

/** 扫描 HTTP 头是否含 Upgrade: websocket（不区分大小写）。 */
static int32_t shu_ws_request_is_upgrade(const uint8_t *req, int32_t req_len) {
    static const char upg[] = "upgrade:";
    int32_t i;
    if (!req || req_len < 24) return 0;
    for (i = 0; i + 8 <= req_len; i++) {
        if (!shu_ws_ci_eq_lit(req + i, upg, 8)) continue;
        {
            int32_t j = i + 8;
            while (j < req_len && (req[j] == ' ' || req[j] == '\t')) j++;
            if (j + 9 <= req_len && shu_ws_ci_eq_lit(req + j, "websocket", 9)) return 1;
        }
    }
    return 0;
}

/** 从 HTTP Upgrade 请求提取 Sec-WebSocket-Key；成功返回 key 长度。 */
int32_t net_ws_extract_key_from_request_c(const uint8_t *req, int32_t req_len, uint8_t *out_key, int32_t out_cap) {
    static const char needle[] = "Sec-WebSocket-Key:";
    int32_t i;
    int32_t key_len = 0;
    if (!req || req_len < 20 || !out_key || out_cap < 2) return -1;
    for (i = 0; i + 18 <= req_len; i++) {
        if (!shu_ws_ci_eq_lit(req + i, needle, 18)) continue;
        {
            int32_t j = i + 18;
            while (j < req_len && (req[j] == ' ' || req[j] == '\t')) j++;
            key_len = 0;
            while (j < req_len && req[j] != '\r' && req[j] != '\n' && key_len < out_cap - 1) {
                out_key[key_len++] = req[j++];
            }
            out_key[key_len] = '\0';
            return key_len > 0 ? key_len : -1;
        }
    }
    return -1;
}

/** 校验客户端 WebSocket Upgrade 请求；成功 0。 */
int32_t net_ws_validate_upgrade_request_c(const uint8_t *req, int32_t req_len) {
    static const char ver[] = "Sec-WebSocket-Version:";
    int32_t i;
    int32_t has_ver13 = 0;
    if (!req || req_len < 32) return -1;
    if (!shu_ws_ci_eq_lit(req, "GET ", 4)) return -1;
    if (!shu_ws_request_is_upgrade(req, req_len)) return -1;
    {
        uint8_t key_probe[80];
        if (net_ws_extract_key_from_request_c(req, req_len, key_probe, (int32_t)sizeof(key_probe)) <= 0) return -1;
    }
    for (i = 0; i + 22 <= req_len; i++) {
        if (!shu_ws_ci_eq_lit(req + i, ver, 22)) continue;
        {
            int32_t j = i + 22;
            while (j < req_len && (req[j] == ' ' || req[j] == '\t')) j++;
            if (j + 2 <= req_len && req[j] == '1' && req[j + 1] == '3') has_ver13 = 1;
        }
    }
    return has_ver13 ? 0 : -1;
}

/** 服务端：对已有 Upgrade 请求缓冲回复 101 并交接到帧层；成功 0。 */
int32_t net_ws_server_accept_request_c(int32_t fd, int64_t tls_ctx, const uint8_t *req, int32_t req_len,
                                       uint32_t timeout_ms) {
    uint8_t key[80];
    uint8_t accept[32];
    uint8_t resp[256];
    int32_t kl;
    int32_t n;
    shu_ws_io_t io = { fd, tls_ctx };
    if (fd < 0 || !req || req_len <= 0) return -1;
    if (net_ws_validate_upgrade_request_c(req, req_len) != 0) return -1;
    kl = net_ws_extract_key_from_request_c(req, req_len, key, (int32_t)sizeof(key));
    if (kl <= 0) return -1;
    if (net_ws_compute_accept_c(key, kl, accept, (int32_t)sizeof(accept)) < 0) return -1;
    n = snprintf((char *)resp, sizeof(resp),
                 "HTTP/1.1 101 Switching Protocols\r\n"
                 "Upgrade: websocket\r\n"
                 "Connection: Upgrade\r\n"
                 "Sec-WebSocket-Accept: %s\r\n"
                 "\r\n",
                 (char *)accept);
    if (n <= 0 || n >= (int32_t)sizeof(resp)) return -1;
    return shu_ws_io_send_all(&io, resp, n, timeout_ms) == n ? 0 : -1;
}

/** 服务端：从 fd 读取 Upgrade 请求并完成 101 握手；成功 0。 */
int32_t net_ws_server_handshake_c(int32_t fd, int64_t tls_ctx, uint32_t timeout_ms) {
    uint8_t req[2048];
    int32_t req_len = 0;
    int32_t hdr_end;
    shu_ws_io_t io = { fd, tls_ctx };
    if (fd < 0) return -1;
    if (tls_ctx == 0 && shu_net_set_blocking(fd, 1) != 0) return -1;
    while (req_len < (int32_t)sizeof(req) - 1) {
        int32_t chunk = shu_ws_io_read_some(&io, req + req_len, (int32_t)sizeof(req) - 1 - req_len, timeout_ms);
        if (chunk <= 0) return -1;
        req_len += chunk;
        hdr_end = shu_ws_header_end(req, req_len);
        if (hdr_end > 0) {
            req_len = hdr_end;
            break;
        }
    }
    if (net_ws_server_accept_request_c(fd, tls_ctx, req, req_len, timeout_ms) != 0) return -1;
    if (tls_ctx == 0) (void)shu_net_set_blocking(fd, 0);
    return 0;
}

/** 服务端 TEXT 帧编码（MASK=0，payload ≤ 125）。 */
int32_t net_ws_encode_server_text_frame_c(const uint8_t *payload, int32_t payload_len, uint8_t *out,
                                          int32_t out_cap) {
    if (payload_len < 0 || payload_len > 125) return -1;
    if (payload_len > 0 && !payload) return -1;
    if (!out || out_cap < 2 + payload_len) return -1;
    out[0] = 0x81;
    out[1] = (uint8_t)(payload_len & 0x7F);
    if (payload_len > 0) memcpy(out + 2, payload, (size_t)payload_len);
    return 2 + payload_len;
}

/** 服务端 BINARY 帧编码（MASK=0，payload ≤ 125）。 */
int32_t net_ws_encode_server_binary_frame_c(const uint8_t *payload, int32_t payload_len, uint8_t *out,
                                            int32_t out_cap) {
    if (payload_len < 0 || payload_len > 125) return -1;
    if (payload_len > 0 && !payload) return -1;
    if (!out || out_cap < 2 + payload_len) return -1;
    out[0] = 0x82;
    out[1] = (uint8_t)(payload_len & 0x7F);
    if (payload_len > 0) memcpy(out + 2, payload, (size_t)payload_len);
    return 2 + payload_len;
}

/** 服务端发送 TEXT 帧（无掩码）；成功返回 payload_len。 */
int32_t net_ws_write_server_text_c(int32_t fd, int64_t tls_ctx, const uint8_t *payload, int32_t payload_len) {
    uint8_t frame[140];
    int32_t flen;
    shu_ws_io_t io = { fd, tls_ctx };
    if (fd < 0 || payload_len < 0) return -1;
    if (payload_len > 0 && !payload) return -1;
    flen = net_ws_encode_server_text_frame_c(payload, payload_len, frame, (int32_t)sizeof(frame));
    if (flen < 0) return -1;
    if (shu_ws_io_send_all(&io, frame, flen, 5000) != flen) return -1;
    return payload_len;
}

/** 服务端发送 BINARY 帧（无掩码）；成功返回 payload_len。 */
int32_t net_ws_write_server_binary_c(int32_t fd, int64_t tls_ctx, const uint8_t *payload, int32_t payload_len) {
    uint8_t frame[140];
    int32_t flen;
    shu_ws_io_t io = { fd, tls_ctx };
    if (fd < 0 || payload_len < 0) return -1;
    if (payload_len > 0 && !payload) return -1;
    flen = net_ws_encode_server_binary_frame_c(payload, payload_len, frame, (int32_t)sizeof(frame));
    if (flen < 0) return -1;
    if (shu_ws_io_send_all(&io, frame, flen, 5000) != flen) return -1;
    return payload_len;
}

#if !defined(_WIN32) && !defined(_WIN64)
/** 握手烟测服务端上下文。 */
typedef struct {
    int fd;
} shu_ws_hs_srv_ctx;

/** 读取客户端握手并回复 101（socketpair 烟测用）。 */
static void *shu_ws_hs_srv_thread(void *arg) {
    shu_ws_hs_srv_ctx *ctx = (shu_ws_hs_srv_ctx *)arg;
    (void)net_ws_server_handshake_c(ctx->fd, 0, 5000);
    return NULL;
}
#endif

/** 服务端 accept 烟测（请求解析 + socketpair 101）。 */
int32_t net_ws_server_accept_smoke_c(void) {
    static const uint8_t req[] = "GET /ws HTTP/1.1\r\n"
                                 "Host: localhost\r\n"
                                 "Upgrade: websocket\r\n"
                                 "Connection: Upgrade\r\n"
                                 "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n"
                                 "Sec-WebSocket-Version: 13\r\n"
                                 "\r\n";
    uint8_t key[32];
    if (net_ws_validate_upgrade_request_c(req, (int32_t)(sizeof(req) - 1)) != 0) return 1;
    if (net_ws_extract_key_from_request_c(req, (int32_t)(sizeof(req) - 1), key, 32) != 24) return 2;
#if !defined(_WIN32) && !defined(_WIN64)
    {
        int sp[2];
        pthread_t th;
        int32_t sr;
        static const uint8_t host[] = "localhost";
        static const uint8_t path[] = "/ws";
        static const uint8_t wskey[] = "dGhlIHNhbXBsZSBub25jZQ==";
        uint8_t creq[512];
        uint8_t resp[512];
        int32_t req_len;
        int32_t resp_len = 0;
        shu_ws_hs_srv_ctx srv;
        if (socketpair(AF_UNIX, SOCK_STREAM, 0, sp) != 0) return 3;
        srv.fd = sp[1];
        if (pthread_create(&th, NULL, shu_ws_hs_srv_thread, &srv) != 0) {
            shu_ws_close_fd(sp[0]);
            shu_ws_close_fd(sp[1]);
            return 4;
        }
        req_len = net_ws_handshake_request_c(host, path, wskey, creq, (int32_t)sizeof(creq));
        if (req_len < 0 || shu_ws_tcp_send_all(sp[0], creq, req_len, 5000) != req_len) {
            shu_ws_close_fd(sp[0]);
            shu_ws_close_fd(sp[1]);
            pthread_join(th, NULL);
            return 5;
        }
        while (resp_len < (int32_t)sizeof(resp) - 1) {
            int32_t chunk = (int32_t)recv(sp[0], resp + resp_len, (size_t)(sizeof(resp) - 1 - (size_t)resp_len), 0);
            if (chunk <= 0) break;
            resp_len += chunk;
            if (shu_ws_header_end(resp, resp_len) > 0) break;
        }
        sr = net_ws_validate_handshake_c(resp, resp_len, wskey, 24);
        pthread_join(th, NULL);
        shu_ws_close_fd(sp[0]);
        shu_ws_close_fd(sp[1]);
        if (sr != 0) return 6;
    }
#endif
    return 0;
}

#if !defined(_WIN32) && !defined(_WIN64)
/** socketpair 烟测：客户端 net_ws_client_handshake_c；Windows 跳过返回 0。 */
int32_t net_ws_client_handshake_smoke_c(void) {
    int sp[2];
    pthread_t th;
    shu_ws_hs_srv_ctx srv;
    int32_t r;
    static const uint8_t host[] = "localhost";
    static const uint8_t path[] = "/ws";
    static const uint8_t key[] = "dGhlIHNhbXBsZSBub25jZQ==";

    if (socketpair(AF_UNIX, SOCK_STREAM, 0, sp) != 0) return 1;
    srv.fd = sp[1];
    if (pthread_create(&th, NULL, shu_ws_hs_srv_thread, &srv) != 0) {
        shu_ws_close_fd(sp[0]);
        shu_ws_close_fd(sp[1]);
        return 2;
    }
    r = net_ws_client_handshake_c(sp[0], host, path, key, 24, 5000);
    pthread_join(th, NULL);
    shu_ws_close_fd(sp[0]);
    shu_ws_close_fd(sp[1]);
    return r == 0 ? 0 : 3;
}
#else
/** Windows：无 socketpair；跳过握手集成烟测。 */
int32_t net_ws_client_handshake_smoke_c(void) {
    return 0;
}
#endif
