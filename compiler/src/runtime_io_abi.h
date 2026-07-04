/**
 * runtime_io_abi.h — 编译器 C 侧文件 I/O ABI 声明（Phase E-04 v3+）
 *
 * 文件职责：声明 POSIX open/read/write 薄封装，供 runtime.c、ast_pool、pipeline glue 链接。
 * 所属模块：compiler 运行时 I/O ABI；实现于 runtime_io_abi.c。
 * 与其它文件的关系：不依赖 C 前端；ast_pool 经 shux_read_file_into_path 回退读文件。
 */

#ifndef SHUX_RUNTIME_IO_ABI_H
#define SHUX_RUNTIME_IO_ABI_H

#include <stddef.h>

typedef struct {
    const char *data;
    size_t length;
    int needs_free;
    int needs_munmap;
} ShuxRuntimeFileView;

/**
 * B-20：读整文件到堆缓冲（open/fstat/read）；成功返回 NUL 结尾缓冲，失败 NULL。
 * 参数：path 文件路径；out_len 非 NULL 时写入字节数（不含 NUL）。
 * 返回值：malloc 缓冲；调用方 free。
 */
char *runtime_read_file_malloc(const char *path, size_t *out_len);

/**
 * S7/std.fs dogfood：优先 mmap 只读映射整个文件，失败时可回退 malloc 缓冲。
 * 参数：path 文件路径；out 非 NULL 且成功时写入 data/length 与释放方式。
 * 返回值：0 成功，-1 失败。调用方须 `runtime_release_file_view(out)`。
 */
int runtime_read_file_view(const char *path, ShuxRuntimeFileView *out);

/** 释放 `runtime_read_file_view()` 返回的资源；可重复对零值结构调用。 */
void runtime_release_file_view(ShuxRuntimeFileView *view);

/**
 * B-20：读文件前缀到 buf[0..cap-1]；成功返回读入字节数，失败 -1。
 * 参数：path/buf/cap 见 ast_pool pipeline_read_file_x_impl_c。
 */
int shux_read_file_into_path(const char *path, void *buf, size_t cap);

/**
 * B-20：POSIX write 整文件；成功 0，失败 -1。
 * 参数：path 目标路径；data/len 待写内容。
 */
int shux_write_path_bytes(const char *path, const void *data, size_t len);

#endif /* SHUX_RUNTIME_IO_ABI_H */
