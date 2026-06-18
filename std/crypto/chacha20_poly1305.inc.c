/**
 * chacha20_poly1305.inc.c — STD-113：ChaCha20-Poly1305 AEAD（RFC 7539）
 *
 * 由 crypto.c #include；无外部依赖。32B key、12B nonce、16B tag。
 */

#define CHACHA_ROTL32(x, n) (((x) << (n)) | ((x) >> (32 - (n))))

/** ChaCha20 quarter round。 */
static void chacha_qr(uint32_t *a, uint32_t *b, uint32_t *c, uint32_t *d) {
    *a += *b; *d ^= *a; *d = CHACHA_ROTL32(*d, 16);
    *c += *d; *b ^= *c; *b = CHACHA_ROTL32(*b, 12);
    *a += *b; *d ^= *a; *d = CHACHA_ROTL32(*d, 8);
    *c += *d; *b ^= *c; *b = CHACHA_ROTL32(*b, 7);
}

/** 生成 ChaCha20 单块 keystream。 */
static void chacha20_block(const uint8_t key[32], const uint8_t nonce[12], uint32_t counter, uint8_t out[64]) {
    static const uint8_t sigma[16] = { 0x65,0x78,0x70,0x61,0x6e,0x64,0x20,0x33,0x32,0x2d,0x62,0x79,0x74,0x65,0x20,0x6b };
    uint32_t st[16];
    int i;
    for (i = 0; i < 4; i++) st[i] = ((uint32_t)sigma[i * 4]) | ((uint32_t)sigma[i * 4 + 1] << 8) |
        ((uint32_t)sigma[i * 4 + 2] << 16) | ((uint32_t)sigma[i * 4 + 3] << 24);
    for (i = 0; i < 8; i++) st[4 + i] = ((uint32_t)key[i * 4]) | ((uint32_t)key[i * 4 + 1] << 8) |
        ((uint32_t)key[i * 4 + 2] << 16) | ((uint32_t)key[i * 4 + 3] << 24);
    st[12] = counter;
    st[13] = ((uint32_t)nonce[0]) | ((uint32_t)nonce[1] << 8) | ((uint32_t)nonce[2] << 16) | ((uint32_t)nonce[3] << 24);
    st[14] = ((uint32_t)nonce[4]) | ((uint32_t)nonce[5] << 8) | ((uint32_t)nonce[6] << 16) | ((uint32_t)nonce[7] << 24);
    st[15] = ((uint32_t)nonce[8]) | ((uint32_t)nonce[9] << 8) | ((uint32_t)nonce[10] << 16) | ((uint32_t)nonce[11] << 24);
    uint32_t x[16];
    memcpy(x, st, 64);
    for (i = 0; i < 10; i++) {
        chacha_qr(&x[0], &x[4], &x[8], &x[12]);
        chacha_qr(&x[1], &x[5], &x[9], &x[13]);
        chacha_qr(&x[2], &x[6], &x[10], &x[14]);
        chacha_qr(&x[3], &x[7], &x[11], &x[15]);
        chacha_qr(&x[0], &x[5], &x[10], &x[15]);
        chacha_qr(&x[1], &x[6], &x[11], &x[12]);
        chacha_qr(&x[2], &x[7], &x[8], &x[13]);
        chacha_qr(&x[3], &x[4], &x[9], &x[14]);
    }
    for (i = 0; i < 16; i++) {
        uint32_t w = x[i] + st[i];
        out[i * 4] = (uint8_t)w;
        out[i * 4 + 1] = (uint8_t)(w >> 8);
        out[i * 4 + 2] = (uint8_t)(w >> 16);
        out[i * 4 + 3] = (uint8_t)(w >> 24);
    }
}

/** ChaCha20 XOR 加密/解密。 */
static void chacha20_xor(uint8_t *out, const uint8_t *in, int32_t len, const uint8_t key[32], const uint8_t nonce[12], uint32_t counter) {
    uint8_t block[64];
    int32_t off = 0;
    while (off < len) {
        chacha20_block(key, nonce, counter, block);
        counter++;
        {
            int32_t take = len - off;
            if (take > 64) take = 64;
            int32_t j;
            for (j = 0; j < take; j++) out[off + j] = in[off + j] ^ block[j];
            off += take;
        }
    }
}

/** Poly1305 状态。 */
typedef struct {
    uint32_t r[5];
    uint32_t h[5];
    uint32_t pad[4];
    int32_t leftover;
    uint8_t buffer[16];
    uint8_t final;
} poly1305_ctx_t;

