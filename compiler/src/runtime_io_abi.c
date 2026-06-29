/**
 * runtime_io_abi.c — 编译器 C 侧文件 I/O ABI 实现（Phase E-04 v3）
 *
 * 文件职责：POSIX 读/写文件原语；自 runtime.c 拆出，逐步收成 E-04 ABI 薄壳。
 * 所属模块：compiler 运行时 I/O；被 runtime.c、ast_pool（shux_read_file_into_path）链接。
 * 与其它文件的关系：替代 C stdio fopen/fread 用于驱动与 pipeline 读源码。
 * 重要约定：read 路径失败返回 NULL/-1，不写 stderr；调用方负责 free(malloc 缓冲)。
 */

#include "runtime_io_abi.h"

#include <fcntl.h>
#include <limits.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

/**
 * B-20：POSIX read 循环读 fd 到 buf[0..cap-1]；成功返回读入字节数，失败 -1。
 * 参数：fd 已打开描述符；buf/cap 输出缓冲与容量。
 */
static int shux_read_fd_into_buf(int fd, void *buf, size_t cap) {
    size_t off;
    ssize_t n;

    if (fd < 0 || !buf || cap == 0 || cap > (size_t)INT32_MAX)
        return -1;
    off = 0;
    while (off < cap) {
        n = read(fd, (char *)buf + off, cap - off);
        if (n < 0)
            return -1;
        if (n == 0)
            break;
        off += (size_t)n;
    }
    return (int)off;
}

static int shux_runtime_file_view_read_malloc(int fd, size_t size, ShuxRuntimeFileView *out) {
    size_t off;
    char *buf;
    ssize_t n;

    buf = (char *)malloc(size + 1);
    if (!buf) {
        close(fd);
        return -1;
    }
    off = 0;
    while (off < size) {
        n = read(fd, buf + off, size - off);
        if (n < 0) {
            free(buf);
            close(fd);
            return -1;
        }
        if (n == 0)
            break;
        off += (size_t)n;
    }
    close(fd);
    if (off != size) {
        free(buf);
        return -1;
    }
    buf[size] = '\0';
    out->data = buf;
    out->length = size;
    out->needs_free = 1;
    out->needs_munmap = 0;
    return 0;
}

int runtime_read_file_view(const char *path, ShuxRuntimeFileView *out) {
    int fd;
    int fd_fallback;
    struct stat st;
    size_t size;
    void *mapped;

    if (!path || !out)
        return -1;
    memset(out, 0, sizeof(*out));
    fd = open(path, O_RDONLY);
    if (fd < 0)
        return -1;
    if (fstat(fd, &st) != 0 || !S_ISREG(st.st_mode) || st.st_size < 0) {
        close(fd);
        return -1;
    }
    size = (size_t)st.st_size;
    if (size == 0) {
        out->data = "";
        out->length = 0;
        close(fd);
        return 0;
    }
    mapped = mmap(NULL, size, PROT_READ, MAP_PRIVATE, fd, 0);
    close(fd);
    if (mapped == MAP_FAILED) {
        fd_fallback = open(path, O_RDONLY);
        if (fd_fallback < 0)
            return -1;
        return shux_runtime_file_view_read_malloc(fd_fallback, size, out);
    }
    out->data = (const char *)mapped;
    out->length = size;
    out->needs_free = 0;
    out->needs_munmap = 1;
    return 0;
}

void runtime_release_file_view(ShuxRuntimeFileView *view) {
    if (!view)
        return;
    if (view->needs_munmap && view->data && view->length > 0)
        munmap((void *)view->data, view->length);
    if (view->needs_free && view->data)
        free((void *)view->data);
    view->data = NULL;
    view->length = 0;
    view->needs_free = 0;
    view->needs_munmap = 0;
}

/**
 * B-20：POSIX open/fstat/read 读整文件到堆缓冲。
 * 参数：见 runtime_io_abi.h。
 */
char *runtime_read_file_malloc(const char *path, size_t *out_len) {
    ShuxRuntimeFileView view;
    char *buf;

    if (runtime_read_file_view(path, &view) != 0)
        return NULL;
    buf = (char *)malloc(view.length + 1);
    if (!buf) {
        runtime_release_file_view(&view);
        return NULL;
    }
    if (view.length > 0)
        memcpy(buf, view.data, view.length);
    buf[view.length] = '\0';
    if (out_len)
        *out_len = view.length;
    runtime_release_file_view(&view);
    return buf;
}

/**
 * B-20：open/read/close 将文件读入 buf；供 ast_pool 与 driver 语法探测。
 * 参数：见 runtime_io_abi.h。
 */
int shux_read_file_into_path(const char *path, void *buf, size_t cap) {
    int fd;
    int n;

    if (!path || !buf || cap == 0 || cap > (size_t)INT32_MAX)
        return -1;
    fd = open(path, O_RDONLY);
    if (fd < 0)
        return -1;
    n = shux_read_fd_into_buf(fd, buf, cap);
    close(fd);
    return n;
}

/**
 * B-20：open(O_WRONLY|O_CREAT|O_TRUNC)/write 写整文件。
 * 参数：见 runtime_io_abi.h。
 */
int shux_write_path_bytes(const char *path, const void *data, size_t len) {
    int fd;
    size_t off;
    ssize_t n;

    if (!path || !data)
        return -1;
    fd = open(path, O_WRONLY | O_CREAT | O_TRUNC, (mode_t)0644);
    if (fd < 0)
        return -1;
    off = 0;
    while (off < len) {
        n = write(fd, (const char *)data + off, len - off);
        if (n < 0) {
            close(fd);
            return -1;
        }
        if (n == 0)
            break;
        off += (size_t)n;
    }
    close(fd);
    return off == len ? 0 : -1;
}
