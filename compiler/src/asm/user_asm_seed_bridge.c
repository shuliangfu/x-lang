/**
 * user_asm_seed_bridge.c — bootstrap-driver-seed 用户程序 asm 后端桥
 *
 * pipeline_sx.o（-E-extern 瘦编排）经 extern 调用 asm_asm_codegen_ast / asm_asm_codegen_elf_o；
 * 本文件提供强符号实现，并链入 build_asm/seed_host/asm_backend_partial.o（shux-c -E asm.sx 抽出）。
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

/** pipeline_sx.o / ast_pool.c（勿在此 TU 自建截断 PipelineDepCtx，含 4MiB 内嵌缓冲） */
extern int32_t pipeline_dep_ctx_use_macho_o(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_dep_ctx_use_coff_o(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_dep_ctx_asm_entry_module_only(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern struct ast_Module *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern struct ast_ASTArena *pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern void pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *dst);
extern int32_t pipeline_module_num_funcs(struct ast_Module *m);
extern void pipeline_elf_ctx_diag_stderr(uint8_t *ctx_bytes);
extern void driver_set_current_dep_path_for_codegen(const char *path);
extern int32_t driver_skip_codegen_dep_0_get(void);
/** std.io 族由 io.o + 本文件桩提供；seed asm 跳过整族 dep 的机器码生成。 */
extern int32_t pipeline_codegen_dep_skip_asm_user_std_io(uint8_t *path);
extern int32_t pipeline_codegen_dep_skip_asm_user_std_fs(uint8_t *path);
extern int32_t pipeline_codegen_dep_skip_asm_user_std_process(uint8_t *path);
extern void pipeline_asm_seed_std_net_struct_layouts(struct ast_Module *m);
extern int32_t pipeline_asm_redirect_std_c_wrapper_sym(uint8_t *name, int32_t name_len, uint8_t *sym_out,
                                                         int32_t sym_cap);
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

/** ast.sx extern 前缀转发。 */
double ast_pipeline_expr_float_val_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_float_val_at(a, expr_ref);
}

/** build_asm/seed_host/asm_backend_partial.o（asm.sx 全量 -E 抽出） */
extern int32_t backend_asm_emit_one_call_arg_elf_arm64_push(void *arena, void *elf_ctx, int32_t expr_ref, int32_t arg_idx, void *ctx, int32_t ta);

/**
 * ARM64 ELF call 实参 push 阶段：宿主 C for 循环逐参调用 backend，避免 .sx 递归/展开叠加深 emit 栈帧 SIGSEGV。
 */
int32_t pipeline_seed_asm_emit_call_args_elf_arm64_push_loop(void *arena, void *elf_ctx, int32_t expr_ref, int32_t reg_n, void *ctx, int32_t ta) {
  int32_t i;
  for (i = 0; i < reg_n; i++) {
    if (getenv("SHUX_ASM_DEBUG")) {
      int32_t arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, i);
      fprintf(stderr, "shux: arm64_push_loop i=%d reg_n=%d call_ref=%d arg_ref=%d\n",
              (int)i, (int)reg_n, (int)expr_ref, (int)arg_ref);
      fflush(stderr);
    }
    if (backend_asm_emit_one_call_arg_elf_arm64_push(arena, elf_ctx, expr_ref, i, ctx, ta) != 0)
      return -1;
  }
  return 0;
}

/** ast.sx -E 前缀转发（backend partial.o 经 ast_pipeline_* 调用）。 */
int32_t ast_pipeline_seed_asm_emit_call_args_elf_arm64_push_loop(void *arena, void *elf_ctx, int32_t expr_ref, int32_t reg_n, void *ctx, int32_t ta) {
  return pipeline_seed_asm_emit_call_args_elf_arm64_push_loop(arena, elf_ctx, expr_ref, reg_n, ctx, ta);
}

/** build_asm/seed_host/asm_backend_partial.o（asm.sx 全量 -E 抽出） */
extern int32_t backend_asm_codegen_ast(void *module, void *arena, void *out_buf, void *ctx);
extern int32_t backend_asm_codegen_ast_to_elf(void *module, void *arena, void *elf_ctx, void *ctx);
extern int32_t peephole_run(void *out_buf);
extern int32_t peephole_elf_run(void *elf_ctx);
extern void platform_elf_elf_ctx_reset(void *elf_ctx);
/** ElfCodegenCtx.macho_leading_underscore 偏移（与 ast_pool.c kPipelineElfCtxMachoUnderscoreOff / elf.sx 4096 表一致）。 */
#define SHUX_ELF_CTX_MACHO_UNDERSCORE_OFF 598052

