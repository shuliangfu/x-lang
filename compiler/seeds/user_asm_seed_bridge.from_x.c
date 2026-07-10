/* seeds/user_asm_seed_bridge.from_x.c — G-02f-15 product TU
 * Product object from this seed; logic still C until full .x port.
 */
/**
 * user_asm_seed_bridge.c — bootstrap-driver-seed 用户程序 asm 后端桥
 *
 * pipeline_x.o（-E-extern 瘦编排）经 extern 调用 asm_asm_codegen_ast / asm_asm_codegen_elf_o；
 * 本文件提供强符号实现，并链入 build_asm/seed_host/asm_backend_partial.o（shux-c -E asm.x 抽出）。
 * 无 C codegen 回退、无 cc -c 汇编 GAS 兜底：asm 失败即返回错误。
 */
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "diag.h"
#include "runtime_diag_codes.h"

/** 与 pipeline 生成体一致的 CodegenOutBuf 布局。 */
struct codegen_CodegenOutBuf {
  uint8_t data[8388608];
  int32_t len;
};

static int seed_asm_debug_enabled(void) {
  return getenv("SHUX_ASM_DEBUG") != NULL;
}

static int seed_asm_emit_trace_enabled(void) {
  return getenv("SHUX_ASM_EMIT_TRACE") != NULL;
}

struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;
struct platform_elf_ElfLabelEntry {
  uint8_t name[64];
  int32_t name_len;
  int32_t offset;
};
struct platform_elf_ElfPatchEntry {
  int32_t rel32_offset;
  uint8_t name[64];
  int32_t name_len;
  int32_t patch_imm_bits;
};
struct platform_elf_ElfRelocEntry {
  int32_t offset;
  int32_t name_len;
};
struct platform_elf_ElfRelocSymName64 {
  uint8_t bytes[64];
};
struct platform_elf_ElfSymEntry {
  uint8_t name[64];
  int32_t name_len;
  int32_t offset;
  int32_t sym_shndx;
};
struct platform_elf_ElfCodegenCtx {
  int32_t code_len;
  struct platform_elf_ElfLabelEntry labels[16384];
  int32_t num_labels;
  struct platform_elf_ElfPatchEntry patches[16384];
  int32_t num_patches;
  struct platform_elf_ElfRelocEntry relocs[16384];
  struct platform_elf_ElfRelocSymName64 reloc_sym_names[16384];
  int32_t num_relocs;
  struct platform_elf_ElfSymEntry syms[16384];
  int32_t num_syms;
  int32_t sym_name_len;
  int32_t e_machine;
  int32_t reloc_type_r_pc32;
  int32_t current_frame_size;
  int32_t macho_leading_underscore;
  int32_t code_hot_len;
  int32_t emit_hot;
  uint8_t code_data[8716288];
  uint8_t code_hot_data[1048576];
  uint8_t sym_name_data[131072];
};

