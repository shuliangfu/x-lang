/**
 * runtime_dynlib_os.c — 动态库 OS 胶层（F-ZC：自 std/dynlib/dynlib_os_glue.c 迁入）
 *
 * dlopen/dlsym/dlclose、LoadLibrary/GetProcAddress/FreeLibrary；
 * dynlib.x 经 extern 调用；与 dynlib.o 一并链入（Linux 需 -ldl）。
 */
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#if defined(_WIN32) || defined(_WIN64)
#include <windows.h>
typedef HMODULE dynlib_handle_t;

/**
 * 将 UTF-8 路径中的 '/' 规范为 '\\' 写入 out。
 * 参数：out 输出缓冲；out_cap 容量；path UTF-8 路径。
 * 返回值：写入长度（不含 NUL）；失败 0。
 */
static size_t dynlib_win_normalize_path(char *out, size_t out_cap, const char *path) {
    size_t i = 0;
    if (!out || out_cap < 2 || !path)
        return 0;
    for (; path[i] != '\0' && i + 1 < out_cap; i++) {
        char c = path[i];
        if (c == '/')
            c = '\\';
        out[i] = c;
    }
    out[i] = '\0';
    return i;
}

/** UTF-8 路径转宽字符后 LoadLibraryW（STD-097）。 */
static HMODULE dynlib_win_load_library_w_utf8(const char *path_utf8) {
    wchar_t wpath[512];
    char norm[512];
    int n;
    if (!path_utf8 || !path_utf8[0])
        return NULL;
    if (dynlib_win_normalize_path(norm, sizeof norm, path_utf8) == 0)
        return NULL;
    n = MultiByteToWideChar(CP_UTF8, 0, norm, -1, wpath, (int)(sizeof(wpath) / sizeof(wpath[0])));
    if (n <= 0)
        return NULL;
    return LoadLibraryW(wpath);
}
#else
#include <dlfcn.h>
typedef void *dynlib_handle_t;
#endif

/**
 * 从 OS 读取动态库错误并写入 buf。
 * 参数：buf 输出；cap 容量。
 * 返回值：写入字节数（不含 NUL）；无内容 0。
 */
int32_t dynlib_os_copy_last_error_c(uint8_t *buf, int32_t cap) {
    if (!buf || cap <= 0)
        return 0;
    buf[0] = '\0';
#if defined(_WIN32) || defined(_WIN64)
    /* 【Why 根源】Windows 无 dlerror：用 GetLastError + FormatMessageA 取系统错误描述。
     * dynlib_os_open_c 失败后立即调用 dynlib_note_os_error_c → 本函数，
     * GetLastError 仍保留 LoadLibrary 失败码（ERROR_MOD_NOT_FOUND 等）。
     * 【Invariant】buf[0..cap) 可写；FormatMessageA NUL 终止；去尾 \r\n 避免诊断噪声。
     * 【Asm/Perf】仅失败路径调用，热路径无开销。 */
    {
        DWORD err = GetLastError();
        DWORD n;
        if (err == 0)
            return 0;
        n = FormatMessageA(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
                           NULL, err, 0, (LPSTR)buf, (DWORD)cap, NULL);
        if (n == 0) {
            buf[0] = '\0';
            return 0;
        }
        while (n > 0 && (buf[n-1] == '\r' || buf[n-1] == '\n' || buf[n-1] == ' '))
            buf[--n] = '\0';
        return (int32_t)n;
    }
#else
    {
        const char *e = dlerror();
        size_t n;
        if (!e || !e[0])
            return 0;
        n = strlen(e);
        if ((size_t)cap <= n)
            n = (size_t)cap - 1;
        memcpy(buf, e, n);
        buf[n] = '\0';
        return (int32_t)n;
    }
#endif
}

/**
 * 打开动态库 path（NUL 结尾）。
 * 返回值：句柄；失败 NULL。
 */
void *dynlib_os_open_c(const uint8_t *path) {
    if (!path || !path[0])
        return NULL;
#if defined(_WIN32) || defined(_WIN64)
    {
        HMODULE h = LoadLibraryA((const char *)path);
        if (!h)
            h = dynlib_win_load_library_w_utf8((const char *)path);
        return (void *)h;
    }
#else
    return dlopen((const char *)path, RTLD_NOW);
#endif
}

/**
 * 取符号 name（NUL 结尾）。
 * 返回值：符号地址；失败 NULL。
 */
void *dynlib_os_sym_c(void *lib, const uint8_t *name) {
    if (!lib || !name)
        return NULL;
#if defined(_WIN32) || defined(_WIN64)
    return (void *)GetProcAddress((HMODULE)lib, (const char *)name);
#else
    return dlsym(lib, (const char *)name);
#endif
}

/** 关闭动态库句柄。 */
void dynlib_os_close_c(void *lib) {
    if (!lib)
        return;
#if defined(_WIN32) || defined(_WIN64)
    FreeLibrary((HMODULE)lib);
#else
    dlclose(lib);
#endif
}

/**
 * STD-097：Windows 正斜杠路径烟测；POSIX 直接返回 0。
 * 返回值：0 成功；负值失败码。
 */
int32_t dynlib_os_win_path_smoke_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    char norm[128];
    HMODULE h;
    if (dynlib_win_normalize_path(norm, sizeof norm, "C:/Windows/System32/kernel32.dll") == 0)
        return -1;
    {
        size_t k = 0;
        while (norm[k] != '\0') {
            if (norm[k] == '/')
                return -2;
            k++;
        }
    }
    h = LoadLibraryW(L"C:\\Windows\\System32\\kernel32.dll");
    if (!h)
        h = dynlib_win_load_library_w_utf8("C:/Windows/System32/kernel32.dll");
    return h ? 0 : -3;
#else
    return 0;
#endif
}
