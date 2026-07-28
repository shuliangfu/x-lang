/* seeds/runtime_dynlib_os.from_x.c — G-02f-20 product TU
 * G-02f-112 helper gates.
 * Product: runtime_dynlib_os.o; R2 full mode.
 *
 * wave502 R2 migration: public API moved to src/asm/runtime_dynlib_os.x;
 * this file only retains OS bridge _impl functions, guarded by
 * XLANG_RUNTIME_DYNLIB_OS_FROM_X when building the rest object.
 * Cold path (without FROM_X guard) provides full public API for bootstrapping.
 *
 * PLATFORM: SHARED — Windows (LoadLibrary/GetProcAddress/FreeLibrary)
 *           POSIX (dlopen/dlsym/dlclose) with _WIN32 / _WIN64 branches.
 */

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#if defined(_WIN32) || defined(_WIN64)
#include <windows.h>
typedef HMODULE dynlib_handle_t;

/* R2 full: dynlib_win_normalize_path is pure computation, implemented in .x.
 * Guarded here to avoid duplicate definition when FROM_X is active. */
#ifndef XLANG_RUNTIME_DYNLIB_OS_FROM_X
/* Public wrapper — only compiled in cold (non-FROM_X) mode.
 * Real implementation is in .x (src/asm/runtime_dynlib_os.x). */
size_t dynlib_win_normalize_path(char *out, size_t out_cap, const char *path) {
    /* Cold-path fallback: minimal C implementation matching .x semantics.
     * This exists only for bootstrapping before .x is available. */
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
#endif

/* OS bridge _impl: UTF-8 path → LoadLibraryW (STD-097).
 * Declared extern "C" in runtime_dynlib_os.x. */
HMODULE dynlib_win_load_library_w_utf8_impl(const char *path_utf8) {
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

#ifndef XLANG_RUNTIME_DYNLIB_OS_FROM_X
/* Public wrapper — delegates to _impl. Only in cold mode. */
HMODULE dynlib_win_load_library_w_utf8(const char *path_utf8) {
    return dynlib_win_load_library_w_utf8_impl(path_utf8);
}
#endif

#else /* !_WIN32 && !_WIN64 */
#include <dlfcn.h>
typedef void *dynlib_handle_t;
#endif

/* OS bridge _impl: retrieve last OS error message into buffer.
 * Windows: GetLastError + FormatMessageA; POSIX: dlerror().
 * Declared extern "C" in runtime_dynlib_os.x. */
int32_t dynlib_os_copy_last_error_impl(uint8_t *buf, int32_t cap) {
    if (!buf || cap <= 0)
        return 0;
    buf[0] = '\0';
#if defined(_WIN32) || defined(_WIN64)
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

#ifndef XLANG_RUNTIME_DYNLIB_OS_FROM_X
/* Public wrapper — only in cold mode. */
int32_t dynlib_os_copy_last_error_c(uint8_t *buf, int32_t cap) {
    return dynlib_os_copy_last_error_impl(buf, cap);
}
#endif

/* OS bridge _impl: open dynamic library.
 * Windows: LoadLibraryA with LoadLibraryW fallback; POSIX: dlopen(RTLD_NOW).
 * Declared extern "C" in runtime_dynlib_os.x. */
void *dynlib_os_open_impl(const uint8_t *path) {
    if (!path || !path[0])
        return NULL;
#if defined(_WIN32) || defined(_WIN64)
    {
        HMODULE h = LoadLibraryA((const char *)path);
        if (!h)
            h = dynlib_win_load_library_w_utf8_impl((const char *)path);
        return (void *)h;
    }
#else
    return dlopen((const char *)path, RTLD_NOW);
#endif
}

#ifndef XLANG_RUNTIME_DYNLIB_OS_FROM_X
/* Public wrapper — only in cold mode. */
void *dynlib_os_open_c(const uint8_t *path) {
    return dynlib_os_open_impl(path);
}
#endif

/* OS bridge _impl: look up symbol in library.
 * Windows: GetProcAddress; POSIX: dlsym.
 * Declared extern "C" in runtime_dynlib_os.x. */
void *dynlib_os_sym_impl(void *lib, const uint8_t *name) {
    if (!lib || !name)
        return NULL;
#if defined(_WIN32) || defined(_WIN64)
    return (void *)GetProcAddress((HMODULE)lib, (const char *)name);
#else
    return dlsym(lib, (const char *)name);
#endif
}

#ifndef XLANG_RUNTIME_DYNLIB_OS_FROM_X
/* Public wrapper — only in cold mode. */
void *dynlib_os_sym_c(void *lib, const uint8_t *name) {
    return dynlib_os_sym_impl(lib, name);
}
#endif

/* OS bridge _impl: close dynamic library handle.
 * Windows: FreeLibrary; POSIX: dlclose.
 * Declared extern "C" in runtime_dynlib_os.x. */
void dynlib_os_close_impl(void *lib) {
    if (!lib)
        return;
#if defined(_WIN32) || defined(_WIN64)
    FreeLibrary((HMODULE)lib);
#else
    dlclose(lib);
#endif
}

#ifndef XLANG_RUNTIME_DYNLIB_OS_FROM_X
/* Public wrapper — only in cold mode. */
void dynlib_os_close_c(void *lib) {
    dynlib_os_close_impl(lib);
}
#endif

/* OS bridge _impl: Windows-only path smoke test.
 * Verifies forward-slash path normalization + LoadLibraryW fallback.
 * Declared extern "C" in runtime_dynlib_os.x. */
int32_t dynlib_os_win_path_smoke_impl(void) {
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
        h = dynlib_win_load_library_w_utf8_impl("C:/Windows/System32/kernel32.dll");
    return h ? 0 : -3;
#else
    return 0;
#endif
}

#ifndef XLANG_RUNTIME_DYNLIB_OS_FROM_X
/* Public wrapper — only in cold mode. */
int32_t dynlib_os_win_path_smoke_c(void) {
    return dynlib_os_win_path_smoke_impl();
}
#endif
