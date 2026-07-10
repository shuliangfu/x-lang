/* seeds/simd_enc.from_x.c — G-02f-7 product pure SIMD encode TU
 * Source intent: src/asm/simd_enc.x (doc) + this seed (full C encode body).
 * Pure hardware-vector encode helpers; no OS #if. Product: → src/asm/simd_enc.o
 * Content from former src/asm/simd_enc.inc (logic still C until full .x port).
 */
/**
 * simd_enc.c — SIMD-S3/S4：x86 SSE/AVX2 与 arm64 NEON 硬件向量编码（shuffle/select/add/…）。
 *
 * 栈布局与 pipeline_glue 向量 lane 一致：lane0 在 fp-slot_off，整向量低址为 slot_off-(lanes-1)*esz。
 */
#include "simd_enc.h"
#include "target_cpu.h"

#include <stdint.h>

extern int32_t pipeline_elf_ctx_append_bytes(uint8_t *ctx_bytes, uint8_t *ptr, int32_t n);

/** slot_off 为 asm 局部槽距 fp 的正字节距（lane0 低址端，与向量 let init 的 lea 一致）；x86 disp = -slot_off。 */
static int32_t simd_rbp_disp32(int32_t slot_off, int32_t lanes, int32_t esz) {
    (void)lanes;
    (void)esz;
    if (slot_off < 0)
        return 0;
    return -slot_off;
}

/**
 * arm64 128-bit 半幅 lea 正偏移（sub x29,#off 用）。
 * slot_off 为 lane0 距 fp 的字节距；lane 序号增大时地址升高、#off 减小，
 * 故 half1 = slot_off - 16（非 +16）；与 let 向量 init 的 [base+lane*esz] 一致。
 */
static int32_t simd_arm64_rbp_lea_off_128half(int32_t slot_off, int32_t half, int32_t esz) {
    if (slot_off < 0 || esz <= 0 || half < 0)
        return slot_off;
    return slot_off - half * 4 * esz;
}

static int32_t simd_append(struct platform_elf_ElfCodegenCtx *elf_ctx, const uint8_t *bytes, int32_t n) {
    if (!elf_ctx || !bytes || n <= 0)
        return -1;
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)bytes, n);
}

/** 向指令尾追加 disp32（小端）。 */
static int32_t simd_append_disp32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t disp) {
    uint8_t d[4];
    d[0] = (uint8_t)(disp & 0xff);
    d[1] = (uint8_t)((disp >> 8) & 0xff);
    d[2] = (uint8_t)((disp >> 16) & 0xff);
    d[3] = (uint8_t)((disp >> 24) & 0xff);
    return simd_append(elf_ctx, d, 4);
}

/** x86：movups xmm0, [rbp+disp32]（0F 10 85 disp32）。 */
static int32_t simd_x86_movups_xmm0_from_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t disp) {
    static const uint8_t prefix[3] = {0x0f, 0x10, 0x85};
    if (simd_append(elf_ctx, prefix, 3) != 0)
        return -1;
    return simd_append_disp32(elf_ctx, disp);
}

/** x86：movups xmm1, [rbp+disp32]（0F 10 8D disp32）。 */
static int32_t simd_x86_movups_xmm1_from_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t disp) {
    static const uint8_t prefix[3] = {0x0f, 0x10, 0x8d};
    if (simd_append(elf_ctx, prefix, 3) != 0)
        return -1;
    return simd_append_disp32(elf_ctx, disp);
}

/** x86：addps xmm0, xmm1（0F 58 C1）。 */
static int32_t simd_x86_addps_xmm0_xmm1(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[3] = {0x0f, 0x58, 0xc1};
    return simd_append(elf_ctx, insn, 3);
}

/** x86：paddd xmm0, xmm1（66 0F FE C1）。 */
static int32_t simd_x86_paddd_xmm0_xmm1(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[4] = {0x66, 0x0f, 0xfe, 0xc1};
    return simd_append(elf_ctx, insn, 4);
}

/** x86：movups [rbp+disp32], xmm0（0F 11 85 disp32）。 */
static int32_t simd_x86_movups_xmm0_to_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t disp) {
    static const uint8_t prefix[3] = {0x0f, 0x11, 0x85};
    if (simd_append(elf_ctx, prefix, 3) != 0)
        return -1;
    return simd_append_disp32(elf_ctx, disp);
}

/** x86 AVX2：vmovups ymm0, [rbp+disp32]（C5 FE 10 85 disp32）。 */
static int32_t simd_x86_vmovups_ymm0_from_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t disp) {
    static const uint8_t prefix[4] = {0xc5, 0xfe, 0x10, 0x85};
    if (simd_append(elf_ctx, prefix, 4) != 0)
        return -1;
    return simd_append_disp32(elf_ctx, disp);
}

/** x86 AVX2：vmovups ymm1, [rbp+disp32]（C5 FE 10 8D disp32）。 */
static int32_t simd_x86_vmovups_ymm1_from_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t disp) {
    static const uint8_t prefix[4] = {0xc5, 0xfe, 0x10, 0x8d};
    if (simd_append(elf_ctx, prefix, 4) != 0)
        return -1;
    return simd_append_disp32(elf_ctx, disp);
}

/** x86 AVX2：vpaddd ymm0, ymm0, ymm1（C5 FD FE C1）。 */
static int32_t simd_x86_vpaddd_ymm0_ymm1(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[4] = {0xc5, 0xfd, 0xfe, 0xc1};
    return simd_append(elf_ctx, insn, 4);
}

/** x86 AVX2：vmovups [rbp+disp32], ymm0（C5 FE 11 85 disp32）。 */
static int32_t simd_x86_vmovups_ymm0_to_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t disp) {
    static const uint8_t prefix[4] = {0xc5, 0xfe, 0x11, 0x85};
    if (simd_append(elf_ctx, prefix, 4) != 0)
        return -1;
    return simd_append_disp32(elf_ctx, disp);
}

/** x86：psubd xmm0, xmm1（66 0F FA C1）。 */
static int32_t simd_x86_psubd_xmm0_xmm1(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[4] = {0x66, 0x0f, 0xfa, 0xc1};
    return simd_append(elf_ctx, insn, 4);
}

