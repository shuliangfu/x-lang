/* seeds/target_cpu_pure.from_x.c — G-02f-2/3/4/5 product pure half of target_cpu.o
 * G-02f-132 true .x pure helpers.
 * G-02f-131 true .x pure helpers.
 * G-02f-111 helper gates.
 * G-02f-110 helper gates.
 * G-02f-103 helper gates.
 * G-02f-97 pure helper gates.
 * G-02f-257：SHUX_L2_TARGET_CPU_FLAGS_FROM_X 时省略所有 .x 业务函数
 *           （由 src/driver/target_cpu_pure.x → .o 提供，再 ld -r）。
 *
 * Source of truth: src/driver/target_cpu_pure.x (+ print is stdio C co-located; f-5)
 * Hand-synced when full shux-c -E hangs on multi-helper TUs.
 * Product default: single TU → src/driver/target_cpu.o (no ld -r).
 *
 * R2 full（2026-07-20）：公共业务符号由 full .x 提供（12 函数 + BSS）：
 *   driver_set_pending + driver_get_pending + tcp_tolower + tcp_eq_at + tcp_set_u32
 *   + tcp_parse_named + shu_target_cpu_resolve + tcp_eq5 + tcp_eq6
 *   + shu_simd_is_vector_type_spelling + shu_simd_vector_lanes_esz_from_spelling
 *   + append_feat_name + flags_has_token
 * Cap residual（mega rest 冷路径）：shu_target_cpu_print (FILE/fprintf) +
 *   OS detect (sysctl/proc/#if platform) 在本文件 #endif 后始终编译。
 * FROM_X 下本文件业务 H=0（仅 extern 声明 + slice marker）。
 * 冷启动/无 PREFER 时仍编译完整 C 体（可与 mega 并存）。
 *
 * Prove：seeds/target_cpu_pure_surface.from_x.c（-E 同构）nm IDENTICAL。
 *
 * Exports: pending, resolve, simd spelling, print.
 * G-02f-6: also embeds OS detect_host / generic_for_host (#if/sysctl/proc).
 * G-02f-174: host detect 🔒 language-limit seed (sysctl/proc/#if); not true-.x.
 */
#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include "target_cpu.h"

#ifndef SHUX_L2_TARGET_CPU_FLAGS_FROM_X
/* Cold start: full C bodies for all .x business funcs */
static uint32_t g_driver_pending_target_cpu_features;

void driver_set_pending_target_cpu_features(uint32_t features) {
  g_driver_pending_target_cpu_features = features;
}

uint32_t driver_get_pending_target_cpu_features(void) {
  return g_driver_pending_target_cpu_features;
}

/* G-02f-131：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
uint8_t tcp_tolower(uint8_t c) {
  if (c >= 65 && c <= 90)
    return (uint8_t)(c + 32);
  return c;
}

/** Compare name[base..base+n) case-insensitively to lowercase lit[0..n). */
/* G-02f-131：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
int32_t tcp_eq_at(const uint8_t *name, size_t base, size_t n, const uint8_t *lit) {
  size_t i;
  for (i = 0; i < n; i++) {
    if (tcp_tolower(name[base + i]) != lit[i])
      return 0;
  }
  return 1;
}

/* tcp_set_u32: simple *out = f; kept for .x symbol parity (cold start inlines). */
void tcp_set_u32(uint32_t *out, uint32_t f) {
  *out = f;
}

