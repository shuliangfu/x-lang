/**
 * std/sys/win32.inc.c — B-17 v1/v2：kernel32 GetStdHandle/WriteFile/CreateFileA/ReadFile
 *
 * 【职责】为 std.sys.win32.sx 提供 Windows I/O FFI；非 Windows 宿主返回 -1/0 占位。
 * 【链接】Windows 可执行文件链入本 .o 并自动解析 kernel32 WriteFile IAT。
 */
#include <stddef.h>
#include <stdint.h>

#if defined(_WIN32)
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#include <windows.h>

/** 返回 GetStdHandle(n)；失败 INVALID_HANDLE_VALUE → NULL。 */
void *shux_win32_get_std_handle(int32_t n) {
    HANDLE h = GetStdHandle((DWORD)n);
    if (h == NULL || h == INVALID_HANDLE_VALUE) {
        return NULL;
    }
    return (void *)h;
}

/**
 * WriteFile 薄封装；成功返回写入字节数，失败 -1。
 * written_out 可为 NULL。
 */
int32_t shux_win32_write_file(void *handle, const uint8_t *buf, int32_t len, uint32_t *written_out) {
    DWORD written = 0;
    if (!handle || !buf || len <= 0) {
        return -1;
    }
    if (!WriteFile((HANDLE)handle, buf, (DWORD)len, &written, NULL)) {
        return -1;
    }
    if (written_out) {
        *written_out = written;
    }
    return (int32_t)written;
}

/** v1 探测：Windows 宿主恒 1。 */
int32_t shux_win32_write_available_c(void) {
    return 1;
}

/**
 * CreateFileA + ReadFile 循环读文件到 buf[0..cap)；成功返回读入字节数，失败 -1。
 * path 为 NUL 结尾 ANSI 路径（B-17 v2）。
 */
int32_t shux_win32_read_file_into_path(const uint8_t *path, uint8_t *buf, int32_t cap) {
    HANDLE h;
    int32_t total;
    if (!path || !buf || cap <= 0) {
        return -1;
    }
    h = CreateFileA((LPCSTR)path, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING,
                    FILE_ATTRIBUTE_NORMAL, NULL);
    if (h == INVALID_HANDLE_VALUE) {
        return -1;
    }
    total = 0;
    while (total < cap) {
        DWORD chunk = (DWORD)(cap - total);
        DWORD nr = 0;
        if (!ReadFile(h, buf + (DWORD)total, chunk, &nr, NULL)) {
            CloseHandle(h);
            return -1;
        }
        if (nr == 0) {
            break;
        }
        total += (int32_t)nr;
    }
    CloseHandle(h);
    return total;
}

/** v2 探测：ReadFile 是否在 Windows 宿主可用（恒 1）。 */
int32_t shux_win32_read_available_c(void) {
    return 1;
}

#else

void *shux_win32_get_std_handle(int32_t n) {
    (void)n;
    return NULL;
}

int32_t shux_win32_write_file(void *handle, const uint8_t *buf, int32_t len, uint32_t *written_out) {
    (void)handle;
    (void)buf;
    (void)len;
    (void)written_out;
    return -1;
}

int32_t shux_win32_write_available_c(void) {
    return 0;
}

int32_t shux_win32_read_file_into_path(const uint8_t *path, uint8_t *buf, int32_t cap) {
    (void)path;
    (void)buf;
    (void)cap;
    return -1;
}

int32_t shux_win32_read_available_c(void) {
    return 0;
}

#endif
