/**
 * runtime_backtrace_platform.c — 调用栈平台胶层（F-ZC：自 std/backtrace/backtrace_platform_glue.c 迁入）
 *
 * execinfo/dladdr/DbgHelp capture/symbolicate；noinline gold_anchor；
 * SAFE-007 crash evidence 落盘。帧辅助与烟测编排在 backtrace.sx；与 backtrace.o 一并链入。
 */

#if defined(__linux__) && !defined(_GNU_SOURCE)
#define _GNU_SOURCE
#endif

#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "diag.h"
#if defined(__unix__) || defined(__APPLE__)
#include <unistd.h>
#endif

#define BACKTRACE_SYM_NAME_LEN 128

/** 烟测全局状态（原 backtrace.sx 全局 let；seed asm 不支持全局写）。 */
static int32_t g_sym_capture_mode = 0;
static int32_t g_sym_capture_result = 0;

/** 从 buf 读取第 i 帧地址。 */
void *backtrace_read_frame_addr_c(const uint8_t *buf, int32_t i) {
  void *p = NULL;
  const uint8_t *src;
  uint8_t *dst;
  size_t k;
  if (!buf || i < 0) {
    return NULL;
  }
  src = buf + (size_t)i * sizeof(void *);
  dst = (uint8_t *)&p;
  for (k = 0; k < sizeof(void *); k++) {
    dst[k] = src[k];
  }
  return p;
}

/** 将地址写入 buf 第 i 帧。 */
void backtrace_write_frame_addr_c(uint8_t *buf, int32_t i, void *addr) {
  uint8_t *dst;
  const uint8_t *src;
  size_t k;
  if (!buf || i < 0) {
    return;
  }
  dst = buf + (size_t)i * sizeof(void *);
  src = (const uint8_t *)&addr;
  for (k = 0; k < sizeof(void *); k++) {
    dst[k] = src[k];
  }
}

/** 单字节转两位小写十六进制。 */
static void backtrace_u8_hex2(uint8_t b, char *out) {
  uint8_t hi = (uint8_t)((b >> 4) & 0x0fu);
  uint8_t lo = (uint8_t)(b & 0x0fu);
  if (!out) {
    return;
  }
  out[0] = (char)(hi < 10 ? ('0' + hi) : ('a' + hi - 10));
  out[1] = (char)(lo < 10 ? ('0' + lo) : ('a' + lo - 10));
}

/** 复制符号名到 out（最多 name_cap-1 字节 + NUL）。 */
void backtrace_copy_sym_name_c(char *out, int32_t name_cap, const char *name) {
  int32_t n;
  if (!out || name_cap <= 0) {
    return;
  }
  if (!name) {
    out[0] = '\0';
    return;
  }
  n = (int32_t)strlen(name);
  if (n >= name_cap) {
    n = name_cap - 1;
  }
  if (n > 0) {
    memcpy(out, name, (size_t)n);
  }
  out[n] = '\0';
}

/** 十六进制回退（不计入成功帧数）。 */
void backtrace_format_hex_addr_c(char *out, int32_t cap, void *addr) {
  char tmp[18];
  uintptr_t v = (uintptr_t)addr;
  int32_t i;
  int32_t pos = 2;
  if (!out || cap <= 0) {
    return;
  }
  tmp[0] = '0';
  tmp[1] = 'x';
  for (i = 15; i >= 0; i--) {
    uint8_t nib = (uint8_t)((v >> (i * 4)) & 15u);
    backtrace_u8_hex2(nib, &tmp[pos]);
    pos += 2;
  }
  if (pos >= cap) {
    pos = cap - 1;
  }
  memcpy(out, tmp, (size_t)pos);
  out[pos] = '\0';
}

/** 检查符号名是否含 gold_anchor 子串。 */
int32_t backtrace_name_has_gold_anchor_c(const uint8_t *name) {
  if (!name) {
    return 0;
  }
  return strstr((const char *)name, "gold_anchor") != NULL ? 1 : 0;
}

#if (defined(__linux__) && defined(__GLIBC__)) || defined(__APPLE__)
#include <execinfo.h>
#define HAVE_EXECINFO 1
#endif

#if defined(__linux__) || defined(__APPLE__)
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

/**
 * 金样锚点：烟测模式下在栈内 capture。
 * noinline 保证栈帧可被 backtrace 捕获。
 */
int32_t backtrace_gold_anchor_smoke_enter_c(void);
#if defined(_MSC_VER)
__declspec(noinline)
#else
__attribute__((noinline))
#endif
void backtrace_gold_anchor_c(void);

int32_t backtrace_capture_c(uint8_t *buf, int32_t max_frames);
int32_t backtrace_symbolicate_c(const uint8_t *buf, int32_t len, uint8_t *out_ptrs, uint8_t *out_names,
                                int32_t max);
