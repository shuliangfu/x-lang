/**
 * target_cpu.inc — SIMD-S1：宿主机 CPU feature 探测与 `-target-cpu` 规格解析。
 *
 * G-02f-2：`driver_set/get_pending_target_cpu_features` 已迁
 * `target_cpu_pure.x`（产品链 ld -r pure + 本 TU → target_cpu.o）。
 *
 * Linux：读 /proc/cpuinfo flags/Features；
 * macOS：sysctl hw.optional.* / machdep.cpu.leaf7_features；
 * 兜底：编译器预定义宏（__AVX2__、__ARM_NEON 等）。
 */
#include "target_cpu.h"

#include <ctype.h>
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
 * 忽略大小写比较 spec 与 literal（spec_len 为 spec 有效长度）。
 */
static int spec_eq_ci(const char *spec, size_t spec_len, const char *literal) {
    size_t i;
    size_t lit_len;

    if (!spec || !literal)
        return 0;
    lit_len = strlen(literal);
    if (spec_len != lit_len)
        return 0;
    for (i = 0; i < spec_len; i++) {
        unsigned char a = (unsigned char)spec[i];
        unsigned char b = (unsigned char)literal[i];
        if (tolower(a) != tolower(b))
            return 0;
    }
    return 1;
}

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

/**
 * 解析具名特性或 microarch level（x86-64-v2/v3/v4）。
 */
static int shu_target_cpu_parse_named(const char *spec, size_t spec_len, uint32_t *out) {
    if (spec_eq_ci(spec, spec_len, "native")) {
        *out = shu_target_cpu_detect_host();
        return 0;
    }
    if (spec_eq_ci(spec, spec_len, "generic")) {
        *out = shu_target_cpu_generic_for_host();
        return 0;
    }
    if (spec_eq_ci(spec, spec_len, "sse2")) {
        *out = SHUX_CPU_FEAT_SSE2;
        return 0;
    }
    if (spec_eq_ci(spec, spec_len, "sse4.1") || spec_eq_ci(spec, spec_len, "sse4_1")) {
        *out = SHUX_CPU_FEAT_SSE2 | SHUX_CPU_FEAT_SSE41;
        return 0;
    }
    if (spec_eq_ci(spec, spec_len, "avx")) {
        *out = SHUX_CPU_FEAT_SSE2 | SHUX_CPU_FEAT_SSE41 | SHUX_CPU_FEAT_AVX;
        return 0;
    }
    if (spec_eq_ci(spec, spec_len, "avx2")) {
        *out = SHUX_CPU_FEAT_SSE2 | SHUX_CPU_FEAT_SSE41 | SHUX_CPU_FEAT_AVX | SHUX_CPU_FEAT_AVX2;
        return 0;
    }
    if (spec_eq_ci(spec, spec_len, "avx512") || spec_eq_ci(spec, spec_len, "avx512f")) {
        *out = SHUX_CPU_FEAT_SSE2 | SHUX_CPU_FEAT_SSE41 | SHUX_CPU_FEAT_AVX | SHUX_CPU_FEAT_AVX2 |
               SHUX_CPU_FEAT_AVX512F;
        return 0;
    }
    if (spec_eq_ci(spec, spec_len, "x86-64-v2")) {
        *out = SHUX_CPU_FEAT_SSE2 | SHUX_CPU_FEAT_SSE41 | SHUX_CPU_FEAT_POPCNT;
        return 0;
    }
    if (spec_eq_ci(spec, spec_len, "x86-64-v3")) {
        *out = SHUX_CPU_FEAT_SSE2 | SHUX_CPU_FEAT_SSE41 | SHUX_CPU_FEAT_AVX | SHUX_CPU_FEAT_AVX2 |
               SHUX_CPU_FEAT_POPCNT | SHUX_CPU_FEAT_BMI2;
        return 0;
    }
    if (spec_eq_ci(spec, spec_len, "x86-64-v4")) {
        *out = SHUX_CPU_FEAT_SSE2 | SHUX_CPU_FEAT_SSE41 | SHUX_CPU_FEAT_AVX | SHUX_CPU_FEAT_AVX2 |
               SHUX_CPU_FEAT_AVX512F | SHUX_CPU_FEAT_POPCNT | SHUX_CPU_FEAT_BMI2;
        return 0;
    }
    if (spec_eq_ci(spec, spec_len, "neon")) {
        *out = SHUX_CPU_FEAT_NEON;
        return 0;
    }
    if (spec_eq_ci(spec, spec_len, "sve")) {
        *out = SHUX_CPU_FEAT_NEON | SHUX_CPU_FEAT_SVE;
        return 0;
    }
    if (spec_eq_ci(spec, spec_len, "rvv")) {
        *out = SHUX_CPU_FEAT_RVV;
        return 0;
    }
    return -1;
}

int shu_target_cpu_resolve(const char *spec, size_t spec_len, uint32_t *out) {
    if (!out)
        return -1;
    if (!spec || spec_len == 0)
        return shu_target_cpu_parse_named("native", 6, out);
    while (spec_len > 0 && (spec[0] == ' ' || spec[0] == '\t')) {
        spec++;
        spec_len--;
    }
    while (spec_len > 0 && (spec[spec_len - 1] == ' ' || spec[spec_len - 1] == '\t'))
        spec_len--;
    return shu_target_cpu_parse_named(spec, spec_len, out);
}

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

/** 比较固定长度类型名（如 "Vec4f"）。 */
static int simd_name_eq(const char *name, size_t name_len, const char *literal) {
    return spec_eq_ci(name, name_len, literal);
}

/**
 * SIMD-S2：标准向量 TYPE_NAMED / lex 回落拼写表。
 * Vec4f→4×f32（128-bit NEON/SSE）；Vec8i→8×i32（256-bit AVX2）。
 */
int shu_simd_is_vector_type_spelling(const char *name, size_t name_len) {
    if (!name || name_len == 0)
        return 0;
    if (simd_name_eq(name, name_len, "i32x4") || simd_name_eq(name, name_len, "i32x8") ||
        simd_name_eq(name, name_len, "i32x16") || simd_name_eq(name, name_len, "u32x4") ||
        simd_name_eq(name, name_len, "u32x8") || simd_name_eq(name, name_len, "u32x16") ||
        simd_name_eq(name, name_len, "f32x4") || simd_name_eq(name, name_len, "Vec4f") ||
        simd_name_eq(name, name_len, "Vec8i"))
        return 1;
    return 0;
}

/**
 * 从拼写推断 lane 数；默认 4 lane i32/u32/f32（esz=4）。
 */
int shu_simd_vector_lanes_esz_from_spelling(const char *name, size_t name_len, int32_t *out_lanes,
                                            int32_t *out_esz) {
    if (!out_lanes || !out_esz || !shu_simd_is_vector_type_spelling(name, name_len))
        return -1;
    *out_lanes = 4;
    *out_esz = 4;
    if (name_len == 5 && name[4] == '8')
        *out_lanes = 8;
    if (name_len == 6 && name[4] == '1' && name[5] == '6')
        *out_lanes = 16;
    if (simd_name_eq(name, name_len, "Vec8i"))
        *out_lanes = 8;
    return 0;
}
