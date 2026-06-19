/**
 * std/compress/gzip/gzip.c — gzip 块压缩/解压与流式 API（STD-039）
 *
 * 【文件职责】.gz 块 API；gzip 流 init/compress/decompress/end。
 * 【编译】-DSHUX_USE_ZLIB（gzip 基于 zlib deflate/inflate + windowBits=15+16）。
 * 【所属模块】std.compress.gzip
 */

#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include "../compress_common.h"

#ifdef SHUX_USE_ZLIB
#include <zlib.h>
/** gzip 格式：windowBits=15+16 使 deflate/inflate 使用 gzip 头尾。 */
#define GZIP_WBITS (15 + 16)
#endif

/** 压缩为 gzip 格式（.gz），返回写入字节数，失败或未启用 zlib 返回 -1。 */
int32_t compress_gzip_compress_c(const uint8_t *in, int32_t in_len, uint8_t *out, int32_t out_cap) {
#ifdef SHUX_USE_ZLIB
    z_stream strm;
    int32_t written;
    if (!in || !out || in_len < 0 || out_cap <= 0)
        return -1;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, GZIP_WBITS, 8, Z_DEFAULT_STRATEGY) != Z_OK)
        return -1;
    strm.avail_in = (uInt)in_len;
    strm.next_in = (z_const Bytef *)in;
    strm.avail_out = (uInt)out_cap;
    strm.next_out = out;
    if (deflate(&strm, Z_FINISH) != Z_STREAM_END) {
        deflateEnd(&strm);
        return -1;
    }
    written = (int32_t)((uint8_t *)strm.next_out - out);
    deflateEnd(&strm);
    return written;
#else
    (void)in;
    (void)in_len;
    (void)out;
    (void)out_cap;
    return -1;
#endif
}

/** 解压 gzip 流，返回写入字节数，失败或未启用 zlib 返回 -1。 */
int32_t compress_gzip_decompress_c(const uint8_t *in, int32_t in_len, uint8_t *out, int32_t out_cap) {
#ifdef SHUX_USE_ZLIB
    z_stream strm;
    int ret;
    int32_t written;
    if (!in || !out || in_len < 0 || out_cap <= 0)
        return -1;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.avail_in = (uInt)in_len;
    strm.next_in = (z_const Bytef *)in;
    if (inflateInit2(&strm, GZIP_WBITS) != Z_OK)
        return -1;
    strm.avail_out = (uInt)out_cap;
    strm.next_out = out;
    ret = inflate(&strm, Z_FINISH);
    written = (ret == Z_STREAM_END) ? (int32_t)((uint8_t *)strm.next_out - out) : -1;
    inflateEnd(&strm);
    return written;
#else
    (void)in;
    (void)in_len;
    (void)out;
    (void)out_cap;
    return -1;
#endif
}

#ifdef SHUX_USE_ZLIB

/** 含 z_stream 的完整 gzip 流状态。 */
typedef struct {
    shu_gzip_stream_hdr_t hdr;
    z_stream strm;
} shu_gzip_stream_t;

/** 校验并返回 gzip 流状态指针。 */
static shu_gzip_stream_t *shu_gzip_stream_cast(uint8_t *state, int32_t state_cap) {
    shu_gzip_stream_t *s;
    if (!state || state_cap < (int32_t)sizeof(shu_gzip_stream_t))
        return NULL;
    s = (shu_gzip_stream_t *)state;
    if (s->hdr.magic != SHU_GZIP_STREAM_MAGIC || !s->hdr.inited)
        return NULL;
    return s;
}

/** 返回 gzip 流状态缓冲最小字节数。 */
int32_t compress_gzip_stream_state_bytes_c(void) {
    return (int32_t)sizeof(shu_gzip_stream_t);
}

/** 初始化 gzip 压缩流；成功 0，失败 -1。 */
int32_t compress_gzip_stream_init_compress_c(uint8_t *state, int32_t state_cap) {
    shu_gzip_stream_t *s;
    if (!state || state_cap < (int32_t)sizeof(shu_gzip_stream_t))
        return -1;
    s = (shu_gzip_stream_t *)state;
    memset(s, 0, sizeof(*s));
    s->hdr.magic = SHU_GZIP_STREAM_MAGIC;
    s->hdr.mode = 0;
    s->strm.zalloc = Z_NULL;
    s->strm.zfree = Z_NULL;
    s->strm.opaque = Z_NULL;
    if (deflateInit2(&s->strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, GZIP_WBITS, 8, Z_DEFAULT_STRATEGY) != Z_OK)
        return -1;
    s->hdr.inited = 1;
    return 0;
}

/** 初始化 gzip 解压流；成功 0，失败 -1。 */
int32_t compress_gzip_stream_init_decompress_c(uint8_t *state, int32_t state_cap) {
    shu_gzip_stream_t *s;
    if (!state || state_cap < (int32_t)sizeof(shu_gzip_stream_t))
        return -1;
    s = (shu_gzip_stream_t *)state;
    memset(s, 0, sizeof(*s));
    s->hdr.magic = SHU_GZIP_STREAM_MAGIC;
    s->hdr.mode = 1;
    s->strm.zalloc = Z_NULL;
    s->strm.zfree = Z_NULL;
    s->strm.opaque = Z_NULL;
    if (inflateInit2(&s->strm, GZIP_WBITS) != Z_OK)
        return -1;
    s->hdr.inited = 1;
    return 0;
}

