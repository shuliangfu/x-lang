/**
 * compress_common.h — std.compress 各格式共用类型与常量
 *
 * 【文件职责】gzip 流状态头（STD-039）；供 gzip/gzip.c 与根 mod 门面引用。
 * 【所属模块】std.compress（P4 可选）
 */
#ifndef SHU_COMPRESS_COMMON_H
#define SHU_COMPRESS_COMMON_H

#include <stdint.h>

/** gzip 流状态魔数（'GZST'）。 */
#define SHU_GZIP_STREAM_MAGIC 0x475a5354u

/** brotli 流状态魔数（'BRST'）。 */
#define SHU_BROTLI_STREAM_MAGIC 0x42525354u

/** zstd 流状态魔数（'ZSTR'）。 */
#define SHU_ZSTD_STREAM_MAGIC 0x5a535452u

/**
 * gzip 流状态头（后接 z_stream 或 stub 占位）。
 * mode: 0=compress 1=decompress
 */
typedef struct {
    uint32_t magic;
    int32_t mode;
    int32_t ended;
    int32_t inited;
} shu_gzip_stream_hdr_t;

/** brotli / zstd 流状态头（后接编码器实例指针）。 */
typedef struct {
    uint32_t magic;
    int32_t mode;
    int32_t ended;
    int32_t inited;
} shu_brotli_stream_hdr_t;

typedef struct {
    uint32_t magic;
    int32_t mode;
    int32_t ended;
    int32_t inited;
} shu_zstd_stream_hdr_t;

#endif /* SHU_COMPRESS_COMMON_H */