/** pipeline_x.o / ast_pool.c（勿在此 TU 自建截断 PipelineDepCtx，含 4MiB 内嵌缓冲） */
extern int32_t pipeline_dep_ctx_use_macho_o(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_dep_ctx_use_coff_o(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_dep_ctx_asm_entry_module_only(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern struct ast_Module *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern struct ast_ASTArena *pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern void pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *dst);
extern int32_t pipeline_module_num_funcs(struct ast_Module *m);
extern void pipeline_elf_label_mod_scope_reset(void);
extern void pipeline_elf_ctx_reloc_sidecar_reset(uint8_t *ctx_bytes);
extern int32_t pipeline_elf_ctx_resolve_patches(uint8_t *ctx_bytes);
extern void driver_set_current_dep_path_for_codegen(const char *path);
extern int32_t driver_skip_codegen_dep_0_get(void);
/** freestanding 标志：nostdlib 链无预编译 std .o，dep 须全部 co-emit（跳过 skip 检查）。 */
extern int32_t driver_freestanding_get(void);
/** std.io 族由 io.o + 本文件桩提供；seed asm 跳过整族 dep 的机器码生成。 */
extern int32_t pipeline_codegen_dep_skip_asm_user_std_io(uint8_t *path);
extern int32_t pipeline_codegen_dep_skip_asm_user_std_fs(uint8_t *path);
extern int32_t pipeline_codegen_dep_skip_asm_user_std_process(uint8_t *path);
extern int32_t pipeline_codegen_dep_skip_asm_user_std_fmt(uint8_t *path);
extern int32_t pipeline_codegen_dep_skip_asm_user_std_misc(uint8_t *path);
extern int32_t pipeline_codegen_dep_skip_asm_user_core_lib(uint8_t *path);
extern int32_t pipeline_asm_user_std_net_dep_path(uint8_t *path);
extern int32_t pipeline_asm_user_deps_need_coemit(char **dep_paths, int32_t n);
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

/** ast.x extern 前缀转发。 */
double ast_pipeline_expr_float_val_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_float_val_at(a, expr_ref);
}

/** build_asm/seed_host/asm_backend_partial.o（asm.x 全量 -E 抽出） */
extern int32_t backend_asm_emit_one_call_arg_elf_arm64_push(void *arena, void *elf_ctx, int32_t expr_ref, int32_t arg_idx, void *ctx, int32_t ta);

/**
 * ARM64 ELF call 实参 push 阶段：宿主 C for 循环逐参调用 backend，避免 .x 递归/展开叠加深 emit 栈帧 SIGSEGV。
 */
int32_t pipeline_seed_asm_emit_call_args_elf_arm64_push_loop(void *arena, void *elf_ctx, int32_t expr_ref, int32_t reg_n, void *ctx, int32_t ta) {
  int32_t i;
  for (i = 0; i < reg_n; i++) {
    if (seed_asm_debug_enabled()) {
      int32_t arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, i);
      diag_reportf(NULL, 0, 0, "note", NULL,
                   "asm debug: arm64_push_loop i=%d reg_n=%d call_ref=%d arg_ref=%d",
                   (int)i, (int)reg_n, (int)expr_ref, (int)arg_ref);
    }
    if (backend_asm_emit_one_call_arg_elf_arm64_push(arena, elf_ctx, expr_ref, i, ctx, ta) != 0)
      return -1;
  }
  return 0;
}

/** ast.x -E 前缀转发（backend partial.o 经 ast_pipeline_* 调用）。 */
int32_t ast_pipeline_seed_asm_emit_call_args_elf_arm64_push_loop(void *arena, void *elf_ctx, int32_t expr_ref, int32_t reg_n, void *ctx, int32_t ta) {
  return pipeline_seed_asm_emit_call_args_elf_arm64_push_loop(arena, elf_ctx, expr_ref, reg_n, ctx, ta);
}

/** build_asm/seed_host/asm_backend_partial.o（asm.x 全量 -E 抽出） */
extern int32_t backend_asm_codegen_ast(void *module, void *arena, void *out_buf, void *ctx);
extern int32_t backend_asm_codegen_ast_to_elf(void *module, void *arena, void *elf_ctx, void *ctx);
extern int32_t peephole_run(void *out_buf);
extern int32_t peephole_elf_run(void *elf_ctx);
/** ElfCodegenCtx.macho_leading_underscore 偏移（与 ast_pool.c kPipelineElfCtxMachoUnderscoreOff / elf.x 4096 表一致）。 */
#define SHUX_ELF_CTX_MACHO_UNDERSCORE_OFF 598052

/** Darwin -o：call/reloc 符号须 leading `_`（与 asm.x::asm_codegen_elf_o 一致）。 */
static void seed_elf_ctx_set_macho_leading_underscore(void *elf_ctx, int32_t on) {
  if (!elf_ctx)
    return;
  *(int32_t *)((uint8_t *)elf_ctx + SHUX_ELF_CTX_MACHO_UNDERSCORE_OFF) = on ? 1 : 0;
}
/** asm 失败时打印 backend.x 记录的当前函数名。 */
extern void driver_diagnostic_asm_print_current_func(void);
extern int32_t pipeline_asm_patch_module_parent_links(struct ast_Module *m, struct ast_ASTArena *a);
extern void pipeline_asm_wpo_reach_compute_for_elf(struct ast_Module *entry, struct ast_ASTArena *entry_arena,
                                                     struct ast_PipelineDepCtx *ctx);