/** x86 AVX2：vpsubd ymm0, ymm0, ymm1（C5 FD FA C1）。 */
static int32_t simd_x86_vpsubd_ymm0_ymm1(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[4] = {0xc5, 0xfd, 0xfa, 0xc1};
    return simd_append(elf_ctx, insn, 4);
}

/** x86 SSE4.1：pmulld xmm0, xmm1（66 0F 38 40 C1）。 */
static int32_t simd_x86_pmulld_xmm0_xmm1(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[5] = {0x66, 0x0f, 0x38, 0x40, 0xc1};
    return simd_append(elf_ctx, insn, 5);
}

/** x86 AVX2：vpmulld ymm0, ymm0, ymm1（C5 FD 40 C1）。 */
static int32_t simd_x86_vpmulld_ymm0_ymm1(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[4] = {0xc5, 0xfd, 0x40, 0xc1};
    return simd_append(elf_ctx, insn, 4);
}

/** x86：mulps xmm0, xmm1（0F 59 C1）。 */
static int32_t simd_x86_mulps_xmm0_xmm1(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[3] = {0x0f, 0x59, 0xc1};
    return simd_append(elf_ctx, insn, 3);
}

/** x86：movups xmm2, [rbp+disp32]（0F 10 95 disp32）。 */
static int32_t simd_x86_movups_xmm2_from_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t disp) {
    static const uint8_t prefix[3] = {0x0f, 0x10, 0x95};
    if (simd_append(elf_ctx, prefix, 3) != 0)
        return -1;
    return simd_append_disp32(elf_ctx, disp);
}

/** x86 FMA3：vfmadd231ps xmm0, xmm1, xmm2（xmm0 = xmm1 * xmm2 + xmm0）。 */
static int32_t simd_x86_vfmadd231ps_xmm0_xmm1_xmm2(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[5] = {0xc4, 0xe2, 0x71, 0xa9, 0xc1};
    return simd_append(elf_ctx, insn, 5);
}

/** 发射整型向量 add/sub 公共路径（SSE paddd/psubd 或 AVX2 vpaddd/vpsubd）。 */
static int32_t simd_enc_try_hw_vector_iadd_isub_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t slot_off_a,
                                                    int32_t slot_off_b, int32_t slot_off_dst, int32_t lanes,
                                                    int32_t esz, int32_t ta, uint32_t cpu_features, int32_t is_sub) {
    int32_t da;
    int32_t db;
    int32_t dd;

    if (!elf_ctx || slot_off_a < 0 || slot_off_b < 0 || slot_off_dst < 0 || esz != 4)
        return -1;
    if (ta != 0)
        return -1;
    da = simd_rbp_disp32(slot_off_a, lanes, esz);
    db = simd_rbp_disp32(slot_off_b, lanes, esz);
    dd = simd_rbp_disp32(slot_off_dst, lanes, esz);
    if (lanes == 8 && (cpu_features & SHUX_CPU_FEAT_AVX2) != 0) {
        if (simd_x86_vmovups_ymm0_from_rbp(elf_ctx, da) != 0)
            return -1;
        if (simd_x86_vmovups_ymm1_from_rbp(elf_ctx, db) != 0)
            return -1;
        if (is_sub) {
            if (simd_x86_vpsubd_ymm0_ymm1(elf_ctx) != 0)
                return -1;
        } else {
            if (simd_x86_vpaddd_ymm0_ymm1(elf_ctx) != 0)
                return -1;
        }
        if (simd_x86_vmovups_ymm0_to_rbp(elf_ctx, dd) != 0)
            return -1;
        return 0;
    }
    if (lanes == 4 && (cpu_features & SHUX_CPU_FEAT_SSE2) != 0) {
        if (simd_x86_movups_xmm0_from_rbp(elf_ctx, da) != 0)
            return -1;
        if (simd_x86_movups_xmm1_from_rbp(elf_ctx, db) != 0)
            return -1;
        if (is_sub) {
            if (simd_x86_psubd_xmm0_xmm1(elf_ctx) != 0)
                return -1;
        } else {
            if (simd_x86_paddd_xmm0_xmm1(elf_ctx) != 0)
                return -1;
        }
        if (simd_x86_movups_xmm0_to_rbp(elf_ctx, dd) != 0)
            return -1;
        return 0;
    }
    return -1;
}

int32_t simd_enc_try_hw_vector_iadd_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t slot_off_a,
                                        int32_t slot_off_b, int32_t slot_off_dst, int32_t lanes, int32_t esz,
                                        int32_t ta, uint32_t cpu_features) {
    return simd_enc_try_hw_vector_iadd_isub_rbp(elf_ctx, slot_off_a, slot_off_b, slot_off_dst, lanes, esz, ta,
                                                cpu_features, 0);
}

int32_t simd_enc_try_hw_vector_isub_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t slot_off_a,
                                        int32_t slot_off_b, int32_t slot_off_dst, int32_t lanes, int32_t esz,
                                        int32_t ta, uint32_t cpu_features) {
    return simd_enc_try_hw_vector_iadd_isub_rbp(elf_ctx, slot_off_a, slot_off_b, slot_off_dst, lanes, esz, ta,
                                                cpu_features, 1);
}

