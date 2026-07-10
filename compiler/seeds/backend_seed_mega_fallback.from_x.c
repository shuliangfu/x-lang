/* seeds/backend_seed_mega_fallback.from_x.c — G-02f-80 product cold-start TU
 * Promoted from compiler/src/asm/backend_seed_mega_fallback.inc (stub/bridge; retired .inc).
 * Compile: cc -c / cc_inc_tu seeds/backend_seed_mega_fallback.from_x.c
 */
#include <stdint.h>
#include <string.h>

#include "runtime_pipeline_abi.h"

struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;
struct codegen_CodegenOutBuf;
struct platform_elf_ElfCodegenCtx;
struct backend_AsmFuncCtx;

typedef struct {
  int32_t frame_size;
  int32_t next_offset;
  int32_t num_locals;
  int32_t label_counter;
  struct ast_Module *module_ref;
  uint8_t loop_break_label_stack[512];
  int32_t loop_break_len_stack[8];
  uint8_t loop_continue_label_stack[512];
  int32_t loop_continue_len_stack[8];
  uint8_t break_label[64];
  int32_t break_len;
  uint8_t continue_label[64];
  int32_t continue_len;
  int32_t loop_label_depth;
  void *dep_pipe;
  uint8_t tail_join_label[64];
  int32_t tail_join_label_len;
} pipeline_glue_AsmFuncCtxLayout;

extern void pipeline_module_hoist_top_level_lets_into_main(struct ast_Module *m, struct ast_ASTArena *a);
extern void pipeline_asm_emit_set_dep_pipe(struct ast_PipelineDepCtx *ctx);
extern void pipeline_asm_emit_set_module(struct ast_Module *m);
extern void pipeline_asm_emit_set_arena(struct ast_ASTArena *arena);
extern void pipeline_asm_emit_set_func_index(int32_t func_index);
extern int32_t pipeline_module_num_funcs(struct ast_Module *m);
extern int32_t pipeline_asm_module_func_is_extern_at(struct ast_Module *m, int32_t func_index);
extern int32_t pipeline_asm_wpo_should_emit_func(struct ast_Module *m, int32_t fi);
extern void pipeline_asm_module_func_name_copy64(struct ast_Module *m, int32_t func_index, uint8_t *dst);
extern int32_t pipeline_asm_module_func_name_len_at(struct ast_Module *m, int32_t func_index);
extern int32_t pipeline_asm_module_func_body_ref_at(struct ast_Module *m, int32_t func_index);
extern int32_t pipeline_asm_module_func_num_params_at(struct ast_Module *m, int32_t func_index);
extern int32_t pipeline_asm_block_num_stmt_order_at(struct ast_ASTArena *a, int32_t br);
extern int32_t pipeline_asm_get_return_expr_ref_at(struct ast_ASTArena *a, struct ast_Module *m, int32_t func_index);
extern int32_t pipeline_asm_compute_frame_size_c(int32_t num_params, struct ast_ASTArena *arena, int32_t block_ref,
                                                 struct ast_Module *mod, int32_t func_index);
extern void pipeline_asm_fill_param_slots(struct backend_AsmFuncCtx *ctx, struct ast_Module *mod, int32_t func_index);
extern void pipeline_asm_fill_local_slots(struct backend_AsmFuncCtx *ctx, struct ast_ASTArena *arena, int32_t block_ref);
extern int32_t pipeline_asm_emit_next_label_c(struct backend_AsmFuncCtx *ctx, uint8_t *buf, int32_t buf_size);
extern int32_t pipeline_asm_emit_block_body_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                              int32_t block_ref, struct backend_AsmFuncCtx *ctx, int32_t target_arch);
extern int32_t pipeline_asm_emit_block_inits_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                               int32_t block_ref, struct backend_AsmFuncCtx *ctx, int32_t target_arch,
                                               int32_t slot_base);