static void poly1305_init(poly1305_ctx_t *ctx, const uint8_t key[32]) {
    uint32_t t0, t1, t2, t3;
    t0 = (uint32_t)key[0] | ((uint32_t)key[1] << 8) | ((uint32_t)key[2] << 16) | ((uint32_t)key[3] << 24);
    t1 = (uint32_t)key[4] | ((uint32_t)key[5] << 8) | ((uint32_t)key[6] << 16) | ((uint32_t)key[7] << 24);
    t2 = (uint32_t)key[8] | ((uint32_t)key[9] << 8) | ((uint32_t)key[10] << 16) | ((uint32_t)key[11] << 24);
    t3 = (uint32_t)key[12] | ((uint32_t)key[13] << 8) | ((uint32_t)key[14] << 16) | ((uint32_t)key[15] << 24);
    ctx->r[0] = (t0) & 0x3ffffffu;
    ctx->r[1] = ((t0 >> 26) | (t1 << 6)) & 0x3ffff03u;
    ctx->r[2] = ((t1 >> 20) | (t2 << 12)) & 0x3ffc0ffu;
    ctx->r[3] = ((t2 >> 14) | (t3 << 18)) & 0x3f03fffu;
    ctx->r[4] = ((t3 >> 8)) & 0x00fffffu;
    ctx->h[0] = ctx->h[1] = ctx->h[2] = ctx->h[3] = ctx->h[4] = 0;
    ctx->pad[0] = (uint32_t)key[16] | ((uint32_t)key[17] << 8) | ((uint32_t)key[18] << 16) | ((uint32_t)key[19] << 24);
    ctx->pad[1] = (uint32_t)key[20] | ((uint32_t)key[21] << 8) | ((uint32_t)key[22] << 16) | ((uint32_t)key[23] << 24);
    ctx->pad[2] = (uint32_t)key[24] | ((uint32_t)key[25] << 8) | ((uint32_t)key[26] << 16) | ((uint32_t)key[27] << 24);
    ctx->pad[3] = (uint32_t)key[28] | ((uint32_t)key[29] << 8) | ((uint32_t)key[30] << 16) | ((uint32_t)key[31] << 24);
    ctx->leftover = 0;
    ctx->final = 0;
}