/** Darwin -o：call/reloc 符号须 leading `_`（与 asm.sx::asm_codegen_elf_o 一致）。 */
static void seed_elf_ctx_set_macho_leading_underscore(void *elf_ctx, int32_t on) {
  if (!elf_ctx)
    return;
  *(int32_t *)((uint8_t *)elf_ctx + SHUX_ELF_CTX_MACHO_UNDERSCORE_OFF) = on ? 1 : 0;
}
extern int32_t platform_elf_elf_resolve_patches(void *elf_ctx);
/** asm 失败时打印 backend.sx 记录的当前函数名。 */
extern void driver_diagnostic_asm_print_current_func(void);
extern int32_t pipeline_asm_patch_module_parent_links(struct ast_Module *m, struct ast_ASTArena *a);
extern void pipeline_asm_wpo_reach_compute_for_elf(struct ast_Module *entry, struct ast_ASTArena *entry_arena,
                                                     struct ast_PipelineDepCtx *ctx);
extern void pipeline_asm_wpo_reach_clear(void);
extern int32_t platform_elf_write_elf_o_to_buf(void *elf_ctx, void *out_buf);

/** 读 ElfCodegenCtx.code_len（前缀字段；与 platform/elf.sx / PipelineElfCtxAccess 一致）。 */
static int32_t seed_elf_ctx_code_len(const void *elf_ctx) {
  if (!elf_ctx)
    return 0;
  return *(const int32_t *)elf_ctx;
}

extern int32_t pipeline_elf_ctx_total_code_len(uint8_t *ctx_bytes);

/**
 * 用户 .o 须含非空 __text；code_len==0 时拒绝写出（避免 576B 空 .o + U main 误导 ld）。
 */
static int32_t seed_asm_reject_empty_elf_text(void *module, void *elf_ctx) {
  int32_t nf;
  int32_t clen;
  if (!module || !elf_ctx)
    return 0;
  nf = pipeline_module_num_funcs((struct ast_Module *)module);
  if (nf <= 0)
    return 0;
  clen = seed_elf_ctx_code_len(elf_ctx);
  if (clen > 0)
    return 0;
  if (pipeline_elf_ctx_total_code_len((uint8_t *)elf_ctx) > 0)
    return 0;
  fprintf(stderr, "shux: asm_codegen_elf_o: empty __text (code_len=0 num_funcs=%d)\n", (int)nf);
  pipeline_elf_ctx_diag_stderr((uint8_t *)elf_ctx);
  return -1;
}
extern int32_t platform_macho_write_macho_o_to_buf(void *elf_ctx, void *out_buf);
extern int32_t platform_coff_write_coff_o_to_buf(void *elf_ctx, void *out_buf);

/** .sx 模块名修饰后的 pipeline_module_num_funcs 转发（asm/backend 分 TU 链接）。 */
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
 * 写出 -o .o / -o exe：先各 dep 再入口（与 asm.sx::asm_codegen_elf_o 一致），再 reloc + 写 Mach-O/ELF。
 */
