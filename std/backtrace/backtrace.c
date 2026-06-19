/**
 * std/backtrace/backtrace.c — 调用栈捕获（对标 Rust std::backtrace）
 *
 * 【文件职责】
 * capture：将当前调用栈的帧指针/返回地址写入 buf（每帧 sizeof(void*) 字节），返回帧数。
 * symbolicate：dladdr / DbgHelp 符号化；金样锚点 backtrace_gold_anchor_c。
 *
 * 【所属模块/组件】
 * 标准库 std.backtrace；与 std/backtrace/mod.sx 同属一模块。
 */

#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>

#define BACKTRACE_SYM_NAME_LEN 128

/* execinfo.h 为 glibc 扩展，Alpine/musl 等无此头文件；仅在有 execinfo 时使用。 */
#if (defined(__linux__) && defined(__GLIBC__)) || defined(__APPLE__)
#include <execinfo.h>
#define HAVE_EXECINFO 1
#endif

#if defined(HAVE_EXECINFO) || defined(__APPLE__)
#include <dlfcn.h>
#define HAVE_DLADDR 1
#endif

#if defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#ifdef _MSC_VER
#pragma comment(lib, "dbghelp.lib")
#endif
#include <dbghelp.h>
#endif

/** 金样锚点：烟测 symbolicate 期望符号名含 gold_anchor。 */
void backtrace_gold_anchor_c(void);

/** 前向声明（capture 烟测辅助）。 */
int32_t backtrace_capture_c(uint8_t *buf, int32_t max_frames);
int32_t backtrace_symbolicate_c(const uint8_t *buf, int32_t len, uint8_t *out_ptrs, uint8_t *out_names,
                                int32_t max);
static int32_t name_has_gold_anchor(const char *name);

/** capture 烟测模式：在锚点函数内 capture 栈。 */
static int32_t g_sym_capture_mode = 0;
static int32_t g_sym_capture_result = 0;

/** 从当前栈 capture 并检查是否含 gold_anchor 符号。 */
static int32_t capture_and_check_gold_anchor(void) {
  uint8_t buf[512];
  uint8_t names[8 * BACKTRACE_SYM_NAME_LEN];
  int32_t n = backtrace_capture_c(buf, 8);
  if (n <= 0) return 10;
  int32_t sym_n = backtrace_symbolicate_c(buf, n, buf, names, n);
  if (sym_n <= 0) return 11;
  for (int32_t i = 0; i < n; i++) {
    if (name_has_gold_anchor((char *)(names + (size_t)i * BACKTRACE_SYM_NAME_LEN))) {
      return 0;
    }
  }
  return 12;
}

/** 金样锚点实现：烟测模式下在栈内 capture。 */
void backtrace_gold_anchor_c(void) {
  if (g_sym_capture_mode) {
    g_sym_capture_result = capture_and_check_gold_anchor();
    g_sym_capture_mode = 0;
  }
}

/** 从 buf 读取第 i 帧地址。 */
static void *read_frame_addr(const uint8_t *buf, int32_t i) {
  size_t ptr_size = sizeof(void *);
  const uint8_t *src = buf + (size_t)i * ptr_size;
  void *p = NULL;
  uint8_t *dst = (uint8_t *)&p;
  for (size_t k = 0; k < ptr_size; k++) dst[k] = src[k];
  return p;
}

/** 将地址写入 buf 第 i 帧。 */
static void write_frame_addr(uint8_t *buf, int32_t i, void *addr) {
  size_t ptr_size = sizeof(void *);
  uint8_t *dst = buf + (size_t)i * ptr_size;
  const uint8_t *src = (const uint8_t *)&addr;
  for (size_t k = 0; k < ptr_size; k++) dst[k] = src[k];
}

/** 复制符号名到 out（最多 name_cap-1 字节 + NUL）。 */
static void copy_sym_name(char *out, int32_t name_cap, const char *name) {
  if (!out || name_cap <= 0) return;
  if (!name) {
    out[0] = 0;
    return;
  }
  int32_t n = (int32_t)strlen(name);
  if (n >= name_cap) n = name_cap - 1;
  memcpy(out, name, (size_t)n);
  out[n] = 0;
}

/** 十六进制回退（不计入成功帧数）。 */
static void format_hex_addr(char *out, int32_t cap, void *addr) {
  if (!out || cap <= 0) return;
  (void)snprintf(out, (size_t)cap, "0x%zx", (size_t)(uintptr_t)addr);
}

/** 检查符号名是否含 gold_anchor 子串。 */
static int32_t name_has_gold_anchor(const char *name) {
  if (!name) return 0;
  return strstr(name, "gold_anchor") != NULL;
}

/** 将当前调用栈捕获到 buf；buf 按帧存储，每帧 sizeof(void*) 字节（通常 8）。
 * 返回写入的帧数（≤ max_frames）；失败或不支持平台返回 0。
 */