static void poly1305_blocks(poly1305_ctx_t *ctx, const uint8_t *m, int32_t bytes, int32_t padbit) {
    uint32_t hibit = padbit ? (1u << 24) : 0u;
    while (bytes >= 16) {
        uint32_t t0, t1, t2, t3, t4;
        uint64_t d0, d1, d2, d3, d4;
        uint32_t c;
        t0 = (uint32_t)m[0] | ((uint32_t)m[1] << 8) | ((uint32_t)m[2] << 16) | ((uint32_t)m[3] << 24);
        t1 = (uint32_t)m[4] | ((uint32_t)m[5] << 8) | ((uint32_t)m[6] << 16) | ((uint32_t)m[7] << 24);
        t2 = (uint32_t)m[8] | ((uint32_t)m[9] << 8) | ((uint32_t)m[10] << 16) | ((uint32_t)m[11] << 24);
        t3 = (uint32_t)m[12] | ((uint32_t)m[13] << 8) | ((uint32_t)m[14] << 16) | ((uint32_t)m[15] << 24);
        ctx->h[0] += t0 & 0x3ffffffu;
        t0 = (t0 >> 26) | (t1 << 6);
        ctx->h[1] += t0 & 0x3ffffffu;
        t1 = (t1 >> 20) | (t2 << 12);
        ctx->h[2] += t1 & 0x3ffffffu;
        t2 = (t2 >> 14) | (t3 << 18);
        ctx->h[3] += t2 & 0x3ffffffu;
        t3 = (t3 >> 8);
        ctx->h[4] += (t3 & 0x3ffffffu) | hibit;
        d0 = (uint64_t)ctx->h[0] * ctx->r[0] + (uint64_t)ctx->h[1] * 5 * ctx->r[4] +
             (uint64_t)ctx->h[2] * 5 * ctx->r[3] + (uint64_t)ctx->h[3] * 5 * ctx->r[2] +
             (uint64_t)ctx->h[4] * 5 * ctx->r[1];
        d1 = (uint64_t)ctx->h[0] * ctx->r[1] + (uint64_t)ctx->h[1] * ctx->r[0] +
             (uint64_t)ctx->h[2] * 5 * ctx->r[4] + (uint64_t)ctx->h[3] * 5 * ctx->r[3] +
             (uint64_t)ctx->h[4] * 5 * ctx->r[2];
        d2 = (uint64_t)ctx->h[0] * ctx->r[2] + (uint64_t)ctx->h[1] * ctx->r[1] +
             (uint64_t)ctx->h[2] * ctx->r[0] + (uint64_t)ctx->h[3] * 5 * ctx->r[4] +
             (uint64_t)ctx->h[4] * 5 * ctx->r[3];
        d3 = (uint64_t)ctx->h[0] * ctx->r[3] + (uint64_t)ctx->h[1] * ctx->r[2] +
             (uint64_t)ctx->h[2] * ctx->r[1] + (uint64_t)ctx->h[3] * ctx->r[0] +
             (uint64_t)ctx->h[4] * 5 * ctx->r[4];
        d4 = (uint64_t)ctx->h[0] * ctx->r[4] + (uint64_t)ctx->h[1] * ctx->r[3] +
             (uint64_t)ctx->h[2] * ctx->r[2] + (uint64_t)ctx->h[3] * ctx->r[1] +
             (uint64_t)ctx->h[4] * ctx->r[0];
        c = (uint32_t)(d0 >> 26); ctx->h[0] = (uint32_t)d0 & 0x3ffffffu; d1 += c;
        c = (uint32_t)(d1 >> 26); ctx->h[1] = (uint32_t)d1 & 0x3ffffffu; d2 += c;
        c = (uint32_t)(d2 >> 26); ctx->h[2] = (uint32_t)d2 & 0x3ffffffu; d3 += c;
        c = (uint32_t)(d3 >> 26); ctx->h[3] = (uint32_t)d3 & 0x3ffffffu; d4 += c;
        c = (uint32_t)(d4 >> 26); ctx->h[4] = (uint32_t)d4 & 0x3ffffffu;
        ctx->h[0] += c * 5;
        c = ctx->h[0] >> 26; ctx->h[0] &= 0x3ffffffu; ctx->h[1] += c;
        m += 16;
        bytes -= 16;
    }
}

static void poly1305_update(poly1305_ctx_t *ctx, const uint8_t *m, int32_t bytes) {
    if (bytes == 0) return;
    if (ctx->leftover) {
        int32_t want = 16 - ctx->leftover;
        if (want > bytes) want = bytes;
        memcpy(ctx->buffer + ctx->leftover, m, (size_t)want);
        m += want;
        bytes -= want;
        ctx->leftover += want;
        if (ctx->leftover < 16) return;
        poly1305_blocks(ctx, ctx->buffer, 16, 1);
        ctx->leftover = 0;
    }
    if (bytes >= 16) {
        int32_t want = bytes & ~15;
        poly1305_blocks(ctx, m, want, 1);
        m += want;
        bytes -= want;
    }
    if (bytes) {
        memcpy(ctx->buffer + ctx->leftover, m, (size_t)bytes);
        ctx->leftover += bytes;
    }
}