int32_t asm_asm_codegen_elf_o(void *module, void *arena, void *ctx, void *elf_ctx, void *out_buf) {
  struct ast_PipelineDepCtx *pctx = (struct ast_PipelineDepCtx *)ctx;
  int32_t jdep;
  int32_t ndep_elf;

  if (elf_ctx) {
    platform_elf_elf_ctx_reset(elf_ctx);
    if (pctx && pipeline_dep_ctx_use_macho_o(pctx) != 0)
      seed_elf_ctx_set_macho_leading_underscore(elf_ctx, 1);
    if (pctx && pipeline_dep_ctx_use_coff_o(pctx) != 0)
      seed_elf_ctx_set_macho_leading_underscore(elf_ctx, 1);
  }
  /** WPO v0：elf 全程序 emit 前构建 reach，供 backend 跳过 dead export。 */
  pipeline_asm_wpo_reach_compute_for_elf((struct ast_Module *)module, (struct ast_ASTArena *)arena, pctx);
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
      if (getenv("SHUX_ASM_EMIT_TRACE")) {
        fprintf(stderr, "shux: co-emit dep[%d] path=%s funcs=%d\n", (int)jdep, (char *)dep_path_buf,
                dep_mod ? (int)pipeline_module_num_funcs(dep_mod) : -1);
        fflush(stderr);
      }
      /** std.io 族：符号由 io.o + 本 TU 桩提供，避免整库 asm emit 导致宿主 Abort。 */
      if (pipeline_codegen_dep_skip_asm_user_std_io(dep_path_buf) != 0)
        continue;
      /** std.fs 族：符号由 fs.o 提供，勿整模块 asm emit（薄包装经 CALL redirect→fs.o）。 */
      if (pipeline_codegen_dep_skip_asm_user_std_fs(dep_path_buf) != 0)
        continue;
      /** std.process：符号由 process.o 提供，args_count/arg 经 CALL redirect。 */
      if (pipeline_codegen_dep_skip_asm_user_std_process(dep_path_buf) != 0)
        continue;
      driver_set_current_dep_path_for_codegen((const char *)dep_path_buf);
      dep_ar = pipeline_dep_ctx_arena_at(pctx, jdep);
      if (dep_mod != NULL && dep_ar != NULL && pipeline_module_num_funcs(dep_mod) > 0) {
        if (backend_asm_codegen_ast_to_elf(dep_mod, dep_ar, elf_ctx, ctx) != 0) {
          driver_set_current_dep_path_for_codegen(NULL);
          pipeline_asm_wpo_reach_clear();
          return -1;
        }
      }
      driver_set_current_dep_path_for_codegen(NULL);
    }
  }
  driver_set_current_dep_path_for_codegen(NULL);
  if (getenv("SHUX_ASM_EMIT_TRACE"))
    fprintf(stderr, "shux: asm_codegen_ast_to_elf entry module funcs=%d\n",
            (int)pipeline_module_num_funcs(module));
  pipeline_asm_patch_module_parent_links(module, arena);
  if (backend_asm_codegen_ast_to_elf(module, arena, elf_ctx, ctx) != 0) {
    if (getenv("SHUX_ASM_DEBUG")) {
      fprintf(stderr, "shux: asm_codegen_elf_o fail at backend entry\n");
      driver_diagnostic_asm_print_current_func();
    }
    pipeline_asm_wpo_reach_clear();
    return -1;
  }
  if (seed_asm_reject_empty_elf_text(module, elf_ctx) != 0) {
    pipeline_asm_wpo_reach_clear();
    return -1;
  }
  if (elf_ctx && peephole_elf_run(elf_ctx) != 0) {
    if (getenv("SHUX_ASM_DEBUG"))
      fprintf(stderr, "shux: asm_codegen_elf_o fail at peephole_elf\n");
    pipeline_asm_wpo_reach_clear();
    return -1;
  }
  if (elf_ctx && platform_elf_elf_resolve_patches(elf_ctx) != 0) {
    if (getenv("SHUX_ASM_DEBUG"))
      fprintf(stderr, "shux: asm_codegen_elf_o fail at resolve_patches\n");
    pipeline_asm_wpo_reach_clear();
    return -1;
  }
  if (pctx && pipeline_dep_ctx_use_coff_o(pctx) != 0) {
    int32_t cw = platform_coff_write_coff_o_to_buf(elf_ctx, out_buf);
    if (getenv("SHUX_ASM_DEBUG"))
      fprintf(stderr, "shux: asm_codegen_elf_o coff_write=%d out_len=%d\n", (int)cw, (int)((struct codegen_CodegenOutBuf *)out_buf)->len);
    pipeline_asm_wpo_reach_clear();
    return cw < 0 ? -1 : 0;
  }
  if (pctx && pipeline_dep_ctx_use_macho_o(pctx) != 0) {
    int32_t mw = platform_macho_write_macho_o_to_buf(elf_ctx, out_buf);
    if (getenv("SHUX_ASM_DEBUG"))
      fprintf(stderr, "shux: asm_codegen_elf_o macho_write=%d out_len=%d\n", (int)mw, (int)((struct codegen_CodegenOutBuf *)out_buf)->len);
    pipeline_asm_wpo_reach_clear();
    return mw < 0 ? -1 : 0;
  }
  {
    int32_t ew = platform_elf_write_elf_o_to_buf(elf_ctx, out_buf);
    if (getenv("SHUX_ASM_DEBUG"))
      fprintf(stderr, "shux: asm_codegen_elf_o elf_write=%d out_len=%d\n", (int)ew, (int)((struct codegen_CodegenOutBuf *)out_buf)->len);
    pipeline_asm_wpo_reach_clear();
    return ew < 0 ? -1 : 0;
  }
}
