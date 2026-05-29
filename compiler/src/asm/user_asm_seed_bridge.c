/**
 * user_asm_seed_bridge.c — bootstrap-driver-seed 用户程序 asm 后端桥
 *
 * pipeline_su.o（-E-extern 瘦编排）经 extern 调用 asm_asm_codegen_ast / asm_asm_codegen_elf_o；
 * 本文件提供强符号实现，并链入 build_asm/seed_host/asm_backend_partial.o（shu-c -E asm.su 抽出）。
 * 无 C codegen 回退、无 cc -c 汇编 GAS 兜底：asm 失败即返回错误。
 */
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

/** 与 pipeline 生成体一致的 CodegenOutBuf 布局。 */
struct codegen_CodegenOutBuf {
  uint8_t data[8388608];
  int32_t len;
};

struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;
struct platform_elf_ElfCodegenCtx;

/** pipeline_su.o / ast_pool.c（勿在此 TU 自建截断 PipelineDepCtx，含 4MiB 内嵌缓冲） */
extern int32_t pipeline_dep_ctx_use_macho_o(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_dep_ctx_asm_entry_module_only(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern struct ast_Module *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern struct ast_ASTArena *pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern void pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *dst);
extern int32_t pipeline_module_num_funcs(struct ast_Module *m);
extern void driver_set_current_dep_path_for_codegen(const char *path);
extern int32_t driver_skip_codegen_dep_0_get(void);
/** std.io 族由 io.o + 本文件桩提供；seed asm 跳过整族 dep 的机器码生成。 */
extern int32_t pipeline_codegen_dep_skip_asm_user_std_io(uint8_t *path);
extern int32_t pipeline_expr_call_arg_ref(void *arena, int32_t expr_ref, int32_t idx);

struct ast_Expr;

extern struct ast_Expr *pipeline_arena_expr_ptr(struct ast_ASTArena *a, int32_t expr_ref);

/** EXPR_FLOAT_LIT 的 float_val；供 asm 后端 emit 时重算位模式（strict_core 旧 glue 无此路径）。 */
double pipeline_expr_float_val_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *p;
  if (!a || expr_ref <= 0)
    return 0.0;
  p = pipeline_arena_expr_ptr(a, expr_ref);
  if (!p)
    return 0.0;
  /** 与 ast_Expr 布局一致：kind..int_val(16) + pad(4) → float_val @ +24。 */
  return *(double *)((char *)p + 24);
}

/** ast.su extern 前缀转发。 */
double ast_pipeline_expr_float_val_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_float_val_at(a, expr_ref);
}

/** build_asm/seed_host/asm_backend_partial.o（asm.su 全量 -E 抽出） */
extern int32_t backend_asm_emit_one_call_arg_elf_arm64_push(void *arena, void *elf_ctx, int32_t expr_ref, int32_t arg_idx, void *ctx, int32_t ta);

/**
 * ARM64 ELF call 实参 push 阶段：宿主 C for 循环逐参调用 backend，避免 .su 递归/展开叠加深 emit 栈帧 SIGSEGV。
 */
int32_t pipeline_seed_asm_emit_call_args_elf_arm64_push_loop(void *arena, void *elf_ctx, int32_t expr_ref, int32_t reg_n, void *ctx, int32_t ta) {
  int32_t i;
  for (i = 0; i < reg_n; i++) {
    if (getenv("SHU_ASM_DEBUG")) {
      int32_t arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, i);
      fprintf(stderr, "shu: arm64_push_loop i=%d reg_n=%d call_ref=%d arg_ref=%d\n",
              (int)i, (int)reg_n, (int)expr_ref, (int)arg_ref);
      fflush(stderr);
    }
    if (backend_asm_emit_one_call_arg_elf_arm64_push(arena, elf_ctx, expr_ref, i, ctx, ta) != 0)
      return -1;
  }
  return 0;
}

/** ast.su -E 前缀转发（backend partial.o 经 ast_pipeline_* 调用）。 */
int32_t ast_pipeline_seed_asm_emit_call_args_elf_arm64_push_loop(void *arena, void *elf_ctx, int32_t expr_ref, int32_t reg_n, void *ctx, int32_t ta) {
  return pipeline_seed_asm_emit_call_args_elf_arm64_push_loop(arena, elf_ctx, expr_ref, reg_n, ctx, ta);
}