extern void pipeline_asm_wpo_reach_clear(void);
extern int32_t pipeline_elf_write_o_standard_to_buf_c(uint8_t *ctx_bytes, struct codegen_CodegenOutBuf *out);

void platform_elf_elf_ctx_reset(void *elf_ctx) {
  struct platform_elf_ElfCodegenCtx *ctx = (struct platform_elf_ElfCodegenCtx *)elf_ctx;
  if (!ctx)
    return;
  ctx->code_len = 0;
  ctx->code_hot_len = 0;
  ctx->emit_hot = 0;
  ctx->num_labels = 0;
  ctx->num_patches = 0;
  ctx->num_relocs = 0;
  ctx->num_syms = 0;
  ctx->sym_name_len = 0;
  ctx->macho_leading_underscore = 0;
  pipeline_elf_label_mod_scope_reset();
  pipeline_elf_ctx_reloc_sidecar_reset((uint8_t *)ctx);
}

int32_t platform_elf_elf_resolve_patches(void *elf_ctx) {
  return pipeline_elf_ctx_resolve_patches((uint8_t *)elf_ctx);
}

/** 读 ElfCodegenCtx.code_len（前缀字段；与 platform/elf.x / PipelineElfCtxAccess 一致）。 */
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
  int32_t total_code_len;
  if (!module || !elf_ctx)
    return 0;
  nf = pipeline_module_num_funcs((struct ast_Module *)module);
  if (nf <= 0)
    return 0;
  clen = seed_elf_ctx_code_len(elf_ctx);
  if (clen > 0)
    return 0;
  total_code_len = pipeline_elf_ctx_total_code_len((uint8_t *)elf_ctx);
  if (total_code_len > 0)
    return 0;
  return SHUX_ASM_CODEGEN_ELF_EMPTY_TEXT_RC;
}
/*
 * Seed bridge 仅消费 seed_host/asm_backend_partial.o 提供的真实 writer。
 * 这里不能再定义同名 fallback，否则同一 TU 内调用会静态绑定到本地 stub，
 * 直接把真实的 Mach-O/COFF writer 全部遮蔽掉。
 */
#if defined(__APPLE__)
extern int32_t platform_macho_write_macho_o_to_buf(void *elf_ctx, void *out_buf) __attribute__((weak_import));
#elif defined(_WIN32) || defined(_WIN64)
extern int32_t platform_coff_write_coff_o_to_buf(void *elf_ctx, void *out_buf) __attribute__((weak));
#endif

static int32_t seed_platform_macho_write_macho_o_to_buf(void *elf_ctx, void *out_buf) {
#if defined(__APPLE__)
  if (!platform_macho_write_macho_o_to_buf)
    return -1;
  return platform_macho_write_macho_o_to_buf(elf_ctx, out_buf);
#else
  (void)elf_ctx;
  (void)out_buf;
  return -1;
#endif
}

static int32_t seed_platform_coff_write_coff_o_to_buf(void *elf_ctx, void *out_buf) {
#if defined(_WIN32) || defined(_WIN64)
  if (!platform_coff_write_coff_o_to_buf)
    return -1;
  return platform_coff_write_coff_o_to_buf(elf_ctx, out_buf);
#else
  (void)elf_ctx;
  (void)out_buf;
  return -1;
#endif
}

