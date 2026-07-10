/* Generated from src/runtime_io_abi.x (G-02f-29/44 true .x + C tail).
 * Regen: ./shux-c -E -L .. src/runtime_io_abi.x > /tmp/io.c
 *         merge fs shim; open_write via flags/mode slots; file_view/os_read C.
 * .x covers: open_read/write/close/read/write/invalid + fs_posix_* aliases.
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
#ifndef _WIN32
#include <unistd.h>
#endif

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
#define SHUX_O_BINARY _O_BINARY
#else
#define SHUX_O_BINARY 0
#endif

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
    fd = open(path, O_RDONLY | SHUX_O_BINARY);
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
        fd_fallback = open(path, O_RDONLY | SHUX_O_BINARY);
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
    fd = open(path, O_RDONLY | SHUX_O_BINARY);
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
    fd = open(path, O_WRONLY | O_CREAT | O_TRUNC | SHUX_O_BINARY, (mode_t)0644);
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

/* -------------------------------------------------------------------------- */
/* G-02e：原 std_fs_shim.c / std_sys_shim.c 并入本 TU（产品链减 2 个手写 C 文件）。 */
/* -------------------------------------------------------------------------- */


/** G-02f-44：open_write 平台 flags/mode 槽（.x 调 open）。 */
int32_t shux_fs_open_write_flags(void) {
    return (int32_t)(O_WRONLY | O_CREAT | O_TRUNC | SHUX_O_BINARY);
}

int32_t shux_fs_open_write_mode(void) {
    return (int32_t)0644;
}

int32_t std_fs_fs_open_read(uint8_t * path) {
  if ((path ==((uint8_t *)(0)))) {
    return (0 - 1);
  }
  (void)(({   {
    int32_t r = open(path, 0, 0);
    return r;
  }
 }));
  return (0 - 1);
}

int32_t std_fs_fs_open_write(uint8_t * path) {
  if ((path ==((uint8_t *)(0)))) {
    return (0 - 1);
  }
  (void)(({   {
    int32_t fl = shux_fs_open_write_flags();
    int32_t md = shux_fs_open_write_mode();
    int32_t r = open(path, fl, md);
    return r;
  }
 }));
  return (0 - 1);
}

int32_t std_fs_fs_close(int32_t fd) {
  (void)(({   {
    int32_t r = close(fd);
    return r;
  }
 }));
  return (0 - 1);
}

int32_t std_fs_fs_invalid_handle(void) {
  return (0 - 1);
}

ssize_t std_fs_fs_read(int32_t fd, uint8_t * buf, size_t count) {
  if ((buf ==((uint8_t *)(0)))) {
    ssize_t neg = ((ssize_t)((0 - 1)));
    return neg;
  }
  (void)(({   {
    ssize_t n = read(fd, buf, count);
    return n;
  }
 }));
  ssize_t neg2 = ((ssize_t)((0 - 1)));
  return neg2;
}

ssize_t std_fs_fs_write(int32_t fd, uint8_t * buf, size_t count) {
  if ((buf ==((uint8_t *)(0)))) {
    ssize_t neg = ((ssize_t)((0 - 1)));
    return neg;
  }
  (void)(({   {
    ssize_t n = write(fd, buf, count);
    return n;
  }
 }));
  ssize_t neg2 = ((ssize_t)((0 - 1)));
  return neg2;
}

int32_t fs_posix_close_c(int32_t fd) {
  return std_fs_fs_close(fd);
}

ssize_t fs_posix_write_c(int32_t fd, uint8_t * buf, size_t count) {
  return std_fs_fs_write(fd, buf, count);
}

ssize_t fs_posix_read_c(int32_t fd, uint8_t * buf, size_t count) {
  return std_fs_fs_read(fd, buf, count);
}

/**
 * std.sys.os_read_file_into 的 C 链接符号（-E-extern import 名）。
 * 成功返回读入字节数；失败 -1。
 */
int32_t std_sys_os_read_file_into(uint8_t *path, uint8_t *buf, int32_t cap) {
  int32_t fd;
  int32_t total;
  if (!path || !buf || cap <= 0)
    return -1;
  fd = (int32_t)open((const char *)path, O_RDONLY | SHUX_O_BINARY, 0);
  if (fd < 0)
    return -1;
  total = 0;
  while (total < cap) {
    int32_t chunk = cap - total;
    ssize_t r = read(fd, buf + total, (size_t)chunk);
    if (r < 0) {
      close(fd);
      return -1;
    }
    if (r == 0)
      break;
    total += (int32_t)r;
  }
  close(fd);
  return total;
}

