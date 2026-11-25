/* Generated from src/runtime_io_abi.x (G-02f-29/44/57..59 true .x + C tail).
 * G-02f-334：PREFER_X_O hybrid 时 thin 由 .x→-E；rest 用 XLANG_L2_RIO_THIN_FROM_X
 *   + XLANG_RUNTIME_IO_ABI_FROM_X（省略已真迁 _impl；仅 slice_marker）。
 * Cap residual pure (2026-07-21)：4 平台 _impl 真迁 .x
 *   （flags_impl / write_path_bytes_impl / release_file_view_impl / read_file_view_impl）。
 * Cold seed 仍保留 mmap/fstat C 体（无 FROM_X）。
 * Regen: ./xlang-c -E -L .. src/runtime_io_abi.x > /tmp/io.c
 * .x covers: std.fs/posix + path/file_view 门闩 + Cap residual pure _impl。
 */
#include "win32_compat.h"
#include "runtime_io_abi.h"

#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifndef _WIN32
#include <sys/mman.h>
#endif
#include <sys/stat.h>
/* PLATFORM: SHARED — include/unistd.h shim provides POSIX wrappers on MinGW
 *            (read/write/close/lseek/open/pread/pwrite/setenv/unsetenv).
 *            macOS/Linux delegate to system <unistd.h> via #include_next.
 *            Historical #ifndef _WIN32 guard removed — shim is a no-op
 *            on POSIX and provides needed declarations on Windows. */
#include <unistd.h>
#include <xlang_io_cap.h>
/* 【Why 根源】MinGW open() 默认文本模式，read/write 做 CRLF↔LF 转换，
 * 导致 fstat 报告的 st_size（物理字节数）与 read 实际返回字节数不一致。
 * 例：fmt 写入 37 字节 LF，文本模式 write 磁盘为 40 字节 CRLF；
 * fstat 报告 40，但 read 文本模式转换后只返回 37 → read mismatch → IO001。
 * 【Invariant】所有编译器 I/O 路径必须用二进制模式，保证 read/write 透明传输。
 * 【Asm/Perf】_O_BINARY 是 MinGW _open 的 flag，零运行时开销。 */
#if defined(_WIN32) || defined(_WIN64)
#include <fcntl.h>
#ifndef _O_BINARY
#define _O_BINARY 0x8000
#endif
#define XLANG_O_BINARY _O_BINARY
#else
#define XLANG_O_BINARY 0
#endif

/**
 * B-20：POSIX read 循环读 fd 到 buf[0..cap-1]；成功返回读入字节数，失败 -1。
 * 参数：fd 已打开描述符；buf/cap 输出缓冲与容量。
 * Cap residual 9.1.8: Linux via xlang_io_cap.h (no libc read); Win keeps read().
 * G-02f-334：hybrid 时作 _impl（.x thin 门闩调 _impl）。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-rest：rest→.x 迁移：_impl 真迁 .x，PREFER_X_O 路径下整体跳过 */
#ifndef XLANG_RUNTIME_IO_ABI_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_RUNTIME_IO_ABI_FROM_X removed */
#ifndef XLANG_L2_RIO_THIN_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_L2_RIO_THIN_FROM_X removed */
#else
        return xlang_runtime_file_view_read_malloc(fd_fallback, size, out);
#endif
#endif /* XLANG_RUNTIME_IO_ABI_FROM_X */


/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-334：hybrid 时作 _impl */
/* G-02f-rest：rest→.x 迁移：_impl 真迁 .x，PREFER_X_O 路径下整体跳过 */
#ifndef XLANG_RUNTIME_IO_ABI_FROM_X
#ifndef XLANG_L2_RIO_THIN_FROM_X
#else
        return xlang_runtime_file_view_read_malloc(fd_fallback, size, out);
#endif
#endif /* XLANG_RUNTIME_IO_ABI_FROM_X */


/* G-02f-59 io helper protos（hybrid 时 flags 由 thin 调 flags_impl） */
#ifndef XLANG_L2_RIO_THIN_FROM_X
#else
int32_t xlang_fs_open_write_flags_impl(void);
#endif
/* G-02f-58 helper protos */
int runtime_read_file_view_impl(const char *path, XlangRuntimeFileView *out);
char *runtime_read_file_malloc_impl(const char *path, size_t *out_len);
int32_t std_sys_os_read_file_into_impl(uint8_t *path, uint8_t *buf, int32_t cap);

/* G-02f-57 helper protos */
int xlang_read_file_into_path_impl(const char *path, void *buf, size_t cap);
int xlang_write_path_bytes_impl(const char *path, const void *data, size_t len);
void runtime_release_file_view_impl(XlangRuntimeFileView *view);

/* G-02f-rest：5 个 pure _impl 已在 .x；FROM_X 时 seed 仅声明供 cold 互调。
 * Cap residual pure (2026-07-21)：4 平台 _impl 亦真迁 .x（flags/write/release/read_view）。
 * Cold (no FROM_X) 仍保留下方 C 体（mmap/fstat 路径）。 */