void *backtrace_gold_anchor_addr_c(void);

/**
 * 将当前调用栈捕获到 buf；每帧 sizeof(void*) 字节。
 * 返回值：捕获帧数；失败 0。
 */
int32_t backtrace_capture_c(uint8_t *buf, int32_t max_frames) {
  if (!buf || max_frames <= 0)
    return 0;
#if defined(HAVE_EXECINFO)
  {
    void *arr[256];
    int n = backtrace(arr, max_frames > 256 ? 256 : (int)max_frames);
    int i;
    if (n <= 0)
      return 0;
    for (i = 0; i < n; i++)
      backtrace_write_frame_addr_c(buf, i, arr[i]);
    return (int32_t)n;
  }
#elif defined(_WIN32) || defined(_WIN64)
  {
    void *arr[256];
    uint32_t n = CaptureStackBackTrace(0, (uint32_t)(max_frames > 256 ? 256 : max_frames), arr, NULL);
    uint32_t i;
    if (n == 0)
      return 0;
    for (i = 0; i < n; i++)
      backtrace_write_frame_addr_c(buf, (int32_t)i, arr[i]);
    return (int32_t)n;
  }
#else
  (void)buf;
  (void)max_frames;
  return 0;
#endif
}

/**
 * 将 capture 得到的 buf 符号化；返回成功解析符号的帧数。
 */
int32_t backtrace_symbolicate_c(const uint8_t *buf, int32_t len, uint8_t *out_ptrs, uint8_t *out_names,
                                int32_t max) {
  int32_t ok = 0;
  int32_t n;
  int32_t i;
  if (!buf || len <= 0 || !out_names || max <= 0)
    return 0;
  n = len < max ? len : max;
  for (i = 0; i < n; i++) {
    void *addr = backtrace_read_frame_addr_c(buf, i);
    char *name_slot = (char *)(out_names + (size_t)i * BACKTRACE_SYM_NAME_LEN);
    if (out_ptrs)
      backtrace_write_frame_addr_c(out_ptrs, i, addr);
#if defined(HAVE_DLADDR)
    {
      Dl_info info;
      memset(&info, 0, sizeof(info));
      if (dladdr(addr, &info) && info.dli_sname && info.dli_sname[0]) {
        backtrace_copy_sym_name_c(name_slot, BACKTRACE_SYM_NAME_LEN, info.dli_sname);
        ok++;
      } else {
        backtrace_format_hex_addr_c(name_slot, BACKTRACE_SYM_NAME_LEN, addr);
      }
    }
#elif defined(_WIN32) || defined(_WIN64)
    {
      static int sym_init = 0;
      char undec[BACKTRACE_SYM_NAME_LEN];
      DWORD64 disp = 0;
      SYMBOL_INFO_PACKAGE pkg;
      if (!sym_init) {
        SymSetOptions(SYMOPT_UNDNAME | SYMOPT_DEFERRED_LOADS);
        SymInitialize(GetCurrentProcess(), NULL, TRUE);
        sym_init = 1;
      }
      memset(&pkg, 0, sizeof(pkg));
      pkg.si.SizeOfStruct = sizeof(SYMBOL_INFO);
      pkg.si.MaxNameLen = MAX_SYM_NAME;
      if (SymFromAddr(GetCurrentProcess(), (DWORD64)(uintptr_t)addr, &disp, &pkg.si)) {
        if (UnDecorateSymbolName(pkg.si.Name, undec, (DWORD)sizeof(undec), UNDNAME_COMPLETE)) {
          backtrace_copy_sym_name_c(name_slot, BACKTRACE_SYM_NAME_LEN, undec);
        } else {
          backtrace_copy_sym_name_c(name_slot, BACKTRACE_SYM_NAME_LEN, pkg.si.Name);
        }
        ok++;
      } else {
        backtrace_format_hex_addr_c(name_slot, BACKTRACE_SYM_NAME_LEN, addr);
      }
    }
#else
    backtrace_format_hex_addr_c(name_slot, BACKTRACE_SYM_NAME_LEN, addr);
#endif
  }
  return ok;
}

/** .sx 导出：金样锚点函数地址（烟测 symbolicate 用）。 */
void *backtrace_gold_anchor_addr_c(void) {
  return (void *)&backtrace_gold_anchor_c;
}

/** 从当前栈 capture 并检查是否含 gold_anchor 符号。 */
static int32_t backtrace_capture_and_check_gold_c(void) {
  uint8_t buf[512];
  uint8_t names[1024];
  int32_t n;
  int32_t sym_n;
  int32_t i;
  n = backtrace_capture_c(buf, 8);
  if (n <= 0) {
    return 10;
  }
  sym_n = backtrace_symbolicate_c(buf, n, buf, names, n);
  if (sym_n <= 0) {
    return 11;
  }
  for (i = 0; i < n; i++) {
    const char *slot = (const char *)(names + (size_t)i * BACKTRACE_SYM_NAME_LEN);
    if (backtrace_name_has_gold_anchor_c((const uint8_t *)slot)) {
      return 0;
    }
  }
  return 12;
}