int32_t simd_enc_try_hw_vector_imul_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t slot_off_a,
                                        int32_t slot_off_b, int32_t slot_off_dst, int32_t lanes, int32_t esz,
                                        int32_t ta, uint32_t cpu_features) {
    int32_t da;
    int32_t db;
    int32_t dd;

    if (!elf_ctx || slot_off_a < 0 || slot_off_b < 0 || slot_off_dst < 0 || esz != 4)
        return -1;
    if (ta != 0)
        return -1;
    da = simd_rbp_disp32(slot_off_a, lanes, esz);
    db = simd_rbp_disp32(slot_off_b, lanes, esz);
    dd = simd_rbp_disp32(slot_off_dst, lanes, esz);
    if (lanes == 8 && (cpu_features & SHUX_CPU_FEAT_AVX2) != 0) {
        if (simd_x86_vmovups_ymm0_from_rbp(elf_ctx, da) != 0)
            return -1;
        if (simd_x86_vmovups_ymm1_from_rbp(elf_ctx, db) != 0)
            return -1;
        if (simd_x86_vpmulld_ymm0_ymm1(elf_ctx) != 0)
            return -1;
        if (simd_x86_vmovups_ymm0_to_rbp(elf_ctx, dd) != 0)
            return -1;
        return 0;
    }
    if (lanes == 4 && (cpu_features & SHUX_CPU_FEAT_SSE41) != 0) {
        if (simd_x86_movups_xmm0_from_rbp(elf_ctx, da) != 0)
            return -1;
        if (simd_x86_movups_xmm1_from_rbp(elf_ctx, db) != 0)
            return -1;
        if (simd_x86_pmulld_xmm0_xmm1(elf_ctx) != 0)
            return -1;
        if (simd_x86_movups_xmm0_to_rbp(elf_ctx, dd) != 0)
            return -1;
        return 0;
    }
    return -1;
}

int32_t simd_enc_try_hw_vector_fadd_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t slot_off_a,
                                        int32_t slot_off_b, int32_t slot_off_dst, int32_t lanes, int32_t esz,
                                        int32_t ta, uint32_t cpu_features) {
    int32_t da;
    int32_t db;
    int32_t dd;

    if (!elf_ctx || slot_off_a < 0 || slot_off_b < 0 || slot_off_dst < 0 || esz != 4 || lanes != 4)
        return -1;
    if (ta != 0)
        return -1;
    if ((cpu_features & SHUX_CPU_FEAT_SSE2) == 0)
        return -1;
    da = simd_rbp_disp32(slot_off_a, lanes, esz);
    db = simd_rbp_disp32(slot_off_b, lanes, esz);
    dd = simd_rbp_disp32(slot_off_dst, lanes, esz);
    if (simd_x86_movups_xmm0_from_rbp(elf_ctx, da) != 0)
        return -1;
    if (simd_x86_movups_xmm1_from_rbp(elf_ctx, db) != 0)
        return -1;
    if (simd_x86_addps_xmm0_xmm1(elf_ctx) != 0)
        return -1;
    if (simd_x86_movups_xmm0_to_rbp(elf_ctx, dd) != 0)
        return -1;
    return 0;
}

int32_t simd_enc_try_hw_vector_fmul_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t slot_off_a,
                                        int32_t slot_off_b, int32_t slot_off_dst, int32_t lanes, int32_t esz,
                                        int32_t ta, uint32_t cpu_features) {
    int32_t da;
    int32_t db;
    int32_t dd;

    if (!elf_ctx || slot_off_a < 0 || slot_off_b < 0 || slot_off_dst < 0 || esz != 4 || lanes != 4)
        return -1;
    if (ta != 0)
        return -1;
    if ((cpu_features & SHUX_CPU_FEAT_SSE2) == 0)
        return -1;
    da = simd_rbp_disp32(slot_off_a, lanes, esz);
    db = simd_rbp_disp32(slot_off_b, lanes, esz);
    dd = simd_rbp_disp32(slot_off_dst, lanes, esz);
    if (simd_x86_movups_xmm0_from_rbp(elf_ctx, da) != 0)
        return -1;
    if (simd_x86_movups_xmm1_from_rbp(elf_ctx, db) != 0)
        return -1;
    if (simd_x86_mulps_xmm0_xmm1(elf_ctx) != 0)
        return -1;
    if (simd_x86_movups_xmm0_to_rbp(elf_ctx, dd) != 0)
        return -1;
    return 0;
}

int32_t simd_enc_try_hw_vector_fma_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t slot_off_a,
                                       int32_t slot_off_b, int32_t slot_off_c, int32_t slot_off_dst, int32_t lanes,
                                       int32_t esz, int32_t ta, uint32_t cpu_features) {
    int32_t da;
    int32_t db;
    int32_t dc;
    int32_t dd;

    if (!elf_ctx || slot_off_a < 0 || slot_off_b < 0 || slot_off_c < 0 || slot_off_dst < 0 || esz != 4 || lanes != 4)
        return -1;
    if (ta != 0)
        return -1;
    if ((cpu_features & SHUX_CPU_FEAT_SSE2) == 0)
        return -1;
    da = simd_rbp_disp32(slot_off_a, lanes, esz);
    db = simd_rbp_disp32(slot_off_b, lanes, esz);
    dc = simd_rbp_disp32(slot_off_c, lanes, esz);
    dd = simd_rbp_disp32(slot_off_dst, lanes, esz);
    if ((cpu_features & SHUX_CPU_FEAT_FMA) != 0) {
        if (simd_x86_movups_xmm0_from_rbp(elf_ctx, da) != 0)
            return -1;
        if (simd_x86_movups_xmm1_from_rbp(elf_ctx, db) != 0)
            return -1;
        if (simd_x86_movups_xmm2_from_rbp(elf_ctx, dc) != 0)
            return -1;
        if (simd_x86_vfmadd231ps_xmm0_xmm1_xmm2(elf_ctx) != 0)
            return -1;
    } else {
        /* b*c → xmm0；xmm0 += a */
        if (simd_x86_movups_xmm0_from_rbp(elf_ctx, dc) != 0)
            return -1;
        if (simd_x86_movups_xmm1_from_rbp(elf_ctx, db) != 0)
            return -1;
        if (simd_x86_mulps_xmm0_xmm1(elf_ctx) != 0)
            return -1;
        if (simd_x86_movups_xmm1_from_rbp(elf_ctx, da) != 0)
            return -1;
        if (simd_x86_addps_xmm0_xmm1(elf_ctx) != 0)
            return -1;
    }
    if (simd_x86_movups_xmm0_to_rbp(elf_ctx, dd) != 0)
        return -1;
    return 0;
}

