/**
 * simd_loop.h — SIMD-S3：counted loop 矢量化（固定数组 index-add 剥离）。
 */
#ifndef SHU_SIMD_LOOP_H
#define SHU_SIMD_LOOP_H

#include <stdint.h>

struct ast_ASTArena;
struct ast_Module;
struct platform_elf_ElfCodegenCtx;
struct backend_AsmFuncCtx;

/**
 * 尝试将 `while i < n { dst[i]=a[i](+|-|*)b[i]; i=i+1/i+=1 }` 矢量化：
 * - 编译期 n（字面量或 let n=K）且 n%lanes==0 → 整段 peel；
 * - 否则 n 为局部变量 → 条带主循环 + 标量 epilogue。
 * @return 1=已发射并跳过原 loop，0=未匹配，-1=错误
 */
int32_t glue_try_simd_peel_f32_soa_sum_while_elf_c(struct ast_ASTArena *arena,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t block_ref,
                                                   int32_t loop_idx, struct backend_AsmFuncCtx *ctx, int32_t ta);

int32_t glue_try_simd_peel_index_add_while_elf_c(struct ast_ASTArena *arena,
                                                 struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t block_ref,
                                                 int32_t loop_idx, struct backend_AsmFuncCtx *ctx, int32_t ta);

#endif /* SHU_SIMD_LOOP_H */