/* G-02f-160：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
int32_t tcp_parse_named(const uint8_t *spec, size_t base, size_t end, uint32_t *out) {
  size_t n;
  if (!out || end < base)
    return -1;
  n = end - base;
  if (n == 6 && tcp_eq_at(spec, base, 6, (const uint8_t *)"native") != 0) {
    *out = shu_target_cpu_detect_host();
    return 0;
  }
  if (n == 7 && tcp_eq_at(spec, base, 7, (const uint8_t *)"generic") != 0) {
    *out = shu_target_cpu_generic_for_host();
    return 0;
  }
  if (n == 4 && tcp_eq_at(spec, base, 4, (const uint8_t *)"sse2") != 0) {
    *out = 1u; /* SSE2 */
    return 0;
  }
  if (n == 6 && (tcp_eq_at(spec, base, 6, (const uint8_t *)"sse4.1") != 0 ||
                 tcp_eq_at(spec, base, 6, (const uint8_t *)"sse4_1") != 0)) {
    *out = 1u | 2u;
    return 0;
  }
  if (n == 3 && tcp_eq_at(spec, base, 3, (const uint8_t *)"avx") != 0) {
    *out = 1u | 2u | 4u;
    return 0;
  }
  if (n == 4 && tcp_eq_at(spec, base, 4, (const uint8_t *)"avx2") != 0) {
    *out = 1u | 2u | 4u | 8u;
    return 0;
  }
  if (n == 6 && tcp_eq_at(spec, base, 6, (const uint8_t *)"avx512") != 0) {
    *out = 1u | 2u | 4u | 8u | 16u;
    return 0;
  }
  if (n == 7 && tcp_eq_at(spec, base, 7, (const uint8_t *)"avx512f") != 0) {
    *out = 1u | 2u | 4u | 8u | 16u;
    return 0;
  }
  if (n == 9 && tcp_eq_at(spec, base, 9, (const uint8_t *)"x86-64-v2") != 0) {
    *out = 1u | 2u | 32u;
    return 0;
  }
  if (n == 9 && tcp_eq_at(spec, base, 9, (const uint8_t *)"x86-64-v3") != 0) {
    *out = 1u | 2u | 4u | 8u | 32u | 64u;
    return 0;
  }
  if (n == 9 && tcp_eq_at(spec, base, 9, (const uint8_t *)"x86-64-v4") != 0) {
    *out = 1u | 2u | 4u | 8u | 16u | 32u | 64u;
    return 0;
  }
  if (n == 4 && tcp_eq_at(spec, base, 4, (const uint8_t *)"neon") != 0) {
    *out = 256u;
    return 0;
  }
  if (n == 3 && tcp_eq_at(spec, base, 3, (const uint8_t *)"sve") != 0) {
    *out = 256u | 512u;
    return 0;
  }
  if (n == 3 && tcp_eq_at(spec, base, 3, (const uint8_t *)"rvv") != 0) {
    *out = 65536u;
    return 0;
  }
  return -1;
}

int shu_target_cpu_resolve(const char *spec, size_t spec_len, uint32_t *out) {
  const uint8_t *s = (const uint8_t *)spec;
  size_t start = 0;
  size_t end;
  if (!out)
    return -1;
  if (!spec || spec_len == 0) {
    *out = shu_target_cpu_detect_host();
    return 0;
  }
  end = spec_len;
  while (start < end && (s[start] == ' ' || s[start] == '\t'))
    start++;
  while (end > start && (s[end - 1] == ' ' || s[end - 1] == '\t'))
    end--;
  if (end <= start) {
    *out = shu_target_cpu_detect_host();
    return 0;
  }
  return tcp_parse_named(s, start, end, out);
}