/** x86 AVX2：vmovups ymm0, [rbx+rax*4]（C4 E2 7D 10 04 83）。 */
static int32_t simd_x86_vmovups_ymm0_from_rbx_rax4(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[6] = {0xc4, 0xe2, 0x7d, 0x10, 0x04, 0x83};
    return simd_append(elf_ctx, insn, 6);
}

/** x86 AVX2：vmovups ymm1, [rbx+rax*4]（C4 E2 75 10 04 83）。 */
static int32_t simd_x86_vmovups_ymm1_from_rbx_rax4(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[6] = {0xc4, 0xe2, 0x75, 0x10, 0x04, 0x83};
    return simd_append(elf_ctx, insn, 6);
}

/** x86 AVX2：vmovups [rbx+rax*4], ymm0（C4 E2 7D 11 04 83）。 */
static int32_t simd_x86_vmovups_ymm0_to_rbx_rax4(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[6] = {0xc4, 0xe2, 0x7d, 0x11, 0x04, 0x83};
    return simd_append(elf_ctx, insn, 6);
}

/** x86 SSE：movups xmm0, [rbx+rax*4]（C5 F8 10 04 83）。 */
static int32_t simd_x86_movups_xmm0_from_rbx_rax4(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[5] = {0xc5, 0xf8, 0x10, 0x04, 0x83};
    return simd_append(elf_ctx, insn, 5);
}

/** x86 SSE：movups xmm1, [rbx+rax*4]（C5 F0 10 04 83）。 */
static int32_t simd_x86_movups_xmm1_from_rbx_rax4(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[5] = {0xc5, 0xf0, 0x10, 0x04, 0x83};
    return simd_append(elf_ctx, insn, 5);
}

/** x86 SSE：movups [rbx+rax*4], xmm0（C5 F8 11 04 83）。 */
static int32_t simd_x86_movups_xmm0_to_rbx_rax4(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[5] = {0xc5, 0xf8, 0x11, 0x04, 0x83};
    return simd_append(elf_ctx, insn, 5);
}

extern int32_t backend_enc_load_rbp_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                                int32_t ta);
extern int32_t backend_enc_lea_rbp_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                               int32_t ta);
extern int32_t backend_enc_lea_rbp_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                               int32_t ta);

int32_t simd_enc_try_hw_vector_binop_rbp_at_idx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off_a,
                                                int32_t off_b, int32_t off_d, int32_t off_i, int32_t array_n,
                                                int32_t binop_ko, int32_t lanes, int32_t esz, int32_t ta,
                                                uint32_t cpu_features) {
    int32_t elem0_a;
    int32_t elem0_b;
    int32_t elem0_d;

    if (!elf_ctx || off_a < 0 || off_b < 0 || off_d < 0 || off_i < 0 || array_n <= 0 || esz != 4)
        return -1;
    if (ta != 0)
        return -1;
    elem0_a = off_a - (array_n - 1) * esz;
    elem0_b = off_b - (array_n - 1) * esz;
    elem0_d = off_d - (array_n - 1) * esz;
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta) != 0)
        return -1;
    if (backend_enc_lea_rbp_to_rbx_arch(elf_ctx, elem0_a, ta) != 0)
        return -1;
    if (lanes == 8 && (cpu_features & SHUX_CPU_FEAT_AVX2) != 0) {
        if (simd_x86_vmovups_ymm0_from_rbx_rax4(elf_ctx) != 0)
            return -1;
        if (backend_enc_lea_rbp_to_rbx_arch(elf_ctx, elem0_b, ta) != 0)
            return -1;
        if (simd_x86_vmovups_ymm1_from_rbx_rax4(elf_ctx) != 0)
            return -1;
        if (binop_ko == 5) {
            if (simd_x86_vpsubd_ymm0_ymm1(elf_ctx) != 0)
                return -1;
        } else if (binop_ko == 6) {
            if (simd_x86_vpmulld_ymm0_ymm1(elf_ctx) != 0)
                return -1;
        } else {
            if (simd_x86_vpaddd_ymm0_ymm1(elf_ctx) != 0)
                return -1;
        }
        if (backend_enc_lea_rbp_to_rbx_arch(elf_ctx, elem0_d, ta) != 0)
            return -1;
        if (simd_x86_vmovups_ymm0_to_rbx_rax4(elf_ctx) != 0)
            return -1;
        return 0;
    }
    if (lanes == 4) {
        if (binop_ko == 6 && (cpu_features & SHUX_CPU_FEAT_SSE41) == 0)
            return -1;
        if (binop_ko != 6 && (cpu_features & SHUX_CPU_FEAT_SSE2) == 0)
            return -1;
        if (simd_x86_movups_xmm0_from_rbx_rax4(elf_ctx) != 0)
            return -1;
        if (backend_enc_lea_rbp_to_rbx_arch(elf_ctx, elem0_b, ta) != 0)
            return -1;
        if (simd_x86_movups_xmm1_from_rbx_rax4(elf_ctx) != 0)
            return -1;
        if (binop_ko == 5) {
            if (simd_x86_psubd_xmm0_xmm1(elf_ctx) != 0)
                return -1;
        } else if (binop_ko == 6) {
            if (simd_x86_pmulld_xmm0_xmm1(elf_ctx) != 0)
                return -1;
        } else {
            if (simd_x86_paddd_xmm0_xmm1(elf_ctx) != 0)
                return -1;
        }
        if (backend_enc_lea_rbp_to_rbx_arch(elf_ctx, elem0_d, ta) != 0)
            return -1;
        if (simd_x86_movups_xmm0_to_rbx_rax4(elf_ctx) != 0)
            return -1;
        return 0;
    }
    return -1;
}

/** 向指令流追加 little-endian u32 机器字（arm64 NEON 等）。 */
static int32_t simd_append_u32_le(struct platform_elf_ElfCodegenCtx *elf_ctx, uint32_t word) {
    uint8_t b[4];
    b[0] = (uint8_t)(word & 0xffU);
    b[1] = (uint8_t)((word >> 8) & 0xffU);
    b[2] = (uint8_t)((word >> 16) & 0xffU);
    b[3] = (uint8_t)((word >> 24) & 0xffU);
    return simd_append(elf_ctx, b, 4);
}