extern int32_t pipeline_asm_emit_expr_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out, int32_t expr_ref,
                                        struct backend_AsmFuncCtx *ctx, int32_t target_arch);
extern int32_t backend_arch_emit_section_text(struct codegen_CodegenOutBuf *out, int32_t ta);
extern int32_t backend_arch_emit_globl(struct codegen_CodegenOutBuf *out, uint8_t *name, int32_t name_len, int32_t ta);
extern int32_t backend_arch_emit_label(struct codegen_CodegenOutBuf *out, uint8_t *name, int32_t name_len, int32_t ta);
extern int32_t backend_arch_emit_prologue(struct codegen_CodegenOutBuf *out, int32_t frame_sz, int32_t ta);
extern int32_t backend_arch_emit_epilogue(struct codegen_CodegenOutBuf *out, int32_t frame_sz, int32_t ta);
extern int32_t ast_ast_block_num_consts(struct ast_ASTArena *a, int32_t br);
extern int32_t ast_ast_block_num_lets(struct ast_ASTArena *a, int32_t br);
extern void driver_diagnostic_asm_set_current_func(const uint8_t *name, int32_t len);
extern void driver_diagnostic_asm_fail_at(int32_t loc);
extern int32_t pipeline_backend_asm_codegen_ast_to_elf_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                         struct ast_PipelineDepCtx *ctx);

static void pipeline_seed_mega_ctx_reset(pipeline_glue_AsmFuncCtxLayout *ctx, struct ast_Module *mod) {
  int32_t label_counter;
  if (!ctx)
    return;
  label_counter = ctx->label_counter;
  memset(ctx, 0, sizeof(*ctx));
  ctx->label_counter = label_counter;
  ctx->module_ref = mod;
}

static int32_t pipeline_dep_ctx_target_arch_local(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->target_arch : 0;
}