int xlang_read_fd_into_buf_impl(int fd, void *buf, size_t cap);
int xlang_runtime_file_view_read_malloc_impl(int fd, size_t size, XlangRuntimeFileView *out);

#ifndef XLANG_RUNTIME_IO_ABI_FROM_X
#ifdef XLANG_L2_RIO_THIN_FROM_X
#else
        return xlang_runtime_file_view_read_malloc(fd_fallback, size, out);
#endif
#endif /* !XLANG_RUNTIME_IO_ABI_FROM_X */

#ifndef XLANG_L2_RIO_THIN_FROM_X
#endif

#ifndef XLANG_RUNTIME_IO_ABI_FROM_X
#endif /* !XLANG_RUNTIME_IO_ABI_FROM_X */

#ifndef XLANG_L2_RIO_THIN_FROM_X
#endif

/**
 * B-20：POSIX open/fstat/read 读整文件到堆缓冲。
 * 参数：见 runtime_io_abi.h。
 */
/* G-02f-rest：rest→.x 迁移：_impl 真迁 .x，PREFER_X_O 路径下整体跳过 */
#ifndef XLANG_RUNTIME_IO_ABI_FROM_X
#ifdef XLANG_L2_RIO_THIN_FROM_X
#else
int32_t xlang_fs_open_write_flags_impl(void)
#endif
#ifdef XLANG_L2_RIO_THIN_FROM_X
#else
    runtime_release_file_view(&view);
#endif
#ifdef XLANG_L2_RIO_THIN_FROM_X
#else
    runtime_release_file_view(&view);
#endif
#endif /* XLANG_RUNTIME_IO_ABI_FROM_X */

#ifndef XLANG_L2_RIO_THIN_FROM_X
#endif

/**
 * B-20：open/read/close 将文件读入 buf；供 ast_pool 与 driver 语法探测。
 * 参数：见 runtime_io_abi.h。
 */
/* G-02f-rest：rest→.x 迁移：_impl 真迁 .x，PREFER_X_O 路径下整体跳过 */
#ifndef XLANG_RUNTIME_IO_ABI_FROM_X
#ifdef XLANG_L2_RIO_THIN_FROM_X
#else
int32_t xlang_fs_open_write_flags_impl(void)
#endif
#endif /* XLANG_RUNTIME_IO_ABI_FROM_X */

#ifndef XLANG_L2_RIO_THIN_FROM_X
#endif

/**
 * B-20：open(O_WRONLY|O_CREAT|O_TRUNC)/write 写整文件。
 * 参数：见 runtime_io_abi.h。
 * Cap residual 9.1.8: Linux via xlang_io_cap.h (no libc write); .x twin same.
 * Cap residual pure：.x 真迁；FROM_X 时由 .x 提供。
 */
#ifndef XLANG_RUNTIME_IO_ABI_FROM_X
#endif /* !XLANG_RUNTIME_IO_ABI_FROM_X */

#ifndef XLANG_L2_RIO_THIN_FROM_X
#endif

/* -------------------------------------------------------------------------- */
/* G-02e：原 std_fs_shim.c / std_sys_shim.c 并入本 TU（产品链减 2 个手写 C 文件）。 */
/* -------------------------------------------------------------------------- */


/** G-02f-44：open_write 平台 flags/mode 槽（.x 调 open）。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-334：hybrid 时作 flags_impl（.x thin 门闩调 _impl） */
/* Cap residual pure：flags_impl 真迁 .x；FROM_X 时整段跳过 */
#ifndef XLANG_RUNTIME_IO_ABI_FROM_X
#ifndef XLANG_L2_RIO_THIN_FROM_X
#else
int32_t xlang_fs_open_write_flags_impl(void)
#endif
#endif /* !XLANG_RUNTIME_IO_ABI_FROM_X */

/* G-02f-120：逻辑源 .x（真迁）；hybrid 时 mode 由 .x thin 提供 */
#ifndef XLANG_L2_RIO_THIN_FROM_X
#endif

/* G-02f-334：std.fs / posix 公共门闩由 .x thin；默认 seed 保留 */
#ifndef XLANG_L2_RIO_THIN_FROM_X
#endif /* !XLANG_L2_RIO_THIN_FROM_X */

/**
 * std.sys.os_read_file_into 的 C 链接符号（-E-extern import 名）。
 * 成功返回读入字节数；失败 -1。
 */
/* G-02f-rest：rest→.x 迁移：_impl 真迁 .x，PREFER_X_O 路径下整体跳过 */
#ifndef XLANG_RUNTIME_IO_ABI_FROM_X
#endif /* XLANG_RUNTIME_IO_ABI_FROM_X */

#ifndef XLANG_L2_RIO_THIN_FROM_X
#endif

/* R2：PREFER_X_O + FROM_X 下 rest 业务 H=0（仅 slice marker；4 平台 Cap residual pure 已闭） */
int runtime_io_abi_slice_marker(void) {
    return 1;
}