/* G-02f-132：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
int32_t tcp_eq5(const uint8_t *name, uint8_t a0, uint8_t a1, uint8_t a2, uint8_t a3, uint8_t a4) {
  uint8_t lit[5];
  lit[0] = a0;
  lit[1] = a1;
  lit[2] = a2;
  lit[3] = a3;
  lit[4] = a4;
  return tcp_eq_at(name, 0, 5, lit);
}

/* G-02f-132：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
int32_t tcp_eq6(const uint8_t *name, uint8_t a0, uint8_t a1, uint8_t a2, uint8_t a3, uint8_t a4,
                       uint8_t a5) {
  uint8_t lit[6];
  lit[0] = a0;
  lit[1] = a1;
  lit[2] = a2;
  lit[3] = a3;
  lit[4] = a4;
  lit[5] = a5;
  return tcp_eq_at(name, 0, 6, lit);
}

int shu_simd_is_vector_type_spelling(const char *name, size_t name_len) {
  const uint8_t *n = (const uint8_t *)name;
  if (!name || name_len == 0)
    return 0;
  if (name_len == 5) {
    if (tcp_eq5(n, 105, 51, 50, 120, 52) != 0)
      return 1;
    if (tcp_eq5(n, 105, 51, 50, 120, 56) != 0)
      return 1;
    if (tcp_eq5(n, 117, 51, 50, 120, 52) != 0)
      return 1;
    if (tcp_eq5(n, 117, 51, 50, 120, 56) != 0)
      return 1;
    if (tcp_eq5(n, 102, 51, 50, 120, 52) != 0)
      return 1;
    if (tcp_eq5(n, 118, 101, 99, 52, 102) != 0)
      return 1;
    if (tcp_eq5(n, 118, 101, 99, 56, 105) != 0)
      return 1;
  }
  if (name_len == 6) {
    if (tcp_eq6(n, 105, 51, 50, 120, 49, 54) != 0)
      return 1;
    if (tcp_eq6(n, 117, 51, 50, 120, 49, 54) != 0)
      return 1;
  }
  return 0;
}

int shu_simd_vector_lanes_esz_from_spelling(const char *name, size_t name_len, int32_t *out_lanes,
                                            int32_t *out_esz) {
  const uint8_t *n = (const uint8_t *)name;
  int32_t lanes = 4;
  int32_t esz = 4;
  if (!out_lanes || !out_esz)
    return -1;
  if (!shu_simd_is_vector_type_spelling(name, name_len))
    return -1;
  if (name_len == 5 && name[4] == '8')
    lanes = 8;
  if (name_len == 6 && name[4] == '1' && name[5] == '6')
    lanes = 16;
  if (name_len == 5 && tcp_eq5(n, 118, 101, 99, 56, 105) != 0)
    lanes = 8;
  *out_lanes = lanes;
  *out_esz = esz;
  return 0;
}

/* G-02f-160：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
void append_feat_name(char *buf, size_t cap, size_t *pos, const char *name) {
  size_t nlen;
  if (!buf || !pos || !name || *pos >= cap)
    return;
  if (*pos > 0 && *pos + 1 < cap)
    buf[(*pos)++] = ',';
  nlen = strlen(name);
  if (*pos + nlen >= cap)
    return;
  memcpy(buf + *pos, name, nlen);
  *pos += nlen;
  buf[*pos] = '\0';
}

/**
 * 在 flags 行（x86）或 Features 行（arm）中查找 token（前后空白/逗号分隔）。
 * Linux /proc/cpuinfo 解析使用；pure 字符串匹配，全平台提供。
 */
/* G-02f-160：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
int flags_has_token(const char *hay, const char *token) {
    const char *p;
    size_t tlen;

    if (!hay || !token)
        return 0;
    tlen = strlen(token);
    for (p = hay; (p = strstr(p, token)) != NULL; p++) {
        char before = (p > hay) ? p[-1] : ' ';
        char after = p[tlen];
        if ((before == ' ' || before == '\t' || before == ',' || p == hay) &&
            (after == ' ' || after == '\t' || after == ',' || after == '\0' || after == '\n'))
            return 1;
        p += tlen > 0 ? tlen - 1 : 0;
    }
    return 0;
}

#else
/* FROM_X: .x provides all business funcs; rest TU only has language-limit residual */
extern void driver_set_pending_target_cpu_features(uint32_t features);
extern uint32_t driver_get_pending_target_cpu_features(void);
extern uint8_t tcp_tolower(uint8_t c);
extern int32_t tcp_eq_at(const uint8_t *name, size_t base, size_t n, const uint8_t *lit);
extern void tcp_set_u32(uint32_t *out, uint32_t f);
extern int32_t tcp_parse_named(const uint8_t *spec, size_t base, size_t end, uint32_t *out);
extern int shu_target_cpu_resolve(const char *spec, size_t spec_len, uint32_t *out);
extern int32_t tcp_eq5(const uint8_t *name, uint8_t a0, uint8_t a1, uint8_t a2, uint8_t a3, uint8_t a4);
extern int32_t tcp_eq6(const uint8_t *name, uint8_t a0, uint8_t a1, uint8_t a2, uint8_t a3, uint8_t a4,
                       uint8_t a5);
