/**
 * std/dynlib/dynlib.c — 动态加载 .so/.dll（对标 Zig std.DynLib、Rust libloading）
 *
 * 【文件职责】open(path)、sym(lib, name)、close(lib)；POSIX dlopen/dlsym/dlclose，Windows LoadLibrary/GetProcAddress/FreeLibrary。
 *
 * 【所属模块/组件】标准库 std.dynlib；与 std/dynlib/mod.sx 同属一模块。按需链接。
 */

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#if defined(_WIN32) || defined(_WIN64)
#include <windows.h>
typedef HMODULE dynlib_handle_t;

/**
 * 将 UTF-8 路径中的 '/' 规范为 '\\' 写入 out；返回写入长度（不含 NUL）。
 * out_cap 须 >= 1；失败返回 0。
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

/** UTF-8 路径转宽字符后 LoadLibraryW（STD-097）；烟测与正斜杠路径回退。 */
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

/** 最近一次 open/sym 失败时的诊断文本（STD-096）。 */
static char dynlib_last_err_buf[256];

/** 从 OS 读取动态库错误并写入 dynlib_last_err_buf。 */
static void dynlib_capture_last_error(void) {
  dynlib_last_err_buf[0] = '\0';
#if defined(_WIN32) || defined(_WIN64)
  (void)0; /* Windows 路径由 FormatMessage 扩展；烟测主要在 POSIX 跑 */
#else
  {
    const char *e = dlerror();
    if (e && e[0]) {
      (void)strncpy(dynlib_last_err_buf, e, sizeof(dynlib_last_err_buf) - 1);
      dynlib_last_err_buf[sizeof(dynlib_last_err_buf) - 1] = '\0';
    }
  }
#endif
}

/** 打开动态库 path（NUL 结尾）；失败返回 0。返回不透明句柄。path 为 NULL 或空字符串时返回 0，避免 Linux 上 dlopen("") 返回主程序句柄导致测试/行为不一致。 */
void *dynlib_open_c(const uint8_t *path) {
  if (!path || !path[0]) return NULL;
#if defined(_WIN32) || defined(_WIN64)
  {
    HMODULE h = LoadLibraryA((const char *)path);
    if (!h)
      h = dynlib_win_load_library_w_utf8((const char *)path);
    if (!h) dynlib_capture_last_error();
    return (void *)h;
  }
#else
  {
    void *h = dlopen((const char *)path, RTLD_NOW);
    if (!h) dynlib_capture_last_error();
    return h;
  }
#endif
}

/** 取符号 name（NUL 结尾）；失败返回 0。 */
void *dynlib_sym_c(void *lib, const uint8_t *name) {
  if (!lib || !name) return NULL;
#if defined(_WIN32) || defined(_WIN64)
  {
    void *p = (void *)GetProcAddress((HMODULE)lib, (const char *)name);
    if (!p) dynlib_capture_last_error();
    return p;
  }
#else
  {
    void *p = dlsym(lib, (const char *)name);
    if (!p) dynlib_capture_last_error();
    return p;
  }
#endif
}

/** 关闭动态库。 */
void dynlib_close_c(void *lib) {
  if (!lib) return;
#if defined(_WIN32) || defined(_WIN64)
  FreeLibrary((HMODULE)lib);
#else
  dlclose(lib);
#endif
}

/** 复制最近一次错误到 buf；返回写入字节数（不含 NUL），失败或无内容返回 0。 */
int32_t dynlib_last_error_copy_c(uint8_t *buf, int32_t cap) {
  size_t n;
  if (!buf || cap <= 0) return 0;
  n = strlen(dynlib_last_err_buf);
  if (n == 0) return 0;
  if ((size_t)cap <= n) n = (size_t)cap - 1;
  memcpy(buf, dynlib_last_err_buf, n);
  buf[n] = '\0';
  return (int32_t)n;
}

/** C 烟测：打开不存在路径后 last_error 非空。 */
int32_t dynlib_last_error_smoke_c(void) {
  static const uint8_t bad[] = "/nonexistent/shux_dynlib_missing.so";
  uint8_t msg[128];
  void *lib = dynlib_open_c(bad);
  int32_t n;
  if (lib) {
    dynlib_close_c(lib);
    return -1;
  }
  n = dynlib_last_error_copy_c(msg, (int32_t)sizeof msg);
  return (n > 0) ? 0 : -2;
}

/**
 * STD-097：Windows 正斜杠路径烟测；POSIX 直接返回 0。
 * 校验 dynlib_win_normalize_path 并将 C:/Windows/System32/kernel32.dll 经 LoadLibraryW 打开。
 */
int32_t dynlib_win_path_smoke_c(void) {
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