/**
 * arm64 NEON：INS V1.S[dst_lane], V0.S[src_lane]（V0 源 / V1 目的，Rn=0 Rd=1）。
 * 低 16 位须为 0x401（clang -c 烟测）；误写 |1 会被 otool 解成 EXT，shuffle 结果错误。
 */
static uint32_t simd_arm64_ins_v1_from_v0_s(int32_t dst_lane, int32_t src_lane) {
  return (uint32_t)(0x6E040000U | ((dst_lane & 3) << 19) | ((src_lane & 3) << 13) | 0x401U);
}

/**
 * arm64 NEON：128-bit comptime shuffle（pshufd 同 imm8 语义，4 lane）。
 * lea_src/lea_dst 为 sub x0,x29,#off 的正字节偏移（与 simd_rbp_disp32 一致）。
 */
static int32_t simd_arm64_pshufd_imm8_128_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lea_src,
                                              int32_t lea_dst, int32_t imm8, int32_t ta) {
    int32_t li;
    int32_t src_lane;

    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, lea_src, ta) != 0)
        return -1;
    if (simd_append_u32_le(elf_ctx, 0x4c407800U) != 0) /* ld1 {v0.4s}, [x0] */
        return -1;
    if (simd_append_u32_le(elf_ctx, 0x4ea01c01U) != 0) /* mov v1.16b, v0.16b */
        return -1;
    for (li = 0; li < 4; li++) {
        src_lane = (imm8 >> (li * 2)) & 3;
        if (simd_append_u32_le(elf_ctx, simd_arm64_ins_v1_from_v0_s(li, src_lane)) != 0)
            return -1;
    }
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, lea_dst, ta) != 0)
        return -1;
    if (simd_append_u32_le(elf_ctx, 0x4c007801U) != 0) /* st1 {v1.4s}, [x0] */
        return -1;
    return 0;
}

/**
 * arm64 NEON：128-bit 向量 select（mask lane > 0 取 a，否则 b）。
 * is_f32!=0 用 fcmgt，否则 cmgt.s #0。
 */
static int32_t simd_arm64_select_128_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lea_mask,
                                       int32_t lea_a, int32_t lea_b, int32_t lea_dst, int32_t is_f32,
                                       int32_t ta) {
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, lea_mask, ta) != 0)
        return -1;
    if (simd_append_u32_le(elf_ctx, 0x4c407800U) != 0) /* ld1 {v0.4s}, [x0] mask */
        return -1;
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, lea_a, ta) != 0)
        return -1;
    if (simd_append_u32_le(elf_ctx, 0x4c407801U) != 0) /* ld1 {v1.4s}, [x0] a */
        return -1;
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, lea_b, ta) != 0)
        return -1;
    if (simd_append_u32_le(elf_ctx, 0x4c407802U) != 0) /* ld1 {v2.4s}, [x0] b */
        return -1;
    if (is_f32) {
        if (simd_append_u32_le(elf_ctx, 0x4ea0c803U) != 0) /* fcmgt v3.4s, v0.4s, #0 */
            return -1;
        if (simd_append_u32_le(elf_ctx, 0x6ea21c23U) != 0) /* bit v3.16b, v1.16b, v2.16b */
            return -1;
    } else {
        if (simd_append_u32_le(elf_ctx, 0x4ea08803U) != 0) /* cmgt v3.4s, v0.4s, #0 */
            return -1;
        /* i32：cmgt 谓词须用 bsl（非 bit）；bit 在 cmgt 后 lane 结果错误 */
        if (simd_append_u32_le(elf_ctx, 0x6e621c23U) != 0) /* bsl v3.16b, v1.16b, v2.16b */
            return -1;
    }
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, lea_dst, ta) != 0)
        return -1;
    if (simd_append_u32_le(elf_ctx, 0x4c007803U) != 0) /* st1 {v3.4s}, [x0] */
        return -1;
    return 0;
}

/** x86：pshufd xmm0, xmm0, imm8（66 0F 70 C0 imm8）。 */
static int32_t simd_x86_pshufd_xmm0_imm8(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm8) {
    static const uint8_t prefix[4] = {0x66, 0x0f, 0x70, 0xc0};
    uint8_t ib;
    if (simd_append(elf_ctx, prefix, 4) != 0)
        return -1;
    ib = (uint8_t)(imm8 & 0xff);
    return simd_append(elf_ctx, &ib, 1);
}

/** x86 AVX2：vpshufd ymm0, ymm0, imm8（C5 FE 70 C0 imm8）。 */
static int32_t simd_x86_vpshufd_ymm0_imm8(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm8) {
    static const uint8_t prefix[4] = {0xc5, 0xfe, 0x70, 0xc0};
    uint8_t ib;
    if (simd_append(elf_ctx, prefix, 4) != 0)
        return -1;
    ib = (uint8_t)(imm8 & 0xff);
    return simd_append(elf_ctx, &ib, 1);
}

