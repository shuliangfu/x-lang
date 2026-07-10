/* seeds/cfg_eval_bootstrap_stub.from_x.c — G-02f-80 product cold-start TU
 * Promoted from compiler/src/lexer/cfg_eval_bootstrap_stub.inc (stub/bridge; retired .inc).
 * Compile: cc -c / cc_inc_tu seeds/cfg_eval_bootstrap_stub.from_x.c
 */
/**
 * cfg_eval_bootstrap_stub.c — 冷启动 #[cfg] 求值（cfg_eval.x 尚不可编时链入）
 *
 * 旧桩恒返回 1，导致 Linux seed 仍解析 #[cfg(windows)] 项，std/net 等模块
 * body_ref 错位、asm emit 失败。本文件与 lexer.c B-01/B-02 语义对齐：
 * target_os / target_arch / all() / not()、-target triple 覆盖。
 * bootstrap 成功后 cfg_eval.x 真实现可替换本 TU。
 */
#include <stdint.h>
#include <string.h>

/** 返回当前 host 的 target_os 字面量。 */
static const char *cfg_host_os_lit(void) {
#if defined(__APPLE__)
  return "macos";
#elif defined(_WIN32) || defined(__CYGWIN__) || defined(__MINGW32__) || defined(__MSYS__)
  return "windows";
#elif defined(__linux__)
  return "linux";
#elif defined(__FreeBSD__)
  return "freebsd";
#else
  return "unknown";
#endif
}

/** 返回当前 host 的 target_arch 字面量。 */
static const char *cfg_host_arch_lit(void) {
#if defined(__aarch64__) || defined(_M_ARM64)
  return "aarch64";
#elif defined(__x86_64__) || defined(_M_X64) || defined(__amd64__)
  return "x86_64";
#elif defined(__riscv) && __riscv_xlen == 64
  return "riscv64";
#else
  return "unknown";
#endif
}

/** `-target` triple 覆盖；未设置时 #[cfg] 用 host。 */
static char g_cfg_os_override[32];
static char g_cfg_arch_override[32];
static int g_cfg_has_target_override;

/**
 * `-freestanding` 模式标志（与 cfg_eval.x g_cfg_freestanding 对齐）。
 * runtime.c 解析 `-freestanding` 时调用 cfg_set_freestanding(1)。
 * co-emit 模式下用 #[cfg(not(freestanding))] 剪枝 hosted-only 函数。
 */
static int g_cfg_freestanding;

/** triple 子串忽略大小写匹配。 */
static int cfg_triple_contains_ci(const char *triple, int len, const char *needle) {
  size_t nlen;
  int i;
  if (!triple || len <= 0 || !needle)
    return 0;
  nlen = strlen(needle);
  if (nlen == 0 || (size_t)len < nlen)
    return 0;
  for (i = 0; i + (int)nlen <= len; i++) {
    int j;
    int ok = 1;
    for (j = 0; j < (int)nlen; j++) {
      unsigned char a = (unsigned char)triple[i + j];
      unsigned char b = (unsigned char)needle[j];
      if (a >= 'A' && a <= 'Z')
        a = (unsigned char)(a + 32);
      if (b >= 'A' && b <= 'Z')
        b = (unsigned char)(b + 32);
      if (a != b) {
        ok = 0;
        break;
      }
    }
    if (ok)
      return 1;
  }
  return 0;
}

/** 从 `-target` triple 解析 os/arch；失败回退 host。 */
static void cfg_parse_triple_literals(const char *triple, int len, char *os_out, size_t os_sz, char *arch_out,
                                      size_t arch_sz) {
  const char *host_os;
  const char *host_arch;
  if (!os_out || os_sz == 0 || !arch_out || arch_sz == 0)
    return;
  host_os = cfg_host_os_lit();
  host_arch = cfg_host_arch_lit();
  strncpy(os_out, host_os, os_sz - 1);
  os_out[os_sz - 1] = '\0';
  strncpy(arch_out, host_arch, arch_sz - 1);
  arch_out[arch_sz - 1] = '\0';
  if (!triple || len <= 0)
    return;
  if (cfg_triple_contains_ci(triple, len, "linux"))
    strncpy(os_out, "linux", os_sz - 1);
  else if (cfg_triple_contains_ci(triple, len, "darwin") || cfg_triple_contains_ci(triple, len, "macos"))
    strncpy(os_out, "macos", os_sz - 1);
  else if (cfg_triple_contains_ci(triple, len, "freebsd"))
    strncpy(os_out, "freebsd", os_sz - 1);
  else if (cfg_triple_contains_ci(triple, len, "windows") || cfg_triple_contains_ci(triple, len, "win32"))
    strncpy(os_out, "windows", os_sz - 1);
  os_out[os_sz - 1] = '\0';
  if (cfg_triple_contains_ci(triple, len, "aarch64") || cfg_triple_contains_ci(triple, len, "arm64"))
    strncpy(arch_out, "aarch64", arch_sz - 1);
  else if (cfg_triple_contains_ci(triple, len, "x86_64") || cfg_triple_contains_ci(triple, len, "amd64"))
    strncpy(arch_out, "x86_64", arch_sz - 1);
  else if (cfg_triple_contains_ci(triple, len, "riscv64"))
    strncpy(arch_out, "riscv64", arch_sz - 1);
  arch_out[arch_sz - 1] = '\0';
}

/** effective target_os（triple 覆盖或 host）。 */
static const char *cfg_effective_os_lit(void) {
  if (g_cfg_has_target_override && g_cfg_os_override[0])
    return g_cfg_os_override;
  return cfg_host_os_lit();
}

