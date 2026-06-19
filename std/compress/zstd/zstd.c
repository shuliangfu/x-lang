/**
 * std/compress/zstd/zstd.c — zstd 块压缩/解压
 *
 * 【文件职责】ZSTD_compress / ZSTD_decompress 封装。
 * 【编译】-DSHUX_USE_ZSTD，链接 -lzstd。
 * 【所属模块】std.compress.zstd
 */

#include <stdint.h>
#include <string.h>
#include "../compress_common.h"

#ifdef SHUX_USE_ZSTD
#include <zstd.h>
#endif

/** 压缩为 zstd 帧，返回写入字节数，失败或未启用 zstd 返回 -1。 */
int32_t compress_zstd_compress_c(const uint8_t *in, int32_t in_len, uint8_t *out, int32_t out_cap) {
#ifdef SHUX_USE_ZSTD
    size_t n;
    if (!in || !out || in_len < 0 || out_cap <= 0)
        return -1;
    n = ZSTD_compress(out, (size_t)out_cap, in, (size_t)in_len, ZSTD_CLEVEL_DEFAULT);
    if (ZSTD_isError(n))
        return -1;
    return (int32_t)n;
#else
    (void)in;
    (void)in_len;
    (void)out;
    (void)out_cap;
    return -1;
#endif
}

/** 解压 zstd 帧，返回写入字节数，失败或未启用 zstd 返回 -1。 */
int32_t compress_zstd_decompress_c(const uint8_t *in, int32_t in_len, uint8_t *out, int32_t out_cap) {
#ifdef SHUX_USE_ZSTD
    size_t n;
    if (!in || !out || in_len < 0 || out_cap <= 0)
        return -1;
    n = ZSTD_decompress(out, (size_t)out_cap, in, (size_t)in_len);
    if (ZSTD_isError(n))
        return -1;
    return (int32_t)n;
#else
    (void)in;
    (void)in_len;
    (void)out;
    (void)out_cap;
    return -1;
#endif
}

#ifdef SHUX_USE_ZSTD
/** 链接 marker：runtime 据此追加 -lzstd。 */
const char shu_compress_zstd_marker = 1;

/** 含 zstd C/D 上下文的流状态。 */
typedef struct {
    shu_zstd_stream_hdr_t hdr;
    ZSTD_CCtx *cctx;
    ZSTD_DCtx *dctx;
} shu_zstd_stream_t;

/** 校验并返回 zstd 流状态指针。 */
static shu_zstd_stream_t *shu_zstd_stream_cast(uint8_t *state, int32_t state_cap) {
    shu_zstd_stream_t *s;
    if (!state || state_cap < (int32_t)sizeof(shu_zstd_stream_t))
        return NULL;
    s = (shu_zstd_stream_t *)state;
    if (s->hdr.magic != SHU_ZSTD_STREAM_MAGIC || !s->hdr.inited)
        return NULL;
    return s;
}

/** 探测 zstd 是否已在编译期启用；1=可用，0=占位 stub。 */
int32_t compress_zstd_available_c(void) {
    return 1;
}

/** 返回 zstd 流状态缓冲最小字节数。 */
int32_t compress_zstd_stream_state_bytes_c(void) {
    return (int32_t)sizeof(shu_zstd_stream_t);
}

/** 初始化 zstd 压缩流；成功 0。 */
int32_t compress_zstd_stream_init_compress_c(uint8_t *state, int32_t state_cap) {
    shu_zstd_stream_t *s;
    if (!state || state_cap < (int32_t)sizeof(shu_zstd_stream_t))
        return -1;
    s = (shu_zstd_stream_t *)state;
    memset(s, 0, sizeof(*s));
    s->hdr.magic = SHU_ZSTD_STREAM_MAGIC;
    s->hdr.mode = 0;
    s->cctx = ZSTD_createCCtx();
    if (!s->cctx)
        return -1;
    if (ZSTD_isError(ZSTD_CCtx_setParameter(s->cctx, ZSTD_c_compressionLevel, ZSTD_CLEVEL_DEFAULT))) {
        ZSTD_freeCCtx(s->cctx);
        s->cctx = NULL;
        return -1;
    }
    s->hdr.inited = 1;
    return 0;
}

