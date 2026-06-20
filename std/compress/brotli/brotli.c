/**
 * std/compress/brotli/brotli.c — Brotli（.br）块压缩/解压
 *
 * 【文件职责】BrotliEncoderCompress / BrotliDecoderDecompress 封装。
 * 【编译】-DSHUX_USE_BROTLI，链接 -lbrotlienc -lbrotlidec。
 * 【所属模块】std.compress.brotli
 */

#include <stdint.h>
#include <string.h>
#include "../compress_common.h"

#ifdef SHUX_USE_BROTLI
#include <brotli/encode.h>
#include <brotli/decode.h>

/** 链接 marker：runtime 据此追加 -lbrotlienc -lbrotlidec。 */
const char shu_compress_brotli_marker = 1;
#endif

/** 压缩为 Brotli 格式（.br），返回写入字节数，失败或未启用 Brotli 返回 -1。 */
int32_t compress_brotli_compress_c(const uint8_t *in, int32_t in_len, uint8_t *out, int32_t out_cap) {
#ifdef SHUX_USE_BROTLI
    size_t encoded_size;
    if (!in || !out || in_len < 0 || out_cap <= 0)
        return -1;
    encoded_size = (size_t)out_cap;
    if (!BrotliEncoderCompress(BROTLI_DEFAULT_QUALITY, BROTLI_DEFAULT_WINDOW, BROTLI_DEFAULT_MODE,
                               (size_t)in_len, in, &encoded_size, out))
        return -1;
    return (int32_t)encoded_size;
#else
    (void)in;
    (void)in_len;
    (void)out;
    (void)out_cap;
    return -1;
#endif
}

/** 解压 Brotli 流，返回写入字节数，失败或未启用 Brotli 返回 -1。 */
int32_t compress_brotli_decompress_c(const uint8_t *in, int32_t in_len, uint8_t *out, int32_t out_cap) {
#ifdef SHUX_USE_BROTLI
    size_t decoded_size;
    if (!in || !out || in_len < 0 || out_cap <= 0)
        return -1;
    decoded_size = (size_t)out_cap;
    if (BrotliDecoderDecompress((size_t)in_len, in, &decoded_size, out) != BROTLI_DECODER_RESULT_SUCCESS)
        return -1;
    return (int32_t)decoded_size;
#else
    (void)in;
    (void)in_len;
    (void)out;
    (void)out_cap;
    return -1;
#endif
}

/** 探测 Brotli 是否已在编译期启用；1=可用，0=占位 stub。 */
int32_t compress_brotli_available_c(void) {
#ifdef SHUX_USE_BROTLI
    return 1;
#else
    return 0;
#endif
}

/** Brotli 往返烟测；未启用时返回 0（skip）。 */
int32_t compress_brotli_smoke_c(void) {
    static const uint8_t inp[] = "hello";
    uint8_t out[64];
    uint8_t dec[64];
    int32_t n;
    int32_t m;
    if (compress_brotli_available_c() == 0)
        return 0;
    n = compress_brotli_compress_c(inp, 5, out, 64);
    if (n <= 0)
        return 1;
    m = compress_brotli_decompress_c(out, n, dec, 64);
    if (m != 5 || memcmp(dec, inp, 5) != 0)
        return 2;
    return 0;
}

#ifdef SHUX_USE_BROTLI

/** 含 Brotli 编码器/解码器指针的流状态。 */
typedef struct {
    shu_brotli_stream_hdr_t hdr;
    BrotliEncoderState *enc;
    BrotliDecoderState *dec;
} shu_brotli_stream_t;

/** 校验并返回 brotli 流状态指针。 */
static shu_brotli_stream_t *shu_brotli_stream_cast(uint8_t *state, int32_t state_cap) {
    shu_brotli_stream_t *s;
    if (!state || state_cap < (int32_t)sizeof(shu_brotli_stream_t))
        return NULL;
    s = (shu_brotli_stream_t *)state;
    if (s->hdr.magic != SHU_BROTLI_STREAM_MAGIC || !s->hdr.inited)
        return NULL;
    return s;
}

/** 返回 brotli 流状态缓冲最小字节数。 */
int32_t compress_brotli_stream_state_bytes_c(void) {
    return (int32_t)sizeof(shu_brotli_stream_t);
}

/** 初始化 brotli 压缩流；成功 0。 */
int32_t compress_brotli_stream_init_compress_c(uint8_t *state, int32_t state_cap) {
    shu_brotli_stream_t *s;
    if (!state || state_cap < (int32_t)sizeof(shu_brotli_stream_t))
        return -1;
    s = (shu_brotli_stream_t *)state;
    memset(s, 0, sizeof(*s));
    s->hdr.magic = SHU_BROTLI_STREAM_MAGIC;
    s->hdr.mode = 0;
    s->enc = BrotliEncoderCreateInstance(NULL, NULL, NULL);
    if (!s->enc)
        return -1;
    s->hdr.inited = 1;
    return 0;
}

/** 初始化 brotli 解压流；成功 0。 */
int32_t compress_brotli_stream_init_decompress_c(uint8_t *state, int32_t state_cap) {
    shu_brotli_stream_t *s;
    if (!state || state_cap < (int32_t)sizeof(shu_brotli_stream_t))
        return -1;
    s = (shu_brotli_stream_t *)state;
    memset(s, 0, sizeof(*s));
    s->hdr.magic = SHU_BROTLI_STREAM_MAGIC;
    s->hdr.mode = 1;
    s->dec = BrotliDecoderCreateInstance(NULL, NULL, NULL);
    if (!s->dec)
        return -1;
    s->hdr.inited = 1;
    return 0;
}