/** effective target_arch（triple 覆盖或 host）。 */
static const char *cfg_effective_arch_lit(void) {
  if (g_cfg_has_target_override && g_cfg_arch_override[0])
    return g_cfg_arch_override;
  return cfg_host_arch_lit();
}

/** 忽略大小写比较 [a, a+alen) 与 C 字符串 b。 */
static int cfg_lit_eq_ci(const char *a, size_t alen, const char *b) {
  size_t blen;
  size_t i;
  if (!a || !b)
    return 0;
  blen = strlen(b);
  if (alen != blen)
    return 0;
  for (i = 0; i < alen; i++) {
    unsigned char ca = (unsigned char)a[i];
    unsigned char cb = (unsigned char)b[i];
    if (ca >= 'A' && ca <= 'Z')
      ca = (unsigned char)(ca + 32);
    if (cb >= 'A' && cb <= 'Z')
      cb = (unsigned char)(cb + 32);
    if (ca != cb)
      return 0;
  }
  return 1;
}

/** 递归求值 cfg 表达式；end 不含。 */
static int cfg_eval_expr(const char *start, const char *end) {
  const char *p = start;

  while (p < end && (*p == ' ' || *p == '\t' || *p == '\n' || *p == '\r'))
    p++;
  if (p >= end)
    return 0;
  if ((size_t)(end - p) >= 4 && strncmp(p, "all(", 4) == 0) {
    p += 4;
    while (p < end) {
      const char *part;
      int depth;
      while (p < end && (*p == ' ' || *p == '\t' || *p == ',' || *p == '\n' || *p == '\r'))
        p++;
      if (p >= end)
        break;
      if (*p == ')')
        return 1;
      part = p;
      depth = 0;
      while (p < end) {
        if (*p == '(')
          depth++;
        else if (*p == ')') {
          if (depth == 0)
            break;
          depth--;
        } else if (*p == ',' && depth == 0)
          break;
        p++;
      }
      if (!cfg_eval_expr(part, p))
        return 0;
      if (p < end && *p == ')')
        return 1;
    }
    return 1;
  }
  if ((size_t)(end - p) >= 4 && strncmp(p, "not(", 4) == 0) {
    const char *inner;
    const char *close;
    int depth;

    inner = p + 4;
    depth = 1;
    close = inner;
    while (close < end && depth > 0) {
      if (*close == '(')
        depth++;
      else if (*close == ')')
        depth--;
      if (depth > 0)
        close++;
    }
    return !cfg_eval_expr(inner, close);
  }
  if ((size_t)(end - p) >= 9 && strncmp(p, "target_os", 9) == 0) {
    const char *lit;
    p += 9;
    while (p < end && (*p == ' ' || *p == '\t'))
      p++;
    if (p >= end || *p != '=')
      return 0;
    p++;
    if (p < end && *p == '=')
      p++; /* 接受 target_os == "linux" 与 target_os = "linux" */
    while (p < end && (*p == ' ' || *p == '\t'))
      p++;
    if (p >= end || *p != '"')
      return 0;
    p++;
    lit = p;
    while (p < end && *p != '"')
      p++;
    return cfg_lit_eq_ci(lit, (size_t)(p - lit), cfg_effective_os_lit());
  }
  if ((size_t)(end - p) >= 11 && strncmp(p, "target_arch", 11) == 0) {
    const char *lit;
    p += 11;
    while (p < end && (*p == ' ' || *p == '\t'))
      p++;
    if (p >= end || *p != '=')
      return 0;
    p++;
    if (p < end && *p == '=')
      p++; /* 接受 == */
    if (p >= end || *p != '"')
      return 0;
    p++;
    lit = p;
    while (p < end && *p != '"')
      p++;
    return cfg_lit_eq_ci(lit, (size_t)(p - lit), cfg_effective_arch_lit());
  }
  /* freestanding 裸标志：#[cfg(freestanding)] / #[cfg(not(freestanding))]。
   * 扫描标识符字符后与 "freestanding" 比较，返回 g_cfg_freestanding。 */
  {
    const char *q = p;
    while (q < end) {
      char c = *q;
      if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '_')
        q++;
      else
        break;
    }
    if (cfg_lit_eq_ci(p, (size_t)(q - p), "freestanding"))
      return g_cfg_freestanding;
  }
  return 0;
}

/** #[cfg(...)] 表达式求值；1=保留，0=剪枝。 */
int cfg_eval_expr_c(const char *start, int len) {
  if (!start || len <= 0)
    return 0;
  return cfg_eval_expr(start, start + len) ? 1 : 0;
}

/** 应用 `-target` triple，后续 #[cfg] 按 cross 目标剪枝。 */
void cfg_apply_compile_target_from_triple(const char *triple, int len) {
  cfg_parse_triple_literals(triple, len, g_cfg_os_override, sizeof g_cfg_os_override, g_cfg_arch_override,
                            sizeof g_cfg_arch_override);
  g_cfg_has_target_override = 1;
}

/** 清除 triple 覆盖，#[cfg] 回退 host。 */
void cfg_reset_compile_target(void) {
  g_cfg_has_target_override = 0;
  g_cfg_os_override[0] = '\0';
  g_cfg_arch_override[0] = '\0';
}

/** 设置 freestanding 模式标志（runtime.c 解析 `-freestanding` 时调用）。 */
void cfg_set_freestanding(int v) {
  g_cfg_freestanding = v;
}