/** 初始化 zstd 解压流；成功 0。 */
int32_t compress_zstd_stream_init_decompress_c(uint8_t *state, int32_t state_cap) {
    shu_zstd_stream_t *s;
    if (!state || state_cap < (int32_t)sizeof(shu_zstd_stream_t))
        return -1;
    s = (shu_zstd_stream_t *)state;
    memset(s, 0, sizeof(*s));
    s->hdr.magic = SHU_ZSTD_STREAM_MAGIC;
    s->hdr.mode = 1;
    s->dctx = ZSTD_createDCtx();
    if (!s->dctx)
        return -1;
    s->hdr.inited = 1;
    return 0;
}

/** 分块 zstd 压缩；is_last≠0 时 ZSTD_e_end。 */
int32_t compress_zstd_stream_compress_c(uint8_t *state, int32_t state_cap, const uint8_t *in, int32_t in_len,
                                          uint8_t *out, int32_t out_cap, int32_t is_last, int32_t *in_consumed) {
    shu_zstd_stream_t *s;
    ZSTD_inBuffer inbuf;
    ZSTD_outBuffer outbuf;
    ZSTD_EndDirective mode;
    size_t remaining;
    if (in_consumed)
        *in_consumed = 0;
    s = shu_zstd_stream_cast(state, state_cap);
    if (!s || s->hdr.mode != 0 || !out || out_cap <= 0)
        return -1;
    if (in_len > 0 && !in)
        return -1;
    inbuf.src = in;
    inbuf.size = (size_t)(in_len > 0 ? in_len : 0);
    inbuf.pos = 0;
    outbuf.dst = out;
    outbuf.size = (size_t)out_cap;
    outbuf.pos = 0;
    mode = (is_last != 0) ? ZSTD_e_end : ZSTD_e_continue;
    remaining = ZSTD_compressStream2(s->cctx, &outbuf, &inbuf, mode);
    if (ZSTD_isError(remaining))
        return -1;
    if (in_consumed)
        *in_consumed = (int32_t)inbuf.pos;
    if (mode == ZSTD_e_end && remaining == 0)
        s->hdr.ended = 1;
    return (int32_t)outbuf.pos;
}

/** 分块 zstd 解压。 */
int32_t compress_zstd_stream_decompress_c(uint8_t *state, int32_t state_cap, const uint8_t *in, int32_t in_len,
                                            uint8_t *out, int32_t out_cap, int32_t *in_consumed) {
    shu_zstd_stream_t *s;
    ZSTD_inBuffer inbuf;
    ZSTD_outBuffer outbuf;
    size_t ret;
    if (in_consumed)
        *in_consumed = 0;
    s = shu_zstd_stream_cast(state, state_cap);
    if (!s || s->hdr.mode != 1 || !out || out_cap <= 0)
        return -1;
    if (in_len > 0 && !in)
        return -1;
    inbuf.src = in;
    inbuf.size = (size_t)(in_len > 0 ? in_len : 0);
    inbuf.pos = 0;
    outbuf.dst = out;
    outbuf.size = (size_t)out_cap;
    outbuf.pos = 0;
    ret = ZSTD_decompressStream(s->dctx, &outbuf, &inbuf);
    if (ZSTD_isError(ret))
        return -1;
    if (in_consumed)
        *in_consumed = (int32_t)inbuf.pos;
    if (ret == 0)
        s->hdr.ended = 1;
    return (int32_t)outbuf.pos;
}

