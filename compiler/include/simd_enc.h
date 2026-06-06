/**
 * simd_enc.h — SIMD-S3：硬件向量指令编码（x86 SSE/AVX2、arm64 NEON 预留）。
 *
 * 供 pipeline_glue 在向量 let 初值 binop 路径调用；lane-scalar 回退仍保留。
 */
#ifndef SHU_SIMD_ENC_H
#define SHU_SIMD_ENC_H

#include <stdint.h>

struct platform_elf_ElfCodegenCtx;

/**
 * 尝试发射整型向量寄存器 add（local VAR + VAR → dst 栈槽）。
 * @param slot_off_a/b/dst  向量槽高端 rbp 正偏移（与 glue vector lane 一致）
 * @param lanes             4 或 8
 * @param esz               元素字节（4=i32/f32）
 * @param ta                0=x86_64，1=arm64
 * @param cpu_features      SIMD-S1 feature 掩码
 * @return 0=已发射硬件指令，-1=不支持/回退 lane-scalar
 */
int32_t simd_enc_try_hw_vector_iadd_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t slot_off_a,
                                        int32_t slot_off_b, int32_t slot_off_dst, int32_t lanes, int32_t esz,
                                        int32_t ta, uint32_t cpu_features);

/**
 * 整型向量 sub（Vec8i / i32x8）；x86 psubd / vpsubd。
 */
int32_t simd_enc_try_hw_vector_isub_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t slot_off_a,
                                        int32_t slot_off_b, int32_t slot_off_dst, int32_t lanes, int32_t esz,
                                        int32_t ta, uint32_t cpu_features);

/**
 * 整型向量 mul（Vec8i / i32x8）；x86 SSE4.1 pmulld / AVX2 vpmulld。
 */
int32_t simd_enc_try_hw_vector_imul_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t slot_off_a,
                                        int32_t slot_off_b, int32_t slot_off_dst, int32_t lanes, int32_t esz,
                                        int32_t ta, uint32_t cpu_features);

/**
 * f32 向量 add（Vec4f / f32x4）；x86 addps / arm64 fadd.4s。
 */
int32_t simd_enc_try_hw_vector_fadd_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t slot_off_a,
                                        int32_t slot_off_b, int32_t slot_off_dst, int32_t lanes, int32_t esz,
                                        int32_t ta, uint32_t cpu_features);

/**
 * f32 向量 mul（Vec4f / f32x4）；x86 mulps。
 */
int32_t simd_enc_try_hw_vector_fmul_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t slot_off_a,
                                        int32_t slot_off_b, int32_t slot_off_dst, int32_t lanes, int32_t esz,
                                        int32_t ta, uint32_t cpu_features);

/**
 * 在动态下标 i 处发射整型向量 binop（[a[i..i+lanes)] op [b[...]] → dst[...]）。
 * @param off_i  归纳变量 i 的 rbp 槽偏移
 * @param array_n  定长数组 compile-time 元素个数（用于 elem0 基址）
 * @param binop_ko 4=ADD / 5=SUB / 6=MUL
 */
int32_t simd_enc_try_hw_vector_binop_rbp_at_idx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off_a,
                                                int32_t off_b, int32_t off_d, int32_t off_i, int32_t array_n,
                                                int32_t binop_ko, int32_t lanes, int32_t esz, int32_t ta,
                                                uint32_t cpu_features);

/**
 * comptime shuffle：pshufd/vpshufd imm8（lane 索引 0..3 每 128-bit 半幅）。
 * @param imm8  x86 pshufd 控制字节（每 2 bit 选一个源 lane）
 */
int32_t simd_enc_try_pshufd_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t slot_off_src,
                                int32_t slot_off_dst, int32_t imm8, int32_t lanes, int32_t ta,
                                uint32_t cpu_features);

/**
 * 向量 select：mask lane 为 0/1（或 f32 0.0/1.0）时 dst = mask?a:b。
 * x86：pcmpgtd/pand/pandn/por（i32）或 cmpgtps/andps/andnps/orps（f32）。
 */
int32_t simd_enc_try_hw_vector_select_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t slot_off_mask,
                                          int32_t slot_off_a, int32_t slot_off_b, int32_t slot_off_dst,
                                          int32_t lanes, int32_t is_f32, int32_t ta, uint32_t cpu_features);

/** x86：xorps xmm0, xmm0。 */
int32_t simd_enc_x86_xorps_xmm0_zero(struct platform_elf_ElfCodegenCtx *elf_ctx);

/** x86：movups xmm1, [rbp+disp32]。 */
int32_t simd_enc_x86_movups_xmm1_rbp_disp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t disp);

/** x86：addps xmm0, xmm1。 */
int32_t simd_enc_x86_addps_xmm0_xmm1(struct platform_elf_ElfCodegenCtx *elf_ctx);

/** x86：xmm0 四 lane f32 水平求和 → 低 lane。 */
int32_t simd_enc_x86_horizontal_addps_xmm0(struct platform_elf_ElfCodegenCtx *elf_ctx);

/** x86：movss xmm0 → [rbp+disp32]。 */
int32_t simd_enc_x86_movss_xmm0_rbp_disp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t disp);

/** f32 SoA 列：movups xmm1, [x[i..i+3]]。 */
int32_t simd_enc_f32_soa_col_movups_xmm1_at_idx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off_col0,
                                                int32_t off_i, int32_t ta);

#endif /* SHU_SIMD_ENC_H */