int32_t simd_enc_try_pshufd_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t slot_off_src,
                                int32_t slot_off_dst, int32_t imm8, int32_t lanes, int32_t ta,
                                uint32_t cpu_features) {
    int32_t ds;
    int32_t dd;
    if (!elf_ctx || slot_off_src < 0 || slot_off_dst < 0)
        return -1;
    ds = simd_rbp_disp32(slot_off_src, lanes, 4);
    dd = simd_rbp_disp32(slot_off_dst, lanes, 4);
    if (ta == 1) {
        if ((cpu_features & SHUX_CPU_FEAT_NEON) == 0)
            return -1;
        ds = simd_arm64_rbp_lea_off_128half(slot_off_src, 0, 4);
        dd = simd_arm64_rbp_lea_off_128half(slot_off_dst, 0, 4);
        if (lanes == 4)
            return simd_arm64_pshufd_imm8_128_rbp(elf_ctx, ds, dd, imm8, ta);
        if (lanes == 8) {
            int32_t ds1;
            int32_t dd1;
            ds1 = simd_arm64_rbp_lea_off_128half(slot_off_src, 1, 4);
            dd1 = simd_arm64_rbp_lea_off_128half(slot_off_dst, 1, 4);
            if (simd_arm64_pshufd_imm8_128_rbp(elf_ctx, ds, dd, imm8, ta) != 0)
                return -1;
            if (simd_arm64_pshufd_imm8_128_rbp(elf_ctx, ds1, dd1, imm8, ta) != 0)
                return -1;
            return 0;
        }
        return -1;
    }
    if (ta != 0)
        return -1;
    if (lanes == 8 && (cpu_features & SHUX_CPU_FEAT_AVX2) != 0) {
        if (simd_x86_vmovups_ymm0_from_rbp(elf_ctx, ds) != 0)
            return -1;
        if (simd_x86_vpshufd_ymm0_imm8(elf_ctx, imm8) != 0)
            return -1;
        if (simd_x86_vmovups_ymm0_to_rbp(elf_ctx, dd) != 0)
            return -1;
        return 0;
    }
    if (lanes == 4 && (cpu_features & SHUX_CPU_FEAT_SSE2) != 0) {
        if (simd_x86_movups_xmm0_from_rbp(elf_ctx, ds) != 0)
            return -1;
        if (simd_x86_pshufd_xmm0_imm8(elf_ctx, imm8) != 0)
            return -1;
        if (simd_x86_movups_xmm0_to_rbp(elf_ctx, dd) != 0)
            return -1;
        return 0;
    }
    return -1;
}

/** x86 AVX2：vmovups ymm2, [rbp+disp32]（C5 FE 10 95 disp32）。 */
static int32_t simd_x86_vmovups_ymm2_from_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t disp) {
    static const uint8_t prefix[4] = {0xc5, 0xfe, 0x10, 0x95};
    if (simd_append(elf_ctx, prefix, 4) != 0)
        return -1;
    return simd_append_disp32(elf_ctx, disp);
}

/** x86 SSE2：pxor xmm3, xmm3（66 0F EF DB）。 */
static int32_t simd_x86_pxor_xmm3_xmm3(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[4] = {0x66, 0x0f, 0xef, 0xdb};
    return simd_append(elf_ctx, insn, 4);
}

/** x86 SSE2：pcmpgtd xmm2, xmm3（66 0F 66 D3）。 */
static int32_t simd_x86_pcmpgtd_xmm2_xmm3(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[4] = {0x66, 0x0f, 0x66, 0xd3};
    return simd_append(elf_ctx, insn, 4);
}

/** x86 SSE2：pand xmm0, xmm2（66 0F DB C2）。 */
static int32_t simd_x86_pand_xmm0_xmm2(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[4] = {0x66, 0x0f, 0xdb, 0xc2};
    return simd_append(elf_ctx, insn, 4);
}

/** x86 SSE2：pandn xmm2, xmm1（66 0F DF D1）。 */
static int32_t simd_x86_pandn_xmm2_xmm1(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[4] = {0x66, 0x0f, 0xdf, 0xd1};
    return simd_append(elf_ctx, insn, 4);
}

/** x86 SSE2：por xmm0, xmm2（66 0F EB C2）。 */
static int32_t simd_x86_por_xmm0_xmm2(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[4] = {0x66, 0x0f, 0xeb, 0xc2};
    return simd_append(elf_ctx, insn, 4);
}

/** x86 SSE：xorps xmm3, xmm3（0F 57 DB）。 */
static int32_t simd_x86_xorps_xmm3_xmm3(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[3] = {0x0f, 0x57, 0xdb};
    return simd_append(elf_ctx, insn, 3);
}

/** x86 SSE：cmpgtps xmm2, xmm3（0F 55 D3）。 */
static int32_t simd_x86_cmpgtps_xmm2_xmm3(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[3] = {0x0f, 0x55, 0xd3};
    return simd_append(elf_ctx, insn, 3);
}

/** x86 SSE：andps xmm0, xmm2（0F 54 C2）。 */
static int32_t simd_x86_andps_xmm0_xmm2(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[3] = {0x0f, 0x54, 0xc2};
    return simd_append(elf_ctx, insn, 3);
}

/** x86 SSE：andnps xmm2, xmm1（0F 55 D1）。 */
static int32_t simd_x86_andnps_xmm2_xmm1(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[3] = {0x0f, 0x55, 0xd1};
    return simd_append(elf_ctx, insn, 3);
}

/** x86 SSE：orps xmm0, xmm2（0F 56 C2）。 */
static int32_t simd_x86_orps_xmm0_xmm2(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[3] = {0x0f, 0x56, 0xc2};
    return simd_append(elf_ctx, insn, 3);
}

/** x86 AVX2：vpxor ymm3, ymm3, ymm3（C5 F5 77 DB）。 */
static int32_t simd_x86_vpxor_ymm3_ymm3(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[4] = {0xc5, 0xf5, 0x77, 0xdb};
    return simd_append(elf_ctx, insn, 4);
}

/** x86 AVX2：vpcmpgtd ymm2, ymm2, ymm3（C5 ED 66 D3）。 */
static int32_t simd_x86_vpcmpgtd_ymm2_ymm3(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[4] = {0xc5, 0xed, 0x66, 0xd3};
    return simd_append(elf_ctx, insn, 4);
}

/** x86 AVX2：vpand ymm0, ymm0, ymm2（C5 E5 DB C2）。 */
static int32_t simd_x86_vpand_ymm0_ymm2(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[4] = {0xc5, 0xe5, 0xdb, 0xc2};
    return simd_append(elf_ctx, insn, 4);
}

/** x86 AVX2：vpandn ymm2, ymm2, ymm1（C5 E5 DF D1）。 */
static int32_t simd_x86_vpandn_ymm2_ymm1(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[4] = {0xc5, 0xe5, 0xdf, 0xd1};
    return simd_append(elf_ctx, insn, 4);
}

/** x86 AVX2：vpor ymm0, ymm0, ymm2（C5 E5 EB C2）。 */
static int32_t simd_x86_vpor_ymm0_ymm2(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[4] = {0xc5, 0xe5, 0xeb, 0xc2};
    return simd_append(elf_ctx, insn, 4);
}