/** 分块 gzip 压缩；is_last≠0 时对末块 Z_FINISH；返回写入 out 字节数。 */
int32_t compress_gzip_stream_compress_c(uint8_t *state, int32_t state_cap, const uint8_t *in, int32_t in_len,
                                        uint8_t *out, int32_t out_cap, int32_t is_last, int32_t *in_consumed) {
    shu_gzip_stream_t *s;
    int32_t in_before;
    int32_t written;
    int flush;
    int ret;
    if (in_consumed)
        *in_consumed = 0;
    s = shu_gzip_stream_cast(state, state_cap);
    if (!s || s->hdr.mode != 0 || !out || out_cap <= 0)
        return -1;
    if (in_len > 0 && !in)
        return -1;
    in_before = in_len;
    s->strm.avail_in = (uInt)(in_len > 0 ? in_len : 0);
    s->strm.next_in = (in_len > 0 && in) ? (z_const Bytef *)in : Z_NULL;
    s->strm.avail_out = (uInt)out_cap;
    s->strm.next_out = out;
    flush = (is_last != 0) ? Z_FINISH : Z_NO_FLUSH;
    ret = deflate(&s->strm, flush);
    written = out_cap - (int32_t)s->strm.avail_out;
    if (in_consumed)
        *in_consumed = in_before - (int32_t)s->strm.avail_in;
    if (ret == Z_STREAM_END) {
        s->hdr.ended = 1;
        return written;
    }
    if (ret == Z_OK)
        return written;
    if (ret == Z_BUF_ERROR && written > 0)
        return written;
    return -1;
}

/** 分块 gzip 解压；返回写入 out 字节数。 */
int32_t compress_gzip_stream_decompress_c(uint8_t *state, int32_t state_cap, const uint8_t *in, int32_t in_len,
                                          uint8_t *out, int32_t out_cap, int32_t *in_consumed) {
    shu_gzip_stream_t *s;
    int32_t in_before;
    int32_t written;
    int ret;
    if (in_consumed)
        *in_consumed = 0;
    s = shu_gzip_stream_cast(state, state_cap);
    if (!s || s->hdr.mode != 1 || !out || out_cap <= 0)
        return -1;
    if (in_len > 0 && !in)
        return -1;
    in_before = in_len;
    s->strm.avail_in = (uInt)(in_len > 0 ? in_len : 0);
    s->strm.next_in = (in_len > 0 && in) ? (z_const Bytef *)in : Z_NULL;
    s->strm.avail_out = (uInt)out_cap;
    s->strm.next_out = out;
    ret = inflate(&s->strm, Z_NO_FLUSH);
    written = out_cap - (int32_t)s->strm.avail_out;
    if (in_consumed)
        *in_consumed = in_before - (int32_t)s->strm.avail_in;
    if (ret == Z_STREAM_END) {
        s->hdr.ended = 1;
        return written;
    }
    if (ret == Z_OK)
        return written;
    if (ret == Z_BUF_ERROR && (written > 0 || s->strm.avail_in < (uInt)in_before))
        return written;
    return -1;
}

/** 释放 gzip 流（deflateEnd/inflateEnd）；成功 0。 */
int32_t compress_gzip_stream_end_c(uint8_t *state, int32_t state_cap) {
    shu_gzip_stream_t *s;
    if (!state || state_cap < (int32_t)sizeof(shu_gzip_stream_hdr_t))
        return 0;
    s = (shu_gzip_stream_t *)state;
    if (s->hdr.magic != SHU_GZIP_STREAM_MAGIC || !s->hdr.inited)
        return 0;
    if (s->hdr.mode == 0)
        deflateEnd(&s->strm);
    else
        inflateEnd(&s->strm);
    s->hdr.inited = 0;
    return 0;
}

#else /* !SHUX_USE_ZLIB */

/** 无 zlib 时 stub 状态大小。 */
int32_t compress_gzip_stream_state_bytes_c(void) {
    return (int32_t)sizeof(shu_gzip_stream_hdr_t);
}

int32_t compress_gzip_stream_init_compress_c(uint8_t *state, int32_t state_cap) {
    (void)state;
    (void)state_cap;
    return -1;
}

int32_t compress_gzip_stream_init_decompress_c(uint8_t *state, int32_t state_cap) {
    (void)state;
    (void)state_cap;
    return -1;
}

int32_t compress_gzip_stream_compress_c(uint8_t *state, int32_t state_cap, const uint8_t *in, int32_t in_len,
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

int32_t compress_gzip_stream_decompress_c(uint8_t *state, int32_t state_cap, const uint8_t *in, int32_t in_len,
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

int32_t compress_gzip_stream_end_c(uint8_t *state, int32_t state_cap) {
    (void)state;
    (void)state_cap;
    return 0;
}

#endif /* SHUX_USE_ZLIB */
