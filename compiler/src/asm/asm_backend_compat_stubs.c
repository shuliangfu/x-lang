/**
 * asm_backend_compat_stubs.c — pipeline_glue 与 asm_backend_partial.o 的符号桥
 *
 * pipeline_glue.c（编入 pipeline_su.o）仍引用若干 backend_* 名，全量 asm.su -E 后部分已改名或未导出；
 * 本 TU 提供薄转发，使 bootstrap-driver-seed / shu_stage2 在 macOS arm64 上可链通。
 */
#include <stdint.h>

struct platform_elf_ElfCodegenCtx;
struct ast_ASTArena;

/** 与 backend.su AsmFuncCtx 前缀一致，供 block_slot_base_for 读 num_locals。 */
struct backend_AsmFuncCtx {
  int32_t frame_size;
  int32_t next_offset;
  int32_t num_locals;
};

/* asm_full.o / partial.o */
extern int32_t backend_emit_expr_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                     int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t backend_enc_mov_rax_to_arg_reg_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k,
                                                  int32_t ta);
extern int32_t backend_enc_cltd_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_idiv_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_edx_to_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern void backend_fill_local_slots(struct backend_AsmFuncCtx *ctx, struct ast_ASTArena *arena, int32_t block_ref);

/* ast_pool / pipeline 生成体 */
extern int32_t pipeline_expr_call_arg_ref(void *arena, int32_t expr_ref, int32_t idx);
extern int32_t ast_ast_block_num_consts(struct ast_ASTArena *a, int32_t br);
extern int32_t ast_ast_block_num_lets(struct ast_ASTArena *a, int32_t br);

/* partial.o 额外导出（build_seed_asm_host.sh SYMS 须含下列 arch_*） */
extern int32_t arch_arm64_enc_enc_mov_imm32_to_w0(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32);
extern int32_t arch_x86_64_enc_enc_ret_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32);
extern int32_t arch_riscv64_enc_enc_ret_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32);

/**
 * 慢路径与快路径合一：全量 backend 仅保留 backend_emit_expr_elf。
 */
int32_t backend_emit_expr_elf_slow(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                   int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  return backend_emit_expr_elf(arena, elf_ctx, expr_ref, ctx, ta);
}

/**
 * 将 imm32 装入“结果寄存器”（arm64 w0 / x86 eax / riscv a0）。
 */
int32_t backend_enc_mov_imm32_to_w0_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_mov_imm32_to_w0(elf_ctx, imm32);
  if (ta == 2)
    return arch_riscv64_enc_enc_ret_imm32(elf_ctx, imm32);
  return arch_x86_64_enc_enc_ret_imm32(elf_ctx, imm32);
}

/** 登记块内 const/let 栈槽（转发 fill_local_slots）。 */
void backend_ensure_block_local_slots(struct backend_AsmFuncCtx *ctx, struct ast_ASTArena *arena, int32_t block_ref) {
  backend_fill_local_slots(ctx, arena, block_ref);
}

/**
 * 块内局部起始槽下标（与 backend.su emit_block_body_elf 一致）。
 */
int32_t backend_block_slot_base_for(struct backend_AsmFuncCtx *ctx, struct ast_ASTArena *arena, int32_t block_ref) {
  int32_t nconst;
  int32_t nlet;
  int32_t slot_base;
  if (!ctx || !arena || block_ref <= 0)
    return 0;
  nconst = ast_ast_block_num_consts(arena, block_ref);
  nlet = ast_ast_block_num_lets(arena, block_ref);
  slot_base = ctx->num_locals - nconst - nlet;
  return slot_base < 0 ? 0 : slot_base;
}

/**
 * ARM64 单 call 实参：emit 表达式再 mov 到第 arg_idx 个参数寄存器。
 */
int32_t backend_asm_emit_one_call_arg_elf_arm64_push(void *arena, void *elf_ctx, int32_t expr_ref, int32_t arg_idx,
                                                     void *ctx, int32_t ta) {
  int32_t arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx);
  if (arg_ref == 0)
    return 0;
  if (backend_emit_expr_elf((struct ast_ASTArena *)arena, (struct platform_elf_ElfCodegenCtx *)elf_ctx, arg_ref,
                            (struct backend_AsmFuncCtx *)ctx, ta) != 0)
    return -1;
  return backend_enc_mov_rax_to_arg_reg_arch((struct platform_elf_ElfCodegenCtx *)elf_ctx, arg_idx, ta);
}
