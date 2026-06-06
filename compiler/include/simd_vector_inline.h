/**
 * simd_vector_inline.h — M8-tail：SIMD 向量 intrinsic let-init 内联 C API（SU 薄包装 bl 目标）。
 */
#ifndef SHU_SIMD_VECTOR_INLINE_H
#define SHU_SIMD_VECTOR_INLINE_H

#include <stdint.h>

struct ast_ASTArena;
struct platform_elf_ElfCodegenCtx;
struct backend_AsmFuncCtx;

/** shuffle / @shuffle / vec*_shuffle → pshufd；1=已内联，0=未匹配，-1=错误。 */
int32_t pipeline_asm_simd_try_inline_shuffle_call_elf_c(struct ast_ASTArena *arena,
                                                          struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                          int32_t call_ref, struct backend_AsmFuncCtx *ctx,
                                                          int32_t ta, int32_t stack_slot_off, int32_t type_ref);

/** select / @select / vec*_select → blend；1=已内联，0=未匹配，-1=错误。 */
int32_t pipeline_asm_simd_try_inline_select_call_elf_c(struct ast_ASTArena *arena,
                                                       struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                       int32_t call_ref, struct backend_AsmFuncCtx *ctx,
                                                       int32_t ta, int32_t stack_slot_off, int32_t type_ref);

/** vec*_add 等两参向量 binop CALL 内联；1=已内联，0=未匹配，-1=错误。 */
int32_t pipeline_asm_simd_try_inline_binop2_call_elf_c(struct ast_ASTArena *arena,
                                                       struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                       int32_t call_ref, struct backend_AsmFuncCtx *ctx,
                                                       int32_t ta, int32_t stack_slot_off, int32_t type_ref);

#endif /* SHU_SIMD_VECTOR_INLINE_H */
