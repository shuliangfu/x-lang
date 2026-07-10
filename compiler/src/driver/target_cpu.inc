/**
 * target_cpu.inc — SIMD-S1：宿主机 CPU feature 探测与 `-target-cpu` 规格解析。
 *
 * G-02f-2/3/4：pending + SIMD 拼写 + resolve 已迁 `target_cpu_pure.x`
 *（产品链 ld -r pure + 本 TU → target_cpu.o；本 TU 仅 detect/generic/print）。
 *
 * Linux：读 /proc/cpuinfo flags/Features；
 * macOS：sysctl hw.optional.* / machdep.cpu.leaf7_features；
 * 兜底：编译器预定义宏（__AVX2__、__ARM_NEON 等）。
 */
#include "target_cpu.h"

#include <stdbool.h>
#include <stdio.h>
#include <string.h>

#if defined(__linux__)
#ifndef _WIN32
#include <unistd.h>
#endif
#endif

#if defined(__APPLE__)
#include <sys/sysctl.h>
#include <sys/types.h>
#endif

/**
 * 在 flags 行（x86）或 Features 行（arm）中查找 token（前后空白/逗号分隔）。
 * 仅 Linux /proc/cpuinfo 解析使用。
 */
#if defined(__linux__)
static int flags_has_token(const char *hay, const char *token) {
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
#endif /* __linux__ */

#if defined(__x86_64__) || defined(_M_X64) || defined(__i386__) || defined(_M_IX86)

/**
 * 编译期宏兜底（交叉编译或无 /proc/cpuinfo 时仍给出合理缺省）。
 */
static uint32_t shu_target_cpu_detect_x86_macro_fallback(void) {
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
static uint32_t shu_target_cpu_detect_x86_linux(void) {
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
/**
 * macOS x86：sysctl machdep.cpu.leaf7_features / machdep.cpu.feature_bits。
 */
static uint32_t shu_target_cpu_detect_x86_macos(void) {
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

static uint32_t shu_target_cpu_detect_x86(void) {
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
static uint32_t shu_target_cpu_detect_arm64_linux(void) {
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
static uint32_t shu_target_cpu_detect_arm64_macos(void) {
    uint32_t f = SHUX_CPU_FEAT_NEON;
    int sve = 0;
    size_t sz = sizeof(sve);

    if (sysctlbyname("hw.optional.arm.FEAT_SVE", &sve, &sz, NULL, 0) == 0 && sve)
        f |= SHUX_CPU_FEAT_SVE;
    return f;
}
#endif

static uint32_t shu_target_cpu_detect_arm64(void) {
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
static uint32_t shu_target_cpu_detect_riscv64_linux(void) {
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

static uint32_t shu_target_cpu_detect_riscv64(void) {
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

/* G-02f-4：shu_target_cpu_resolve / parse_named 已迁 target_cpu_pure。 */

/**
 * 追加单个 feature 名到 buf（逗号分隔）。
 */
static void append_feat_name(char *buf, size_t cap, size_t *pos, const char *name) {
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

void shu_target_cpu_print(FILE *out, uint32_t features) {
    char list[256];
    size_t pos = 0;

    if (!out)
        return;
    list[0] = '\0';
    if (features & SHUX_CPU_FEAT_SSE2)
        append_feat_name(list, sizeof(list), &pos, "sse2");
    if (features & SHUX_CPU_FEAT_SSE41)
        append_feat_name(list, sizeof(list), &pos, "sse4.1");
    if (features & SHUX_CPU_FEAT_AVX)
        append_feat_name(list, sizeof(list), &pos, "avx");
    if (features & SHUX_CPU_FEAT_AVX2)
        append_feat_name(list, sizeof(list), &pos, "avx2");
    if (features & SHUX_CPU_FEAT_AVX512F)
        append_feat_name(list, sizeof(list), &pos, "avx512f");
    if (features & SHUX_CPU_FEAT_POPCNT)
        append_feat_name(list, sizeof(list), &pos, "popcnt");
    if (features & SHUX_CPU_FEAT_BMI2)
        append_feat_name(list, sizeof(list), &pos, "bmi2");
    if (features & SHUX_CPU_FEAT_NEON)
        append_feat_name(list, sizeof(list), &pos, "neon");
    if (features & SHUX_CPU_FEAT_SVE)
        append_feat_name(list, sizeof(list), &pos, "sve");
    if (features & SHUX_CPU_FEAT_RVV)
        append_feat_name(list, sizeof(list), &pos, "rvv");
    fprintf(out, "target_cpu_features=0x%08x\n", features);
    fprintf(out, "target_cpu_features_list=%s\n", list[0] ? list : "(none)");
    fprintf(out, "target_cpu_host_features=0x%08x\n", shu_target_cpu_detect_host());
}

/* G-02f-3：shu_simd_is_vector_type_spelling / shu_simd_vector_lanes_esz_from_spelling
 * 已迁 target_cpu_pure.x（产品链 pure.from_x.c）。 */