int32_t backend_asm_codegen_ast_seed_mega(struct ast_Module *module, struct ast_ASTArena *arena,
                                          struct codegen_CodegenOutBuf *out,
                                          struct ast_PipelineDepCtx *pipeline_ctx) {
  pipeline_glue_AsmFuncCtxLayout ctx;
  uint8_t fname_buf[64];
  int32_t ta;
  int32_t i;

  if (!module || !arena || !out || !pipeline_ctx)
    return -1;
  pipeline_module_hoist_top_level_lets_into_main(module, arena);
  ta = pipeline_dep_ctx_target_arch_local(pipeline_ctx);
  memset(&ctx, 0, sizeof(ctx));
  pipeline_asm_emit_set_dep_pipe(pipeline_ctx);
  pipeline_asm_emit_set_module(module);
  pipeline_asm_emit_set_arena(arena);
  for (i = 0; i < pipeline_module_num_funcs(module); i++) {
    int32_t body_ref;
    int32_t frame_sz;
    int32_t result_ref;

    if (i == 0) {
      if (backend_arch_emit_section_text(out, ta) != 0) {
        driver_diagnostic_asm_fail_at(1);
        return -1;
      }
    }
    if (pipeline_asm_module_func_is_extern_at(module, i) != 0)
      continue;
    if (pipeline_asm_wpo_should_emit_func(module, i) == 0)
      continue;
    pipeline_asm_module_func_name_copy64(module, i, fname_buf);
    driver_diagnostic_asm_set_current_func(fname_buf, pipeline_asm_module_func_name_len_at(module, i));
    pipeline_asm_emit_set_func_index(i);
    pipeline_seed_mega_ctx_reset(&ctx, module);
    ctx.dep_pipe = pipeline_ctx;
    pipeline_asm_fill_param_slots((struct backend_AsmFuncCtx *)&ctx, module, i);
    if (backend_arch_emit_globl(out, fname_buf, pipeline_asm_module_func_name_len_at(module, i), ta) != 0) {
      driver_diagnostic_asm_fail_at(2);
      return -1;
    }
    if (backend_arch_emit_label(out, fname_buf, pipeline_asm_module_func_name_len_at(module, i), ta) != 0) {
      driver_diagnostic_asm_fail_at(3);
      return -1;
    }
    body_ref = pipeline_asm_module_func_body_ref_at(module, i);
    frame_sz = 0;
    if (body_ref != 0) {
      frame_sz = pipeline_asm_compute_frame_size_c(pipeline_asm_module_func_num_params_at(module, i), arena, body_ref,
                                                   module, i);
      if (pipeline_asm_block_num_stmt_order_at(arena, body_ref) == 0)
        pipeline_asm_fill_local_slots((struct backend_AsmFuncCtx *)&ctx, arena, body_ref);
    }
    if (backend_arch_emit_prologue(out, frame_sz, ta) != 0) {
      driver_diagnostic_asm_fail_at(4);
      return -1;
    }
    if (body_ref != 0) {
      int32_t slot_base;
      ctx.tail_join_label_len = pipeline_asm_emit_next_label_c((struct backend_AsmFuncCtx *)&ctx, ctx.tail_join_label, 64);
      if (ctx.tail_join_label_len <= 0) {
        driver_diagnostic_asm_fail_at(9);
        return -1;
      }
      if (pipeline_asm_block_num_stmt_order_at(arena, body_ref) > 0) {
        if (pipeline_asm_emit_block_body_c(arena, out, body_ref, (struct backend_AsmFuncCtx *)&ctx, ta) != 0) {
          driver_diagnostic_asm_fail_at(5);
          return -1;
        }
      } else {
        slot_base = ctx.num_locals - ast_ast_block_num_consts(arena, body_ref) - ast_ast_block_num_lets(arena, body_ref);
        if (slot_base < 0) {
          driver_diagnostic_asm_fail_at(6);
          return -1;
        }
        if (pipeline_asm_emit_block_inits_c(arena, out, body_ref, (struct backend_AsmFuncCtx *)&ctx, ta, slot_base) != 0) {
          driver_diagnostic_asm_fail_at(6);
          return -1;
        }
      }
      if (backend_arch_emit_label(out, ctx.tail_join_label, ctx.tail_join_label_len, ta) != 0) {
        driver_diagnostic_asm_fail_at(9);
        return -1;
      }
    }
    result_ref = 0;
    if (body_ref == 0 || pipeline_asm_block_num_stmt_order_at(arena, body_ref) == 0)
      result_ref = pipeline_asm_get_return_expr_ref_at(arena, module, i);
    if (result_ref != 0) {
      if (pipeline_asm_emit_expr_c(arena, out, result_ref, (struct backend_AsmFuncCtx *)&ctx, ta) != 0) {
        driver_diagnostic_asm_fail_at(7);
        return -1;
      }
    }
    if (backend_arch_emit_epilogue(out, frame_sz, ta) != 0) {
      driver_diagnostic_asm_fail_at(8);
      return -1;
    }
  }
  return 0;
}

int32_t backend_asm_codegen_ast_to_elf_seed_mega(struct ast_Module *module, struct ast_ASTArena *arena,
                                                 struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                 struct ast_PipelineDepCtx *ctx) {
  return pipeline_backend_asm_codegen_ast_to_elf_c(module, arena, elf_ctx, ctx);
}

int32_t backend_asm_codegen_ast(struct ast_Module *module, struct ast_ASTArena *arena,
                                struct codegen_CodegenOutBuf *out, struct ast_PipelineDepCtx *ctx) {
  return backend_asm_codegen_ast_seed_mega(module, arena, out, ctx);
}

int32_t backend_asm_codegen_ast_to_elf(struct ast_Module *module, struct ast_ASTArena *arena,
                                       struct platform_elf_ElfCodegenCtx *elf_ctx,
                                       struct ast_PipelineDepCtx *ctx) {
  return backend_asm_codegen_ast_to_elf_seed_mega(module, arena, elf_ctx, ctx);
}