/** build_asm/seed_host/asm_backend_partial.o（asm.su 全量 -E 抽出） */
extern int32_t backend_asm_codegen_ast(void *module, void *arena, void *out_buf, void *ctx);
extern int32_t backend_asm_codegen_ast_to_elf(void *module, void *arena, void *elf_ctx, void *ctx);
extern int32_t peephole_run(void *out_buf);
extern int32_t peephole_elf_run(void *elf_ctx);
extern void platform_elf_elf_ctx_reset(void *elf_ctx);
extern int32_t platform_elf_elf_resolve_patches(void *elf_ctx);
extern int32_t platform_elf_write_elf_o_to_buf(void *elf_ctx, void *out_buf);
extern int32_t platform_macho_write_macho_o_to_buf(void *elf_ctx, void *out_buf);

/** .su 模块名修饰后的 pipeline_module_num_funcs 转发（asm/backend 分 TU 链接）。 */
int32_t asm_pipeline_module_num_funcs(struct ast_Module *m) {
  return pipeline_module_num_funcs(m);
}
int32_t backend_pipeline_module_num_funcs(struct ast_Module *m) {
  return pipeline_module_num_funcs(m);
}

/**
 * pipeline 调用的 asm 文本 codegen：backend 产出 GAS，再窥孔优化。
 * 任一步失败返回 -1。
 */
int32_t asm_asm_codegen_ast(void *module, void *arena, void *out_buf, void *ctx) {
  if (backend_asm_codegen_ast(module, arena, out_buf, ctx) != 0)
    return -1;
  if (peephole_run(out_buf) != 0)
    return -1;
  return 0;
}

/**
 * 写出 -o .o / -o exe：先各 dep 再入口（与 asm.su::asm_codegen_elf_o 一致），再 reloc + 写 Mach-O/ELF。
 */
int32_t asm_asm_codegen_elf_o(void *module, void *arena, void *ctx, void *elf_ctx, void *out_buf) {
  struct ast_PipelineDepCtx *pctx = (struct ast_PipelineDepCtx *)ctx;
  int32_t jdep;
  int32_t ndep_elf;

  if (elf_ctx)
    platform_elf_elf_ctx_reset(elf_ctx);
  if (pctx && pipeline_dep_ctx_asm_entry_module_only(pctx) == 0) {
    ndep_elf = pipeline_dep_ctx_ndep(pctx);
    for (jdep = 0; jdep < ndep_elf; jdep++) {
      struct ast_Module *dep_mod;
      struct ast_ASTArena *dep_ar;
      uint8_t dep_path_buf[64];
      int pk;
      int dup;
      if (jdep == 0 && driver_skip_codegen_dep_0_get() != 0)
        continue;
      dep_mod = pipeline_dep_ctx_module_at(pctx, jdep);
      if (dep_mod == (struct ast_Module *)module)
        continue;
      dup = 0;
      for (pk = 0; pk < jdep; pk++) {
        if (pipeline_dep_ctx_module_at(pctx, pk) == dep_mod) {
          dup = 1;
          break;
        }
      }
      if (dup)
        continue;
      memset(dep_path_buf, 0, sizeof(dep_path_buf));
      pipeline_dep_ctx_import_path_copy64(pctx, jdep, dep_path_buf);
      /** std.io 族：符号由 io.o + 本 TU 桩提供，避免整库 asm emit 导致宿主 Abort。 */
      if (pipeline_codegen_dep_skip_asm_user_std_io(dep_path_buf) != 0)
        continue;
      driver_set_current_dep_path_for_codegen((const char *)dep_path_buf);
      dep_ar = pipeline_dep_ctx_arena_at(pctx, jdep);
      if (dep_mod != NULL && dep_ar != NULL && pipeline_module_num_funcs(dep_mod) > 0) {
        if (backend_asm_codegen_ast_to_elf(dep_mod, dep_ar, elf_ctx, ctx) != 0) {
          driver_set_current_dep_path_for_codegen(NULL);
          return -1;
        }
      }
      driver_set_current_dep_path_for_codegen(NULL);
    }
  }
  driver_set_current_dep_path_for_codegen(NULL);
  if (backend_asm_codegen_ast_to_elf(module, arena, elf_ctx, ctx) != 0)
    return -1;
  if (elf_ctx && peephole_elf_run(elf_ctx) != 0)
    return -1;
  if (elf_ctx && platform_elf_elf_resolve_patches(elf_ctx) != 0)
    return -1;
  if (pctx && pipeline_dep_ctx_use_macho_o(pctx) != 0)
    return platform_macho_write_macho_o_to_buf(elf_ctx, out_buf) < 0 ? -1 : 0;
  return platform_elf_write_elf_o_to_buf(elf_ctx, out_buf) < 0 ? -1 : 0;
}