/** 释放 zstd 流；成功 0。 */
int32_t compress_zstd_stream_end_c(uint8_t *state, int32_t state_cap) {
    shu_zstd_stream_t *s;
    if (!state || state_cap < (int32_t)sizeof(shu_zstd_stream_hdr_t))
        return 0;
    s = (shu_zstd_stream_t *)state;
    if (s->hdr.magic != SHU_ZSTD_STREAM_MAGIC || !s->hdr.inited)
        return 0;
    if (s->cctx) {
        ZSTD_freeCCtx(s->cctx);
        s->cctx = NULL;
    }
    if (s->dctx) {
        ZSTD_freeDCtx(s->dctx);
        s->dctx = NULL;
    }
    s->hdr.inited = 0;
    return 0;
}

/** zstd 块 + 流往返烟测；未启用时返回 0（skip）。 */
int32_t compress_zstd_smoke_c(void) {
    static const uint8_t inp[] = "hello";
    uint8_t out[64];
    uint8_t dec[64];
    uint8_t st_c[512];
    uint8_t st_d[512];
    int32_t cap_c;
    int32_t cap_d;
    int32_t n;
    int32_t m;
    int32_t consumed;
    if (compress_zstd_available_c() == 0)
        return 0;
    n = compress_zstd_compress_c(inp, 5, out, 64);
    if (n <= 0)
        return 1;
    m = compress_zstd_decompress_c(out, n, dec, 64);
    if (m != 5 || memcmp(dec, inp, 5) != 0)
        return 2;
    cap_c = compress_zstd_stream_state_bytes_c();
    cap_d = compress_zstd_stream_state_bytes_c();
    if (compress_zstd_stream_init_compress_c(st_c, cap_c) != 0)
        return 3;
    consumed = 0;
    n = compress_zstd_stream_compress_c(st_c, cap_c, inp, 5, out, 64, 1, &consumed);
    if (n <= 0) {
        compress_zstd_stream_end_c(st_c, cap_c);
        return 4;
    }
    compress_zstd_stream_end_c(st_c, cap_c);
    if (compress_zstd_stream_init_decompress_c(st_d, cap_d) != 0)
        return 5;
    consumed = 0;
    m = compress_zstd_stream_decompress_c(st_d, cap_d, out, n, dec, 64, &consumed);
    compress_zstd_stream_end_c(st_d, cap_d);
    if (m != 5 || memcmp(dec, inp, 5) != 0)
        return 6;
    return 0;
}

#else /* !SHUX_USE_ZSTD */

int32_t compress_zstd_available_c(void) {
    return 0;
}

int32_t compress_zstd_stream_state_bytes_c(void) {
    return (int32_t)sizeof(shu_zstd_stream_hdr_t);
}

int32_t compress_zstd_stream_init_compress_c(uint8_t *state, int32_t state_cap) {
    (void)state;
    (void)state_cap;
    return -1;
}

int32_t compress_zstd_stream_init_decompress_c(uint8_t *state, int32_t state_cap) {
    (void)state;
    (void)state_cap;
    return -1;
}

int32_t compress_zstd_stream_compress_c(uint8_t *state, int32_t state_cap, const uint8_t *in, int32_t in_len,
                                          uint8_t *out, int32_t out_cap, int32_t is_last, int32_t *in_consumed) {
    (void)state;
    (void)state_cap;
    (void)in;
    (void)in_len;
    (void)out;
    (void)out_cap;
    (void)is_last;
    if (in_consumed)
        *in_consumed = 0;
    return -1;
}

int32_t compress_zstd_stream_decompress_c(uint8_t *state, int32_t state_cap, const uint8_t *in, int32_t in_len,
                                            uint8_t *out, int32_t out_cap, int32_t *in_consumed) {
    (void)state;
    (void)state_cap;
    (void)in;
    (void)in_len;
    (void)out;
    (void)out_cap;
    if (in_consumed)
        *in_consumed = 0;
    return -1;
}

int32_t compress_zstd_stream_end_c(uint8_t *state, int32_t state_cap) {
    (void)state;
    (void)state_cap;
    return 0;
}

int32_t compress_zstd_smoke_c(void) {
    return 0;
}

#endif /* SHUX_USE_ZSTD */