/** x86 AVX：vxorps ymm3, ymm3, ymm3（C5 F0 57 DB）。 */
static int32_t simd_x86_vxorps_ymm3_ymm3(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[4] = {0xc5, 0xf0, 0x57, 0xdb};
    return simd_append(elf_ctx, insn, 4);
}

/** x86 AVX：vcmpgtps ymm2, ymm2, ymm3（C5 E8 57 D3）。 */
static int32_t simd_x86_vcmpgtps_ymm2_ymm3(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[4] = {0xc5, 0xe8, 0x57, 0xd3};
    return simd_append(elf_ctx, insn, 4);
}

/** x86 AVX：vandps ymm0, ymm0, ymm2（C5 E0 54 C2）。 */
static int32_t simd_x86_vandps_ymm0_ymm2(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[4] = {0xc5, 0xe0, 0x54, 0xc2};
    return simd_append(elf_ctx, insn, 4);
}

/** x86 AVX：vandnps ymm2, ymm2, ymm1（C5 E8 55 D1）。 */
static int32_t simd_x86_vandnps_ymm2_ymm1(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[4] = {0xc5, 0xe8, 0x55, 0xd1};
    return simd_append(elf_ctx, insn, 4);
}

/** x86 AVX：vorps ymm0, ymm0, ymm2（C5 E0 56 C2）。 */
static int32_t simd_x86_vorps_ymm0_ymm2(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[4] = {0xc5, 0xe0, 0x56, 0xc2};
    return simd_append(elf_ctx, insn, 4);
}

/** i32 向量 select：xmm0=a, xmm1=b, xmm2=mask→结果写回 xmm0。 */
static int32_t simd_enc_emit_i32_select_xmm_seq(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    if (simd_x86_pxor_xmm3_xmm3(elf_ctx) != 0)
        return -1;
    if (simd_x86_pcmpgtd_xmm2_xmm3(elf_ctx) != 0)
        return -1;
    if (simd_x86_pand_xmm0_xmm2(elf_ctx) != 0)
        return -1;
    if (simd_x86_pandn_xmm2_xmm1(elf_ctx) != 0)
        return -1;
    if (simd_x86_por_xmm0_xmm2(elf_ctx) != 0)
        return -1;
    return 0;
}

/** f32 向量 select：xmm0=a, xmm1=b, xmm2=mask→结果写回 xmm0。 */
static int32_t simd_enc_emit_f32_select_xmm_seq(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    if (simd_x86_xorps_xmm3_xmm3(elf_ctx) != 0)
        return -1;
    if (simd_x86_cmpgtps_xmm2_xmm3(elf_ctx) != 0)
        return -1;
    if (simd_x86_andps_xmm0_xmm2(elf_ctx) != 0)
        return -1;
    if (simd_x86_andnps_xmm2_xmm1(elf_ctx) != 0)
        return -1;
    if (simd_x86_orps_xmm0_xmm2(elf_ctx) != 0)
        return -1;
    return 0;
}

/** AVX2 i32 select：ymm0=a, ymm1=b, ymm2=mask。 */
static int32_t simd_enc_emit_i32_select_ymm_seq(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    if (simd_x86_vpxor_ymm3_ymm3(elf_ctx) != 0)
        return -1;
    if (simd_x86_vpcmpgtd_ymm2_ymm3(elf_ctx) != 0)
        return -1;
    if (simd_x86_vpand_ymm0_ymm2(elf_ctx) != 0)
        return -1;
    if (simd_x86_vpandn_ymm2_ymm1(elf_ctx) != 0)
        return -1;
    if (simd_x86_vpor_ymm0_ymm2(elf_ctx) != 0)
        return -1;
    return 0;
}

/** AVX f32 select：ymm0=a, ymm1=b, ymm2=mask。 */
static int32_t simd_enc_emit_f32_select_ymm_seq(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    if (simd_x86_vxorps_ymm3_ymm3(elf_ctx) != 0)
        return -1;
    if (simd_x86_vcmpgtps_ymm2_ymm3(elf_ctx) != 0)
        return -1;
    if (simd_x86_vandps_ymm0_ymm2(elf_ctx) != 0)
        return -1;
    if (simd_x86_vandnps_ymm2_ymm1(elf_ctx) != 0)
        return -1;
    if (simd_x86_vorps_ymm0_ymm2(elf_ctx) != 0)
        return -1;
    return 0;
}