/** 分块 brotli 压缩；is_last≠0 时 FINISH。 */
int32_t compress_brotli_stream_compress_c(uint8_t *state, int32_t state_cap, const uint8_t *in, int32_t in_len,
                                          uint8_t *out, int32_t out_cap, int32_t is_last, int32_t *in_consumed) {
    shu_brotli_stream_t *s;
    BrotliEncoderOperation op;
    size_t avail_in;
    const uint8_t *next_in;
    size_t avail_out;
    uint8_t *next_out;
    size_t total_out = 0;
    int32_t written;
    if (in_consumed)
        *in_consumed = 0;
    s = shu_brotli_stream_cast(state, state_cap);
    if (!s || s->hdr.mode != 0 || !out || out_cap <= 0)
        return -1;
    if (in_len > 0 && !in)
        return -1;
    op = (is_last != 0) ? BROTLI_OPERATION_FINISH : BROTLI_OPERATION_PROCESS;
    avail_in = (size_t)(in_len > 0 ? in_len : 0);
    next_in = (in_len > 0 && in) ? in : NULL;
    avail_out = (size_t)out_cap;
    next_out = out;
    if (BrotliEncoderCompressStream(s->enc, op, &avail_in, &next_in, &avail_out, &next_out, &total_out) !=
        BROTLI_TRUE)
        return -1;
    written = out_cap - (int32_t)avail_out;
    if (in_consumed)
        *in_consumed = in_len - (int32_t)avail_in;
    if (is_last != 0 && BrotliEncoderIsFinished(s->enc))
        s->hdr.ended = 1;
    return written;
}

/** 分块 brotli 解压。 */
int32_t compress_brotli_stream_decompress_c(uint8_t *state, int32_t state_cap, const uint8_t *in, int32_t in_len,
                                            uint8_t *out, int32_t out_cap, int32_t *in_consumed) {
    shu_brotli_stream_t *s;
    size_t avail_in;
    const uint8_t *next_in;
    size_t avail_out;
    uint8_t *next_out;
    BrotliDecoderResult r;
    int32_t written;
    if (in_consumed)
        *in_consumed = 0;
    s = shu_brotli_stream_cast(state, state_cap);
    if (!s || s->hdr.mode != 1 || !out || out_cap <= 0)
        return -1;
    if (in_len > 0 && !in)
        return -1;
    avail_in = (size_t)(in_len > 0 ? in_len : 0);
    next_in = (in_len > 0 && in) ? in : NULL;
    avail_out = (size_t)out_cap;
    next_out = out;
    r = BrotliDecoderDecompressStream(s->dec, &avail_in, &next_in, &avail_out, &next_out, NULL);
    written = out_cap - (int32_t)avail_out;
    if (in_consumed)
        *in_consumed = in_len - (int32_t)avail_in;
    if (r == BROTLI_DECODER_RESULT_SUCCESS)
        s->hdr.ended = 1;
    if (r == BROTLI_DECODER_RESULT_NEEDS_MORE_OUTPUT && written > 0)
        return written;
    if (r == BROTLI_DECODER_RESULT_NEEDS_MORE_INPUT && written > 0)
        return written;
    if (r == BROTLI_DECODER_RESULT_SUCCESS)
        return written;
    if (r == BROTLI_DECODER_RESULT_NEEDS_MORE_INPUT || r == BROTLI_DECODER_RESULT_NEEDS_MORE_OUTPUT)
        return written;
    return -1;
}

/** 释放 brotli 流；成功 0。 */
int32_t compress_brotli_stream_end_c(uint8_t *state, int32_t state_cap) {
    shu_brotli_stream_t *s;
    if (!state || state_cap < (int32_t)sizeof(shu_brotli_stream_hdr_t))
        return 0;
    s = (shu_brotli_stream_t *)state;
    if (s->hdr.magic != SHU_BROTLI_STREAM_MAGIC || !s->hdr.inited)
        return 0;
    if (s->hdr.mode == 0 && s->enc)
        BrotliEncoderDestroyInstance(s->enc);
    if (s->hdr.mode == 1 && s->dec)
        BrotliDecoderDestroyInstance(s->dec);
    s->enc = NULL;
    s->dec = NULL;
    s->hdr.inited = 0;
    return 0;
}

#else /* !SHUX_USE_BROTLI */

int32_t compress_brotli_stream_state_bytes_c(void) {
    return (int32_t)sizeof(shu_brotli_stream_hdr_t);
}

int32_t compress_brotli_stream_init_compress_c(uint8_t *state, int32_t state_cap) {
    (void)state;
    (void)state_cap;
    return -1;
}

int32_t compress_brotli_stream_init_decompress_c(uint8_t *state, int32_t state_cap) {
    (void)state;
    (void)state_cap;
    return -1;
}

int32_t compress_brotli_stream_compress_c(uint8_t *state, int32_t state_cap, const uint8_t *in, int32_t in_len,
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

int32_t compress_brotli_stream_decompress_c(uint8_t *state, int32_t state_cap, const uint8_t *in, int32_t in_len,
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

int32_t compress_brotli_stream_end_c(uint8_t *state, int32_t state_cap) {
    (void)state;
    (void)state_cap;
    return 0;
}

#endif /* SHUX_USE_BROTLI */