/** platform glue 金样锚点回调：烟测模式下在栈内 capture。 */
int32_t backtrace_gold_anchor_smoke_enter_c(void) {
  if (g_sym_capture_mode != 0) {
    g_sym_capture_result = backtrace_capture_and_check_gold_c();
    g_sym_capture_mode = 0;
  }
  return 0;
}

#if defined(_MSC_VER)
__declspec(noinline)
#else
__attribute__((noinline))
#endif
void backtrace_gold_anchor_c(void) {
  (void)backtrace_gold_anchor_smoke_enter_c();
}

/** STD-052 C 烟测：直接 symbolicate gold_anchor + capture 路径。 */
int32_t backtrace_symbolicate_smoke_c(void) {
  uint8_t buf[64];
  uint8_t names[128];
  g_sym_capture_result = 12;
  backtrace_write_frame_addr_c(buf, 0, backtrace_gold_anchor_addr_c());
  if (backtrace_symbolicate_c(buf, 1, buf, names, 1) <= 0) {
    return 1;
  }
  if (!backtrace_name_has_gold_anchor_c(names)) {
    return 2;
  }
  g_sym_capture_mode = 1;
  backtrace_gold_anchor_c();
  return g_sym_capture_result;
}

/** 返回当前宿主平台名（STD-147）。 */
const char *backtrace_xplat_platform_name_c(void) {
#if defined(__APPLE__)
  return "Darwin";
#elif defined(_WIN32) || defined(_WIN64)
  return "Windows";
#elif defined(__linux__)
  return "Linux";
#else
  return "Unknown";
#endif
}

/** 检查符号名是否含 gold_anchor。 */
static int32_t name_has_gold_anchor(const char *name) {
  return backtrace_name_has_gold_anchor_c((const uint8_t *)name);
}

/** STD-147 跨平台符号质量探测。 */
int32_t backtrace_xplat_quality_c(void) {
  const char *plat = backtrace_xplat_platform_name_c();
  uint8_t buf[512];
  uint8_t names[32 * BACKTRACE_SYM_NAME_LEN];
  int32_t gold = 0;
  int32_t resolved = 0;
  int32_t total = 0;

  backtrace_write_frame_addr_c(buf, 0, backtrace_gold_anchor_addr_c());
  if (backtrace_symbolicate_c(buf, 1, buf, names, 1) > 0) {
    if (name_has_gold_anchor((char *)names))
      gold = 1;
  }
  total = backtrace_capture_c(buf, 32);
  if (total > 0)
    resolved = backtrace_symbolicate_c(buf, total, buf, names, total);
  diag_reportf(NULL, 0, 0, "note", NULL,
               "backtrace xplat: platform=%s gold=%d resolved=%d total=%d",
               plat, gold, resolved, total);
  if (gold < 1 || resolved < 1 || total < 1)
    return 1;
  return 0;
}

/**
 * SAFE-007：SHUX_CRASH_EVIDENCE=1 时 capture 栈并 stderr/bundle 落盘。
 * 强符号覆盖 runtime_panic.c 内弱默认实现。
 */
void shux_crash_evidence_collect_c(int has_msg, int msg_val) {
  const char *en = getenv("SHUX_CRASH_EVIDENCE");
  uint8_t buf[512];
  int32_t n;
  int32_t pid = 0;
  if (!en || en[0] != '1')
    return;
  n = backtrace_capture_c(buf, 32);
#if defined(__unix__) || defined(__APPLE__)
  pid = (int32_t)getpid();
#elif defined(_WIN32) || defined(_WIN64)
  pid = (int32_t)GetCurrentProcessId();
#endif
  fprintf(stderr, "note: crash evidence: panic=%d msg=%d frames=%d pid=%d\n", has_msg, msg_val,
          n, pid);
  {
    const char *dir = getenv("SHUX_CRASH_EVIDENCE_DIR");
    if (dir && dir[0]) {
      char path[1024];
      FILE *f;
      int32_t i;
      (void)snprintf(path, sizeof(path), "%s/shux-crash-%d.txt", dir, pid);
      f = fopen(path, "w");
      if (f) {
        fprintf(f, "panic_has_msg=%d\npanic_msg=%d\nframes=%d\npid=%d\n", has_msg, msg_val, n, pid);
        for (i = 0; i < n; i++) {
          void *addr = backtrace_read_frame_addr_c(buf, i);
          fprintf(f, "frame%d=0x%zx\n", (int)i, (size_t)(uintptr_t)addr);
        }
        fclose(f);
        fprintf(stderr, "note: crash evidence: bundle=%s\n", path);
      }
    }
  }
}