/*
 * fallback partial 只保证 seed 链可链接并保留强 seed_mega；
 * 与本地已存在的 asm_backend_partial.o 一致，补齐 phase1 仍会引用的 backend_emit_* 弱占位符。
 */
__attribute__((weak)) int32_t backend_emit_block_body(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                                      int32_t block_ref, struct backend_AsmFuncCtx *ctx,
                                                      int32_t target_arch) {
  (void)arena;
  (void)out;
  (void)block_ref;
  (void)ctx;
  (void)target_arch;
  return 0;
}

__attribute__((weak)) int32_t backend_emit_block_inits(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                                       int32_t block_ref, struct backend_AsmFuncCtx *ctx,
                                                       int32_t target_arch, int32_t slot_base) {
  (void)arena;
  (void)out;
  (void)block_ref;
  (void)ctx;
  (void)target_arch;
  (void)slot_base;
  return 0;
}

__attribute__((weak)) int32_t backend_emit_expr(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                                int32_t expr_ref, struct backend_AsmFuncCtx *ctx,
                                                int32_t target_arch) {
  (void)arena;
  (void)out;
  (void)expr_ref;
  (void)ctx;
  (void)target_arch;
  return 0;
}

__attribute__((weak)) int32_t backend_emit_expr_call(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                                     int32_t expr_ref, void *expr_copy,
                                                     struct backend_AsmFuncCtx *ctx, int32_t target_arch) {
  (void)arena;
  (void)out;
  (void)expr_ref;
  (void)expr_copy;
  (void)ctx;
  (void)target_arch;
  return 0;
}

__attribute__((weak)) int32_t backend_emit_expr_elf(struct ast_ASTArena *arena,
                                                    struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                    struct backend_AsmFuncCtx *ctx, int32_t ta) {
  (void)arena;
  (void)elf_ctx;
  (void)expr_ref;
  (void)ctx;
  (void)ta;
  return 0;
}

__attribute__((weak)) int32_t backend_emit_expr_method_call(struct ast_ASTArena *arena,
                                                            struct codegen_CodegenOutBuf *out, int32_t expr_ref,
                                                            void *expr_copy, struct backend_AsmFuncCtx *ctx,
                                                            int32_t target_arch) {
  (void)arena;
  (void)out;
  (void)expr_ref;
  (void)expr_copy;
  (void)ctx;
  (void)target_arch;
  return 0;
}

__attribute__((weak)) int32_t backend_emit_for_loop(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                                    int32_t block_ref, int32_t for_idx,
                                                    struct backend_AsmFuncCtx *ctx, int32_t target_arch) {
  (void)arena;
  (void)out;
  (void)block_ref;
  (void)for_idx;
  (void)ctx;
  (void)target_arch;
  return 0;
}

__attribute__((weak)) int32_t backend_emit_if_then_block_body_text(struct ast_ASTArena *arena,
                                                                   struct codegen_CodegenOutBuf *out,
                                                                   int32_t then_block_ref,
                                                                   struct backend_AsmFuncCtx *ctx,
                                                                   int32_t target_arch) {
  (void)arena;
  (void)out;
  (void)then_block_ref;
  (void)ctx;
  (void)target_arch;
  return 0;
}

__attribute__((weak)) int32_t backend_emit_loop_body_content(struct ast_ASTArena *arena,
                                                             struct codegen_CodegenOutBuf *out, int32_t body_ref,
                                                             struct backend_AsmFuncCtx *ctx, int32_t target_arch) {
  (void)arena;
  (void)out;
  (void)body_ref;
  (void)ctx;
  (void)target_arch;
  return 0;
}

__attribute__((weak)) int32_t backend_emit_while_loop(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                                      int32_t block_ref, int32_t loop_idx,
                                                      struct backend_AsmFuncCtx *ctx, int32_t target_arch) {
  (void)arena;
  (void)out;
  (void)block_ref;
  (void)loop_idx;
  (void)ctx;
  (void)target_arch;
  return 0;
}