extern int shu_simd_is_vector_type_spelling(const char *name, size_t name_len);
extern int shu_simd_vector_lanes_esz_from_spelling(const char *name, size_t name_len, int32_t *out_lanes,
                                                    int32_t *out_esz);
extern void append_feat_name(char *buf, size_t cap, size_t *pos, const char *name);
extern int flags_has_token(const char *hay, const char *token);
#endif

/* slice_marker: indicates business funcs are provided by .x (R2 full) */
int target_cpu_pure_slice_marker(void) {
  return 1;
}

/* --- Cap residual: language-limit funcs (always compiled) --- */

/* --- G-02f-5：print（stdio / FILE* 语言限制，逻辑与原 target_cpu.inc 一致）--- */

void shu_target_cpu_print(FILE *out, uint32_t features) {
  char list[256];
  size_t pos = 0;

  if (!out)
    return;
  list[0] = '\0';
  if (features & 1u) /* SSE2 */
    append_feat_name(list, sizeof(list), &pos, "sse2");
  if (features & 2u) /* SSE41 */
    append_feat_name(list, sizeof(list), &pos, "sse4.1");
  if (features & 4u) /* AVX */
    append_feat_name(list, sizeof(list), &pos, "avx");
  if (features & 8u) /* AVX2 */
    append_feat_name(list, sizeof(list), &pos, "avx2");
  if (features & 16u) /* AVX512F */
    append_feat_name(list, sizeof(list), &pos, "avx512f");
  if (features & 32u) /* POPCNT */
    append_feat_name(list, sizeof(list), &pos, "popcnt");
  if (features & 64u) /* BMI2 */
    append_feat_name(list, sizeof(list), &pos, "bmi2");
  if (features & 256u) /* NEON */
    append_feat_name(list, sizeof(list), &pos, "neon");
  if (features & 512u) /* SVE */
    append_feat_name(list, sizeof(list), &pos, "sve");
  if (features & 65536u) /* RVV */
    append_feat_name(list, sizeof(list), &pos, "rvv");
  fprintf(out, "target_cpu_features=0x%08x\n", features);
  fprintf(out, "target_cpu_features_list=%s\n", list[0] ? list : "(none)");
  fprintf(out, "target_cpu_host_features=0x%08x\n", shu_target_cpu_detect_host());
}

/* --- G-02f-6：OS detect（原 target_cpu.inc 语言限制 #if / sysctl /proc）--- */
#include "target_cpu.h"
#if defined(__linux__)
/* PLATFORM: SHARED — include/unistd.h shim provides POSIX wrappers on MinGW
 *            (read/write/close/lseek/open/pread/pwrite/setenv/unsetenv).
 *            macOS/Linux delegate to system <unistd.h> via #include_next.
 *            Historical #ifndef _WIN32 guard removed — shim is a no-op
 *            on POSIX and provides needed declarations on Windows. */
#include <unistd.h>
#endif
#if defined(__APPLE__)
#include <sys/sysctl.h>
#include <sys/types.h>
#endif

#if defined(__x86_64__) || defined(_M_X64) || defined(__i386__) || defined(_M_IX86)

