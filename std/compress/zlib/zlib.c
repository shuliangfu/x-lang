/**
 * std/compress/zlib/zlib.c — zlib 块压缩/解压（deflate/inflate）
 *
 * 【文件职责】RFC 1950 zlib 封装：compress2 / uncompress。
 * 【编译】-DSHUX_USE_ZLIB，链接 -lz。
 * 【所属模块】std.compress.zlib
 */

#include <stdint.h>
#include "../compress_common.h"

#ifdef SHUX_USE_ZLIB
#include <zlib.h>
#endif

/** 压缩：zlib 格式写入 out，返回写入字节数，失败或未启用 zlib 返回 -1。 */
int32_t compress_deflate_c(const uint8_t *in, int32_t in_len, uint8_t *out, int32_t out_cap) {
#ifdef SHUX_USE_ZLIB
    uLongf dest_len;
    int ret;
    if (!in || !out || in_len < 0 || out_cap <= 0)
        return -1;
    dest_len = (uLongf)out_cap;
    ret = compress2(out, &dest_len, in, (uLong)in_len, Z_DEFAULT_COMPRESSION);
    return (ret == Z_OK) ? (int32_t)dest_len : -1;
#else
    (void)in;
    (void)in_len;
    (void)out;
    (void)out_cap;
    return -1;
#endif
}

/** 解压：从 in 读 zlib 流，写入 out，返回写入字节数，失败或未启用 zlib 返回 -1。 */
int32_t compress_inflate_c(const uint8_t *in, int32_t in_len, uint8_t *out, int32_t out_cap) {
#ifdef SHUX_USE_ZLIB
    uLongf dest_len;
    int ret;
    if (!in || !out || in_len < 0 || out_cap <= 0)
        return -1;
    dest_len = (uLongf)out_cap;
    ret = uncompress(out, &dest_len, in, (uLong)in_len);
    return (ret == Z_OK) ? (int32_t)dest_len : -1;
#else
    (void)in;
    (void)in_len;
    (void)out;
    (void)out_cap;
    return -1;
#endif
}

#ifdef SHUX_USE_ZLIB
/** 链接 marker：runtime 据此追加 -lz。 */
const char shu_compress_zlib_marker = 1;
#endif