int32_t simd_enc_try_hw_vector_select_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t slot_off_mask,
                                          int32_t slot_off_a, int32_t slot_off_b, int32_t slot_off_dst,
                                          int32_t lanes, int32_t is_f32, int32_t ta, uint32_t cpu_features) {
    int32_t dm;
    int32_t da;
    int32_t db;
    int32_t dd;

    if (!elf_ctx || slot_off_mask < 0 || slot_off_a < 0 || slot_off_b < 0 || slot_off_dst < 0)
        return -1;
    dm = simd_rbp_disp32(slot_off_mask, lanes, 4);
    da = simd_rbp_disp32(slot_off_a, lanes, 4);
    db = simd_rbp_disp32(slot_off_b, lanes, 4);
    dd = simd_rbp_disp32(slot_off_dst, lanes, 4);
    if (ta == 1) {
        if ((cpu_features & SHUX_CPU_FEAT_NEON) == 0)
            return -1;
        dm = simd_arm64_rbp_lea_off_128half(slot_off_mask, 0, 4);
        da = simd_arm64_rbp_lea_off_128half(slot_off_a, 0, 4);
        db = simd_arm64_rbp_lea_off_128half(slot_off_b, 0, 4);
        dd = simd_arm64_rbp_lea_off_128half(slot_off_dst, 0, 4);
        if (lanes == 4)
            return simd_arm64_select_128_rbp(elf_ctx, dm, da, db, dd, is_f32, ta);
        if (lanes == 8) {
            int32_t dm1;
            int32_t da1;
            int32_t db1;
            int32_t dd1;
            dm1 = simd_arm64_rbp_lea_off_128half(slot_off_mask, 1, 4);
            da1 = simd_arm64_rbp_lea_off_128half(slot_off_a, 1, 4);
            db1 = simd_arm64_rbp_lea_off_128half(slot_off_b, 1, 4);
            dd1 = simd_arm64_rbp_lea_off_128half(slot_off_dst, 1, 4);
            if (simd_arm64_select_128_rbp(elf_ctx, dm, da, db, dd, is_f32, ta) != 0)
                return -1;
            if (simd_arm64_select_128_rbp(elf_ctx, dm1, da1, db1, dd1, is_f32, ta) != 0)
                return -1;
            return 0;
        }
        return -1;
    }
    if (ta != 0)
        return -1;
    if (lanes == 8 && (cpu_features & SHUX_CPU_FEAT_AVX2) != 0) {
        if (simd_x86_vmovups_ymm0_from_rbp(elf_ctx, da) != 0)
            return -1;
        if (simd_x86_vmovups_ymm1_from_rbp(elf_ctx, db) != 0)
            return -1;
        if (simd_x86_vmovups_ymm2_from_rbp(elf_ctx, dm) != 0)
            return -1;
        if (is_f32) {
            if (simd_enc_emit_f32_select_ymm_seq(elf_ctx) != 0)
                return -1;
        } else {
            if (simd_enc_emit_i32_select_ymm_seq(elf_ctx) != 0)
                return -1;
        }
        if (simd_x86_vmovups_ymm0_to_rbp(elf_ctx, dd) != 0)
            return -1;
        return 0;
    }
    if (lanes == 4 && (cpu_features & SHUX_CPU_FEAT_SSE2) != 0) {
        if (simd_x86_movups_xmm0_from_rbp(elf_ctx, da) != 0)
            return -1;
        if (simd_x86_movups_xmm1_from_rbp(elf_ctx, db) != 0)
            return -1;
        if (simd_x86_movups_xmm2_from_rbp(elf_ctx, dm) != 0)
            return -1;
        if (is_f32) {
            if (simd_enc_emit_f32_select_xmm_seq(elf_ctx) != 0)
                return -1;
        } else {
            if (simd_enc_emit_i32_select_xmm_seq(elf_ctx) != 0)
                return -1;
        }
        if (simd_x86_movups_xmm0_to_rbp(elf_ctx, dd) != 0)
            return -1;
        return 0;
    }
    return -1;
}

/** x86：xorps xmm0, xmm0（acc 清零）。 */
int32_t simd_enc_x86_xorps_xmm0_zero(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[3] = {0x0f, 0x57, 0xc0};
    if (!elf_ctx)
        return -1;
    return simd_append(elf_ctx, insn, 3);
}

/** x86：movups xmm1, [rbp+disp32]（f32 SoA 列块 load）。 */
int32_t simd_enc_x86_movups_xmm1_rbp_disp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t disp) {
    if (!elf_ctx)
        return -1;
    return simd_x86_movups_xmm1_from_rbp(elf_ctx, disp);
}

/** x86：addps xmm0, xmm1（f32 向量累加）。 */
int32_t simd_enc_x86_addps_xmm0_xmm1(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    if (!elf_ctx)
        return -1;
    return simd_x86_addps_xmm0_xmm1(elf_ctx);
}

/** x86：pshufd xmm1, xmm0, imm8（66 0F 70 C8 imm）。 */
static int32_t simd_x86_pshufd_xmm1_xmm0(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t imm) {
    static const uint8_t prefix[3] = {0x66, 0x0f, 0x70};
    if (simd_append(elf_ctx, prefix, 3) != 0)
        return -1;
    {
        static const uint8_t modrm[1] = {0xc8};
        if (simd_append(elf_ctx, modrm, 1) != 0)
            return -1;
    }
    return simd_append(elf_ctx, &imm, 1);
}

/**
 * x86：xmm0 内 4×f32 归约为标量（低 lane = 四 lane 之和）。
 * pshufd/addps 三指令序列（无栈 spill，避免大栈帧下 RSP 破坏）。
 */
int32_t simd_enc_x86_horizontal_addps_xmm0(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    if (!elf_ctx)
        return -1;
    if (simd_x86_pshufd_xmm1_xmm0(elf_ctx, 0xee) != 0)
        return -1;
    if (simd_x86_addps_xmm0_xmm1(elf_ctx) != 0)
        return -1;
    if (simd_x86_pshufd_xmm1_xmm0(elf_ctx, 0x55) != 0)
        return -1;
    return simd_x86_addps_xmm0_xmm1(elf_ctx);
}

/** x86：movss xmm0 → [rbp+disp32]（f32 标量写回累加槽）。 */
int32_t simd_enc_x86_movss_xmm0_rbp_disp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t disp) {
    static const uint8_t prefix[3] = {0xf3, 0x0f, 0x11};
    if (!elf_ctx)
        return -1;
    if (simd_append(elf_ctx, prefix, 3) != 0)
        return -1;
    {
        static const uint8_t modrm[1] = {0x85};
        if (simd_append(elf_ctx, modrm, 1) != 0)
            return -1;
    }
    return simd_append_disp32(elf_ctx, disp);
}

/**
 * f32 SoA 列：movups xmm1, [col0 + i*4]（col0 为 x[0] 栈正偏移，i 在 rbp+off_i）。
 */
int32_t simd_enc_f32_soa_col_movups_xmm1_at_idx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off_col0,
                                                int32_t off_i, int32_t ta) {
    if (!elf_ctx || off_col0 < 0 || off_i < 0 || ta != 0)
        return -1;
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta) != 0)
        return -1;
    if (backend_enc_lea_rbp_to_rbx_arch(elf_ctx, off_col0, ta) != 0)
        return -1;
    {
        /** legacy SSE：movups xmm1, [rbx+rax*4]（0F 10 0C 83；勿 VEX C5 前缀）。 */
        static const uint8_t insn[4] = {0x0f, 0x10, 0x0c, 0x83};
        if (simd_append(elf_ctx, insn, 4) != 0)
            return -1;
    }
    return 0;
}