/**
 * 编译期宏兜底（交叉编译或无 /proc/cpuinfo 时仍给出合理缺省）。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
uint32_t shu_target_cpu_detect_x86_macro_fallback(void) {
    uint32_t f = SHUX_CPU_FEAT_SSE2;
#if defined(__SSE4_1__)
    f |= SHUX_CPU_FEAT_SSE41;
#endif
#if defined(__AVX__)
    f |= SHUX_CPU_FEAT_AVX;
#endif
#if defined(__AVX2__)
    f |= SHUX_CPU_FEAT_AVX2;
#endif
#if defined(__AVX512F__)
    f |= SHUX_CPU_FEAT_AVX512F;
#endif
#if defined(__POPCNT__)
    f |= SHUX_CPU_FEAT_POPCNT;
#endif
#if defined(__BMI2__)
    f |= SHUX_CPU_FEAT_BMI2;
#endif
#if defined(__FMA__)
    f |= SHUX_CPU_FEAT_FMA;
#endif
    return f;
}
#if defined(__linux__)
/**
 * Linux x86：解析 /proc/cpuinfo 首条 flags 行。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
uint32_t shu_target_cpu_detect_x86_linux(void) {
    FILE *fp;
    char line[512];
    uint32_t f = 0;

    fp = fopen("/proc/cpuinfo", "r");
    if (!fp)
        return shu_target_cpu_detect_x86_macro_fallback();
    while (fgets(line, (int)sizeof(line), fp)) {
        if (strncmp(line, "flags", 5) != 0)
            continue;
        if (flags_has_token(line, "sse2"))
            f |= SHUX_CPU_FEAT_SSE2;
        if (flags_has_token(line, "sse4_1"))
            f |= SHUX_CPU_FEAT_SSE41;
        if (flags_has_token(line, "avx"))
            f |= SHUX_CPU_FEAT_AVX;
        if (flags_has_token(line, "avx2"))
            f |= SHUX_CPU_FEAT_AVX2;
        if (flags_has_token(line, "avx512f"))
            f |= SHUX_CPU_FEAT_AVX512F;
        if (flags_has_token(line, "popcnt"))
            f |= SHUX_CPU_FEAT_POPCNT;
        if (flags_has_token(line, "bmi2"))
            f |= SHUX_CPU_FEAT_BMI2;
        if (flags_has_token(line, "fma"))
            f |= SHUX_CPU_FEAT_FMA;
        break;
    }
    fclose(fp);
    if (f == 0)
        f = shu_target_cpu_detect_x86_macro_fallback();
    return f;
}
#endif

#if defined(__APPLE__)
/** macOS x86：sysctl machdep.cpu.leaf7_features / machdep.cpu.feature_bits。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
uint32_t shu_target_cpu_detect_x86_macos(void) {
    uint64_t leaf7 = 0;
    uint64_t feat = 0;
    size_t sz;
    uint32_t f = SHUX_CPU_FEAT_SSE2 | SHUX_CPU_FEAT_SSE41;

    sz = sizeof(leaf7);
    if (sysctlbyname("machdep.cpu.leaf7_features", &leaf7, &sz, NULL, 0) == 0) {
        if (leaf7 & (1ULL << 5))
            f |= SHUX_CPU_FEAT_AVX2;
        if (leaf7 & (1ULL << 16))
            f |= SHUX_CPU_FEAT_AVX512F;
        if (leaf7 & (1ULL << 8))
            f |= SHUX_CPU_FEAT_BMI2;
        if (leaf7 & (1ULL << 12))
            f |= SHUX_CPU_FEAT_FMA;
    }
    sz = sizeof(feat);
    if (sysctlbyname("machdep.cpu.feature_bits", &feat, &sz, NULL, 0) == 0) {
        if (feat & (1ULL << 28))
            f |= SHUX_CPU_FEAT_AVX;
        if (feat & (1ULL << 14))
            f |= SHUX_CPU_FEAT_POPCNT;
    }
    if (f == 0)
        f = shu_target_cpu_detect_x86_macro_fallback();
    return f;
}
#endif
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */

uint32_t shu_target_cpu_detect_x86(void) {
#if defined(__linux__)
    return shu_target_cpu_detect_x86_linux();
#elif defined(__APPLE__)
    return shu_target_cpu_detect_x86_macos();
#else
    return shu_target_cpu_detect_x86_macro_fallback();
#endif
}
#endif /* x86 */