static void poly1305_finish(poly1305_ctx_t *ctx, uint8_t mac[16]) {
    uint32_t c, mask;
    uint64_t f, g0, g1, g2, g3, g4;
    if (ctx->leftover) {
        int32_t i = ctx->leftover;
        ctx->buffer[i++] = 1;
        while (i < 16) ctx->buffer[i++] = 0;
        poly1305_blocks(ctx, ctx->buffer, 16, 0);
    }
    c = ctx->h[1] >> 26; ctx->h[1] &= 0x3ffffffu; ctx->h[2] += c;
    c = ctx->h[2] >> 26; ctx->h[2] &= 0x3ffffffu; ctx->h[3] += c;
    c = ctx->h[3] >> 26; ctx->h[3] &= 0x3ffffffu; ctx->h[4] += c;
    c = ctx->h[4] >> 26; ctx->h[4] &= 0x3ffffffu; ctx->h[0] += c * 5;
    c = ctx->h[0] >> 26; ctx->h[0] &= 0x3ffffffu; ctx->h[1] += c;
    c = ctx->h[1] >> 26; ctx->h[1] &= 0x3ffffffu; ctx->h[2] += c;
    c = ctx->h[2] >> 26; ctx->h[2] &= 0x3ffffffu; ctx->h[3] += c;
    c = ctx->h[3] >> 26; ctx->h[3] &= 0x3ffffffu; ctx->h[4] += c;
    c = ctx->h[4] >> 26; ctx->h[4] &= 0x3ffffffu; ctx->h[0] += c * 5;
    c = ctx->h[0] >> 26; ctx->h[0] &= 0x3ffffffu; ctx->h[1] += c;
    g0 = ctx->h[0] + 5; c = (uint32_t)(g0 >> 26); g0 &= 0x3ffffffu;
    g1 = ctx->h[1] + c; c = (uint32_t)(g1 >> 26); g1 &= 0x3ffffffu;
    g2 = ctx->h[2] + c; c = (uint32_t)(g2 >> 26); g2 &= 0x3ffffffu;
    g3 = ctx->h[3] + c; c = (uint32_t)(g3 >> 26); g3 &= 0x3ffffffu;
    g4 = ctx->h[4] + c - (1u << 26);
    mask = (uint32_t)((g4 >> 31) - 1);
    ctx->h[0] = (ctx->h[0] & ~mask) | ((uint32_t)g0 & mask);
    ctx->h[1] = (ctx->h[1] & ~mask) | ((uint32_t)g1 & mask);
    ctx->h[2] = (ctx->h[2] & ~mask) | ((uint32_t)g2 & mask);
    ctx->h[3] = (ctx->h[3] & ~mask) | ((uint32_t)g3 & mask);
    ctx->h[4] = (ctx->h[4] & ~mask) | ((uint32_t)g4 & mask);
    f = (uint64_t)ctx->h[0] + ctx->pad[0]; ctx->h[0] = (uint32_t)f;
    f = (uint64_t)ctx->h[1] + ctx->pad[1] + (f >> 32); ctx->h[1] = (uint32_t)f;
    f = (uint64_t)ctx->h[2] + ctx->pad[2] + (f >> 32); ctx->h[2] = (uint32_t)f;
    f = (uint64_t)ctx->h[3] + ctx->pad[3] + (f >> 32); ctx->h[3] = (uint32_t)f;
    f = (uint64_t)ctx->h[4] + (f >> 32); ctx->h[4] = (uint32_t)f;
    mac[0] = (uint8_t)(ctx->h[0] & 0xff);
    mac[1] = (uint8_t)((ctx->h[0] >> 8) & 0xff);
    mac[2] = (uint8_t)((ctx->h[0] >> 16) & 0xff);
    mac[3] = (uint8_t)((ctx->h[0] >> 24) & 0xff);
    mac[4] = (uint8_t)(ctx->h[1] & 0xff);
    mac[5] = (uint8_t)((ctx->h[1] >> 8) & 0xff);
    mac[6] = (uint8_t)((ctx->h[1] >> 16) & 0xff);
    mac[7] = (uint8_t)((ctx->h[1] >> 24) & 0xff);
    mac[8] = (uint8_t)(ctx->h[2] & 0xff);
    mac[9] = (uint8_t)((ctx->h[2] >> 8) & 0xff);
    mac[10] = (uint8_t)((ctx->h[2] >> 16) & 0xff);
    mac[11] = (uint8_t)((ctx->h[2] >> 24) & 0xff);
    mac[12] = (uint8_t)(ctx->h[3] & 0xff);
    mac[13] = (uint8_t)((ctx->h[3] >> 8) & 0xff);
    mac[14] = (uint8_t)((ctx->h[3] >> 16) & 0xff);
    mac[15] = (uint8_t)((ctx->h[3] >> 24) & 0xff);
}

/** RFC 7539 AEAD：计算 Poly1305 tag。 */
static void chacha_poly1305_tag(const uint8_t key[32], const uint8_t nonce[12],
    const uint8_t *aad, int32_t aad_len, const uint8_t *ct, int32_t ct_len, uint8_t tag[16]) {
    uint8_t poly_key[64];
    poly1305_ctx_t ctx;
    uint8_t lenbuf[16];
    chacha20_block(key, nonce, 0, poly_key);
    poly1305_init(&ctx, poly_key);
    poly1305_update(&ctx, aad, aad_len);
    if (aad_len & 15) {
        uint8_t pad[16];
        memset(pad, 0, 16);
        poly1305_update(&ctx, pad, 16 - (aad_len & 15));
    }
    poly1305_update(&ctx, ct, ct_len);
    if (ct_len & 15) {
        uint8_t pad[16];
        memset(pad, 0, 16);
        poly1305_update(&ctx, pad, 16 - (ct_len & 15));
    }
    lenbuf[0] = (uint8_t)aad_len;
    lenbuf[1] = (uint8_t)(aad_len >> 8);
    lenbuf[2] = (uint8_t)(aad_len >> 16);
    lenbuf[3] = (uint8_t)(aad_len >> 24);
    lenbuf[4] = lenbuf[5] = lenbuf[6] = lenbuf[7] = 0;
    lenbuf[8] = (uint8_t)ct_len;
    lenbuf[9] = (uint8_t)(ct_len >> 8);
    lenbuf[10] = (uint8_t)(ct_len >> 16);
    lenbuf[11] = (uint8_t)(ct_len >> 24);
    lenbuf[12] = lenbuf[13] = lenbuf[14] = lenbuf[15] = 0;
    poly1305_update(&ctx, lenbuf, 16);
    poly1305_finish(&ctx, tag);
    memset(poly_key, 0, sizeof(poly_key));
}