/** .x 模块名修饰后的 pipeline_module_num_funcs 转发（asm/backend 分 TU 链接）。 */
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
 * 写出 -o .o / -o exe：先各 dep 再入口（与 asm.x::asm_codegen_elf_o 一致），再 reloc + 写 Mach-O/ELF。
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
      if (seed_asm_emit_trace_enabled())
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "asm emit trace: co-emit dep[%d] path=%s funcs=%d",
                     (int)jdep, (char *)dep_path_buf,
                     dep_mod ? (int)pipeline_module_num_funcs(dep_mod) : -1);
      /** freestanding 模式：nostdlib 链无预编译 std .o，跳过 skip（dep 须全部 co-emit）。
       * hosted 模式：std.io/fs/process/fmt 等族符号由预编译 .o 提供，skip 整库 co-emit。 */
      if (driver_freestanding_get() == 0) {
        if (pipeline_codegen_dep_skip_asm_user_std_io(dep_path_buf) != 0)
          continue;
        if (pipeline_codegen_dep_skip_asm_user_std_fs(dep_path_buf) != 0)
          continue;
        if (pipeline_codegen_dep_skip_asm_user_std_process(dep_path_buf) != 0)
          continue;
        if (pipeline_codegen_dep_skip_asm_user_std_fmt(dep_path_buf) != 0)
          continue;
        if (pipeline_codegen_dep_skip_asm_user_std_misc(dep_path_buf) != 0)
          continue;
        if (pipeline_codegen_dep_skip_asm_user_core_lib(dep_path_buf) != 0)
          continue;
      }
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
  if (seed_asm_emit_trace_enabled())
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "asm emit trace: asm_codegen_ast_to_elf entry module funcs=%d",
                 (int)pipeline_module_num_funcs(module));
  pipeline_asm_patch_module_parent_links(module, arena);
  if (backend_asm_codegen_ast_to_elf(module, arena, elf_ctx, ctx) != 0) {
    if (seed_asm_debug_enabled()) {
      diag_report(NULL, 0, 0, "note", "asm debug: asm_codegen_elf_o fail at backend entry", NULL);
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
    if (seed_asm_debug_enabled())
      diag_report(NULL, 0, 0, "note", "asm debug: asm_codegen_elf_o fail at peephole_elf", NULL);
    pipeline_asm_wpo_reach_clear();
    return -1;
  }
  if (elf_ctx && platform_elf_elf_resolve_patches(elf_ctx) != 0) {
    if (seed_asm_debug_enabled())
      diag_report(NULL, 0, 0, "note", "asm debug: asm_codegen_elf_o fail at resolve_patches", NULL);
    pipeline_asm_wpo_reach_clear();
    return -1;
  }
  if (pctx && pipeline_dep_ctx_use_coff_o(pctx) != 0) {
    int32_t cw = seed_platform_coff_write_coff_o_to_buf(elf_ctx, out_buf);
    if (seed_asm_debug_enabled())
      diag_reportf(NULL, 0, 0, "note", NULL,
                   "asm debug: asm_codegen_elf_o coff_write=%d out_len=%d",
                   (int)cw, (int)((struct codegen_CodegenOutBuf *)out_buf)->len);
    pipeline_asm_wpo_reach_clear();
    return cw < 0 ? -1 : 0;
  }
  if (pctx && pipeline_dep_ctx_use_macho_o(pctx) != 0) {
    int32_t mw = seed_platform_macho_write_macho_o_to_buf(elf_ctx, out_buf);
    if (seed_asm_debug_enabled())
      diag_reportf(NULL, 0, 0, "note", NULL,
                   "asm debug: asm_codegen_elf_o macho_write=%d out_len=%d",
                   (int)mw, (int)((struct codegen_CodegenOutBuf *)out_buf)->len);
    pipeline_asm_wpo_reach_clear();
    return mw < 0 ? -1 : 0;
  }
  {
    int32_t ew = pipeline_elf_write_o_standard_to_buf_c((uint8_t *)elf_ctx, (struct codegen_CodegenOutBuf *)out_buf);
    if (seed_asm_debug_enabled())
      diag_reportf(NULL, 0, 0, "note", NULL,
                   "asm debug: asm_codegen_elf_o elf_write=%d out_len=%d",
                   (int)ew, (int)((struct codegen_CodegenOutBuf *)out_buf)->len);
    pipeline_asm_wpo_reach_clear();
    return ew < 0 ? -1 : 0;
  }
}