#if defined(__aarch64__) || defined(_M_ARM64)

#if defined(__linux__)
/**
 * Linux arm64：/proc/cpuinfo Features 行（asimd=NEON，sve=SVE）。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
uint32_t shu_target_cpu_detect_arm64_linux(void) {
    FILE *fp;
    char line[512];
    uint32_t f = SHUX_CPU_FEAT_NEON;

    fp = fopen("/proc/cpuinfo", "r");
    if (!fp)
        return f;
    while (fgets(line, (int)sizeof(line), fp)) {
        if (strncmp(line, "Features", 8) != 0)
            continue;
        if (flags_has_token(line, "asimd") || flags_has_token(line, "neon"))
            f |= SHUX_CPU_FEAT_NEON;
        if (flags_has_token(line, "sve"))
            f |= SHUX_CPU_FEAT_SVE;
        break;
    }
    fclose(fp);
    return f;
}
#endif

#if defined(__APPLE__)
/** macOS arm64：NEON 为 mandatory；SVE 通过 hw.optional.arm.FEAT_SVE 探测。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
uint32_t shu_target_cpu_detect_arm64_macos(void) {
    uint32_t f = SHUX_CPU_FEAT_NEON;
    int sve = 0;
    size_t sz = sizeof(sve);

    if (sysctlbyname("hw.optional.arm.FEAT_SVE", &sve, &sz, NULL, 0) == 0 && sve)
        f |= SHUX_CPU_FEAT_SVE;
    return f;
}
#endif
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */

uint32_t shu_target_cpu_detect_arm64(void) {
#if defined(__linux__)
    return shu_target_cpu_detect_arm64_linux();
#elif defined(__APPLE__)
    return shu_target_cpu_detect_arm64_macos();
#else
    return SHUX_CPU_FEAT_NEON;
#endif
}
#endif /* arm64 */

#if defined(__riscv) && __riscv_xlen == 64

#if defined(__linux__)
/** Linux riscv64：isa 行含 'v' 时认为有 RVV。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
uint32_t shu_target_cpu_detect_riscv64_linux(void) {
    FILE *fp;
    char line[256];
    uint32_t f = 0;

    fp = fopen("/proc/cpuinfo", "r");
    if (!fp)
        return 0;
    while (fgets(line, (int)sizeof(line), fp)) {
        const char *isa;
        if (strncmp(line, "isa", 3) != 0)
            continue;
        isa = strchr(line, ':');
        if (!isa)
            break;
        isa++;
        while (*isa == ' ' || *isa == '\t')
            isa++;
        if (strchr(isa, 'v') != NULL)
            f |= SHUX_CPU_FEAT_RVV;
        break;
    }
    fclose(fp);
    return f;
}
#endif
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */

uint32_t shu_target_cpu_detect_riscv64(void) {
#if defined(__linux__)
    return shu_target_cpu_detect_riscv64_linux();
#else
    return 0;
#endif
}
#endif /* riscv64 */

uint32_t shu_target_cpu_detect_host(void) {
#if defined(__x86_64__) || defined(_M_X64) || defined(__i386__) || defined(_M_IX86)
    return shu_target_cpu_detect_x86();
#elif defined(__aarch64__) || defined(_M_ARM64)
    return shu_target_cpu_detect_arm64();
#elif defined(__riscv) && __riscv_xlen == 64
    return shu_target_cpu_detect_riscv64();
#else
    return 0;
#endif
}

uint32_t shu_target_cpu_generic_for_host(void) {
#if defined(__x86_64__) || defined(_M_X64) || defined(__i386__) || defined(_M_IX86)
    return SHUX_CPU_FEAT_SSE2;
#elif defined(__aarch64__) || defined(_M_ARM64)
    return SHUX_CPU_FEAT_NEON;
#else
    return 0;
#endif
}