/** STD-113：ChaCha20-Poly1305 加密；key_len=32、nonce_len=12、tag 16B。 */
int32_t crypto_chacha20_poly1305_seal_c(const uint8_t *key, int32_t key_len, const uint8_t *nonce, int32_t nonce_len,
    const uint8_t *aad, int32_t aad_len, const uint8_t *pt, int32_t pt_len, uint8_t *ct, uint8_t *tag) {
    if (!key || !nonce || !tag || key_len != 32 || nonce_len != 12) return -1;
    if (pt_len > 0 && (!pt || !ct)) return -1;
    if (pt_len == 0 && pt != 0 && ct == 0) return -1;
    if (pt_len > 0) chacha20_xor(ct, pt, pt_len, key, nonce, 1);
    chacha_poly1305_tag(key, nonce, aad, aad_len, ct, pt_len, tag);
    return 0;
}

/** STD-113：ChaCha20-Poly1305 解密并校验 tag。 */
int32_t crypto_chacha20_poly1305_open_c(const uint8_t *key, int32_t key_len, const uint8_t *nonce, int32_t nonce_len,
    const uint8_t *aad, int32_t aad_len, const uint8_t *ct, int32_t ct_len, const uint8_t *tag, uint8_t *pt) {
    uint8_t calc[16];
    if (!key || !nonce || !tag || key_len != 32 || nonce_len != 12) return -1;
    if (ct_len > 0 && (!ct || !pt)) return -1;
    chacha_poly1305_tag(key, nonce, aad, aad_len, ct, ct_len, calc);
    if (crypto_mem_eq_c(calc, tag, 16) != 1) return -1;
    if (ct_len > 0) chacha20_xor(pt, ct, ct_len, key, nonce, 1);
    return 0;
}

/** STD-113：C 烟测（RFC 7539 §2.8.2 金样 + round-trip）。 */
int32_t crypto_chacha20_poly1305_smoke_c(void) {
    static const uint8_t key[32] = {
        0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8a,0x8b,0x8c,0x8d,0x8e,0x8f,
        0x90,0x91,0x92,0x93,0x94,0x95,0x96,0x97,0x98,0x99,0x9a,0x9b,0x9c,0x9d,0x9e,0x9f
    };
    static const uint8_t nonce[12] = { 0x07,0,0,0,0x40,0x41,0x42,0x43,0x44,0x45,0x46,0x47 };
    static const uint8_t aad[16] = {
        0x50,0x51,0x52,0x53,0x54,0x55,0x56,0x57,0x58,0x59,0x5a,0x5b,0x5c,0x5d,0x5e,0x5f
    };
    static const char pt[] =
        "Ladies and Gentlemen of the class of 1999: If I could offer you only one tip for the future, sunscreen would be it";
    int32_t pt_len = 114;
    uint8_t ct[128];
    uint8_t tag[16];
    uint8_t out[128];
    if (crypto_chacha20_poly1305_seal_c(key, 32, nonce, 12, aad, 16, (const uint8_t *)pt, pt_len, ct, tag) != 0) return -1;
    if (crypto_chacha20_poly1305_open_c(key, 32, nonce, 12, aad, 16, ct, pt_len, tag, out) != 0) return -2;
    if (crypto_mem_eq_c(out, (const uint8_t *)pt, pt_len) != 1) return -3;
    tag[0] ^= 1;
    if (crypto_chacha20_poly1305_open_c(key, 32, nonce, 12, aad, 16, ct, pt_len, tag, out) != -1) return -4;
    return 0;
}