int32_t backtrace_capture_c(uint8_t *buf, int32_t max_frames) {
  if (!buf || max_frames <= 0) return 0;
#if defined(HAVE_EXECINFO)
  {
    void *arr[256];
    int n = backtrace(arr, max_frames > 256 ? 256 : (int)max_frames);
    if (n <= 0) return 0;
    size_t ptr_size = sizeof(void *);
    for (int i = 0; i < n; i++) {
      void *p = arr[i];
      uint8_t *dst = buf + (size_t)i * ptr_size;
      const uint8_t *src = (const uint8_t *)&p;
      for (size_t k = 0; k < ptr_size; k++) dst[k] = src[k];
    }
    return (int32_t)n;
  }
#elif defined(_WIN32) || defined(_WIN64)
  {
    void *arr[256];
    uint32_t n = CaptureStackBackTrace(0, (uint32_t)(max_frames > 256 ? 256 : max_frames), arr, NULL);
    if (n == 0) return 0;
    size_t ptr_size = sizeof(void *);
    for (uint32_t i = 0; i < n; i++) {
      void *p = arr[i];
      uint8_t *dst = buf + (size_t)i * ptr_size;
      const uint8_t *src = (const uint8_t *)&p;
      for (size_t k = 0; k < ptr_size; k++) dst[k] = src[k];
    }
    return (int32_t)n;
  }
#else
  (void)buf;
  (void)max_frames;
  return 0;
#endif
}

/** 将 capture 得到的 buf 符号化；len 为帧数；out_names 布局 max × SYM_NAME_LEN。
 * 返回成功解析符号的帧数（不含十六进制回退）。
 */
int32_t backtrace_symbolicate_c(const uint8_t *buf, int32_t len, uint8_t *out_ptrs, uint8_t *out_names,
                                int32_t max) {
  if (!buf || len <= 0 || !out_names || max <= 0) return 0;
  int32_t ok = 0;
  int32_t n = len < max ? len : max;

  for (int32_t i = 0; i < n; i++) {
    void *addr = read_frame_addr(buf, i);
    char *name_slot = (char *)(out_names + (size_t)i * BACKTRACE_SYM_NAME_LEN);

    if (out_ptrs) {
      write_frame_addr(out_ptrs, i, addr);
    }

#if defined(HAVE_DLADDR)
    {
      Dl_info info;
      memset(&info, 0, sizeof(info));
      if (dladdr(addr, &info) && info.dli_sname && info.dli_sname[0]) {
        copy_sym_name(name_slot, BACKTRACE_SYM_NAME_LEN, info.dli_sname);
        ok++;
      } else {
        format_hex_addr(name_slot, BACKTRACE_SYM_NAME_LEN, addr);
      }
    }
#elif defined(_WIN32) || defined(_WIN64)
    {
      static int sym_init = 0;
      if (!sym_init) {
        SymSetOptions(SYMOPT_UNDNAME | SYMOPT_DEFERRED_LOADS);
        SymInitialize(GetCurrentProcess(), NULL, TRUE);
        sym_init = 1;
      }
      char undec[BACKTRACE_SYM_NAME_LEN];
      DWORD64 disp = 0;
      SYMBOL_INFO_PACKAGE pkg;
      memset(&pkg, 0, sizeof(pkg));
      pkg.si.SizeOfStruct = sizeof(SYMBOL_INFO);
      pkg.si.MaxNameLen = MAX_SYM_NAME;
      if (SymFromAddr(GetCurrentProcess(), (DWORD64)(uintptr_t)addr, &disp, &pkg.si)) {
        if (UnDecorateSymbolName(pkg.si.Name, undec, (DWORD)sizeof(undec), UNDNAME_COMPLETE)) {
          copy_sym_name(name_slot, BACKTRACE_SYM_NAME_LEN, undec);
        } else {
          copy_sym_name(name_slot, BACKTRACE_SYM_NAME_LEN, pkg.si.Name);
        }
        ok++;
      } else {
        format_hex_addr(name_slot, BACKTRACE_SYM_NAME_LEN, addr);
      }
    }
#else
    format_hex_addr(name_slot, BACKTRACE_SYM_NAME_LEN, addr);
#endif
  }
  return ok;
}

/** STD-052 C 烟测：直接符号化 gold_anchor + capture 路径。 */
int32_t backtrace_symbolicate_smoke_c(void) {
  uint8_t buf[64];
  uint8_t names[BACKTRACE_SYM_NAME_LEN];

  /* 直接符号化锚点地址 */
  write_frame_addr(buf, 0, (void *)backtrace_gold_anchor_c);
  if (backtrace_symbolicate_c(buf, 1, buf, names, 1) <= 0) return 1;
  if (!name_has_gold_anchor((char *)names)) return 2;

  /* capture → symbolicate：在锚点函数内 capture 栈 */
  g_sym_capture_mode = 1;
  g_sym_capture_result = 12;
  backtrace_gold_anchor_c();
  return g_sym_capture_result;
}
